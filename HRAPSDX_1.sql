--------------------------------------------------------
--  DDL for Package Body HRAPSDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSDX" as
  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');    

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
  begin 

    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;
    v_percent       number; --<< user25 14/08/2021 #4331

    cursor c1 is
      select codempid,codcomp,codpos,qtywork,amtsal,qtyscore,grade,pctadjsal,pctcalsal,amtadj,amtbudg,amtsaln
        from tapprais 
       where dteyreap   = b_index_year
         and codcomp    like b_index_codcomp||'%'
    order by codempid;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;                

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('qtywork', trunc(r1.qtywork / 12,0)||':'||mod(r1.qtywork,12));
        obj_data.put('score', r1.qtyscore);
        obj_data.put('grade', r1.grade);
        
--<< user25 14/08/2021 #4331
        v_percent := nvl(nvl(r1.pctadjsal, r1.pctcalsal),0);
        obj_data.put('percent', to_char(v_percent,'fm990.00'));
--      obj_data.put('percent', nvl(r1.pctadjsal, r1.pctcalsal)); 
-->> user25 14/08/2021 #4331     
        if v_zupdsal = 'Y' then
            obj_data.put('slrycur', stddec(r1.amtsal,r1.codempid,v_chken));
            obj_data.put('increase', stddec(r1.amtadj,r1.codempid,v_chken));
            obj_data.put('total', stddec(r1.amtbudg,r1.codempid,v_chken) + stddec(r1.amtadj,r1.codempid,v_chken));
            obj_data.put('salary', stddec(r1.amtsaln,r1.codempid,v_chken));
        else
            obj_data.put('slrycur', '');
            obj_data.put('increase', '');
            obj_data.put('total', '');
            obj_data.put('salary', '');
        end if;

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tapprais');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);    
    gen_detail(json_str_output);

    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean := false;

    v_day           number;
	v_month         number;
	v_year          number;

    cursor c1 is
      select a.codempid,b.dteedit,a.qtyscore,a.grade,a.pctcalsal,b.pctsal,b.amtadj,b.codcreate,b.dtecreate
        from tapprais a, tlogapprais b 
       where a.codempid = b.codempid
         and a.dteyreap = b.dteyreap
         and a.dteyreap = b_index_year
         and a.codcomp  like b_index_codcomp||'%'
         and a.flgsal   = 'Y'   
    order by a.codempid,b.dteedit desc;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then 
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dteedit', to_char(r1.dteedit,'dd/mm/yyyy hh24:mi'));
        obj_data.put('score', r1.qtyscore);
        obj_data.put('grade', r1.grade);
        --<< user25 14/08/2021 #4331
        /*
        obj_data.put('percal', r1.pctcalsal);
        obj_data.put('perincrease', r1.pctsal);
        */
        obj_data.put('percal', to_char(r1.pctcalsal,'fm990.00'));
        obj_data.put('perincrease', to_char(r1.pctsal,'fm990.00'));
        -->> user25 14/08/2021 #4331
        if v_zupdsal = 'Y' then
            obj_data.put('special_amount', stddec(r1.amtadj,r1.codempid,v_chken));
        else
            obj_data.put('special_amount', '');
        end if;
--      obj_data.put('desc_codempap', get_temploy_name(r1.codcreate,global_v_lang));--<< user25 14/08/2021 #4331
        obj_data.put('desc_codempap', get_temploy_name(get_codempid(r1.codcreate),global_v_lang));--<< user25 14/08/2021 #4331
        obj_data.put('dteappr', to_char(r1.dtecreate,'dd/mm/yyyy'));

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tapprais');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
end;

/
