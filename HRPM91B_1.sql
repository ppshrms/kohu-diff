--------------------------------------------------------
--  DDL for Package Body HRPM91B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM91B" is
-- last update: 04/02/2021 18:15 redmine #2247

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
--    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dteproc           := to_date(hcm_util.get_string_t(json_obj,'p_dteproc'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_code    varchar2(1000);
  begin
    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
    if param_msg_error is not null then
      return;
    end if;
  end check_index;

  procedure initial_batchtask is
  begin
    for i in 1..global_v_batch_count loop
      global_v_batch_codalw(i)   := global_v_batch_codapp||to_char(i);
      global_v_batch_flgproc(i)  := 'N';
      global_v_batch_qtyproc(i)  := 0;
      global_v_batch_qtyerror(i) := 0;
    end loop;
  end;

  procedure process_data (json_str_input in clob, json_str_output out clob) is
    obj_row                 json_object_t;
    v_response            varchar2(4000);
    v_s_new_emp         number := 0;
    v_e_new_emp         number := 0;
    v_s_rehire_emp       number := 0;
    v_e_rehire_emp       number := 0;
    v_s_transfer_comp   number := 0;
    v_e_transfer_comp   number := 0;
    v_s_probate             number := 0;
    v_e_probate             number := 0;
    v_s_movement         number := 0;
    v_e_movement         number := 0;
    v_s_punishment         number := 0;
    v_e_punishment        number := 0;
    v_s_terminate           number := 0;
    v_e_terminate           number := 0;
    v_s_secure              number := 0;
    v_e_secure              number := 0;
    v_s_user                number := 0;
    v_e_user                number := 0;
    v_s_user1                number := 0;
    v_e_user1                number := 0;
    v_s_user2                number := 0;
    v_e_user2                number := 0;
    v_s_user3                number := 0;
    v_e_user3                number := 0;
    v_s_user4                number := 0;
    v_e_user4                number := 0;

  begin
    initial_value(json_str_input);
    initial_batchtask;
    check_index;
    delete ttemfilt where codapp = 'HRPM91B' and coduser = global_v_coduser;
--    commit;
    obj_row := json_object_t();
    if param_msg_error is null then
      hrpm91b_batch.process_new_employment(p_codcomp,p_dteproc,global_v_coduser,v_s_new_emp,v_e_new_emp,
                                           v_s_user1,v_e_user1, --user36 27/05/2022
                                           global_v_batch_dtestrt);
      hrpm91b_batch.process_reemployment(p_codcomp,p_dteproc,global_v_coduser,'R',v_s_rehire_emp,v_e_rehire_emp,
                                         v_s_user2,v_e_user2, --user36 27/05/2022
                                         global_v_batch_dtestrt);
      hrpm91b_batch.process_reemployment(p_codcomp,p_dteproc,global_v_coduser,'T',v_s_transfer_comp,v_e_transfer_comp,
                                         v_s_user3,v_e_user3, --user36 27/05/2022
                                         global_v_batch_dtestrt);
      hrpm91b_batch.process_probation(p_codcomp,p_dteproc,global_v_coduser,v_s_probate,v_e_probate,global_v_batch_dtestrt);
      hrpm91b_batch.process_movement(p_codcomp,p_dteproc,global_v_coduser,null,null,null,v_s_movement,v_e_movement,v_s_secure, v_e_secure, global_v_batch_dtestrt);
      hrpm91b_batch.process_mistake(p_codcomp,p_dteproc,global_v_coduser,v_s_punishment,v_e_punishment,global_v_batch_dtestrt);
      hrpm91b_batch.process_exemption(p_codcomp,null,p_dteproc,global_v_coduser,v_s_terminate,v_e_terminate,global_v_batch_dtestrt);
      hrpm91b_batch.process_tsecpos(p_codcomp,p_dteproc,global_v_coduser,v_s_user4,v_e_user4,global_v_batch_dtestrt); --user36 27/05/2022

      if nvl(v_e_new_emp,0) + nvl(v_e_rehire_emp,0) + nvl(v_e_transfer_comp,0) + nvl(v_e_probate,0) + nvl(v_e_movement,0) + nvl(v_e_punishment,0) + nvl(v_e_terminate,0) > 0 then
        param_msg_error := get_error_msg_php('HR2716',global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      end if;

      v_response        := get_response_message(null,param_msg_error,global_v_lang);
      obj_row.put('coderror', '200');
      obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      obj_row.put('succ_new_emp',v_s_new_emp);
      obj_row.put('error_new_emp',v_e_new_emp);
      obj_row.put('succ_rehire_emp',v_s_rehire_emp);
      obj_row.put('error_rehire_emp',v_e_rehire_emp);
      obj_row.put('succ_transfer_comp',v_s_transfer_comp);
      obj_row.put('error_transfer_comp',v_e_transfer_comp);
      obj_row.put('succ_probate',v_s_probate);
      obj_row.put('error_probate',v_e_probate);
      obj_row.put('succ_movement',v_s_movement);
      obj_row.put('error_movement',v_e_movement);
      obj_row.put('succ_punishment',v_s_punishment);
      obj_row.put('error_punishment',v_e_punishment);
      obj_row.put('succ_terminate',v_s_terminate);
      obj_row.put('error_terminate',v_e_terminate);
      --<<user36 27/05/2022
/*--<<redmine 2249
      obj_row.put('succ_secure',v_s_secure);
      obj_row.put('error_secure',v_e_secure);
-->>redmine 2249*/
      v_s_user := v_s_user1 + v_s_user2 + v_s_user3 + v_s_user4;
      v_e_user := v_e_user1 + v_e_user2 + v_e_user3 + v_e_user4;
      obj_row.put('succ_secure',v_s_user); 
      obj_row.put('error_secure',v_e_user); 
      -->>user36 27/05/2022
      json_str_output := obj_row.to_clob;

      -- set complete batch process
      global_v_batch_flgproc(1)  := 'Y';
      global_v_batch_qtyproc(1)  := v_s_new_emp;
      global_v_batch_qtyerror(1) := v_e_new_emp;
      global_v_batch_flgproc(2)  := 'Y';
      global_v_batch_qtyproc(2)  := v_s_movement;
      global_v_batch_qtyerror(2) := v_e_movement;
      global_v_batch_flgproc(3)  := 'Y';
      global_v_batch_qtyproc(3)  := v_s_rehire_emp;
      global_v_batch_qtyerror(3) := v_e_rehire_emp;
      global_v_batch_flgproc(4)  := 'Y';
      global_v_batch_qtyproc(4)  := v_s_punishment;
      global_v_batch_qtyerror(4) := v_e_punishment;
      global_v_batch_flgproc(5)  := 'Y';
      global_v_batch_qtyproc(5)  := v_s_transfer_comp;
      global_v_batch_qtyerror(5) := v_e_transfer_comp;
      global_v_batch_flgproc(6)  := 'Y';
      global_v_batch_qtyproc(6)  := v_s_terminate;
      global_v_batch_qtyerror(6) := v_e_terminate;
      global_v_batch_flgproc(7)  := 'Y';
      global_v_batch_qtyproc(7)  := v_s_probate;
      global_v_batch_qtyerror(7) := v_e_probate;
--<<redmine 2247
      global_v_batch_flgproc(8)  := 'Y';
      global_v_batch_qtyproc(8)  := v_s_secure;
      global_v_batch_qtyerror(8) := v_e_secure;
-->>redmine 2247
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    -- set complete batch process
    for i in 1..global_v_batch_count loop
        hcm_batchtask.finish_batch_process(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw(i),
          p_dtestrt  => global_v_batch_dtestrt,
          p_flgproc  => global_v_batch_flgproc(i),
          p_qtyproc  => global_v_batch_qtyproc(i),
          p_qtyerror => global_v_batch_qtyerror(i),
          p_oracode  => param_msg_error
        );
    end loop;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    for i in 1..global_v_batch_count loop
        hcm_batchtask.finish_batch_process(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw(i),
          p_dtestrt  => global_v_batch_dtestrt,
          p_flgproc  => 'N',
          p_oracode  => param_msg_error
        );
    end loop;
  end process_data;

  procedure get_error_list (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_error_list(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_error_list (json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    v_index_numappl   varchar2(100 char);
    cursor c_error_list is
      select  item01,item02,item03,item04,item05,item06,item07,item08
      from    ttemfilt
      where   codapp    = 'HRPM91B'
      and     coduser   = global_v_coduser
      order by numseq;
  begin
    obj_row    := json_object_t();
    for i in c_error_list loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.item01);
      obj_data.put('namemp',i.item02);
      obj_data.put('desc_codcomp',i.item03||' '||i.item04);
      obj_data.put('desc_codpos',i.item05||' '||i.item06);
      obj_data.put('process_topic',get_label_name('HRPM91BC1',global_v_lang,i.item08));
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;

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
end HRPM91B;

/
