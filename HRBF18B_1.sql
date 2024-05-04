--------------------------------------------------------
--  DDL for Package Body HRBF18B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF18B" AS
--redmine/6855  11/09/2021 14:30

  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_numperiod         := hcm_util.get_string_t(json_obj, 'p_numperiod');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_process is
    v_staemp            temploy1.staemp%type;
    v_codcomp           temploy1.codcomp%type;
    v_typpayroll        temploy1.typpayroll%type;
  begin
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is not null then
        if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    end if;
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
  end check_process;

  procedure find_codpay (v_codcomp temploy1.codcomp%type, v_codincrt out tcontrbf.codincrt%type, v_coddisovr out tcontrbf.coddisovr%type) as
    v_codcompy          tcontrbf.codcompy%type;
  begin
    v_codcompy          := hcm_util.get_codcomp_level(v_codcomp, 1);
    begin
      select codincrt, coddisovr
        into v_codincrt, v_coddisovr
        from tcontrbf
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontrbf
                          where codcompy = v_codcompy
                            and dteeffec < sysdate);
    exception when no_data_found then
      v_codincrt      := null;
      v_coddisovr     := null;
    end;
    if v_codincrt is null or v_coddisovr is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tcontrbf');
      return;
    end if;
  end find_codpay;

  procedure get_process (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
      gen_process(json_str_output);
    end if;
    if param_msg_error is not null then
      rollback;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_process;

  procedure gen_process (json_str_output out clob) AS
    obj_data            json_object_t;
    v_period            trepay.dtelstpay%type;

    v_found             boolean := false;
    v_chksecur       boolean := false;
    v_secur             boolean := false;

    v_rcnt1             number := 0;
    v_rcnt2             number := 0;
    v_codincrt          tcontrbf.codincrt%type;
    v_coddisovr         tcontrbf.coddisovr%type;
    v_amtpaye           tclnsum.amtpaye%type;
    v_amtpayf           tclnsum.amtpayf%type;    
    v_amtoutstd         trepay.amtoutstd%type;
    v_dteclose          trepay.dteclose%type;
    v_amtclose          trepay.amtclose%type;
    v_flgclose          trepay.flgclose%type;
    v_table             varchar2(20 char) := 'tclnsinf';
    v_amtrepaym         trepay.amtrepaym%type := 0;

    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    ----
    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;

    cursor c1 is
            select a.codempid, a.flgdocmt, b.typpayroll,
                     least (decode(nvl(a.amtemp,0),0,a.amtalw, a.amtemp) , a.amtalw) amtalw, nvl(a.amtemp,0) amtemp, --redmine 6855
                     --least (a.amtemp , a.amtalw) amtalw ,     --redmine 6855
                     b.codcomp, a.dtereq,
                     a.typpay, a.numvcher, a.amtovrpay, b.typemp, a.codrel, c.costcent, a.typamt, a.dtecrest
              from tclnsinf a, temploy1 b, tcenter c
             where a.codempid   = b.codempid
               and a.codcomp    = c.codcomp(+)
               and a.codcomp    like p_codcomp || '%'
               and a.codempid   = nvl(p_codempid, a.codempid)
               and b.typpayroll = nvl(p_typpayroll, b.typpayroll)
               and a.dteyrepay  = p_dteyrepay
               and a.dtemthpay  = p_dtemthpay
               and a.numperiod  = p_numperiod
               and nvl(a.staappov, 'N') = 'Y'
               and nvl(a.flgtranpy, 'N') = 'N'
               and a.typpay     = '2'
  order by a.codempid;

    cursor c2 is
            select a.codempid, a.amtoutstd, a.qtyrepaym, a.amtrepaym, a.dtestrpm,
                   a.qtypaid, a.dteclose, a.amtclose, a.dtelstpay, a.amtlstpay,
                   a.amttotpay, a.flgclose, b.codcomp, b.typpayroll, b.typemp, c.costcent
              from trepay a, temploy1 b, tcenter c
             where a.codempid   = b.codempid
               and b.codcomp    = c.codcomp(+)
               and b.codcomp    like p_codcomp || '%'
               and a.codempid   = nvl(p_codempid, a.codempid)
               and b.typpayroll = nvl(p_typpayroll, b.typpayroll)
               and a.dteclose   is null
               and a.dtestrpm   <= v_period
               and nvl(a.flgclose, 'N') = 'N'
               and (a.dtelstpay <> v_period or a.dtelstpay is null)
       order by a.codempid;

  begin
    v_period      := p_dteyrepay || lpad(p_dtemthpay, 2, '0') || p_numperiod;
    if p_codcomp is not null then
      v_codcomp := p_codcomp ||'%';
    end if;

    for i1 in c1 loop
      if nvl(i1.amtalw,0)  > 0 then
        v_found       := true;
        v_codempid := i1.codempid ;
        if secur_main.secur2(i1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          v_chksecur  := true;
          if nvl(i1.amtemp,0) > 0 then
            find_codpay(i1.codcomp, v_codincrt, v_coddisovr);
            if param_msg_error is not null then
              return;
            end if;

            v_rcnt1 := v_rcnt1 + 1;
            begin
              insert into tothinc
                       ( codempid, dteyrepay, dtemthpay, numperiod, codpay, codcomp, typpayroll,
                         typemp, qtypayda, qtypayhr, qtypaysc, ratepay, amtpay, codsys, costcent,
                         dtecreate, codcreate, coduser )
                values ( i1.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codincrt, i1.codcomp, i1.typpayroll,
                         i1.typemp, null, null, null, null, stdenc(nvl(i1.amtalw, 0), i1.codempid, v_chken), 'BF', i1.costcent,
                         sysdate, global_v_coduser, global_v_coduser );
            exception when dup_val_on_index then
             update tothinc
                set amtpay    = stdenc((stddec(amtpay, codempid, v_chken) + nvl(i1.amtalw, 0)), codempid, v_chken),
                    dteupd    = sysdate,
                    coduser   = global_v_coduser
              where codempid  = i1.codempid
                and dteyrepay = p_dteyrepay
                and dtemthpay = p_dtemthpay
                and numperiod = p_numperiod
                and codpay    = v_codincrt;
            end;
            begin
              insert into tothinc2
                       ( codempid, dteyrepay, dtemthpay, numperiod, codpay, codcompw,
                         qtypayda, qtypayhr, qtypaysc, amtpay, codsys, costcent,
                         dtecreate, codcreate, coduser )
                values ( i1.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codincrt, i1.codcomp,
                         null, null, null, stdenc(nvl(i1.amtalw, 0), i1.codempid, v_chken), 'BF', i1.costcent,
                         sysdate, global_v_coduser, global_v_coduser );
            exception when dup_val_on_index then
             update tothinc2
                    set amtpay    = stdenc((stddec(amtpay, codempid, v_chken) + nvl(i1.amtalw, 0)), codempid, v_chken),
                        dteupd    = sysdate,
                        coduser   = global_v_coduser
              where codempid  = i1.codempid
                and dteyrepay = p_dteyrepay
                and dtemthpay = p_dtemthpay
                and numperiod = p_numperiod
                and codpay    = v_codincrt
                and codcompw  = i1.codcomp;
            end;
            --end if;  --if nvl(i.amtemp,0) > 0 then

            v_amtpaye         := 0;
            v_amtpayf         := 0;
            if   i1.codrel = 'E' then
              v_amtpaye         := nvl(i1.amtalw, 0);
            else
              v_amtpayf         := nvl(i1.amtalw, 0);
            end if;
            begin
              insert into tclnsum
                       ( codempid, dteyrepay, dtemthpay, numperiod, codcomp, typpayroll,
                         typemp, amtpaye, amtpayf, amtrepay, codcurr,
                         dtecreate, codcreate, coduser )
            values (  i1.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, i1.codcomp, i1.typpayroll,
                         i1.typemp, v_amtpaye, v_amtpayf, null, null,
                         sysdate, global_v_coduser, global_v_coduser );
            exception when dup_val_on_index then
              update tclnsum
                  set amtpaye   = (nvl(amtpaye, 0) + v_amtpaye),
                      amtpayf   = (nvl(amtpayf, 0) + v_amtpayf),
                      dteupd    = sysdate,
                      coduser   = global_v_coduser
              where codempid  = i1.codempid
                  and dteyrepay = p_dteyrepay
                  and dtemthpay = p_dtemthpay
                  and numperiod = p_numperiod;
           end;
        end if;  --if nvl(i.amtemp,0) > 0 then 

       begin
         update tclnsinf
            set flgtranpy = 'Y',
                 dtetranpy = sysdate,
                 --flgupd    = 'Y',
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
          where codempid  = i1.codempid
            and dteyrepay = p_dteyrepay
            and dtemthpay = p_dtemthpay
            and numperiod = p_numperiod
            and nvl(flgtranpy, 'N') = 'N'
            and typpay    = '2';
       exception when others then
         null;
       end;                          
         --v_rcnt1       := v_rcnt1 + 1;  --redmine6855
      end if;        --if secur_main.

    end if;   --if i1.amtalw > 0 then

  end loop;-- for i1 in c1 loop

    for i2 in c2 loop
      v_secur       := secur_main.secur2(i2.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal);
      if  v_secur then
                if p_dteyrepay < to_number(substr(i2.dtelstpay, 0, 4)) then
                  exit;
                elsif p_dteyrepay = to_number(substr(i2.dtelstpay, 0, 4)) and p_dtemthpay < to_number(substr(i2.dtelstpay, 5, 2)) then
                  exit;
                elsif p_dteyrepay = to_number(substr(i2.dtelstpay, 0, 4)) and p_dtemthpay = to_number(substr(i2.dtelstpay, 5, 2)) and p_numperiod < to_number(substr(i2.dtelstpay, 7, 1)) then
                 exit;
                end if;
      end  if;
      v_found       := true;
      if   v_secur then
        v_chksecur  := true;
        v_amtrepaym         := i2.amtrepaym;
        if (i2.qtyrepaym - i2.qtypaid) = 1 then
          v_amtrepaym         := nvl(i2.amtoutstd, 0);
        end if;
        v_amtoutstd         := nvl(i2.amtoutstd, 0) - nvl(v_amtrepaym, 0);
        v_dteclose          := i2.dteclose;
        v_amtclose          := i2.amtclose;
        v_flgclose          := i2.flgclose;
        if v_amtoutstd <= 0 then
          begin
            select dtepaymt
              into v_dteclose
              from tdtepay
             where codcompy   = hcm_util.get_codcomp_level(i2.codcomp, 1)
               and typpayroll = i2.typpayroll
               and dteyrepay  = p_dteyrepay
               and dtemthpay  = p_dtemthpay
               and numperiod  = p_numperiod;
          exception when no_data_found then
            null;
          end;
          v_amtclose          := nvl(v_amtrepaym, 0);
          v_flgclose          := 'Y';
        end if;
        begin
          update trepay
             set amtoutstd  = v_amtoutstd,
                 qtypaid    = nvl(qtypaid, 0) + 1,
                 amttotpay  = nvl(amttotpay, 0) + nvl(v_amtrepaym, 0),
                 dtelstpayp = i2.dtelstpay,
                 dtelstpay  = v_period,
                 amtlstpayp = i2.amtlstpay,
                 amtlstpay  = nvl(v_amtrepaym, 0),
                 dteclose   = v_dteclose,
                 amtclose   = v_amtclose,
                 flgclose   = v_flgclose,
                 flgtranpy  = 'Y',
                 dtetranpy  = sysdate,
                 dteupd     = sysdate,
                 coduser    = global_v_coduser
           where codempid   = i2.codempid;
        exception when others then
          null;
        end;
        find_codpay(i2.codcomp, v_codincrt, v_coddisovr);
        if param_msg_error is not null then
          return;
        end if;

        begin
          insert into tothinc
                    (
                      codempid, dteyrepay, dtemthpay, numperiod, codpay, codcomp, typpayroll,
                      typemp, qtypayda, qtypayhr, qtypaysc, ratepay, amtpay, codsys, costcent,
                      dtecreate, codcreate, coduser
                    )
             values (
                      i2.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_coddisovr, i2.codcomp, i2.typpayroll,
                      i2.typemp, null, null, null, null, stdenc(nvl(v_amtrepaym, 0), i2.codempid, v_chken), 'BF', i2.costcent,
                      sysdate, global_v_coduser, global_v_coduser
                    );
        exception when dup_val_on_index then
          update tothinc
             set amtpay    = stdenc((stddec(amtpay, codempid, v_chken) + nvl(v_amtrepaym, 0)), codempid, v_chken),
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where codempid  = i2.codempid
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay
             and numperiod = p_numperiod
             and codpay    = v_coddisovr;
        end;
        begin
          insert into tothinc2
                    (
                      codempid, dteyrepay, dtemthpay, numperiod, codpay, codcompw,
                      qtypayda, qtypayhr, qtypaysc, amtpay, codsys, costcent,
                      dtecreate, codcreate, coduser
                    )
             values (
                      i2.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_coddisovr, i2.codcomp,
                      null, null, null, stdenc(nvl(v_amtrepaym, 0), i2.codempid, v_chken), 'BF', i2.costcent,
                      sysdate, global_v_coduser, global_v_coduser
                    );
        exception when dup_val_on_index then
          update tothinc2
             set amtpay    = stdenc((stddec(amtpay, codempid, v_chken) + nvl(v_amtrepaym, 0)), codempid, v_chken),
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where codempid  = i2.codempid
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay
             and numperiod = p_numperiod
             and codpay    = v_coddisovr
             and codcompw  = i2.codcomp;
        end;
        begin
          insert into tclnsum
                    (
                      codempid, dteyrepay, dtemthpay, numperiod,
                      codcomp, typpayroll, typemp, amtrepay, numprdpay,
                      dtecreate, codcreate, coduser
                    )
             values (
                      i2.codempid, p_dteyrepay, p_dtemthpay, p_numperiod,
                      i2.codcomp, i2.typpayroll, i2.typemp, nvl(v_amtrepaym, 0), 1,
                      sysdate, global_v_coduser, global_v_coduser
                    );
        exception when dup_val_on_index then
          update tclnsum
             set amtrepay  = (nvl(amtrepay, 0) + nvl(v_amtrepaym, 0)),
                 numprdpay = (nvl(numprdpay, 0) + 1),
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where codempid  = i2.codempid
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay
             and numperiod = p_numperiod;
        end;
        v_rcnt2       := v_rcnt2 + 1;
      end if;
    end loop;

    if v_found then
      --if v_rcnt1 = 0 and v_rcnt2 = 0 then
       if   not v_chksecur then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       else
            commit;
            obj_data        := json_object_t(get_response_message(null, get_error_msg_php('HR2715', global_v_lang), global_v_lang));
            obj_data.put('rec_tran', v_rcnt1);
            obj_data.put('rec_err', v_rcnt2);
            json_str_output := obj_data.to_clob;
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
    end if;
  end gen_process;
end HRBF18B;

/
