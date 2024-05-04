--------------------------------------------------------
--  DDL for Package Body HRSC15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC15E" is
-- last update: 12/11/2018 21:12
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');

    -- index
    p_codproc           := upper(hcm_util.get_string_t(json_obj, 'p_codproc'));
    p_codprocQuery      := upper(hcm_util.get_string_t(json_obj, 'p_codprocQuery'));
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_index (json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c_tprocess is
      select codproc, linkurl, flgcreate, decode(global_v_lang, '101', desproce
                                          , '102', desproct
                                          , '103', desproc3
                                          , '104', desproc4
                                          , '105', desproc5
                                          , '') desproc
        from tprocess
       order by codproc;

  begin
    obj_row            := json_object_t();
    for r1 in c_tprocess loop
      v_rcnt             := v_rcnt + 1;
      obj_data           := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codproc', r1.codproc);
      obj_data.put('desproc', r1.desproc);
      obj_data.put('flgcreate', r1.flgcreate);
      obj_data.put('linkurl', r1.linkurl);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure check_tprocess is
    v_codproc          tprocess.codproc%type;
  begin
    if p_codproc is not null then
      begin
        select codproc
          into v_codproc
          from tprocess
         where codproc = p_codproc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tprocess');
        return;
      end;
    end if;
  end check_tprocess;

  procedure get_tprocess (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_tprocess (json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tprocess;

  procedure gen_tprocess (json_str_output out clob) is
    obj_data            json_object_t;
    v_desproc           tprocess.desproce%type;
    v_desproce          tprocess.desproce%type;
    v_desproct          tprocess.desproct%type;
    v_desproc3          tprocess.desproc3%type;
    v_desproc4          tprocess.desproc4%type;
    v_desproc5          tprocess.desproc5%type;
    v_codimage          tprocess.codimage%type;
    v_flgcreate         tprocess.flgcreate%type;
    v_dtecreate         tprocess.dtecreate%type;
    v_codcreate         tprocess.codcreate%type;
    v_dteupd            tprocess.dteupd%type;
    v_coduser           tprocess.coduser%type;
    v_linkurl           tprocess.linkurl%type;
  begin
    begin
      select decode(global_v_lang, '101', desproce
                                 , '102', desproct
                                 , '103', desproc3
                                 , '104', desproc4
                                 , '105', desproc5
                                 , '') desproc,
             desproce, desproct, desproc3, desproc4, desproc5, codimage,
             flgcreate, dtecreate, codcreate, dteupd, coduser,linkurl
        into v_desproc, v_desproce, v_desproct, v_desproc3, v_desproc4, v_desproc5, v_codimage,
             v_flgcreate, v_dtecreate, v_codcreate, v_dteupd, v_coduser,v_linkurl
        from tprocess
       where codproc = p_codproc;
    exception when no_data_found then
      null;
    end;
    if p_codprocQuery is not null then
      v_flgcreate := '2';
    end if;
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codproc', nvl(p_codprocQuery, p_codproc));
    obj_data.put('desproc', v_desproc);
    obj_data.put('desproce', v_desproce);
    obj_data.put('desproct', v_desproct);
    obj_data.put('desproc3', v_desproc3);
    obj_data.put('desproc4', v_desproc4);
    obj_data.put('desproc5', v_desproc5);
    obj_data.put('codimage', v_codimage);
    obj_data.put('flgcreate', v_flgcreate);
    obj_data.put('dteupd', to_char(nvl(v_dteupd, v_dtecreate), 'dd/mm/yyyy'));
    obj_data.put('coduser', nvl(v_coduser, v_codcreate));
    obj_data.put('desc_coduser', get_temploy_name(get_codempid(nvl(v_coduser, v_codcreate)), global_v_lang));
    obj_data.put('linkurl', v_linkurl);
    json_str_output := obj_data.to_clob;
  end gen_tprocess;

  procedure get_tprocapp (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_tprocapp (json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tprocapp;

  procedure gen_tprocapp (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1_tprocapp is
      select numseq1, numseq2, numseq3, numseq4,
             decode(global_v_lang, '101', desappe
                                 , '102', desappt
                                 , '103', desapp3
                                 , '104', desapp4
                                 , '105', desapp5
                                 , '') desapp,
             codapp, desappe, desappt, desapp3, desapp4, desapp5,
             dteupd, coduser,linkurl
        from tprocapp
       where codproc = p_codproc
       order by numseq1, numseq2, numseq3, numseq4;
  begin
    obj_row             := json_object_t();

    for r1 in c1_tprocapp loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codproc', p_codproc);
      obj_data.put('numseq1', r1.numseq1);
      obj_data.put('numseq2', r1.numseq2);
      obj_data.put('numseq3', r1.numseq3);
      obj_data.put('numseq4', r1.numseq4);
      obj_data.put('no', r1.numseq1 || '.' || r1.numseq2 || '.' || r1.numseq3 || '.' || r1.numseq4);
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
      obj_data.put('linkurl', r1.linkurl);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tprocapp;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        p_codproc         := hcm_util.get_string_t(json_row, 'codproc');
        if v_flg = 'delete' then
          if param_msg_error is null then
            begin
              delete from tprocess
              where codproc = p_codproc
                and flgcreate <> '1';
            exception when others then
              param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            end;
          end if;
          if param_msg_error is null then
            begin
              delete from tprocapp
              where codproc = p_codproc;
            exception when others then
              param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            end;
          end if;
        end if;
      end loop;
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
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  procedure initial_save (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    -- detail
    p_codproc           := upper(hcm_util.get_string_t(json_obj, 'codproc'));
    p_desproc           := upper(hcm_util.get_string_t(json_obj, 'desproc'));
    p_desproce          := hcm_util.get_string_t(json_obj, 'desproce');
    p_desproct          := hcm_util.get_string_t(json_obj, 'desproct');
    p_desproc3          := hcm_util.get_string_t(json_obj, 'desproc3');
    p_desproc4          := hcm_util.get_string_t(json_obj, 'desproc4');
    p_desproc5          := hcm_util.get_string_t(json_obj, 'desproc5');
    p_codimage          := hcm_util.get_string_t(json_obj, 'codimage');
    p_linkurl           := hcm_util.get_string_t(json_obj, 'linkurl');
    if global_v_lang = '101' then
      p_desproce := p_desproc;
    elsif global_v_lang = '102' then
      p_desproct := p_desproc;
    elsif global_v_lang = '103' then
      p_desproc3 := p_desproc;
    elsif global_v_lang = '104' then
      p_desproc4 := p_desproc;
    elsif global_v_lang = '105' then
      p_desproc5 := p_desproc;
    end if;
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'tprocapp');

  end initial_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_codapp            tprocapp.codapp%type;
    v_numseq1           tprocapp.numseq1%type;
    v_numseq2           tprocapp.numseq2%type;
    v_numseq3           tprocapp.numseq3%type;
    v_numseq4           tprocapp.numseq4%type;
    v_desapp            tprocapp.desappe%type;
    v_desappe           tprocapp.desappe%type;
    v_desappt           tprocapp.desappt%type;
    v_desapp3           tprocapp.desapp3%type;
    v_desapp4           tprocapp.desapp4%type;
    v_desapp5           tprocapp.desapp5%type;
    v_linkurl           tprocapp.linkurl%type;
    v_check             varchar2(10);
  begin
    initial_value (json_str_input);
    initial_save (json_str_input);
    if param_msg_error is null then
--<< user22 : 07/08/2022 : ST11 ||
      v_check := std_sc.chk_license_by_menu(p_codproc);
      if v_check = 'N' then
        param_msg_error := get_error_msg_php('HR8888', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return;        
      end if;
-->> user22 : 07/08/2022 : ST11 ||
      begin
        insert into tprocess
               (codproc, desproce, desproct, desproc3, desproc4, desproc5, codimage, flgcreate, codcreate, linkurl)
        values (p_codproc, p_desproce, p_desproct, p_desproc3, p_desproc4, p_desproc5, p_codimage, '2', global_v_coduser, p_linkurl);
      exception when dup_val_on_index then
        update tprocess
           set desproce  = p_desproce,
               desproct  = p_desproct,
               desproc3  = p_desproc3,
               desproc4  = p_desproc4,
               desproc5  = p_desproc5,
               codimage  = p_codimage,
               linkurl   = p_linkurl,
               coduser   = global_v_coduser
         where codproc = p_codproc;
      end;
      begin
        delete from tprocapp where codproc = p_codproc;
      exception when others then
        null;
      end;
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_numseq1         := hcm_util.get_string_t(json_row, 'numseq1');
        v_numseq2         := hcm_util.get_string_t(json_row, 'numseq2');
        v_numseq3         := hcm_util.get_string_t(json_row, 'numseq3');
        v_numseq4         := hcm_util.get_string_t(json_row, 'numseq4');
        v_codapp          := hcm_util.get_string_t(json_row, 'codapp');
        v_desapp          := hcm_util.get_string_t(json_row, 'desapp');
        v_desappe         := hcm_util.get_string_t(json_row, 'desappe');
        v_desappt         := hcm_util.get_string_t(json_row, 'desappt');
        v_desapp3         := hcm_util.get_string_t(json_row, 'desapp3');
        v_desapp4         := hcm_util.get_string_t(json_row, 'desapp4');
        v_desapp5         := hcm_util.get_string_t(json_row, 'desapp5');
        v_linkurl         := hcm_util.get_string_t(json_row, 'linkurl');        
        if global_v_lang = '101' then
          v_desappe := v_desapp;
        elsif global_v_lang = '102' then
          v_desappt := v_desapp;
        elsif global_v_lang = '103' then
          v_desapp3 := v_desapp;
        elsif global_v_lang = '104' then
          v_desapp4 := v_desapp;
        elsif global_v_lang = '105' then
          v_desapp5 := v_desapp;
        end if;
        begin
          insert into tprocapp
                 (codproc, numseq1, numseq2, numseq3, numseq4, codapp, desappe, desappt, desapp3, desapp4, desapp5, coduser, linkurl)
          values (p_codproc, v_numseq1, v_numseq2, v_numseq3, v_numseq4, v_codapp, v_desappe, v_desappt, v_desapp3, v_desapp4, v_desapp5, global_v_coduser, v_linkurl);
        exception when others then
          null;
        end;
      end loop;
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
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
  --
end HRSC15E;

/
