--------------------------------------------------------
--  DDL for Package Body HRBF55B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF55B" AS
/*
   date        : 27/03/2021 16:01
*/
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

    p_codcomp               := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll            := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_dtepaymt              := to_date(hcm_util.get_string_t(json_obj,'p_dtepaymt'), 'DD/MM/YYYY');
    p_dteyrepay             := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_dtemthpay             := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_numperiod             := hcm_util.get_string_t(json_obj, 'p_numperiod');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_dtepaymt (v_dtepaymt out tdtepay.dtepaymt%type) is
  begin
    begin
      select dtepaymt --,dtestrt
        into v_dtepaymt--,v_dtestrt
        from tdtepay
       where codcompy   = hcm_util.get_codcomp_level(p_codcomp, 1)
         and typpayroll = p_typpayroll
         and dteyrepay  = p_dteyrepay
         and dtemthpay  = p_dtemthpay
         and numperiod  = p_numperiod;
    exception when no_data_found then
      null;
    end;
    if v_dtepaymt is null then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tdtepay');
      return;
    end if;
  end check_dtepaymt;

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
    check_dtepaymt(p_dtepaymt);
    if param_msg_error is not null then
      return;
    end if;
  end check_process;

  function find_costcent (v_codcomp tcenter.codcomp%type) return tcenter.costcent%type is
    v_costcent              tcenter.costcent%type;
  begin
    begin
      select costcent
        into v_costcent
        from tcenter
       where codcomp = v_codcomp;
    exception when no_data_found then
      null;
    end;
    return v_costcent;
  end find_costcent;

  procedure process_data (json_str_input in clob, json_str_output out clob) AS
    obj_data                json_object_t;
    v_codlon                tloaninf.codlon%type;
    v_dteeffec              tintrteh.dteeffec%type;
    v_codpaye               tintrteh.codpaye%type;
    v_codcompy              tintrteh.codcompy%type;
    v_found                 boolean := false;
    v_success               number := 0;
    v_amount                number := 0;
    v_codpayc               tintrteh.codpayc%type;
    v_codpayd               tintrteh.codpayd%type;
    v_costcent              tcenter.costcent%type;
    v_amtnpfin              tloaninf.amtnpfin%type;
    v_amtnpfin_new          tloaninf.amtnpfin%type;
    v_amtintovr             tloaninf.amtintovr%type;
    v_stalon                tloaninf.stalon%type;
    v_dteaccls              tloaninf.dteaccls%type;
    v_amtintrest            ttrepayh.amtintrest%type;
    v_dtelpay               date ;
    cursor c1 is
      select a.numcont, a.dterepmt, a.typtran, a.codempid,
             b.codcomp, b.typpayroll, b.typemp, a.typpay, a.numperiod,
             a.dtemthpay, a.dteyrepay, a.amtpfin, a.amtpint, a.amtrepmt,
             a.amtintst
        from tloanpay a, temploy1 b
       where a.codempid   = b.codempid
         and b.codcomp    like p_codcomp || '%'
         and b.typpayroll = p_typpayroll
         and a.numperiod  = p_numperiod
         and a.dtemthpay  = p_dtemthpay
         and a.dteyrepay  = p_dteyrepay
         and a.typpay     = '1'
         and nvl(a.flgtranpy, 'N') = 'N'
       order by a.numcont, a.dterepmt;

  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
      for i in c1 loop
        v_found               := true;
        if secur_main.secur3(i.codcomp, i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          if (nvl(i.amtpfin, 0) + nvl(i.amtpint, 0)) > 0 then
            v_codcompy            := hcm_util.get_codcomp_level(i.codcomp, 1);
            v_costcent            := find_costcent(i.codcomp);
            begin
              select codlon ,dtelpay
                into v_codlon ,v_dtelpay
                from tloaninf
               where numcont = i.numcont;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tloaninf');
              return;
            end;
            begin
              select codpayc, codpayd
                into v_codpayc, v_codpayd
                from tintrteh
               where codcompy = v_codcompy
                 and codlon   = v_codlon
                 and dteeffec = (select max(dteeffec)
                                   from tintrteh
                                  where codcompy = v_codcompy
                                    and codlon   = v_codlon
                                    and trunc(dteeffec) <= trunc(sysdate));
            exception when no_data_found then
              null;
            end;
            if  i.amtpfin  > 0 then
                begin
                  insert into tothinc
                            (
                              codempid, dteyrepay, dtemthpay, numperiod, codpay, codcomp, typpayroll,
                              typemp, qtypayda, qtypayhr, qtypaysc, ratepay, amtpay, codsys, costcent,
                              dtecreate, codcreate, coduser
                            )
                     values (
                              i.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpayc, i.codcomp, i.typpayroll,
                              i.typemp, null, null, null, null, stdenc(i.amtpfin, i.codempid, v_chken), 'BF', v_costcent,
                              sysdate, global_v_coduser, global_v_coduser
                            );
                exception when dup_val_on_index then
                  update tothinc
                     set amtpay    = stdenc(stddec(amtpay, i.codempid, v_chken) + nvl(i.amtpfin, 0), i.codempid, v_chken),
                         dteupd    = sysdate,
                         coduser   = global_v_coduser
                   where codempid  = i.codempid
                     and dteyrepay = p_dteyrepay
                     and dtemthpay = p_dtemthpay
                     and numperiod = p_numperiod
                     and codpay    = v_codpayc;
                end;


            begin
              insert into tothinc2
                        (
                          codempid, dteyrepay, dtemthpay, numperiod, codpay, codcompw,
                          qtypayda, qtypayhr, qtypaysc, amtpay, codsys, costcent,
                          dtecreate, codcreate, coduser
                        )
                 values (
                          i.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpayc, i.codcomp,
                          null, null, null, stdenc(i.amtpfin, i.codempid, v_chken), 'BF', v_costcent,
                          sysdate, global_v_coduser, global_v_coduser
                        );
            exception when dup_val_on_index then
              update tothinc2
                 set amtpay    = stdenc(stddec(amtpay, i.codempid, v_chken) + nvl(i.amtpfin, 0), i.codempid, v_chken),
                     dteupd    = sysdate,
                     coduser   = global_v_coduser
               where codempid  = i.codempid
                 and dteyrepay = p_dteyrepay
                 and dtemthpay = p_dtemthpay
                 and numperiod = p_numperiod
                 and codpay    = v_codpayc
                 and codcompw  = i.codcomp;
            end;
            end if;

            if  i.amtpint > 0  then
                begin
                  insert into tothinc
                            (
                              codempid, dteyrepay, dtemthpay, numperiod, codpay, codcomp, typpayroll,
                              typemp, qtypayda, qtypayhr, qtypaysc, ratepay, amtpay, codsys, costcent,
                              dtecreate, codcreate, coduser
                            )
                     values (
                              i.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpayd, i.codcomp, i.typpayroll,
                              i.typemp, null, null, null, null, stdenc(i.amtpint, i.codempid, v_chken), 'BF', v_costcent,
                              sysdate, global_v_coduser, global_v_coduser
                            );
                exception when dup_val_on_index then
                  update tothinc
                     set amtpay    = stdenc(stddec(amtpay, i.codempid, v_chken) + nvl(i.amtpint, 0), i.codempid, v_chken),
                         dteupd    = sysdate,
                         coduser   = global_v_coduser
                   where codempid  = i.codempid
                     and dteyrepay = p_dteyrepay
                     and dtemthpay = p_dtemthpay
                     and numperiod = p_numperiod
                     and codpay    = v_codpayd;
                end;
                begin
                  insert into tothinc2
                            (
                              codempid, dteyrepay, dtemthpay, numperiod, codpay, codcompw,
                              qtypayda, qtypayhr, qtypaysc, amtpay, codsys, costcent,
                              dtecreate, codcreate, coduser
                            )
                     values (
                              i.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpayd, i.codcomp,
                              null, null, null, stdenc(i.amtpint, i.codempid, v_chken), 'BF', v_costcent,
                              sysdate, global_v_coduser, global_v_coduser
                            );
                exception when dup_val_on_index then
                  update tothinc2
                     set amtpay    = stdenc(stddec(amtpay, i.codempid, v_chken) + nvl(i.amtpint, 0), i.codempid, v_chken),
                         dteupd    = sysdate,
                         coduser   = global_v_coduser
                   where codempid  = i.codempid
                     and dteyrepay = p_dteyrepay
                     and dtemthpay = p_dtemthpay
                     and numperiod = p_numperiod
                     and codpay    = v_codpayd
                     and codcompw  = i.codcomp;
                end;
            end if;

            begin
              select amtnpfin
                into v_amtnpfin
                from tloaninf
               where numcont = i.numcont;
            exception when no_data_found then
              v_amtnpfin        := 0;
            end;
            begin
              select sum(amtintrest)
                into v_amtintrest
                from ttrepayh
               where numcont        = i.numcont
                 --and trunc(dtestrt) = trunc(i.dterepmt)
                 --and trunc(dteend)  = trunc(sysdate);
                 and trunc(dtestrt) >= v_dtelpay
                 and trunc(dteend)  = trunc(i.dterepmt) ;
            exception when no_data_found then
              v_amtintrest      := 0;
            end;

--<<user14 12/01/2021
            --v_amtnpfin_new      := v_amtnpfin + nvl(i.amtpfin, 0);
            v_amtnpfin_new      := v_amtnpfin - nvl(i.amtpfin, 0);
-->>user14 12/01/2021

            v_amtintovr         := greatest(nvl(i.amtintst, 0) + nvl(v_amtintrest, 0) - nvl(i.amtpint, 0),0);
            v_stalon            := 'P';
            v_dteaccls          := null;
            if v_amtnpfin_new = 0 and v_amtintovr = 0 then
              v_stalon          := 'C';
              v_dteaccls        := sysdate;
            end if;
            begin
              update tloaninf
                 set amtnpfin  = v_amtnpfin_new,
                     amtintovr = v_amtintovr,
                     yrelcal   = p_dteyrepay,
                     mthlcal   = p_dtemthpay,
                     prdlcal   = p_numperiod,
                     dtelpay   = i.dterepmt,
                     amttotpay = (nvl(amttotpay, 0) + nvl(i.amtpfin, 0)),
                     qtyperip  = qtyperip + 1,
                     stalon    = v_stalon,
                     dteaccls  = nvl(v_dteaccls, dteaccls),
                     dteupd    = sysdate,
                     coduser   = global_v_coduser
               where numcont   = i.numcont;
            exception when others then
              null;
            end;
            begin
              update tloanpay
                 set amtpfinen = v_amtnpfin_new,
                     amtinten  = v_amtintovr,
                     dtetrnpy  = trunc(sysdate),
                     flgtranpy = 'Y',
                     dteupd    = sysdate,
                     coduser   = global_v_coduser
               where numcont   = i.numcont
                 and dterepmt  = i.dterepmt
                 and typtran   = i.typtran;
              v_success         := v_success + 1;
              v_amount          := v_amount + nvl(i.amtpfin, 0) + nvl(i.amtpint, 0);
            exception when others then
              null;
            end;
          end if;
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
            obj_data.put('rec_amount', v_amount);
            json_str_output := obj_data.to_clob;
          end if;
        else
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tloanpay');
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

  procedure get_dtepaymt (json_str_input in clob, json_str_output out clob) AS
    obj_data                json_object_t;
  begin
    initial_value(json_str_input);
    check_dtepaymt(p_dtepaymt);
    if param_msg_error is null then
      obj_data                := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtepaymt', to_char(p_dtepaymt, 'DD/MM/YYYY'));

      json_str_output := obj_data.to_clob;
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end get_dtepaymt;

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

  procedure get_lastpay_info (json_str_input in clob, json_str_output out clob) AS
    obj_data                json_object_t;
    v_numperiod             tloanpay.numperiod%type;
    v_dtemthpay             tloanpay.dtemthpay%type;
    v_dteyrepay             tloanpay.dteyrepay%type;
  begin
    initial_value(json_str_input);
    check_dtepaymt(p_dtepaymt);
    if param_msg_error is null then
      begin
        select numperiod, dtemthpay, dteyrepay
          into v_numperiod, v_dtemthpay, v_dteyrepay
          from tloanpay
         where codcomp    like p_codcomp || '%'
           and typpayroll = p_typpayroll
           and typpay     = '1'
           and flgtranpy  = 'Y'
         fetch first 1 rows only;
      exception when no_data_found then
        null;
      end;
      obj_data                := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('typpayroll', p_typpayroll);
      obj_data.put('numperiod', v_numperiod);
      obj_data.put('dtemthpay', v_dtemthpay);
      obj_data.put('dteyrepay', v_dteyrepay);
      obj_data.put('dtepaymt', to_char(p_dtepaymt, 'DD/MM/YYYY'));

      json_str_output := obj_data.to_clob;
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end get_lastpay_info;
end HRBF55B;

/
