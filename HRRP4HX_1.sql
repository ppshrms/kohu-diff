--------------------------------------------------------
--  DDL for Package Body HRRP4HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP4HX" is
-- last update: 11/08/2020 10:07

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
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');
    b_index_month       := hcm_util.get_string_t(json_obj,'p_month');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure check_index as
  begin
    if b_index_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char);
    flgpass     	  boolean;
    v_year          number := 0;
    v_month         number := 0;
    v_day           number := 0;
    v_codcomp       tposempd.codcomp%type;
    v_codpos        tposempd.codpos%type;

    cursor c1 is
      select codempid,codcomp,codpos,dteefpos,dteposdue,numseq
        from tposempd
       where codcomp like b_index_codcomp||'%'
         and to_char(dteposdue,'mm/yyyy') = lpad(b_index_month,2,'0')||'/'||b_index_year
        and dteefpos is not null 
    order by codempid,numseq;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';
      flgpass := secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if flgpass then
        begin
          select codcomp,codpos into v_codcomp,v_codpos
          from TPOSEMPD
         where codempid = i.codempid
           and numseq = i.numseq + 1;
        exception when no_data_found then
        v_codcomp := '';
        v_codpos := '';
        end;
        get_service_year(i.dteefpos,trunc(sysdate),'Y',v_year,v_month,v_day);
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image',get_emp_img(i.codempid));
        obj_data.put('numseq',i.numseq);
        obj_data.put('codempid',i.codempid);
        obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
        obj_data.put('curr_desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
        obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
        obj_data.put('ageposit',v_year||'('||v_month||')');
        obj_data.put('dteposit',to_char(i.dteposdue,'dd/mm/yyyy'));
        obj_data.put('next_desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
        obj_data.put('next_pos',get_tpostn_name(v_codpos,global_v_lang));

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgdata = 'Y' then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TPOSEMPD');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
end;

/
