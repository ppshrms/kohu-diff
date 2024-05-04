--------------------------------------------------------
--  DDL for Package Body HRSC02E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC02E" is
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
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codproc           := upper(hcm_util.get_string_t(json_obj, 'p_codproc'));
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

    -- hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codapp          tappprof.codapp%type;
  begin
    if p_codapp is not null then
      begin
        select codapp
          into v_codapp
          from tappprof
         where codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tappprof');
        return;
      end;
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
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
    v_flgcreate         varchar2(1 char);

    cursor c_tappprof is
      select codapp, typapp, codproc,
             decode(global_v_lang, '101', desappe
                                 , '102', desappt
                                 , '103', desapp3
                                 , '104', desapp4
                                 , '105', desapp5
                                 , null) as desapp,
             desappe,
             desappt,
             desapp3,
             desapp4,
             desapp5,
             decode(global_v_lang, '101', desrepe
                                 , '102', desrept
                                 , '103', desrep3
                                 , '104', desrep4
                                 , '105', desrep5
                                 , null) as desrep,
             desrepe,
             desrept,
             desrep3,
             desrep4,
             desrep5,
             dteupd, coduser
        from tappprof
       where codapp  = nvl(p_codapp, codapp)
         and codproc like nvl(p_codproc, codproc)
       order by codapp;

  begin
    obj_row            := json_object_t();
    for r1 in c_tappprof loop
      v_rcnt             := v_rcnt + 1;
      obj_data           := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', r1.codapp);
      obj_data.put('typapp', r1.typapp);
      obj_data.put('desc_typapp', get_tlistval_name('TYPAPP', r1.typapp, global_v_lang));
      obj_data.put('codproc', r1.codproc);
      obj_data.put('desapp', r1.desapp);
      obj_data.put('desappe', r1.desappe);
      obj_data.put('desappt', r1.desappt);
      obj_data.put('desapp3', r1.desapp3);
      obj_data.put('desapp4', r1.desapp4);
      obj_data.put('desapp5', r1.desapp5);
      obj_data.put('desrep', r1.desrep);
      obj_data.put('desrepe', r1.desrepe);
      obj_data.put('desrept', r1.desrept);
      obj_data.put('desrep3', r1.desrep3);
      obj_data.put('desrep4', r1.desrep4);
      obj_data.put('desrep5', r1.desrep5);
      obj_data.put('dteupd', to_char(r1.dteupd, 'dd/mm/yyyy'));
      obj_data.put('coduser', get_temploy_name(get_codempid(r1.coduser), global_v_lang));
      begin
        select 'Y'
          into v_flgcreate
          from tprocess
         where codproc   = r1.codproc
           and flgcreate = 1;
      exception when no_data_found then
        v_flgcreate := 'N';
      end;
      obj_data.put('flgcreate', v_flgcreate);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure check_save is
    v_codapp          tappprof.codapp%type;
  begin
    if p_codapp is not null then
      begin
        select codapp
          into v_codapp
          from tappprof
         where codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tappprof');
        return;
      end;
    end if;
  end;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_codapp            tappprof.codapp%type;
    v_typapp            tappprof.typapp%type;
    v_codproc           tappprof.codproc%type;
    v_desapp            tappprof.desappe%type;
    v_desappe           tappprof.desappe%type;
    v_desappt           tappprof.desappt%type;
    v_desapp3           tappprof.desapp3%type;
    v_desapp4           tappprof.desapp4%type;
    v_desapp5           tappprof.desapp5%type;
    v_desrep            tappprof.desrepe%type;
    v_desrepe           tappprof.desrepe%type;
    v_desrept           tappprof.desrept%type;
    v_desrep3           tappprof.desrep3%type;
    v_desrep4           tappprof.desrep4%type;
    v_desrep5           tappprof.desrep5%type;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codapp          := upper(hcm_util.get_string_t(json_row, 'codapp'));
        v_typapp          := upper(hcm_util.get_string_t(json_row, 'typapp'));
        v_codproc         := upper(hcm_util.get_string_t(json_row, 'codproc'));
        v_desapp          := hcm_util.get_string_t(json_row, 'desapp');
        v_desappe         := hcm_util.get_string_t(json_row, 'desappe');
        v_desappt         := hcm_util.get_string_t(json_row, 'desappt');
        v_desapp3         := hcm_util.get_string_t(json_row, 'desapp3');
        v_desapp4         := hcm_util.get_string_t(json_row, 'desapp4');
        v_desapp5         := hcm_util.get_string_t(json_row, 'desapp5');
        v_desrep          := hcm_util.get_string_t(json_row, 'desrep');
        v_desrepe         := hcm_util.get_string_t(json_row, 'desrepe');
        v_desrept         := hcm_util.get_string_t(json_row, 'desrept');
        v_desrep3         := hcm_util.get_string_t(json_row, 'desrep3');
        v_desrep4         := hcm_util.get_string_t(json_row, 'desrep4');
        v_desrep5         := hcm_util.get_string_t(json_row, 'desrep5');
        if global_v_lang = '101' then
          v_desappe := v_desapp;
          v_desrepe := v_desrep;
        elsif global_v_lang = '102' then
          v_desappt := v_desapp;
          v_desrept := v_desrep;
        elsif global_v_lang = '103' then
          v_desapp3 := v_desapp;
          v_desrep3 := v_desrep;
        elsif global_v_lang = '104' then
          v_desapp4 := v_desapp;
          v_desrep4 := v_desrep;
        elsif global_v_lang = '105' then
          v_desapp5 := v_desapp;
          v_desrep5 := v_desrep;
        end if;
        if v_flg = 'edit' then
          p_codapp := v_codapp;
          check_save;
          if param_msg_error is not null then
            exit;
          end if;

          begin
            update tappprof
              set desappe = v_desappe,
                  desappt = v_desappt,
                  desapp3 = v_desapp3,
                  desapp4 = v_desapp4,
                  desapp5 = v_desapp5,
                  desrepe = v_desrepe,
                  desrept = v_desrept,
                  desrep3 = v_desrep3,
                  desrep4 = v_desrep4,
                  desrep5 = v_desrep5,
                  dteupd  = sysdate,
                  coduser = global_v_coduser
            where codapp  = v_codapp;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
          begin
            update tprocapp
              set desappe = v_desappe,
                  desappt = v_desappt,
                  desapp3 = v_desapp3,
                  desapp4 = v_desapp4,
                  desapp5 = v_desapp5,
                  dteupd  = sysdate,
                  coduser = global_v_coduser
            where codapp  = v_codapp
              and codproc IN (select codproc from tprocess where flgcreate = '1');
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
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
end HRSC02E;

/
