--------------------------------------------------------
--  DDL for Package Body GRAPH_PY_COMPENSATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_PY_COMPENSATION" AS
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
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
    b_index_typpayroll  := hcm_util.get_string_t(json_obj,'p_typpayroll');
    b_index_codpay      := hcm_util.get_string_t(json_obj,'p_codpay');
    b_index_codtypemp   := hcm_util.get_string_t(json_obj,'p_codtypemp');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    -- configuration
    conf_display_codcomp  := false;
    conf_defalut_complvl  := '2';

  end initial_value;
  --
  function get_compensation_summary(json_str_input clob) return clob is
    obj_row       json_object_t;
    obj_typ       json_object_t;
    arr_typ       json_array_t;
    v_secur   	  boolean := true;
    v_sum         number := 0;

    cursor c_tsincexp is
      select a.typpayroll,
             sum(nvl(stddec(amtincom1,a.codempid,v_chken),0)) sum_amtincom1
        from ttaxcur a,temploy1 b,tcenter c
       where a.codempid  = b.codempid(+)
         and a.codcomp   = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp   like b_index_codcomp
         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and a.dtemthpay = decode(b_index_month,'A',a.dtemthpay,b_index_month)
         and a.dteyrepay = b_index_year
         and a.typpayroll= nvl(b_index_typpayroll,a.typpayroll)
         and a.typemp    = nvl(b_index_codtypemp,a.typemp)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
         and b.numlvl    between global_v_numlvlsalst and global_v_numlvlsalen
      group by a.typpayroll
      order by a.typpayroll;

  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    obj_row.put('coderror','200');

    arr_typ := json_array_t();
    for r_tsincexp in c_tsincexp loop
      obj_typ := json_object_t();
      obj_typ.put('name',get_tcodec_name('tcodtypy',r_tsincexp.typpayroll,global_v_lang));
      obj_typ.put('amount',to_char(r_tsincexp.sum_amtincom1,'fm999,999,999,999,999,999,999,999,999,990.90'));
      arr_typ.append(obj_typ);
      v_sum := v_sum + r_tsincexp.sum_amtincom1;
    end loop;

    obj_row.put('total',to_char(v_sum,'fm999,999,999,999,999,999,999,999,999,990.90'));
    obj_row.put('typpayroll',arr_typ);
    return obj_row.to_clob;
  end;
  --
  function get_compensation_by_typpayroll(json_str_input clob) return clob is
    obj_row               json_object_t;
    arr_labels            json_array_t;
    arr_data              json_array_t;
    arr_datasets_inc      json_array_t;
    arr_datasets_othinc   json_array_t;
    arr_datasets_ded      json_array_t;
    arr_datasets_tax      json_array_t;

    cursor c_tsincexp is
      select a.typpayroll,
             sum(decode(typincexp,'1',nvl(stddec(amtpay,a.codempid,2017),0))) + sum(decode(typincexp,'2',nvl(stddec(amtpay,a.codempid,2017),0))) inc,
             sum(decode(typincexp,'3',nvl(stddec(amtpay,a.codempid,2017),0))) othinc,
             sum(decode(typincexp,'4',nvl(stddec(amtpay,a.codempid,2017),0))) + sum(decode(typincexp,'5',nvl(stddec(amtpay,a.codempid,2017),0))) ded,
             sum(decode(typincexp,'6',nvl(stddec(amtpay,a.codempid,2017),0))) tax
        from tsincexp a,temploy1 b,tcenter c
       where a.codempid  = b.codempid(+)
         and a.codcomp   = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp   like b_index_codcomp
         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and a.dtemthpay = decode(b_index_month,'A',a.dtemthpay,b_index_month)
         and a.dteyrepay = b_index_year
         and a.typpayroll= nvl(b_index_typpayroll,a.typpayroll)
         and a.typemp    = nvl(b_index_codtypemp,a.typemp)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
         and b.numlvl    between global_v_numlvlsalst and global_v_numlvlsalen
      group by a.typpayroll
      order by a.typpayroll;
  begin
    initial_value(json_str_input);
    obj_row               := json_object_t();
    arr_labels            := json_array_t();
    arr_datasets_inc      := json_array_t();
    arr_datasets_othinc   := json_array_t();
    arr_datasets_ded      := json_array_t();
    arr_datasets_tax      := json_array_t();
    for r_tsincexp in c_tsincexp loop
      arr_labels.append(get_tcodec_name('tcodtypy',r_tsincexp.typpayroll,global_v_lang));
      arr_datasets_inc.append(nvl(to_char(r_tsincexp.inc,'fm999999999990.90'),0));
      arr_datasets_othinc.append(nvl(to_char(r_tsincexp.othinc,'fm999999999990.90'),0));
      arr_datasets_ded.append(nvl(to_char(r_tsincexp.ded,'fm999999999990.90'),0));
      arr_datasets_tax.append(nvl(to_char(r_tsincexp.tax,'fm999999999990.90'),0));
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets_inc);
    arr_data.append(arr_datasets_othinc);
    arr_data.append(arr_datasets_ded);
    arr_data.append(arr_datasets_tax);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_compensation_by_department(json_str_input clob) return clob is
    obj_row         json_object_t;
    arr_labels      json_array_t;
    arr_datasets    json_array_t;
    arr_data        json_array_t;
    v_desc_codcomp  varchar2(4000 char);

    cursor c_tsincexp is
      select a.codcomp,sum(nvl(stddec(amtnet,a.codempid,v_chken),0)) sum_amtnet
        from ttaxcur a,temploy1 b,tcenter c
       where a.codempid  = b.codempid(+)
         and a.codcomp   = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp   like b_index_codcomp
         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and a.dtemthpay = decode(b_index_month,'A',a.dtemthpay,b_index_month)
         and a.dteyrepay = b_index_year
         and a.typpayroll= nvl(b_index_typpayroll,a.typpayroll)
         and a.typemp    = nvl(b_index_codtypemp,a.typemp)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
         and b.numlvl    between global_v_numlvlsalst and global_v_numlvlsalen
      group by a.codcomp
      order by a.codcomp;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r_tsincexp in c_tsincexp loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r_tsincexp.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r_tsincexp.codcomp,global_v_lang));
      arr_datasets.append(to_char(r_tsincexp.sum_amtnet,'fm999999999990.90'));
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_compensation_by_month(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_month       number;
    v_sum_amtpay  number;

    cursor c_tsincexp is
      select sum(nvl(stddec(amtnet,a.codempid,v_chken),0)) sum_amtnet
        from ttaxcur a,temploy1 b,tcenter c
       where a.codempid  = b.codempid(+)
         and a.codcomp   = c.codcomp(+)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and a.codcomp   like b_index_codcomp
         and (b_index_complvl is null or c.comlevel = nvl(b_index_complvl,c.comlevel))
         and a.dtemthpay = v_month
         and a.dteyrepay = b_index_year
         and a.typpayroll= nvl(b_index_typpayroll,a.typpayroll)
         and a.typemp    = nvl(b_index_codtypemp,a.typemp)
         and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
         and b.numlvl    between global_v_numlvlsalst and global_v_numlvlsalen
      group by a.dtemthpay
      order by a.dtemthpay;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for i in 1..12 loop
      v_month := lpad(i,2,'0');
      v_sum_amtpay := 0;
      for r_tsincexp in c_tsincexp loop
        v_sum_amtpay := r_tsincexp.sum_amtnet;
      end loop;

      arr_labels.append(get_tlistval_name('DTEMTHPAY',to_char(i),global_v_lang));
      arr_datasets.append(to_char(v_sum_amtpay,'fm999999999990.90'));
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
