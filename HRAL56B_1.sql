--------------------------------------------------------
--  DDL for Package Body HRAL56B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL56B" is
-- 09/07/2021
  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_stdate            := to_date(trim(hcm_util.get_string_t(json_obj,'p_stdate')),'dd/mm/yyyy');
    p_endate            := to_date(trim(hcm_util.get_string_t(json_obj,'p_endate')),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_secur   varchar2(4000 char);
  begin
    if p_stdate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_stdate');
      return;
    elsif p_endate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_endate');
      return;
    end if;
    if p_stdate > p_endate then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_stdate > p_endate');
      return;
    end if;

    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codcomp is not null then
      v_secur := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if v_secur is not null then
        param_msg_error := v_secur;
        return;
      end if;
    end if;
  end check_index;

  procedure process_data(json_str_input in clob, json_str_output out clob) as
    obj_row     json_object_t;
    v_numrec    number;
    v_numrec2   number;
  begin
    initial_value(json_str_input);
    check_index;

    if param_msg_error is null then
      hral56b_batch.gen_leave_Cancel(p_codempid,p_codcomp,p_stdate,p_endate,global_v_coduser,v_numrec);
      hral56b_batch.gen_leave(p_codempid,p_codcomp,p_stdate,p_endate,global_v_coduser,v_numrec2);
      v_numrec := nvl(v_numrec,0) + nvl(v_numrec2,0);
      --hral56b_batch.cal_process(p_codempid,p_codcomp,p_stdate,p_endate,global_v_coduser,v_numrec);
      --v_numrec2 := hral5qd_batch.cal_tleavecc(p_codempid,p_codcomp,p_stdate,p_endate,global_v_coduser);
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('numrec', v_numrec);
      obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
      json_str_output := obj_row.to_clob;

      -- set complete batch process 
      global_v_batch_flgproc  := 'Y';
      global_v_batch_qtyproc  := v_numrec;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    -- finish batch process
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
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

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
end HRAL56B;

/
