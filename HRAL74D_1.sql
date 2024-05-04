--------------------------------------------------------
--  DDL for Package Body HRAL74D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL74D" as
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
    p_codcompy          := hcm_util.get_codcomp_level(p_codcomp,1);
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
    v_trnbank     varchar2(1 char);
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
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tcodtypy');
        return;
			end;
		end if;
    if p_codempid is not null then
      begin
        select codcomp, typpayroll into p_codcomp, p_typpayroll
        from   temploy1
        where  codempid = p_codempid;
        p_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'temploy1');
        return;
      end;
      v_flgsecu := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;

      begin
        select 'Y' into v_trnbank
        from  ttaxcur
        where codempid  = p_codempid
        and   dteyrepay = (p_dteyrepay - global_v_zyear)
        and   dtemthpay = to_number(p_dtemthpay)
        and   numperiod = p_numperiod
        and   nvl(flgtrnbank,'N') = 'Y';
      exception when no_data_found then
        v_trnbank := 'N';
      end;
      if v_trnbank = 'Y' then
        param_msg_error := get_error_msg_php('AL0076',global_v_lang); 
        return;
      end if;
    else      
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      v_trnbank := 'N';
      begin
        select 'Y' into v_trnbank
        from  ttaxcur
        where codcompy    = p_codcompy
        and   typpayroll  = p_typpayroll
        and   dteyrepay   = (p_dteyrepay - global_v_zyear)
        and   dtemthpay   = to_number(p_dtemthpay)
        and   numperiod   = p_numperiod
        and   nvl(flgtrnbank,'N') = 'Y'
        and   rownum = 1;
      exception when no_data_found then
        null;
      end;
      if v_trnbank = 'Y' then
        param_msg_error := get_error_msg_php('AL0076',global_v_lang); 
        return;
      end if;
    end if;
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
      select t1.codpay
        from tpriodal t1
       where t1.codcompy   = p_codcompy
         and t1.typpayroll = p_typpayroll
         and t1.dteyrepay  = p_dteyrepay - global_v_zyear
         and t1.dtemthpay  = p_dtemthpay
         and t1.numperiod  = p_numperiod
         and exists (select t2.codpay
                       from tpaysum t2
                      where t2.codcomp like p_codcompy||'%'
                        and t2.typpayroll = t1.typpayroll
                        and t2.dteyrepay  = t1.dteyrepay
                        and t2.dtemthpay  = t1.dtemthpay
                        and t2.numperiod  = t1.numperiod
                        and t2.codpay = t1.codpay
                        and t2.flgtran   = 'Y')
        order by t1.codpay;

  begin
    obj_row  := json_object_t();
    v_rcnt   := 0;
    for c1 in c_tpriodal loop
      v_exist      := true;
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codpay', c1.codpay);
      obj_data.put('despay', get_tinexinf_name(c1.codpay,global_v_lang));
      obj_data.put('numrec', '');
      obj_row.put(to_char(v_rcnt), obj_data);
    end loop;

    if not v_exist then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tpriodal');
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
        if v_flg = 'Y' then
          cancel_data;
          v_rcnt       := v_rcnt+1;
          obj_data     := json_object_t();
          obj_data.put('codpay', p_codpay);
          obj_data.put('despay', get_tinexinf_name(p_codpay,global_v_lang));
          obj_data.put('numrec', nvl(p_numrec,0));
          obj_row.put(to_char(v_rcnt-1), obj_data);
        end if;
      end loop;
      data_row := obj_row.to_clob;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2421',global_v_lang);
        v_response := get_response_message(null,param_msg_error,global_v_lang);

        json_obj.put('coderror',hcm_util.get_string_t(json_object_t(v_response),'coderror'));
        json_obj.put('desc_coderror',hcm_util.get_string_t(json_object_t(v_response),'desc_coderror'));
        json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
        json_obj.put('param_json',data_row);
        commit;
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        rollback;
      end if;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
    end if;
    json_str_output := json_obj.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_transfer_data;

  procedure cancel_data is
    v_flgsecu		boolean;
    v_codempid	temploy1.codempid%type;
    v_codpay		tpriodal.codpay%type;
    v_codcurr		temploy3.codcurr%type;
    v_check 	  boolean := false;
    v_codalw		tpaysum.codalw%type;
    v_codot			tcontrot.codot%type;
    v_codlev		tcontal2.codlev%type;
    v_trnbank   varchar2(1 char);

    cursor c_emp is
      select codempid,codcomp,typpayroll,typemp,numlvl
        from temploy1
       where ((p_codempid is not null and codempid = p_codempid)
          or (p_codempid is null and codcomp like p_codcomp||'%'
                                 and typpayroll = p_typpayroll))
         and staemp in ('1','3','9')
         and exists (select codempid
                       from tpaysum
                      where tpaysum.codempid = temploy1.codempid
                        and dteyrepay = (p_dteyrepay - global_v_zyear)
                        and dtemthpay = to_number(p_dtemthpay)
                        and numperiod = p_numperiod
                        and flgtran   = 'Y')
      order by codempid;

    cursor c_tpaysum is
      select rowid,codalw,codpay
        from tpaysum
       where dteyrepay = (p_dteyrepay - global_v_zyear)
         and dtemthpay = to_number(p_dtemthpay)
         and numperiod = p_numperiod
         and codempid  = v_codempid
         and codpay		 = v_codpay
         and flgtran	 = 'Y'
         and not exists (select codempid
                           from tsincexp
                          where tsincexp.codempid = tpaysum.codempid
                            and tsincexp.dteyrepay = tpaysum.dteyrepay
                            and tsincexp.dtemthpay = tpaysum.dtemthpay
                            and tsincexp.numperiod = tpaysum.numperiod
                            and tsincexp.codpay = tpaysum.codpay)
         ;

    cursor c_tpaysum_alw is
      select rowid,codalw,codpay,amtday,qtyday,amtpay  --del amtothr
        from tpaysum
       where dteyrepay = (p_dteyrepay - global_v_zyear)
         and dtemthpay = to_number(p_dtemthpay)
         and numperiod = p_numperiod
         and codempid  = v_codempid
         and codalw		 = v_codalw
         and flgtran	 = 'Y';
  begin
    begin
      select codlev
        into v_codlev
        from tcontal2
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec) from tcontal2
                          where	codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and	dteeffec <= sysdate);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tcontal2');
    end;

    begin
      select codot
        into v_codot
        from tcontrot
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec) from tcontrot
                          where	codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and	dteeffec <= sysdate);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tcontrot');
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

        begin
          select 'Y' into v_trnbank
          from  ttaxcur
          where codempid  = r_emp.codempid
          and   dteyrepay = (p_dteyrepay - global_v_zyear)
          and   dtemthpay = to_number(p_dtemthpay)
          and   numperiod = p_numperiod
          and   nvl(flgtrnbank,'N') = 'Y';
        exception when no_data_found then
          v_trnbank := 'N';
        end;
        if v_trnbank = 'Y' then
          exit main_loop;
        end if;

        for r1 in c_tpaysum loop
          if r1.codalw = 'OT' then
            del_totsum(v_codempid);
            -- MARK FLAG --
            update tpaysum
               set flgtran = 'N',coduser = global_v_coduser
             where rowid   = r1.rowid;

            v_codalw := 'MEAL';
            for r2 in c_tpaysum_alw loop
              del_tothinc(v_codempid,r2.codpay);
              -- MARK FLAG --
              update tpaysum
                 set flgtran = 'N',coduser = global_v_coduser
               where rowid   = r2.rowid;
            end loop;
          elsif r1.codalw = 'AWARD' then
            del_tothinc(v_codempid,r1.codpay);
            -- MARK FLAG --
            update tpaysum
               set flgtran = 'N',coduser = global_v_coduser
             where rowid   = r1.rowid;

            v_codalw := 'RET_AWARD';
            for r2 in c_tpaysum_alw loop
              del_tothinc(v_codempid,r2.codpay);
              -- MARK FLAG --
              update tpaysum
                 set flgtran = 'N',coduser = global_v_coduser
               where rowid   = r2.rowid;
            end loop;
          else
						del_tothinc(v_codempid,r1.codpay);
            -- MARK FLAG --
            update tpaysum
               set flgtran = 'N',coduser = global_v_coduser
             where rowid   = r1.rowid;
          end if;
        end loop;
        if v_codpay = v_codlev then
          v_codalw := 'DED_LEAVE';
          for r2 in c_tpaysum_alw loop
              del_tothinc(v_codempid,r2.codpay);
              -- MARK FLAG --
              update tpaysum
                 set flgtran = 'N',coduser = global_v_coduser
               where rowid   = r2.rowid;
          end loop;
        end if;

        exit main_loop;
      end loop;
    end loop;
    ------ MARK FLAG ------
    update tpriodal set flgcal = 'N'
     where codcompy   = p_codcompy
       and typpayroll = p_typpayroll
       and dteyrepay  = (p_dteyrepay - global_v_zyear)
       and dtemthpay  = p_dtemthpay
       and numperiod  = p_numperiod
       and codpay     = v_codpay;
  end;

  procedure del_totsum (v_codempid in varchar2) is
    cursor c_totsum is
      select rowid
        from totsum
       where codempid   = v_codempid
         and dteyrepay  = (p_dteyrepay - global_v_zyear)
         and dtemthpay  = to_number(p_dtemthpay)
         and numperiod  = p_numperiod;

    cursor c_totsumd is
      select rowid
        from totsumd
       where codempid   = v_codempid
         and dteyrepay  = (p_dteyrepay - global_v_zyear)
         and dtemthpay  = to_number(p_dtemthpay)
         and numperiod  = p_numperiod;

  begin
    for r_totsumd in c_totsumd loop
      delete totsumd where rowid = r_totsumd.rowid;
    end loop;

    for r_totsum in c_totsum loop
      delete totsum	where rowid = r_totsum.rowid;
    end loop;

    update tovrtime
      set flgotcal	 = 'N',
          coduser	   = global_v_coduser
    where codempid   = v_codempid
      and dteyrepay  = (p_dteyrepay - global_v_zyear)
      and dtemthpay  = to_number(p_dtemthpay)
      and numperiod  = p_numperiod;

    p_numrec := nvl(p_numrec,0) + 1;
  end;

  procedure del_tothinc (v_codempid in varchar2, v_codpay in varchar2) is
    cursor c_tothinc is
      select rowid
        from tothinc
       where codempid   = v_codempid
         and dteyrepay  = (p_dteyrepay - global_v_zyear)
         and dtemthpay  = to_number(p_dtemthpay)
         and numperiod  = p_numperiod
         and codpay     = v_codpay;

    cursor c_tothinc2 is
      select rowid
        from tothinc2
       where codempid   = v_codempid
         and dteyrepay  = (p_dteyrepay - global_v_zyear)
         and dtemthpay  = to_number(p_dtemthpay)
         and numperiod  = p_numperiod
         and codpay     = v_codpay;
  begin
    for r_tothinc in c_tothinc loop
      delete tothinc where rowid = r_tothinc.rowid;
    end loop;
    --
    for r_tothinc2 in c_tothinc2 loop
      delete tothinc2 where rowid = r_tothinc2.rowid;
    end loop;
    p_numrec := nvl(p_numrec,0) + 1;
  end;
end HRAL74D;

/
