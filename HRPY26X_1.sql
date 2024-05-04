--------------------------------------------------------
--  DDL for Package Body HRPY26X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY26X" as

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
    p_numperiod         := hcm_util.get_string_t(json_obj, 'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codpay            := hcm_util.get_string_t(json_obj, 'p_codpay');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_typpayroll tcodtypy.codcodec%type;
    v_codpay     tinexinf.codpay%type;
    v_codempid   temploy1.codempid%type;
  begin
    if p_codcomp is null then
      if p_codempid is null then
         if p_typpayroll is null then
            param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codempid');
            return;
         end if;
      end if;
    end if;
    --
    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;
    --
    if p_codempid is not null then
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_codpay is not null then
      begin
			  select codpay
          into v_codpay
          from tinexinf
         where codpay = p_codpay;
		 exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
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
    obj_row              json_object_t;
    obj_data             json_object_t;
    v_rcnt               number;
    v_flg_secure         boolean := false;
    v_flg_exist          boolean := false;
    v_flg_exist2         boolean := false;
    v_flg_permission     boolean := false;

    cursor c1 is
      select b.codempid,b.codpay, nvl(stddec(a.ratepay,a.codempid,v_chken),0) ratepay, a.codsys,a.codcomp,b.codcompw,b.costcent,nvl(b.qtypayda,0) qtypayda,
             nvl(b.qtypayhr,0) qtypayhr,nvl(b.qtypaysc,0) qtypaysc,nvl(stddec(b.amtpay,b.codempid,v_chken),0) amtpay,b.dteupd,b.coduser,a.dtemthpay,a.dteyrepay,a.numperiod
        from tothinc a,tothinc2 b,temploy1 emp
       where a.codempid   =  b.codempid
         and a.dteyrepay  =  b.dteyrepay
         and a.dtemthpay  =  b.dtemthpay
         and a.numperiod  =  b.numperiod
         and a.codpay     =  b.codpay
         and a.codcomp    like  p_codcomp||'%'
         and a.typpayroll like  nvl(p_typpayroll,'%')
         and a.codempid   like  nvl(p_codempid,'%')
         and a.codempid   = emp.codempid(+)
         and a.dteyrepay  =  p_dteyrepay
         and a.dtemthpay  =  p_dtemthpay
         and a.numperiod  =  p_numperiod
         and a.codpay     = nvl(p_codpay,a.codpay)
      order by a.codcomp,a.typpayroll,a.codempid,a.codpay,b.codcompw;

     cursor c2 is
      select a.codcomp,a.codempid,a.dteyrepay,a.dtemthpay,a.numperiod,a.codpay,a.dtepay,a.typpayroll,
             a.typemp,nvl(stddec(a.amtpay,a.codempid,v_chken),0) amtpay,a.flgpyctax,a.dteupd,a.coduser,
             a.costcent,a.rowid
				from tothpay a, temploy1 b
			 where a.dteyrepay = p_dteyrepay - global_v_zyear
				 and a.dtemthpay = p_dtemthpay
				 and a.numperiod = p_numperiod
				 and a.codcomp like p_codcomp||'%'
				 and a.typpayroll like nvl(p_typpayroll, a.typpayroll)
				 and a.codempid like nvl(p_codempid, a.codempid)
				 and a.codpay like nvl(p_codpay, a.codpay)
         and a.codempid = b.codempid(+)
		order by a.codcomp,a.typpayroll,a.codempid,a.codpay;


  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    --
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;

    for r2 in c2 loop
      v_flg_exist2 := true;
      exit;
     end loop;

     --
    if not v_flg_exist AND not v_flg_exist2 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tothinc2');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      v_flg_secure := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codpay', r1.codpay);
        obj_data.put('desc_codpay', get_tinexinf_name(r1.codpay, global_v_lang));
        obj_data.put('ratepay', r1.ratepay);
        obj_data.put('codsys', r1.codsys);
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('codcompw', r1.codcompw);
        obj_data.put('desc_codcompw', get_tcenter_name(r1.codcompw, global_v_lang));
        obj_data.put('costcent', r1.costcent);
        obj_data.put('qtypayda', r1.qtypayda);
        obj_data.put('qtypayhr', r1.qtypayhr);
        obj_data.put('qtypaysc', r1.qtypaysc);
        obj_data.put('amtpay', r1.amtpay);
        obj_data.put('dteupd', to_char(r1.dteupd, 'DD/MM/YYYY'));
        obj_data.put('coduser', r1.coduser);
        obj_data.put('dtemthpay', r1.dtemthpay);
        obj_data.put('dteyrepay', r1.dteyrepay);
        obj_data.put('numperiod', r1.numperiod);

        if isInsertReport then
          if json_param_break.get_size <= 0 then
            insert_ttemprpt_tab1(obj_data);
          end if;
        end if;

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;
    --
    if isInsertReport then
      if json_param_break.get_size > 0 then
        begin
          json_break_params := json_object_t();
          json_param_json.put('data', obj_row);
          json_break_params.put('codapp', 'HRPY26X1');
          json_break_params.put('p_coduser', global_v_coduser);
          json_break_params.put('p_codempid', global_v_codempid);
          json_break_params.put('p_lang', global_v_lang);
          json_break_params.put('json_input_str1', json_param_json);
          json_break_params.put('json_input_str2', json_param_break);
          json_str_output := json_break_params.to_clob;
          json_break_output := json_object_t(hcm_breaklevel.get_breaklevel(json_str_output));
          json_break_output_row   := hcm_util.get_json_t(json_break_output, 'param_json');
          for i in 0..json_break_output_row.get_size - 1 loop
            insert_ttemprpt_tab1(hcm_util.get_json_t(json_break_output_row, to_char(i)));
          end loop;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      end if;
--      insert_ttemprpt_head(obj_data);
    end if;
    if not v_flg_permission and v_flg_exist then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

  procedure get_data_tab2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data_tab2;

  procedure gen_data_tab2(json_str_output out clob) is
    obj_row              json_object_t;
    obj_data             json_object_t;
    v_rcnt               number;
    v_flg_secure         boolean := false;
    v_flg_exist          boolean := false;
    v_flg_exist2         boolean := false;
    v_flg_permission     boolean := false;

    cursor c1 is
      select a.codcomp,a.codempid,a.dteyrepay,a.dtemthpay,a.numperiod,a.codpay,a.dtepay,a.typpayroll,
             a.typemp,nvl(stddec(a.amtpay,a.codempid,v_chken),0) amtpay,a.flgpyctax,a.dteupd,a.coduser,
             a.costcent,a.rowid
				from tothpay a, temploy1 b
			 where a.dteyrepay = p_dteyrepay - global_v_zyear
				 and a.dtemthpay = p_dtemthpay
				 and a.numperiod = p_numperiod
				 and a.codcomp like p_codcomp||'%'
				 and a.typpayroll like nvl(p_typpayroll, a.typpayroll)
				 and a.codempid like nvl(p_codempid, a.codempid)
				 and a.codpay like nvl(p_codpay, a.codpay)
         and a.codempid = b.codempid(+)
		order by a.codcomp,a.typpayroll,a.codempid,a.codpay;

    cursor c2 is
      select b.codempid,b.codpay, nvl(stddec(a.ratepay,a.codempid,v_chken),0) ratepay, a.codsys,a.codcomp,b.codcompw,b.costcent,b.qtypayda,
             b.qtypayhr,b.qtypaysc,nvl(stddec(b.amtpay,b.codempid,v_chken),0) amtpay,b.dteupd,b.coduser,a.dtemthpay,a.dteyrepay,a.numperiod
        from tothinc a,tothinc2 b,temploy1 emp
       where a.codempid   =  b.codempid
         and a.dteyrepay  =  b.dteyrepay
         and a.dtemthpay  =  b.dtemthpay
         and a.numperiod  =  b.numperiod
         and a.codpay     =  b.codpay
         and a.codcomp    like  p_codcomp||'%'
         and a.typpayroll like  nvl(p_typpayroll,'%')
         and a.codempid   like  nvl(p_codempid,'%')
         and a.codempid   =  emp.codempid(+)
         and a.dteyrepay  =  p_dteyrepay
         and a.dtemthpay  =  p_dtemthpay
         and a.numperiod  =  p_numperiod
         and a.codpay     =  nvl(p_codpay,a.codpay)
      order by a.codcomp,a.typpayroll,a.codempid,a.codpay,b.codcompw;


  begin

    obj_row                := json_object_t();
    v_rcnt                 := 0;
    --
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    --
    for r2 in c2 loop
      v_flg_exist2 := true;
      exit;
    end loop;
    --
    if not v_flg_exist AND not v_flg_exist2 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tothpay');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      v_flg_secure := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;

        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('codpay', r1.codpay);
        obj_data.put('desc_codpay', get_tinexinf_name(r1.codpay, global_v_lang));
        obj_data.put('dtepay', to_char(r1.dtepay, 'DD/MM/YYYY'));
        obj_data.put('amtpay', r1.amtpay);
        obj_data.put('tax_compute', get_tlistval_name('TFLGCAL', r1.flgpyctax, global_v_lang));
        obj_data.put('costcent', r1.costcent);
        obj_data.put('dteupd', to_char(r1.dteupd, 'DD/MM/YYYY'));
        obj_data.put('coduser', r1.coduser);

        if isInsertReport then
          if json_param_break_payment.get_size <= 0 then
            insert_ttemprpt_tab2(obj_data);
          end if;
        end if;

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;
    --
    if isInsertReport then
      if json_param_break_payment.get_size > 0 then
        begin
          json_break_params_payment := json_object_t();
          json_param_json_payment.put('data', obj_row);
          json_break_params_payment.put('codapp', 'HRPY26X2');
          json_break_params_payment.put('p_coduser', global_v_coduser);
          json_break_params_payment.put('p_codempid', global_v_codempid);
          json_break_params_payment.put('p_lang', global_v_lang);
          json_break_params_payment.put('json_input_str1', json_param_json_payment);
          json_break_params_payment.put('json_input_str2', json_param_break_payment);
          json_str_output := json_break_params_payment.to_clob;
          json_break_output_payment := json_object_t(hcm_breaklevel.get_breaklevel(json_str_output));
          json_break_output_row_payment   := hcm_util.get_json_t(json_break_output_payment, 'param_json');
          for i in 0..json_break_output_row_payment.get_size - 1 loop
            insert_ttemprpt_tab2(hcm_util.get_json_t(json_break_output_row_payment, to_char(i)));
          end loop;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      end if;
--      insert_ttemprpt_head(obj_data);
    end if;

    if not v_flg_permission and v_flg_exist then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data_tab2;


  procedure initial_report(json_str in clob) is
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
    p_numperiod                 := hcm_util.get_string_t(json_obj, 'p_numperiod');
    p_dtemthpay                 := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay                 := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_codcomp                   := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll                := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_codempid                  := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codpay                    := hcm_util.get_string_t(json_obj, 'p_codpay');
    json_param_break            := hcm_util.get_json_t(json_obj, 'param_break');
    json_param_json             := hcm_util.get_json_t(json_obj, 'param_json');
    json_param_break_payment    := hcm_util.get_json_t(json_obj, 'param_break_payment');
    json_param_json_payment     := hcm_util.get_json_t(json_obj, 'param_json_payment');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin

    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      p_codapp := 'HRPY26X1';
      gen_data(json_output);
      p_codapp := 'HRPY26X2';
      gen_data_tab2(json_output);
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

  procedure insert_ttemprpt_tab1(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dteupd            date;
    v_dteupd_           varchar2(100 char) := '';
    v_emp_image         varchar2(600);
    v_folder            varchar2(600);
    v_flg_img           varchar2(1) := 'N';
    v_codempid          tothpay.codempid%type;
    v_desc_codempid     varchar2(600);
    v_codpay            ttemprpt.item1%type;
    v_desc_codpay       ttemprpt.item1%type;
    v_ratepay           ttemprpt.item1%type;
    v_qtypayda          ttemprpt.item1%type;
    v_qtypayhr          ttemprpt.item1%type;
    v_qtypaysc          ttemprpt.item1%type;
    v_amtpay            ttemprpt.item1%type;
    v_desc_codcompw     ttemprpt.item1%type;
    v_costcent          ttemprpt.item1%type;
    v_codsys            ttemprpt.item1%type;
    v_coduser           ttemprpt.item1%type;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq      := v_numseq + 1;
    v_year        := hcm_appsettings.get_additional_year;
    v_dteupd      := to_date(hcm_util.get_string_t(obj_data, 'dteupd'), 'DD/MM/YYYY');
    v_dteupd_     := hcm_util.get_date_buddhist_era(v_dteupd);
    v_emp_image   := get_emp_img(p_codempid);
    v_folder      := get_tfolderd('HRPMC2E1');

    v_codempid          := hcm_util.get_string_t(obj_data, 'codempid');
    v_desc_codempid     := hcm_util.get_string_t(obj_data, 'desc_codempid');
    v_codpay            := hcm_util.get_string_t(obj_data, 'codpay');
    v_desc_codpay       := hcm_util.get_string_t(obj_data, 'desc_codpay');
    v_ratepay           := to_char(to_number(replace(hcm_util.get_string_t(obj_data, 'ratepay'),',','')),'FM999,999,999,990.90');
    v_qtypayda          := hcm_util.get_string_t(obj_data, 'qtypayda');
    v_qtypayhr          := hcm_util.get_string_t(obj_data, 'qtypayhr');
    v_qtypaysc          := hcm_util.get_string_t(obj_data, 'qtypaysc');
    v_amtpay            := to_char(to_number(replace(hcm_util.get_string_t(obj_data, 'amtpay'),',','')),'FM999,999,999,990.90');
    v_desc_codcompw     := hcm_util.get_string_t(obj_data, 'desc_codcompw');
    v_costcent          := hcm_util.get_string_t(obj_data, 'costcent');
    v_codsys            := hcm_util.get_string_t(obj_data, 'codsys');
    v_coduser           := hcm_util.get_string_t(obj_data, 'coduser');

    if v_emp_image is not null then
      v_emp_image   := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_emp_image;
      v_flg_img     := 'Y';
    end if;

    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq,
             item1, item2, item3, item4, item5, item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15, item16, item17, item18, item19, item20, item21,
             item22, item23
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             p_numperiod,
             p_dtemthpay,
             p_dteyrepay,
             p_codcomp,
             p_typpayroll,
             p_codempid,
             p_codpay,
             v_codempid,
             v_desc_codempid,
             v_codpay,
             v_desc_codpay,
             v_ratepay,
             v_qtypayda,
             v_qtypayhr,
             v_qtypaysc,
             v_amtpay,
             v_desc_codcompw,
             v_costcent,
             v_codsys,
             v_dteupd_,
             v_coduser,
             v_emp_image,v_flg_img
           );

    exception when others then
      null;
    end;
  exception when others then
    null;
  end insert_ttemprpt_tab1;

  procedure insert_ttemprpt_tab2(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dteupd            date;
    v_dteupd_           varchar2(100 char) := '';
    v_emp_image         varchar2(600);
    v_folder            varchar2(600);
    v_flg_img           varchar2(1) := 'N';

     v_codempid         ttemprpt.item1%type;
     v_desc_codempid    ttemprpt.item1%type;
     v_codpay           ttemprpt.item1%type;
     v_desc_codpay      ttemprpt.item1%type;
     v_dtepay           ttemprpt.item1%type;
     v_amtpay           ttemprpt.item1%type;
     v_tax_compute      ttemprpt.item1%type;
     v_coduser          ttemprpt.item1%type;
     v_desc_codcomp     ttemprpt.item1%type;
     v_costcent         ttemprpt.item1%type;
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
    v_numseq      := v_numseq + 1;
    v_year        := hcm_appsettings.get_additional_year;
    v_dteupd      := to_date(hcm_util.get_string_t(obj_data, 'dteupd'), 'DD/MM/YYYY');
    v_dteupd_     := hcm_util.get_date_buddhist_era(v_dteupd);
    v_emp_image   := get_emp_img(p_codempid);
    v_folder      := get_tfolderd('HRPMC2E1');

     v_codempid         := hcm_util.get_string_t(obj_data, 'codempid');
     v_desc_codempid    := hcm_util.get_string_t(obj_data, 'desc_codempid');
     v_codpay           := hcm_util.get_string_t(obj_data, 'codpay');
     v_desc_codpay      := hcm_util.get_string_t(obj_data, 'desc_codpay');
     v_dtepay           := hcm_util.get_date_buddhist_era(to_date(hcm_util.get_string_t(obj_data, 'dtepay'),'DD/MM/YYYY'));
     v_amtpay           := to_char(replace(hcm_util.get_string_t(obj_data, 'amtpay'),',',''),'FM999,999,999,990.90');
     v_tax_compute      := hcm_util.get_string_t(obj_data, 'tax_compute');
     v_coduser          := hcm_util.get_string_t(obj_data, 'coduser');
     v_desc_codcomp     := hcm_util.get_string_t(obj_data, 'desc_codcomp');
     v_costcent         := hcm_util.get_string_t(obj_data, 'costcent');

    if v_emp_image is not null then
      v_emp_image   := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_emp_image;
      v_flg_img     := 'Y';
    end if;
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15, item16, item17, item18,
             item22, item23
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             p_numperiod,
             p_dtemthpay,
             p_dteyrepay,
             p_codcomp,
             p_typpayroll,
             p_codempid,
             p_codpay,
             v_codempid,
             v_desc_codempid,
             v_codpay,
             v_desc_codpay,
             v_dtepay,
             v_amtpay,
             v_tax_compute,
             v_dteupd_,
             v_coduser,
             v_desc_codcomp,
             v_costcent,
             v_emp_image,v_flg_img
           );

    exception when others then
      null;
    end;
  end insert_ttemprpt_tab2;

end HRPY26X;

/
