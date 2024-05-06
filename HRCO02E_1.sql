--------------------------------------------------------
--  DDL for Package Body HRCO02E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO02E" AS

  procedure check_index is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;
    if p_codcompy is not null then
      begin
        select codcompy
        into   p_codcompy
        from   tcompny
        where  codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
        return;
      end;
    end if;
    error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
    end if;
  end;

  procedure check_save is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if(p_typsign = '1') then

      if p_codempid_query is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
        return;
      end if;

      begin
        select codempid
        into   p_codempid_query
        from   temploy1
        where  codempid = p_codempid_query;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;
      error_secur := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid_query);
      if error_secur is not null then
        param_msg_error := error_secur;
        return;
      end if;
    end if;
    if(p_typsign = '2') then
      if p_codcomp is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
        return;
      else
        error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if error_secur is not null then
          param_msg_error := error_secur;
          return;
        end if;
      end if;
      if p_codpos is null then
         param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpos');
        return;
      end if;

    end if;
--    if(p_typsign = '3') then
--      if p_signname is null then
--         param_msg_error := get_error_msg_php('HR2045',global_v_lang,'signname');
--        return;
--      end if;
--      if p_posname is null then
--         param_msg_error := get_error_msg_php('HR2045',global_v_lang,'posname');
--        return;
--      end if;
--      if(length(p_signname) > 150) then
--        param_msg_error := get_error_msg_php('HR2015',global_v_lang,'signname');
--        return;
--      end if;
--    end if;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_list_value        := hcm_util.get_string_t(json_obj,'p_list_value');
    p_coddoc            := hcm_util.get_string_t(json_obj,'p_coddoc');
    p_typsign           := hcm_util.get_string_t(json_obj,'p_typsign');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_signname          := hcm_util.get_string_t(json_obj,'p_signname');
    p_posname           := hcm_util.get_string_t(json_obj,'p_posname');
    p_namsign           := hcm_util.get_string_t(json_obj,'p_namsign');

    p_rowid             := hcm_util.get_string_t(json_obj,'p_rowid');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure gen_data (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_list_value    tlistval.list_value%type;

--  cursor c1 is
--    select a.desc_label, a.list_value,
--           b.rowid as indexid, b.codcompy, b.codempid, b.codpos, b.signname, b.posname, b.coduser, b.namsign, b.dteupd, b.typsign
--      from tlistval a,tsetsign b
--     where codapp = 'CODDOC'
--       and codlang = global_v_lang
--       and a.list_value = b.coddoc(+)
--       and numseq > 0
--       and b.codcompy = p_codcompy;
--
  cursor c1 is
    select a.desc_label, a.list_value
      from tlistval a
     where codapp = 'CODDOC'
       and codlang = global_v_lang
       and numseq > 0;

  cursor c2 is
    select b.rowid as indexid, b.codcompy, b.codempid, b.codpos, b.signname,
           b.posname, b.coduser, b.namsign, b.dteupd, b.typsign
      from tsetsign b
     where b.coddoc  = v_list_value
       and b.codcompy = p_codcompy;

  v_desc_codpos       varchar2(4000 char);
  v_codempid          temploy1.codempid%type;
  v_namsign           tsetsign.namsign%type;
  v_folder            varchar2(4000 char);
  v_flgskip           varchar2(1):= 'N';

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      v_list_value := r1.list_value;

      obj_data.put('desc_label', r1.desc_label);
      obj_data.put('list_value', r1.list_value);
      v_flgskip := 'Y';
      for r2 in c2 loop
          v_flgskip := 'N';
          obj_data.put('codcompy', r2.codcompy);
          obj_data.put('indexid', r2.indexid);

          if (r2.typsign='1') then
              begin
                select get_tpostn_name(codpos,global_v_lang)
                  into v_desc_codpos
                  from temploy1
                 where codempid = r2.codempid;
              exception when no_data_found then
                v_desc_codpos := null;
              end;

              begin
                select namsign
                  into v_namsign
                  from tempimge
                 where codempid = r2.codempid;
              exception when no_data_found then
                v_namsign := null;
              end;
              --
              begin
                select folder
                  into v_folder
                  from tfolderd
                 where codapp = 'HRPMC2E2';
              exception when no_data_found then
                v_namsign := null;
              end;

              obj_data.put('signname', get_temploy_name(r2.codempid,global_v_lang));
              obj_data.put('posname', v_desc_codpos);
              obj_data.put('namsign', v_folder||'/'||v_namsign);
          end if;

          if (r2.typsign='2') then
              begin
                select codempid
                  into v_codempid
                  from temploy1
                 where codpos  = r2.codpos
                   and codcomp like nvl(r2.codcompy,'')||'%'
                   and staemp in ('1','3')
                   and rownum  = 1
                order by codempid;
              exception when no_data_found then
                v_codempid := null;
              end;

              begin
                select namsign
                  into v_namsign
                  from tempimge
                 where codempid = v_codempid;
              exception when no_data_found then
                v_namsign := null;
              end;
              --
              begin
                select folder
                  into v_folder
                  from tfolderd
                 where codapp = 'HRPMC2E2';
              exception when no_data_found then
                v_namsign := null;
              end;

              obj_data.put('signname', get_temploy_name(v_codempid,global_v_lang));
              obj_data.put('posname', get_tpostn_name(r2.codpos,global_v_lang));
              obj_data.put('namsign', v_folder||'/'||v_namsign);
          end if;

          if (r2.typsign='3') then
              v_namsign := r2.namsign;
              begin
                select folder
                  into v_folder
                  from tfolderd
                 where codapp = 'HRCO02E';
              exception when no_data_found then
                v_folder := null;
              end;


              obj_data.put('signname', r2.signname);
              obj_data.put('posname', r2.posname);
              obj_data.put('namsign', v_folder||'/'||v_namsign);
          end if;
         obj_data.put('coduser', r2.coduser);
         obj_data.put('dteupd', hcm_util.get_date_buddhist_era(r2.dteupd));
      end loop;
      obj_data.put('flgskip', v_flgskip);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end;
  procedure get_data (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
  procedure gen_tsetsign (json_str_output out clob) as
    obj_data        json_object_t;
  begin
    begin
      select rowid as indexid, coddoc, typsign, codempid, codcomp, codpos, signname, posname, namsign, dtecreate, codcreate, dteupd, coduser
      into p_indexid, p_coddoc, p_typsign, p_codempid_query, p_codcomp, p_codpos, p_signname, p_posname, p_namsign, p_dtecreate, p_codcreate, p_dteupd, p_coduser
      from tsetsign  where codcompy = p_codcompy and CODDOC = p_list_value;

    exception when no_data_found then
       p_typsign := 1;
       p_coddoc := p_list_value;
    end;

    p_codcomp := hcm_util.get_codcomp_level(p_codcomp,null,null,'Y'); --#6194 || USER39 || 02/09/2021

    obj_data := json_object_t();

--    dbms_lob.createtemporary(json_str_output, true);

    obj_data.put('coderror', '200');
    obj_data.put('indexid', p_indexid);
    obj_data.put('codcompy', p_codcompy);
    obj_data.put('coddoc_label',  get_tlistval_name('CODDOC', p_coddoc, global_v_lang));
    obj_data.put('coddoc', p_coddoc);
    obj_data.put('typsign', p_typsign);
    obj_data.put('codempid', p_codempid_query);
    obj_data.put('codcomp', p_codcomp);
    obj_data.put('codpos', p_codpos);
    obj_data.put('signname', p_signname);
    obj_data.put('posname', p_posname);
    obj_data.put('namsign', p_namsign);
    obj_data.put('dtecreate', p_dtecreate);
    obj_data.put('codcreate', p_codcreate);
    obj_data.put('dteupd', p_dteupd);
    obj_data.put('coduser', p_coduser);

--    obj_data.to_clob(json_str_output);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_tsetsign (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tsetsign(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure update_tsetsign is
    v_numrec number;
  begin
   begin
    SELECT Count (*)  into v_numrec
      from tsetsign
     where codcompy = p_codcompy
       and coddoc = p_coddoc;
   end;

    --<<#6194 || USER39 || 02/09/2021   
    if p_typsign = '2' then
        p_codcomp := hcm_util.get_codcomp_level(p_codcomp,null,null,'Y'); 
    end if;    
    -->>#6194 || USER39 || 02/09/2021     

    if v_numrec = 0 then
        insert into tsetsign (typsign, codempid, codcomp, codpos, posname,
                              signname, namsign, coduser, codcompy, coddoc)
                       values ( p_typsign, p_codempid_query, p_codcomp, p_codpos, p_posname,
                              p_signname, p_namsign, global_v_coduser, p_codcompy, p_coddoc);
    else
        begin
          update tsetsign
          set typsign = p_typsign,
              codempid = p_codempid_query,
              codcomp = p_codcomp,
              codpos = p_codpos,
              posname = p_posname,
              signname = p_signname,
              namsign = p_namsign,
              coduser = global_v_coduser
          where codcompy = p_codcompy and coddoc = p_coddoc;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          rollback;
        end;
    end if;

  end;
  procedure edit_tsetsign(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_save();
    update_tsetsign();
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;


END HRCO02E;

/
