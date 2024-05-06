--------------------------------------------------------
--  DDL for Package Body HRPY18E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY18E" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
  end initial_value;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row		number := 0;
    cursor c1 is
      select *
      from tcodeduct
      order by typdeduct,coddeduct;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();

    for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('coddeduct',i.coddeduct);
        obj_data.put('typdeduct',i.typdeduct);
        obj_data.put('descname',i.descname);
        obj_data.put('descnamt',i.descnamt);
        obj_data.put('descnam3',i.descnam3);
        obj_data.put('descnam4',i.descnam4);
        obj_data.put('descnam5',i.descnam5);
        obj_data.put('flgcorr',i.flgcorr);
        obj_data.put('dtecreate',i.dtecreate);
        obj_data.put('codcreate',i.codcreate);
        obj_data.put('dteupd',i.dteupd);
        obj_data.put('coduser',i.coduser);
        obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_save(param_json json_object_t) as
    v_flg       varchar2(6 char);
    v_codeduct  varchar2(4 char);
    v_typdeduct varchar2(1 char);
    json_obj    json_object_t;
    v_count     number := 0;
    v_flgcorr   varchar2(1 char) := 0;
    v_typdeduct_old varchar2(1 char);

  begin
    for i in 0..param_json.get_size-1 loop
        v_count := 0;
        json_obj         := hcm_util.get_json_t(param_json,to_char(i));
        v_flg            := hcm_util.get_string_t(json_obj,'flg');
        v_codeduct       := hcm_util.get_string_t(json_obj,'coddeduct');
        v_typdeduct      := hcm_util.get_string_t(json_obj,'typdeduct');
        v_typdeduct_old  := hcm_util.get_string_t(json_obj,'typdeductold');
        if v_codeduct is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'tcodeduct');
            return;
        end if;
        if v_typdeduct is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'tcodeduct');
            return;
        end if;

        if v_flg = 'add' then
            select count(*) into v_count
                from tcodeduct
                where upper(coddeduct) = upper(v_codeduct);
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tcodeduct');
                return;
            end if;
        elsif v_flg = 'edit' then
            select count(*)
                into v_count
                from tdeductd
                where upper(coddeduct) = upper(v_codeduct);
            if v_count > 0 and v_typdeduct != v_typdeduct_old then
                param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tcodeduct');
            end if;
        elsif v_flg = 'delete' then
            select count(*)
                into v_count
                from tdeductd
                where upper(coddeduct) = upper(v_codeduct);
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tcodeduct');
                return;
            end if;
        end if;
        if regexp_like(v_codeduct,'[a-zA-Z]{1}[0-9]{3}$') = false then
            param_msg_error := get_error_msg_php('PY0053',global_v_lang);
            return;
        end if;
    end loop;
  end;

  procedure add_codeduct(
      v_codeduct varchar2,
      v_typdeduct varchar2,
      v_descname varchar2,
      v_descnamt varchar2,
      v_descnam3 varchar2,
      v_descnam4 varchar2,
      v_descnam5 varchar2,
      v_currentdate date) as
  begin
    insert into
        tcodeduct (
            coddeduct,
            typdeduct,
            descname ,
            descnamt ,
            descnam3 ,
            descnam4 ,
            descnam5 ,
            dtecreate,
            codcreate,
            coduser,
            dteupd)
        values (
            upper(v_codeduct),
            v_typdeduct,
            v_descname ,
            v_descnamt ,
            v_descnam3 ,
            v_descnam4 ,
            v_descnam5 ,
            v_currentdate,
            global_v_coduser,
            global_v_coduser,
            sysdate);
  end add_codeduct;

  procedure edit_codeduct(
      v_flgcorr varchar2,
      v_codeduct varchar2,
      v_typdeduct varchar2,
      v_descname varchar2,
      v_descnamt varchar2,
      v_descnam3 varchar2,
      v_descnam4 varchar2,
      v_descnam5 varchar2,
      v_currentdate date) as
  begin
    if v_flgcorr = '0' then
        update  tcodeduct
        set typdeduct   = v_typdeduct ,
            descname    = v_descname  ,
            descnamt    = v_descnamt  ,
            descnam3    = v_descnam3  ,
            descnam4    = v_descnam4  ,
            descnam5    = v_descnam5  ,
            dteupd      = v_currentdate ,
            coduser     = global_v_coduser
        where
            coddeduct = v_codeduct;
    elsif v_flgcorr = '1' then
        update  tcodeduct
        set descname    = v_descname  ,
            descnamt    = v_descnamt  ,
            descnam3    = v_descnam3  ,
            descnam4    = v_descnam4  ,
            descnam5    = v_descnam5  ,
            dteupd      = v_currentdate ,
            coduser     = global_v_coduser
        where
            coddeduct = v_codeduct;
    end if;
  end;

  procedure save_codeduct(json_str_input in clob,json_str_output out clob) as
    json_obj        json_object_t;
    v_flg           varchar2(6 char);
    v_codeduct      varchar2(4 char);
    v_typdeduct     varchar2(1 char);
    v_descname      varchar2(150 char);
    v_descnamt      varchar2(150 char);
    v_descnam3      varchar2(150 char);
    v_descnam4      varchar2(150 char);
    v_descnam5      varchar2(150 char);
    v_flgcorr       varchar2(1 char) := 0;
    v_currentdate   date;
    v_count         number := 0;
  begin
    initial_value(json_str_input);
    param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    check_save(param_json);
    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    for i in 0..param_json.get_size-1 loop
        json_obj        := hcm_util.get_json_t(param_json,to_char(i));
        v_flg           := hcm_util.get_string_t(json_obj,'flg');
        v_codeduct      := hcm_util.get_string_t(json_obj,'coddeduct');
        v_typdeduct     := hcm_util.get_string_t(json_obj,'typdeduct');
        v_descname      := hcm_util.get_string_t(json_obj,'descname');
        v_descnamt      := hcm_util.get_string_t(json_obj,'descnamt');
        v_descnam3      := hcm_util.get_string_t(json_obj,'descnam3');
        v_descnam4      := hcm_util.get_string_t(json_obj,'descnam4');
        v_descnam5      := hcm_util.get_string_t(json_obj,'descnam5');
        v_flgcorr       := hcm_util.get_string_t(json_obj,'flgcorr');
        begin
            select current_date into v_currentdate from dual;
        end;
        begin
            if v_flg = 'add' then
            add_codeduct(v_codeduct ,v_typdeduct,v_descname ,v_descnamt ,v_descnam3 ,v_descnam4 ,v_descnam5 ,v_currentdate);
            elsif v_flg = 'edit' then
                begin
                    select flgcorr into v_flgcorr
                    from tcodeduct
                    where coddeduct = v_codeduct;
                exception when no_data_found then
                    v_flgcorr := '0';
                end;
                edit_codeduct(v_flgcorr,v_codeduct ,v_typdeduct,v_descname ,v_descnamt ,v_descnam3 ,v_descnam4 ,v_descnam5 ,v_currentdate);
            elsif v_flg = 'delete' then
                delete from tcodeduct
                where
                    upper(coddeduct) = upper(v_codeduct) and
                    flgcorr != '1';
            end if;
        end;
    end loop;

    if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
    else
        rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_codeduct;
end HRPY18E;

/
