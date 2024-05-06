--------------------------------------------------------
--  DDL for Package Body HRSC01E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC01E" as
-- last update: 22/02/2023 12:30
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');

    -- index params
    p_coduser           := upper(hcm_util.get_string_t(json_obj, 'p_coduser_query'));
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_typeauth          := upper(hcm_util.get_string_t(json_obj, 'p_typeauth'));
    p_typeuser          := upper(hcm_util.get_string_t(json_obj, 'p_typeuser'));
    if p_typeuser = '5' then
       p_typeuser := '';
    end if;
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');
    -- tprocapp
    p_codproc           := upper(hcm_util.get_string_t(json_obj, 'p_codproc'));
    -- report
    json_coduser        := hcm_util.get_json_t(json_obj, 'json_coduser');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_flgsecu1        boolean := false;
    v_flgsecu2        boolean := false;
    v_staemp          temploy1.staemp%type;
    v_typeuser        tusrprof.typeuser%type;
    v_typeauth        tusrprof.typeauth%type;
  begin
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
          return;
      else
          v_flgsecu1 := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu1  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
      end if;
    end if;
    if p_codcomp is not null then
      v_flgsecu2 := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu2 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
        return;
      end if;
    end if;

    begin
      select typeuser,typeauth
        into v_typeuser,v_typeauth
        from tusrprof
       where coduser = global_v_coduser;
    exception when no_data_found then
      null;
    end;
    if v_typeuser <> 4 then
      param_msg_error      := get_error_msg_php('HR3005', global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row                json_object_t;
    obj_data               json_object_t;
    v_rcnt                 number;
    v_flgsecu              boolean := false;
    v_flgfound             boolean := false;

    cursor c_tusrprof is
      select a.coduser, b.codempid, typeauth, typeuser
        from tusrprof a, temploy1 b
       where a.codempid = b.codempid
         and a.codempid = nvl(p_codempid, a.codempid)
         and b.codcomp like p_codcomp || '%'
         and a.coduser = nvl(p_coduser, a.coduser)
--         and typeauth like nvl(p_typeauth, typeauth)
         and typeuser like nvl(p_typeuser, typeuser)
         order by a.coduser;
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_tusrprof loop
      v_flgfound  := true;
      v_flgsecu   := secur_main.secur2(c1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecu then
        obj_data          := json_object_t();
        v_rcnt            := v_rcnt + 1;
        obj_data.put('coderror', '200');
        obj_data.put('coduser', c1.coduser);
        obj_data.put('desc_coduser', get_temploy_name(c1.codempid, global_v_lang));
        obj_data.put('codempid', c1.codempid);
        obj_data.put('typeauth', c1.typeauth);
        obj_data.put('desc_typeauth', get_tlistval_name('TYPEAUTH', c1.typeauth, global_v_lang));
        obj_data.put('typeuser', c1.typeuser);
        obj_data.put('desc_typeuser', get_tlistval_name('TYPEUSER', c1.typeuser, global_v_lang));

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    if v_flgfound then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error   := get_error_msg_php('HR3007', global_v_lang, 'tusrprof');
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'tusrprof');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure get_currentusertypauth (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_currentusertypauth(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_currentusertypauth;

  procedure gen_currentusertypauth (json_str_output out clob) is
    obj_data               json_object_t;
    v_typeuser             tusrprof.typeuser%type;
    v_typeauth             tusrprof.typeauth%type;
  begin
    begin
      select typeuser,typeauth
        into v_typeuser,v_typeauth
        from tusrprof
       where coduser = global_v_coduser;
    exception when no_data_found then
      null;
    end;
    if v_typeuser <> 4 then
      param_msg_error      := get_error_msg_php('HR3005', global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('typeuser', v_typeuser);
    obj_data.put('typeauth', v_typeauth);
    obj_data.put('response', nvl(v_typeauth, '4'));

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_currentusertypauth;

  procedure gen_seqnum_tusrlog as
  begin
    begin
      select nvl(max(seqnum), 0)
        into tusrlog_seqnum
        from tusrlog
       where rcupdid = global_v_coduser
         and dteupd  = sysdate;
    end;
  end gen_seqnum_tusrlog;

  function get_tusrprof_field(p_coduser varchar2, p_field varchar2) return varchar2 is
    l_theCursor       integer default dbms_sql.open_cursor;
    l_columnValue     varchar2(4000 char);
    l_status          integer;
    l_descTbl         dbms_sql.desc_tab;
    l_colCnt          number;
    v_query           clob;
  begin
    v_query           := 'select ';
    v_query           := v_query || p_field;
    v_query           := v_query || ' from tusrprof where coduser =  ''' || p_coduser || '''';

    dbms_sql.parse(l_theCursor, v_query, dbms_sql.native);
    dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl);

    for i in 1 .. l_colCnt loop
      dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
    end loop;

    l_status := dbms_sql.execute(l_theCursor);
    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
      for i in 1 .. l_colCnt loop
        dbms_sql.column_value( l_theCursor, i, l_columnValue );
      end loop;
    end loop;
    dbms_sql.close_cursor( l_theCursor );
    return l_columnValue;
  exception when others then dbms_sql.close_cursor( l_theCursor ); RAISE;
  end get_tusrprof_field;

  procedure save_tusrlog (v_table in varchar2, v_column in varchar2, v_descnew in varchar2, v_descoldInput in varchar2 default null) as
    v_descold               varchar2(4000 char);
  begin
    v_descold               := v_descoldInput;
    if upper(v_table) = 'TUSRPROF' and v_column not in ('coduser', 'codpswd', 'numlvlst', 'numlvlen', 'numlvlsalst', 'numlvlsalen') then
      v_descold             := get_tusrprof_field(tusrprof_coduser, v_column);
    end if;
    if nvl(v_descold, '@#$%') <> nvl(v_descnew, '@#$%') or v_column = 'codpswd' then
      tusrlog_seqnum        := tusrlog_seqnum + 1;
      begin
        insert
          into tusrlog
               (rcupdid, dteupd, seqnum, coduser, codtable, codcolmn, descold, descnew)
        values (global_v_coduser, sysdate, tusrlog_seqnum, tusrprof_coduser, upper(v_table), upper(v_column), v_descold, v_descnew);
      exception when others then
        null;
      end;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end save_tusrlog;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_coduser           tusrprof.coduser%type;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_seqnum_tusrlog;
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_coduser         := upper(hcm_util.get_string_t(json_row, 'coduser'));
        tusrprof_coduser  := v_coduser;
        if param_msg_error is not null then
          exit;
        end if;
        if v_flg = 'delete' then
          begin
            delete from tusrprof
             where coduser = v_coduser;
            save_tusrlog('tusrprof', 'coduser', '', v_coduser);
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
          end;
          if param_msg_error is not null then
            exit;
          end if;
          begin
            delete from users
             where email = v_coduser;
            save_tusrlog('users', 'email', '', v_coduser);
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
          end;
          if param_msg_error is not null then
            exit;
          end if;
          begin
            delete from tusrproc
             where coduser = v_coduser;
            save_tusrlog('tusrproc', 'coduser', '', v_coduser);
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
          end;
          if param_msg_error is not null then
            exit;
          end if;
          begin
            delete from tusrproac
             where coduser = v_coduser;
            save_tusrlog('tusrproac', 'coduser', '', v_coduser);
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
          end;
          if param_msg_error is not null then
            exit;
          end if;
          begin
            Delete From tusrcom
             Where coduser = v_coduser;
            save_tusrlog('tusrcom', 'coduser', '', v_coduser);
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;
  --
  procedure check_detail is
    v_flgsecu1        boolean := false;
    v_flgsecu2        boolean := false;
    v_staemp          temploy1.staemp%type;
    v_coduser         tusrprof.coduser%type;
    v_codempid        tusrprof.codempid%type;
  begin
    if p_coduser is not null then
      begin
        select coduser, codempid
          into v_coduser, v_codempid
          from tusrprof
         where coduser = p_coduser;
      exception when no_data_found then
        v_codempid := '';
      end;
      if p_coduser <> global_v_coduser then -- if edit myself not check secure
        if v_codempid is not null then
          v_flgsecu1   := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu1 then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
        end if;
      end if;
    end if;
  end check_detail;
  --
  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_data               json_object_t;
    v_coduser              tusrprof.coduser%type;
    v_codempid             tusrprof.codempid%type;
    v_userdomain           tusrprof.userdomain%type;
    v_typeauth             tusrprof.typeauth%type;
    v_typeuser             tusrprof.typeuser%type;
    v_flgact               tusrprof.flgact%type;
    v_codpswd              tusrprof.codpswd%type;
    v_timepswd             tusrprof.timepswd%type;
    v_codsecu              tusrprof.codsecu%type;
    v_flgauth              tusrprof.flgauth%type;
    v_numlvlst             tusrprof.numlvlst%type;
    v_numlvlen             tusrprof.numlvlen%type;
    v_numlvlsalst          tusrprof.numlvlsalst%type;
    v_numlvlsalen          tusrprof.numlvlsalen%type;
    v_eventBtn             varchar2(10 char);

  begin
    begin
      select coduser, codempid, userdomain, typeauth, typeuser, flgact,
             codpswd, timepswd, codsecu, flgauth, pwddec(numlvlst, coduser, v_chken) numlvlst, pwddec(numlvlen, coduser, v_chken) numlvlen, pwddec(numlvlsalst, coduser, v_chken) numlvlsalst, pwddec(numlvlsalen, coduser, v_chken) numlvlsalen
        into v_coduser, v_codempid, v_userdomain, v_typeauth, v_typeuser, v_flgact,
             v_codpswd, v_timepswd, v_codsecu, v_flgauth, v_numlvlst, v_numlvlen, v_numlvlsalst, v_numlvlsalen
        from tusrprof
      where coduser = p_coduser;
      v_eventBtn := 'edit';
    exception when no_data_found then
      v_eventBtn := 'add';
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('coduser', p_coduser);
    obj_data.put('codempid', v_codempid);
    obj_data.put('userdomain', v_userdomain);
    obj_data.put('typeauth', nvl(v_typeauth, '4'));
    obj_data.put('typeuser', nvl(v_typeuser, '1'));
    obj_data.put('typeuser_old', nvl(v_typeuser, '1'));
    obj_data.put('flgact', nvl(v_flgact, '1'));
    obj_data.put('codpswd', v_codpswd);
    obj_data.put('timepswd', v_timepswd);
    obj_data.put('codsecu', v_codsecu);
    obj_data.put('flgauth', nvl(v_flgauth, '2'));
    obj_data.put('numlvlst', to_char(v_numlvlst));
    obj_data.put('numlvlen', to_char(v_numlvlen));
    obj_data.put('numlvlsalst', to_char(v_numlvlsalst));
    obj_data.put('numlvlsalen', to_char(v_numlvlsalen));
    obj_data.put('salary_lvst', to_char(global_v_numlvlsalst));
    obj_data.put('salary_lven', to_char(global_v_numlvlsalen));
    obj_data.put('typeuser_old', nvl(v_typeuser, '1'));
    obj_data.put('codempid_old', v_codempid);
    obj_data.put('eventBtn', v_eventBtn);

    if isInsertReport then
      insert_ttemprpt(obj_data);
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

  procedure get_emp_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_emp_data(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_emp_data;

  procedure gen_emp_data (json_str_output out clob) is
    obj_data               json_object_t;
    v_codempid             tusrprof.codempid%type;
    v_typeuser             tusrprof.typeuser%type;
    v_numlvl               temploy1.numlvl%type;
    v_numlvlst             tusrprof.numlvlst%type;
    v_numlvlen             tusrprof.numlvlen%type;
    v_numlvlsalst          tusrprof.numlvlsalst%type;
    v_numlvlsalen          tusrprof.numlvlsalen%type;

  begin

    begin
      select  codempid,numlvl
        into v_codempid, v_numlvl
        from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      null;
    end;

    if p_typeuser = '2' then
       v_numlvlst := v_numlvl;
       v_numlvlen := v_numlvl;
       v_numlvlsalst := '0';
       v_numlvlsalen := '0';
    elsif p_typeuser = '3' then
       v_numlvlst := '1';
       v_numlvlen := v_numlvl;
       v_numlvlsalst := '0';
       v_numlvlsalen := '0';
    else
       v_numlvlst := '0';
       v_numlvlen := '0';
       v_numlvlsalst := '0';
       v_numlvlsalen := '0';
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('typeuser', p_typeuser);
    obj_data.put('numlvlst', to_char(v_numlvlst));
    obj_data.put('numlvlen', to_char(v_numlvlen));
    obj_data.put('numlvlsalst', to_char(v_numlvlsalst));
    obj_data.put('numlvlsalen', to_char(v_numlvlsalen));

    if isInsertReport then
      insert_ttemprpt(obj_data);
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_emp_data;

  procedure get_tusrcom (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tusrcom(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tusrcom;

  procedure gen_tusrcom (json_str_output out clob) is
    obj_row                json_object_t;
    obj_data               json_object_t;
    v_rcnt                 number;

    cursor c_tusrcom is
      select coduser, codcomp
        from tusrcom
       where coduser  in
          (
            select coduser
              from tusrprof
             where coduser = p_coduser
          );
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_tusrcom loop
      obj_data          := json_object_t();
      v_rcnt            := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('coduser', c1.coduser);
      obj_data.put('codcomp', c1.codcomp);

      if isInsertReport then
        insert_ttemprpt_comp(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tusrcom;

  procedure get_emp_data_tusrcom (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_emp_data_tusrcom(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_emp_data_tusrcom;

  procedure gen_emp_data_tusrcom (json_str_output out clob) is
    obj_row                json_object_t;
    obj_data               json_object_t;
    v_rcnt                 number;
    v_codcomp              varchar2(200);

    cursor c_tusrcom is
      select coduser, codcomp
        from tusrcom
       where coduser  in
          (
            select coduser
              from tusrprof
             where coduser = p_coduser
          );
    cursor c_tusrcom2 is
      select codcomp
        from temploy1
       where codempid = p_codempid;
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;

    if p_typeuser = '2' or p_typeuser = '3' then  -- employee, head
        for c2 in c_tusrcom2 loop
          obj_data          := json_object_t();
          v_rcnt            := v_rcnt + 1;
            if p_typeuser = '2' then
               v_codcomp := hcm_util.get_codcomp_level(c2.codcomp,null,'-','Y');
            elsif p_typeuser = '3' then
               v_codcomp := hcm_util.get_codcomp_level(c2.codcomp,null,'-');
            end if;

            obj_data.put('coderror', '200');
            obj_data.put('coduser', p_coduser);
            obj_data.put('codcomp', v_codcomp);

            obj_row.put(to_char(v_rcnt - 1), obj_data);
        end loop;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_emp_data_tusrcom;

  procedure get_tusrproc (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tusrproc(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tusrproc;

  function gen_tusrproac(v_codproc varchar2) return json_object_t is
    obj_row                json_object_t;
    v_rcnt                 number;

    cursor c_tusrproac is
      select coduser, codproc, codapp
        from tusrproac
       where coduser = p_coduser
         and codproc = v_codproc;
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_tusrproac loop
      v_rcnt            := v_rcnt + 1;
      obj_row.put(to_char(v_rcnt - 1), c1.codapp);
    end loop;

    return obj_row;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end gen_tusrproac;

  procedure gen_tusrproc (json_str_output out clob) is
    obj_row                json_object_t;
    obj_data               json_object_t;
    v_rcnt                 number;

    cursor c_tusrproc is
      select coduser, codproc, flgauth
        from tusrproc
       where coduser = p_coduser;
  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_tusrproc loop
      obj_data          := json_object_t();
      v_rcnt            := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('coduser', c1.coduser);
      obj_data.put('codproc', c1.codproc);
      obj_data.put('flgauth', c1.flgauth);
      obj_data.put('tusrproac', gen_tusrproac(c1.codproc));

      if isInsertReport then
        insert_ttemprpt_proc(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tusrproc;

  procedure check_save_tusrprof as
    v_passenc             varchar2(4000 char);
  begin
    if tusrprof_coduser is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    begin
        v_passenc := pwdenc(tusrprof_codpswd, tusrprof_coduser, v_chken);
    exception when others then
        param_msg_error := get_error_msg_php('HR3015', global_v_lang);
        return;
    end;

--    if (tusrprof_numlvlst <= global_v_zminlvl or tusrprof_numlvlst >= global_v_zwrklvl) and (tusrprof_numlvlen >= global_v_zwrklvl or tusrprof_numlvlen <= global_v_zwrklvl) then
--      param_msg_error := get_error_msg_php('HR3091', global_v_lang);
--      return;
--    end if;
--    if (tusrprof_numlvlsalst <= global_v_numlvlsalst or tusrprof_numlvlsalst >= global_v_numlvlsalen) and (tusrprof_numlvlsalen >= global_v_numlvlsalen or tusrprof_numlvlsalen <= global_v_numlvlsalen) then
--      param_msg_error := get_error_msg_php('HR3091', global_v_lang);
--    end if;
  end;

  procedure save_tusrprof as
    b_flgchgpass          tusrprof.flgchgpass%type := 'N';
    b_codpswd             varchar2(4000 char);
    b_numlvlst            varchar2(4000 char);
    b_numlvlen            varchar2(4000 char);
    b_numlvlsalst         varchar2(4000 char);
    b_numlvlsalen         varchar2(4000 char);
  begin
    begin
      select codpswd, flgchgpass, pwddec(numlvlst, tusrprof_coduser, v_chken), pwddec(numlvlen, tusrprof_coduser, v_chken), pwddec(numlvlsalst, tusrprof_coduser, v_chken), pwddec(numlvlsalen, tusrprof_coduser, v_chken)
        into b_codpswd, b_flgchgpass, b_numlvlst, b_numlvlen, b_numlvlsalst, b_numlvlsalen
        from tusrprof
       where coduser = tusrprof_coduser;
    exception when no_data_found then
      null;
    end;
    check_save_tusrprof;
    if nvl(b_codpswd, '@#$%') <> nvl(tusrprof_codpswd, '@#$%') then
      save_tusrlog('tusrprof', 'codpswd', '*****', '*****');
      b_flgchgpass := 'N';
    end if;
    if param_msg_error is null then
      save_tusrlog('tusrprof', 'codempid', tusrprof_codempid);
      save_tusrlog('tusrprof', 'userdomain', tusrprof_userdomain);
      save_tusrlog('tusrprof', 'flgact', tusrprof_flgact);
      save_tusrlog('tusrprof', 'flgauth', tusrprof_flgauth);
      save_tusrlog('tusrprof', 'codsecu', tusrprof_codsecu);
      save_tusrlog('tusrprof', 'timepswd', tusrprof_timepswd);
      save_tusrlog('tusrprof', 'typeauth', tusrprof_typeauth);
      save_tusrlog('tusrprof', 'typeuser', tusrprof_typeuser);
      save_tusrlog('tusrprof', 'numlvlst', tusrprof_numlvlst, b_numlvlst);
      save_tusrlog('tusrprof', 'numlvlen', tusrprof_numlvlen, b_numlvlen);
      save_tusrlog('tusrprof', 'numlvlsalst', tusrprof_numlvlsalst, b_numlvlsalst);
      save_tusrlog('tusrprof', 'numlvlsalen', tusrprof_numlvlsalen, b_numlvlsalen);
      save_tusrlog('tusrprof', 'flgchgpass', b_flgchgpass);
      begin
        insert into tusrprof
              (
                coduser, codempid, userdomain,
                flgact, codpswd, flgauth,
                codsecu, timepswd, typeauth,
                numlvlst, numlvlen, numlvlsalst, numlvlsalen,
                typeuser, dtecreate, usrcreate, flgchgpass, coduser2
              )
        values
              (
                tusrprof_coduser, tusrprof_codempid, tusrprof_userdomain,
                tusrprof_flgact, pwdenc(tusrprof_codpswd, tusrprof_coduser, v_chken), tusrprof_flgauth,
                tusrprof_codsecu, tusrprof_timepswd, tusrprof_typeauth,
                pwdenc(tusrprof_numlvlst, tusrprof_coduser, v_chken), pwdenc(tusrprof_numlvlen, tusrprof_coduser, v_chken), pwdenc(tusrprof_numlvlsalst, tusrprof_coduser, v_chken), pwdenc(tusrprof_numlvlsalen, tusrprof_coduser, v_chken),
                tusrprof_typeuser, sysdate, global_v_coduser, b_flgchgpass, global_v_coduser
              );
      exception when dup_val_on_index then
        update tusrprof
           set codempid    = tusrprof_codempid,
               userdomain  = tusrprof_userdomain,
               flgact      = tusrprof_flgact,
               flgauth     = tusrprof_flgauth,
               codsecu     = tusrprof_codsecu,
               timepswd    = tusrprof_timepswd,
               typeauth    = tusrprof_typeauth,
               typeuser    = tusrprof_typeuser,
               numlvlst    = pwdenc(tusrprof_numlvlst, tusrprof_coduser, v_chken),
               numlvlen    = pwdenc(tusrprof_numlvlen, tusrprof_coduser, v_chken),
               numlvlsalst = pwdenc(tusrprof_numlvlsalst, tusrprof_coduser, v_chken),
               numlvlsalen = pwdenc(tusrprof_numlvlsalen, tusrprof_coduser, v_chken),
               dtercupd    = sysdate,
               rcupdid     = global_v_coduser,
               dteupd      = sysdate,
               flgchgpass  = b_flgchgpass,
               coduser2    = global_v_coduser
         where coduser     = tusrprof_coduser;
      end;
      -- users
      begin
        insert into users (name, email, password, is_client, created_at, updated_at, username, codempid)
        values (tusrprof_coduser, tusrprof_coduser, p_codpswd_hash, '1', sysdate, sysdate, tusrprof_coduser, tusrprof_codempid);
      exception when dup_val_on_index then
        update users
           set codempid   = tusrprof_codempid,
               updated_at = sysdate
         where email      = tusrprof_coduser;
        if nvl(b_codpswd, '@#$%') <> nvl(tusrprof_codpswd, '@#$%') then
          update tusrprof
             set codpswd = pwdenc(tusrprof_codpswd, tusrprof_coduser, v_chken)
           where coduser = tusrprof_coduser;
          update users
            set password   = p_codpswd_hash,
                codempid   = tusrprof_codempid,
                updated_at = sysdate
          where email      = tusrprof_coduser;
        end if;
      end;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end save_tusrprof;

  procedure initail_save as
  begin
    -- save detail
    tusrprof_coduser     := hcm_util.get_string_t(json_params, 'coduser');
    tusrprof_codempid    := hcm_util.get_string_t(json_params, 'codempid');
    tusrprof_userdomain  := hcm_util.get_string_t(json_params, 'userdomain');
    tusrprof_flgact      := hcm_util.get_string_t(json_params, 'flgact');
    tusrprof_codpswd     := hcm_util.get_string_t(json_params, 'codpswd');
    p_codpswd_hash       := hcm_util.get_string_t(json_params, 'codpswd_hash');
    tusrprof_flgauth     := hcm_util.get_string_t(json_params, 'flgauth');
    tusrprof_codsecu     := hcm_util.get_string_t(json_params, 'codsecu');
    tusrprof_timepswd    := to_number(hcm_util.get_string_t(json_params, 'timepswd'));
    tusrprof_typeauth    := hcm_util.get_string_t(json_params, 'typeauth');
    tusrprof_typeuser    := hcm_util.get_string_t(json_params, 'typeuser');
    tusrprof_numlvlst    := hcm_util.get_string_t(json_params, 'numlvlst');
    tusrprof_numlvlen    := hcm_util.get_string_t(json_params, 'numlvlen');
    tusrprof_numlvlsalst := hcm_util.get_string_t(json_params, 'numlvlsalst');
    tusrprof_numlvlsalen := hcm_util.get_string_t(json_params, 'numlvlsalen');
    gen_seqnum_tusrlog;
  end initail_save;

  procedure save_tusrcom is
    json_row            json_object_t;
    json_obj            json_object_t;
    v_flg_delete        boolean;
    v_codcomp           tusrcom.codcomp%type;
    v_flgsecu           boolean := false;

    -- for log file
    v_flglog            varchar2(100 char);
    v_tusrcom_key       varchar2(100 char);
    type arr_1d is table of varchar2(4000 char) index by varchar2(4000 char);
      a_tusrcom         arr_1d;

    cursor c_tusrcom is
      select codcomp
        from tusrcom
       where coduser = tusrprof_coduser;
  begin
    json_obj          := hcm_util.get_json_t(json_params, 'tableTab1');

    -- for log file
    for r_tusrcom in c_tusrcom loop
      a_tusrcom(r_tusrcom.codcomp) := 'delete';
    end loop;

    -- delete all before insert
    delete from tusrcom where coduser  = tusrprof_coduser;

    for i in 0..json_obj.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_obj, to_char(i));
      v_flg_delete      := hcm_util.get_boolean_t(json_row, 'flgDelete');
      v_codcomp         := upper(hcm_util.get_string_t(json_row, 'codcomp'));

      -- check secur codcomp
      if tusrprof_coduser <> global_v_coduser then -- if edit myself not check secure
        if v_codcomp is not null then
--          v_flgsecu := secur_main.secur7(v_codcomp, global_v_coduser);
--          if not v_flgsecu then
--            param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
--            return;
--          end if;

         -- << wanlapa ||issue:#9036 22/02/2023
          if v_flg_delete = false then
            v_flgsecu := secur_main.secur7(v_codcomp, global_v_coduser);
              if not v_flgsecu then
                param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
                return;
              end if;
         end if;
         -- >> wanlapa ||issue:#9036 22/02/2023

        end if;
      end if;

      if not v_flg_delete then -- case add or edit
        begin -- check log
          a_tusrcom(v_codcomp) := a_tusrcom(v_codcomp);
          a_tusrcom(v_codcomp) := 'old';
        exception when others then
          a_tusrcom(v_codcomp) := 'add';
        end;

        begin
          insert into tusrcom (coduser, codcomp,rcupdid, dteupd, codcreate)
             values(tusrprof_coduser, v_codcomp,global_v_coduser, sysdate, global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      end if;
    end loop;

    -- insert log
    v_tusrcom_key := a_tusrcom.first;
    while v_tusrcom_key is not null loop
      v_flglog := a_tusrcom(v_tusrcom_key);
      if v_flglog = 'add' then
        save_tusrlog('tusrcom', 'codcomp', v_tusrcom_key);
      elsif v_flglog = 'delete' then
        save_tusrlog('tusrcom', 'codcomp', '', v_tusrcom_key);
      end if;
      v_tusrcom_key := a_tusrcom.NEXT(v_tusrcom_key);
    end loop;

  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end save_tusrcom;

  procedure save_tusrproc is
    json_row            json_object_t;
    json_obj            json_object_t;
    v_flg               varchar2(100 char);
    v_codproc           tusrproc.codproc%type;
    v_codprocOld        tusrproc.codproc%type;
    v_flgauth           tusrproc.flgauth%type;
    v_flgauthOld        tusrproc.flgauth%type;
    json_data           json_object_t;
    v_codapp            tusrproac.codapp%type;
    v_check             varchar2(10);
--<< user22 : 07/08/2022 : ST11 ||
    cursor c1 is
      select a.coduser,a.flgact,b.codproc
        from tusrprof a, tusrproc b
       where a.coduser = b.coduser
         and a.coduser = tusrprof_coduser;
-->> user22 : 07/08/2022 : ST11 ||         
  begin
    json_obj          := hcm_util.get_json_t(json_params, 'tableTab2');

    for i in 0..json_obj.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_obj, to_char(i));
      v_flg             := hcm_util.get_string_t(json_row, 'flg');
      v_codproc         := upper(hcm_util.get_string_t(json_row, 'codproc'));
      v_codprocOld      := upper(hcm_util.get_string_t(json_row, 'codprocOld'));
      v_flgauth         := hcm_util.get_string_t(json_row, 'flgauth');
      v_flgauthOld      := hcm_util.get_string_t(json_row, 'flgauthOld');

      if v_codproc is null or v_flgauth is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        exit;
      end if;
      if v_flg = 'delete' then
        begin
          delete
            from tusrproc
           where coduser = tusrprof_coduser
             and codproc = v_codproc;
          save_tusrlog('tusrproc', 'codproc', '', v_codproc);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
        end;
        if param_msg_error is null then
          begin
            delete from tusrproac
                  where coduser = tusrprof_coduser
                    and codproc = v_codproc;
--            save_tusrlog('tusrproac', 'codproc', '', v_codproc);
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
          end;
        end if;
      else
        begin
          delete from tusrproac
                where coduser = tusrprof_coduser
                  and codproc = v_codproc;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
        end;
        begin
          if v_flg = 'add' then
            insert into tusrproc ( coduser, codproc, flgauth, dteupd, rcupdid )
                 values ( tusrprof_coduser, v_codproc, v_flgauth, sysdate, global_v_coduser );
            save_tusrlog('tusrproc', 'codproc', v_codproc, '');
            save_tusrlog('tusrproc', 'flgauth', v_flgauth, '');
          else
            update tusrproc
               set coduser = tusrprof_coduser,
                   codproc = v_codproc,
                   flgauth = v_flgauth
             where coduser = tusrprof_coduser
               and codproc = v_codprocOld;

            if v_codproc <> v_codprocOld then
              save_tusrlog('tusrproc', 'codproc', v_codproc, v_codprocOld);
            end if;
            if v_flgauth <> v_flgauthOld then
              save_tusrlog('tusrproc', 'flgauth', v_flgauth, v_flgauthOld);
            end if;
          end if;
        exception when dup_val_on_index then
          null;
        end;
        if v_flgauth = '3' then
          json_data         := hcm_util.get_json_t(json_row, 'tusrproac');
          for i in 0..json_data.get_size - 1 loop
            v_codapp           := hcm_util.get_string_t(json_data, to_char(i));
            begin
              insert into tusrproac ( coduser, codproc, codapp, codcreate, coduserupd )
                   values ( tusrprof_coduser, v_codproc, v_codapp, global_v_coduser, global_v_coduser );

              save_tusrlog('tusrproac', 'codapp', v_codproc || ' - ' || v_codapp);
            exception when dup_val_on_index then
              null;
            end;
          end loop;
        end if;
      end if;
    end loop;
--<< user22 : 07/08/2022 : ST11 ||
    for i in c1 loop
      v_check := std_sc.chk_license_by_user(i.codproc, i.coduser, i.flgact);
      if v_check = 'N' then
        param_msg_error := get_error_msg_php('HR8888', global_v_lang);
        exit;        
      end if;    
    end loop;
-->> user22 : 07/08/2022 : ST11 ||          
    if param_msg_error is not null then
      return;
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end save_tusrproc;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_coduser           tusrprof.coduser%type;

  begin
    initial_value (json_str_input);
    initail_save;
    if param_msg_error is null then
      save_tusrprof;
    end if;
    if param_msg_error is null then
      save_tusrcom;
    end if;
    if param_msg_error is null then
      save_tusrproc;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;

    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;

  procedure get_tprocapp (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_tprocapp (json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_tprocapp;

  function check_typapp (v_codapp varchar2) return varchar2 is
    v_typapp      tappprof.typapp%type := '#';
  begin
    begin
      select typapp
        into v_typapp
        from tappprof
       where codapp = v_codapp;
    exception when no_data_found then
      null;
    end;
    return v_typapp;
  end;

  procedure gen_tprocapp (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1_tprocapp is
      select numseq1, numseq2, numseq3, numseq4,
             decode(global_v_lang, '101', a.desappe
                                 , '102', a.desappt
                                 , '103', a.desapp3
                                 , '104', a.desapp4
                                 , '105', a.desapp5
                                 , '') desapp,
             a.codapp, a.desappe, a.desappt, a.desapp3, a.desapp4, a.desapp5,
             a.dteupd, a.coduser
       from tprocapp a
       where a.codproc = p_codproc
       and (a.codapp in (select b.codapp from tappprof b where a.codapp = b.codapp and b.typapp   <> 'R' )
       or a.codapp not in (select b.codapp from tappprof b where a.codapp = b.codapp ) )
       order by numseq1, numseq2, numseq3, numseq4;
  begin
    obj_row             := json_object_t();

    for r1 in c1_tprocapp loop
      if check_typapp(r1.codapp) <> 'R' then
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codproc', p_codproc);
        obj_data.put('numseq1', r1.numseq1);
        obj_data.put('numseq2', r1.numseq2);
        obj_data.put('numseq3', r1.numseq3);
        obj_data.put('numseq4', r1.numseq4);
        obj_data.put('codapp', r1.codapp);
        obj_data.put('desapp', r1.desapp);
        obj_data.put('desappe', r1.desappe);
        obj_data.put('desappt', r1.desappt);
        obj_data.put('desapp3', r1.desapp3);
        obj_data.put('desapp4', r1.desapp4);
        obj_data.put('desapp5', r1.desapp5);
        obj_data.put('dteupd', to_char(r1.dteupd, 'dd/mm/yyyy'));
        obj_data.put('coduser', r1.coduser);
        obj_data.put('desc_coduser', r1.coduser || ' - ' || get_temploy_name(get_codempid(r1.coduser), global_v_lang));

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tprocapp;


  procedure set_column_label(p_codform      in varchar2) is
    cursor c1 is
      select decode(global_v_lang, '101', descripe
                               , '102', descript
                               , '103', descrip3
                               , '104', descrip4
                               , '105', descrip5) as desc_label,
             b.codtable,b.ffield,b.flgdesc
        from tfrmmail a,tfrmmailp b
       where a.codform   = p_codform
         and a.codform   = b.codform
       order by b.numseq;
    v_index         number;
    v_sum_length    number;
    v_codtable      varchar2(15 char);
    v_codcolmn      varchar2(60 char);
    v_funcdesc      varchar2(200 char);
    v_data_type     varchar2(200 char);
    v_max_col       number;
    type t_array_num is table of number index by binary_integer;
      p_col_length    t_array_num;
  BEGIN

    for x in 1..p_max_column loop
      p_column_label(x)   := null;
      p_text_align(x)     := null; --user36 #7053 04/10/2021
    end loop;

    --<< for column numseq
    v_index         := 1;
    p_col_length(1) := 2;
    v_sum_length    := 2;
    -->> for column numseq

    for i in c1 loop
      v_codtable    := i.codtable;
      v_codcolmn    := i.ffield;
      v_index       := v_index + 1;
      exit when v_index > p_max_column;
      begin
        select funcdesc ,data_type into v_funcdesc, v_data_type
          from tcoldesc
         where codtable = v_codtable
           and codcolmn = v_codcolmn;
      exception when no_data_found then
        v_funcdesc := null;
      end;

      if v_data_type = 'DATE' then
        p_col_length(v_index) := 2;
      elsif v_codcolmn like 'TIM%' then
        p_col_length(v_index) := 2;
      elsif v_data_type = 'NUMBER' or (v_codcolmn like 'COD%' and nvl(i.flgdesc,'N') <> 'Y') then
        p_col_length(v_index) := 3;
      else
        p_col_length(v_index) := 5;
      end if;

      v_sum_length                  := v_sum_length + p_col_length(v_index);
      p_column_label(v_index - 1)   := i.desc_label;
    end loop;
    -- cal width column
    v_max_col     := least(p_max_column,p_col_length.count);
    for n in 1..v_max_col loop
      p_column_width(n)   := to_char(trunc(p_col_length(n)*100/v_sum_length));
    end loop;
  end;
  --
  procedure get_column_value(p_codempid     in temploy1.codempid%type,
                             p_rowid        in varchar2,
                             p_codform      in varchar2) is
    v_codtable    varchar2(15 char);
    v_codcolmn    varchar2(60 char);
    v_funcdesc    varchar2(200 char);
    v_flgchksal   varchar2(1 char);
    v_statmt      clob;
    v_value       varchar2(500 char);
    v_data_type   varchar2(200 char);

    v_codempid_req    temploy1.codempid%type;
    v_col_index   number;

    cursor c1 is
      select b.fparam,b.ffield,
             b.codtable,c.fwhere,
             'select '||b.ffield||' from '||b.codtable||' where '||c.fwhere as stm ,flgdesc
          from tfrmmail a,tfrmmailp b,tfrmtab c
          where a.codform   = p_codform
            and a.codform   = b.codform
            and a.typfrm    = c.typfrm
            and b.codtable  = c.codtable
       order by b.numseq;
  BEGIN
    v_col_index   := 0;
    for x in 1..p_max_column loop
      p_column_value(x)   := null;
    end loop;
    for i in c1 loop
      v_codtable    := i.codtable;
      v_codcolmn    := i.ffield;
      v_col_index   := v_col_index + 1;

      begin
        select funcdesc ,flgchksal, data_type into v_funcdesc,v_flgchksal,v_data_type
          from tcoldesc
         where codtable = v_codtable
           and codcolmn = v_codcolmn;
      exception when no_data_found then
        v_funcdesc    := null;
        v_flgchksal   := 'N' ;
      end;

      if nvl(i.flgdesc,'N') = 'N' then
        v_funcdesc := null;
      end if;

      if v_flgchksal = 'Y' then
        v_statmt  := 'select to_char(stddec('||i.ffield||',codempid,'''||v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_data_type = 'NUMBER' and i.ffield not in ('NUMSEQ','SEQNO') then
        v_statmt  := 'select to_char('||i.ffield||',''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
      elsif upper(v_codcolmn) = 'CODPSWD' and upper(v_codtable) = 'TUSRPROF' then
        v_statmt  := 'select pwddec('||i.ffield||',coduser,'''||v_chken||''') from '||i.codtable ||' where  '||i.fwhere ;
      elsif upper(v_codcolmn) = 'TYPEUSER' and upper(v_codtable) = 'TUSRPROF' then
        v_statmt  := 'select get_tlistval_name(''TYPEUSER'','||i.ffield||','''||global_v_lang||''') from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_funcdesc is not null and i.flgdesc = 'Y' then
        v_funcdesc := replace(v_funcdesc,'P_CODE',i.ffield) ;
        v_funcdesc := replace(v_funcdesc,'P_LANG',global_v_lang) ;
        v_funcdesc := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
        v_funcdesc := replace(v_funcdesc,'P_TEXT',v_chken) ;
        v_statmt  := 'select '||v_funcdesc||' from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_data_type = 'DATE' then
        v_statmt  := 'select to_char('||i.ffield||',''dd/mm/yyyy'') from '||i.codtable ||' where  '||i.fwhere ;
      else
        v_statmt  := i.stm ;
      end if;

      v_statmt    := replace(v_statmt,'[#CODEMPID]',p_codempid);
      v_statmt    := replace(v_statmt,'[#ROWID]',p_rowid);

      v_value   := execute_desc(v_statmt) ;
      if i.ffield like 'TIM%' then
        if v_value is not null then
          declare
            v_chk_length    number;
          begin
            select  char_length
            into    v_chk_length
            from    user_tab_columns
            where   table_name    = i.codtable
            and     column_name   = i.ffield;
            if v_chk_length = 4 then
              v_value   := substr(lpad(v_value,4,'0'),1,2)||':'||substr(lpad(v_value,4,'0'),-2,2);
            end if;
          exception when no_data_found then
            null;
          end;
        else
          v_value := ' ';
        end if;
      end if;

      if v_flgchksal = 'Y' then
        v_value   := null ;
      end if;
      if (i.ffield like 'TIM%') or (i.ffield like 'COD%' and nvl(i.flgdesc,'N') <> 'Y') or (v_data_type = 'DATE') or (i.ffield in ('NUMSEQ','SEQNO')) then
        p_text_align(v_col_index)   := 'center';
      elsif v_data_type = 'NUMBER' then
        p_text_align(v_col_index)   := 'right';
      else
        p_text_align(v_col_index)   := 'left';
      end if;
      p_column_value(v_col_index)  := v_value;
    end loop;
  end;

  procedure post_send_mail (json_str_input in clob, json_str_output out clob) is
    v_name        varchar2(1000 char);
    v_subject     varchar2(1000 char);
    v_temp        varchar2(1000 char);
    v_error       varchar2(1000 char);
    v_msg         tfrmmail.messagee%type;
    v_send        temploy1.email%type;
    v_codempid    varchar2(1000 char);
    p_data_list     clob;

    v_data_table     clob;
    v_data_list      clob;
    v_num            number := 0;
    v_chkmax         varchar2(1 char);
    v_bgcolor        varchar2(20 char);
    v_rowid          rowid;
    v_max_col        number := 0;
    crlf        varchar2( 2 ):= chr( 13 ) || chr( 10 );

     cursor c1 is
        select rowid,tusrprof.*
          from tusrprof
         where coduser = p_coduser;

  begin
    initial_value (json_str_input);
    v_name := get_temploy_name(get_codempid(p_coduser), global_v_lang);
    begin
      select decode(global_v_lang, '101', messagee,
                                   '102', messaget,
                                   '103', message3,
                                   '104', message4,
                                   '105', message5,
                                   messagee)
        into v_msg
        from tfrmmail
       where codform = 'HRSC01E';
    exception when no_data_found then
      null;
    end;

    set_column_label('HRSC01E');
    v_max_col  := least(p_max_column,p_column_width.count - 1);
--    -- ## LOOP DATA START ## --
--    -- TABLE HEADER
    v_data_table := '<table width="100%" border="0" cellpadding="0" cellspacing="1" bordercolor="#FFFFFF">';
    v_data_table := v_data_table||'<tr class="TextBody" bgcolor="#006699">
                         <td width="'||p_column_width(1)||'%"  height="20" align="center"><font color="#FFFFFF">'||get_label_name('ESS', global_v_lang, 20)||'</font></td>';
    for x in 1..v_max_col loop
      v_data_table  := v_data_table||'<td width="'||p_column_width(x + 1)||'%" align="center"><font color="#FFFFFF">'||p_column_label(x)||'</font></td>';
    end loop;
    v_data_table  := v_data_table||'</tr>';

    -- TABLE BODY
    v_num      := 0;
    v_chkmax   := 'N';
    v_data_list := ''; -- LIST CONTENT
    for j in c1 loop
      v_num  := v_num + 1 ;
      if mod(v_num,2) = 1 then
        v_bgcolor := '"#EFF4F8"' ;
      else
        v_bgcolor := '"#FFFFFF"' ;
      end if;
      if v_chkmax = 'N' then
        get_column_value(j.codempid,j.rowid,'HRSC01E');
        v_data_table  := v_data_table||'<tr class="TextBody"  bgcolor='||v_bgcolor||'>
                             <td height="15" align="center">'||v_num||'</td>';
        v_data_list := v_data_list||'<div>';  -- LIST CONTENT
        for x in 1..v_max_col loop
          v_data_table  := v_data_table||'<td align="'||p_text_align(x)||'">'||p_column_value(x)||'</td>';
          v_data_list   := v_data_list||'<div>'||p_column_label(x)||': '||p_column_value(x)||'</div>';  -- LIST CONTENT
        end loop;
        v_data_table  := v_data_table||'</tr>';
        v_data_list := v_data_list||'</div>';  -- LIST CONTENT
      end if;  --v_chkmax
    end loop;--for j in c3 loop
    v_data_table     := v_data_table||'</table>';
    -- ## LOOP DATA END ## --

    begin
      select pwddec(codpswd, p_coduser, v_chken)
        into tusrprof_codpswd
        from tusrprof
       where coduser = p_coduser;
    exception when no_data_found then
      null;
    end;

    v_send := hcm_util.get_temploy_field(get_codempid(p_coduser), 'email');

    -- Replace Text
    if v_msg like ('%[TABLE]%') then
      v_msg  := replace(v_msg  ,'[TABLE]', v_data_table);
    end if;

    if v_msg like ('%[LIST]%') then
      v_msg  := replace(v_msg  ,'[LIST]', v_data_list);
    end if;

    if v_msg like ('%[PARAM-TO]%') then
      v_msg  := replace(v_msg  ,'[PARAM-TO]', v_name);
    end if;
    v_msg  := replace(v_msg, '[param-01]', v_name);
    v_msg  := replace(v_msg, '[param-02]', p_coduser);
    v_msg  := replace(v_msg, '[param-03]', tusrprof_codpswd);
    v_subject  := get_label_name('HRSC01E1', global_v_lang, '60');
    v_codempid := get_tsetup_value('MAILEMAIL');
    -- param_msg_error := '<b>' || v_subject || '</b><br />' || v_msg || '@#$%400';

    if v_send is not null and param_msg_error is null then
        if v_temp is null then
            v_msg := 'From: ' ||v_send|| crlf ||
             'To: '||v_send||crlf||
             'Subject: '||v_subject||crlf||
             'Content-Type: text/html;'||crlf||crlf||'<html><body>'||v_msg||'</body></html>';
            v_error := send_mail(v_send,v_msg,null,null);
        else
            v_error := SendMail_AttachFile(v_codempid, v_send, v_subject, v_msg, v_temp, null, null, null, null);
        end if;
      -- param_msg_error := v_error || '@#$%400';
      if v_error = '7521' then
        param_msg_error := get_error_msg_php('HR2046', global_v_lang);
        commit;
      else
        param_msg_error := get_error_msg_php('HR7522', global_v_lang);
        rollback;
      end if;
    end if;

    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end post_send_mail;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  function get_tsecurh_name (v_codsecu varchar2) return varchar2 is
    v_namsecu           tsecurh.namsecue%type;
  begin
    begin
      select decode(global_v_lang, '101', namsecue,
                                   '102', namsecut,
                                   '103', namsecu3,
                                   '104', namsecu4,
                                   '105', namsecu5,
                                   namsecue)
        into v_namsecu
        from tsecurh
       where codsecu = v_codsecu;
    exception when no_data_found then
      null;
    end;
    return v_namsecu;
  end get_tsecurh_name;

  function get_tprocess_name (v_codproc varchar2) return varchar2 is
    v_desproc           tprocess.desproce%type;
  begin
    begin
      select decode(global_v_lang, '101', desproce,
                                   '102', desproct,
                                   '103', desproc3,
                                   '104', desproc4,
                                   '105', desproc5,
                                   desproce)
        into v_desproc
        from tprocess
       where codproc = v_codproc;
    exception when no_data_found then
      null;
    end;
    return v_desproc;
  end get_tprocess_name;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_coduser           tusrprof.coduser%type;
    v_codempid          tusrprof.codempid%type;
    v_userdomain        tusrprof.userdomain%type;
    v_typeauth          tusrprof.typeauth%type;
    v_typeuser          tusrprof.typeuser%type;
    v_flgact            tusrprof.flgact%type;
    v_codpswd           tusrprof.codpswd%type;
    v_timepswd          tusrprof.timepswd%type;
    v_codsecu           tusrprof.codsecu%type;
    v_desc_codsecu      varchar2(1000 char);
    v_flgauth           tusrprof.flgauth%type;
    v_numlvlst          tusrprof.numlvlst%type;
    v_numlvlen          tusrprof.numlvlen%type;
    v_numlvlsalst       tusrprof.numlvlsalst%type;
    v_numlvlsalen       tusrprof.numlvlsalen%type;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    v_coduser               := hcm_util.get_string_t(obj_data, 'coduser');
    v_codempid              := hcm_util.get_string_t(obj_data, 'codempid');
    v_userdomain            := hcm_util.get_string_t(obj_data, 'userdomain');
    v_typeauth              := hcm_util.get_string_t(obj_data, 'typeauth');
    v_typeuser              := hcm_util.get_string_t(obj_data, 'typeuser');
    v_flgact                := hcm_util.get_string_t(obj_data, 'flgact');
    v_codpswd               := hcm_util.get_string_t(obj_data, 'codpswd');
    v_timepswd              := hcm_util.get_string_t(obj_data, 'timepswd');
    v_codsecu               := hcm_util.get_string_t(obj_data, 'codsecu');
    v_desc_codsecu          := v_codsecu || ' - ' || get_tsecurh_name(v_codsecu);
    v_flgauth               := hcm_util.get_string_t(obj_data, 'flgauth');
    v_numlvlst              := to_char(hcm_util.get_string_t(obj_data, 'numlvlst'));
    v_numlvlen              := to_char(hcm_util.get_string_t(obj_data, 'numlvlen'));
    v_numlvlsalst           := to_char(hcm_util.get_string_t(obj_data, 'numlvlsalst'));
    v_numlvlsalen           := to_char(hcm_util.get_string_t(obj_data, 'numlvlsalen'));
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
              '1',
              v_coduser,
              v_codempid || ' - ' || get_temploy_name(v_codempid, global_v_lang),
              v_userdomain,
              get_tlistval_name('TYPEAUTH', v_typeauth, global_v_lang),
              get_tlistval_name('TYPEUSER', v_typeuser, global_v_lang),
              get_tlistval_name('USRSTA', v_flgact, global_v_lang),
              v_codpswd,
              v_timepswd,
              nvl(v_desc_codsecu, '-'),
              get_tlistval_name('HRSC01E1', v_flgauth, global_v_lang),
              v_numlvlst,
              v_numlvlen,
              v_numlvlsalst,
              v_numlvlsalen
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt;

  procedure insert_ttemprpt_comp(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_coduser           tusrcom.coduser%type;
    v_codcomp           tusrcom.codcomp%type;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    v_coduser               := hcm_util.get_string_t(obj_data, 'coduser');
    v_codcomp               := hcm_util.get_string_t(obj_data, 'codcomp');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
              '2',
              v_coduser,
              v_codcomp || ' - ' || get_tcenter_name(v_codcomp, global_v_lang)
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_comp;

  procedure insert_ttemprpt_proc(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_coduser           tusrproc.coduser%type;
    v_codproc           tusrproc.codproc%type;
    v_flgauth           tusrproc.flgauth%type;
    v_desc_codproc      varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    v_coduser               := hcm_util.get_string_t(obj_data, 'coduser');
    v_codproc               := hcm_util.get_string_t(obj_data, 'codproc');
    v_flgauth               := hcm_util.get_string_t(obj_data, 'flgauth');
    v_desc_codproc          := v_codproc || ' - ' || get_tprocess_name(v_codproc);
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
              '3',
              v_coduser,
              v_desc_codproc,
              get_tlistval_name('FLGAUTH', v_flgauth, global_v_lang)
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_proc;

  procedure gen_report(json_str_input in clob, json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_coduser.get_size-1 loop
        if param_msg_error is not null then
          exit;
        end if;
        p_coduser := hcm_util.get_string_t(json_coduser, to_char(i));
        gen_detail(json_output);
        gen_tusrcom(json_output);
        gen_tusrproc(json_output);
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end gen_report;

  procedure get_codproc_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select   codproc,decode(global_v_lang,'101',desproce,
                                            '102',desproct,
                                            '103',desproc3,
                                            '104',desproc4,
                                            '105',desproc5) desc_codproc
        from  tprocess
    order by  codproc;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codproc',i.codproc);
      obj_data.put('desc_codproc',i.desc_codproc);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codproc_all;
end HRSC01E;

/
