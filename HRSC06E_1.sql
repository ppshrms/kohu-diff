--------------------------------------------------------
--  DDL for Package Body HRSC06E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC06E" as
-- last update: 15/05/2022 21:33

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

    -- index params
    b_index_codcompy    := upper(hcm_util.get_string_t(json_obj, 'p_codcompy'));
    b_index_dteeffec    := to_date(upper(hcm_util.get_string_t(json_obj, 'p_dteeffec')),'dd/mm/yyyy');

    -- save index
    p_typecodusr        := hcm_util.get_string_t(json_obj, 'p_typecodusr');
    p_typepwd           := hcm_util.get_string_t(json_obj, 'p_typepwd');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
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
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_row_m           json_object_t;
    obj_data_m          json_object_t;
    json_obj            json_object_t;
    v_row               number;
    v_row_m             number;
    v_dteeffec          date;
    v_numseq            number;
    v_response          varchar2(1000 char);

    cursor c_tcontrusr is
      select dteeffec,typecodusr,typepwd
        from tcontrusr
       where codcompy = b_index_codcompy
         and dteeffec = v_dteeffec;

    cursor c_tcontrusrd is
      select numseq,syncond,statement,typeusr
        from tcontrusrd
       where codcompy = b_index_codcompy
         and dteeffec = v_dteeffec
      order by numseq;

    cursor c_tcontrusrm is
      select codproc
        from tcontrusrm
       where codcompy = b_index_codcompy
         and dteeffec = v_dteeffec
         and numseq   = v_numseq
      order by codproc;
  begin
    begin
      select max(dteeffec) into v_dteeffec
        from tcontrusr
       where codcompy = b_index_codcompy
         and dteeffec <= b_index_dteeffec;
    exception when others then
      v_dteeffec := null;
    end;

    json_obj := json_object_t();
    if b_index_dteeffec < trunc(sysdate) then
        json_obj.put('isAdd',false);
        json_obj.put('isEdit',false);
    else
        if b_index_dteeffec = v_dteeffec then
            json_obj.put('isAdd',false);
            json_obj.put('isEdit',true);
        else
            json_obj.put('isAdd',true);
            json_obj.put('isEdit',false);
        end if;
    end if;

    json_obj.put('codcompy',b_index_codcompy);
    for r_tcontrusr in c_tcontrusr loop
        json_obj.put('typecodusr',r_tcontrusr.typecodusr);
        json_obj.put('typepwd',r_tcontrusr.typepwd);
    end loop;

    v_row      := 0;
    obj_row    := json_object_t();
    for r_tcontrusrd in c_tcontrusrd loop
      v_row     := v_row + 1;
      obj_data  := json_object_t();
      obj_data.put('numseq',to_char(r_tcontrusrd.numseq));
      obj_data.put('codcompy', b_index_codcompy);
      obj_data.put('dteeffec', to_char(b_index_dteeffec,'dd/mm/yyyy'));
      obj_data.put('syncond', r_tcontrusrd.syncond);
      obj_data.put('desc_syncond', get_logical_desc(r_tcontrusrd.statement));
      obj_data.put('statement', r_tcontrusrd.statement);
      obj_data.put('typeusr', r_tcontrusrd.typeusr);

      v_numseq  := r_tcontrusrd.numseq;
      v_row_m   := 0;
      obj_row_m := json_object_t();
      for r_tcontrusrm in c_tcontrusrm loop
        v_row_m    := v_row_m + 1;
        obj_data_m := json_object_t();
        obj_data_m.put('codproc', r_tcontrusrm.codproc);
        obj_row_m.put(to_char(v_row_m-1), obj_data_m);
      end loop;
      obj_data.put('children', obj_row_m);

      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;

    v_response := get_response_message(null,param_msg_error,global_v_lang);
    json_obj.put('coderror',hcm_util.get_string_t(json_object_t(v_response),'coderror'));
    json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
    if b_index_dteeffec < trunc(sysdate) and v_row > 0 then
      json_obj.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
      v_response := get_response_message(null,get_error_msg_php('HR1501',global_v_lang),global_v_lang);
      json_obj.put('warning_message',hcm_util.get_string_t(json_object_t(v_response),'response'));
    elsif b_index_dteeffec < trunc(sysdate) and v_row = 0 then
      json_obj.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
      param_msg_error := get_error_msg_php('HR1501',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      json_obj.put('warning_message',hcm_util.get_string_t(json_object_t(v_response),'response'));
    else
      json_obj.put('dteeffec',to_char(b_index_dteeffec,'dd/mm/yyyy'));
      json_obj.put('warning_message', '');
    end if;
    json_obj.put('table',obj_row);

    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure check_save (p_syncond varchar2,p_statement clob,p_typeusr varchar2) is
  begin
    if p_syncond is null then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'syncond');
        return;
    end if;
    if p_statement is null then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'statement');
        return;
    end if;
    if p_typeusr is null then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'typeusr');
        return;
    end if;
  end;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    param_json              json_object_t;
    param_json_row          json_object_t;
    param_json_child        json_object_t;
    param_json_child_row    json_object_t;
    v_flg_parent_delete     boolean;
    v_flg_child_delete      boolean;
    v_numseq                tcontrusrd.numseq%type;
    v_numseq_reorder        tcontrusrd.numseq%type;
    obj_syncond             json_object_t;
    v_syncond               tcontrusrd.syncond%type;
    v_statement             tcontrusrd.statement%type;
    v_typeusr               tcontrusrd.typeusr%type;
    v_codproc               tcontrusrm.codproc%type;

  begin
    initial_value (json_str_input);

    -- insert/update tcontrusr
    begin
        insert into tcontrusr (codcompy,dteeffec,typecodusr,typepwd,
                               codcreate,coduser)
        values(b_index_codcompy,b_index_dteeffec,p_typecodusr,p_typepwd,
               global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
        update tcontrusr
           set typecodusr = p_typecodusr,
               typepwd = p_typepwd,
               coduser = global_v_coduser
         where codcompy = b_index_codcompy
           and dteeffec = b_index_dteeffec;
    end;

    -- delete before insert/update
    begin
        delete from tcontrusrd
         where codcompy  = b_index_codcompy
           and dteeffec  = b_index_dteeffec;

        delete from tcontrusrm
         where codcompy  = b_index_codcompy
           and dteeffec  = b_index_dteeffec;
    exception when others then null;
    end;

    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str2');
    if param_msg_error is null then
        v_numseq_reorder := 0;

        for i in 0..param_json.get_size - 1 loop
            param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
            v_flg_parent_delete := hcm_util.get_boolean_t(param_json_row,'flgDelete');
            v_numseq            := hcm_util.get_string_t(param_json_row,'numseq');
            obj_syncond         := hcm_util.get_json_t(param_json_row,'syncond');
            v_syncond           := hcm_util.get_string_t(obj_syncond, 'code');
            v_statement         := hcm_util.get_string_t(obj_syncond, 'statement');
            v_typeusr           := hcm_util.get_string_t(param_json_row, 'typeusr');

            if not v_flg_parent_delete then
                check_save(v_syncond,v_statement,v_typeusr);
                if param_msg_error is null then
                    v_numseq_reorder := v_numseq_reorder + 1;
                    begin
                        insert into tcontrusrd (codcompy,dteeffec,numseq,
                                                syncond,statement,typeusr,
                                                codcreate,coduser)
                        values(b_index_codcompy,b_index_dteeffec,v_numseq_reorder,
                               v_syncond,v_statement,v_typeusr,
                               global_v_coduser,global_v_coduser);
                    exception when dup_val_on_index then
                        update tcontrusrd
                           set syncond   = v_syncond,
                               statement = v_statement,
                               typeusr   = v_typeusr,
                               coduser   = global_v_coduser
                         where codcompy  = b_index_codcompy
                           and dteeffec  = b_index_dteeffec
                           and numseq    = v_numseq_reorder;
                    end;

                    param_json_child  := hcm_util.get_json_t(param_json_row,'children');

                    for j in 0..param_json_child.get_size - 1 loop
                        param_json_child_row    := hcm_util.get_json_t(param_json_child,to_char(j));
                        v_flg_child_delete      := hcm_util.get_boolean_t(param_json_child_row,'flgDelete');
                        v_codproc               := hcm_util.get_string_t(param_json_child_row,'codproc');

                        if not v_flg_child_delete then
                            begin
                                insert into tcontrusrm (codcompy,dteeffec,numseq,
                                                        codproc,
                                                        codcreate,coduser)
                                values(b_index_codcompy,b_index_dteeffec,v_numseq_reorder,
                                       v_codproc,
                                       global_v_coduser,global_v_coduser);
                            exception when dup_val_on_index then
                                update tcontrusrm
                                   set codproc   = v_codproc,
                                       coduser   = global_v_coduser
                                 where codcompy  = b_index_codcompy
                                   and dteeffec  = b_index_dteeffec
                                   and numseq    = v_numseq_reorder;
                            end;
                        end if;

                    end loop; -- child
                end if; -- if param_msg_error is null then
            end if; -- if not v_flg_parent_delete then
        end loop; -- parent
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
  end save_index;

end HRSC06E;

/
