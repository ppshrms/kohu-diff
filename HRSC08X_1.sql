--------------------------------------------------------
--  DDL for Package Body HRSC08X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC08X" is
-- last update: 25/10/2019 09:00
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');
    -- index
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codproc           := upper(hcm_util.get_string_t(json_obj, 'p_codproc'));
    -- index params
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
----------------------------------------------------------------------------------------
  procedure check_index is
    v_codapp          tappprof.codapp%type;
  begin
    if p_codapp is not null then
      begin
        select codapp
          into v_codapp
          from tappprof
         where codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tappprof');
        return;
      end;
    end if;
  end;
----------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------
  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_count             number := 0;
    v_current_use       number := 0;
    v_current_use_sc_co number := 0;
    v_codproc           tprocess.codproc%type;
    v_module_name       tprocess.desproce%type;
    v_module            varchar2(100 char);
    v_license           number;

    p_type_license  varchar2(10 char);
    p_license       number;
    p_license_Emp   number;

    cursor c_stdmodule is
      select a.list_value as codproc,a.desc_label as module
        from tlistval a, tprocess b
       where a.list_value = b.codproc
         and a.codapp  = 'STDMODULE'
         and a.codlang = '102'
         and a.list_value not in ('SC','CO')
      order by a.list_value;

  begin
    -- count current use in module sc and co
    begin
      select count('X') 
        into v_current_use_sc_co
        from tlogin
       where lcodsub in ('SC','CO') 
         and lcodsub is not null 
         and luserid not in('PPSIMP','PPSADM');
    exception when others then
      v_current_use_sc_co := 0;
    end;

    -- loop standard module without sc and co
    obj_row := json_object_t();
    for r_stdmodule in c_stdmodule loop
      v_codproc := r_stdmodule.codproc;
      v_module  := r_stdmodule.module;

      -- count current use
      begin
        select count('X') 
          into v_current_use
          from tlogin
         where lcodsub = v_module
           and lcodsub is not null 
           and luserid not in('PPSIMP','PPSADM');
      exception when others then
        v_current_use := 0;
      end;
      if v_codproc = '3.PM' then
        v_current_use := v_current_use + v_current_use_sc_co;
      end if;

      -- get module name
      begin
        select decode(global_v_lang,'101', desproce,
                                    '102', desproct,
                                    '103', desproc3,
                                    '104', desproc4,
                                    '105', desproc5,
                                    desproce) as module_name
          into v_module_name
          from tprocess
         where codproc = v_codproc;
      exception when no_data_found then
        v_module_name := null;
      end;

      -- get license
      v_license := get_license(hcm_util.get_temploy_field(global_v_codempid, 'codcomp'),v_module);
--insert into a(a) values(v_module||' + '||v_license); commit;
      if v_codproc in ('9.ES', 'A.MS') then
        std_sc.get_license_Info(p_type_license, p_license, p_license_Emp);
        if nvl(p_type_license,'1') = '2' then
          v_license     := p_license;
          v_module_name := v_module_name ||' ('||get_tlistval_name('TYPLICENSE',p_type_license,global_v_lang)||')';
        end if; 
      end if;
      if v_license > 0 then
        v_rcnt   := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codapp', p_codapp);
        obj_data.put('module_name', v_module_name);
        obj_data.put('license', v_license);
        obj_data.put('current_use', v_current_use);
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_index;
end HRSC08X;

/
