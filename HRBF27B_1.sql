--------------------------------------------------------
--  DDL for Package Body HRBF27B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF27B" AS
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
    p_dtecash           := to_date(hcm_util.get_string_t(json_obj,'p_dtecash'),'dd/mm/yyyyhh24miss') ;
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

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

  procedure get_process (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
      gen_process(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
    hcm_batchtask.finish_batch_process(
      p_codapp    => global_v_batch_codapp,
      p_coduser   => global_v_coduser,
      p_codalw    => global_v_batch_codalw,
      p_dtestrt   => global_v_batch_dtestrt,
      p_flgproc   => 'Y',
      p_qtyproc   => global_v_batch_qtyproc,
      p_qtyerror  => global_v_batch_qtyerror,
      p_oracode   => param_msg_error
    );
  exception when others then
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_process;

  procedure gen_process (json_str_output out clob) AS
    obj_data            json_object_t;
    v_period            trepay.dtelstpay%type;
    v_found             boolean := false;
    v_rcnt1             number := 0;
    v_rcnt2             number := 0;
    v_codincbf          tcontrbf.codincbf%type;
    v_coddisovr         tcontrbf.coddisovr%type;
    v_amtpayce          tclnsum.amtpayce%type;
    v_amtpaycf          tclnsum.amtpaycf%type;
    v_dteyre            taccmexp.dteyre%type;
    v_dtemonth          taccmexp.dtemonth%type;
    v_amtoutstd         trepay.amtoutstd%type;
    v_dteclose          trepay.dteclose%type;
    v_amtclose          trepay.amtclose%type;
    v_flgclose          trepay.flgclose%type;

    v_amtwidrwy         number;
    v_qtywidrwy         number;
    v_amtwidrwt         number;
    v_amtacc            number;
    v_amtacc_typ        number;
    v_qtyacc            number;
    v_qtyacc_typ        number;
    v_amtbal            number;
    v_sumamtsumin       number := 0;
    v_sumqtysumin       number := 0;

    cursor c1 is
      select a.codempid, a.flgdocmt, b.typpayroll, a.amtalw, b.codcomp, a.dtereq,
             a.typpay, a.numvcher,  b.typemp, a.codrel, c.costcent, a.typamt,
             a.dtecrest
        from tclnsinf a, temploy1 b, tcenter c
       where a.codempid   = b.codempid
         and a.codcomp    = c.codcomp(+)
         and a.codcomp    like p_codcomp || '%'
         and a.codempid   = nvl(p_codempid, a.codempid)
         and b.typpayroll = nvl(p_typpayroll, b.typpayroll)
         and a.dtecash <=  p_dtecash
         and a.flgupd  = 'N'
       order by a.codempid;

  begin
    for i1 in c1 loop
      v_found       := true;
      if secur_main.secur2(i1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        /*
        v_amtpayce         := 0;
        v_amtpaycf         := 0;
        if i1.codrel = 'E' then
          v_amtpayce         := nvl(i1.amtalw, 0);
        else
          v_amtpaycf         := nvl(i1.amtalw, 0);
        end if;
        begin
          insert into tclnsum
                    (
                      codempid, dteyrepay, dtemthpay, numperiod, codcomp, typpayroll,
                      typemp, amtpayce, amtpaycf, amtrepay, codcurr,
                      dtecreate, codcreate, coduser
                    )
             values (
                      i1.codempid, p_dteyrepay, p_dtemthpay, p_numperiod, i1.codcomp, i1.typpayroll,
                      i1.typemp, v_amtpayce, v_amtpaycf, null, null,
                      sysdate, global_v_coduser, global_v_coduser
                    );
        exception when dup_val_on_index then
          update tclnsum
             set amtpayce   = (nvl(amtpayce, 0) + v_amtpayce),
                 amtpaycf   = (nvl(amtpaycf, 0) + v_amtpaycf),
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where codempid  = i1.codempid
             and dteyrepay = p_dteyrepay
             and dtemthpay = p_dtemthpay
             and numperiod = p_numperiod;
        end;
        */
        begin
          update tclnsinf
             set flgupd    = 'Y',
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where codempid  = i1.codempid;
        exception when others then
          null;
        end;
        v_dteyre            := to_number(to_char(i1.dtereq, 'YYYY'));
        v_dtemonth          := to_number(to_char(i1.dtereq, 'MM'));
        ----
        std_bf.get_medlimit(i1.codempid, i1.dtereq, i1.dtecrest, i1.numvcher, i1.typamt, i1.codrel,
                            v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);
        begin
          insert into taccmexp
                    (
                      codempid, dteyre, dtemonth, typamt, typrelate,
                      codcomp, amtsumin, qtysumin, amtwidrwt, dteulast,
                      dtecreate, codcreate, coduser
                    )
             values (
                      i1.codempid, v_dteyre, v_dtemonth, i1.typamt, i1.codrel,
                      i1.codcomp, i1.amtalw, 1, v_amtwidrwt, i1.dtereq,
                      sysdate, global_v_coduser, global_v_coduser
                    );
        exception when dup_val_on_index then
          update taccmexp
             set amtsumin  = (nvl(amtsumin, 0) + i1.amtalw),
                 qtysumin  = (nvl(qtysumin, 0) + 1),
                 dteulast  = greatest(nvl(dteulast,i1.dtereq), i1.dtereq), ----
                 amtwidrwt = v_amtwidrwt, ----
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where codempid  = i1.codempid
             and dteyre    = v_dteyre
             and dtemonth  = v_dtemonth
             and typamt    = i1.typamt
             and typrelate = i1.codrel;
        end;
        v_rcnt1       := v_rcnt1 + 1;

        --keep summary data at month = 13
        v_sumamtsumin := 0;
        v_sumqtysumin := 0;
        begin
          select nvl(sum(nvl(amtsumin,0)),0), nvl(sum(nvl(qtysumin,0)),0)
            into v_sumamtsumin, v_sumqtysumin
            from taccmexp
           where codempid  = i1.codempid
             and dteyre    = v_dteyre
             and dtemonth  <> 13
             and typamt    = i1.typamt
             and typrelate = i1.codrel;
        end;
        begin
          insert into taccmexp
                    (
                      codempid, dteyre, dtemonth, typamt, typrelate,
                      codcomp, amtsumin, qtysumin, amtwidrwt, dteulast,
                      dtecreate, codcreate, coduser
                    )
             values (
                      i1.codempid, v_dteyre, 13, i1.typamt, i1.codrel,
                      i1.codcomp, v_sumamtsumin, v_sumqtysumin, v_amtwidrwt, i1.dtereq,
                      sysdate, global_v_coduser, global_v_coduser
                    );
        exception when dup_val_on_index then
          update taccmexp
             set amtsumin  = v_sumamtsumin,
                 qtysumin  = v_sumqtysumin,
                 dteulast  = greatest(nvl(dteulast,i1.dtereq), i1.dtereq), 
                 amtwidrwt = v_amtwidrwt, 
                 dteupd    = sysdate,
                 coduser   = global_v_coduser
           where codempid  = i1.codempid
             and dteyre    = v_dteyre
             and dtemonth  = 13
             and typamt    = i1.typamt
             and typrelate = i1.codrel;
        end;
      end if;
    end loop;

    if v_found then
      if v_rcnt1 = 0 and v_rcnt2 = 0 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        obj_data        := json_object_t(get_response_message(null, get_error_msg_php('HR2715', global_v_lang), global_v_lang));
        obj_data.put('rec_tran', v_rcnt1);
        obj_data.put('rec_err', v_rcnt2);
        json_str_output := obj_data.to_clob;
        global_v_batch_qtyproc  := v_rcnt1;
        global_v_batch_qtyerror := v_rcnt2;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tclnsinf');
    end if;
  end gen_process;
end HRBF27B;

/
