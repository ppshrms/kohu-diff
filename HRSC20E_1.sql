--------------------------------------------------------
--  DDL for Package Body HRSC20E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC20E" is
-- last update: 07/11/2020 16:55
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
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_typeuser          := upper(hcm_util.get_string_t(json_obj, 'p_typeuser'));    
    -- DetailIno
    p_emp_coduser       := upper(hcm_util.get_string_t(json_obj, 'p_emp_coduser'));
   -- p_emp_detail        := upper(hcm_util.get_string_t(json_obj, 'codempid'));       
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');
    -- hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
---

  procedure check_index is 
     v_temp  varchar2(1 char);
    begin
        -- รหัสบริษัท ต้องมีข้อมูลในตาราง TCOMPNY (HR2010)
        if p_codcomp is not null then
            begin
                select 'X' 
                into v_temp 
                from tcenter 
                where codcomp like p_codcomp||'%'
                and rownum <=1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;
        end if;
        -- รหัสบริษัทให้ Check Security โดยใช้ secur_main.secur7
        if p_codcomp is not null then
            if secur_main.secur7(p_codcomp,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
        ----------------------------------
         -- รหัสประเภทผู้ใช้งาน ต้องมีข้อมูลในตาราง TUSRPROF (HR2010)
        if p_typeuser is not null then
            begin
                select 'X' 
                into  v_temp 
                from  tusrprof 
                where typeuser =  p_typeuser
                and rownum <=1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TUSRPROF');
                return;
            end;
        end if;    
    end check_index;
---

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
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flg_data      number := 0;
    v_flgcreate     varchar2(1 char); 

    cursor c_temploy1 is
        select b.typeuser,b.coduser, a.codempid
          from temploy1 a,tusrprof b
         where a.codempid = b.codempid(+)
           and a.codcomp like  p_codcomp || '%'
           and b.typeuser =  p_typeuser
           and a.staemp in ('1','3')
      order by codempid;

  begin  
        obj_row            := json_object_t();
        for r1 in c_temploy1 loop
            v_flg_data         := v_flg_data+1;
            v_rcnt             := v_rcnt + 1;
            obj_data           := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang)); 
            obj_data.put('emp_coduser', r1.coduser);        
            obj_row.put(to_char(v_rcnt - 1), obj_data);
        end loop;

        if v_flg_data > 0  then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TUSRPROF');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

 procedure get_AssignWidget (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_AssignWidget (json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_AssignWidget;

  procedure gen_AssignWidget (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flg_data      number := 0;
    v_flgcreate     varchar2(1 char);
    v_wgname        twidget.wgdesct%type;
    v_FlgDe         boolean := false;

    cursor c_twidgetcom is
        select  a.codwg, b.flgadjust, b.positionmetric, a.flgdefault
          from  twidgetcom a, twidget b
         where  a.codwg     = b.codwg
           and  a.codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
           and  nvl(a.flgdefault,'N') = 'Y'
      order by a.codwg;

  begin  
        obj_row    := json_object_t();
        for r1 in c_twidgetcom loop
                v_rcnt          := v_rcnt + 1;
                v_flg_data      := v_flg_data+1;
                obj_data        := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('codwg', r1.codwg);
                obj_data.put('wgname',get_twidget_name(r1.codwg,global_v_lang));   
                obj_data.put('flgdefault', r1.flgdefault);            
                if r1.flgdefault = 'Y' then 
                    v_flgde := true;
                else
                    v_flgde := true;
                end if;                        
               obj_data.put('flgdefault_', v_flgde);            
               obj_data.put('flgadjust', r1.flgadjust);
               obj_data.put('positionmetric', r1.positionmetric);   
               obj_row.put(to_char(v_rcnt - 1), obj_data);
        end loop;

        if v_flg_data > 0  then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TWIDGETCOM');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_AssignWidget;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    param_json_intput         json_object_t;
    param_assign_widget       json_object_t;
    param_assign_widget_row   json_object_t;
    param_assign_row          json_object_t;

    param_employee            json_object_t;
    param_employee_row        json_object_t;

    v_codwg                   twidgetusr.codwg%type;
    v_emp_coduser             twidgetusr.coduser%type;
    v_positionmetric          twidget.positionmetric%type;
    v_flgused                 twidgetusr.flgused%type;
  -----
  begin
    initial_value (json_str_input);
    param_json_intput         := json_object_t(json_str_input);

    param_employee            := hcm_util.get_json_t(param_json_intput,'p_employee');

    param_assign_widget       := hcm_util.get_json_t(param_json_intput,'p_assignWidget');
    param_assign_widget_row   := hcm_util.get_json_t(param_assign_widget,'rows');

    for i in 0..param_employee.get_size - 1 loop
      param_employee_row      := hcm_util.get_json_t(param_employee, to_char(i));
      v_emp_coduser           := hcm_util.get_string_t(param_employee_row,'emp_coduser');
      delete  twidgetusr where coduser = v_emp_coduser;

      for j in 0..param_assign_widget_row.get_size - 1 loop
        param_assign_row    := hcm_util.get_json_t(param_assign_widget_row, to_char(j));
        v_codwg             := hcm_util.get_string_t(param_assign_row,'codwg');
        v_positionmetric    := hcm_util.get_string_t(param_assign_row,'positionmetric');
        v_flgused           := hcm_util.get_string_t(param_assign_row,'flgdefault');              
         insert into twidgetusr(coduser,codwg,flgused,layoutcol,layoutrow,layoutposition,codcreate) 
              values (v_emp_coduser,v_codwg,v_flgused,0,0,v_positionmetric,global_v_coduser);
      end loop;
    end loop;

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
  --
  procedure reset_widget (json_str_input in clob, json_str_output out clob) is
    param_json_intput         json_object_t;    
    param_employee            json_object_t;
    param_employee_row        json_object_t;
    v_emp_coduser             twidgetusr.coduser%type;
  -----
  begin
    initial_value (json_str_input);
    param_json_intput         := json_object_t(json_str_input);
    param_employee            := hcm_util.get_json_t(param_json_intput,'param_json');
    for i in 0..param_employee.get_size - 1 loop
      param_employee_row        := hcm_util.get_json_t(param_employee, to_char(i));
      v_emp_coduser             := hcm_util.get_string_t(param_employee_row,'emp_coduser');    
       delete  twidgetusr where coduser = v_emp_coduser;
    end loop;

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
  end reset_widget;
---

  procedure get_twidgetusr (json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flg_data      number := 0;
    v_flgcreate     varchar2(1 char);
    v_wgname        twidget.wgdesct%type;
    v_FlgDe         boolean := false;
    v_emp_coduser   twidgetusr.coduser%type;
    param_json_intput         json_object_t;    
    param_employee            json_object_t;
    param_employee_row        json_object_t;
    v_codwg         twidgetcom.codwg%type;

    cursor c_twidgetcom is
        select codwg,flgdefault
          from twidgetcom 
         where codcompy    =  hcm_util.get_codcomp_level(p_codcomp,1) 
           and  nvl(flgdefault,'N') = 'Y';

    cursor c_twidgetusr is
        select  pdk.check_codempid(coduser) codempid, coduser,codwg ,   flgused flgdefault
          from  twidgetusr 
         where  coduser = p_emp_coduser 
            and codwg   = v_codwg
          order by codwg;

  begin  
        initial_value (json_str_input);
        obj_row    := json_object_t();
         for r1 in c_twidgetcom loop
            v_rcnt          := v_rcnt + 1;
            v_flg_data      := v_flg_data+1;
            obj_data        := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('codwg', r1.codwg);
            obj_data.put('wgname',get_twidget_name(r1.codwg,global_v_lang));   
            obj_data.put('flgdefault', '');            
            ---
            v_codwg := r1.codwg;         
            for r2 in c_twidgetusr loop
                obj_data.put('coderror', '200');
                obj_data.put('flgdefault', r2.flgdefault);
                ---
            end loop;
           obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

        if v_flg_data > 0  then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TWIDGETUSR');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_twidgetusr;
---
end HRSC20E;

/
