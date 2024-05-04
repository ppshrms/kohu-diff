--------------------------------------------------------
--  DDL for Package Body HRAP5BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP5BX" is
-- last update: 18/09/2020 20:20

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

    b_index_dteyreap     := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_numtime      := to_number(hcm_util.get_string_t(json_obj,'p_no'));
    b_index_codbon       := hcm_util.get_string_t(json_obj,'p_typebonus');
    b_index_codcomp      := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_typpayroll   := hcm_util.get_string_t(json_obj,'p_typpayroll');

    
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
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

  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean; 
    v_zupdsal   	varchar2(4);

    cursor c1 is
        select codempid,codcomp,typpayroll,
               stddec(amtnbon,codempid,v_chken) amtnbon,
               numperiod,dtemthpay,dteyrepay
          from tbonus
         where dteyreap = b_index_dteyreap
           and numtime = b_index_numtime
           and codbon = nvl(b_index_codbon,codbon)
           and codcomp like b_index_codcomp||'%'
           and typpayroll = nvl(b_index_typpayroll,typpayroll)
           and flgtrnpy = 'Y'
           and codempid is not null
        order by typpayroll,codcomp,codempid;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata   := 'Y';
        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('typpayroll', i.typpayroll);
            obj_data.put('desc_typpayroll', i.typpayroll);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid', i.codempid);
            obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('periodpay',i.numperiod||'/'||i.dtemthpay||'/'||i.dteyrepay);
            obj_data.put('amtnbon', i.amtnbon);
            obj_data.put('codcomp', i.codcomp);
            
            obj_data.put('dteyreap', b_index_dteyreap);
            obj_data.put('numtime', b_index_numtime);
            obj_data.put('codbon', b_index_codbon);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tbonus');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
end;

/
