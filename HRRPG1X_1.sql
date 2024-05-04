--------------------------------------------------------
--  DDL for Package Body HRRPG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRPG1X" as
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
    b_index_comlevel    := hcm_util.get_string_t(json_obj,'p_complvl');
    b_index_col_grp     := hcm_util.get_string_t(json_obj,'p_flgsumdata');

    b_index_dteyear     := nvl(b_index_dteyear,to_char(sysdate,'yyyy'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure gen_type_monthly_access_rate(json_str_output out clob) is
    obj_data          json_object_t;
    array_head_label  json_array_t;
    array_label       json_array_t;
    array_qty         json_array_t;
    array_data        json_array_t;
    cursor c1 is
      select --New Employee
             sum(decode(dtemthbug,1,qtytotrc,0)) qty1,
             sum(decode(dtemthbug,2,qtytotrc,0)) qty2,
             sum(decode(dtemthbug,3,qtytotrc,0)) qty3,
             sum(decode(dtemthbug,4,qtytotrc,0)) qty4,
             sum(decode(dtemthbug,5,qtytotrc,0)) qty5,
             sum(decode(dtemthbug,6,qtytotrc,0)) qty6,
             sum(decode(dtemthbug,7,qtytotrc,0)) qty7,
             sum(decode(dtemthbug,8,qtytotrc,0)) qty8,
             sum(decode(dtemthbug,9,qtytotrc,0)) qty9,
             sum(decode(dtemthbug,10,qtytotrc,0)) qty10,
             sum(decode(dtemthbug,11,qtytotrc,0)) qty11,
             sum(decode(dtemthbug,12,qtytotrc,0)) qty12
        from tmanpwm a
       where dteyrbug = b_index_dteyear
         and codcomp  like b_index_codcompy||'%'
         and exists (select 1
                       from tusrcom us
                      where a.codcomp     like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
      union all
      select --Resign Employee
             sum(decode(dtemthbug,1,qtytotre,0)) qty1,
             sum(decode(dtemthbug,2,qtytotre,0)) qty2,
             sum(decode(dtemthbug,3,qtytotre,0)) qty3,
             sum(decode(dtemthbug,4,qtytotre,0)) qty4,
             sum(decode(dtemthbug,5,qtytotre,0)) qty5,
             sum(decode(dtemthbug,6,qtytotre,0)) qty6,
             sum(decode(dtemthbug,7,qtytotre,0)) qty7,
             sum(decode(dtemthbug,8,qtytotre,0)) qty8,
             sum(decode(dtemthbug,9,qtytotre,0)) qty9,
             sum(decode(dtemthbug,10,qtytotre,0)) qty10,
             sum(decode(dtemthbug,11,qtytotre,0)) qty11,
             sum(decode(dtemthbug,12,qtytotre,0)) qty12
        from tmanpwm a
       where dteyrbug = b_index_dteyear
         and codcomp  like b_index_codcompy||'%'
         and exists (select 1
                       from tusrcom us
                      where a.codcomp     like us.codcomp||'%'
                        and us.coduser    = global_v_coduser);
  begin
    obj_data          := json_object_t();
    array_label       := json_array_t();
    array_data        := json_array_t();
    for i in 1..12 loop
      array_label.append(get_tlistval_name('NAMMTHABB',i,global_v_lang));
    end loop;
    for i in c1 loop
      array_qty   := json_array_t();
      array_qty.append(i.qty1);
      array_qty.append(i.qty2);
      array_qty.append(i.qty3);
      array_qty.append(i.qty4);
      array_qty.append(i.qty5);
      array_qty.append(i.qty6);
      array_qty.append(i.qty7);
      array_qty.append(i.qty8);
      array_qty.append(i.qty9);
      array_qty.append(i.qty10);
      array_qty.append(i.qty11);
      array_qty.append(i.qty12);
      array_data.append(array_qty);
    end loop;
    array_head_label  := json_array_t();
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,810));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,820));

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_type_monthly_access_rate(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_type_monthly_access_rate(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_existing_manpower_by_criteria(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label  json_array_t;
    array_label     json_array_t;
    array_qty_m     json_array_t;
    array_qty_f     json_array_t;
    array_data      json_array_t;
    v_cursor        number;
    v_dummy         integer;
    v_statment      varchar2(4000);
    v_qty_emp       number;
    v_col_grp       varchar2(1000);
    v_fundesc       varchar2(1000);
    v_desc          varchar2(1000);
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_data    := json_array_t();
    array_qty_m   := json_array_t();
    array_qty_f   := json_array_t();

    if b_index_col_grp is not null  then
      v_statment := 'select distinct '||b_index_col_grp||' as col_grp
                       from v_hrrps3x a
                      where hcm_util.get_codcomp_level(codcomp,1) = nvl('''||b_index_codcompy||''',hcm_util.get_codcomp_level(codcomp,1))
                        and '||b_index_col_grp||' is not null
                        and codsex is not null
                        and (a.codempid = '''||global_v_codempid||''' or
                            (a.codempid <> '''||global_v_codempid||'''
                             and a.numlvl between '''||global_v_zminlvl||''' and '''||global_v_zwrklvl||'''
                             and 0 <> (select count(ts.codcomp)
                                        from tusrcom ts
                                       where ts.coduser = '''||global_v_coduser||'''
                                         and a.codcomp like ts.codcomp||''%''
                                         and rownum    <= 1 )))
                        order by '||b_index_col_grp ;
    end if;
    v_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_statment,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_col_grp,1000);
    v_dummy := dbms_sql.execute(v_cursor);

    while dbms_sql.fetch_rows(v_cursor) > 0 loop
      dbms_sql.column_value(v_cursor,1,v_col_grp);

      --description fundesc from treport2
      begin
        select funcdesc
          into v_fundesc
          from treport2
         where codapp = 'HRRPS3XR'
           and namfld = b_index_col_grp;
      exception when no_data_found then
        v_fundesc := null;
      end;

      v_fundesc := replace(v_fundesc,'P_CODE',''''||v_col_grp||'''');
      v_fundesc := replace(v_fundesc,'P_LANG',''''||global_v_lang||'''');
      if v_fundesc is not null then
        v_fundesc   := 'select '||v_fundesc||' from dual';
        v_desc      := execute_desc(v_fundesc);
      else
        v_desc      := v_col_grp;
      end if;

      array_label.append(v_desc);
      begin
        v_qty_emp   := execute_desc('select count(1) as qty_emp
                                       from v_hrrps3x a
                                      where hcm_util.get_codcomp_level(codcomp,1) = '''||b_index_codcompy||'''
                                        and '||b_index_col_grp||' = '''||v_col_grp||'''
                                        and codsex      = ''M''
                                        and (a.codempid = '''||global_v_codempid||''' or
                                            (a.codempid <> '''||global_v_codempid||'''
                                             and a.numlvl between '''||global_v_zminlvl||''' and '''||global_v_zwrklvl||'''
                                             and 0 <> (select count(ts.codcomp)
                                                        from tusrcom ts
                                                       where ts.coduser = '''||global_v_coduser||'''
                                                         and a.codcomp like ts.codcomp||''%''
                                                         and rownum    <= 1 ))) ');
      end;

      array_qty_m.append(nvl(v_qty_emp,0)); ----- Male
      begin
        v_qty_emp   := execute_desc('select count(1) as qty_emp
                                       from v_hrrps3x a
                                      where hcm_util.get_codcomp_level(codcomp,1) = '''||b_index_codcompy||'''
                                        and '||b_index_col_grp||' = '''||v_col_grp||'''
                                        and codsex      = ''F''
                                        and (a.codempid = '''||global_v_codempid||''' or
                                            (a.codempid <> '''||global_v_codempid||'''
                                             and a.numlvl between '''||global_v_zminlvl||''' and '''||global_v_zwrklvl||'''
                                             and 0 <> (select count(ts.codcomp)
                                                        from tusrcom ts
                                                       where ts.coduser = '''||global_v_coduser||'''
                                                         and a.codcomp like ts.codcomp||''%''
                                                         and rownum    <= 1 ))) ');
      end;
      array_qty_f.append(nvl(v_qty_emp,0)); ----- Female
    end loop;
    array_head_label  := json_array_t();
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,830));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,840));

    array_data.append(array_qty_m);
    array_data.append(array_qty_f);

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_existing_manpower_by_criteria(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_existing_manpower_by_criteria(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_sum_employee_each_department(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label  json_array_t;
    array_label     json_array_t;
    array_qty_m     json_array_t;
    array_qty_f     json_array_t;
    array_qty_all   json_array_t;
    array_data      json_array_t;
    v_secure        boolean;
    cursor c1 is
      select hcm_util.get_codcomp_level (codcomp,b_index_comlevel) codcomp,
             count( case when codsex = 'M' then 'x' end ) count_m,
             count( case when codsex = 'F' then 'x' end ) count_f,
             count(codempid) count_all
        from v_temploy
       where 1 = 1
         and numlvl between global_v_zminlvl and global_v_zwrklvl
    group by hcm_util.get_codcomp_level (codcomp,b_index_comlevel)
    order by hcm_util.get_codcomp_level (codcomp,b_index_comlevel);
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty_m   := json_array_t();
    array_qty_f   := json_array_t();
    array_qty_all := json_array_t();
    array_data    := json_array_t();

    for i in c1 loop
      v_secure    := secur_main.secur7(i.codcomp,global_v_coduser);
      if v_secure then
        array_label.append(i.codcomp);
        array_qty_m.append(i.count_m);
        array_qty_f.append(i.count_f);
        array_qty_all.append(i.count_all);
      end if;
    end loop;
    array_head_label  := json_array_t();
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,830));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,840));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,850));

    array_data.append(array_qty_m);
    array_data.append(array_qty_f);
    array_data.append(array_qty_all);
    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_sum_employee_each_department(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_sum_employee_each_department(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_agency_vacancy_summary(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label  json_array_t;
    array_label     json_array_t;
    array_qty_b     json_array_t;
    array_qty_p     json_array_t;
    array_data      json_array_t;
    v_present       number := 0;
    v_secure        boolean := false;
    cursor c1 is
      select hcm_util.get_codcomp_level(codcomp,b_index_comlevel) as comp_lvl, sum(qtybudgt) as qtybudgt
        from tbudgetm a
       where dteyrbug  = b_index_dteyear
         and dtemthbug = decode(b_index_dteyear,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)   --ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
         and codcomp   like b_index_codcomp || '%'
         and dtereq    = (select max(dtereq)
                             from tbudgetm
                            where codpos    = a.codpos
                              and dteyrbug  = b_index_dteyear
                              and dtemthbug = decode(b_index_dteyear,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)  --ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
                              and codcomp   = a.codcomp)
      group by hcm_util.get_codcomp_level(codcomp,b_index_comlevel)
      order by comp_lvl;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty_b   := json_array_t();
    array_qty_p   := json_array_t();
    array_data    := json_array_t();

    for r1 in c1 loop
      v_secure  := secur_main.secur7(r1.comp_lvl,global_v_coduser);
      if v_secure then
        begin
          select count(codempid) into v_present
           from temploy1
          where codcomp   like r1.comp_lvl||'%'
            and staemp    in (1,3);
        exception when others then
          v_present := 0;
        end;

        array_qty_b.append(r1.qtybudgt);
        array_qty_p.append(v_present);
      end if;
    end loop;
    array_head_label  := json_array_t();
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,860));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,870));

    array_data.append(array_qty_b);
    array_data.append(array_qty_p);
    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_agency_vacancy_summary(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_agency_vacancy_summary(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_list_of_talent(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label  json_array_t;
    array_label     json_array_t;
    array_qty_x     json_array_t;
    array_qty_y     json_array_t;
    array_qty_b     json_array_t;
    array_data      json_array_t;
    v_present       number := 0;
    v_cntbaby       number := 0;
    v_cntgenx       number := 0;
    v_cntgeny       number := 0;

    cursor c1 is
      select codpose, dteeffec
        from ttalente a
       where codcompe   like b_index_codcompy||'%'
         and exists (select 1
                       from tusrcom us
                      where a.codcompe    like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
         and exists (select 1
                       from temploy1 emp
                      where emp.codempid  = a.codempid
                        and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
         and dteeffec   = (select max(dteeffec)
                            from ttalente b
                           where b.codcompe = a.codcompe
                             and b.codpose  = a.codpose)
    group by codpose, dteeffec
    order by codpose, dteeffec;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty_x   := json_array_t();
    array_qty_y   := json_array_t();
    array_qty_b   := json_array_t();
    array_data    := json_array_t();

    for r1 in c1 loop
      --Baby Boomer--
      array_label.append(get_tpostn_name(r1.codpose,global_v_lang));
      begin
       select count(a.codempid) into v_cntbaby
         from ttalente a, temploy1 b
        where a.codempid   = b.codempid
          and a.codcompe   like b_index_codcompy||'%'
          and a.codpose    = r1.codpose
          and a.dteeffec   = r1.dteeffec
          and a.staappr    = 'Y'
          and b.numlvl     between global_v_zminlvl and global_v_zwrklvl
          and exists (select 1
                       from tusrcom us
                      where a.codcompe    like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
          and get_generation(b.dteempdb) = '0001'; ----(sysdate - b.dteempdb) + 1 between (50 * 365) and  (60 * 365);
      end;
      --Gen X--
      begin
       select count(a.codempid) into v_cntgenx
         from ttalente a, temploy1 b
        where a.codempid   = b.codempid
          and a.codcompe   like b_index_codcompy||'%'
          and a.codpose    = r1.codpose
          and a.dteeffec   = r1.dteeffec
          and a.staappr    = 'Y'
          and b.numlvl     between global_v_zminlvl and global_v_zwrklvl
          and exists (select 1
                       from tusrcom us
                      where a.codcompe    like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
          and get_generation(b.dteempdb) = '0002'; ----(sysdate - b.dteempdb) + 1 between (35 * 365) and  (49 * 365);
      end;
      --Gen Y--
      begin
       select count(a.codempid) into v_cntgeny
         from ttalente a, temploy1 b
        where a.codempid   = b.codempid
          and a.codcompe   like b_index_codcompy||'%'
          and a.codpose    = r1.codpose
          and a.dteeffec   = r1.dteeffec
          and a.staappr    = 'Y'
          and b.numlvl     between global_v_zminlvl and global_v_zwrklvl
          and exists (select 1
                       from tusrcom us
                      where a.codcompe    like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
          and get_generation(b.dteempdb) = '0003'; ----(sysdate - b.dteempdb) + 1 between (14 * 365) and  (34 * 365);
      end;
      array_qty_x.append(v_cntgenx);
      array_qty_y.append(v_cntgeny);
      array_qty_b.append(v_cntbaby);
    end loop;
    array_head_label  := json_array_t();
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,880));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,890));
    array_head_label.append(get_label_name('HRRPG1X1',global_v_lang,900));

    array_data.append(array_qty_x);
    array_data.append(array_qty_y);
    array_data.append(array_qty_b);
    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_list_of_talent(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_list_of_talent(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_9_box(json_str_output out clob) is
    obj_box       json_object_t;
    obj_data      json_object_t;
    v_dteeffec    date;
    v_amountemp   varchar2(100 char);
    v_percntemp   varchar2(100 char);
    cursor c1 is
      select codcompy,codgroup,descgroup,dteeffec,namgroupt
        from tninebox a
       where a.codcompy = hcm_util.get_codcomp_level(b_index_codcomp, 1) 
         and a.dteeffec = (select max(dteeffec)
                             from tninebox
                            where codcompy = a.codcompy
                              and dteeffec <= v_dteeffec);
  begin
    v_dteeffec    := to_date('31/12/'||to_char(b_index_dteyear),'dd/mm/yyyy hh24:mi:ss');

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dteeffec', to_char(v_dteeffec,'dd/mm/yyyy'));
    obj_data.put('codselect', '');

    for r1 in c1 loop
      hrrp6bx.get_data_box(b_index_dteyear, r1.codcompy, r1.codcompy, r1.codgroup, v_amountemp, v_percntemp);
      obj_box := json_object_t();
      obj_box.put('codgroup', nvl(r1.codgroup,''));
      obj_box.put('namgroupt', nvl(r1.namgroupt,''));
      obj_box.put('descgroup', nvl(r1.descgroup,''));
      obj_box.put('amountemp', v_amountemp);
      obj_box.put('percntemp', v_percntemp);
      obj_data.put('box'||r1.codgroup, obj_box);
    end loop;
    json_str_output := obj_data.to_clob;
  end;
  --
  procedure get_9_box(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_9_box(json_str_output);
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
