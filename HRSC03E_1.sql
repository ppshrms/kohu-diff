--------------------------------------------------------
--  DDL for Package Body HRSC03E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC03E" as
-- last update: 14/11/2018 22:31
  procedure initial_value (json_str in clob) is
    json_obj            json_object_t;
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
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'dteeffec'), 'dd/mm/yyyy');
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'codcomp'));
    p_typeproc          := hcm_util.get_number_t(json_obj, 'typeproc');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'dteend'), 'dd/mm/yyyy');
    p_syncond           := hcm_util.get_json_t(json_obj, 'syncond');
    p_userid            := hcm_util.get_string_t(json_obj, 'userid');
    p_password          := upper(hcm_util.get_string_t(json_obj, 'password'));
    p_qtymistake        := hcm_util.get_number_t(json_obj, 'qtymistake');
    p_typeuser          := hcm_util.get_number_t(json_obj, 'typeuser');
    p_typepassword      := hcm_util.get_number_t(json_obj, 'typepassword');
    json_params         := hcm_util.get_json_t(json_obj, 'table');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function gen_user(v_codempid temploy1.codempid%type) return varchar2 is
    v_coduser           tusrprof.coduser%type;
    n                   number;
    v_dup               boolean := false;
    v_dteyear           number := to_char(sysdate, 'yyyy');
  begin
    if p_userid = 'random' then
      loop
        v_coduser   := dbms_random.string('a', 8);
        begin
          select coduser
            into v_coduser
            from tusrprof
           where coduser = v_coduser;
          v_dup := true;
        exception when others then
          v_dup := false;
        end;
      exit when not v_dup;
      end loop;
    elsif p_userid = 'codempid' then
      v_coduser       := v_codempid;
    --//Since it should not use the Run No of the employee code used by the history registration system.
    /* elsif p_userid = 'numseq' then
      -- v_coduser       := std_genid.gen_id(v_dteyear, 'U', 8, 'tusrprof', 'codempid');
      v_coduser       := v_codempid; */
    end if;
    return upper(v_coduser);
  end;

  function get_pwd (v_coduser tusrprof.coduser%type, v_codempid temploy1.codempid%type) return varchar2 is
    v_codpswd           tusrprof.codpswd%type;
    v_qtypassmax        tsetpass.qtypassmax%type;
    v_qtynumdigit       tsetpass.qtynumdigit%type;
    v_qtyspecail        tsetpass.qtyspecail%type;
    v_qtyalpbup         tsetpass.qtyalpbup%type;
    v_qtyalpblow        tsetpass.qtyalpblow%type;
--    v_psspassmax        varchar2(500);
    v_pssnumdigit       varchar2(200);
    v_pssspecail        varchar2(200);
    v_pssalpbup         varchar2(200);
    v_pssalpblow        varchar2(200);
    v_sp_char           varchar2(100);
  begin
--    if p_password = 'R' then
--      v_codpswd       := dbms_random.string('a', 8);
--    elsif p_password = 'U' then
--      v_codpswd       := v_coduser;
--    elsif p_password = 'E' then
--      v_codpswd       := v_codempid;
--    end if;
    begin
      select  qtypassmax,qtynumdigit,qtyspecail,qtyalpbup,qtyalpblow
      into    v_qtypassmax,v_qtynumdigit,v_qtyspecail,v_qtyalpbup,v_qtyalpblow
      from    tsetpass
      where   dteeffec = (select  max(dteeffec)
                          from    tsetpass
                          where   dteeffec  <= trunc(sysdate));
      v_pssnumdigit := lpad(trunc(dbms_random.value(0,trim(lpad(' ',v_qtynumdigit + 1,'9')))),v_qtynumdigit,'0');
      v_pssalpbup   := dbms_random.string('U',v_qtyalpbup);
      v_pssalpblow  := dbms_random.string('L',v_qtyalpblow);
      begin
        select  listagg(text) within group (order by text)
        into    v_sp_char
        from    tchkpass
        where   code between 32 and 47
        or      code between 58 and 64
        or      code between 91 and 96
        or      code between 123 and 126;
      exception when others then
        v_sp_char := null;
      end;
      if v_sp_char is not null and nvl(v_qtyspecail,0) > 0 then
        for i in 1..v_qtyspecail loop
          v_pssspecail  := v_pssspecail||substr(v_sp_char,trunc(dbms_random.value(1,33)),1);
        end loop;
      end if;
      v_codpswd     := lpad(nvl(v_pssnumdigit||v_pssalpbup||v_pssalpblow||v_pssspecail,'X'),v_qtypassmax,trunc(dbms_random.value(1,10)));
    exception when no_data_found then
      v_codpswd     := dbms_random.string('a', 8);
    end;
    return v_codpswd;
  end;

  procedure create_user (v_codempid temploy1.codempid%type, v_coduser tusrprof.coduser%type, v_codpswd varchar2) as
    v_numlvl              varchar2(4000 char);
    v_codcomp             temploy1.codcomp%type;
    obj_data              json_object_t;
    json_data             json_object_t;
    v_codproc             tusrproc.codproc%type;
    v_flgauth             tusrproc.flgauth%type;
    v_codapp              tusrproac.codapp%type;
    v_comlevel            number := 0;
    v_check               varchar2(10);    
  begin
    begin
      select a.numlvl, a.codcomp, b.comlevel
        into v_numlvl, v_codcomp, v_comlevel
        from temploy1 a, tcenter b
       where a.codempid = v_codempid
         and b.codcomp  = a.codcomp ;
    exception when no_data_found then
      null;
    end;
--    if p_typeuser = '3' then
--      v_codcomp := hcm_util.get_codcomp_level(v_codcomp, null);
--    end if;
    if p_typeuser = '2' then
        v_codcomp := hcm_util.get_codcomp_level(v_codcomp,null,null,'Y');
    else
        v_codcomp := hcm_util.get_codcomp_level(v_codcomp,v_comlevel,'');
    end if;
    if param_msg_error is null then
      begin
        insert into tusrprof
              (
                coduser, codempid, flgact, codpswd, flgauth,
                codsecu, typeauth, typeuser, flgchgpass, flgalter, flgtranl,
                numlvlst, numlvlen,
                numlvlsalst, numlvlsalen,
                dtecreate, usrcreate
              )
        values
              (
                v_coduser, v_codempid, '1', pwdenc(v_codpswd, v_coduser, v_chken), '2',
                null, '4', p_typeuser, 'N', 'N', 'N',
                pwdenc(decode(p_typeuser,'3','1',v_numlvl), v_coduser, v_chken), pwdenc(v_numlvl, v_coduser, v_chken),
                pwdenc('0', v_coduser, v_chken), pwdenc('0', v_coduser, v_chken),
                sysdate, global_v_coduser
              );
      exception when dup_val_on_index then
        null;
      end;
      begin
        insert
          into tusrcom
              (
                coduser, codcomp,
                rcupdid, dteupd
              )
        values
              (
                v_coduser, v_codcomp,
                global_v_coduser, sysdate
              );
      exception when dup_val_on_index then
        null;
      end;
      for i in 0..json_params.get_size - 1 loop
        obj_data          := hcm_util.get_json_t(json_params, to_char(i));
        v_codproc         := upper(hcm_util.get_string_t(obj_data, 'codproc'));
        v_flgauth         := hcm_util.get_string_t(obj_data, 'flgauth');
--<< user22 : 07/08/2022 : ST11 ||
        v_check := std_sc.chk_license_by_module(v_codproc);
        if v_check = 'Y' then
-->> user22 : 07/08/2022 : ST11 ||           
          begin
            insert
              into tusrproc(coduser, codproc, flgauth,dteupd, rcupdid)
            values( v_coduser, v_codproc, v_flgauth,sysdate, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          if v_flgauth = '3' then
            json_data         := hcm_util.get_json_t(obj_data, 'tusrproac');
            if json_data.get_size > 0 then
              for i in 0..json_data.get_size - 1 loop
                v_codapp           := hcm_util.get_string_t(json_data, to_char(i));
                begin
                  insert
                    into tusrproac
                        (
                          coduser, codproc, codapp,
                          codcreate, coduserupd
                        )
                  values
                        (
                          v_coduser, v_codproc, v_codapp,
                          global_v_coduser, global_v_coduser
                        );
                exception when dup_val_on_index then
                  null;
                end;
              end loop;
            end if;
          end if;
        end if;--if v_check = 'Y' then -- user22 : 07/08/2022 : ST11 ||     
      end loop;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end create_user;

  procedure delete_user (v_codempid in temploy1.codempid%type, v_coduser in varchar2, v_codpswd in varchar2) as
  begin
    begin
      Delete From tusrprof
        Where coduser = v_coduser;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
    if param_msg_error is not null then
      return;
    end if;
    begin
      Delete From users
        Where email = v_coduser;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
    if param_msg_error is not null then
      return;
    end if;
    begin
      Delete From tusrproc
        Where coduser = v_coduser;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
    if param_msg_error is not null then
      return;
    end if;
    begin
      Delete From tusrproac
        Where coduser = v_coduser;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
    if param_msg_error is not null then
      return;
    end if;
    begin
      Delete From tusrcom
        Where coduser = v_coduser;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end delete_user;

  procedure check_process is
    v_flgsecu         boolean := false;
  begin
    if p_codcomp is not null then
      v_flgsecu := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang,' codcomp');
        return;
      end if;
    end if;
  end check_process;

  procedure post_process (json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_stmt              clob;
    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    v_numlvl            temploy1.numlvl%type;
    v_coduser           tusrprof.coduser%type;
    v_password          tusrprof.codpswd%type;

    v_codpswd       tusrprof.codpswd%type;
    v_cursor            number;
    v_dummy             integer;
    v_syncond           varchar2(4000 char);
    v_column_date       varchar2(10 char);
    v_not_tusrprof      varchar2(5 char);

    cursor c1 is
     select coduser as coduser, pwddec(codpswd, coduser, v_chken) as codpswd
        from tusrprof
       where codempid = v_codempid;
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
      obj_row             := json_object_t();
      v_syncond           := hcm_util.get_string_t(p_syncond, 'code');
      v_stmt := 'select codempid, codcomp, numlvl from temploy1 ';
      if p_typeproc = '1' then
        v_column_date := 'dteempmt';
        v_stmt := v_stmt || ' where staemp in (''1'', ''3'')';
        v_not_tusrprof := 'not';
      else
        v_column_date := 'dteeffex';
        v_stmt := v_stmt || ' where dteeffex <= sysdate';
        v_not_tusrprof := '';
      end if;

      v_stmt := v_stmt || ' and codempid ' || v_not_tusrprof || ' in (select codempid from tusrprof)';
      v_stmt := v_stmt || ' and ' || v_column_date || ' between '
                            || 'to_date(''' || to_char(p_dtestrt, 'dd/mm/yyyy') || ''', ''dd/mm/yyyy'')' || ' and '
                            || 'to_date(''' || to_char(p_dteend, 'dd/mm/yyyy') || ''', ''dd/mm/yyyy'')';
      v_stmt := v_stmt || ' and codcomp like ''' || p_codcomp || ''' || ''%''';
      v_stmt := v_stmt || ' and ( ' || v_syncond||' )';
      v_stmt := v_stmt || ' order by codempid ';
      
      -- param_msg_error := v_stmt || '@#$%400';
      v_cursor  := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor, v_stmt, dbms_sql.native);
      dbms_sql.define_column(v_cursor, 1, v_codempid, 1000);
      dbms_sql.define_column(v_cursor, 2, v_codcomp, 1000);
      dbms_sql.define_column(v_cursor, 3, v_numlvl);
      v_dummy := dbms_sql.execute(v_cursor);
      while (dbms_sql.fetch_rows(v_cursor) > 0) loop
        dbms_sql.column_value(v_cursor, 1, v_codempid);
        dbms_sql.column_value(v_cursor, 2, v_codcomp);
        dbms_sql.column_value(v_cursor, 3, v_numlvl);
        v_coduser  := null;
        v_password := null;

        if p_typeproc = '1' then
          v_coduser  := gen_user(v_codempid);
          if p_typepassword = '2' then
            begin
              select substr(numoffid,-5)
                into v_password
                from temploy2
               where codempid   = v_codempid;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010', global_v_lang,'temploy2');
              GOTO stop_process;
            end;
          else
            v_password := get_pwd(v_coduser, v_codempid);
          end if;
          create_user(v_codempid, v_coduser, v_password);

          v_rcnt            := v_rcnt + 1;
          obj_data          := json_object_t();
          obj_data.put('image', get_emp_img(v_codempid));
          obj_data.put('codempid', v_codempid);
          obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
          obj_data.put('coduser', v_coduser);
          obj_data.put('password', v_password);
          obj_row.put(to_char(v_rcnt-1), obj_data);
        else
          for r1 in c1 loop
            v_coduser   :=  r1.coduser;
            v_password  :=  r1.codpswd;
            delete_user(v_codempid, v_coduser, v_password);
            v_rcnt            := v_rcnt + 1;
            obj_data          := json_object_t();
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('coduser', v_coduser);
            obj_data.put('password', v_password);
            obj_row.put(to_char(v_rcnt-1), obj_data);
          end loop;
        end if;
      end loop;
    end if;
    <<stop_process>>
    if param_msg_error is null then
      commit;
      if obj_row.get_size = 0 then
        param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      else
        json_str_output   := obj_row.to_clob;
      end if;
    else
      rollback;
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end post_process;

  procedure send_mail (json_str_input in clob, json_str_output out clob) is
    v_name          varchar2(1000 char);
    v_subject       varchar2(1000 char);
    v_temp          varchar2(1000 char);
    v_error         varchar2(1000 char);
    v_msg           tfrmmail.messagee%type;
    v_msg_template  tfrmmail.messagee%type;
    v_send          temploy1.email%type;
    v_codempid      varchar2(1000 char);
    v_coduser       tusrprof.coduser%type;
    v_codpswd       tusrprof.codpswd%type;
  begin
    initial_value (json_str_input);
    begin
      select decode(global_v_lang, '101', messagee,
                                   '102', messaget,
                                   '103', message3,
                                   '104', message4,
                                   '105', message5,
                                   messagee)
        into v_msg_template
        from tfrmmail
       where codform = 'HRSC03E';
    exception when no_data_found then
      null;
    end;

    for i in 0..json_params.get_size - 1 loop
      if param_msg_error is not null then
        exit;
      end if;
      v_coduser := hcm_util.get_string_t(json_params, to_char(i));
      v_name := get_temploy_name(get_codempid(v_coduser), global_v_lang);
      v_msg  := v_msg_template;

      begin
        select pwddec(codpswd, v_coduser, v_chken)
          into v_codpswd
          from tusrprof
        where coduser = v_coduser;
      exception when no_data_found then
        null;
      end;

      v_send := hcm_util.get_temploy_field(get_codempid(v_coduser), 'email');
      v_msg  := replace(v_msg, '<param-01>', v_coduser);
      v_msg  := replace(v_msg, '[PARAM-01]', v_coduser);
      v_msg  := replace(v_msg, '<param-02>', v_codpswd);
      v_msg  := replace(v_msg, '[PARAM-02]', v_codpswd);
      v_msg  := replace(v_msg, '<param-03>', v_name);
      v_msg  := replace(v_msg, '[PARAM-03]', v_name);

      v_subject  := get_label_name('HRSC01E1', global_v_lang, '60');
      v_codempid := get_tsetup_value('MAILEMAIL');
      -- param_msg_error := '<b>' || v_send || '</b><br />' || '<b>' || v_subject || '</b><br />' || v_msg || '@#$%400';
      -- exit;

      if v_send is not null then
        v_error := SendMail_AttachFile(v_codempid, v_send, v_subject, v_msg, v_temp, null, null, null, null);
        -- param_msg_error := v_error || '@#$%400';
        if v_error = '7521' then
          null;
        else
          param_msg_error := get_error_msg_php('HR7522', global_v_lang);
        end if;
      else
        param_msg_error := get_error_msg_php('HR2602', global_v_lang, v_coduser);
      end if;
    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2046', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end send_mail;

  procedure create_users (json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_coduser       tusrprof.coduser%type;
    v_codpswd       varchar2(4000 char);
  begin
    initial_value (json_str_input);
    for i in 0..json_params.get_size - 1 loop
      if param_msg_error is not null then
        exit;
      end if;
      obj_data            := hcm_util.get_json_t(json_params, to_char(i));
      v_codempid          := hcm_util.get_string_t(obj_data, 'codempid');
      v_coduser           := hcm_util.get_string_t(obj_data, 'coduser');
      v_codpswd           := hcm_util.get_string_t(obj_data, 'codpswd');
      begin
       insert into users (name, email, password, is_client, created_at, updated_at, username, codempid)
        values (v_coduser, v_coduser, v_codpswd, '1', sysdate, sysdate, v_coduser, v_codempid);
      exception  when dup_val_on_index then null;
                 when others then
                    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
      end;
    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end create_users;
end HRSC03E;

/
