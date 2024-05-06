--------------------------------------------------------
--  DDL for Package Body HRBFG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFG1X" as
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
    b_index_typdata     := hcm_util.get_string_t(json_obj,'p_flgtype');
    b_index_comlevel    := hcm_util.get_string_t(json_obj,'p_complvl');

    b_index_dteyear     := nvl(b_index_dteyear,to_char(sysdate,'yyyy'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure gen_accumulated_benefit(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_qty       json_array_t;
    array_data      json_array_t;

    cursor c1 is
      select a.codobf,count(distinct b.codempid) qtyemp,sum(decode(typebf,'T',a.qtywidrw * c.amtvalue,'C',a.amtwidrw)) as sumamt
        from tobfsum a,temploy1 b,tobfcde c
       where b.codcomp like hcm_util.get_codcomp_level(b_index_codcomp,null) || '%'
         and a.dteyre     = b_index_dteyear
         and a.codempid   = b.codempid
         and a.codobf     = c.codobf
         and b.numlvl between global_v_zminlvl and global_v_zwrklvl
         and exists (select 1
                      from tusrcom us
                     where b.codcomp    like us.codcomp||'%'
                       and us.coduser   = global_v_coduser)
      group by a.codobf
      order by a.codobf;

  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty     := json_array_t();

    for r1 in c1 loop
      array_label.append(get_tobfcde_name(r1.codobf,global_v_lang));
      if b_index_typdata = '1' then
        array_qty.append(r1.qtyemp);
      else
        array_qty.append(r1.sumamt);
      end if;
    end loop;

    array_data := json_array_t();
    array_data.append(array_qty);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_accumulated_benefit(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_accumulated_benefit(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_expense_by_department(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_dataset   json_array_t;
    array_data      json_array_t;
    v_daybfst       tcontrbf.daybfst%type;
    v_mthbfst       tcontrbf.mthbfst%type;
    v_dtebfst       date;
    v_dtebfen       date;

    cursor c1 is
      select codcomp, sum(nvl(amtalw,0)) sum_amtalw
        from (select hcm_util.get_codcomp_level(codcomp,b_index_comlevel) as codcomp,amtalw
                from tclnsinf
               where codcomp like b_index_codcompy||'%'
                 and dtebill between v_dtebfst and v_dtebfen
                 and exists (select 1
                               from temploy1 emp
                              where emp.codempid  = tclnsinf.codempid
                                and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
                 and exists (select 1
                               from tusrcom us
                              where tclnsinf.codcomp like us.codcomp||'%'
                                and us.coduser       = global_v_coduser))
      group by codcomp
      order by codcomp;

  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_dataset := json_array_t();

    begin
      select daybfst,mthbfst into v_daybfst, v_mthbfst
        from tcontrbf
       where codcompy   = b_index_codcompy
         and dteeffec   = (select max(dteeffec)
                             from tcontrbf
                            where codcompy = b_index_codcompy
                              and dteeffec <= sysdate);
    exception when no_data_found then
      v_daybfst := 1; v_mthbfst := 1;
    end;

    v_dtebfst   := to_date(v_daybfst||'/'||v_mthbfst||'/'||b_index_dteyear,'dd/mm/yyyy');
    v_dtebfen   := add_months(v_dtebfst,12) - 1;

    for r1 in c1 loop
      array_label.append(r1.codcomp);
      array_dataset.append(r1.sum_amtalw);
    end loop;
    array_data    := json_array_t();
    array_data.append(array_dataset);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_expense_by_department(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_expense_by_department(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_expense_by_month(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_dataset   json_array_t;
    array_data      json_array_t;
    v_daybfst       tcontrbf.daybfst%type;
    v_mthbfst       tcontrbf.mthbfst%type;
    v_dtebfst       date;
    v_dtebfen       date;

    cursor c1 is
      select month_bill, sum(nvl(amtalw,0)) sum_amtalw
        from (select to_char(dtebill,'mm') as month_bill,amtalw
                from tclnsinf
               where codcomp like hcm_util.get_codcomp_level(b_index_codcomp,null)||'%'
                 and dtebill between v_dtebfst and v_dtebfen
                 and exists (select 1
                               from temploy1 emp
                              where emp.codempid  = tclnsinf.codempid
                                and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
                 and exists (select 1
                               from tusrcom us
                              where tclnsinf.codcomp like us.codcomp||'%'
                                and us.coduser       = global_v_coduser))
      group by month_bill
      order by month_bill;

  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_dataset := json_array_t();

    begin
      select daybfst,mthbfst into v_daybfst, v_mthbfst
        from tcontrbf
       where codcompy   = hcm_util.get_codcomp_level(b_index_codcomp,1)
         and dteeffec   = (select max(dteeffec)
                             from tcontrbf
                            where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
                              and dteeffec <= sysdate);
    exception when no_data_found then
      v_daybfst := 1; v_mthbfst := 1;
    end;

    v_dtebfst   := to_date(v_daybfst||'/'||v_mthbfst||'/'||b_index_dteyear,'dd/mm/yyyy');
    v_dtebfen   := add_months(v_dtebfst,12) - 1;

    for r1 in c1 loop
      array_label.append(get_tlistval_name('NAMMTHFUL',to_number(r1.month_bill),global_v_lang));
      array_dataset.append(r1.sum_amtalw);
    end loop;
    array_data    := json_array_t();
    array_data.append(array_dataset);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_expense_by_month(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_expense_by_month(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_top_ten_diseases_expense(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_header      json_object_t;
    obj_output      json_object_t;
    v_daybfst       tcontrbf.daybfst%type;
    v_mthbfst       tcontrbf.mthbfst%type;
    v_dtebfst       date;
    v_dtebfen       date;
    v_rcnt          number := 0;
    v_sum_emp       number := 0;

    cursor c1 is
      select coddc,qtyemp
        from (select a.coddc, count(distinct a.codempid) qtyemp
                from tclnsinf a ,tdcinf b
               where 1 = 1
                 and a.codcomp  like b_index_codcompy||'%'
                 and a.dtebill  between v_dtebfst and v_dtebfen
                 and exists (select 1
                               from temploy1 emp
                              where emp.codempid  = a.codempid
                                and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
                 and exists (select 1
                               from tusrcom us
                              where a.codcomp   like us.codcomp||'%'
                                and us.coduser  = global_v_coduser)
              group by a.coddc
              order by qtyemp desc)
       where rownum <= 10;
  begin

    begin
      select daybfst,mthbfst into v_daybfst, v_mthbfst
        from tcontrbf
       where codcompy   = b_index_codcompy
         and dteeffec   = (select max(dteeffec)
                             from tcontrbf
                            where codcompy = b_index_codcompy
                              and dteeffec <= sysdate);
    exception when no_data_found then
      v_daybfst := 1; v_mthbfst := 1;
    end;

    v_dtebfst   := to_date(v_daybfst||'/'||v_mthbfst||'/'||b_index_dteyear,'dd/mm/yyyy');
    v_dtebfen   := add_months(v_dtebfst,12) - 1;
    obj_row     := json_object_t();
    for r1 in c1 loop
      obj_data      := json_object_t();
      obj_data.put('qtycount', r1.qtyemp);
      obj_data.put('coddc', r1.coddc);
      obj_data.put('desc_coddc', get_tcodec_name('TDCINF',r1.coddc,global_v_lang));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
      v_sum_emp   := v_sum_emp + r1.qtyemp;
    end loop;
    obj_header  := json_object_t();
    obj_header.put('valuemax',v_sum_emp);

    obj_output  := json_object_t();
    obj_output.put('coderror','200');
    obj_output.put('header',obj_header);
    obj_output.put('table',obj_row);

    json_str_output   := obj_output.to_clob;
  end;
  --
  procedure get_top_ten_diseases_expense(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_top_ten_diseases_expense(json_str_output);
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
