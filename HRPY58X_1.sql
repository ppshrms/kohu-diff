--------------------------------------------------------
--  DDL for Package Body HRPY58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY58X" as

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_numperiod         := to_number(hcm_util.get_string_t(obj_detail,'numperiod'));
    p_month             := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll        := hcm_util.get_string_t(obj_detail,'typpayroll');
    p_comlevel          := to_number(hcm_util.get_string_t(obj_detail,'comlevel'));
    p_sysdate           := sysdate;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null and p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp,typpayroll');
      return;
    end if;
    if p_comlevel is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'comlevel');
      return;
    end if;
    if p_codcomp is not null then
      p_typpayroll := null;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows             json_object_t := json_object_t();
    obj_data             json_object_t;
    v_count              number := 0;
    v_flg_secur          boolean := false;
    v_flg_exist          boolean := false;
    v_flg_permission     boolean := false;
    v_numseq_level       number := 0;
    v_cod_level          varchar2(100 char) := '';
    v_cod_level_temp     varchar2(100 char) := '@#!';
    cursor c1 is
      select a.codempid  ,a.codcomp ,a.numlvl,a.codcurr,a.codcurr_e,
             a.typpayroll,a.codempmt,b.codpos,b.codcalen,
             row_number() over (partition by a.codcomp order by a.codcomp) as seq_comp
--            , a.codpay,a.dtemthpay,a.dteyrepay,a.numperiod
        from tsincexp a,temploy1 b
       where a.dteyrepay  = p_year
         and a.dtemthpay  = p_month
         and a.numperiod  = p_numperiod
         and a.codcomp    like p_codcomp || '%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.flgslip    = '1'
         and a.codempid   = b.codempid
--    group by a.codcomp,a.codempid,a.numlvl,a.codcurr,a.codcurr_e,a.typpayroll,a.codempmt,b.codpos,b.codcalen,a.codpay,a.dtemthpay,a.dteyrepay,a.numperiod
    group by a.codcomp,a.codempid,a.numlvl,a.codcurr,a.codcurr_e,a.typpayroll,a.codempmt,b.codpos,b.codcalen
    order by a.codcomp,b.codcalen,a.codempid;
  begin
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r1 in c1 loop
      --<<User37 Final Test Phase 1 V11 #2499 08/10/2020   
      --v_flg_secur := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      v_flg_secur := secur_main.secur2(r1.codempid, global_v_coduser, global_v_numlvlsalst,global_v_numlvlsalen, v_zupdsal);
      -->>User37 Final Test Phase 1 V11 #2499 08/10/2020 
      if v_flg_secur then
        v_flg_permission := true;
--        insert_temp(to_char(v_count + 1),r1.codempid,r1.codcomp);
        obj_data := json_object_t();
        obj_data.put('image'          ,get_emp_img(r1.codempid));
        obj_data.put('codempid'       ,r1.codempid);
        obj_data.put('desc_codempid'  ,get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codcomp'        ,r1.codcomp);
        obj_data.put('desc_codcomp'   ,get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos'         ,r1.codpos);
        obj_data.put('desc_codpos'    ,get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('typpayroll'     ,r1.typpayroll);
        obj_data.put('desc_typpayroll',get_tcodec_name('TCODWORK',r1.codcalen,global_v_lang));
        obj_data.put('coderror'       ,'200');


        --<<User37 [Final Test Phase 1 V11 - Error Program #2500] 08/10/2020
        obj_data.put('dteyrepay'      ,p_year);
        obj_data.put('dtemthpay'      ,p_month);
        obj_data.put('numperiod'      ,p_numperiod);
        -->>User37 [Final Test Phase 1 V11 - Error Program #2500] 08/10/2020

--        obj_data.put('codpay'         ,r1.codpay);
--        obj_data.put('dtemthpay'       ,r1.dtemthpay);
--        obj_data.put('dteyrepay'       ,r1.dteyrepay);
--        obj_data.put('numperiod'       ,r1.numperiod);
        v_cod_level := hcm_util.get_codcomp_level(nvl(hcm_util.get_string_t(obj_data, 'codcomp'), ' '),p_comlevel);
        obj_data.put('desc_cod_level'   ,get_tcenter_name(v_cod_level,global_v_lang));
        if v_cod_level_temp <> v_cod_level then
           v_numseq_level := 1;
           v_cod_level_temp := v_cod_level;
        else
           v_numseq_level := v_numseq_level+1;
        end if;
        obj_data.put('seq_level'     ,v_numseq_level);
        obj_data.put('cod_level'     ,v_cod_level);

        --report--
        if isInsertReport then
            insert_ttemprpt(obj_data);
        end if;
        obj_rows.put(to_char(v_count) ,obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
    return;
  end gen_index;
  --
  procedure get_list_tsetcomp (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_json_input    json_object_t;
    v_rcnt          number := 0;
    v_codcomp       tcenter.codcomp%type;

    cursor c_tsetcomp is
      select numseq
        from tsetcomp
        where nvl(qtycode,0) > 0
      order by numseq;
  begin
    initial_value(json_str_input);
    v_json_input    := json_object_t(json_str_input);
    v_codcomp       := hcm_util.get_string_t(v_json_input,'p_codcomp');
    obj_row := json_object_t();
    for r1 in c_tsetcomp loop
      v_rcnt      := v_rcnt+1;
      obj_data     := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('comlevel', r1.numseq);
      if r1.numseq = 1 then
        obj_data.put('namecomlevel', get_label_name('SCRLABEL',global_v_lang,2250));
      else
        obj_data.put('namecomlevel', get_comp_label(v_codcomp,r1.numseq,global_v_lang));
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
---
  procedure insert_temp(v_index in varchar2,v_codempid in varchar2,v_codcomp in varchar2) as
    v_desc_codcomp varchar2(4000 char);
  begin
    if p_codcomp is not null then
      v_desc_codcomp := get_tcenter_name(p_codcomp,global_v_lang);
    else
      v_desc_codcomp := get_label_name('HRPY58X',global_v_lang,p_label_all);
    end if;
    begin
      insert into ttemprpt(codempid   ,codapp    ,numseq    ,
                           item1      ,item2     ,item3     ,
                           item4      ,item5     ,item6     ,
                           item7      ,item8     ,item9     ,
                           item31     ,item32    ,item33    ,
                           item34)
                    values(global_v_codempid     ,'HRPY58X' ,    v_index,
                           p_numperiod,p_month   ,p_year    ,
                           v_codcomp  ,
                           v_desc_codcomp,
                           to_char(sysdate,'dd/mm/yyyy hh24:mi'),
                           to_char(p_comlevel),
                           hcm_util.get_codcomp_level(v_codcomp,p_comlevel),
                           get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp,p_comlevel),global_v_lang),
                           v_index    ,
                           v_codempid,
                           get_temploy_name(v_codempid,global_v_lang),
                           get_tcenter_name(v_codcomp,global_v_lang));
    exception when no_data_found then
      update ttemprpt
         set item1    = p_numperiod,
             item2    = p_month,
             item3    = p_year,
             item4    = v_codcomp,
             item5    = v_desc_codcomp,
             item6    = to_char(sysdate,'dd/mm/yyyy hh24:mi'),
             item31   = v_index,
             item32   = v_codempid,
             item33   = get_temploy_name(v_codempid,global_v_lang),
             item34   = get_tcenter_name(v_codcomp,global_v_lang)
       where codempid = global_v_codempid
         and codapp   = 'HRPY58X'
         and numseq   = v_index;
    end;
  end;
  ----- Specific Report ------
  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));
    p_month             := to_number(hcm_util.get_string_t(json_obj, 'p_month'));
    p_year              := to_number(hcm_util.get_string_t(json_obj, 'p_year')) - hcm_appsettings.get_additional_year;
    p_comlevel          := to_number(hcm_util.get_string_t(json_obj, 'p_comlevel'));
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_report;
  --
  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      p_codapp := 'HRPY58X';
      clear_ttemprpt;
      gen_index(json_output);

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
  end gen_report;
  --
  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
        where codempid = global_v_codempid
        and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;
  --
  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;

    v_year              number := 0;
    v_codempid          varchar2(100 char) := '';
    v_desc_codempid     varchar2(100 char) := '';
    v_codcomp           varchar2(100 char) := '';
    v_desc_codcomp      varchar2(100 char) := '';
    v_codpos            varchar2(100 char) := '';
    v_desc_codpos       varchar2(100 char) := '';
    v_typpayroll        varchar2(100 char) := '';
    v_desc_typpayroll   varchar2(100 char) := '';
    v_item1 varchar2(100 char);
    v_item2 varchar2(100 char);
    v_item3 varchar2(100 char);
    v_item4 varchar2(100 char);
    v_item5 varchar2(100 char);
    v_item6 varchar2(100 char);
    v_item7 varchar2(100 char);
    v_item8 varchar2(100 char);
    v_item15 varchar2(100 char);
    v_item16 varchar2(100 char);
    v_item17 varchar2(100 char);

    v_year_             number := 0;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;
    v_year      := hcm_appsettings.get_additional_year;
    v_item1  := nvl(hcm_util.get_string_t(obj_data, 'codempid'), ' ');
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), ' ');
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'codcomp'), ' ');
    v_item4 := nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp'), ' ');
    v_item5  := nvl(hcm_util.get_string_t(obj_data, 'codpos'), ' ');
    v_item6 := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), ' ');
    v_item7 := nvl(hcm_util.get_string_t(obj_data, 'typpayroll'), ' ');
    v_item8 := nvl(hcm_util.get_string_t(obj_data, 'desc_typpayroll'), ' ');

    v_item15 := nvl(hcm_util.get_string_t(obj_data, 'seq_level'), ' ');
    v_item16 := nvl(hcm_util.get_string_t(obj_data, 'cod_level'), ' ');
    v_item17 := nvl(hcm_util.get_string_t(obj_data, 'desc_cod_level'), ' ');

    begin
      null;
      insert
        into ttemprpt(codempid, codapp, numseq, item1, item2, item3, item4, item5,
                      item6, item7, item8, item9, item10, item11, item12, item13,item14,
                      item15,item16,item17)
        values(global_v_codempid, p_codapp, v_numseq,
               v_item1,
               v_item2,
               v_item3,
               v_item4,
               v_item5,
               v_item6,
               v_item7,
               v_item8,
               p_numperiod,
               p_month,
               p_year + hcm_appsettings.get_additional_year,
               p_codcomp,
               p_typpayroll,
               p_comlevel,
               v_item15,
               v_item16,
               v_item17);

    exception when others then
      null;
    end;
  end insert_ttemprpt;
end hrpy58x;

/
