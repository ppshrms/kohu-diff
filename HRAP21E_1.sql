--------------------------------------------------------
--  DDL for Package Body HRAP21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP21E" as
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

    b_index_dteyreap    := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);

    cursor c1 is
      select codcompy,dteyreap,jobgrade,amtminsa,amtmaxsa,midpoint
        from tsalstr
       where codcompy = b_index_codcompy
         and dteyreap = p_year
       order by jobgrade;
        
  begin
    obj_row := json_object_t();
    check_yreeffec;
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcompy', i.codcompy);
      obj_data.put('dteyreap', i.dteyreap);
      obj_data.put('jobgrade', i.jobgrade);
      obj_data.put('desc_jobgrade', i.jobgrade || ' - ' || get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang) );
      obj_data.put('minsal', i.amtminsa);
      obj_data.put('maxsal', i.amtmaxsa);
      obj_data.put('avgsal', i.midpoint);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('flgedit', p_flgedit);
    obj_result.put('table', obj_row);
    if p_flgedit = 'Y' then
      obj_result.put('response', '');
    else
      param_msg_error := get_error_msg_php('HR1501',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_result.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
    end if;
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcompy   varchar2(4 char);
  begin

    if b_index_codcompy is not null then
      begin
        select codcompy into v_codcompy
          from tcompny
         where codcompy = b_index_codcompy
           and rownum = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCOMPNY');
        return;
      end;
      if not secur_main.secur7(b_index_codcompy, global_v_coduser) then
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
  procedure check_yreeffec is
     v_codcompy   varchar2(4 char);
     v_chkExist   number;
     v_chkExist2  number;
     v_yreeffec   number;
  begin
    if b_index_dteyreap < to_char(trunc(sysdate),'yyyy') then
      begin
       select count(*) into v_chkExist
        from tsalstr
       where codcompy = b_index_codcompy
         and dteyreap = b_index_dteyreap;
      end;
      
      if v_chkExist > 0 then
        p_year := b_index_dteyreap;
        p_flgedit := 'N';
      else
        begin
         select dteyreap into v_yreeffec
          from tsalstr
         where codcompy = b_index_codcompy
           and dteyreap = (select max(dteyreap)
                            from tsalstr
                           where codcompy = b_index_codcompy
                           and dteyreap < b_index_dteyreap)
           and rownum = 1;
        exception when no_data_found then
          v_yreeffec := null;
        end;
        if v_yreeffec is not null then
          begin
            select count(*) into v_chkExist2
              from tsalstr
             where codcompy = b_index_codcompy
               and dteyreap = v_yreeffec;
          end;
          if v_chkExist2 > 0 then
            p_year := v_yreeffec;
            p_flgedit := 'N';
          end if;
        else
          p_year := b_index_dteyreap;
          p_flgedit := 'Y';
        end if;
      end if;
    else
      begin
       select count(*) into v_chkExist
        from tsalstr
       where codcompy = b_index_codcompy
         and dteyreap = b_index_dteyreap;
      end;
      if v_chkExist = 0 then
        begin
         select dteyreap into v_yreeffec
          from tsalstr
         where codcompy = b_index_codcompy
           and dteyreap = (select max(dteyreap)
                            from tsalstr
                           where codcompy = b_index_codcompy
                           and dteyreap < b_index_dteyreap)
           and rownum = 1;
        exception when no_data_found then
          v_yreeffec := null;
        end;
        
        p_year := v_yreeffec;
        p_flgedit := 'Y';
      else
        p_year := b_index_dteyreap;
        p_flgedit := 'Y';
      end if;
    end if;
  end;
  --
  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    param_index         json_object_t;
    
    v_flg	            varchar2(1000 char);
    v_flgupd	        varchar2(1000 char);
    v_numvcher	      varchar2(1000 char);
    v_jobgrade	      tsalstr.jobgrade%type;
    v_jobgradeOld	    tsalstr.jobgrade%type;
    v_minsal	        tsalstr.amtminsa%type;
    v_maxsal	        tsalstr.amtmaxsa%type;
    v_avgsal	        tsalstr.midpoint%type;
    v_flgDelete       boolean;
  begin
    initial_value(json_str_input);
    param_index  := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    param_json  := hcm_util.get_json_t(param_index,'rows');
    begin
      delete tsalstr 
      where codcompy = b_index_codcompy 
      and dteyreap = b_index_dteyreap;
    end;
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      v_flgDelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');
      v_jobgrade      := hcm_util.get_string_t(param_json_row,'jobgrade');
      v_jobgradeOld   := hcm_util.get_string_t(param_json_row,'jobgradeOld');
      v_minsal        := hcm_util.get_string_t(param_json_row,'minsal');
      v_maxsal        := hcm_util.get_string_t(param_json_row,'maxsal');
      v_avgsal        := hcm_util.get_string_t(param_json_row,'avgsal');
      if v_flgDelete then
        begin
          delete tsalstr where codcompy = b_index_codcompy and dteyreap = b_index_dteyreap and jobgrade = v_jobgrade;
        end;
      else
        begin
          insert into tsalstr(codcompy,dteyreap,jobgrade,amtminsa,amtmaxsa,midpoint,codcreate,coduser)
          values (b_index_codcompy, b_index_dteyreap, v_jobgrade, v_minsal, v_maxsal, v_avgsal,global_v_coduser,global_v_coduser);
        exception when DUP_VAL_ON_INDEX then
          begin
            update tsalstr 
               set jobgrade = v_jobgrade,
                   amtminsa = v_minsal,
                   amtmaxsa = v_maxsal,
                   midpoint = v_avgsal,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codcompy = b_index_codcompy 
               and dteyreap = b_index_dteyreap 
               and jobgrade = v_jobgradeOld;
          end;
        end;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  
end hrap21e;

/
