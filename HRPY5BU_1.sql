--------------------------------------------------------
--  DDL for Package Body HRPY5BU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5BU" as
  --1.TDEDLNSLF 
  --2.TLOANSLF
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
    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_month');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_year');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
    v_codcompy  tcompny.codcompy%type;
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      begin
        select codcompy into v_codcompy
        from tcompny
        where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
      end;
    end if;
  end check_index;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data             json_object_t;
    v_flg_secure         boolean := false;
    v_flg_permission     boolean := false;
    v_flg_exist          boolean := false;
    v_count_exist        number := 0;
    v_tdedlnslf           tdedlnslf%rowtype;
  begin
    begin
      select * into v_tdedlnslf
      from tdedlnslf
      where codcompy = p_codcompy
      and dtemthpay = p_dtemthpay
      and dteyrepay = p_dteyrepay;
    exception when no_data_found then
      null;
    end;
    obj_data  := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcompy', p_codcompy);
    obj_data.put('dtemthpay', p_dtemthpay);
    obj_data.put('dteyrepay', p_dteyrepay);
    obj_data.put('amtdedstu', stddec(v_tdedlnslf.amtdedstu, p_codcompy, v_chken)); 
    obj_data.put('chequeno', v_tdedlnslf.chequeno ); 
    obj_data.put('codbank', v_tdedlnslf.codbank ); 
    obj_data.put('codconfirm', v_tdedlnslf.codconfirm ); 
    obj_data.put('dtecheque', to_char(v_tdedlnslf.dtecheque,'dd/mm/yyyy') ); 
    obj_data.put('dteconfirm', to_char(v_tdedlnslf.dteconfirm ,'dd/mm/yyyy') ); 
    obj_data.put('timconfirm',  to_char(v_tdedlnslf.dteconfirm ,'hh24mi') ); 
    obj_data.put('dtededstu', to_char(v_tdedlnslf.dtededstu,'dd/mm/yyyy') ); 
    obj_data.put('filename1', v_tdedlnslf.filename1 ); 
    obj_data.put('filename2', v_tdedlnslf.filename2 ); 
    obj_data.put('receiptno', v_tdedlnslf.receiptno ); 
    obj_data.put('typdedstu', v_tdedlnslf.typdedstu ); 
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
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
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
    obj_param_json json_object_t;
    -- get param json
    v_flg           varchar2(100 char);

    tmp_amtdedstu		number;
    v_amtdedstu		  tdedlnslf.amtdedstu%type;
    v_chequeno		  tdedlnslf.chequeno%type;
    v_codbank		    tdedlnslf.codbank%type;
    v_codconfirm	  tdedlnslf.codconfirm%type;
    v_dtecheque		  tdedlnslf.dtecheque%type;
    v_dteconfirm	  tdedlnslf.dteconfirm%type;
    v_timconfirm	  varchar2(100 char);
    v_dtededstu		  tdedlnslf.dtededstu%type;
    v_filename1		  tdedlnslf.filename1%type;
    v_filename2		  tdedlnslf.filename2%type;
    v_receiptno		  tdedlnslf.receiptno%type;
    v_typdedstu		  tdedlnslf.typdedstu%type;
  begin
    initial_value(json_str_input);
--    check_index;
    obj_param_json  := json_object_t(json_str_input);

    p_codcompy      := hcm_util.get_string_t(obj_param_json, 'codcompy');
    p_dtemthpay     := hcm_util.get_string_t(obj_param_json, 'dtemthpay');
    p_dteyrepay     := hcm_util.get_string_t(obj_param_json, 'dteyrepay');
    tmp_amtdedstu   := to_number(hcm_util.get_string_t(obj_param_json, 'amtdedstu'));
    v_chequeno      := hcm_util.get_string_t(obj_param_json, 'chequeno');
    v_codbank       := hcm_util.get_string_t(obj_param_json, 'codbank');
    v_codconfirm    := hcm_util.get_string_t(obj_param_json, 'codconfirm');
    v_dtecheque     := to_date(hcm_util.get_string_t(obj_param_json, 'dtecheque'),'dd/mm/yyyy');
    v_dteconfirm    := to_date(hcm_util.get_string_t(obj_param_json, 'dteconfirm'),'dd/mm/yyyy');
    v_timconfirm    := replace(hcm_util.get_string_t(obj_param_json,'timconfirm'),':','');
    v_dtededstu     := to_date(hcm_util.get_string_t(obj_param_json, 'dtededstu'),'dd/mm/yyyy');
    v_filename1     := hcm_util.get_string_t(obj_param_json, 'filename1');
    v_filename2     := hcm_util.get_string_t(obj_param_json, 'filename2');
    v_receiptno     := hcm_util.get_string_t(obj_param_json, 'receiptno');
    v_typdedstu     := hcm_util.get_string_t(obj_param_json, 'typdedstu');

    v_dteconfirm    := to_date(to_char(v_dteconfirm,'dd/mm/yyyy')||v_timconfirm,'dd/mm/yyyyhh24mi');
    v_amtdedstu :=  stdenc(tmp_amtdedstu, p_codcompy, v_chken);
    if param_msg_error is null then
      begin
        insert into tdedlnslf(codcompy,dteyrepay,dtemthpay,dteconfirm,codconfirm,
                              receiptno,filename1,dtededstu,amtdedstu,typdedstu,
                              codbank,chequeno,dtecheque,filename2,dtecreate,codcreate,coduser)
                       values(p_codcompy,p_dteyrepay,p_dtemthpay,v_dteconfirm,
                              v_codconfirm,v_receiptno,v_filename1,v_dtededstu,v_amtdedstu,v_typdedstu,
                              v_codbank,v_chequeno,v_dtecheque,v_filename2,trunc(sysdate),global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tdedlnslf 
           set dteconfirm	= v_dteconfirm,
               codconfirm	= v_codconfirm,
               receiptno	= v_receiptno,
               filename1	= v_filename1,
               dtededstu	= v_dtededstu,
               amtdedstu	= v_amtdedstu,
               typdedstu	= v_typdedstu,
               codbank		= v_codbank,
               chequeno	  = v_chequeno,
               dtecheque	= v_dtecheque,
               filename2	= v_filename2,
               dteupd     = trunc(sysdate),
               coduser    = global_v_coduser
         where codcompy  = p_codcompy
           and dteyrepay = p_dteyrepay
           and dtemthpay = p_dtemthpay;
      end;
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

end hrpy5bu;

/
