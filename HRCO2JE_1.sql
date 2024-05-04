--------------------------------------------------------
--  DDL for Package Body HRCO2JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2JE" AS

  procedure check_index is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codapp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codapp');
      return;
    end if;
    if p_codapp is not null then
      begin
        select codapp
        into   p_codapp
        from   tappprof
        where  codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tappprof');
        return;
      end;
    end if;
    if p_codapp is not null then
      begin
        select p_codapp
        into   p_codapp
        from   twkfunct
        where  codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'twkfunct');
        return;
      end;
    end if;
  end;

  procedure check_index2 is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_seqno is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'seqno');
      return;
    end if;
  end;
  --
  procedure check_tab2 is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codempid_query is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    end if;
    if p_codempid_query is null then
      begin
        select codempid
        into p_codempid_query
        from temploy1
        where codempid = p_codempid_query;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
    end if;
    if p_codempid_query is null then
      begin
        select p_codempid_query
        into p_codempid_tmp
        from twkflpr
        where codempid = p_codempid_query and codapp = p_codapp;
      end;
      if p_codempid_tmp is not null then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TWKFLPR');
        return;
      end if;
    end if;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error   := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codapp            := hcm_util.get_string_t(json_obj,'p_codapp_query');
    p_codfrmto          := hcm_util.get_string_t(json_obj,'p_codfrmto');
    p_codfrmcc          := hcm_util.get_string_t(json_obj,'p_codfrmcc');
    p_codappap          := hcm_util.get_string_t(json_obj,'p_codappap');
    p_dtetotal          := hcm_util.get_string_t(json_obj,'p_dtetotal');
    p_hrtotal           := hcm_util.get_string_t(json_obj,'p_hrtotal');

    p_rowid           := hcm_util.get_string_t(json_obj,'p_rowid');
    p_flg             := hcm_util.get_string_t(json_obj,'p_flg');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure gen_data (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;

  cursor c1 is
    Select rowid as indexid, twkflph.* From twkflph order by codapp,seqno;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;

      obj_data    := json_object_t();

      obj_data.put('indexid', r1.indexid);
      obj_data.put('codapp', r1.codapp);
      obj_data.put('codapp_name', get_tappprof_name(r1.codapp,1,global_v_lang));
      obj_data.put('seqno', r1.seqno);
      obj_data.put('syncond', get_logical_desc(r1.statement));
      obj_data.put('routeno', r1.routeno);
      obj_data.put('replyapp', r1.replyapp);
      obj_data.put('codfrmap', r1.codfrmap);
      obj_data.put('typreplya', r1.typreplya);
      obj_data.put('replyno', r1.replyno);
      obj_data.put('codfrmno', r1.codfrmno);
      obj_data.put('typreplyn', r1.typreplyn);
      obj_data.put('typreplyar', r1.typreplyar);
      obj_data.put('typreplynr', r1.typreplynr);
--      obj_data.put('strseq', r1.strseq);
      obj_data.put('dtecreate', r1.dtecreate);
      obj_data.put('codcreate', r1.codcreate);
      obj_data.put('dteupd', r1.dteupd);
      obj_data.put('coduser', r1.coduser);

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
  procedure get_data (json_str_input in clob, json_str_output out clob) as
      obj_row json_object_t;
  begin
      initial_value(json_str_input);
      gen_data(json_str_output);
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_twkflpf (json_str_output out clob) is
  obj_data         json_object_t;

  begin
    begin
      select rowid as index_id, codapp, codfrmto, codfrmcc, codappap, dtetotal, hrtotal, dtecreate, codcreate, dteupd, coduser
      into p_indexid, p_codapp, p_codfrmto, p_codfrmcc, p_codappap, p_dtetotal, p_hrtotal, p_dtecreate, p_codcreate, p_dteupd, p_coduser
      from twkflpf
      where codapp = p_codapp;
    exception when no_data_found then
      null;
    end;

    obj_data := json_object_t();

    obj_data.put('coderror', '200');
    obj_data.put('indexid', p_indexid);
    obj_data.put('codapp', p_codapp);
    obj_data.put('codfrmto', p_codfrmto);
    obj_data.put('codfrmcc', p_codfrmcc);
    obj_data.put('codappap', p_codappap);
    obj_data.put('dtetotal', hcm_util.convert_minute_to_hour(p_dtetotal));
    obj_data.put('hrtotal', hcm_util.convert_minute_to_hour(p_hrtotal));
    json_str_output := obj_data.to_clob;
--
--    obj_data.to_clob(json_str_output);
--    dbms_lob.createtemporary(json_str_output, true);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_twkflpf (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_twkflpf(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_twkflph (json_str_output out clob) is
  obj_data        json_object_t;
  obj_row         json_object_t;
  obj_result      json_object_t;
  obj_syncond     json_object_t;
  v_rcnt          number := 0;
  v_exists        boolean := false;
  cursor c1 is
    select rowid as indexid, codapp, seqno, syncond, statement, routeno,
          replyapp, codfrmap, typreplya, replyno, codfrmno, strseq,
          typreplyn, typreplyar, typreplynr, dtecreate, codcreate, dteupd, coduser
    from twkflph
    where codapp = p_codapp
    order by seqno;
  begin

    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      v_exists    := true;
      obj_data    := json_object_t();
      obj_syncond := json_object_t();

      obj_data.put('indexid', r1.indexid);
      obj_data.put('seqno', r1.seqno);
      obj_syncond.put('code', r1.syncond);
      obj_syncond.put('description', r1.syncond);
      obj_syncond.put('statement', r1.statement);
      obj_data.put('syncond', obj_syncond.to_clob);
      obj_data.put('routeno', r1.routeno);
      obj_data.put('replyapp', r1.replyapp);
      obj_data.put('codfrmap', r1.codfrmap);
      obj_data.put('typreplya', r1.typreplya);
      obj_data.put('replyno', r1.replyno);
      obj_data.put('codfrmno', r1.codfrmno);
      obj_data.put('typreplyn', r1.typreplyn);
      obj_data.put('typreplyar', r1.typreplyar);
      obj_data.put('typreplynr', r1.typreplynr);
      obj_data.put('strseq', r1.strseq);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if not v_exists then
      v_rcnt      := v_rcnt+1;
      v_exists    := true;
      obj_data    := json_object_t();
      obj_syncond := json_object_t();

      obj_data.put('indexid', '');
      obj_data.put('seqno', '1');
      obj_syncond.put('code', '');
      obj_syncond.put('description', '');
      obj_syncond.put('statement', '');
      obj_data.put('syncond', obj_syncond.to_clob);
      obj_data.put('routeno', '');
      obj_data.put('replyapp', '');
      obj_data.put('codfrmap', '');
      obj_data.put('typreplya', '3');
      obj_data.put('replyno', '');
      obj_data.put('codfrmno', '');
      obj_data.put('typreplyn', '3');
      obj_data.put('typreplyar', '3');
      obj_data.put('typreplynr', '2');
      obj_data.put('strseq', '');
      obj_row.put(to_char(v_rcnt-1),obj_data);
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
  --
  procedure get_twkflph (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_twkflph(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_twkflpr (json_str_output out clob) is
  obj_data        json_object_t;
  obj_row         json_object_t;
  obj_result      json_object_t;
  v_rcnt          number := 0;

  cursor c1 is
    select rowid as indexid, codapp, codempid, dtecreate, codcreate, dteupd, coduser
--    into p_indexid, p_codapp, p_codempid, p_dtecreate, p_codcreate, p_dteupd, p_coduser
    from twkflpr
    where codapp = p_codapp
    order by codempid;
  begin

    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('indexid', r1.indexid);
      obj_data.put('codapp', r1.codapp);
      obj_data.put('codempid', r1.codempid);

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
  procedure get_twkflpr (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_twkflpr(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_twkflpf is
    v_dtetotal    number;
    v_hrtotal     number;
  begin
    v_dtetotal    := nvl(hcm_util.convert_hour_to_minute(p_dtetotal),0);
    v_hrtotal     := nvl(hcm_util.convert_hour_to_minute(p_hrtotal),0);
    begin
      insert into twkflpf (codapp, codfrmto, codfrmcc, codappap,
                           dtetotal, hrtotal, codcreate, coduser)
      values (p_codapp, p_codfrmto, p_codfrmcc, p_codappap,
              hcm_util.convert_hour_to_minute(p_dtetotal), hcm_util.convert_hour_to_minute(p_hrtotal), global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update twkflpf
        set codfrmto  = p_codfrmto,
            codfrmcc  = p_codfrmcc,
            codappap  = p_codappap,
            dtetotal  = hcm_util.convert_hour_to_minute(p_dtetotal),
            hrtotal   = hcm_util.convert_hour_to_minute(p_hrtotal),
            coduser   = global_v_coduser
        where codapp  = p_codapp;
    end;
  end;
  --
  procedure save_twkflph(param_json json_object_t) is
    param_json_row    json_object_t;
    v_flg             varchar2(100);
    v_routeno         twkflowd.routeno%type;
  begin
    for i in 0..param_json.get_size-1 loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));

      p_seqno           := to_number(hcm_util.get_string_t(param_json_row,'seqno'));
      p_syncond         := hcm_util.get_string_t(param_json_row,'syncond_save');
      p_statement       := hcm_util.get_string_t(param_json_row,'statement_save');
      p_routeno         := hcm_util.get_string_t(param_json_row,'routeno');
      p_codfrmap        := hcm_util.get_string_t(param_json_row,'codfrmap');
      p_codfrmno        := hcm_util.get_string_t(param_json_row,'codfrmno');
      p_typreplya       := hcm_util.get_string_t(param_json_row,'typreplya');
      p_typreplyar      := hcm_util.get_string_t(param_json_row,'typreplyar');
      p_typreplyn       := hcm_util.get_string_t(param_json_row,'typreplyn');
      p_typreplynr      := hcm_util.get_string_t(param_json_row,'typreplynr');
      p_strseq          := hcm_util.get_string_t(param_json_row,'strseq');

      if p_strseq is not null then
        begin
          select routeno
            into v_routeno
            from twkflowd
           where routeno = p_routeno
             and numseq = p_strseq;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TWKFLOWD');
          exit;
        end;
      end if;
      if p_typreplya = '3' and p_typreplyar = '3' then
        p_replyapp  := 'N';
      else
        p_replyapp  := 'Y';
      end if;

      if p_typreplyn = '3' and p_typreplynr = '2' then
        p_replyno  := 'N';
      else
        p_replyno  := 'Y';
      end if;

      p_rowid           := hcm_util.get_string_t(param_json_row,'p_rowid');
      v_flg             := hcm_util.get_string_t(param_json_row,'flg');
      if v_flg = 'delete' then
        delete from twkflph
        where   codapp  = p_codapp
        and     seqno   = p_seqno;
      else
        begin
          insert into twkflph (codapp, seqno, syncond, statement, routeno, replyapp, codfrmap,
                               typreplya, replyno, codfrmno, typreplyn, typreplyar, typreplynr,strseq,
                               codcreate, coduser)
          values (p_codapp, p_seqno, p_syncond, p_statement, p_routeno, p_replyapp, p_codfrmap,
                  p_typreplya, p_replyno, p_codfrmno, p_typreplyn, p_typreplyar, p_typreplynr,p_strseq,
                  global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update twkflph
          set codapp           = p_codapp,
              seqno            = p_seqno,
              syncond          = p_syncond,
              statement        = p_statement,
              routeno          = p_routeno,
              replyapp         = p_replyapp,
              codfrmap         = p_codfrmap,
              typreplya        = p_typreplya,
              replyno          = p_replyno,
              codfrmno         = p_codfrmno,
              typreplyn        = p_typreplyn,
              typreplyar       = p_typreplyar,
              typreplynr       = p_typreplynr,
              strseq           = p_strseq,
              coduser          = global_v_coduser
          where codapp  = p_codapp
          and   seqno   = p_seqno;
        end;
      end if;
    end loop;
    begin
      select max(seqno)
        into p_lstseqno
        from twkflph
       where codapp = p_codapp;
    end;
  end;
  --
  procedure save_twkflpr (param_json json_object_t) as
    param_json_row  json_object_t;
  begin
    for i in 0..param_json.get_size-1 loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      p_codempid_query  := hcm_util.get_string_t(param_json_row,'codempid');
      p_rowid           := hcm_util.get_string_t(param_json_row,'indexid');
      p_flg             := hcm_util.get_string_t(param_json_row,'flg');
      check_tab2;
      if param_msg_error is null then
        if(p_flg = 'add') then
          insert into twkflpr (codapp, codempid, codcreate, coduser)
          values (p_codapp, p_codempid_query, global_v_coduser, global_v_coduser);
        end if;
        if(p_flg = 'delete') then
          delete  twkflpr
          where   rowid   = p_rowid;
        end if;
      else
        return;
      end if;
    end loop;
  end;
  --
  procedure save_data (json_str_input in clob, json_str_output out clob) as
    param_json              json_object_t;
    param_json_condition    json_object_t;
    param_json_reply        json_object_t;
    json_obj                json_object_t;
    v_response              varchar2(1000);
  begin
    json_obj := json_object_t();
    initial_value(json_str_input);
    check_index;
    param_json                  := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_json_condition        := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'condition'),'rows');
    param_json_reply            := hcm_util.get_json_t(param_json,'reply');
    save_twkflpf;
    if param_msg_error is null then
      save_twkflph(param_json_condition);
      if param_msg_error is null then
        save_twkflpr(param_json_reply);
      end if;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      json_obj.put('coderror', 200);
      commit;
    else
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      json_obj.put('coderror', 400);
      rollback;
    end if;

    json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
    json_obj.put('seqno',p_lstseqno);

    json_str_output := json_obj.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure delete_data_twkflpfhr is
  begin
    begin
      delete twkflph where codapp = p_codapp and seqno = p_seqno;

      begin
        select count(*)
        into p_count
        from twkflph where codapp = p_codapp;
      end;

      if(p_count <= 0) then   -- #6979 || User39 || 02/11/2564  if(p_count <= 1) then 
        delete twkflpf where codapp = p_codapp;
        delete twkflpr where codapp = p_codapp;
      end if;

    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  --
  procedure delete_index (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        p_flg     := hcm_util.get_string_t(param_json_row,'flg');
        p_codapp  := hcm_util.get_string_t(param_json_row,'codapp');
        p_seqno  := to_number(hcm_util.get_string_t(param_json_row,'seqno'));        
        if(p_flg = 'delete') then
          delete_data_twkflpfhr;
        end if;
      end loop;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;

    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
END HRCO2JE;

/
