--------------------------------------------------------
--  DDL for Package Body HRBF4PE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4PE" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
     select codcnty, codgrpcnty
       from tgrpcnty
      order by codcnty;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcnty', i.codcnty);
      obj_data.put('codgrpcnty', i.codgrpcnty);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_codcnty           tgrpcnty.codcnty%type;
    v_codgrpcnty        tgrpcnty.codgrpcnty%type;
    v_codgrpcntyOld     tgrpcnty.codgrpcnty%type;
    v_flg               varchar2(10 char);
    v_check_flg         boolean := false;
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(json_params, to_char(i));
      if param_msg_error is null then
        v_flg             := hcm_util.get_string_t(obj_data, 'flg');
        v_codcnty         := hcm_util.get_string_t(obj_data, 'codcnty');
        v_codgrpcnty      := hcm_util.get_string_t(obj_data, 'codgrpcnty');
        v_codgrpcntyOld   := hcm_util.get_string_t(obj_data, 'codgrpcntyOld');
        if v_flg = 'delete' then
          begin
            delete from tgrpcnty
             where codcnty    = v_codcnty
               and codgrpcnty = v_codgrpcnty;
          exception when others then
            null;
          end;
        elsif v_flg = 'edit' then
          v_check_flg := true;
          update tgrpcnty
             set codgrpcnty = v_codgrpcnty,
                 coduser    = global_v_coduser,
                 dteupd     = sysdate
           where codcnty    = v_codcnty
             and codgrpcnty = v_codgrpcntyOld;
        else
          v_check_flg := true;
          begin
            insert into tgrpcnty
                   (codcnty, codgrpcnty, dtecreate, codcreate, coduser)
            values (v_codcnty, v_codgrpcnty, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      commit;
      if v_check_flg then
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2425', global_v_lang);
      end if;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;
end HRBF4PE;


/
