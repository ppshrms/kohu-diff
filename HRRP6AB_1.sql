--------------------------------------------------------
--  DDL for Package Body HRRP6AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP6AB" as
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_year              := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');   
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');   
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteselect'),'dd/mm/yyyy');
    p_codselect         := hcm_util.get_string_t(json_obj,'p_codselect');
    p_codgroup          := hcm_util.get_string_t(json_obj,'p_codgroup');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    else
      begin
        select codcomp into v_codcomp
        from tcenter
        where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_codselect is not null then
      begin
        select staemp into v_staemp
        from temploy1
        where codempid = p_codselect;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgSecur := secur_main.secur2(p_codselect, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean;

    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_year          number;
    v_month         number;
    v_day           number;
    v_amount        number := 0;
    cursor c1 is
      select a.codgroup,a.namgroupt,a.descgroup,a.syncond,a.codcompy
        from tninebox a 
        where p_codcomp like codcompy||'%' 
        and dteeffec = (select max(dteeffec) 
                        from tninebox where codcompy = a.codcompy 
                        and dteeffec <= p_dteeffec)              
        order by codgroup;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('boxno', v_rcnt);
      obj_data.put('year', p_year);
      obj_data.put('codgroup', r1.codgroup);
      obj_data.put('namgroupt', r1.namgroupt);
      obj_data.put('descgroup', r1.descgroup);
      obj_data.put('desc_forgroup', r1.descgroup);
      obj_data.put('syncond', r1.syncond);
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('codcomp', p_codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(get_compful(p_codcomp), global_v_lang));
      obj_data.put('dteselect', to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_data.put('codselect', p_codselect);
      obj_data.put('desc_codselect', get_temploy_name(p_codselect, global_v_lang));
      begin
        select count(codempid) into v_amount
        from tnineboxe
       where dteyear   = p_year
         and codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
         and codgroup = r1.codgroup
         and staappr = 'P';
      end;
      obj_data.put('amount', v_amount);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if param_msg_error is null then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TNINEBOX');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
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

  procedure gen_detail1(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean;

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
      select codempid,agework,codgroup,codcomp,codpos
        from tnineboxe 
       where dteyear = p_year 
         and codcompy = p_codcompy
         and codgroup = p_codgroup 
         and staappr = 'P'
       order by codempid;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      if secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('empid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('agework', r1.agework);
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        obj_data.put('codgroup', r1.codgroup);
        begin
          select codgroup,namgroupt,descgroup into v_codgroup,v_namgroupt,v_descgroup
            from tninebox
           where codcompy = hcm_util.get_codcomp_level(p_codcompy,1)
             and codgroup = p_codgroup
             and dteeffec = (select max(dteeffec) 
                               from tninebox 
                              where codcompy = hcm_util.get_codcomp_level(p_codcompy,1)
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
--    
  json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_detail1(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure check_approve is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codselect is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;
  procedure post_process(json_str_input in clob, json_str_output out clob) as
    json_obj      json_object_t;
    obj_data      json_object_t;

    v_dteappr     date;
    v_approvno    number;
    v_codempid    temploy1.codempid%type;
    v_codcomp     ttalente.codcomp%type;
    v_codcompe    ttalente.codcomp%type;
    v_codappr     ttalente.codempid%type;
    v_approve     ttalente.remarkap%type;
    v_notapprove  ttalente.remarkap%type;
    v_remark      ttalente.remarkap%type;
    v_dteselect   date;

    v_staappr     ttalente.staappr%type;
    v_flgAppr     boolean;
    p_check       varchar2(10 char);
    v_error_sendmail       varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_approve;
    if param_msg_error is null then
      gen_emp9box(p_codcomp, p_year, p_dteeffec, p_codselect);
    end if;
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

  procedure gen_emp9box(p_codcomp varchar, p_dteyear number, p_dteappr date, p_codappr varchar) is
    v_codcompy      tninebox.codcompy%type := hcm_util.get_codcomp_level(p_codcomp,1);
    v_cursor_main   number;
    v_cursor_query  number;
    v_dummy         integer;
    v_stmt          varchar2(4000);
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    qtyempmt        number(10);

    cursor c_tninebox is
      select codcompy,codgroup,syncond
        from tninebox a
       where codcompy   = v_codcompy
         and dteeffec   = (select max(dteeffec)
                             from tninebox b
                            where b.codcompy   = a.codcompy
                              and dteeffec    <= p_dteappr)
    order by codgroup;

  begin
    delete tnineboxe
     where dteyear   = p_dteyear
       and codcompy  = v_codcompy
       and staappr = 'P';

    for r1 in c_tninebox loop  
      v_stmt := '   select codempid,agework '||
                '     from v_rp_emp '||
                '    where codcomp   like '''||p_codcomp||'%'' '||
                '      and staemp    in (''1'',''3'') '||
                '      and not exists (select codempid '||
                '                        from tnineboxe b '||
                '                       where dteyear    = '||p_dteyear ||
                '                         and codcompy   = hcm_util.get_codcomp_level(v_rp_emp.codcomp,1) '||
                '                         and b.codempid = v_rp_emp.codempid) '||
                '      and '||r1.syncond ||
	              ' order by codempid';

      v_cursor_main   := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor_main,v_stmt,dbms_sql.native);
      dbms_sql.define_column(v_cursor_main,1,v_codempid,100);
      dbms_sql.define_column(v_cursor_main,2,qtyempmt);
      v_dummy := dbms_sql.execute(v_cursor_main);

      while (dbms_sql.fetch_rows(v_cursor_main) > 0) loop
        dbms_sql.column_value(v_cursor_main,1,v_codempid);
        dbms_sql.column_value(v_cursor_main,2,qtyempmt);
        if secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
          begin
            select codcomp, codpos into v_codcomp, v_codpos
            from temploy1
            where codempid = v_codempid;
          exception when no_data_found then
            null;
          end;
          begin
            insert into tnineboxe(dteyear,codcompy,codgroup,codempid,codcomp,codpos,
                                  agework,staappr,approvno,dtechoose,codchoose,
                                  dtecreate,codcreate,coduser)
                           values(p_dteyear,r1.codcompy,r1.codgroup,v_codempid,v_codcomp, v_codpos,
                                  qtyempmt, 'P', 0, p_dteeffec, p_codselect,
                                  sysdate,global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then null;
          end;
        end if;              
      end loop;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure gen_after_process(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean;

    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_year          number;
    v_month         number;
    v_day           number;
    v_amount        number := 0;
    cursor c1 is
      select a.codgroup,a.namgroupt,a.descgroup,a.syncond,a.codcompy
        from tninebox a 
        where p_codcomp like codcompy||'%' 
        and dteeffec = (select max(dteeffec) 
                        from tninebox where codcompy = a.codcompy 
                        and dteeffec <= p_dteeffec)              
        order by codgroup;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('boxno', v_rcnt);
      obj_data.put('year', p_year);
      obj_data.put('codgroup', r1.codgroup);
      obj_data.put('namgroupt', r1.namgroupt);
      obj_data.put('descgroup', r1.descgroup);
      obj_data.put('desc_forgroup', r1.descgroup);
      obj_data.put('syncond', r1.syncond);
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('codcomp', p_codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(get_compful(p_codcomp), global_v_lang));
      obj_data.put('dteselect', to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_data.put('codselect', p_codselect);
      obj_data.put('desc_codselect', get_temploy_name(p_codselect, global_v_lang));
      begin
        select count(codempid) into v_amount
        from tnineboxe
       where dteyear   = p_year
         and codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
         and codgroup = r1.codgroup
         and staappr = 'P';
      end;
      obj_data.put('amount', v_amount);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

  json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_after_process(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    gen_after_process(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hrrp6ab;

/
