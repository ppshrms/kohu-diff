--------------------------------------------------------
--  DDL for Package Body HRAP13E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP13E" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index

    p_codcompy              := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_dteyreap              := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_codcompyQuery         := hcm_util.get_string_t(json_obj,'p_codcompyQuery');
    p_dteyreapQuery         := hcm_util.get_string_t(json_obj,'p_dteyreapQuery');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_dteyreap      tgradekpi.dteyreap%type;
    v_flgDisabled   boolean;
    v_flgAdd        boolean := false;

    v_rcnt          number := 0;
    cursor c1 is
      select *
        from tgradekpi
       where codcompy = p_codcompy
         and dteyreap = v_dteyreap
       order by score desc ;


  begin
    if p_codcompyQuery is not null and p_dteyreapQuery is not null then
      p_isCopy          :=  'Y';
      v_flgDisabled     := false;
      v_dteyreap        := p_dteyreap;
      v_flgAdd          := true;
    else
        begin
            select max(dteyreap)
              into v_dteyreap
              from tgradekpi
             where codcompy = p_codcompy;
        exception when others then
            v_dteyreap := null;
        end;

        if v_dteyreap is null or p_dteyreap >= v_dteyreap then
            v_flgDisabled   := false;
            if p_dteyreap > v_dteyreap or v_dteyreap is null then
                v_flgAdd        := true;
            else
                v_flgAdd        := false;
            end if;
        else
            v_flgDisabled   := true;
        end if;

--        begin
--            select max(dteyreap)
--              into v_dteyreap
--              from tgradekpi
--             where codcompy = p_codcompy
--               and dteyreap <= p_dteyreap;
--        exception when others then
--            v_dteyreap := null;
--        end;
--        
--        if p_dteyreap < to_char(sysdate,'yyyy') then
--            if v_dteyreap is null then
--                v_flgDisabled   := false;
--                v_flgAdd        := true;
--            else
--                v_flgDisabled := true;
--            end if;
--        else
--            v_flgDisabled := false;
--            if v_dteyreap is null or v_dteyreap < p_dteyreap  then
--                v_flgAdd := true;
--            end if;
--        end if;    
    end if;

    obj_row := json_object_t();
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('grade', i.grade);
      obj_data.put('desgrade', i.desgrade);
      obj_data.put('score', i.score);
      obj_data.put('color', i.color);
      obj_data.put('color', i.color);
      obj_data.put('flgAdd', v_flgAdd);
      if not v_flgAdd then
        obj_data.put('disabled', true);
      else
        obj_data.put('disabled', false);
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('isCopy', p_isCopy);
    obj_result.put('flgDisabled', v_flgDisabled);
    if v_flgDisabled then
        obj_result.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
    end if;
    obj_result.put('table', obj_row);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcompy   tcompny.codcompy%type;
  begin

    if p_codcompy is not null then
      begin
        select codcompy into v_codcompy
          from tcompny
         where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCOMPNY');
        return;
      end;
      if not secur_main.secur7(p_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_copy_list(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    cursor c1 is
      select distinct codcompy, dteyreap 
        from tgradekpi  
--       where codcompy = b_index_codcomp
    order by dteyreap  desc , codcompy asc;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcompy', i.codcompy);
      obj_data.put('desc_codcompy', get_tcenter_name(i.codcompy,global_v_lang));
--      obj_data.put('desc_codcompy', i.codcompy ||' - '|| get_tcenter_name(i.codcompy,global_v_lang));
      obj_data.put('dteyreap', i.dteyreap);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_copy_list(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_copy_list(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save(json_str_input in clob) is
     v_codcomp      tcenter.codcomp%type;
     param_json     json_object_t;
     obj_formula    json_object_t;
     obj_table      json_object_t;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    obj_formula   := hcm_util.get_json_t(param_json,'formula');
    obj_table     := hcm_util.get_json_t(param_json,'table');
  end;
  --
  procedure post_save (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;

    v_flg	        varchar2(1000 char);
    v_flggrade	    varchar2(100 char);
    v_grade	        tgradekpi.grade%type;
    v_desgrade	    tgradekpi.desgrade%type;
    v_score         tgradekpi.score%type;
    v_color         tgradekpi.color%type;
    v_flgDup        varchar2(2 char);
    v_isCopy        varchar2(1 char);
    v_count         number;
  begin
    initial_value(json_str_input);
--    check_save(json_str_input);

    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    v_isCopy      := hcm_util.get_string_t(json_object_t(json_str_input),'isCopy');
    if v_isCopy = 'Y' then
        begin
          delete tgradekpi 
           where codcompy = p_codcompy 
             and dteyreap = p_dteyreap;
        end;    
    end if;
    for i in 0..param_json.get_size-1 loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_flg             := hcm_util.get_string_t(param_json_row,'flg');
      v_grade           := hcm_util.get_string_t(param_json_row,'grade');
      v_desgrade		:= hcm_util.get_string_t(param_json_row,'desgrade');	
      v_score		    := to_number(hcm_util.get_string_t(param_json_row,'score'));
      v_color		:= hcm_util.get_string_t(param_json_row,'color');

      if v_flg = 'add' then
        begin
          insert into tgradekpi(codcompy,dteyreap,grade,desgrade,score,
                                color,dtecreate,codcreate,dteupd,coduser)
          values (p_codcompy, p_dteyreap, v_grade,v_desgrade,v_score,
                  v_color,sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TGRADEKPI');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            rollback;
            return;
        end;
      elsif v_flg = 'delete' then
        begin
          delete tgradekpi 
           where codcompy = p_codcompy 
             and dteyreap = p_dteyreap 
             and grade = v_grade;
        end;
      elsif v_flg = 'edit' then
        begin
          update tgradekpi 
             set desgrade =	v_desgrade,
                 score = v_score,
                 color = v_color,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codcompy = p_codcompy 
             and dteyreap = p_dteyreap 
             and grade = v_grade;
        end;
      end if;
    end loop;


    select count(grade)
      into v_count
      from tgradekpi
     where codcompy = p_codcompy 
       and dteyreap = p_dteyreap;

    if v_count > 5 then
        param_msg_error := get_error_msg_php('AP0054',global_v_lang);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
end HRAP13E;

/
