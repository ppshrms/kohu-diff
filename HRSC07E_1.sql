--------------------------------------------------------
--  DDL for Package Body HRSC07E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC07E" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin

    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');

    p_dteeffec          := to_date(trim(hcm_util.get_string_t(json_obj, 'p_dteeffec')),'dd/mm/yyyy');
    p_dteeffecOld       := p_dteeffec;
    json_params         := hcm_util.get_json_t(json_obj, 'params');

  end initial_value;
  --
  procedure check_index is
    v_code    varchar2(100);
  begin
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    v_dteeffec  date;
    v_total     number;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      begin
        select qtypassmax,qtypassmin,qtynumdigit,qtyspecail,qtyalpbup,qtyalpblow,
                agepass,qtymistake,qtynopass,qtyotp,timeotp,alepass,flgchang,timeunlock
          into p_qtypassmax,p_qtypassmin,p_qtynumdigit,p_qtyspecail,p_qtyalpbup,p_qtyalpblow,
                p_agepass,p_qtymistake,p_qtynopass,p_qtyotp,p_timeotp,p_alepass,p_flgchang,p_timeunlock
          from tsetpass
          where dteeffec = p_dteeffec;
      exception when no_data_found then null;
      end;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteeffec', to_char(p_dteeffec, 'dd/mm/yyyy'));
      obj_data.put('qtypassmax', p_qtypassmax);
      obj_data.put('qtypassmin', p_qtypassmin);
      obj_data.put('qtynumdigit', p_qtynumdigit);
      obj_data.put('qtyspecail', p_qtyspecail);
      obj_data.put('qtyalpbup', p_qtyalpbup);
      obj_data.put('qtyalpblow', p_qtyalpblow);
      obj_data.put('agepass', p_agepass);
      obj_data.put('qtymistake', p_qtymistake);
      obj_data.put('qtynopass', p_qtynopass);
      obj_data.put('qtyotp', p_qtyotp);
      obj_data.put('timeotp', p_timeotp);
      obj_data.put('alepass', p_alepass);
      obj_data.put('flgchang', p_flgchang);
      obj_data.put('timeunlock', p_timeunlock);

      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure initial_save is
  begin
    p_dteeffec        := to_date(trim(hcm_util.get_string_t(json_params, 'dteeffec')), 'dd/mm/yyyy');
    p_qtypassmax      := hcm_util.get_string_t(json_params, 'qtypassmax');
    p_qtypassmin      := hcm_util.get_string_t(json_params, 'qtypassmin');
    p_qtynumdigit     := hcm_util.get_string_t(json_params, 'qtynumdigit');
    p_qtyspecail      := hcm_util.get_string_t(json_params, 'qtyspecail');
    p_qtyalpbup       := hcm_util.get_string_t(json_params, 'qtyalpbup');
    p_qtyalpblow      := hcm_util.get_string_t(json_params, 'qtyalpblow');
    p_agepass         := hcm_util.get_string_t(json_params, 'agepass');
    p_qtymistake      := hcm_util.get_string_t(json_params, 'qtymistake');
    p_qtynopass       := hcm_util.get_string_t(json_params, 'qtynopass');
    p_qtyotp          := hcm_util.get_string_t(json_params, 'qtyotp');
    p_timeotp         := hcm_util.get_string_t(json_params, 'timeotp');
    p_alepass         := hcm_util.get_string_t(json_params, 'alepass');
    p_flgchang        := hcm_util.get_string_t(json_params, 'flgchang');
    p_timeunlock      := hcm_util.get_string_t(json_params, 'timeunlock');
  end initial_save;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    initial_save;

    begin
      insert into tsetpass(dteeffec, qtypassmax, qtypassmin, qtynumdigit, qtyspecail,
                           qtyalpbup, qtyalpblow, agepass, qtymistake, qtynopass,
                           qtyotp, timeotp, alepass, flgchang, timeunlock, codcreate, coduser)
                   values (p_dteeffec, p_qtypassmax, p_qtypassmin, p_qtynumdigit, p_qtyspecail,
                           p_qtyalpbup, p_qtyalpblow, p_agepass, p_qtymistake, p_qtynopass,
                           p_qtyotp, p_timeotp, p_alepass, p_flgchang, p_timeunlock, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update tsetpass
         set qtypassmax  = p_qtypassmax,
             qtypassmin  = p_qtypassmin,
             qtynumdigit = p_qtynumdigit,
             qtyspecail  = p_qtyspecail,
             qtyalpbup   = p_qtyalpbup,
             qtyalpblow  = p_qtyalpblow,
             agepass     = p_agepass,
             qtymistake  = p_qtymistake,
             qtynopass   = p_qtynopass,
             qtyotp      = p_qtyotp,
             timeotp     = p_timeotp,
             alepass     = p_alepass,
             flgchang    = p_flgchang,
             timeunlock  = p_timeunlock,
             coduser     = global_v_coduser
       where dteeffec    = p_dteeffec;
    end;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('isEdit', isEdit);
      obj_data.put('isAdd', isAdd);
      if isAdd or isEdit then
        obj_data.put('msqerror', '');  
        obj_data.put('dteeffec', to_char(p_dteeffecOld, 'DD/MM/YYYY'));
      else
        obj_data.put('msqerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));  
        obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));
      end if;
      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
      begin
        select count(*) into v_count
          from tsetpass
         where dteeffec  = p_dteeffec;
      exception when no_data_found then
        v_count := 0;
      end;  

      if v_count = 0 then
        select max(dteeffec) into v_maxdteeffec
          from tsetpass
         where dteeffec <= p_dteeffec;
        if v_maxdteeffec is null then
            select min(dteeffec) into v_maxdteeffec
              from tsetpass
             where dteeffec > p_dteeffec; 
            if v_maxdteeffec is null then
              isEdit                := true;
              isAdd                 := true;
            else 
                isEdit              := false;
                isAdd               := false;
                p_dteeffec          := v_maxdteeffec;
            end if;
        else
            if p_dteeffec < trunc(sysdate) then
              isEdit := false;
            else
              isEdit := false;
              isAdd  := true;
            end if;
            p_dteeffec := v_maxdteeffec;            
        end if;
      else
        if p_dteeffec < trunc(sysdate) then
          isEdit := false;
        else
          isEdit := true;
        end if;
      end if;
  end gen_flg_status;

end HRSC07E;

/
