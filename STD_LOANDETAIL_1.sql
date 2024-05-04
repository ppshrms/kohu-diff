--------------------------------------------------------
--  DDL for Package Body STD_LOANDETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_LOANDETAIL" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_numcont           := hcm_util.get_string_t(json_obj,'p_numcont');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure get_tloaninf(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tloaninf(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tloaninf(json_str_output out clob)as
    obj_data        json_object_t;
    cursor c_tloaninf is
      select *
        from tloaninf
       where numcont = p_numcont;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('response', '');
    for r1 in c_tloaninf loop
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('numcont', r1.numcont);
        obj_data.put('codlon', r1.codlon || ' - ' || GET_TTYPLOAN_NAME(r1.codlon,global_v_lang));
        obj_data.put('typintr', get_tlistval_name('TYPINTREST',r1.typintr,global_v_lang));
        obj_data.put('formula', hcm_formula.get_description(r1.formula,global_v_lang));
        obj_data.put('amtlon', to_char(r1.amtlon,'fm999,999,999,990.00'));
        obj_data.put('numlony', trunc(r1.numlon/12,0));
        obj_data.put('numlonm', mod(r1.numlon,12));
        obj_data.put('rateilon', to_char(r1.rateilon,'fm999,999,999,990.00'));
        obj_data.put('dtelonst', to_char(r1.dtelonst,'dd/mm/yyyy'));
        obj_data.put('dtelonen', to_char(r1.dtelonen,'dd/mm/yyyy'));
        obj_data.put('dteissue', to_char(r1.dteissue,'dd/mm/yyyy'));
        obj_data.put('dtestcal', to_char(r1.dtestcal,'dd/mm/yyyy'));
        obj_data.put('typpayamt',  get_tlistval_name('LOANPAYMT2',r1.typpayamt,global_v_lang));
        obj_data.put('prdpay',  r1.prdpay||' '||get_tlistval_name('NAMMTHFUL',r1.mthpay,global_v_lang)||' '||hcm_util.get_year_buddhist_era(r1.dteyrpay));
        obj_data.put('reaslon', r1.reaslon);
        obj_data.put('typpay', get_tlistval_name('LOANPAYMT',r1.typpayamt,global_v_lang));
        obj_data.put('qtyperiod', r1.qtyperiod);
        obj_data.put('amtiflat', to_char(r1.amtiflat,'fm999,999,999,990.00'));
        obj_data.put('amttlpay', to_char(r1.amttlpay,'fm999,999,999,990.00'));
        obj_data.put('amtpaybo', to_char(r1.amtpaybo,'fm999,999,999,990.00'));
        obj_data.put('codreq', r1.codreq);
        obj_data.put('desc_codreq', get_temploy_name(r1.codreq,global_v_lang));
    end loop;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tloaninf;

  procedure get_tloancol(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tloancol(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tloancol;

  procedure gen_tloancol(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number:=0;
      cursor c_tloancol is
        select * 
          from tloancol
         where numcont = p_numcont
      order by codcolla;
    begin
      obj_row := json_object_t();
      for r1 in c_tloancol loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('response','');
          obj_data.put('codcolla',r1.codcolla);
          obj_data.put('desc_codcolla',get_tcodec_name ('TCODCOLA',r1.codcolla,global_v_lang));
          obj_data.put('amtcolla',r1.amtcolla);
          obj_data.put('numrefer',r1.numrefer);
          obj_data.put('descolla',r1.descolla);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tloancol;

  procedure get_tloangar(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_tloangar(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tloangar;

  procedure gen_tloangar(json_str_output out clob)as
      obj_data          json_object_t;
      obj_row           json_object_t;
      v_rcnt            number;
      v_codcomp         temploy1.codcomp%type;
      v_codpos          temploy1.codpos%type;
      v_agework         number;
      v_dteempmt        temploy1.dteempmt%type;
      v_workage_year    number;
      v_workage_month   number;
      v_workage_day     number;
      cursor c_tloangar is
        select * 
          from tloangar
         where numcont = p_numcont
      order by codempgar;
    begin
      v_rcnt := 0;
      obj_row := json_object_t();
      for r1 in c_tloangar loop
        begin
            select codcomp, codpos, dteempmt
              into v_codcomp, v_codpos,v_dteempmt
              from temploy1
             where codempid = r1.codempgar;        
        exception when others then
            v_codcomp   := null;
            v_codpos    := null;
        end;
        get_service_year(v_dteempmt,sysdate,'Y',v_workage_year,v_workage_month,v_workage_day);
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response','');
        obj_data.put('image',get_emp_img (r1.codempgar));
        obj_data.put('codempgar',r1.codempgar);
        obj_data.put('desc_codempgar',get_temploy_name(r1.codempgar,global_v_lang));
        obj_data.put('desc_codposgar',get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('desc_codcompgar',get_tcenter_name(v_codcomp,global_v_lang));
        obj_data.put('agework',v_workage_year||'('|| v_workage_month ||')');
        obj_data.put('amtgar',r1.amtgar);
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tloangar;  


  procedure get_tloaninf2(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tloaninf2(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tloaninf2(json_str_output out clob)as
    obj_data        json_object_t;
    cursor c_tloaninf is
      select *
        from tloaninf
       where numcont = p_numcont;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('response', '');
    for r1 in c_tloaninf loop
        obj_data.put('staloan', get_tlistval_name('STALOAN',r1.stalon,global_v_lang));
        obj_data.put('dteaccls', to_char(r1.dteaccls,'dd/mm/yyyy'));
        obj_data.put('amtnpfin', to_char(r1.amtnpfin,'fm999,999,999,990.00'));
        obj_data.put('dtelpay', to_char(r1.dtelpay,'dd/mm/yyyy'));
        obj_data.put('qtyperiod', r1.qtyperiod);
        obj_data.put('desaccls', r1.desaccls);
    end loop;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tloaninf2;  
end std_loandetail;

/
