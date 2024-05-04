--------------------------------------------------------
--  DDL for Package Body HRPY2IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2IX" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codlegald         := hcm_util.get_string_t(json_obj, 'p_codlegald');
    p_codlegald_x       := hcm_util.get_string_t(json_obj, 'p_codlegald_x');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_data              := hcm_util.get_json_t(json_obj,'p_data');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codlegald tcodlegald.codcodec%type;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_codlegald is not null then
      begin
        select codcodec
          into v_codlegald
          from tcodlegald
         where codcodec = p_codlegald;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodlegald');
        return;
      end;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data(json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    obj_child_data     json_object_t;
    obj_child_row      json_object_t;
    v_rcnt             number;
    v_rcnt_child       number;
    v_flgdata          varchar2(1 char) := 'N';
    v_flg_permission   boolean := false;
    v_total            number := 0;
    v_secur            boolean := false;
    v_data             number := 0;
    v_numseq           number := 1;
    v_temp_id          varchar2(100);

    cursor c1 is
      select a.codlegald
        from tlegalexe a
       where a.codlegald = nvl(p_codlegald,a.codlegald)
         and ((a.codlegald = p_codlegald_x and p_codlegald_x is not null) or p_codlegald_x is null) 
         and exists(select b.codempid from tlegalprd b
                     where b.codempid  = a.codempid
                       and b.numcaselw = a.numcaselw
                       and b.codcomp   like nvl(p_codcomp, b.codcomp) || '%'
                       and b.dtemthpay = p_dtemthpay
                       and b.dteyrepay = p_dteyrepay)
      group by a.codlegald
      order by a.codlegald;

    cursor c2 (v_codlegald varchar2) is
      select a.codempid,a.codcomp,a.numtime,a.numcaselw,
             nvl(stddec(a.amtded,a.codempid,v_chken),0) amtded,
             a.dtepay,a.typpaymt,a.numref
        from tlegalprd a, tlegalexe b
       where a.codempid  = b.codempid
         and a.numcaselw = b.numcaselw
         and a.codcomp like nvl(p_codcomp,a.codcomp) || '%'
         and a.dtemthpay = p_dtemthpay
         and a.dteyrepay = p_dteyrepay
         and b.codlegald = v_codlegald
       order by a.codempid,a.codcomp;
  begin

    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_rcnt_child           := 0;
    v_flgdata              := 'N';
    v_data                 := 0;
    --
    for r1 in c1 loop
      v_flgdata            := 'Y';
      exit;
    end loop;
    --
    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tlegalprd');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      obj_data         := json_object_t();
      obj_child_row    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codlegald', r1.codlegald);
      obj_data.put('codcomp', p_codcomp);
      obj_data.put('dtemthpay', p_dtemthpay);
      obj_data.put('dteyrepay', p_dteyrepay);
      v_rcnt_child  := 0;
      v_numseq      := 1;
      v_temp_id     := '';
      for r2 in c2 (r1.codlegald) loop  
        v_secur := secur_main.secur3(r2.codcomp,r2.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_secur then
          v_data := v_data+1;
          v_flg_permission := true;
          obj_child_data   := json_object_t();
          obj_child_data.put('coderror', '200');
          obj_child_data.put('image', nvl(get_emp_img(r2.codempid),r2.codempid));
          obj_child_data.put('codempid', r2.codempid);
          obj_child_data.put('desc_codempid', get_temploy_name(r2.codempid, global_v_lang));
          obj_child_data.put('codcomp', r2.codcomp);
          obj_child_data.put('desc_codcomp', get_tcenter_name(r2.codcomp, global_v_lang));
          obj_child_data.put('numcaselw', r2.numcaselw);
--<<user46 14/12/2021
--          obj_child_data.put('numtime', r2.numtime);
          if v_temp_id is null then
            v_temp_id   := r2.codempid;
          elsif r2.codempid <> v_temp_id then
            v_numseq    := 1;
            v_temp_id   := r2.codempid;
          end if;
          obj_child_data.put('numtime', v_numseq);
          v_numseq  := v_numseq + 1;
-->>user46 14/12/2021
          obj_child_data.put('amtded', r2.amtded);
          obj_child_data.put('dtepay', to_char(r2.dtepay,'dd/mm/yyyy'));
          obj_child_data.put('typpaymt', get_tlistval_name('TYPPAYMT',r2.typpaymt, global_v_lang));
          obj_child_data.put('numref', r2.numref);
          obj_child_row.put(to_char(v_rcnt_child), obj_child_data);
          v_rcnt_child    := v_rcnt_child + 1;
        end if;
      end loop;
      obj_data.put('children', obj_child_row);
      --report--
      if obj_child_row.get_size > 0 then 
          if isInsertReport then
            insert_ttemprpt_data(obj_data);
          end if;
          --
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt           := v_rcnt + 1;
      end if;
    end loop;
    --
    if not isInsertReport then
        if not v_flg_permission then
              param_msg_error := get_error_msg_php('HR3007', global_v_lang);
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
              return;
        else
             if v_data = 0 then 
                param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'totsum');
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                return; 
             end if;
        end if;    
    end if;    
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

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

  procedure get_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    obj_main          json_object_t;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    obj_main := json_object_t();
    if param_msg_error is null then
      p_codapp := 'HRPY2IX';
      clear_ttemprpt;
      obj_main.put('codlegald',p_codlegald_x);
      obj_main.put('codcomp', p_codcomp);
      obj_main.put('dtemthpay', p_dtemthpay);
      obj_main.put('dteyrepay', p_dteyrepay);
      obj_main.put('children',p_data);
      insert_ttemprpt_data(obj_main);
--      gen_data(json_output);
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
  end get_report;

  procedure insert_ttemprpt_data(obj_data in json_object_t) is
    json_data_rows      json_object_t;
    v_data_rows         json_object_t;
    v_numseq            number := 0;
    v_year              number := 0;
    v_all_amtded        number := 0;
    v_dtepay            date;
    v_dtepay_           varchar2(100 char) := '';

    v_codlegald         varchar2(1000 char);
    v_codcomp           varchar2(1000 char);
    v_dtemthpay         varchar2(1000 char);
    v_dteyrepay         varchar2(1000 char);
    v_thyear            varchar2(1000 char);
    v_month             varchar2(1000 char);
    v_desc_codlegald    varchar2(1000 char);
    v_desc_codcomp      varchar2(1000 char);
    v_item6 varchar2(1000 char);
    v_item7 varchar2(1000 char);
    v_item8 varchar2(1000 char);
    v_item9 varchar2(1000 char);
    v_item10 varchar2(1000 char);
    v_item11 varchar2(1000 char);
    v_item12 varchar2(1000 char);
    v_item14 varchar2(1000 char);
    v_item15 varchar2(1000 char);
    v_item16 varchar2(1000 char);
    v_item17 varchar2(1000 char);
    v_item18 varchar2(1000 char);
  begin
    v_codlegald       := hcm_util.get_string_t(obj_data, 'codlegald');
    v_desc_codlegald  := v_codlegald||' - '||get_tcodelegald_name(v_codlegald, global_v_lang);
    v_codcomp         := hcm_util.get_string_t(obj_data, 'codcomp');
    v_dtemthpay       := hcm_util.get_string_t(obj_data, 'dtemthpay');
    v_dteyrepay       := hcm_util.get_string_t(obj_data, 'dteyrepay');
    v_thyear          := to_number(v_dteyrepay) + hcm_appsettings.get_additional_year;
    v_month           := get_nammthful(v_dtemthpay,global_v_lang);

    json_data_rows     := hcm_util.get_json_t(obj_data, 'children');
    for i in 0..json_data_rows.get_size-1 loop
      v_data_rows      := hcm_util.get_json_t(json_data_rows, to_char(i));
      if hcm_util.get_string_t(v_data_rows, 'codempid') is not null then
        v_all_amtded := v_all_amtded + to_number(hcm_util.get_string_t(v_data_rows, 'amtded'));
      end if;
    end loop;

    for i in 0..json_data_rows.get_size-1 loop
      v_data_rows      := hcm_util.get_json_t(json_data_rows, to_char(i));
      --
      begin
        select nvl(max(numseq), 0) into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp   = p_codapp;
      exception when no_data_found then null;
      end;
      if hcm_util.get_string_t(v_data_rows, 'codempid') is not null then
          v_numseq    := v_numseq + 1;
          v_year      := hcm_appsettings.get_additional_year;
          v_dtepay    := to_date(hcm_util.get_string_t(v_data_rows, 'dtepay'), 'DD/MM/YYYY');
          v_dtepay_   := to_char(v_dtepay, 'DD/MM/') || (to_number(to_char(v_dtepay, 'YYYY')) + v_year);
          v_item6 := nvl(hcm_util.get_string_t(v_data_rows, 'codempid'), ' ');
          v_item7 := nvl(hcm_util.get_string_t(v_data_rows, 'desc_codempid'), ' ');
          v_item8 := nvl(hcm_util.get_string_t(v_data_rows, 'codcomp'), ' ');
           v_item9 := nvl(hcm_util.get_string_t(v_data_rows, 'desc_codcomp'), ' ');
           v_item10 := nvl(hcm_util.get_string_t(v_data_rows, 'numcaselw'), ' ');
           v_item11 := nvl(hcm_util.get_string_t(v_data_rows, 'numtime'), ' ');
           v_item12 := nvl(to_char(hcm_util.get_string_t(v_data_rows, 'amtded'),'FM9,999,999,990.00'), ' ');

           v_item14 := nvl(hcm_util.get_string_t(v_data_rows, 'typpaymt'), ' ');
           v_item15 := nvl(hcm_util.get_string_t(v_data_rows, 'numref'), ' ');
           v_item16 := to_char(sysdate,'DD/MM/YYYY HH24:MI:SS');
           v_item17 := v_month||' '||v_thyear ;
           v_item18 := nvl(to_char(v_all_amtded,'FM9,999,999,990.00'), ' ');
          --
          begin
            insert
              into ttemprpt
                 (
                   codempid, codapp, numseq, item1, item2, item3, item4,item5,
                   item6, item7, item8,
                   item9, item10, item11, item12, item13, item14, item15, item16, item17 ,item18
                 )
            values
                 ( global_v_codempid, p_codapp, v_numseq,
                   v_codlegald, v_desc_codlegald, v_codcomp, v_dtemthpay, v_dteyrepay,
                   v_item6,
                   v_item7,
                   v_item8,
                   v_item9,
                   v_item10,
                   v_item11,
                   v_item12,
                   v_dtepay_,
                   v_item14,
                   v_item15,
                   v_item16,
                   v_item17,
                   v_item18
            );
          exception when others then null;
          end;
      end if;
    end loop;
  end insert_ttemprpt_data;
end HRPY2IX;

/
