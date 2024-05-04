--------------------------------------------------------
--  DDL for Package Body GRAPH_PM_EMPLOYEE_MOVEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_PM_EMPLOYEE_MOVEMENT" AS
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
    b_index_codtrn    := hcm_util.get_string_t(json_obj,'p_codtrn');
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
  function get_employee_movement_summary(json_str_input clob) return clob is
    obj_row         json_object_t;

    cursor c_ttmovemt is
      select codsex,count(*) qtyemp
        from ttmovemt a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and to_char(a.dteeffec,'mm') = decode(b_index_month,'A',to_char(a.dteeffec,'mm'),b_index_month)
         and to_char(a.dteeffec,'yyyy') =  b_index_year
         and codtrn   = nvl(b_index_codtrn,codtrn)
         and codsex   = nvl(b_index_codsex,codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, codempid) = 'Y'
      group by codsex;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('female','0');
    obj_row.put('male','0');
    for r_ttmovemt in c_ttmovemt loop
      if r_ttmovemt.codsex = 'F' then
        obj_row.put('female',to_char(r_ttmovemt.qtyemp,'fm999,999,999,999,990'));
      elsif r_ttmovemt.codsex = 'M' then
        obj_row.put('male',to_char(r_ttmovemt.qtyemp,'fm999,999,999,999,990'));
      end if;
    end loop;

    return obj_row.to_clob;
  end;
  --
  function get_employee_movement_by_movement(json_str_input clob) return clob is
    obj_row         json_object_t;
    arr_labels      json_array_t;
    arr_datasets_m  json_array_t;
    arr_datasets_f  json_array_t;
    arr_data        json_array_t;
    v_codtrn        ttmovemt.codtrn%type;
    v_codcomp       temploy1.codcomp%type;
    v_emp_m         number := 0;
    v_emp_f         number := 0;
    v_loop          number := 0;

    cursor c_ttmovemt is
      select codtrn,codsex,count(*) qtyemp
        from ttmovemt a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and to_char(a.dteeffec,'mm') = decode(b_index_month,'A',to_char(a.dteeffec,'mm'),b_index_month)
         and to_char(a.dteeffec,'yyyy') =  b_index_year
         and codtrn   = nvl(b_index_codtrn,codtrn)
         and codsex   = nvl(b_index_codsex,codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, codempid) = 'Y'
      group by codtrn,codsex
      order by codtrn,codsex;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets_m := json_array_t();
    arr_datasets_f := json_array_t();

    v_codtrn := '#$%';
    if b_index_codcomp is not null then
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid     = global_v_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    for r_ttmovemt in c_ttmovemt loop
      v_loop := v_loop + 1;
      if v_codtrn <> r_ttmovemt.codtrn then
        arr_labels.append(r_ttmovemt.codtrn||' : '||get_tcodec_name('TCODMOVE',r_ttmovemt.codtrn,global_v_lang));
        if v_loop > 1 then
          arr_datasets_m.append(v_emp_m);
          arr_datasets_f.append(v_emp_f);
        end if;
        v_emp_m := 0;
        v_emp_f := 0;
      end if;
      v_codtrn := r_ttmovemt.codtrn;
      if r_ttmovemt.codsex = 'M' then
        v_emp_m := r_ttmovemt.qtyemp;
      elsif r_ttmovemt.codsex = 'F' then
        v_emp_f := r_ttmovemt.qtyemp;
      end if;
    end loop;

    if v_loop > 0 then -- for last datasets
      arr_datasets_m.append(v_emp_m);
      arr_datasets_f.append(v_emp_f);
    end if;

    arr_data := json_array_t();
    arr_data.append(arr_datasets_m);
    arr_data.append(arr_datasets_f);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_employee_movement_by_department(json_str_input clob) return clob is
    obj_row         json_object_t;
    arr_labels      json_array_t;
    arr_datasets    json_array_t;
    arr_data        json_array_t;
    v_desc_codcomp  varchar2(4000 char);

    cursor c_ttmovemt is
      select a.codcomp,count(*) qtyemp
        from ttmovemt a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and to_char(a.dteeffec,'mm') = decode(b_index_month,'A',to_char(a.dteeffec,'mm'),b_index_month)
         and to_char(a.dteeffec,'yyyy') =  b_index_year
         and codtrn   = nvl(b_index_codtrn,codtrn)
         and codsex   = nvl(b_index_codsex,codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, codempid) = 'Y'
      group by a.codcomp
      order by a.codcomp;
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_ttmovemt in c_ttmovemt loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r_ttmovemt.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r_ttmovemt.codcomp,global_v_lang));
      arr_datasets.append(r_ttmovemt.qtyemp);
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
