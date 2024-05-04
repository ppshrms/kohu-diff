--------------------------------------------------------
--  DDL for Package Body HRPM94B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM94B" is

-- last update: 19/04/2021 18:01 redmine5670

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
--    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemonth');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codpay            := hcm_util.get_string_t(json_obj,'p_coddeduc');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_code    varchar2(1000);
  begin
--    if p_codcomp is not null then
    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
    if param_msg_error is not null then
      return;
    end if;
    p_codcompy    := hcm_util.get_codcomp_level(p_codcomp,1);
--    end if;

--    if p_typpayroll is not null then
    begin
      select codcodec
        into v_code
        from tcodtypy
       where codcodec = p_typpayroll;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
      return;
--    end;
    end;

    begin
      select  codpay
      into    v_code
      from    tinexinf
      where   codpay    in (select  codpay
                            from    TINEXINFC
                            where   codcompy = p_codcompy)
      and     typpay in ('4','5')
      and     codpay    = p_codpay
      and     rownum    = 1;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
      return;
    end;

    begin
      select  dtestrt,dteend
      into    tdtepay_dtestrt,tdtepay_dteend
      from    tdtepay
      where   codcompy    = p_codcompy
      and     typpayroll  = p_typpayroll
      and     dteyrepay   = p_dteyrepay
      and     dtemthpay   = p_dtemthpay
      and     numperiod   = p_numperiod;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tdtepay');
      return;
    end;

  end check_index;

  procedure process_data (json_str_input in clob, json_str_output out clob) is
    obj_row           json_object_t;
    json_obj           json_object_t;
    v_numrec         number := 0;
    v_numrec_non   number := 0;
    v_error       varchar2(4000 char);
    v_err_table   varchar2(4000 char);
    v_response    varchar2(4000);
    v_chk_data    boolean := false;
    v_chk_secur   boolean := false;
    v_staded      varchar2(1);
    v_periodpay   varchar2(20);
    v_costcent           tcenter.costcent%type;
    v_qtytranpy          number:=0;

    v_amtded            number:=0;

    cursor c_tcolltrl is
      select  a.codempid,a.codcomp,b.numcolla,a.codpos,a.numlvl,
                 b.qtyperiod,a.typemp,
                 stddec(b.amtded,  a.codempid     ,global_v_chken) amtded,
                 stddec(b.amtdedcol, a.codempid  ,global_v_chken) amtdedcol,
                 stddec(b.amtcolla, a.codempid     ,global_v_chken) amtcolla,
                 dteend,dtelstpay,qtytranpy
        from temploy1 a, tcolltrl b
      where a.codempid    = b.codempid
          and a.codcomp  like p_codcomp||'%'
          and a.typpayroll      = p_typpayroll
          and nvl(b.flgded,'N') = 'Y' -- Y-Deduct By PY
--<<user14 redmine#5004
          and nvl(b.STATUS,'A')  = 'A'
-->>user14 redmine#5004
          and nvl(b.staded,'N') <> 'C' -- C-Close, Y-salary deduct
          and b.dtestrt   <= tdtepay_dteend -- redmine2779  tdtepay_dtestrt
          and nvl(b.dtelstpay,'1111011') < v_periodpay
          and nvl(stddec(b.amtded,  a.codempid,global_v_chken),0) > 0
   order by codempid;

  begin
    initial_value(json_str_input);
    check_index;
    json_obj := json_object_t();
    if param_msg_error is null then
      v_periodpay   := lpad(p_dteyrepay,4,'0')||lpad(p_dtemthpay,2,'0')||lpad(p_numperiod,1,'0');
      v_numrec      := 0;
      for i in c_tcolltrl loop
           v_qtytranpy   := 0;
           v_amtded      := 0;
           v_chk_data    := true;
           v_chk_secur   := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

           if v_chk_secur then
                   v_chk_secur   := true;
--<<redmine5670   
                   if    ( nvl(i.amtdedcol,0) + nvl(i.amtded,0) ) >= nvl(i.amtcolla,0) then
                         v_staded    := 'C';
                         v_amtded   := least( (nvl(i.amtcolla,0) - nvl(i.amtdedcol,0)) , nvl(i.amtded,0) );
                   else
                         v_staded    := 'Y';
                         v_amtded   := nvl(i.amtded,0);
                         tdtepay_dteend  := i.dteend; --null;
                   end if;


                   if nvl(i.dtelstpay,'1111011') = v_periodpay then
                      v_qtytranpy  := nvl(i.qtytranpy,0);
                   else
                       v_qtytranpy  := nvl(i.qtytranpy,0) + 1;
                   end if;
-->>redmine5670   


                   begin
                     select costcent into v_costcent
                       from tcenter
                     where codcomp = i.codcomp;
                   exception when no_data_found then
                     v_costcent := null;
                   end;

                   begin
                     insert into tothinc(codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                                codcomp,typpayroll,typemp,
                                                amtpay,codsys, costcent,
                                                codcreate,coduser)
                                     values (i.codempid,p_dteyrepay,p_dtemthpay,p_numperiod,p_codpay,
                                                i.codcomp,p_typpayroll, i.typemp,
                                                stdenc(nvl(v_amtded,0),i.codempid,global_v_chken),'PM', v_costcent,
                                                global_v_coduser,global_v_coduser);
                   exception when dup_val_on_index then
                     update  tothinc
                           set  amtpay    = stdenc( (stddec(amtpay,i.codempid,global_v_chken) + v_amtded),i.codempid,global_v_chken),
                                 coduser    = global_v_coduser
                      where codempid    = i.codempid
                          and dteyrepay   = p_dteyrepay
                          and dtemthpay   = p_dtemthpay
                          and numperiod   = p_numperiod
                          and codpay       = p_codpay;
                   end;

                   begin
                     insert into tothinc2( codempid,dteyrepay,dtemthpay,
                                                  numperiod,codpay,codcompw,
                                                  amtpay,  costcent ,
                                                  codsys,
                                                  codcreate,coduser)
                                     values (i.codempid,p_dteyrepay,p_dtemthpay,
                                                p_numperiod,p_codpay,i.codcomp,
                                                stdenc(nvl(v_amtded,0),i.codempid,global_v_chken), v_costcent,
                                                'PM',
                                                global_v_coduser,global_v_coduser);

                   exception when dup_val_on_index then
                           update  tothinc2
                                 set amtpay    = stdenc( (stddec(amtpay,i.codempid,global_v_chken) + nvl(v_amtded,0)),i.codempid,global_v_chken),
                                      coduser   = global_v_coduser
                             where codempid    = i.codempid
                                 and dteyrepay    = p_dteyrepay
                                 and  dtemthpay  = p_dtemthpay
                                 and numperiod    = p_numperiod
                                 and codpay        = p_codpay
                                 and codcompw    = p_codcomp;
                   end;

                   --- update tcolltrl                
                   begin
                        update tcolltrl  ---amtdedcol   = amtdedcol + i.amtded
                              set amtdedcol   =  stdenc( (nvl(stddec(amtdedcol,i.codempid,global_v_chken),0) + nvl(v_amtded,0)),i.codempid,global_v_chken),
                                   qtytranpy   = v_qtytranpy, --<<redmine5670
                                   staded       = v_staded,
                                   dtelstpay    = v_periodpay,
                                   dteend       = tdtepay_dteend,
                                   coduser      = global_v_coduser
                        where  codempid    = i.codempid
                           and   numcolla    = i.numcolla
                           and   nvl(staded,'N') <> 'C';
                   end;

                   begin
                        insert into ttguartee(codempid,numcolla,
                                                     dteyrepay,dtemthpay,
                                                      numperiod,
                                                      amtpay,
                                                      codcreate,coduser)
                                           values(i.codempid,i.numcolla,
                                                      p_dteyrepay,p_dtemthpay,
                                                      p_numperiod,
                                                      stdenc(v_amtded, i.codempid,global_v_chken),
                                                      global_v_coduser,global_v_coduser);
                      exception when dup_val_on_index then
                           update  ttguartee
                                 set amtpay      = stdenc( (nvl(stddec(amtpay,i.codempid,global_v_chken),0) + nvl(v_amtded,0)),i.codempid,global_v_chken),
                                       coduser     = global_v_coduser
                            where codempid    = i.codempid
                                and numcolla      = i.numcolla
                                and dteyrepay   = p_dteyrepay
                                and dtemthpay   = p_dtemthpay
                                and numperiod   = p_numperiod;
                   end;
           end if;   --v_chk_secur
           v_numrec  := v_numrec + 1;
           commit;
      end loop;

      if not v_chk_data then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tcolltrl');
      elsif not v_chk_secur then
         param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR6537',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      obj_row.put('numrec', v_numrec);

      json_str_output := obj_row.to_clob;
    else
      rollback;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end process_data;

end HRPM94B;

/
