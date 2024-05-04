--------------------------------------------------------
--  DDL for Package Body HRRP6BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP6BX" AS
   procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
    b_index_year        := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codgroup          := hcm_util.get_string_t(json_obj,'p_codgroup');
    p_year              := to_number(hcm_util.get_string_t(json_obj,'p_year'));

    params_syncond      := hcm_util.get_json_t(json_obj,'p_syncond');
    params_json         := hcm_util.get_json_t(json_obj,'json_input_str');
    p_dteeffec          :=  to_date('31/12/'||to_char(b_index_year),'dd/mm/yyyy hh24:mi:ss');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    else
      begin
        select codcomp into v_codcomp
        from tcenter
        where codcomp = get_compful(b_index_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(b_index_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if b_index_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;
  procedure gen_index(json_str_output out clob) as
    obj_data     json_object_t;
    obj_box      json_object_t;
    obj_syncond  json_object_t;
    v_description  varchar2(4000 char);
    v_statement   tninebox.statement%type;
    v_syncond     tninebox.syncond%type;
    v_codgroup    tninebox.codgroup%type;
    v_namgroupt   tninebox.namgroupt%type;
    v_descgroup   tninebox.descgroup%type;
    v_dteeffec    tninebox.dteeffec%type;
    v_codcompy    tninebox.codcompy%type;
    v_amountemp   varchar2(100 char);
    v_percntemp   varchar2(100 char);
    v_flgExist    boolean := false;
    v_numseq      number := 0;
    v_dtechoose   tnineboxe.dtechoose%type;
    v_codchoose   tnineboxe.codchoose%type;
    v_dteyear     tnineboxe.dteyear%type;

    cursor c1 is
      select codcompy,codgroup,descgroup,dteeffec,namgroupt
        from tninebox a
       where b_index_codcomp like a.codcompy||'%'
         and a.dteeffec = (select max(dteeffec)
                             from tninebox
                            where codcompy = a.codcompy
                              and dteeffec <= p_dteeffec);
  begin

    begin
      select codcompy into v_codcompy
          from tninebox a
         where b_index_codcomp like a.codcompy||'%'
           and a.dteeffec = (select max(dteeffec)
                               from tninebox
                              where codcompy = a.codcompy
                                and dteeffec <= p_dteeffec)
           and rownum = 1;
    exception when no_data_found then
      v_dteeffec := '';
    end;
    begin
      select dtechoose, codchoose
      into v_dtechoose, v_codchoose
        from tnineboxe
       where dteyear = b_index_year
         and codcompy = v_codcompy
         and codcomp like b_index_codcomp||'%'
         and dtechoose = (select max(dtechoose)
                            from tnineboxe
                           where dteyear = b_index_year
                             and codcompy = v_codcompy
                             and codcomp like b_index_codcomp||'%')
         and rownum = 1;
    exception when no_data_found then null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dteeffec', to_char(v_dtechoose,'dd/mm/yyyy'));
    obj_data.put('codselect', v_codchoose || ' - ' || get_temploy_name(v_codchoose, global_v_lang));
    --box
    for r1 in c1 loop
      v_flgExist := true;
      get_data_box(b_index_year, b_index_codcomp, r1.codcompy, r1.codgroup, v_amountemp, v_percntemp);
      obj_box := json_object_t();
      obj_box.put('codgroup', nvl(r1.codgroup,''));
      obj_box.put('namgroupt', nvl(r1.namgroupt,''));
      obj_box.put('descgroup', nvl(r1.descgroup,''));
      obj_box.put('amountemp', v_amountemp);
      obj_box.put('percntemp', v_percntemp);
      obj_data.put('box'||r1.codgroup, obj_box);

    end loop;
    if not v_flgExist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TNINEBOX');
    end if;
    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

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
  procedure get_data_box(v_year in varchar2, v_codcomp in varchar2, v_codcompy in tninebox.codcompy%type, v_codgroup in tninebox.codgroup%type,
                         v_amountemp out varchar,
                         v_percntemp out varchar) as
    v_empall number := 0;
  begin
    begin
      select count(a.codempid)
        into v_amountemp
        from tnineboxe a, temploy1 b
       where a.codcompy = v_codcompy
         and a.codempid = b.codempid(+)
         and a.codcomp like  v_codcomp||'%'
         and a.dteyear = v_year
         and a.codgroup = v_codgroup
         and a.staappr = 'Y'
         and b.numlvl between global_v_zminlvl and global_v_zwrklvl
         and exists (select codcomp
                       from tusrcom c
                      where c.coduser = global_v_coduser
                        and codcomp like c.codcomp||'%');
    exception when no_data_found then
      v_amountemp := 0;
    end;
    begin
      select count(a.codempid)
        into v_empall
        from tnineboxe a, temploy1 b
       where a.codcompy = v_codcompy
         and a.codempid = b.codempid(+)
         and a.codcomp like  v_codcomp||'%'
         and a.dteyear = v_year
         and a.staappr = 'Y'
         and b.numlvl between global_v_zminlvl and global_v_zwrklvl
         and exists (select c.codcomp
                       from tusrcom c
                      where c.coduser = global_v_coduser
                        and codcomp like c.codcomp||'%');
    exception when no_data_found then
      v_empall := 0;
    end;
    -- calculate percent
--    (5/200)*100 = 2.5%
    if v_empall > 0 then
      v_percntemp := to_char((v_amountemp/v_empall) * 100, 'fm990.90');
    else
      v_percntemp := 0;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean;
    v_flgData       boolean := false;

    v_dteempmt      temploy1.dteempmt%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_year          number;
    v_month         number;
    v_day           number;
    v_amount        number := 0;
    v_codgroup      tninebox.codgroup%type;
    v_namgroupt     tninebox.namgroupt%type;
    v_descgroup     tninebox.descgroup%type;
    v_jobgrade      temploy1.jobgrade%type;

    cursor c1 is
      select codempid,agework,codgroup,codcomp,codpos,codcompy,dteeffec, dteyear
        from tnineboxe
       where dteyear = p_year
         and codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and codcomp like p_codcomp||'%'
         and codgroup = p_codgroup
         and staappr = 'Y'
       order by codcomp, codpos, codempid;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgData   := true;
      if secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
--        begin
--          select dteempmt,codcomp,codpos into v_dteempmt,v_codcomp,v_codpos
--          from temploy1
--          where codempid = r1.codempid;
--        end;
--        get_service_year(v_dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
--        obj_data.put('agework', v_year||'('|| v_month ||')');
        obj_data.put('agework', trunc(r1.agework/12)||'('||mod(r1.agework,12)||')');--User37 #7233 1. RP Module 08/12/2021 obj_data.put('agework', r1.agework);
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        obj_data.put('codgroup', r1.codgroup);
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('dteyear', r1.dteyear);
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
        begin
          select codgroup,namgroupt,descgroup into v_codgroup,v_namgroupt,v_descgroup
            from tninebox
           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
             and codgroup = p_codgroup
             and dteeffec = (select max(dteeffec)
                               from tninebox
                              where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                and dteeffec <= trunc(sysdate));
        end;
        obj_data.put('namgroupt', v_namgroupt);
        obj_data.put('descgroup', v_descgroup);
        obj_data.put('desc_forgroup', v_descgroup);

        begin
          select jobgrade into v_jobgrade
          from temploy1
          where codempid = r1.codempid;
        exception when no_data_found then
          v_jobgrade := '';
        end;
        obj_data.put('jobgrade', v_jobgrade);
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG', v_jobgrade, global_v_lang));
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
--    json_str_output := obj_row.to_clob;
    if v_flgData then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3008',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TNINEBOXE');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_report(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    p_zyear       number := 0;
    v_empall      number := 0;
    v_numseq      number := 0;
    v_amountemp   varchar(100 char);
    v_percntemp   varchar(100 char);
    v_item1		ttemprpt.item1%type;
    v_item2		ttemprpt.item2%type;
    v_item3		ttemprpt.item3%type;
    v_item4		ttemprpt.item4%type;
    v_item5		ttemprpt.item5%type;
    v_item6		ttemprpt.item6%type;
    v_item7		ttemprpt.item7%type;
    v_item8		ttemprpt.item8%type;
    v_item9		ttemprpt.item9%type;
    v_item10		ttemprpt.item10%type;
    v_item11		ttemprpt.item11%type;
    v_item12		ttemprpt.item12%type;
    v_item13		ttemprpt.item13%type;
    v_item14		ttemprpt.item14%type;
    v_item15		ttemprpt.item15%type;
    v_item16		ttemprpt.item16%type;
    v_item17		ttemprpt.item17%type;
    v_item18		ttemprpt.item18%type;
    v_item19		ttemprpt.item19%type;
    v_item20		ttemprpt.item20%type;
    v_item21		ttemprpt.item21%type;
    v_item22		ttemprpt.item22%type;
    v_dteeffec  tninebox.dteeffec%type;
    v_codcompy    tninebox.codcompy%type;
    v_dtechoose   tnineboxe.dtechoose%type;
    v_codchoose   tnineboxe.codchoose%type;
  begin
    initial_value(json_str_input);
    p_dteeffec  :=  to_date('31/12/'||to_char(b_index_year),'dd/mm/yyyy hh24:mi:ss');
      begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRRP6BX';
      end;
      begin
        select nvl(max(numseq) + 1,1) into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRRP6BX';
      exception when no_data_found then
        v_numseq := 1;
      end;
--      begin
--        select distinct(dteeffec) into v_dteeffec
--            from tninebox a
--           where b_index_codcomp like a.codcompy||'%'
--             and a.dteeffec = (select max(dteeffec)
--                                 from tninebox
--                                where codcompy = a.codcompy
--                                  and dteeffec <= p_dteeffec);
--      exception when no_data_found then
--        v_dteeffec := '';
--      end;
      begin
        select codcompy into v_codcompy
            from tninebox a
           where b_index_codcomp like a.codcompy||'%'
             and a.dteeffec = (select max(dteeffec)
                                 from tninebox
                                where codcompy = a.codcompy
                                  and dteeffec <= p_dteeffec)
             and rownum = 1;
      exception when no_data_found then
        v_codcompy := '';
      end;
      begin
        select dtechoose, codchoose into v_dtechoose, v_codchoose
          from tnineboxe
         where dteyear = b_index_year
           and codcompy = v_codcompy
           and codcomp like b_index_codcomp||'%'
           and dtechoose = (select max(dtechoose)
                              from tnineboxe
                             where dteyear = b_index_year
                               and codcompy = v_codcompy
                               and codcomp like b_index_codcomp||'%')
           and rownum = 1;
      exception when no_data_found then null;
      end;
      p_zyear := HCM_APPSETTINGS.get_additional_year;
      v_item1 := b_index_codcomp;
      v_item2 := b_index_year+p_zyear;
      v_item3 := to_char(add_months(v_dtechoose,p_zyear*12),'dd/mm/yyyy');
      v_item4 := v_codchoose || ' - ' || get_temploy_name(v_codchoose, global_v_lang);

      --9box 1
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 1, v_amountemp, v_percntemp);
      v_item9 := v_amountemp; v_item10 := v_percntemp;
      --9box 2
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 2, v_amountemp, v_percntemp);
      v_item7 := v_amountemp; v_item8 := v_percntemp;
      --9box 3
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 3, v_amountemp, v_percntemp);
      v_item5 := v_amountemp; v_item6 := v_percntemp;
      --9box 4
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 4, v_amountemp, v_percntemp);
      v_item15 := v_amountemp; v_item16 := v_percntemp;
      --9box 5
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 5, v_amountemp, v_percntemp);
      v_item13 := v_amountemp; v_item14 := v_percntemp;
      --9box 6
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 6, v_amountemp, v_percntemp);
      v_item11 := v_amountemp; v_item12 := v_percntemp;
      --9box 7
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 7, v_amountemp, v_percntemp);
      v_item21 := v_amountemp; v_item22 := v_percntemp;
      --9box 8
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 8, v_amountemp, v_percntemp);
      v_item19 := v_amountemp; v_item20 := v_percntemp;
      --9box 9
      get_data_box(b_index_year, b_index_codcomp, hcm_util.get_codcomp_level(b_index_codcomp, 1), 9, v_amountemp, v_percntemp);
      v_item17 := v_amountemp; v_item18 := v_percntemp;

      insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,
                            item5,item6,item7,item8,item9,item10,
                            item11,item12,item13,item14,item15,item16,
                            item17,item18,item19,item20,item21,item22)
           values (global_v_codempid, 'HRRP6BX',v_numseq,v_item1,v_item2,v_item3,v_item4,
                   v_item5,v_item6,v_item7,v_item8,v_item9,v_item10,
                   v_item11,v_item12,v_item13,v_item14,v_item15,v_item16,
                   v_item17,v_item18,v_item19,v_item20,v_item21,v_item22);
      v_numseq := v_numseq + 1;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRRP6BX;

/
