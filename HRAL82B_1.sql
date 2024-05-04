--------------------------------------------------------
--  DDL for Package Body HRAL82B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL82B" as

  procedure initial_value(json_str_input in clob) as
  json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_flgprocess        := hcm_util.get_string_t(json_obj,'p_flgprocess');
    p_flgtyp            := hcm_util.get_string_t(json_obj,'p_flgtyp');

    p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    p_dtecal            := to_date(hcm_util.get_string_t(json_obj,'p_dtecal'),'ddmmyyyy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
      gen_process(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
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
  end get_process;

  procedure check_process as
  begin
    if p_dtecal is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_flgprocess is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif p_flgprocess = '1' then
      null;
    elsif p_flgprocess = '2' then
        if p_flgtyp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif p_flgtyp = '1' and p_year is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif p_flgtyp = '2' and (p_numperiod is null or p_dtemthpay is null or p_dteyrepay is null)then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    else
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_codempid is null and p_codcomp is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
    end if;

    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;

    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
        ----p_codcomp := hcm_util.get_codcomp_level(p_codcomp,1);
    end if;
  end check_process;

  procedure gen_process(json_str_output out clob) as
    v_numrec            number := 0;
    v_error             varchar2(4000 char);
    v_err_table         varchar2(4000 char);
    json_obj            json_object_t;
  begin
--    if p_flgprocess = '1' then
    hral82b_batch.gen_vacation(p_codempid,p_codcomp,p_dtecal,global_v_coduser,v_numrec);
    /*hral82b_batch.cal_process(p_codempid,p_codcomp,p_dtecal,global_v_coduser,v_numrec,v_error,v_err_table);
    if v_error is not null then
        param_msg_error := get_error_msg_php(v_error,global_v_lang,v_err_table);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    if p_flgprocess = '2' then
        if p_flgtyp = '1' then
            hral82b_batch.cal_payvac_yearly(p_codempid,p_codcomp,p_dtecal,p_year,global_v_coduser,
                                            v_numrec,v_error,v_err_table);
            if v_error is not null then
                param_msg_error := get_error_msg_php(v_error,global_v_lang,v_err_table);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                return;
            end if;
        elsif p_flgtyp = '2' then
            hral82b_batch.cal_payvac_resign(p_codempid,p_codcomp,p_dtecal,p_dteyrepay,p_dtemthpay,p_numperiod,global_v_coduser,
                              v_numrec,v_error,v_err_table);
            if v_error is not null then
                param_msg_error := get_error_msg_php(v_error,global_v_lang,v_err_table);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                return;
            end if;
        end if;
    end if;*/
    param_msg_error := get_error_msg_php('HR2715', global_v_lang);
    json_obj        := json_object_t(get_response_message(null, param_msg_error, global_v_lang));
    json_obj.put('numrec', to_char(nvl(v_numrec,0), 'fm99,990'));

--    json_obj.put('coderror' , '200');
    json_str_output := json_obj.to_clob;

    -- set complete batch process
    global_v_batch_flgproc := 'Y';
    global_v_batch_qtyproc := nvl(v_numrec,0);
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
  end gen_process;

  procedure get_latestupdate(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_latestupdate;
    if param_msg_error is null then
      gen_latestupdate(json_str_output);
    else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_latestupdate as
  begin
    if p_codcomp is null and p_codempid is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcomp is null and p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end;

  procedure gen_latestupdate(json_str_output out clob) as
    json_obj  json_object_t;
    v_dayeupd date;
    v_codcomp varchar2(4000 char);
  begin
    if p_codempid is not null then
      begin
        select codcomp --hcm_util.get_codcomp_level(codcomp, 1)
          into v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_codcomp := '';
      end;
    else
      v_codcomp := p_codcomp;--hcm_util.get_codcomp_level(p_codcomp,1);
    end if;

    begin
        select  dayeupd
        into    v_dayeupd
        from    tmthend
        where   codcomp like v_codcomp||'%'
        and     rownum <= 1
        order by codcomp;
    exception when others then null;
    end;
    json_obj := json_object_t();
--    json_obj.put('dtecal',to_char(sysdate,'dd/mm/yyyy'));
    json_obj.put('dayeupd',to_char(v_dayeupd,'dd/mm/yyyy'));
    json_obj.put('coderror','200');
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;
end HRAL82B;

/
