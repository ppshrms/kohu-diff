--------------------------------------------------------
--  DDL for Package Body HRAL85B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL85B" is
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

    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_codcalen          := hcm_util.get_string_t(json_obj, 'p_codcalen');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codtypy           TCODTYPY.codcodec%TYPE;
    v_codwork           TCODWORK.codcodec%TYPE;
    v_secur             boolean := false;
  begin
    if p_codempid is not null then
--      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid,false);
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy');
        return;
      end;
      --
      v_secur := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur = false  then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select codcodec
          into v_codtypy
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;

    if p_codcalen is not null then
      begin
        select codcodec
          into v_codwork
          from tcodwork
         where codcodec = p_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodwork');
        return;
      end;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtestrt');
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dteend');
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dtestrt');
      return;
    end if;
  end check_index;

  procedure process_data (json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    json_obj      json_object_t;
    v_numrec      number := 0;
    v_numrec_non  number := 0;
    v_error       varchar2(4000 char);
    v_err_table   varchar2(4000 char);
    v_response    varchar2(4000);

    v_codcompy    temploy1.codcomp%type; --15/02/2021
    v_year        number;
    v_year2       number;
    v_stdate      date;
    v_endate      date;

    cursor c_tleavecd is --15/02/2021
      select a.codleave,a.typleave,a.staleave
        from tleavecd a,tleavcom b
       where a.typleave = b.typleave
         and a.staleave = 'C'
         and b.codcompy = v_codcompy;

  begin
msg_err2('IN process_data');
    initial_value(json_str_input);
    check_index;
    json_obj := json_object_t();
    if param_msg_error is null then
      Hral85b_Batch.cal_process(p_codempid, p_codcomp, p_codcalen, p_typpayroll, p_dtestrt, p_dteend, global_v_coduser, v_numrec, v_error, v_err_table);
      hral85b_batch.gen_compensate(p_codempid, p_codcomp, p_codcalen, p_typpayroll, p_dtestrt, global_v_coduser, v_numrec_non, v_error, v_err_table);

      --<<15/02/2021
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
      for c1 in c_tleavecd loop
        std_al.cycle_leave(v_codcompy,p_codempid,c1.codleave,p_dtestrt,v_year,v_stdate,v_endate);
        v_year  := (v_year - global_v_zyear);

        std_al.cycle_leave(v_codcompy,p_codempid,c1.codleave,p_dteend,v_year,v_stdate,v_endate);
        v_year2  := (v_year - global_v_zyear);    
        if v_year <> v_year2 then
          hral85b_batch.gen_compensate(p_codempid, p_codcomp, p_codcalen, p_typpayroll, p_dteend, global_v_coduser, v_numrec_non, v_error, v_err_table);
        end if;
      end loop;
      -->>15/02/2021
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      obj_row.put('numrec', v_numrec);

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

  --
  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'AL85';

  begin
    null;
-- /*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = v_codapp;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(v_codapp,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;
  --

end HRAL85B;

/
