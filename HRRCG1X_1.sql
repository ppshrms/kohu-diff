--------------------------------------------------------
--  DDL for Package Body HRRCG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRCG1X" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    b_index_dteyear     := hcm_util.get_string_t(json_obj,'p_year');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    b_index_typdata     := hcm_util.get_string_t(json_obj,'p_flgsummarize');
    b_index_comlevel    := hcm_util.get_string_t(json_obj,'p_complvl');

    b_index_dteyear     := nvl(b_index_dteyear,to_char(sysdate,'yyyy'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure gen_cost_of_rc_by_dept(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_dataset   json_array_t;
    array_data      json_array_t;
    cursor c1 is
      select hcm_util.get_codcomp_level(codcomp,b_index_comlevel) as comp_lvl,
             sum(amtpay) as sum_amtpay
        from tjobpost
       where codcomp like hcm_util.get_codcomp_level(b_index_codcomp,null)||'%'
         and to_char(dtepost,'yyyy') = b_index_dteyear
      group by hcm_util.get_codcomp_level(codcomp,b_index_comlevel)
      order by comp_lvl;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_dataset := json_array_t();
    array_data    := json_array_t();
    for i in c1 loop
      if secur_main.secur7(i.comp_lvl, global_v_coduser) then
        array_label.append(i.comp_lvl);
        array_dataset.append(i.sum_amtpay);
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
  procedure get_cost_of_rc_by_dept(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_cost_of_rc_by_dept(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_cost_of_rc_by_position(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_dataset   json_array_t;
    array_data      json_array_t;
    v_qtyact        treqest2.qtyact%type;
    v_exp           number;
    cursor c1 is
      select --numreqst, 
             codpos, sum(amtpay) as amtpay
        from tjobpost
       where codpos    = nvl(b_index_codpos,codpos)
         and to_char(dtepost,'yyyy') = b_index_dteyear
         and exists (select 1
                       from tusrcom us
                      where tjobpost.codcomp  like us.codcomp||'%'
                        and us.coduser        = global_v_coduser)
      group by codpos
      order by codpos;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_dataset := json_array_t();
    for i in c1 loop
      v_exp   := 0;
      begin
        select nvl(sum(nvl(qtyact,0)),0) as qtyact
          into v_qtyact
          from treqest2
         where 1 = 1 --numreqst = i.numreqst
           and codpos   = i.codpos;
      exception when no_data_found then
        v_qtyact := 0;
      end;

      v_exp   := nvl(i.amtpay / nullif(v_qtyact,0),0);
      array_label.append(get_tpostn_name(i.codpos, global_v_lang));
      array_dataset.append(v_exp);
    end loop;
    array_data := json_array_t();
    array_data.append(array_dataset);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_cost_of_rc_by_position(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_cost_of_rc_by_position(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_average_cost_of_hire(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_dataset   json_array_t;
    array_data      json_array_t;
    v_month         varchar2(2 char);
    v_qtyact        number := 0;
    v_amtsalavg     number := 0;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_dataset := json_array_t();
    for i in 1..12 loop
      begin
        select to_char(dteappchse,'mm') ,sum( nvl(qtyact,0) ) ,sum( nvl(qtyact,0) * nvl(amtsalavg,0) )
          into v_month,v_qtyact,v_amtsalavg
          from treqest2 rq
         where codcomp like hcm_util.get_codcomp_level(b_index_codcomp,null)||'%'
           and to_char(dtereqm, 'yyyy') = b_index_dteyear
           and to_char(dteappchse,'mm') = to_char(lpad(i,2,0))
           and exists (select 1
                         from tusrcom us
                        where rq.codcomp    like us.codcomp||'%'
                          and us.coduser    = global_v_coduser)
        group by to_char(dteappchse,'mm')
        order by to_char(dteappchse,'mm');
      exception when no_data_found then
        v_month        := to_char(lpad(i,2,0));
        v_qtyact       := 0;
        v_amtsalavg    := 0;
      end;
      array_label.append(get_nammthabb(v_month,global_v_lang));
      if b_index_typdata = '1' then
        array_dataset.append(v_amtsalavg);
      else
        array_dataset.append(v_qtyact);
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
  procedure get_average_cost_of_hire(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_average_cost_of_hire(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_source_of_hire(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label  json_array_t;
    array_label     json_array_t;
    array_qtyemp    json_array_t;
    array_qtyact    json_array_t;
    array_amtpay    json_array_t;
    array_data      json_array_t;
    v_month         varchar2(2 char);
    v_qtyact        number := 0;
    v_qtyemp        number := 0;
    cursor c1 is
      select codjobpost, sum(amtpay) as amtpay
        from tjobposte jb
       where to_char(dtepost, 'yyyy') = b_index_dteyear
         and exists (select 1
                       from tusrcom us
                      where jb.codcomp    like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
      group by codjobpost;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qtyemp  := json_array_t();
    array_qtyact  := json_array_t();
    array_amtpay  := json_array_t();
    for i in c1 loop
      begin
        select count(b.numappl) into v_qtyemp
          from tjobpost a, tapplinf b
         where to_char(a.dtepost, 'yyyy') = b_index_dteyear
           and a.codjobpost = i.codjobpost
           and a.numreqst = b.numreql
           and a.codpos = b.codposl
           and exists (select 1
                         from tusrcom us
                        where a.codcomp     like us.codcomp||'%'
                          and us.coduser    = global_v_coduser);
      end;
      begin
        select sum(nvl(b.qtyact,0)) into v_qtyact
          from tjobpost a, treqest2 b
         where to_char(a.dtepost, 'yyyy') = b_index_dteyear
           and a.codjobpost = i.codjobpost
           and a.numreqst = b.numreqst
           and a.codpos = b.codpos
           and exists (select 1
                         from tusrcom us
                        where a.codcomp     like us.codcomp||'%'
                          and us.coduser    = global_v_coduser);
      end;

      array_label.append(get_tcodec_name('TCODJOBPOST', i.codjobpost, global_v_lang));
      if b_index_typdata    = '1' then
        array_qtyemp.append(v_qtyemp);
        array_qtyact.append(v_qtyact);
      else
        array_amtpay.append(i.amtpay);
      end if;
    end loop;
    array_data    := json_array_t();
    if b_index_typdata    = '1' then
      array_data.append(array_qtyemp);
      array_data.append(array_qtyact);
    else
      array_data.append(array_amtpay);
    end if;
    array_head_label  := json_array_t();
    array_head_label.append(get_label_name('HRRCG1X1',global_v_lang,810));
    array_head_label.append(get_label_name('HRRCG1X1',global_v_lang,820));

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_source_of_hire(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_source_of_hire(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_time_per_stage(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label  json_array_t;
    array_label     json_array_t;
    array_qtyapp    json_array_t;
    array_qtypos    json_array_t;
    array_qtytrn    json_array_t;
    array_qtyinv    json_array_t;
    array_qtyrec    json_array_t;
    array_data      json_array_t;
    cursor c1 is
      select b.codpos, 
             sum(trunc(a.dteaprov) - trunc(a.dtereq)) as qtyapp,
             sum(trunc(b.dtepost) - trunc(a.dteaprov)) as qtypos,
             sum(trunc(b.dtechoose) - trunc(b.dtepost)) as qtytrn,
             sum(trunc(b.dteintview) - trunc(b.dtechoose)) as qtyinv,
             sum(trunc(b.dteappchse) - trunc(b.dteintview)) as qtyrec
        from treqest1 a, treqest2 b
       where a.numreqst   = b.numreqst
         and b.codpos     = nvl(b_index_codpos,b.codpos)
         and exists (select 1
                       from tusrcom us
                      where a.codcomp     like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
      group by b.codpos
      order by b.codpos;
  begin
    obj_data      := json_object_t();
    array_head_label  := json_array_t();
    array_label   := json_array_t();
    array_qtyapp  := json_array_t();
    array_qtypos  := json_array_t();
    array_qtytrn  := json_array_t();
    array_qtyinv  := json_array_t();
    array_qtyrec  := json_array_t();

    for i in c1 loop
      array_label.append(get_tpostn_name(i.codpos,global_v_lang));
      array_qtyapp.append(i.qtyapp);
      array_qtypos.append(i.qtypos);
      array_qtytrn.append(i.qtytrn);
      array_qtyinv.append(i.qtyinv);
      array_qtyrec.append(i.qtyrec);
    end loop;
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,830));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,840));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,850));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,860));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,870));

    array_data    := json_array_t();
    array_data.append(array_qtyapp);
    array_data.append(array_qtypos);
    array_data.append(array_qtytrn);
    array_data.append(array_qtyinv);
    array_data.append(array_qtyrec);

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_time_per_stage(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_time_per_stage(json_str_output);
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
