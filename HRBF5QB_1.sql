--------------------------------------------------------
--  DDL for Package Body HRBF5QB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5QB" AS
  procedure initial_value (json_str in clob) AS
    json_obj                json_object_t;
  begin
    json_obj                := json_object_t(json_str);
    -- global
    v_chken                 := hcm_secur.get_v_chken;
    global_v_coduser        := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid       := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_batch_dtestrt  := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'), 'dd/mm/yyyyhh24miss');

    p_codempid              := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codcomp               := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll            := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_codlon                := hcm_util.get_string_t(json_obj, 'p_codlon');
    p_dteyrepay             := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_dtemthpay             := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_numperiod             := hcm_util.get_string_t(json_obj, 'p_numperiod');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_process is
    v_numlvl            temploy1.numlvl%type;
    v_staemp            temploy1.staemp%type;
    v_codcomp           temploy1.codcomp%type;
    v_typpayroll        temploy1.typpayroll%type;
    v_codlon            ttyploan.codlon%type;
    v_check             varchar2(1 char);
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcomp
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codempid is not null then
      begin
        select staemp, codcomp, numlvl, typpayroll
          into v_staemp, v_codcomp, v_numlvl, v_typpayroll
          from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if v_staemp is not null then
        if v_staemp = '9' then
          param_msg_error := get_error_msg_php('HR2101', global_v_lang);
          return;
        elsif not secur_main.secur1(v_codcomp, v_numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      end if;
    end if;
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
    if p_codlon is not null then
      begin
        select codlon
          into v_codlon
          from ttyploan
         where codlon = p_codlon;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'ttyploan');
        return;
      end;
    end if;
    begin
      select dtepaymt
        into p_dtepaymt
        from tdtepay
       where codcompy   = hcm_util.get_codcomp_level(v_codcomp, 1)
         and typpayroll = v_typpayroll
         and dteyrepay  = p_dteyrepay
         and dtemthpay  = p_dtemthpay
         and numperiod  = p_numperiod;
    exception when no_data_found then
      null;
    end;
    if p_dtepaymt is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tdtepay');
      return;
    end if;
  end check_process;

  function conv_sec_to_hms (v_timin number) return varchar2 is
    v_hour              number := 0;
    v_min               number := 0;
    v_sec               number := 0;
  begin
    v_hour              := floor(v_timin / 60 / 60);
    v_min               := floor(v_timin / 60) - (v_hour * 60);
    v_sec               := mod(v_timin, 60);
    return v_hour || ':' || lpad(v_min, 2, '0') || ':' || lpad(v_sec, 2, '0');
  end conv_sec_to_hms;

  procedure process_data (json_str_input in clob, json_str_output out clob) AS
    obj_data                json_object_t;
    v_codpaye               tintrteh.codpaye%type;
    v_codcomp               temploy1.codcomp%type;
    v_codcompy              tintrteh.codcompy%type;
    v_found                 boolean := false;
    v_success               number := 0;
    v_batch_dtestrt         date;

    cursor c_tloaninf is
      select a.codempid, b.codcomp, b.typpayroll, b.typemp, a.amtlon, a.codlon,
             a.numcont, b.numlvl, b.staemp, (b.dteeffex - 1) before_dteffex, c.costcent
        from tloaninf a, temploy1 b, tcenter c
       where b.codempid   = a.codempid
         and b.codcomp    = c.codcomp(+)
         and b.codcomp    like p_codcomp || '%'
         and b.typpayroll = nvl(p_typpayroll, b.typpayroll)
         and a.codempid   = nvl(p_codempid, a.codempid)
         and a.dteyrpay   = p_dteyrepay
         and a.mthpay     = p_dtemthpay
         and a.prdpay     = p_numperiod
         and a.codlon     = p_codlon
         and b.staemp     <> '9'
         and a.typpayamt  = '1'
         and a.staappr    = 'Y'
         and nvl(a.flgpay, 'N') = 'N'
       order by a.codempid;

  begin
    v_batch_dtestrt           := sysdate;
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
      if p_codempid is not null then
        v_codcomp               := hcm_util.get_temploy_field(p_codempid, 'codcomp');
        v_codcompy              := hcm_util.get_codcomp_level(v_codcomp, 1);
      else
        v_codcomp               := p_codcomp;
        v_codcompy              := hcm_util.get_codcomp_level(v_codcomp, 1);
      end if;
      begin
        select codpaye
          into v_codpaye
          from tintrteh
         where codcompy = v_codcompy
           and codlon   = p_codlon
           and dteeffec = (select max(dteeffec)
                             from tintrteh
                            where codcompy = v_codcompy
                              and codlon   = p_codlon
                              and trunc(dteeffec) <= trunc(sysdate));
      exception when no_data_found then
        null;
      end;
      for i in c_tloaninf loop
        v_found               := true;
        if secur_main.secur3(i.codcomp, i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          begin
            insert into tothinc
                      (
                        codempid, dteyrepay, dtemthpay, numperiod, codpay, codcomp, typpayroll,
                        typemp, qtypayda, qtypayhr, qtypaysc, ratepay, amtpay, codsys, costcent,
                        dtecreate, codcreate, coduser
                      )
               values (
                        i.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpaye, i.codcomp, i.typpayroll,
                        i.typemp, null, null, null, null, stdenc(i.amtlon, i.codempid, v_chken), 'BF', i.costcent,
                        sysdate, global_v_coduser, global_v_coduser
                      );
          exception when dup_val_on_index then
            update tothinc
               set amtpay    = stdenc(stddec(amtpay, i.codempid, v_chken) + nvl(i.amtlon, 0), i.codempid, v_chken),
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where codempid  = i.codempid
               and dteyrepay = p_dteyrepay
               and dtemthpay = p_dtemthpay
               and numperiod = p_numperiod
               and codpay    = v_codpaye;
          end;
          begin
            insert into tothinc2
                      (
                        codempid, dteyrepay, dtemthpay, numperiod, codpay, codcompw,
                        qtypayda, qtypayhr, qtypaysc, amtpay, codsys, costcent,
                        dtecreate, codcreate, coduser
                      )
               values (
                        i.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpaye, i.codcomp,
                        null, null, null, stdenc(i.amtlon, i.codempid, v_chken), 'BF', i.costcent,
                        sysdate, global_v_coduser, global_v_coduser
                      );
          exception when dup_val_on_index then
            update tothinc2
               set amtpay    = stdenc(stddec(amtpay, i.codempid, v_chken) + nvl(i.amtlon, 0), i.codempid, v_chken),
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where codempid  = i.codempid
               and dteyrepay = p_dteyrepay
               and dtemthpay = p_dtemthpay
               and numperiod = p_numperiod
               and codpay    = v_codpaye
               and codcompw  = i.codcomp;
          end;
          begin
            update tloaninf
               set flgpay    = 'Y',
                   dteissue  = p_dtepaymt,
                   dteptrn   = sysdate,
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where numcont   = i.numcont;
            v_success         := v_success + 1;
          exception when others then
            null;
          end;
        end if;
      end loop;
      if param_msg_error is null then
        if v_found then
          if v_success = 0 then
            global_v_batch_flgproc  := 'N';
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          else
            -- set complete batch process
            global_v_batch_flgproc  := 'Y';
            global_v_batch_qtyproc  := v_success;
            global_v_batch_qtyerror := null;
            obj_data        := json_object_t(get_response_message(null, get_error_msg_php('HR2715', global_v_lang), global_v_lang));
            obj_data.put('rec_tran', v_success);
            obj_data.put('rec_time', conv_sec_to_hms(floor((sysdate - v_batch_dtestrt) * 24 * 60 * 60)));
            json_str_output := obj_data.to_clob;
          end if;
        else
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tloaninf');
        end if;
      end if;
    end if;
    if param_msg_error is not null then
      rollback;
      global_v_batch_flgproc  := 'N';
      global_v_batch_qtyproc  := null;
      global_v_batch_qtyerror := null;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      commit;
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
    end if;
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
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end process_data;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is not null then
      v_response := replace(param_msg_error, '@#$%400');
    end if;
    return v_response;
  end check_index_batchtask;
end HRBF5QB;

/
