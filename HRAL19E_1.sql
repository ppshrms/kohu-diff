--------------------------------------------------------
--  DDL for Package Body HRAL19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL19E" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    --get_holiday
    p_codcompy  := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
    p_year      := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    --set_clone_codcompy
    p_codcompy_clone := upper(hcm_util.get_string_t(json_obj,'p_codcompy_clone'));
    p_year_clone     := to_number(hcm_util.get_string_t(json_obj,'p_year_clone'));
    --set_holiday
    p_dtestrt	  := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend	  := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'DD/MM/YYYY');
    p_dtestrto	  := to_date(hcm_util.get_string_t(json_obj,'p_dtestrto'), 'DD/MM/YYYY');
    p_dteendo	  := to_date(hcm_util.get_string_t(json_obj,'p_dteendo'), 'DD/MM/YYYY');
    p_typwork	  := upper(hcm_util.get_string_t(json_obj,'p_typwork'));
    p_flgdelete := hcm_util.get_string_t(json_obj,'p_flgdelete');
    p_desholdy	:= hcm_util.get_string_t(json_obj,'p_desholdy');
    p_desholdye	:= hcm_util.get_string_t(json_obj,'p_desholdye');
    p_desholdyt	:= hcm_util.get_string_t(json_obj,'p_desholdyt');
    p_desholdy3	:= hcm_util.get_string_t(json_obj,'p_desholdy3');
    p_desholdy4	:= hcm_util.get_string_t(json_obj,'p_desholdy4');
    p_desholdy5	:= hcm_util.get_string_t(json_obj,'p_desholdy5');
    begin
      if global_v_lang = '101' then
        p_desholdye	:= hcm_util.get_string_t(json_obj,'p_desholdy');
      end if;
      if global_v_lang = '102' then
        p_desholdyt	:= hcm_util.get_string_t(json_obj,'p_desholdy');
      end if;
      if global_v_lang = '103' then
        p_desholdy3	:= hcm_util.get_string_t(json_obj,'p_desholdy');
      end if;
      if global_v_lang = '104' then
        p_desholdy4	:= hcm_util.get_string_t(json_obj,'p_desholdy');
      end if;
      if global_v_lang = '105' then
        p_desholdy5	:= hcm_util.get_string_t(json_obj,'p_desholdy');
      end if;
    end;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codcomp');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;

  procedure get_holiday(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_holiday(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_holiday;

  procedure gen_holiday(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    objLang         json_object_t;

    v_rcnt          number;
    cursor c_tholiday is
      select codcompy, dteyear, dtedate, typwork,desholdye,desholdyt,desholdy3,desholdy4,desholdy5,
             decode(global_v_lang, '101', desholdye,
                                   '102', desholdyt,
                                   '103', desholdy3,
                                   '104', desholdy4,
                                   '105', desholdy5,
                                   '') desholdy,
             dteupd, coduser, count(1) over() as totalrec
        from tholiday
       where dteyear = nvl(p_year, to_char(sysdate, 'YYYY'))
         and upper(codcompy) = p_codcompy
    order by dtedate ASC;
  begin
    v_rcnt     := 0;
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    for i in c_tholiday loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('codcompy', i.codcompy);
      obj_data.put('dteyear',i.dteyear + global_v_zyear);
      obj_data.put('dtedate',to_char(i.dtedate, 'DD/MM/YYYY'));
      obj_data.put('typwork',i.typwork);
      obj_data.put('desholdy',i.desholdy);
      obj_data.put('desholdye',i.desholdye);
      obj_data.put('desholdyt',i.desholdyt);
      obj_data.put('desholdy3',i.desholdy3);
      obj_data.put('desholdy4',i.desholdy4);
      obj_data.put('desholdy5',i.desholdy5);

      obj_data.put('dteupd',to_char(i.dteupd, 'DD/MM/YYYY'));
      obj_data.put('coduser',i.coduser);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_holiday;

  procedure set_holiday(json_str_input in clob, json_str_output out clob) as
    b_dtedate date;
    v_count number;
  begin
    initial_value(json_str_input);

    begin
        select count(dtedate) into v_count from tholiday
              where upper(codcompy) = p_codcompy
                and dteyear = p_year;
    exception when others then
      v_count := 0;
    end;

    for i in 0 .. p_dteendo - p_dtestrto loop
      b_dtedate := to_date(p_dtestrto + i);
      if b_dtedate < trunc(sysdate) and v_count >0 then
        param_msg_error := get_error_msg_php('HR1501',global_v_lang);
      end if;
    end loop;

    for i in 0 .. p_dteend - p_dtestrt loop
      b_dtedate := to_date(p_dtestrt + i);
      if b_dtedate < trunc(sysdate) and v_count >0 then
        param_msg_error := get_error_msg_php('HR1501',global_v_lang);
      end if;
    end loop;

    if param_msg_error is null then
      param_msg_error := hcm_validate.validate_lov('typwork', p_typwork, global_v_lang);
      begin
        if param_msg_error is null then
          if p_flgdelete = 'Y' then
            delete
              from tholiday
             where codcompy = p_codcompy
               and dtedate between p_dtestrto and p_dteendo;
               param_msg_error := get_error_msg_php('HR2425',global_v_lang);
          else
            delete
              from tholiday
             where codcompy = p_codcompy
               and dtedate between p_dtestrto and p_dteendo
               and dtedate not  between p_dtestrt and p_dteend;
               param_msg_error := get_error_msg_php('HR2425',global_v_lang);

            for i in 0 .. p_dteend - p_dtestrt loop
              b_dtedate := to_date(p_dtestrt + i);
              begin
                insert into tholiday
                (codcompy, dteyear, dtedate, typwork, desholdye, desholdyt, desholdy3, desholdy4, desholdy5, codcreate, coduser)
                values
                (p_codcompy, to_number(to_char(b_dtedate, 'YYYY')), b_dtedate, p_typwork, p_desholdye, p_desholdyt, p_desholdy3, p_desholdy4, p_desholdy5, global_v_coduser, global_v_coduser );
              exception when DUP_VAL_ON_INDEX then
                update tholiday
                   set typwork   = p_typwork,
                       desholdye = p_desholdye,
                       desholdyt = p_desholdyt,
                       desholdy3 = p_desholdy3,
                       desholdy4 = p_desholdy4,
                       desholdy5 = p_desholdy5,
                       coduser = global_v_coduser
                where codcompy = p_codcompy
                  and dtedate = b_dtedate
                  and dteyear = to_char(b_dtedate, 'YYYY');
              end;
            end loop;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          end if;
          commit;
        else
          rollback;
        end if;
      end;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end set_holiday;

  procedure get_list_codcompy(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_list_codcompy(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_list_codcompy;

  procedure gen_list_codcompy(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number;
    v_secur         varchar2(100 char);
    cursor c_tholiday is
      select codcompy, dteyear, count(1) over() as totalrec
        from tholiday
    group by codcompy, dteyear
    order by codcompy, dteyear;
  begin
    v_rcnt     := 0;
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    for i in c_tholiday loop
      v_secur     := hcm_secur.secur_main7(i.codcompy, global_v_coduser);
      if v_secur = 'Y' then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcompy',i.codcompy);
        obj_data.put('desc_codcompy',nvl(get_tcompny_name(i.codcompy, global_v_lang), i.codcompy));
        obj_data.put('year', to_char(i.dteyear));

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_list_codcompy;

  procedure set_clone_codcompy(json_str_input in clob, json_str_output out clob) as
    v_dtedate             date;
    v_dtedate_st          date;
    v_month_diff          number := 1;
    v_count               number := 0;
    cursor c_tholiday is
      select codcompy, dteyear, dtedate, typwork,
             desholdye, desholdyt, desholdy3, desholdy4, desholdy5
        from tholiday
       where dteyear = p_year_clone
         and upper(codcompy) = p_codcompy_clone
         and ((v_count>0 and dtedate>= v_dtedate_st) or v_count = 0 )
    order by dtedate ASC;
  begin
    initial_value(json_str_input);
    v_dtedate_st := to_date(to_char(sysdate,'dd/mm') || p_year_clone,'dd/mm/yyyy');
    begin
        select count(dtedate) into v_count from tholiday
              where upper(codcompy) = p_codcompy
                and dteyear = p_year;
    exception when others then
      v_count := 0;
    end;

    if param_msg_error is null then
      begin
        delete from tholiday
              where upper(codcompy) = p_codcompy
                and dteyear = p_year
                and ((v_count>0 and dtedate>= trunc(sysdate)) or v_count = 0 );
      end;
      v_month_diff        := (p_year - p_year_clone) * 12;
      for i in c_tholiday loop
        begin
          v_dtedate           := add_months(i.dtedate, v_month_diff);

          insert into tholiday
                      (codcompy, dteyear, dtedate, typwork,
                       desholdye, desholdyt, desholdy3, desholdy4, desholdy5,
                       codcreate, coduser)
               values (p_codcompy, to_char(v_dtedate, 'YYYY'), v_dtedate, i.typwork,
                       i.desholdye, i.desholdyt, i.desholdy3, i.desholdy4, i.desholdy5,
                       global_v_coduser, global_v_coduser);
        end;
      end loop;
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end set_clone_codcompy;

END HRAL19E;

/
