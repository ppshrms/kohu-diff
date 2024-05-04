--------------------------------------------------------
--  DDL for Package Body HRCO34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO34E" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    params_json         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
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
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_status           varchar2(100 char);

    cursor cl is
      select errorno, errortyp,
             decode(global_v_lang, '101', descripe,
                                   '102', descript,
                                   '103', descrip3,
                                   '104', descrip4,
                                   '105', descrip5,
                                   descripe) descrip,
             descripe, descript, descrip3, descrip4, descrip5
        from terrorm
    order by errorno;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in cl loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('errorno', r1.errorno);
      obj_data.put('errortyp', r1.errortyp);
      obj_data.put('desc_errortyp', get_tlistval_name('TYPEERR', r1.errortyp, global_v_lang));
      obj_data.put('descrip', r1.descrip);
      obj_data.put('descripe', r1.descripe);
      obj_data.put('descript', r1.descript);
      obj_data.put('descrip3', r1.descrip3);
      obj_data.put('descrip4', r1.descrip4);
      obj_data.put('descrip5', r1.descrip5);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure check_save as
  begin
    if p_errorno is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_errortyp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;

  procedure post_save (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_data;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end post_save;

  procedure save_data as
    json_obj         json_object_t;
    v_flg            varchar2(10 char);

  begin
    for i in 0..params_json.get_size - 1 loop
      json_obj            := hcm_util.get_json_t(params_json, to_char(i));
      v_flg               := hcm_util.get_string_t(json_obj, 'flg');
      p_errorno           := hcm_util.get_string_t(json_obj, 'errorno');
      p_errortyp          := hcm_util.get_string_t(json_obj, 'errortyp');
      p_descripe          := hcm_util.get_string_t(json_obj, 'descripe');
      p_descript          := hcm_util.get_string_t(json_obj, 'descript');
      p_descrip3          := hcm_util.get_string_t(json_obj, 'descrip3');
      p_descrip4          := hcm_util.get_string_t(json_obj, 'descrip4');
      p_descrip5          := hcm_util.get_string_t(json_obj, 'descrip5');
      check_save;
      if param_msg_error is not null then
        return;
      else
        if v_flg = 'delete' then
          begin
            Delete
              From terrorm
             Where errorno = p_errorno;
          exception when others then
            null;
          end;
        else
          begin
            insert into terrorm
                      (
                        errorno, errortyp, descripe, descript,
                        descrip3, descrip4, descrip5,
                        dtecreate, codcreate
                        )
                values (
                        p_errorno, p_errortyp, p_descripe, p_descript,
                        p_descrip3, p_descrip4, p_descrip5,
                        sysdate, global_v_coduser
                        );
          exception when dup_val_on_index then
            if v_flg = 'add' then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang, 'TERRORM');
            else
              update terrorm
                set errortyp = p_errortyp,
                    descripe = p_descripe,
                    descript = p_descript,
                    descrip3 = p_descrip3,
                    descrip4 = p_descrip4,
                    descrip5 = p_descrip5,
                    dteupd   = sysdate,
                    coduser  = global_v_coduser
              where errorno  = p_errorno;
            end if;
          end;
        end if;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end save_data;

  procedure get_typeauth (json_str_input in clob, json_str_output out clob) AS
    v_typeauth          tusrprof.typeauth%type;
    obj_data            json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      begin
        select typeauth
          into v_typeauth
          from tusrprof
         where coduser = global_v_coduser;
      exception when no_data_found then
        null;
      end;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('typeauth', v_typeauth);
      json_str_output   := obj_data.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_typeauth;
end HRCO34E;

/
