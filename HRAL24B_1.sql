--------------------------------------------------------
--  DDL for Package Body HRAL24B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL24B" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcomp             := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dteeffec               := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_dteeffec_en         := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec_en'),'dd/mm/yyyy');

    if p_dteeffec_en is null then
       p_dteeffec_en      := to_date(hcm_util.get_string_t(json_obj,'p_endate'),'dd/mm/yyyy');
    end if;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,
                               global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
  v_flgsecu		boolean	:= null;
  v_codtrn    tcodmove.codcodec%type;
  begin

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
    if param_msg_error is not null then
      return;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
    if p_dteeffec > sysdate then
      param_msg_error := get_error_msg_php('HR4508',global_v_lang,'dteeffec');
      return;
    end if;
    begin
      select codcodec into v_codtrn
        from tcodmove
       where typmove in('1','2','6','M')
         and rownum <= 1;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcomp1');
      return;
    end;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_row         json_object_t;
    v_rcnt          number := 0;
  begin
    begin
      select dtework into p_dtework
       from tattence
      where codcomp like p_codcomp
        and dtework = (select max(dtework)
                         from tattence
                        where codcomp like p_codcomp)
        and rownum <= 1;
    exception when no_data_found then
      p_dtework := null;
    end;

    obj_row    := json_object_t();

    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('dtework', to_char(p_dtework,'dd/mm/yyyy'));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure initial_batchtask is
  begin
    for i in 1..global_v_batch_count loop
      global_v_batch_codalw(i)   := global_v_batch_codapp||to_char(i);
      global_v_batch_flgproc(i)  := 'N';
      global_v_batch_qtyproc(i)  := 0;
      global_v_batch_qtyerror(i) := 0;
    end loop;
  end;

  procedure get_data_process(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    initial_batchtask;
    check_index;
    if param_msg_error is null then
      gen_data_process(json_str_output);
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
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    for i in 1..global_v_batch_count loop
        hcm_batchtask.finish_batch_process(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw(i),
          p_dtestrt  => global_v_batch_dtestrt,
          p_flgproc  => 'N',
          p_oracode => param_msg_error
        );
    end loop;
  end;

  procedure gen_data_process(json_str_output out clob)as
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_recemp        number := 0;
    v_rectrans      number := 0;
    v_recter        number := 0;
    v_recchng       number := 0;
  begin
    hral24b_batch.cal_process (p_codcomp||'%', global_v_coduser,
                                                      p_dteeffec,   p_dteeffec_en ,
                                                      v_recemp,    v_rectrans,
                                                      v_recter,       v_recchng);

    obj_row    := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('recemp', v_recemp);
    obj_row.put('recter', v_recter);
    obj_row.put('rectrans', v_rectrans);
    obj_row.put('recchng', v_recchng);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));

    json_str_output := obj_row.to_clob;

    -- set complete batch process
    global_v_batch_flgproc(1)  := 'Y';
    global_v_batch_flgproc(2)  := 'Y';
    global_v_batch_flgproc(3)  := 'Y';
    global_v_batch_qtyproc(1)  := v_recemp;
    global_v_batch_qtyproc(2)  := v_recter;
    global_v_batch_qtyproc(3)  := v_rectrans;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    for i in 1..global_v_batch_count loop
        hcm_batchtask.finish_batch_process(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw(i),
          p_dtestrt  => global_v_batch_dtestrt,
          p_flgproc  => 'N',
          p_oracode => param_msg_error
        );
    end loop;
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
end HRAL24B;

/
