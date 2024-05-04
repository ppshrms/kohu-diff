--------------------------------------------------------
--  DDL for Package Body HRPY6CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY6CE" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_dteyear           := to_number(hcm_util.get_string_t(json_obj,'p_dteyear'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_temp				number;
  begin
    if p_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'dteyear');
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index;

  procedure check_save is
    v_empid     varchar2(100 char);
    v_comp      varchar2(100 char);
    v_empid1    varchar2(100 char);
    v_pos       varchar2(100 char);
    v_flgsecur  boolean;
  begin

    begin
      select codempid,codpos,codcomp
        into v_empid,v_pos,v_comp
        from temploy1
       where codempid = v_codempid
         and codcomp  like p_codcomp||'%';
    exception when no_data_found then
      v_empid := null;
      v_pos   := null;
    end;
    -- chk null
    if v_empid is null then
      param_msg_error := get_error_msg_php('HR7523', global_v_lang, 'TEMPLOY1');
    end if;
    --chk dup
    begin
      select codempid
        into v_empid1
        from tlstrevn
       where dteyear  = p_dteyear
         and codempid = v_codempid;
    exception when no_data_found then
      v_empid1 := null;
    end;
    if v_empid1 is not null then
      param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TLSTREVN');
    end if;

    if v_codempid is null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,v_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    v_flgsecur := secur_main.secur7(p_codcomp,global_v_coduser);
    if not v_flgsecur then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    end if;
  end check_save;

  procedure gen_index(json_str_output out clob) is
    obj_row           json_object_t := json_object_t();
    obj_data          json_object_t;
    v_row             number := 0;
    v_pos             varchar2(100 char);
    v_flg_exist       boolean := false;
    v_flg_secure      boolean := false;
    v_flg_permission  boolean := false;

    cursor c1 is
      select codempid,codcomp
        from tlstrevn
       where dteyear = p_dteyear
         and codcomp like p_codcomp||'%'
      order by codempid;

  begin
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    --

    for r1 in c1 loop
      v_flg_secure := secur_main.secur2(r1.codempid, global_v_coduser, global_v_numlvlsalst, global_v_numlvlsalen, v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        --
        begin
          select codpos
            into v_pos
            from temploy1
           where codempid = r1.codempid;
        exception when no_data_found then
          v_pos   := null;
        end;
        --
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(v_pos,global_v_lang));
        obj_data.put('codcomp', r1.codcomp);

        obj_row.put(to_char(v_row - 1), obj_data);
      end if;
    end loop;
    if not v_flg_secure and v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tlstrevn');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure get_position(json_str_input in clob, json_str_output out clob) is
    obj_row      json_object_t := json_object_t();
    v_pos        varchar2(100 char);
    v_comp       varchar2(100 char);
    v_empid       varchar2(100 char);
  begin
    initial_value(json_str_input);
    begin
      select codpos,codcomp,codempid
        into v_pos,v_comp,v_empid
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_pos := null;
    end;
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('desc_codempid', v_empid ||' - '|| get_temploy_name(v_empid,global_v_lang));
    obj_row.put('desc_codpos', get_tpostn_name(v_pos,global_v_lang));
    obj_row.put('codcomp', v_comp);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end get_position;

  procedure save_data(json_str_input in clob, json_str_output out clob) is
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_flg             varchar2(10 char);
    v_codcomp         varchar2(100 char);
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
        v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');

        if v_flg = 'add' then
          check_save;
          if param_msg_error is null then
            begin
              insert into tlstrevn
                          (dteyear,codempid,codcomp)
                   values (p_dteyear,v_codempid,v_codcomp);
            exception when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            end;
          end if;
        elsif v_flg = 'delete' then
          delete from tlstrevn
                where dteyear  = p_dteyear
                  and codempid = v_codempid
                  and codcomp  = v_codcomp;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

end HRPY6CE;

/
