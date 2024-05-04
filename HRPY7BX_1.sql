--------------------------------------------------------
--  DDL for Package Body HRPY7BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY7BX" as
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcompy      := hcm_util.get_string_t(json_obj, 'codcompy');
    p_dtemthst      := hcm_util.get_string_t(json_obj, 'dtemthst');
    p_dteyrest      := hcm_util.get_string_t(json_obj, 'dteyrest');
    p_dtemthen      := hcm_util.get_string_t(json_obj, 'dtemthen');
    p_dteyreen      := hcm_util.get_string_t(json_obj, 'dteyreen');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  procedure check_index is
    v_codcompy  tcompny.codcompy%type;
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      begin
        select codcompy into v_codcompy
        from tcompny
        where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
      end;
    end if;
    if p_dtemthst is null  or p_dteyrest is null or p_dtemthen is null or p_dteyreen is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
--    secur7
    if not secur_main.secur7(p_codcompy, global_v_coduser) then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;
    
    --<<User37 #5230 Final Test Phase 1 V11 02/03/2021 
    if to_number(p_dteyrest||lpad(p_dtemthst,2,'00')) > to_number(p_dteyreen||lpad(p_dtemthen,2,'00')) then
        param_msg_error := get_error_msg_php('HR2029',global_v_lang);
    end if;
    -->>User37 #5230 Final Test Phase 1 V11 02/03/2021 
  end check_index;

  procedure gen_index(json_str_output out clob) is
    obj_data              json_object_t;
    obj_row               json_object_t;

    flgpass1     	      boolean := false;
    flgpass2     	      boolean := false;
    v_flgsecu1            varchar2(1 char) := 'N';
    v_flgsecu2            varchar2(1 char) := 'N';
    v_data                number := 0;

    v_rcnt                number := 0;
    v_stdate              date;
    v_endate              date;
    v_comp                tcenter.codcomp%type;

    cursor c1 is
      select *
        from tdedlnslf
       where codcompy = p_codcompy
       and to_date('01'|| lpad(dtemthpay,2,'0') ||dteyrepay,'dd/mm/yyyy')
       between v_stdate and v_endate;
  begin
    v_stdate := to_date('01'|| lpad(p_dtemthst,2,'0') ||p_dteyrest,'dd/mm/yyyy');
    v_endate := last_day(to_date('01'|| lpad(p_dtemthen,2,'0') ||p_dteyreen,'dd/mm/yyyy'));
    obj_row  := json_object_t();
    v_rcnt   := 0;
    v_data   :=0;
    for r1 in c1 loop
         begin
           select   codcomp
             into   v_comp
             from   temploy1
            where   codempid = r1.codconfirm;
           exception when no_data_found then
            v_comp := null;
         end;
                  v_rcnt               := v_rcnt + 1;
                  v_data               := v_data + 1;
                  obj_data  := json_object_t();
                  obj_data.put('coderror', '200');
                  obj_data.put('codcompy', p_codcompy);
                  obj_data.put('dtemthst', get_nammthful(r1.dtemthpay,global_v_lang));
                  obj_data.put('dteyrest', r1.dteyrepay);
                  obj_data.put('dtemthen', get_nammthful(p_dtemthen,global_v_lang));
                  obj_data.put('dteyreen', p_dteyreen);
                  obj_data.put('dteconfirm', to_char(r1.dteconfirm ,'dd/mm/yyyy hh24:mm') );
                  obj_data.put('codconfirm', get_temploy_name(r1.codconfirm, global_v_lang));
                  obj_data.put('amtdedstu', stddec(r1.amtdedstu, p_codcompy, v_chken));
                  obj_data.put('amntemployee', v_data);
                  obj_data.put('chequeno', r1.chequeno );
                  obj_data.put('dtededstu', to_char(r1.dtededstu,'dd/mm/yyyy') );
                  obj_data.put('filename1', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPY5BU')||'/'||r1.filename1 );
                  obj_data.put('filename2', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPY5BU')||'/'||r1.filename2 );
                  if r1.typdedstu = 1 then
                    obj_data.put('typdedstu', get_label_name('HRPY5BU', global_v_lang, 110) );
                  else
                    obj_data.put('typdedstu', get_label_name('HRPY5BU', global_v_lang, 120) );
                  end if;
                  obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

     --<<User37 #5230 Final Test Phase 1 V11 02/03/2021 
     if v_data = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TDEDLNSLF');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
     else
        json_str_output := obj_row.to_clob;
     end if;
     /*if (v_flgsecu1 = 'N' or   v_flgsecu2 = 'N') then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      else
          if v_data = 0 then
              param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TDEDLNSLF');
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          else
              json_str_output := obj_row.to_clob;
          end if;
      end if;*/
      -->>User37 #5230 Final Test Phase 1 V11 02/03/2021 

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;


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
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

end hrpy7bx;

/
