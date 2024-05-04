--------------------------------------------------------
--  DDL for Package Body HRPY46B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY46B" as

  function cal_hhmiss (p_st date,p_en date) return varchar2 is
    v_num  number := 0;
    v_sc   number := 0;
    v_mi   number := 0;
    v_hr   number := 0;
    v_time varchar2(500 char);
  begin
    v_num  := ((p_en - p_st) * 86400) + 1;
    v_hr   := trunc(v_num/3600);
    v_mi   := mod  (v_num,3600);
    v_sc   := mod  (v_mi ,60);
    v_mi   := trunc(v_mi /60);
    v_time := lpad(v_hr,2,0) || ':' || lpad(v_mi,2,0) || ':' || lpad(v_sc,2,0);
    return (v_time);
  end;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(obj_detail,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_month             := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll        := hcm_util.get_string_t(obj_detail,'typpayroll');
    p_codempid          := hcm_util.get_string_t(obj_detail,'codempid_query');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_process as
    v_flgsecu		boolean;
    v_codempid		temploy1.codempid%type;
  begin
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp,codempid');
      return;
    end if;

    if p_codempid is not null then
      p_codcomp := '';
      p_typpayroll := '';
      begin
        select codempid
        into v_codempid
        from temploy1
        where codempid = p_codempid;
        v_flgsecu      := secur_main.secur2(p_codempid,global_v_coduser,
                                            global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang);
        return;
      end;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
  end check_process;

  procedure get_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
        gen_process(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
        return;
    end if;
    
    if global_v_batch_qtyerror > 0 then
      global_v_batch_descproc := '('||get_label_name('HRPY46B', global_v_lang, '60') || ': ' || global_v_batch_qtyerror || ' ' || get_label_name('HRPY46B', global_v_lang, '70')||')';
    end if;
    
    -- set complete batch process
    hcm_batchtask.finish_batch_process(
      p_codapp    => global_v_batch_codapp,
      p_coduser   => global_v_coduser,
      p_codalw    => global_v_batch_codalw,
      p_dtestrt   => global_v_batch_dtestrt,
      p_flgproc   => global_v_batch_flgproc,
      p_qtyproc   => global_v_batch_qtyproc,
      p_qtyerror  => 0,
      p_oracode   => param_msg_error,
      p_descproc  => global_v_batch_descproc
    );
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;

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

  procedure gen_process(json_str_output out clob) as
    obj_detail       json_object_t := json_object_t();
    v_codpaypy1      tcontrpy.codpaypy1%type;
    v_codpaypy8      tcontrpy.codpaypy8%type;
    v_codcurr        tcontrpy.codcurr%type;
    v_codcomp        tcenter.codcomp%type;
    v_sumqtyerr      number :=0;
    v_sumqtyproc     number :=0;
    v_sysdate_before date;
    v_sysdate_after  date;
    v_error          varchar2(4000 char);
    v_flg_exist      boolean;
    v_flg_permission boolean;
  begin
    if p_codcomp is not null then
      v_codcomp := p_codcomp;
    else
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_codcomp := null;
      end;
    end if;
    begin
      select codpaypy1  ,codpaypy8  ,codcurr
        into v_codpaypy1,v_codpaypy8,v_codcurr
        from tcontrpy
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                            and dteeffec < trunc(sysdate));
    exception when no_data_found then
      v_codpaypy1 := null;
      v_codpaypy8 := null;
      v_codcurr := null;
    end;
    v_sysdate_before := sysdate;

    hrpy46b_batch.start_process(p_codempid,v_codcomp,p_typpayroll,
                                p_year    ,p_month  ,v_codcurr   ,
                                global_v_coduser    ,
                                v_flg_exist         ,
                                v_flg_permission);
    v_sysdate_after  := sysdate;
    obj_detail.put('processTime',cal_hhmiss(v_sysdate_before,v_sysdate_after));
    begin
      select sum(qtyerr) ,sum(qtyproc)
        into v_sumqtyerr ,v_sumqtyproc
        from tprocount
       where codapp  = 'HRPY46B'
         and coduser = global_v_coduser
         and flgproc = 'Y';
    exception when no_data_found then
      v_sumqtyerr  := null;
      v_sumqtyproc := null;

    end;
    obj_detail.put('recordC',nvl(to_char(v_sumqtyerr ),'0'));
    obj_detail.put('recordP',nvl(to_char(v_sumqtyproc),'0'));

    -- set complete batch process
    global_v_batch_qtyproc := nvl(to_char(v_sumqtyproc),'0');
    global_v_batch_qtyerror:= nvl(to_char(v_sumqtyerr ),'0');

    begin
      select codempid || '-' || remark
        into v_error
        from tprocount
       where codapp  = 'HRPY46B'
         and coduser = global_v_coduser
         and flgproc = 'E'
         and rownum  = 1;
      obj_detail.put('response',v_error);
      obj_detail.put('coderror','400');
      rollback;
    exception when no_data_found then
      null;
    end;

    if not v_flg_exist then--nut v_sumqtyproc = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTAXCUR');
      obj_detail.put('response',hcm_secur.get_response(null,param_msg_error,global_v_lang));
      obj_detail.put('coderror','400');
    elsif not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      obj_detail.put('response',hcm_secur.get_response(null,param_msg_error,global_v_lang));
      obj_detail.put('coderror','400');
    else
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      obj_detail.put('response',hcm_secur.get_response(null,param_msg_error,global_v_lang));
      obj_detail.put('coderror','200');

      -- set complete batch process
      global_v_batch_flgproc := 'Y';
    end if;
    json_str_output := obj_detail.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;

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
end hrpy46b;

/
