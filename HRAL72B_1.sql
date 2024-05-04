--------------------------------------------------------
--  DDL for Package Body HRAL72B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL72B" as
  procedure cal_dhm(p_qtyday  in  number,
                    p_day			out number,
                    p_hour		out number,
                    p_min			out number) is
  begin
    p_day  := trunc(p_qtyday,0);
    p_hour := trunc((mod(p_qtyday,1) * p_qtyavgwk) / 60,0);
    p_min  := mod(mod(p_qtyday,1) * p_qtyavgwk,60);
  end;
  procedure get_status (v_codpay varchar2) is
    val_y   number := 0;
    val_n   number := 0;
  begin
    begin
      select nvl(sum(decode(flgtran,'Y',1,0)),0) , nvl(sum(decode(flgtran,'N',1,0)),0)
      into val_y,val_n
      from tpaysum
      where dteyrepay = (p_dteyrepay - global_v_zyear)
        and dtemthpay = to_number(p_dtemthpay)
        and numperiod = p_numperiod
        and typpayroll = nvl(p_typpayroll,typpayroll)
        and codcomp like p_codcomp||'%'
        and codempid = nvl(p_codempid,codempid)
        and codpay = v_codpay;
    exception when no_data_found then
      val_y := 0;
      val_n := 0;
    end;
    if val_y = 0 and val_n = 0 then
      p_status := get_label_name('HRAL72C1',global_v_lang,'100');
    elsif val_y > 0 and val_n = 0 then
      p_status := get_label_name('HRAL72C1',global_v_lang,'110');
    elsif val_y > 0 and val_n > 0 then
      p_status := get_label_name('HRAL72C1',global_v_lang,'120');
    elsif val_y = 0 and val_n > 0 then
      p_status := get_label_name('HRAL72C1',global_v_lang,'130');
    else
      p_status := val_y||'-'||val_n;
    end if;
  end;

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    v_chken             := hcm_secur.get_v_chken;

    -- index params
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codcomp           := replace(hcm_util.get_string_t(json_obj, 'p_codcomp'),'-',null);
    p_codcompy          := get_comp_split(p_codcomp,1);
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_flgsecu		  boolean	:= null;
    v_codcomp     varchar2(1000 char);
    v_typpayroll  varchar2(1000 char);
    v_codempid		varchar2(1000 char);
  begin
    if p_codempid is not null then
       p_codcomp    := null;
       p_typpayroll := null;
    end if;
    if p_typpayroll is not null then
			begin
				select codcodec into v_typpayroll
				from 	 tcodtypy
				where  codcodec = p_typpayroll;
			exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'typpayroll');
        return;
			end;
		end if;
    if p_codempid is not null then
      begin
        select codcomp, typpayroll into p_codcomp, p_typpayroll
        from   temploy1
        where  codempid = p_codempid;
        p_codcompy     := hcm_util.get_codcomp_level(p_codcomp,1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'codempid');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is null then
        return;
      end if;
    end if;

    /*20/02/2021 move to transfer procedure
    if param_msg_error is null then
      begin
        select qtyavgwk into p_qtyavgwk
        from   tcontral
        where  codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
        and    dteeffec = (select max(dteeffec)
                           from   tcontral
                           where  codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                           and    dteeffec <= sysdate);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('AL0012', global_v_lang, 'codcomp');
        return;
      end;
     end if;*/
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_exist         boolean := false;
    cursor c_tpriodal is
      select codpay, flgcal
        from tpriodal
       where codcompy   = p_codcompy
         and typpayroll = p_typpayroll
         and dteyrepay  = p_dteyrepay - global_v_zyear
         and dtemthpay  = p_dtemthpay
         and numperiod  = p_numperiod
        order by codpay;
  begin
    obj_row  := json_object_t();
    v_rcnt   := 0;
    for c1 in c_tpriodal loop
      get_status(c1.codpay);
      v_exist      := true;
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codpay', c1.codpay);
      obj_data.put('despay', c1.codpay||' - '||get_tinexinf_name(c1.codpay,global_v_lang));
      obj_data.put('status', p_status);
      obj_data.put('flgcal', c1.flgcal);
      obj_data.put('numrec', '');
      obj_row.put(to_char(v_rcnt), obj_data);
    end loop;

    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tpriodal');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;

  procedure post_transfer_data (json_str_input in clob, json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    data_row        clob;
    v_flg           varchar2(1000);
    obj_data        json_object_t;
    obj_row         json_object_t;
    json_obj        json_object_t;
    v_rcnt          number := 0;
    v_response      varchar2(1000);
  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      json_obj := json_object_t();
      obj_row  := json_object_t();
      v_rcnt   := 0;
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        p_codpay        := hcm_util.get_string_t(param_json_row,'codpay');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');
        if v_flg = 'Y' then null;
          transfer_data;
          v_rcnt       := v_rcnt+1;
          obj_data     := json_object_t();
          obj_data.put('codpay', p_codpay);
          obj_data.put('despay', p_codpay||' - '||get_tinexinf_name(p_codpay,global_v_lang));
          obj_data.put('numrec', nvl(p_numrec,0));
          obj_data.put('status', p_status);
          obj_row.put(to_char(v_rcnt-1), obj_data);
        end if;
      end loop;
      data_row := obj_row.to_clob;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        v_response := get_response_message(null,param_msg_error,global_v_lang);

        json_obj.put('coderror',hcm_util.get_string_t(json_object_t(v_response),'coderror'));
        json_obj.put('desc_coderror',hcm_util.get_string_t(json_object_t(v_response),'desc_coderror'));
        json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
        json_obj.put('param_json',data_row);
        commit;
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        rollback;
        return;
      end if;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    end if;
    json_str_output := json_obj.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_transfer_data;

  procedure transfer_data is
    v_flgsecu		boolean;
    v_codempid	varchar2(1000 char);
    v_codpay		varchar2(1000 char);
--    v_codcurr		varchar2(1000 char);
    v_codalw		varchar2(1000 char);
    v_day				number;
    v_hour			number;
    v_min				number;
    v_codlev		tcontal2.codlev%type;
    v_codot			tcontrot.codot%type;

    cursor c_emp is
      select codempid,codcomp,typpayroll,typemp,numlvl
        from temploy1
       where ((p_codempid is not null and codempid = p_codempid)
          or  (p_codempid is null and codcomp like p_codcomp||'%'
                                  and typpayroll = p_typpayroll))
         and	staemp in ('1','3','9')
         and  exists (select codempid
                from tpaysum
               where tpaysum.codempid = temploy1.codempid
                 and dteyrepay = (p_dteyrepay - global_v_zyear)
                 and dtemthpay = to_number(p_dtemthpay)
                 and numperiod = p_numperiod
                 and flgtran   = 'N')
      order by codempid;

    cursor c_tpaysum is
      select rowid,codalw,codpay,amtothr,amtday,qtyday,amtpay
        from tpaysum
       where dteyrepay = (p_dteyrepay - global_v_zyear)
         and dtemthpay = to_number(p_dtemthpay)
         and numperiod = p_numperiod
         and codempid  = v_codempid
         and codpay		 = v_codpay
         and flgtran	 = 'N';

    cursor c_tpaysum2 is
      select dtework,codshift as typot,rowid
        from tpaysum2
       where dteyrepay = (p_dteyrepay - global_v_zyear)
         and dtemthpay = to_number(p_dtemthpay)
         and numperiod = p_numperiod
         and codempid  = v_codempid
         and codalw    = v_codalw
         and codpay		 = v_codpay;

    cursor c_tpaysum_alw is
      select rowid,codalw,codpay,amtothr,amtday,qtyday,amtpay
        from tpaysum
       where dteyrepay = (p_dteyrepay - global_v_zyear)
         and dtemthpay = to_number(p_dtemthpay)
         and numperiod = p_numperiod
         and codempid  = v_codempid
         and codalw		 = v_codalw
         and flgtran	 = 'N';
  begin
    begin --20/02/2021
      select qtyavgwk into p_qtyavgwk
      from   tcontral
      where  codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
      and    dteeffec = (select max(dteeffec)
                         from   tcontral
                         where  codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                         and    dteeffec <= sysdate);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0012', global_v_lang, 'codcomp');
    end;

    begin
			select codlev
			  into v_codlev
			  from tcontal2
			 where codcompy = get_comp_split(p_codcomp,1)
			   and dteeffec = (select max(dteeffec) from tcontal2
            						  where	codcompy = get_comp_split(p_codcomp,1)
												    and	dteeffec <= sysdate);
		exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'codpay');
		end;

    begin
      select codot
        into v_codot
        from tcontrot
       where codcompy = get_comp_split(p_codcomp,1)
         and dteeffec = (select max(dteeffec) from tcontrot
                          where	codcompy = get_comp_split(p_codcomp,1)
                            and	dteeffec <= sysdate);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'codpay');
    end;
    p_numrec := null;
    v_codpay := p_codpay;
    for r_emp in c_emp loop
      << main_loop >> loop
        v_codempid := r_emp.codempid;
        v_flgsecu := secur_main.secur2(r_emp.codcomp,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu then
          exit main_loop;
        end if;
--        begin
--          select codcurr into v_codcurr
--            from temploy3
--           where codempid = v_codempid;
--        exception when no_data_found then
--          exit main_loop;
--        end;
        for r1 in c_tpaysum loop
          if r1.codalw = 'OT' then
            upd_totsum(v_codempid,r_emp.codcomp,r_emp.typpayroll,r_emp.typemp,/*v_codcurr,*/r1.amtothr);
            v_codalw := 'OT';
            v_codpay := r1.codpay;
            for r_tpaysum2 in c_tpaysum2 loop
              update tovrtime
                 set flgotcal	  = 'Y',
                     dteyrepay  = (p_dteyrepay - global_v_zyear),
                     dtemthpay  = to_number(p_dtemthpay),
                     numperiod  = p_numperiod,
                     coduser	  = global_v_coduser,
                     codcreate	= global_v_coduser
               where codempid   = v_codempid
                 and dtework    = r_tpaysum2.dtework
                 and typot      = r_tpaysum2.typot;
              --
              update tpaysum
                 set flgtran = 'Y',coduser = global_v_coduser
               where rowid   = r1.rowid;
            end loop;
            v_codalw := 'MEAL';
            for r2 in c_tpaysum_alw loop
              cal_dhm(r2.qtyday,v_day,v_hour,v_min);
              upd_tothinc(v_codempid,r2.codpay,r_emp.codcomp,r_emp.typpayroll,r_emp.typemp,v_day,v_hour,v_min,r2.amtday,r2.amtpay,/*v_codcurr,*/v_codalw);
              --
              update tpaysum
                 set flgtran = 'Y',coduser = global_v_coduser
               where rowid   = r1.rowid;
            end loop;
          elsif r1.codalw = 'AWARD' then
            v_codalw := 'AWARD';
            upd_tothinc(v_codempid,r1.codpay,r_emp.codcomp,r_emp.typpayroll,r_emp.typemp,null,null,null,r1.amtday,r1.amtpay,/*v_codcurr,*/v_codalw);

            v_codalw := 'RET_AWARD';
            for r2 in c_tpaysum_alw loop
              upd_tothinc(v_codempid,r2.codpay,r_emp.codcomp,r_emp.typpayroll,r_emp.typemp,null,null,null,r2.amtday,r2.amtpay,/*v_codcurr,*/v_codalw);
              --
              update tpaysum
                 set flgtran = 'Y',coduser = global_v_coduser
               where rowid   = r2.rowid;
            end loop;
          else
            v_codalw := r1.codalw;
            cal_dhm(r1.qtyday,v_day,v_hour,v_min);
						upd_tothinc(v_codempid,r1.codpay,r_emp.codcomp,r_emp.typpayroll,r_emp.typemp,v_day,v_hour,v_min,r1.amtday,r1.amtpay,/*v_codcurr,*/v_codalw);
          end if;
          update tpaysum
             set flgtran = 'Y',
                 coduser = global_v_coduser
           where rowid   = r1.rowid;
        end loop;

        if v_codpay = v_codlev then
          v_codalw := 'DED_LEAVE';
          for r2 in c_tpaysum_alw loop
            cal_dhm(r2.qtyday,v_day,v_hour,v_min);
            upd_tothinc(v_codempid,r2.codpay,r_emp.codcomp,r_emp.typpayroll,r_emp.typemp,v_day,v_hour,v_min,r2.amtday,r2.amtpay,/*v_codcurr,*/v_codalw);

            update tpaysum
               set flgtran = 'Y',coduser = global_v_coduser
             where rowid   = r2.rowid;
          end loop;
        end if;
        exit main_loop;
      end loop;
    end loop;
    update tpriodal set flgcal = 'Y'
		 where codcompy   = get_comp_split(p_codcomp,1)
		   and typpayroll = p_typpayroll
		   and dteyrepay  = (p_dteyrepay - global_v_zyear)
		   and dtemthpay  = p_dtemthpay
		   and numperiod  = p_numperiod
		   and codpay     = v_codpay;

    get_status(v_codpay);
  end;

  procedure upd_tothinc (p_codempid in varchar2, p_codpay in varchar2, p_codcomp in varchar2,
                         p_typpayroll in varchar2, p_typemp in varchar2, p_qtypayda in number,
                         p_qtypayhr in number, p_qtypaysc in number, p_ratepay  in varchar2,
                         p_amtpay  in varchar2,/* p_codcurr in varchar2,*/ p_codalw in varchar2) is
    v_flgfound 		boolean;
    v_flgfound2   	boolean;
    v_amtpay		number;
    v_amtpay2		number;
    v_codcompw		varchar2(40);
    v_codcompgl   	varchar2(40);
    v_costcent    	varchar2(40);
	--02/12/2020
	v_qtypayda		number;
	v_qtypayhr		number;
	v_qtypaysc		number;

  cursor c_tothinc is
    select rowid,codempid,amtpay
      from tothinc
     where codempid   = p_codempid
       and dteyrepay  = (p_dteyrepay - global_v_zyear)
       and dtemthpay  = to_number(p_dtemthpay)
       and numperiod  = p_numperiod
       and codpay     = p_codpay;

  cursor c_tpaysum2 is
    --02/12/2020
    select codcompw,sum(stddec(amtpay,a.codempid,v_chken)) sumamtpay,sum(qtymin / qtydaywk) sumday
      from tpaysum2 a, tshiftcd b, tattence c
     where a.dteyrepay  = (p_dteyrepay - global_v_zyear)
       and a.dtemthpay  = to_number(p_dtemthpay)
       and a.numperiod  = p_numperiod
       and a.codempid   = p_codempid
       and a.codalw     = p_codalw
       and a.codpay	    = p_codpay
--       and a.codshift = b.codshift
       and a.codempid = c.codempid
       and a.dtework  = c.dtework
       and c.codshift = b.codshift
	group by codcompw
	order by codcompw;
	/*select rowid,codpay,amtpay,amtday,codcompw
      from tpaysum2
     where dteyrepay  = (p_dteyrepay - global_v_zyear)
       and dtemthpay  = to_number(p_dtemthpay)
       and numperiod  = p_numperiod
       and codempid   = p_codempid
       and codalw     = p_codalw
       and codpay		  = p_codpay;*/

  cursor c_tothinc2 is
    select rowid,codempid,amtpay
      from tothinc2
     where codempid   = p_codempid
       and dteyrepay  = (p_dteyrepay - global_v_zyear)
       and dtemthpay  = to_number(p_dtemthpay)
       and numperiod  = p_numperiod
       and codpay     = p_codpay
       and codcompw   = v_codcompw;
  begin
    v_flgfound  := false;

    begin
      select costcent into v_costcent
        from tcenter
       where codcomp = p_codcomp;
    exception when no_data_found then
      v_costcent := null;
    end;

    for r_tothinc in c_tothinc loop
      v_flgfound := true;
      v_amtpay := nvl(stddec(r_tothinc.amtpay,r_tothinc.codempid,v_chken),0) + nvl(stddec(p_amtpay,r_tothinc.codempid,v_chken),0);
      update tothinc
        set codcomp    = p_codcomp,
            typpayroll = p_typpayroll,
            typemp     = p_typemp,
            ratepay	   = p_ratepay,
--            codcurr    = p_codcurr,
            qtypayda   = qtypayda + round(p_qtypayda),
            qtypayhr   = qtypayhr + round(p_qtypayhr),
            qtypaysc   = qtypaysc + round(p_qtypaysc),
            amtpay     = stdenc(v_amtpay,codempid,v_chken),
            codsys		 = 'AL',
            coduser    = global_v_coduser,
            codcreate  = global_v_coduser
      where rowid = r_tothinc.rowid;
    end loop;

    if not v_flgfound then
      insert into tothinc
        (codempid,dteyrepay,
         dtemthpay,numperiod, costcent,
         codpay,codcomp,typpayroll,typemp,
         ratepay/*,codcurr*/,qtypayda,qtypayhr,qtypaysc,
         amtpay,codsys,coduser,codcreate)
      values
        (p_codempid,(p_dteyrepay - global_v_zyear),
         to_number(p_dtemthpay),p_numperiod, v_costcent,
         p_codpay,p_codcomp,p_typpayroll,p_typemp,
         p_ratepay/*,p_codcurr*/,round(p_qtypayda),round(p_qtypayhr),round(p_qtypaysc),
         p_amtpay,'AL',global_v_coduser,global_v_coduser);
    end if;

--<< user22 : 27/02/2020 ||
    if p_codalw in ('AWARD','RET_AWARD') then
      v_flgfound  := false;
      v_codcompw  := p_codcomp;
      begin
        select costcent into v_codcompgl
          from tcenter
         where codcomp = v_codcompw;
      exception when no_data_found then
        v_codcompgl := null;
      end;
      for r_tothinc2 in c_tothinc2 loop
        v_flgfound := true;
        v_amtpay := nvl(stddec(r_tothinc2.amtpay,r_tothinc2.codempid,v_chken),0) + nvl(stddec(p_amtpay,r_tothinc2.codempid,v_chken),0);

        update tothinc2
           set qtypayda   = qtypayda + p_qtypayda,
               qtypayhr   = qtypayhr + p_qtypayhr,
               qtypaysc   = qtypaysc + p_qtypaysc,
               amtpay     = stdenc(v_amtpay,codempid,v_chken),
               costcent   = v_codcompgl,
               codsys		 = 'AL',
               coduser    = global_v_coduser,
               codcreate  = global_v_coduser
         where rowid = r_tothinc2.rowid;
      end loop;

      if not v_flgfound then
        insert into tothinc2
          (codempid,dteyrepay,
           dtemthpay,numperiod,
           codpay,codcompw,costcent,
           qtypayda,qtypayhr,qtypaysc,
           amtpay,codsys,coduser,codcreate)
        values
          (p_codempid,(p_dteyrepay - global_v_zyear),
           to_number(p_dtemthpay),p_numperiod,
           p_codpay,v_codcompw,v_codcompgl,
           p_qtypayda,p_qtypayhr,p_qtypaysc,
           p_amtpay,'AL',global_v_coduser,global_v_coduser);
      end if;
    end if; --p_codalw in ('AWARD','RET_AWARD')
-->> user22 : 27/02/2020 ||

    v_flgfound2 := false;
    for r_tpaysum2 in c_tpaysum2 loop
      v_codcompw := r_tpaysum2.codcompw;
      v_amtpay2 := nvl(r_tpaysum2.sumamtpay,0); --02/12/2020
      cal_dhm(r_tpaysum2.sumday,v_qtypayda,v_qtypayhr,v_qtypaysc); --02/12/2020

      begin
        select costcent into v_codcompgl
          from tcenter
         where codcomp = v_codcompw;
      exception when no_data_found then
        v_codcompgl := null;
      end;
      v_flgfound2 := false;
      for r_tothinc2 in c_tothinc2 loop
        v_flgfound2 := true;
        --02/12/2020--v_amtpay2 := nvl(stddec(r_tothinc2.amtpay,r_tothinc2.codempid,v_chken),0) + nvl(stddec(r_tpaysum2.amtpay,r_tothinc2.codempid,v_chken),0);

        update tothinc2
          set qtypayda   = round(v_qtypayda), --02/12/2020--qtypayda + p_qtypayda,
              qtypayhr   = round(v_qtypayhr), --02/12/2020--qtypayhr + p_qtypayhr,
              qtypaysc   = round(v_qtypaysc), --02/12/2020--qtypaysc + p_qtypaysc,
              amtpay     = stdenc(v_amtpay2,codempid,v_chken),
              costcent   = v_codcompgl,
              codsys	   = 'AL',
              coduser    = global_v_coduser,
              codcreate  = global_v_coduser
        where rowid = r_tothinc2.rowid;
      end loop;

      if not v_flgfound2 then
        insert into tothinc2
          (codempid,dteyrepay,
           dtemthpay,numperiod,
           codpay,codcompw,costcent,
           qtypayda,qtypayhr,qtypaysc,
           amtpay,codsys,coduser,codcreate)
        values
          (p_codempid,(p_dteyrepay - global_v_zyear),
           to_number(p_dtemthpay),p_numperiod,
           p_codpay,v_codcompw,v_codcompgl,
           round(v_qtypayda),round(v_qtypayhr),round(v_qtypaysc), --02/12/2020--p_qtypayda,p_qtypayhr,p_qtypaysc,
           stdenc(v_amtpay2,p_codempid,v_chken), --02/12/2020--r_tpaysum2.amtpay,
		   'AL',global_v_coduser,global_v_coduser);
      end if;
    end loop;
    p_numrec := nvl(p_numrec,0) + 1;
  end;

  procedure upd_totsum (p_codempid in varchar2, p_codcomp in varchar2, p_typpayroll in varchar2,
                        p_typemp   in varchar2, /*p_codcurr in varchar2,*/ p_amtothr in varchar2) is
    v_flgfound 		boolean;
    v_rtesmot     	number;
    v_amtottot    	number;
    v_sumqtyot    	number;
    v_sumamtot    	number;

    v_flgfound2 	boolean;
    v_rtesmot2    	number;
    v_amtottot2   	number;
    v_sumqtyot2   	number;
    v_sumamtot2   	number;
    v_codcompw		varchar2(40);
    v_costcent		varchar2(40);

  cursor c_tpaysumd is
    select codempid,codcompw,rtesmot,qtymot,amtottot
      from tpaysumd
     where dteyrepay  = (p_dteyrepay - global_v_zyear)
       and dtemthpay  = to_number(p_dtemthpay)
       and numperiod  = p_numperiod
       and codempid   = p_codempid;

  cursor c_totsumd is
    select rowid,amtspot
      from totsumd
     where codempid   = p_codempid
       and dteyrepay  = (p_dteyrepay - global_v_zyear)
       and dtemthpay  = to_number(p_dtemthpay)
       and numperiod  = p_numperiod
       and rtesmot		= v_rtesmot
       and codcompw   = v_codcompw;

  cursor c_totsum is
    select rowid,amtottot
      from totsum
     where codempid   = p_codempid
       and dteyrepay  = (p_dteyrepay - global_v_zyear)
       and dtemthpay  = to_number(p_dtemthpay)
       and numperiod  = p_numperiod;

  begin
   --
    v_sumqtyot := 0; v_sumamtot := 0; v_amtottot := 0;
    for r_tpaysumd in c_tpaysumd loop
    	v_codcompw := r_tpaysumd.codcompw;
      v_amtottot := nvl(stddec(r_tpaysumd.amtottot,p_codempid,v_chken),0);
      if v_amtottot > 0 then
        v_rtesmot  := r_tpaysumd.rtesmot;
        v_sumqtyot := v_sumqtyot + r_tpaysumd.qtymot;
        v_sumamtot := v_sumamtot + v_amtottot;
        v_flgfound := false;
        for r_totsumd in c_totsumd loop
          v_flgfound := true;
          v_amtottot := nvl(stddec(r_totsumd.amtspot,p_codempid,v_chken),0) + v_amtottot;
          update totsumd
            set qtysmot = qtysmot + r_tpaysumd.qtymot,
                amtspot = stdenc(v_amtottot,p_codempid,v_chken),
                codsys  = 'AL',
                codcreate = global_v_coduser,
                coduser = global_v_coduser
            where rowid = r_totsumd.rowid;
        end loop;
        --costcent--
        begin
          select costcent into v_costcent
            from tcenter
           where codcomp = v_codcompw;
        exception when no_data_found then
          v_costcent := null;
        end;
        if not v_flgfound then
          insert into totsumd(codempid,dteyrepay,dtemthpay,numperiod,codcompw, costcent, codsys ,
                              rtesmot,qtysmot,amtspot,coduser, codcreate)
                       values(p_codempid,(p_dteyrepay - global_v_zyear),to_number(p_dtemthpay),p_numperiod,r_tpaysumd.codcompw,v_costcent,'AL',
                              v_rtesmot,r_tpaysumd.qtymot,stdenc(v_amtottot,p_codempid,v_chken),global_v_coduser,global_v_coduser );
        end if;
      end if;
    end loop;
    --
    if v_sumamtot > 0 then
      v_flgfound := false;
      for r_totsum in c_totsum loop
        v_flgfound := true;
        v_sumamtot := nvl(stddec(r_totsum.amtottot,p_codempid,v_chken),0) + v_sumamtot;
        update totsum
           set codcomp    = p_codcomp,
               typpayroll = p_typpayroll,
               typemp     = p_typemp,
               amtothr	  = p_amtothr,
--               codcurr    = p_codcurr,
               qtysmot    = qtysmot + v_sumqtyot,
               amtottot   = stdenc(v_sumamtot,p_codempid,v_chken),
               coduser    = global_v_coduser,
               codcreate  = global_v_coduser
         where rowid = r_totsum.rowid;
      end loop;

       --costcent--
        begin
          select costcent into v_costcent
            from tcenter
           where codcomp = v_codcompw;
        exception when no_data_found then
          v_costcent := null;
        end;

      if not v_flgfound then
        insert into totsum(codempid,dteyrepay,dtemthpay,numperiod, costcent,
                           codcomp,typpayroll,typemp,
                           qtysmot,amtottot,amtothr/*,codcurr*/,coduser,codcreate )
                    values(p_codempid,(p_dteyrepay - global_v_zyear),to_number(p_dtemthpay),p_numperiod,v_costcent,
                           p_codcomp,p_typpayroll,p_typemp,
                           v_sumqtyot,stdenc(v_sumamtot,p_codempid,v_chken),p_amtothr/*,p_codcurr*/,global_v_coduser,global_v_coduser);
      end if;
    end if;
    --
    p_numrec := nvl(p_numrec,0) + 1;
  end;
end HRAL72B;

/
