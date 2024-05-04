--------------------------------------------------------
--  DDL for Package Body HRCO31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO31E" as
  -- Update 15/10/2019 11:20
  procedure initial_value(json_str_input in clob) is
      json_obj json_object_t;
  begin
      json_obj          := json_object_t(json_str_input);
      global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
      global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
      global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
  end initial_value;

  procedure gen_index(json_str_output out clob) as
      obj_result  json_object_t;
      obj_rows    json_object_t;
      obj_data    json_object_t;
      v_row       number := 0;
      v_typeauth  tusrprof.typeauth%type;
      
      cursor c_tlanguage is
          select * 
            from tlanguage 
           order by codlang;
          
      cursor c_tsetup is
          select * 
            from tsetup 
           order by codvalue;
  begin
      obj_result  := json_object_t();
      obj_rows    := json_object_t();
      for r1 in c_tlanguage loop
          v_row   := v_row+1;
          obj_data    := json_object_t();
          obj_data.put('codlang',nvl(r1.codlang,''));
          obj_data.put('namlang',nvl(r1.namlang,''));
          obj_data.put('namabb',nvl(r1.namabb,''));
          obj_data.put('namimage',nvl(r1.namimage,''));
          obj_data.put('codlang2',nvl(r1.codlang2,''));
          obj_rows.put(to_char(v_row-1),obj_data);
      end loop;
      obj_result.put('tlanguage',obj_rows);
      v_row   := 0;
      obj_rows    := json_object_t();
      for r2 in c_tsetup loop
          v_row   := v_row+1;
          obj_data    := json_object_t();
          obj_data.put('codvalue',nvl(r2.codvalue,''));
          obj_data.put('remarks',nvl(r2.remarks,''));
          obj_data.put('value',nvl(r2.value,''));
          obj_rows.put(to_char(v_row-1),obj_data);
      end loop;
      obj_result.put('tsetup',obj_rows);
      begin
          select typeauth
            into v_typeauth
            from tusrprof
           where coduser = global_v_coduser;
      end;
      obj_result.put('typeauth',v_typeauth);
      obj_data    := json_object_t();
      obj_data.put('0',obj_result);
      json_str_output := obj_data.to_clob;
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      if param_msg_error is null then
          gen_index(json_str_output);
      else
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure validate_save(v_tlanguage json_object_t,v_tsetup json_object_t) as
      v_codlang2  tlanguage.codlang2%type;
      v_codlang   tlanguage.codlang%type;
      v_namlang   tlanguage.namlang%type;
      v_namabb    tlanguage.namabb%type;
      v_namimage  tlanguage.namimage%type;
      v_isdup     varchar2(1 char);
      v_codvalue  tsetup.codvalue%type;
      v_remarks   tsetup.remarks%type;
      v_value     tsetup.value%type;
      v_flgedit   varchar2(10 char);
      json_obj    json_object_t;
      v_temp      varchar2(1 char);
      v_count     number := 0;
  begin
      for t1 in 0..v_tlanguage.get_size-1 loop
          json_obj    := hcm_util.get_json_t(v_tlanguage,to_char(t1));
          v_codlang   := hcm_util.get_string_t(json_obj,'codlang');
          v_codlang2  := upper(hcm_util.get_string_t(json_obj,'codlang2'));
          v_namlang   := hcm_util.get_string_t(json_obj,'namlang');
          v_namabb    := upper(hcm_util.get_string_t(json_obj,'namabb'));
          v_namimage  := hcm_util.get_string_t(json_obj,'namimage');
          v_isdup     := hcm_util.get_string_t(json_obj,'isdup');
          
          -- ข้อมูลที่ต้องระบุ รูปภาษา,ชื่อภาษา และชื่อย่อภาษา
          if v_codlang2 is not null then
              if (v_namimage is null) or (v_namabb is null) then
                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                  return;
              end if;
          end if;
--          if t1 = 1 then
--              if v_codlang2 is null then
--                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--                  return;
--              end if;
--          end if;
          -- เช็คข้อมูล NAMLANG,NAMABB จาก TLANGUAGE ว่ามีการกำหนดแล้วหรือยังหากเลือก ภาษา หรือ ชื่อย่อ ซ้ำให้Alert HR2005
          if v_isdup = 'Y' then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TLANGUAGE');
              return;
          end if;
      end loop;

      for t2 in 0..v_tsetup.get_size-1 loop
          json_obj    := hcm_util.get_json_t(v_tsetup,to_char(t2));
          v_codvalue  := upper(hcm_util.get_string_t(json_obj,'codvalue'));
          v_remarks   := hcm_util.get_string_t(json_obj,'remarks');
          v_value     := hcm_util.get_string_t(json_obj,'value');
          v_flgedit   := hcm_util.get_string_t(json_obj,'flg');

          -- ข้อมูลที่ต้องระบุ รหัสข้อมูล,รายละเอียด และ ค่าข้อมูล
          if (v_codvalue is null) or (v_remarks is null) then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang);
              return;
          end if;

          -- ตรวจสอบการซ้ำกันของข้อมูล รหัสข้อมูล ที่ระบุ ต้องไม่ซ้ำกับข้อมูลที่มีในตาราง   TSETUP
          if v_flgedit = 'add' then
              begin
                  select count(*) into v_count
                  from tsetup
                  where codvalue = v_codvalue;
              end;
              if v_count > 0 then
                  param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tsetup');
                  return;
              end if;
          end if;
      end loop;
  end validate_save;

  procedure save_data(v_tlanguage json_object_t, v_tsetup json_object_t, json_str_output out clob) as
      v_codlang2  tlanguage.codlang2%type;
      v_codlang   tlanguage.codlang%type;
      v_namlang   tlanguage.namlang%type;
      v_namabb    tlanguage.namabb%type;
      v_namimage  tlanguage.namimage%type;
      v_isdup     varchar2(1 char);
      v_codvalue  tsetup.codvalue%type;
      v_remarks   tsetup.remarks%type;
      v_value     tsetup.value%type;
      v_flgedit   varchar2(10 char);
      v_typeauth  tusrprof.typeauth%type;
      json_obj    json_object_t;
      v_temp      varchar2(1 char);
      v_count     number := 0;
      v_codvalue_check tsetup.codvalue%type;
  begin
      for t1 in 0..v_tlanguage.get_size-1 loop
          json_obj    := hcm_util.get_json_t(v_tlanguage,to_char(t1));
          v_codlang   := hcm_util.get_string_t(json_obj,'codlang');
          v_codlang2  := upper(hcm_util.get_string_t(json_obj,'codlang2'));
--            v_namlang   := hcm_util.get_string_t(json_obj,'namlang');
          v_namlang   := get_tcodec_name('TCODLANG',v_codlang2,101);
          v_namabb    := upper(hcm_util.get_string_t(json_obj,'namabb'));
          v_namimage  := hcm_util.get_string_t(json_obj,'namimage');
          v_isdup     := hcm_util.get_string_t(json_obj,'isdup');
          v_flgedit   := hcm_util.get_string_t(json_obj,'flg');
          
          if v_codlang2 is null then
              v_namlang := null;
              v_namabb  := null;
              v_namimage := null;
          end if;
          v_temp := null;
          if v_flgedit = 'edit' then
              begin
                  select 'X' into v_temp
                  from tlanguage
                  where codlang = v_codlang;

                  if v_codlang = '101' then
                      update tlanguage
                      set namabb  = v_namabb,
                          namimage = v_namimage,
                          dtecreate = sysdate,
                          codcreate = global_v_coduser,
                          dteupd  = sysdate,
                          coduser = global_v_coduser
                      where codlang = v_codlang;
                  else
                      update tlanguage
                      set namlang = v_namlang,
                          namabb  = v_namabb,
                          namimage = v_namimage,
                          codlang2 = v_codlang2,
                          dtecreate = sysdate,
                          codcreate = global_v_coduser,
                          dteupd  = sysdate,
                          coduser = global_v_coduser
                      where codlang = v_codlang;
                  end if;
              exception when no_data_found then
                  insert into tlanguage(codlang,namlang,namabb,namimage,codlang2,dteupd,coduser,dtecreate,codcreate)
                  values(v_codlang,v_namlang,v_namabb,v_namimage,v_codlang2,sysdate,global_v_coduser,sysdate,global_v_coduser);
              end;
          end if;
      end loop;
      begin
          select typeauth
            into v_typeauth
            from tusrprof
           where coduser = global_v_coduser;
      exception when no_data_found then
          v_typeauth := null;
      end;
      if v_typeauth = '1' then
          for t2 in 0..v_tsetup.get_size-1 loop
              json_obj    := hcm_util.get_json_t(v_tsetup,to_char(t2));
              v_codvalue  := upper(hcm_util.get_string_t(json_obj,'codvalue'));
              v_remarks   := hcm_util.get_string_t(json_obj,'remarks');
              v_value     := hcm_util.get_string_t(json_obj,'value');
              v_flgedit   := hcm_util.get_string_t(json_obj,'flg');
              v_temp := null;

              if v_flgedit = 'add' then
                  insert into tsetup(codvalue,remarks,value,dteupd,coduser,dtecreate,codcreate)
                  values(v_codvalue,v_remarks,v_value,sysdate,global_v_coduser,sysdate,global_v_coduser);
              elsif v_flgedit = 'edit' then
                begin
                    select codvalue into v_codvalue_check
                    from tsetup
                    where codvalue = v_codvalue;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR1500',global_v_lang,'tsetup');
                end;
                update tsetup
                   set remarks = v_remarks,
                       value = v_value,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codvalue = v_codvalue;
              elsif v_flgedit = 'delete' then
                  delete from tsetup where codvalue = v_codvalue;
              end if;
          end loop;
      end if;

      if param_msg_error is null then
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
      else
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          rollback;
      end if;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
      rollback;
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
      json_obj    json_object_t;
      v_tlanguage json_object_t;
      v_tsetup    json_object_t;
  begin
      initial_value(json_str_input);
      json_obj        := json_object_t(json_str_input);
--      param_json      := hcm_util.get_json_t(json_obj,'param_json');
      v_tlanguage     := hcm_util.get_json_t(json_obj,'tlanguage');
      v_tsetup        := hcm_util.get_json_t(json_obj,'tsetup');
      validate_save(v_tlanguage,v_tsetup);
      if param_msg_error is null then
          save_data(v_tlanguage,v_tsetup,json_str_output);
      else
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

end HRCO31E;

/
