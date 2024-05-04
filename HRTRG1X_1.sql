--------------------------------------------------------
--  DDL for Package Body HRTRG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTRG1X" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    b_index_dteyear     := hcm_util.get_string_t(json_obj,'p_year');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_typdata     := hcm_util.get_string_t(json_obj,'p_flgtype');

    b_index_dteyear     := nvl(b_index_dteyear,to_char(sysdate,'yyyy'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure gen_number_of_training_by_month(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_dataset   json_array_t;
    array_data      json_array_t;
    v_dtemonth      thistrnn.dtemonth%type;

    cursor c1 is
     select count(distinct codempid) qtyemp, sum(nvl(amtcost,0)) sumamt
       from thistrnn
      where codcomp   like hcm_util.get_codcomp_level(b_index_codcomp,null)||'%'
        and dteyear   = b_index_dteyear
        and dtemonth  = v_dtemonth
        and exists (select 1
                      from temploy1 emp
                     where emp.codempid  = thistrnn.codempid
                       and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
        and exists (select 1
                      from tusrcom us
                     where thistrnn.codcomp like us.codcomp||'%'
                       and us.coduser       = global_v_coduser);
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_dataset := json_array_t();

    for i in 1..12 loop
      array_label.append(get_tlistval_name('NAMMTHFUL',i,global_v_lang));
      v_dtemonth  := i;
      for r1 in c1 loop
        if b_index_typdata = '1' then
          array_dataset.append(r1.qtyemp);
        else
          array_dataset.append(nvl(r1.sumamt,0));
        end if;
      end loop;
    end loop;
    array_data := json_array_t();
    array_data.append(array_dataset);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_number_of_training_by_month(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_number_of_training_by_month(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_number_of_training_by_course(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_dataset   json_array_t;
    array_data      json_array_t;
    v_dtemonth      thistrnn.dtemonth%type;

    cursor c1 is
     select codcours, count(distinct codempid) qtyemp, sum(nvl(amtcost,0)) sumamt
       from thistrnn
      where codcomp   like hcm_util.get_codcomp_level(b_index_codcomp,null)||'%'
        and dteyear   = b_index_dteyear
        and exists (select 1
                      from temploy1 emp
                     where emp.codempid  = thistrnn.codempid
                       and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
        and exists (select 1
                      from tusrcom us
                     where thistrnn.codcomp like us.codcomp||'%'
                       and us.coduser       = global_v_coduser)
     group by codcours
     order by codcours;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_dataset := json_array_t();
    for r1 in c1 loop
      array_label.append(get_tcourse_name(r1.codcours,global_v_lang));
      if b_index_typdata = '1' then
        array_dataset.append(r1.qtyemp);
      else
        array_dataset.append(nvl(r1.sumamt,0));
      end if;
    end loop;
    array_data := json_array_t();
    array_data.append(array_dataset);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_number_of_training_by_course(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_number_of_training_by_course(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;


/
