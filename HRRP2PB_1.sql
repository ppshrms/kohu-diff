--------------------------------------------------------
--  DDL for Package Body HRRP2PB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2PB" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');


    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_dteyrbug          := hcm_util.get_string_t(json_obj, 'p_dteyrbug');
    p_dtemthbugstr      := hcm_util.get_string_t(json_obj, 'p_dtemthbugstr');
    p_dtemthbugend      := hcm_util.get_string_t(json_obj, 'p_dtemthbugend');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_secur             boolean := false;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_dteyrbug is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dteyrbug');
      return;
    end if;
    if p_dtemthbugstr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtemthbugstr');
      return;
    end if;

    if p_dtemthbugend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtemthbugend');
      return;
    end if;

    if p_dtemthbugstr > p_dtemthbugend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dtemthbugstr');
      return;
    end if;

  end check_index;
  function cal_hhmiss(p_st	date,p_en date) return varchar is
      v_num   number	:= 0;
      v_sc   	number	:= 0;
      v_mi   	number	:= 0;
      v_hr   	number	:= 0;
      v_time  varchar2(500);
  begin
      v_num	  :=  ((p_en - p_st) * 86400) + 1;  ---- 86400 = 24*60*60
      v_hr    :=  trunc(v_num/3600);
      v_mi    :=  mod(v_num,3600);
      v_sc    :=  mod(v_mi,60);
      v_mi    :=  trunc(v_mi/60);
      v_time  :=  lpad(v_hr,2,0)||':'||lpad(v_mi,2,0)||':'||lpad(v_sc,2,0);
      return(v_time);
  end;

  procedure process_data (json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    json_obj      json_object_t;
    v_numrec      number := 0;
    v_numrec_non  number := 0;
    v_error       varchar2(4000 char);
    v_err_table   varchar2(4000 char);
    v_response    varchar2(4000);
    v_dtestr      date;
    v_dteend  	  date;
    v_time      varchar2(100 char);
  begin
    initial_value(json_str_input);
    check_index;
    json_obj := json_object_t();
    if param_msg_error is null then
      -- start
      v_dtestr := sysdate;
      v_numrec := 0;
      hrrp2pb_batch.cal_process (p_codcomp, p_dteyrbug, p_dtemthbugstr, p_dtemthbugend, global_v_coduser, v_numrec, v_error, v_err_table);
      -- end

      v_dteend := sysdate;
      v_time   := cal_hhmiss(v_dtestr,v_dteend);
      --
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      obj_row.put('numrec', v_numrec);
      obj_row.put('timeprocess', v_time);

      json_str_output := obj_row.to_clob;

      -- set complete batch process
      global_v_batch_flgproc := 'Y';
      global_v_batch_qtyproc := v_numrec;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    -- set complete batch process
    hcm_batchtask.finish_batch_process(
      p_codapp   => global_v_batch_codapp,
      p_coduser  => global_v_coduser,
      p_codalw   => global_v_batch_codalw,
      p_dtestrt  => global_v_batch_dtestrt,
      p_flgproc  => global_v_batch_flgproc,
      p_qtyproc  => global_v_batch_qtyproc,
      p_qtyerror => global_v_batch_qtyerror,
      p_oracode  => param_msg_error
    );

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );

  end process_data;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;

end HRRP2PB;

/
