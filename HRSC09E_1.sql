--------------------------------------------------------
--  DDL for Package Body HRSC09E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC09E" is
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
    p_codcompy          := upper(hcm_util.get_string_t(json_obj, 'p_codcompy'));
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');
    -- hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
---

  procedure check_index is
     v_temp  varchar2(1 char);
    begin
        -- รหัสบริษัท ต้องมีข้อมูลในตาราง TCOMPNY (HR2010)
        if p_codcompy is not null then
            begin
                select 'X' 
                into v_temp 
                from tcompny 
                where codcompy = p_codcompy;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
                return;
            end;
        end if;

        -- รหัสบริษัทให้ Check Security โดยใช้ secur_main.secur7
        if p_codcompy is not null then
            if secur_main.secur7(p_codcompy,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
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
    v_wgname        twidget.wgdesct%type;
    v_FlgDe         boolean := false;
    v_codwg         twidget.codwg%type;

    cursor c_twidget is
      select codwg, flgadjust, flgdefault
        from twidget
       where nvl(flgallow,'N')    = 'Y'
      order by codwg;


    cursor c_twidgetcom is
      select flgdefault
        from twidgetcom 
       where codcompy    = p_codcompy
         and codwg       = v_codwg;

  begin  
    obj_row            := json_object_t();
    for r1 in c_twidget loop
            v_rcnt          := v_rcnt + 1;
            v_flg_data      := v_flg_data+1;
            obj_data        := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('codwg', r1.codwg);
            obj_data.put('wgname',get_twidget_name(r1.codwg,global_v_lang));   
            obj_data.put('flgdefault', r1.flgdefault);            
            if r1.flgdefault = 'Y' then 
                v_FlgDe := true;
            else
                v_FlgDe := true;
            end if;                        
            obj_data.put('flgdefault_', v_FlgDe);
            ---
           v_codwg := r1.codwg;         
            for r2 in c_twidgetcom loop
                obj_data.put('coderror', '200');
                ----
                if r2.flgdefault = 'Y' then 
                    v_FlgDe := true;
                else
                    v_FlgDe := true;
                end if;
                obj_data.put('flgdefault', r2.flgdefault);
                obj_data.put('flgdefault_', v_FlgDe);
                ---
            end loop;
           obj_data.put('flgadjust', r1.flgadjust);
           obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

   -- json_str_output := obj_row.to_clob;
        if v_flg_data > 0  then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TWIDGET');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_obj_tmp    json_object_t;
    json_obj        json_object_t;
    json_obj_row    json_object_t;
    json_obj2       json_object_t;
    v_rowcount      number:= 0;
    v_codwg         twidgetcom.codwg%type;
    v_codcompy      twidgetcom.codcompy%type;
    v_flgdefault    twidgetcom.flgdefault%type;
  -----
  begin
    initial_value (json_str_input);
--     json_obj := json_object_t(json_str_input).get_object('param_json');

     json_obj_tmp   := json_object_t(json_str_input);
     json_obj       := hcm_util.get_json_t(json_obj_tmp, 'param_json');
     json_obj_row   := hcm_util.get_json_t(json_obj, 'rows');
     v_codcompy     := hcm_util.get_string_t(json_obj_tmp, 'p_codcompy');

     delete  twidgetcom where codcompy = v_codcompy;

     v_rowcount := json_obj_row.get_size;
     for i in 0..json_obj_row.get_size-1 loop
      json_obj2     := hcm_util.get_json_t(json_obj_row,to_char(i));
      v_codwg       := hcm_util.get_string_t(json_obj2,'codwg');
      v_flgdefault  := hcm_util.get_string_t(json_obj2, 'flgdefault');

     -- insert
         begin
            insert into twidgetcom(codcompy,codwg,flgdefault,codcreate,coduser)
                 values (v_codcompy,v_codwg,v_flgdefault,global_v_coduser,global_v_coduser);
          end; 
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
end HRSC09E;

/
