--------------------------------------------------------
--  DDL for Package Body GRAPH_PM_HEADCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_PM_HEADCOUNT" AS
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
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');
    b_index_month       := hcm_util.get_string_t(json_obj,'p_month');
    b_index_comgrp      := hcm_util.get_string_t(json_obj,'p_comgrp');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp')||'%';
    b_index_complvl     := hcm_util.get_string_t(json_obj,'p_complvl');
    b_index_codempmt    := hcm_util.get_string_t(json_obj,'p_codempmt');
    b_index_codjobgrade := hcm_util.get_string_t(json_obj,'p_codjobgrade');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    b_index_codsex      := hcm_util.get_string_t(json_obj,'p_codsex');
    if b_index_codsex = '%' then
      b_index_codsex := null;
    end if;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  function get_headcount_summary(json_str_input clob) return clob is
    obj_row       json_object_t;
    obj_typemp    json_object_t;
    arr_typemp    json_array_t;
    v_sum         number := 0;

    cursor c_temploy1 is
      select codempmt,get_tcodec_name('tcodempl',codempmt,global_v_lang) desc_codempmt,count(*) qtyemp
        from temploy1 a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and codempmt   = nvl(b_index_codempmt,codempmt)
         and jobgrade   = nvl(b_index_codjobgrade,jobgrade)
         and codpos     = nvl(b_index_codpos,codpos)
         and codsex     = nvl(b_index_codsex,codsex)
         and staemp     in ('1', '3')
      group by codempmt
      order by codempmt;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    obj_row.put('coderror','200');

    arr_typemp := json_array_t();
    for r_temploy1 in c_temploy1 loop
      obj_typemp := json_object_t();
      obj_typemp.put('name',r_temploy1.desc_codempmt);
      obj_typemp.put('amount',to_char(r_temploy1.qtyemp,'fm999,999,999,999,990'));
      arr_typemp.append(obj_typemp);
      v_sum := v_sum + r_temploy1.qtyemp;
    end loop;
    obj_row.put('total',to_char(v_sum,'fm999,999,999,999,990'));
    obj_row.put('typemp',arr_typemp);
    return obj_row.to_clob;
  end;
  --
  function get_headcount_by_jobgrade(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_temploy1 is
      select jobgrade,count(*) qtyemp
        from temploy1 a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and codempmt   = nvl(b_index_codempmt,codempmt)
         and jobgrade   = nvl(b_index_codjobgrade,jobgrade)
         and codpos     = nvl(b_index_codpos,codpos)
         and codsex     = nvl(b_index_codsex,codsex)
         and staemp     in ('1', '3')
      group by jobgrade
      order by jobgrade;
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_temploy1 in c_temploy1 loop
      arr_labels.append(r_temploy1.jobgrade||' : '||get_tcodec_name('TCODJOBG',r_temploy1.jobgrade,global_v_lang));
      arr_datasets.append(r_temploy1.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_headcount_by_gender(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_temploy1 is
      select codsex,count(*) qtyemp
        from temploy1 a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and codempmt   = nvl(b_index_codempmt,codempmt)
         and jobgrade   = nvl(b_index_codjobgrade,jobgrade)
         and codpos     = nvl(b_index_codpos,codpos)
         and codsex     = nvl(b_index_codsex,codsex)
         and staemp     in ('1', '3')
      group by codsex
      order by codsex;
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_temploy1 in c_temploy1 loop
      arr_labels.append(r_temploy1.codsex||' : '||get_tlistval_name('NAMSEX',r_temploy1.codsex,global_v_lang));
      arr_datasets.append(r_temploy1.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_headcount_by_range_age(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_strt        number;
    v_end         number;
    v_dtestrt     date;
    v_dteend      date;

    cursor c_temploy1 is
      select count(*) qtyemp
        from temploy1 a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and codempmt   = nvl(b_index_codempmt,codempmt)
         and jobgrade   = nvl(b_index_codjobgrade,jobgrade)
         and codpos     = nvl(b_index_codpos,codpos)
         and codsex     = nvl(b_index_codsex,codsex)
         and staemp     in ('1', '3')
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
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    -- Gen-X
    v_dtestrt := to_date('01/01/1965','dd/mm/yyyy');  v_dteend  := to_date('31/12/1979','dd/mm/yyyy');
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'60'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    -- Gen-Y
    v_dtestrt := to_date('01/01/1980','dd/mm/yyyy');  v_dteend  := to_date('31/12/1997','dd/mm/yyyy');
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'70'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    -- Gen-Z
    v_dtestrt := to_date('01/01/1998','dd/mm/yyyy');  v_dteend  := to_date('31/12/3000','dd/mm/yyyy');
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'80'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    /*v_strt := 0;  v_end  := 17;
    arr_labels.append(get_label_name('HRPMG1XC6',global_v_lang,'20')|| ' 18 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_strt := 18; v_end  := 25;
    arr_labels.append('18-25 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_strt := 26; v_end  := 30;
    arr_labels.append('26-30 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_strt := 31; v_end  := 40;
    arr_labels.append('31-40 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_strt := 41; v_end  := 50;
    arr_labels.append('41-50 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_strt := 51; v_end  := 55;
    arr_labels.append('51-55 '||get_label_name('HRPMG1XC6',global_v_lang,'30'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_strt := 56; v_end  := 999;
    arr_labels.append('56 '||get_label_name('HRPMG1XC6','102','40'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;*/

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_headcount_by_company(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_temploy1 is
      select hcm_util.get_codcomp_level(a.codcomp,1) tmp_codcompy,count(*) qtyemp
        from temploy1 a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and codempmt = nvl(b_index_codempmt,codempmt)
         and jobgrade = nvl(b_index_codjobgrade,jobgrade)
         and codpos   = nvl(b_index_codpos,codpos)
         and codsex   = nvl(b_index_codsex,codsex)
         and staemp in ('1', '3')
      group by hcm_util.get_codcomp_level(a.codcomp,1)
      order by hcm_util.get_codcomp_level(a.codcomp,1);
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_temploy1 in c_temploy1 loop
      arr_labels.append(r_temploy1.tmp_codcompy||' : '||get_tcenter_name(r_temploy1.tmp_codcompy,global_v_lang));
      arr_datasets.append(r_temploy1.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_headcount_by_branch(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_temploy1 is
      select codbrlc,count(*) qtyemp
        from temploy1 a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and codempmt   = nvl(b_index_codempmt,codempmt)
         and jobgrade   = nvl(b_index_codjobgrade,jobgrade)
         and codpos     = nvl(b_index_codpos,codpos)
         and codsex     = nvl(b_index_codsex,codsex)
         and staemp     in ('1', '3')
      group by codbrlc
      order by codbrlc;
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_temploy1 in c_temploy1 loop
      arr_labels.append(r_temploy1.codbrlc||' : '||get_tcodec_name('TCODLOCA',r_temploy1.codbrlc,global_v_lang));
      arr_datasets.append(r_temploy1.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_headcount_by_department(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_temploy1 is
      select hcm_util.get_codcomp_level(b.codcomp,b_index_complvl) as comp_by_level,count(*) qtyemp
        from temploy1 a,tcenter b,tusrcom c
       where a.codcomp  like hcm_util.get_codcomp_level(b.codcomp,b_index_complvl)||'%'
         and b.codcomp  like c.codcomp||'%'
         and b.comlevel = nvl(b_index_complvl,b.comlevel)
         and c.coduser  = global_v_coduser
         and staemp     in ('1', '3')
      group by hcm_util.get_codcomp_level(b.codcomp,b_index_complvl)
      order by comp_by_level;
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_temploy1 in c_temploy1 loop
--      arr_labels.append(r_temploy1.comp_by_level||' : '||get_tcenter_name(r_temploy1.comp_by_level,global_v_lang));
      arr_labels.append(r_temploy1.comp_by_level);
      arr_datasets.append(r_temploy1.qtyemp);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_headcount_by_service_year(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
		v_year_start	number;
		v_year_end	  number;

    cursor c_temploy1 is
      select count(*) qtyemp
        from temploy1 a,tcenter b
       where a.codcomp = b.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp  like b_index_codcomp
--         and (b_index_complvl is null or b.comlevel = nvl(b_index_complvl,b.comlevel))
         and codempmt   = nvl(b_index_codempmt,codempmt)
         and jobgrade   = nvl(b_index_codjobgrade,jobgrade)
         and codpos     = nvl(b_index_codpos,codpos)
         and codsex     = nvl(b_index_codsex,codsex)
         and staemp     in ('1', '3')
				 and months_between(sysdate,DTEEMPMT)/12 >= v_year_start and months_between(sysdate,DTEEMPMT)/12 < v_year_end;
--      group by trunc(months_between(sysdate,DTEEMPMT)/12)
--      order by trunc(months_between(sysdate,DTEEMPMT)/12);
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    v_year_start := 0;  v_year_end  := 1;
    arr_labels.append('< 1 '||get_label_name('HRPMG1XC9',global_v_lang,'20'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_year_start := 1;  v_year_end  := 2;
    arr_labels.append('1 '||get_label_name('HRPMG1XC9',global_v_lang,'20'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_year_start := 2;  v_year_end  := 3;
    arr_labels.append('2 '||get_label_name('HRPMG1XC9',global_v_lang,'20'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_year_start := 3;  v_year_end  := 4;
    arr_labels.append('3 '||get_label_name('HRPMG1XC9',global_v_lang,'20'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_year_start := 4;  v_year_end  := 5;
    arr_labels.append('4 '||get_label_name('HRPMG1XC9',global_v_lang,'20'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_year_start := 5;  v_year_end  := 6;
    arr_labels.append('5 '||get_label_name('HRPMG1XC9',global_v_lang,'20'));
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    v_year_start := 6;  v_year_end  := 100;
    arr_labels.append('6 '||get_label_name('HRPMG1XC9',global_v_lang,'20')||' +');
    for r_temploy1 in c_temploy1 loop arr_datasets.append(r_temploy1.qtyemp); end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
end;

/
