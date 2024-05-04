--------------------------------------------------------
--  DDL for Package Body HRPY42D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY42D" as
-- last update: 10/02/2021 16:01 redmine#3405

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_flgsecu		boolean;
    v_numlvl		temploy1.numlvl%type;
    v_codcompy		tcontrpy.codcompy%type;
    v_lastperd		varchar2(100 char);
    v_currperd		varchar2(100 char);
    v_nextperd		varchar2(100 char);
    v_perd		    varchar2(100 char);
    v_temp		    number;
    v_date		    date;
    v_zupdsal       varchar2(1 char);

    cursor c_tdtepay_last is
      select dteyrepay,dtemthpay,numperiod
      from tdtepay
      where codcompy   = b_var_codcompy
        and typpayroll = b_var_typpayroll
        and flgcal = 'Y'
      order by dteyrepay desc,dtemthpay desc,numperiod desc;


  begin
    if p_codempid is not null then
      p_codcomp := null;
    else
      b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);
      b_var_typpayroll := p_typpayroll;
    end if;

    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numperiod');
    end if;
    if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dtemthpay');
    end if;
    if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyrepay');
    end if;
    if p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    if (p_typpayroll is null) and (p_codcomp is not null) then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    if p_codempid is not null then
      begin
        select codcomp,typpayroll,numlvl
          into p_codcomp,b_var_typpayroll,v_numlvl
          from temploy1
         where codempid = p_codempid;
            b_var_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
--            v_flgsecu      := secur_main.secur1(p_codcomp,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
            v_flgsecu      := secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang);
        return;
      end;
    else
      begin
        select	codcodec into b_var_typpayroll
        from	tcodtypy
        where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODTYPY');
      end;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      if length(p_codcomp) < 40 then
        p_codcomp := p_codcomp||'%';
      end if;
    end if;

    -- Check Period For Calculate
    v_currperd := lpad(to_char(p_dteyrepay),4,'0')||lpad(p_dtemthpay,2,'0')||to_char(p_numperiod);
    b_index_lastperd := null;
    v_lastperd := v_currperd;

    for r_tdtepay_last in c_tdtepay_last loop
        v_lastperd       := lpad(to_char(r_tdtepay_last.dteyrepay),4,'0')||lpad(to_char(r_tdtepay_last.dtemthpay),2,'0')||to_char(r_tdtepay_last.numperiod);
        b_index_lastperd := r_tdtepay_last.numperiod;
        b_index_lstmnt   := r_tdtepay_last.dtemthpay;
        b_index_lstyear  := r_tdtepay_last.dteyrepay;
        exit;
    end loop;
    if v_currperd < v_lastperd then
--Error #7977        param_msg_error := get_error_msg_php('HR7517', global_v_lang, 'p_numperiod');
--redmine#3405 param_msg_error := get_error_msg_php('HR7517', global_v_lang);
         param_msg_error := get_error_msg_php('PY0066', global_v_lang);         
    end if;

  end check_index;

procedure get_process (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process;

  procedure process_data(json_str_output out clob) is
    obj_data        json_object_t;
    o_numrec        number;
    p_numrec        number;
    o_numerr        number;
    o_time          varchar2(100 char);
    o_error         varchar2(1000 char);
    v_response      varchar2(4000 char);
    v_empid         varchar2(100 char);

    v_exist			boolean;
    v_secur 		boolean;

    cursor c_emp is
      select codempid,codcomp,numlvl
        from ttaxcur
        where ((p_codempid is not null) and
               (codempid = p_codempid))
           or ((p_codempid is null) and
               (codcomp like p_codcomp||'%') and
               (typpayroll = b_var_typpayroll) and
               (staemp in ('1','3','9')))
           and dteyrepay = p_dteyrepay
           and dtemthpay = p_dtemthpay
           and numperiod = p_numperiod
        order by codempid;
      /*select codempid,codcomp,numlvl
        from temploy1
        where ((p_codempid is not null) and
               (codempid = p_codempid))
           or ((p_codempid is null) and
               (codcomp like p_codcomp||'%') and
               (typpayroll = b_var_typpayroll) and
               (staemp in ('1','3','9')))
        order by codempid;*/

  begin

    v_exist     := false;
    v_secur     := false;
    o_numrec    := 0;
    for r_emp in c_emp loop
      v_exist  := true;
      v_secur  := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_secur then
        v_secur  := true;
        p_numrec := 0;
        clear_olddata(r_emp.codempid,p_numrec);
        if nvl(p_numrec,0) <> 0 then
            o_numrec := nvl(o_numrec,0) + 1;
        end if;
      end if; -- p_secur = true
    end loop; -- c_emp
    commit;


    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang);
    elsif not v_secur then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
      update tdtepay
        set flgcal    = 'N',
            coduser  = global_v_coduser,
            dteupd   = trunc(sysdate)
        where codcompy   = b_var_codcompy
          and typpayroll = b_var_typpayroll
          and dteyrepay  = p_dteyrepay
          and dtemthpay  = p_dtemthpay
          and numperiod  = p_numperiod;
      commit;
    end if;


    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('lastperd', b_index_lastperd);
    obj_data.put('lstmnt', b_index_lstmnt);
    obj_data.put('lstyear', b_index_lstyear);
    obj_data.put('numrec', nvl(o_numrec,0));


    ---param_msg_error := get_error_msg_php('HR2715',global_v_lang);
    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    json_str_output := obj_data.to_clob;
  exception when others then
    rollback;
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end process_data;

  procedure clear_olddata (p_var_codempid in varchar2,p_numrec in out number) is

    v_numrec        number := 0;
    v_dteyrepay     number;
    v_dtemthpay     number;
    v_numperiod     number;
    v_count         number := 0;

    cursor c_ttaxcur is
        select  codempid,amtnet,amtcal,amtincl,amtincc,amtincn,
                amtexpl,amtexpc,amtexpn,amttax,amtgrstx,
                amtcprv,amtprove,amtprovc,amtproic,amtproie,
                amtsoc,amtsoca,amtsocc,qtywork,rowid,
                amtothe,amtothc,amtotho,amtcalc,amttaxoth,codcomp,typpayroll
          from ttaxcur
         where codempid  = p_var_codempid
           and dteyrepay = p_dteyrepay
           and dtemthpay = p_dtemthpay
           and numperiod = p_numperiod;

    cursor c_ttaxpf is
        select rowid,codpolicy,amtprove,amtprovc,dteeffec
          from ttaxpf
         where codempid  = p_var_codempid
           and dteyrepay = p_dteyrepay
           and dtemthpay = p_dtemthpay
          and numperiod  = p_numperiod;

  begin

    delete from	tsincexp
    where codempid  = p_var_codempid
      and dteyrepay	= p_dteyrepay
      and dtemthpay	= p_dtemthpay
      and numperiod	= p_numperiod
      and flgslip   = '1';

	delete from	tinctxpnd
	where codempid  = p_var_codempid
	  and dteyrepay	= p_dteyrepay
	  and dtemthpay	= p_dtemthpay
	  and numperiod	= p_numperiod;

    update tfincadj	set staupd = 'T'
     where codempid = p_var_codempid
      and dteyrepay	= p_dteyrepay
      and dtemthpay	= p_dtemthpay
      and numperiod	= p_numperiod
      and staupd    = 'U';


    for r_ttaxpf in c_ttaxpf loop
        /*update tpfirinf set amtcaccu = stdenc(stddec(amtcaccu,p_var_codempid,v_chken) - stddec(r_ttaxpf.amtprovc,p_var_codempid,v_chken),p_var_codempid,v_chken),
	                        amteaccu = stdenc(stddec(amteaccu,p_var_codempid,v_chken) - stddec(r_ttaxpf.amtprove,p_var_codempid,v_chken),p_var_codempid,v_chken)
        where codempid  = p_var_codempid
          and dteeffec  = r_ttaxpf.dteeffec
          and codpolicy = r_ttaxpf.codpolicy;*/

        delete from	ttaxpf where rowid = r_ttaxpf.rowid;
    end loop; --c_ttaxpf



    for r_ttaxcur in c_ttaxcur loop
        v_numrec := v_numrec +1;
        update tssmemb
           set accmemb	 = stdenc(stddec(accmemb,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtsoca,p_var_codempid,v_chken),p_var_codempid,v_chken)
         where codempid  = p_var_codempid;

        update tpfmemb set  amtcaccu = stdenc(stddec(amtcaccu,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtprovc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                            amteaccu = stdenc(stddec(amteaccu,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtprove,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                            amtintaccu = stdenc(stddec(amtintaccu,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtproic,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                            amtinteccu = stdenc(stddec(amtinteccu,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtproie,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken)
        where	codempid = p_var_codempid;

        begin
            select count(*) into v_count
              from tsincexp
             where codempid  = p_var_codempid
               and dteyrepay = p_dteyrepay ;
        exception when no_data_found then
           v_count := 0;
        end;

        if v_count = 0 then
            delete ttaxmas
             where codempid     = p_var_codempid
               and dteyrepay	= p_dteyrepay;
        else
            update ttaxmas set  amtnett   =	stdenc(stddec(amtnett,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtnet,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtcalt	  =	stdenc(stddec(amtcalt,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtcal,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtinclt  = stdenc(stddec(amtinclt,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtincl,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtincct  = stdenc(stddec(amtincct,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtincc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtincnt  = stdenc(stddec(amtincnt,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtincn,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtexplt  = stdenc(stddec(amtexplt,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtexpl,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtexpct  = stdenc(stddec(amtexpct,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtexpc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtexpnt  = stdenc(stddec(amtexpnt,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtexpn,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amttaxt   =	stdenc(stddec(amttaxt,p_var_codempid,v_chken) - stddec(r_ttaxcur.amttax,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtsoct   =	stdenc(stddec(amtsoct,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtsoc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtsocat  = stdenc(stddec(amtsocat,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtsoca,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtsocct  = stdenc(stddec(amtsocct,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtsocc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtcprvt  = stdenc(stddec(amtcprvt,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtcprv,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtprovte =	stdenc(stddec(amtprovte,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtprove,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtprovtc =	stdenc(stddec(amtprovtc,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtprovc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtcalct  =	stdenc(stddec(amtcalct,p_var_codempid,v_chken) - stddec(r_ttaxcur.amtcalc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtothe   =	stdenc(stddec(amtothe,p_var_codempid,v_chken)  - stddec(r_ttaxcur.amtothe,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtothc   =	stdenc(stddec(amtothc,p_var_codempid,v_chken)  - stddec(r_ttaxcur.amtothc,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amtotho   =	stdenc(stddec(amtotho,p_var_codempid,v_chken)  - stddec(r_ttaxcur.amtotho,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                                amttaxoth =	stdenc(stddec(amttaxoth,p_var_codempid,v_chken)  - stddec(r_ttaxcur.amttaxoth,r_ttaxcur.codempid,v_chken),p_var_codempid,v_chken),
                    qtyworkt  = qtyworkt - r_ttaxcur.qtywork
              where	codempid  = p_var_codempid
                and dteyrepay = p_dteyrepay - v_zyear;
        end if;


        delete from	ttaxcur
        where rowid = r_ttaxcur.rowid;

        delete 	ttaxmasl
         where codempid     = p_var_codempid
           and dteyrepay	= p_dteyrepay
           and dtemthpay	= p_dtemthpay
           and numperiod	= p_numperiod;

        delete 	ttaxmasf
         where codempid     = p_var_codempid
           and dteyrepay	= p_dteyrepay
           and dtemthpay	= p_dtemthpay
           and numperiod	= p_numperiod;

        delete 	ttaxmasd
         where codempid     = p_var_codempid
           and dteyrepay	= p_dteyrepay
           and dtemthpay	= p_dtemthpay
           and numperiod	= p_numperiod;

    end loop; --c_ttaxcur

    p_numrec := v_numrec;
  end;

end HRPY42D;

/
