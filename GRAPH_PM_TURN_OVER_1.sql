--------------------------------------------------------
--  DDL for Package Body GRAPH_PM_TURN_OVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_PM_TURN_OVER" AS
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
    b_index_comgrp    := hcm_util.get_string_t(json_obj,'p_comgrp');
    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp')||'%';
    b_index_complvl   := hcm_util.get_string_t(json_obj,'p_complvl');
    b_index_codexam   := hcm_util.get_string_t(json_obj,'p_codexam');
    b_index_codpos    := hcm_util.get_string_t(json_obj,'p_codpos');
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
  function get_turn_over_summary(json_str_input clob) return clob is
    obj_row       json_object_t;
    v_qtyemp_f    number := 0;
    v_qtyemp_m    number := 0;

    cursor c_ttexempt is
      select a.codsex,count(*) qtyemp
        from ttexempt a,tcenter b
       where a.codcomp  = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and to_char(a.dteeffec,'yyyy') =  b_index_year
         and a.codexemp  = nvl(b_index_codexam,a.codexemp)
         and a.codpos   = nvl(b_index_codpos,a.codpos)
         and a.codsex   = nvl(b_index_codsex,a.codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
      group by a.codsex;

  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('female','0');
    obj_row.put('male','0');
    for r_ttexempt in c_ttexempt loop
      if r_ttexempt.codsex = 'F' then
        v_qtyemp_f := r_ttexempt.qtyemp;
        obj_row.put('female',to_char(r_ttexempt.qtyemp,'fm999,999,999,999,990'));
      elsif r_ttexempt.codsex = 'M' then
        v_qtyemp_m := r_ttexempt.qtyemp;
        obj_row.put('male',to_char(r_ttexempt.qtyemp,'fm999,999,999,999,990'));
      end if;
    end loop;
    obj_row.put('total',to_char(v_qtyemp_f + v_qtyemp_m,'fm999,999,999,999,990'));

    return obj_row.to_clob;
  end;
  --
  function get_turn_over_by_department(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_desc_codcomp  varchar2(4000 char);

    cursor c_ttexempt is
      select a.codcomp,count(*) qtyemp
        from ttexempt a,tcenter b
       where a.codcomp  = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and to_char(a.dteeffec,'yyyy') =  b_index_year
         and a.codexemp  = nvl(b_index_codexam,a.codexemp)
         and a.codpos   = nvl(b_index_codpos,a.codpos)
         and a.codsex   = nvl(b_index_codsex,a.codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
      group by a.codcomp
      order by a.codcomp;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_ttexempt in c_ttexempt loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r_ttexempt.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r_ttexempt.codcomp,global_v_lang));
      arr_datasets.append(r_ttexempt.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_turn_over_by_reason(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_ttexempt is
      select a.codexemp,count(*) qtyemp
        from ttexempt a,tcenter b
       where a.codcomp  = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and to_char(a.dteeffec,'yyyy') =  b_index_year
         and a.codexemp  = nvl(b_index_codexam,a.codexemp)
         and a.codpos   = nvl(b_index_codpos,a.codpos)
         and a.codsex   = nvl(b_index_codsex,a.codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
      group by a.codexemp
      order by a.codexemp;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_ttexempt in c_ttexempt loop
      arr_labels.append(r_ttexempt.codexemp||' : '||get_tcodec_name('TCODRETM',r_ttexempt.codexemp,global_v_lang));
      arr_datasets.append(r_ttexempt.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_turn_over_by_generation(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_strt        number;
    v_end         number;
    v_dtestrt     date;
    v_dteend      date;

    cursor c_ttexempt is
      select count(*) qtyemp
        from ttexempt a,temploy1 b,tcenter c
       where a.codempid = b.codempid(+)
         and a.codcomp  = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and to_char(a.dteeffec,'yyyy') =  b_index_year
         and a.codexemp  = nvl(b_index_codexam,a.codexemp)
         and a.codpos   = nvl(b_index_codpos,a.codpos)
         and a.codsex   = nvl(b_index_codsex,a.codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
         and dteempdb between v_dtestrt and v_dteend;
--         and floor(months_between(sysdate,dteempdb) /12) between v_strt and v_end;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    -- Baby boomer
    v_dtestrt := to_date('01/01/1000','dd/mm/yyyy');  v_dteend  := to_date('31/12/1964','dd/mm/yyyy');
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'50'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    -- Gen-X
    v_dtestrt := to_date('01/01/1965','dd/mm/yyyy');  v_dteend  := to_date('31/12/1979','dd/mm/yyyy');
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'60'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    -- Gen-Y
    v_dtestrt := to_date('01/01/1980','dd/mm/yyyy');  v_dteend  := to_date('31/12/1997','dd/mm/yyyy');
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'70'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    -- Gen-Z
    v_dtestrt := to_date('01/01/1998','dd/mm/yyyy');  v_dteend  := to_date('31/12/3000','dd/mm/yyyy');
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'80'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    /*v_strt := 60;  v_end  := 999;
    arr_labels.append('60 '||get_label_name('HRPMG1XC6',global_v_lang,'40'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    v_strt := 50;  v_end  := 59;
    arr_labels.append('50-59 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    v_strt := 40;  v_end  := 49;
    arr_labels.append('40-49 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    v_strt := 30;  v_end  := 39;
    arr_labels.append('30-39 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    v_strt := 20;  v_end  := 29;
    arr_labels.append('20-29 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;

    v_strt := 0;  v_end  := 19;
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'20')|| ' 20 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_ttexempt in c_ttexempt loop arr_datasets.append(r_ttexempt.qtyemp); end loop;*/

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_turn_over_by_month(json_str_input clob) return clob is
    obj_row         json_object_t;
    arr_labels      json_array_t;
    arr_datasets_m  json_array_t;
    arr_datasets_f  json_array_t;
    arr_data        json_array_t;
    v_month         number;
    v_emp_m         number := 0;
    v_emp_f         number := 0;

    cursor c_ttexempt is
      select to_char(a.dteeffec, 'mm') tmp_month,c.codsex,count(*) qtyemp
        from ttexempt a,tcenter b,temploy1 c
       where a.codcomp  = b.codcomp(+)
         and a.codempid = c.codempid(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and to_char(a.dteeffec,'yyyy') =  nvl(b_index_year,to_char(sysdate,'YYYY'))
         and to_char(a.dteeffec,'mm') =  v_month
         and a.codexemp  = nvl(b_index_codexam,a.codexemp)
         and a.codpos   = nvl(b_index_codpos,a.codpos)
         and a.codsex   = nvl(b_index_codsex,a.codsex)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
      group by to_char(a.dteeffec, 'mm'),c.codsex
      order by to_char(a.dteeffec, 'mm'),c.codsex;
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
      for r_ttexempt in c_ttexempt loop
        if r_ttexempt.codsex = 'M' then
          v_emp_m := r_ttexempt.qtyemp;
        elsif r_ttexempt.codsex = 'F' then
          v_emp_f := r_ttexempt.qtyemp;
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
end;

/
