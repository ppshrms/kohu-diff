--------------------------------------------------------
--  DDL for Package Body HRRP1IE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP1IE" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codposg     := hcm_util.get_string_t(json_obj,'p_codposg');
  end;

  procedure check_index is
  begin
    if b_index_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompy);
    if param_msg_error is not null then
      return;
    end if;
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

  procedure gen_detail_data(json_str_output out clob)as
    obj_data        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_coduser       tusrprof.coduser%type;
    v_dteupd        date;

    cursor c1 is
      select dteupd,coduser
        from tgrppos
       where codcompy = b_index_codcompy
         and codgrpos = b_index_codposg
      order by dteupd desc;
  begin
    for r1 in c1 loop
      v_coduser := r1.coduser;
      v_dteupd  := r1.dteupd;
      exit;
    end loop;

    begin
      select codempid
        into v_codempid
        from tusrprof
       where coduser = v_coduser;
    exception when no_data_found then
      v_codempid := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codempid', v_codempid);
    obj_data.put('desc_codempid', get_temploy_name(v_codempid,global_v_lang));
    obj_data.put('dteupd', to_char(v_dteupd,'dd/mm/yyyy'));
    obj_data.put('coduser', v_coduser);

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
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

  procedure gen_detail_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data_detail json_object_t;
    obj_row_output  json_object_t;
    v_rcnt          number := 0;

    cursor c1 is
      select codpos
        from tgrppos
       where codcompy = b_index_codcompy
         and codgrpos = b_index_codposg
      order by codpos;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));

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

  procedure get_codpos_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select  codpos,decode(global_v_lang,'101',nampose,
                                          '102',nampost,
                                          '103',nampos3,
                                          '104',nampos4,
                                          '105',nampos5) desc_codpos
        from  tpostn
        /*User37 #7440 1. RP Module 17/01/2022 where codpos not in (select codpos
                                                     from tgrppos
                                                    where codcompy = b_index_codcompy)*/
        order by  codpos;
--        where codpos not in (select codpos
--                               from tgrppos
--                              where codpos not in (select codpos
--                                                     from tgrppos
--                                                    where codcompy = b_index_codcompy
--                                                      and codgrpos = b_index_codposg))

  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpos',i.codpos);
      obj_data.put('desc_codpos',i.desc_codpos);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codpos_all;

  procedure post_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail_codpos(json_str_input);
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

  procedure save_detail_codpos(json_str_input in clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_flg           varchar2(100 char);
    v_codpos        varchar2(100 char);
  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_codpos        := hcm_util.get_string_t(param_json_row,'codpos');
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');

      if v_codpos is null then
         param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpos');
         return;
      end if;

      if v_flg = 'add' then
        begin
          select codpos
            into v_codpos
            from tpostn
            where codpos = upper(v_codpos);
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tpostn');
          return;
        end;
        begin
          insert into tgrppos (codcompy, codgrpos, codpos, codcreate, coduser)
               values (b_index_codcompy, b_index_codposg, v_codpos, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tgrppos');
          return;
        end;
      elsif v_flg = 'delete' then
        begin
          delete from tgrppos
                where codcompy = b_index_codcompy
                  and codgrpos = b_index_codposg
                  and codpos   = v_codpos;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
      end if;
    end loop;
  end save_detail_codpos;

end hrrp1ie;

/
