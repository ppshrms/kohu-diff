--------------------------------------------------------
--  DDL for Package Body HRPM87X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM87X" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    pa_codempid              := hcm_util.get_string_t(json_obj,'pa_codempid');
    pa_dtestr                := to_date(trim(hcm_util.get_string_t(json_obj,'pa_dtestr')),'dd/mm/yyyy');
    pa_dteend                := to_date(trim(hcm_util.get_string_t(json_obj,'pa_dteend')),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_getindex(json_str_input in clob) as
    v_codcomp      temploy1.codcomp%type;
    v_numlvl       temploy1.numlvl%type;
    secur          boolean;
  BEGIN
        if (pa_codempid is null) OR (pa_dtestr is null) OR (pa_dteend is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return ;
        end if;

        if (pa_codempid is not null) then
        begin
           select codcomp,numlvl into v_codcomp,v_numlvl
            from temploy1
           where codempid = pa_codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'');
          return;
        end;
        end if;

        if( pa_dtestr > pa_dteend ) then
           param_msg_error := get_error_msg_php('HR2021',global_v_lang, '');
          return ;
        end if;

       secur := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
       if not secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
       end if;
  END vadidate_variable_getindex;

  procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);
    if param_msg_error is null then
        gen_index(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        	json_object_t;
    obj_row         	json_object_t;
    obj_result      	json_object_t;
    v_rcnt          	number := 0;
    v_secur             boolean := false;
    v_permission        boolean := false;
    v_data_exist        boolean := false;
    v_codempid          thisrewd.codempid%type;

    v_ocodempid   thisrewd.codempid%type  := GET_OCODEMPID(pa_codempid);

    cursor c1 is    select codempid,dteinput,typrewd,desrewd1,numhmref
                    from thisrewd
                    where (codempid = pa_codempid or v_ocodempid like '[%'||codempid||']%')
                    and dteinput between nvl(pa_dtestr,dteinput) and nvl(pa_dteend,dteinput)
                    order by dteinput desc;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_data_exist := true;
      exit;
    end loop;

    if not v_data_exist then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'thisrewd');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      v_codempid := r1.codempid;

      v_secur := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

      if v_secur then
      v_permission := true;

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('date',to_char(r1.dteinput,'dd/mm/yyyy'));
      obj_data.put('type', get_tcodec_name('TCODREWD',r1.typrewd,global_v_lang));
      obj_data.put('detail', r1.desrewd1);
      obj_data.put('docid', r1.numhmref);
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));

      obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_permission then
        json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'');
        json_str_output := get_response_message('404',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end HRPM87X;

/
