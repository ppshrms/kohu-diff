--------------------------------------------------------
--  DDL for Package Body GRAPH_PM_EMPLOYEE_NEW_HIRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_PM_EMPLOYEE_NEW_HIRE" AS
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    --block b_index
    b_index_year      := hcm_util.get_string_t(json_obj,'p_year');
    b_index_month     := hcm_util.get_string_t(json_obj,'p_month');
    b_index_comgrp    := hcm_util.get_string_t(json_obj,'p_comgrp');
    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp')||'%';
    b_index_complvl   := hcm_util.get_string_t(json_obj,'p_complvl');
    b_index_codsex    := hcm_util.get_string_t(json_obj,'p_codsex');
    if b_index_codsex = '%' then
      b_index_codsex := null;
    end if;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    -- configuration
    conf_display_codcomp  := false;
    conf_defalut_complvl  := '2';

  end initial_value;
  --
  function get_employee_new_hire_summary(json_str_input clob) return clob is
    obj_row       json_object_t;
    v_qtyemp_f    number := 0;
    v_qtyemp_m    number := 0;

    cursor c_ttnewemp is
      select codsex,count(*) qtyemp
        from ttnewemp a,temploy1 b,tcenter c
       where a.codempid = b.codempid(+)
         and b.codcomp  = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and to_char(a.dteempmt,'mm') = decode(b_index_month,'A',to_char(a.dteempmt,'mm'),b_index_month)
         and to_char(a.dteempmt,'yyyy') =  b_index_year
         and codsex   = nvl(b_index_codsex,codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
      group by codsex;
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('female','0');
    obj_row.put('male','0');
    for r_ttnewemp in c_ttnewemp loop
      if r_ttnewemp.codsex = 'F' then
        v_qtyemp_f := r_ttnewemp.qtyemp;
        obj_row.put('female',to_char(r_ttnewemp.qtyemp,'fm999,999,999,999,990'));
      elsif r_ttnewemp.codsex = 'M' then
        v_qtyemp_m := r_ttnewemp.qtyemp;
        obj_row.put('male',to_char(r_ttnewemp.qtyemp,'fm999,999,999,999,990'));
      end if;
    end loop;
    obj_row.put('total',to_char(v_qtyemp_f + v_qtyemp_m,'fm999,999,999,999,990'));

    return obj_row.to_clob;
  end;
  --
  function get_employee_new_hire_by_month(json_str_input clob) return clob is
    obj_row         json_object_t;
    arr_labels      json_array_t;
    arr_datasets_m  json_array_t;
    arr_datasets_f  json_array_t;
    arr_data        json_array_t;
    v_month         number;
    v_emp_m         number := 0;
    v_emp_f         number := 0;

    cursor c_ttnewemp is
      select to_char(a.dteempmt, 'mm') tmp_month,b.codsex,count(*) qtyemp
        from ttnewemp a,temploy1 b,tcenter c
       where a.codempid = b.codempid(+)
         and a.codcomp  = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and to_char(a.dteempmt,'yyyy') = b_index_year
         and to_char(a.dteempmt,'mm')   = v_month
         and codsex   = nvl(b_index_codsex,codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
      group by to_char(a.dteempmt, 'mm'),b.codsex
      order by to_char(a.dteempmt, 'mm'),b.codsex;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets_m := json_array_t();
    arr_datasets_f := json_array_t();
    for i in 1..12 loop
      v_month := lpad(i,2,'0');
      v_emp_m := 0;
      v_emp_f := 0;
      for r_ttnewemp in c_ttnewemp loop
        if r_ttnewemp.codsex = 'M' then
          v_emp_m := r_ttnewemp.qtyemp;
        elsif r_ttnewemp.codsex = 'F' then
          v_emp_f := r_ttnewemp.qtyemp;
        end if;
      end loop;

      arr_labels.append(get_tlistval_name('DTEMTHPAY',to_char(i),global_v_lang));
      arr_datasets_m.append(v_emp_m);
      arr_datasets_f.append(v_emp_f);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets_m);
    arr_data.append(arr_datasets_f);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_employee_new_hire_by_department(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_desc_codcomp  varchar2(4000 char);

    cursor c_ttnewemp is
      select b.codcomp,count(*) qtyemp
        from ttnewemp a,temploy1 b,tcenter c
       where a.codempid = b.codempid(+)
         and a.codcomp  = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and to_char(a.dteempmt,'mm') = decode(b_index_month,'A',to_char(a.dteempmt,'mm'),b_index_month)
         and to_char(a.dteempmt,'yyyy') =  b_index_year
         and codsex   = nvl(b_index_codsex,codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
      group by b.codcomp
      order by b.codcomp;
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_ttnewemp in c_ttnewemp loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r_ttnewemp.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r_ttnewemp.codcomp,global_v_lang));
      arr_datasets.append(r_ttnewemp.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
end;

/
