--------------------------------------------------------
--  DDL for Package Body HRAL73X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL73X" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_chken        := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codalw            := hcm_util.get_string_t(json_obj,'p_codalw');
    p_codpay            := hcm_util.get_string_t(json_obj,'p_codpay');
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_report            := to_number(hcm_util.get_string_t(json_obj,'p_report'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
    v_secur   boolean	:= null;
  begin
    if p_report is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if nvl(p_dteyrepay,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      if p_typpayroll is not null then
        begin
          select codcodec into v_typpayroll
            from tcodtypy
           where codcodec = p_typpayroll;
          v_typpayroll := p_typpayroll;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
          return;
        end;
      end if;
    elsif p_codempid is not null then
        p_codcomp := null;
        p_typpayroll := null;
        --
        begin
          select codempid
            into p_codempid
            from temploy1
           where codempid = p_codempid;
        exception when no_data_found then null;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          return;
        end;
        --
        if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
        end if;
    end if;
  end check_index;

  procedure check_detail is
    v_count number := 0;
  begin
    check_index;
    if param_msg_error is not null then
      return;
    end if;
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    else
      if p_codalw is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      else
          begin
            select  count(*)
              into  v_count
              from  tpaysum a,temploy1 b
             where  a.codpay     = p_codpay
               and  a.codalw     = p_codalw
               and  a.codempid   = b.codempid
               and  a.dteyrepay  = p_dteyrepay
               and  a.dtemthpay  = p_dtemthpay
               and  a.numperiod  = p_numperiod
               and  a.codempid   = nvl(p_codempid,a.codempid)
               and  a.codcomp 	 like p_codcomp||'%'
               and  a.typpayroll = nvl(p_typpayroll,a.typpayroll)
               and  (p_report 	 = '2'
                or  (p_report 	 = '1' and a.codalw not in ('AWARD','RET_AWARD')))
               and  b.numlvl between global_v_zminlvl and global_v_zwrklvl
               and  exists (select c.coduser
                              from tusrcom c
                             where c.coduser = global_v_coduser
                               and b.codcomp like c.codcomp || '%')
         group by  codalw
         order by  codalw;
          exception when others then null;
          end;
          if v_count = 0 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpaysum');
             return;
          end if;
      end if;
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  	json_obj		json_object_t := json_object_t();
  	json_row		json_object_t;
  	json_row1		json_object_t;
  	json_row2		json_object_t;
    v_exist         boolean := false;
    v_permission    boolean := false;
    v_check         varchar2(1 char) := '1';
    v_secure        varchar2(4000 char);
  	v_count			number := 0;
  	v_count2		number := 0;
    v_codpay 		tpaysum.codpay%type;
    cursor c1 is
      select a.codpay, get_tinexinf_name(a.codpay,global_v_lang) desc_codpay
        from tpaysum a,temploy1 b
       where a.codempid   = b.codempid
         and a.dteyrepay  = p_dteyrepay
         and a.dtemthpay  = p_dtemthpay
         and a.numperiod  = p_numperiod
         and a.codempid   = nvl(p_codempid,a.codempid)
         and a.codcomp like p_codcomp||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and (p_report = '2'
          or (p_report = '1' and a.codalw not in ('AWARD','RET_AWARD')))
         and  (
              (v_check = '1')
               or (v_check = '2'
                   and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                   and exists (select c.coduser
                                 from tusrcom c
                                where c.coduser = global_v_coduser
                                  and b.codcomp like c.codcomp || '%')
                  )
             )
    group by codpay
    order by codpay;

    cursor c2 is
      select a.codalw, get_tlistval_name('CODALW',a.codalw,global_v_lang) desc_codalw
        from tpaysum a,temploy1 b
       where a.codempid = b.codempid
         and a.dteyrepay  = p_dteyrepay
         and a.dtemthpay  = p_dtemthpay
         and a.numperiod  = p_numperiod
         and a.codempid   = nvl(p_codempid,a.codempid)
         and a.codcomp 	like p_codcomp||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codpay   = v_codpay
         and (p_report 	= '2'
          or (p_report 	= '1' and a.codalw not in ('AWARD','RET_AWARD')))
         and  (
              (v_check = '1')
               or (v_check = '2'
                   and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                   and exists (select c.coduser
                                 from tusrcom c
                                where c.coduser = global_v_coduser
                                  and b.codcomp like c.codcomp || '%')
                  )
             )
    group by codalw
    order by codalw;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      for r1 in c1 loop
        v_exist := true;
        exit;
      end loop;
      if not v_exist then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tpaysum');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
      v_check := '2';
      for r1 in c1 loop
      	v_codpay  := r1.codpay;
      	json_row  := json_object_t();
      	json_row1 := json_object_t();
      	json_row.put('codpay', r1.codpay);
      	json_row.put('desc_codpay', r1.desc_codpay);
      	v_count2  := 0;
      	for r2 in c2 loop
            v_permission := true;
	      	json_row2 := json_object_t();
	      	json_row2.put('codalw', r2.codalw);
	      	json_row2.put('desc_codalw', r2.desc_codalw);
	      	json_row1.put(to_char(v_count2), json_row2);
	      	v_count2 := v_count2 + 1;
      	end loop;
      	json_row.put('alw', json_row1);
      	json_row.put('coderror', '200');
      	json_obj.put(to_char(v_count), json_row);
      	v_count := v_count + 1;
      end loop;
      if not v_permission then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
      json_str_output := json_obj.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if p_report = '1' then
      if p_codalw = 'OT' then
        gen_detail_ot(json_str_output);
      else
        gen_detail(json_str_output);
      end if;
    else
      gen_detail_summary(json_str_output);
    end if;
    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row         number  := 0;
    v_secur       boolean := false;
    v_exist       boolean := false;
    v_permission  boolean := false;
    v_r_codcomp   tcenter.codcomp%type;
    v_namcentlvl  varchar2(4000 char);
    v_namcent     varchar2(4000 char);
    v_comlevel    number;
    v_chken       varchar2(4000 char) := hcm_secur.get_v_chken;
    v_amtpay		  number 		:= 0;
    v_qtymin      number 		:= 0;
    v_cost_center varchar2(500 char);

    cursor c_tpaysum is
      select  a.codempid ,a.codcomp  ,b.dtework ,
              b.codshift ,b.timstrt  ,b.timend  ,
              nvl(b.qtymin,0) qtymin ,b.amtday  ,
              b.amtothr  ,b.amtpay   ,nvl(b.codcompw,a.codcomp) codcomp_charge
        from  tpaysum a,tpaysum2 b
       where  a.dteyrepay  = b.dteyrepay
         and  a.dtemthpay  = b.dtemthpay
         and  a.numperiod  = b.numperiod
         and  a.codempid   = b.codempid
         and  a.codalw     = b.codalw
         and  a.codpay     = b.codpay
         and  a.dteyrepay  = p_dteyrepay
         and  a.dtemthpay  = p_dtemthpay
         and  a.numperiod  = p_numperiod
         and  a.codpay     = p_codpay
         and  a.codalw     = p_codalw
         and  a.codempid   = nvl(p_codempid,a.codempid)
         and  a.codcomp    like p_codcomp||'%'
         and  a.typpayroll = nvl(p_typpayroll,a.typpayroll)
    order by  a.codcomp,a.codempid,b.dtework,b.timstrt,b.timend;

  begin
    obj_row := json_object_t();
    for r1 in c_tpaysum loop
      v_exist := true;
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then

        begin
          select costcent into v_cost_center
            from tcenter
           where codcomp = r1.codcomp_charge
             and rownum <= 1
        order by codcomp;
        exception when no_data_found then
          v_cost_center := null;
        end;

        v_permission := true;
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('v_row'    , v_row);
        obj_data.put('image'    , get_emp_img(r1.codempid));
        obj_data.put('codempid' , r1.codempid);
        obj_data.put('desc_codempid' , get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codcomp' , r1.codcomp);
        obj_data.put('desc_codcomp' , get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codcomp_' , get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
        obj_data.put('dtework'  , to_char(r1.dtework,'dd/mm/yyyy'));
        obj_data.put('codshift' , r1.codshift);
        obj_data.put('codcomp_charge' , r1.codcomp_charge);
        obj_data.put('coscent'  , v_cost_center);
        obj_data.put('typpayroll' , p_typpayroll);
        obj_data.put('numperiod' , p_numperiod);
        obj_data.put('dtemthpay' , p_dtemthpay);
        obj_data.put('dteyrepay' , p_dteyrepay);
        obj_data.put('codpay' , p_codpay);
        obj_data.put('codalw' , p_codalw);
        obj_data.put('time'     , substr(r1.timstrt,1,2) || ':' || substr(r1.timstrt,3,2) || '-' || substr(r1.timend,1,2) || ':' || substr(r1.timend,3,2));
        obj_data.put('qtyhrs'   , hcm_util.convert_minute_to_hour(r1.qtymin));
        v_qtymin 	:= v_qtymin + nvl(r1.qtymin,0);
        if v_zupdsal = 'Y' then
          obj_data.put('amtday' , stddec(r1.amtday ,r1.codempid,v_chken));
          obj_data.put('amtothr', stddec(r1.amtothr,r1.codempid,v_chken));
          obj_data.put('amtpay' , stddec(r1.amtpay ,r1.codempid,v_chken));
          v_amtpay 	:= v_amtpay + nvl(stddec(r1.amtpay ,r1.codempid,v_chken),0);
        end if;
        --
          if isInsertReport then
            if json_param_break.get_size <= 0 then
              insert_ttemprpt(obj_data);
            end if;
          end if;
        --
        obj_row.put(to_char(v_row-1),obj_data);
      end if;
    end loop;
    if isInsertReport then
      if json_param_break.get_size > 0 then
        begin
        json_break_params := json_object_t();
        json_param_json.put('data', obj_row);
        json_break_params.put('codapp', 'HRAL73X');
        json_break_params.put('p_coduser', global_v_coduser);
        json_break_params.put('p_codempid', global_v_codempid);
        json_break_params.put('p_lang', global_v_lang);
        json_break_params.put('json_input_str1', json_param_json);
        json_break_params.put('json_input_str2', json_param_break);
        json_str_output := json_break_params.to_clob;
        json_break_output := json_object_t(hcm_breaklevel.get_breaklevel(json_str_output));
        json_break_output_row   := hcm_util.get_json_t(json_break_output, 'param_json');
        for i in 0..json_break_output_row.get_size - 1 loop
          insert_ttemprpt(hcm_util.get_json_t(json_break_output_row, to_char(i)));
        end loop;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      end if;
      insert_ttemprpt_head(obj_data);
    end if;
    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tpaysum');
      return;
    end if;
    if not v_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_ot(json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row         number  := 0;
    v_secur       boolean := false;
    v_exist       boolean := false;
    v_r_codcomp   tcenter.codcomp%type;
    v_namcentlvl  varchar2(4000 char);
    v_namcent     varchar2(4000 char);
    v_comlevel    number;
    v_chken       varchar2(4000 char) := hcm_secur.get_v_chken;
    v_codempid    totpaydt.codempid%type;
    v_dtework     totpaydt.dtework%type;
    v_typot       varchar2(4000 char);
    flg_secur     varchar2(1) := 'N';
    v_data        varchar2(1) := 'N';
    v_amtpay		  number 		:= 0;
    v_qtymin      number 		:= 0;
    v_cost_center varchar2(500 char);

    cursor c_tpaysum is
      select  a.codempid ,a.codcomp  ,b.dtework ,
              b.codshift ,b.timstrt  ,b.timend  ,
              nvl(b.qtymin,0) qtymin ,b.amtday  ,
              b.amtothr  ,b.amtpay   , nvl(b.codcompw,a.codcomp) codcomp_charge
        from  tpaysum a,tpaysum2 b
       where  a.dteyrepay  = b.dteyrepay
         and  a.dtemthpay  = b.dtemthpay
         and  a.numperiod  = b.numperiod
         and  a.codempid   = b.codempid
         and  a.codalw     = b.codalw
         and  a.codpay     = b.codpay
         and  a.dteyrepay  = p_dteyrepay
         and  a.dtemthpay  = p_dtemthpay
         and  a.numperiod  = p_numperiod
         and  a.codpay     = p_codpay
         and  a.codalw     = p_codalw
         and  a.codempid   = nvl(p_codempid,a.codempid)
         and  a.codcomp    like p_codcomp||'%'
         and  a.typpayroll = nvl(p_typpayroll,a.typpayroll)
    order by  a.codcomp,a.codempid,b.dtework,b.timstrt,b.timend;

    cursor c_totpaydt is
      select  dtework,typot,rteotpay,nvl(qtyminot,0) qtyminot,amtottot
        from  totpaydt
       where  codempid = v_codempid
         and  dtework  = v_dtework
         and  typot    = v_typot
    order by  typot,rteotpay;

  begin
    obj_row := json_object_t();
    v_row   := 0;
    for r1 in c_tpaysum loop
      v_exist := true;
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
        begin
          select costcent into v_cost_center
            from tcenter
           where codcomp = r1.codcomp_charge
             and rownum <= 1
        order by codcomp;
        exception when no_data_found then
          v_cost_center := null;
        end;
        flg_secur := 'Y';
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('v_row' , (v_row+1));
        obj_data.put('image'    , get_emp_img(r1.codempid));
        obj_data.put('codempid' , r1.codempid);
        obj_data.put('desc_codempid' , get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codcomp' , r1.codcomp);
        obj_data.put('desc_codcomp' , get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codcomp_' , get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
        obj_data.put('dtework'  , to_char(r1.dtework,'dd/mm/yyyy'));
        obj_data.put('typot'    , r1.codshift);
        obj_data.put('codshift'    , r1.codshift);
        obj_data.put('codcomp_charge' , r1.codcomp_charge);
        obj_data.put('coscent'    , v_cost_center);
        obj_data.put('typpayroll' , p_typpayroll);
        obj_data.put('numperiod' , p_numperiod);
        obj_data.put('dtemthpay' , p_dtemthpay);
        obj_data.put('dteyrepay' , p_dteyrepay);
        obj_data.put('codpay' , p_codpay);
        obj_data.put('codalw' , p_codalw);
        obj_data.put('time'     , substr(r1.timstrt,1,2) || ':' || substr(r1.timstrt,3,2) || '-' || substr(r1.timend,1,2) || ':' || substr(r1.timend,3,2));
        obj_data.put('qtyhrs'   , hcm_util.convert_minute_to_hour(r1.qtymin));
        --
        if v_zupdsal = 'Y' then
          obj_data.put('amtday' , stddec(r1.amtday ,r1.codempid,v_chken));
          obj_data.put('amtothr', stddec(r1.amtothr,r1.codempid,v_chken));
        else
          obj_data.put('amtday' , '');
          obj_data.put('amtothr', '');
        end if;
        v_codempid  := r1.codempid;
        v_dtework   := r1.dtework;
        v_typot     := r1.codshift;
        for r2 in c_totpaydt loop
          v_data := 'Y';
          obj_data := json_object_t();
          obj_data.put('coderror' , '200');
          obj_data.put('v_row' , (v_row+1));
          obj_data.put('image'    , get_emp_img(r1.codempid));
          obj_data.put('codempid' , r1.codempid);
          obj_data.put('desc_codempid' , get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('codcomp'  , r1.codcomp);
          obj_data.put('desc_codcomp' , get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('desc_codcomp_' , get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
          obj_data.put('dtework'  , to_char(r1.dtework,'dd/mm/yyyy'));
          obj_data.put('typot'    , r1.codshift);
          obj_data.put('codcomp_charge' , r1.codcomp_charge);
          obj_data.put('coscent'    , v_cost_center);
          obj_data.put('time'     , substr(r1.timstrt,1,2) || ':' || substr(r1.timstrt,3,2) || '-' || substr(r1.timend,1,2) || ':' || substr(r1.timend,3,2));
          obj_data.put('qtyhrs'   , hcm_util.convert_minute_to_hour(r1.qtymin));
          v_qtymin 	:= v_qtymin + nvl(r1.qtymin,0); --user36 MAE-HR2201 #9442 20/05/2023 change to use tpaysum2 data
          if v_zupdsal = 'Y' then
            obj_data.put('amtday' , stddec(r1.amtday ,r1.codempid,v_chken));
            obj_data.put('amtothr', stddec(r1.amtothr,r1.codempid,v_chken));
            --<<user36 MAE-HR2201 #9442 20/05/2023 change to use tpaysum2 data
            obj_data.put('amtpay',stddec(r1.amtpay,r1.codempid,v_chken));
            v_amtpay 	:= v_amtpay + nvl(stddec(r1.amtpay,r1.codempid,v_chken),0);
            -->>user36 MAE-HR2201 #9442 20/05/2023 change to use tpaysum2 data
          end if;
          obj_data.put('rteotpay' , r2.rteotpay);

          /*user36 MAE-HR2201 #9442 20/05/2023 change to use tpaysum2 data
          obj_data.put('qtyhrs'   , hcm_util.convert_minute_to_hour(r2.qtyminot));
          v_qtymin 	:= v_qtymin + nvl(r2.qtyminot,0);           
          if v_zupdsal = 'Y' then
            obj_data.put('amtpay',stddec(r2.amtottot,r1.codempid,v_chken));
            v_amtpay 	:= v_amtpay + nvl(stddec(r2.amtottot,r1.codempid,v_chken),0);            
          end if;
          */

          obj_data.put('typpayroll' , p_typpayroll);
          obj_data.put('numperiod' , p_numperiod);
          obj_data.put('dtemthpay' , p_dtemthpay);
          obj_data.put('dteyrepay' , p_dteyrepay);
          obj_data.put('codpay' , p_codpay);
          obj_data.put('codalw' , p_codalw);
          if isInsertReport then
            if json_param_break.get_size <= 0 then
              insert_ttemprpt_ot(obj_data);
            end if;
          end if;
          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row + 1;
        end loop;
        if v_data = 'N' then
          v_qtymin 	:= v_qtymin + nvl(r1.qtymin,0);
          --
          if isInsertReport then
            if json_param_break.get_size <= 0 then
              insert_ttemprpt_ot(obj_data);
            end if;
          end if;
          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row + 1;
        end if;
      end if;
    end loop;
    if isInsertReport then
      if json_param_break.get_size > 0 then
        begin
        json_break_params := json_object_t();
        json_param_json.put('data', obj_row);
        json_break_params.put('codapp', 'HRAL73X');
        json_break_params.put('p_coduser', global_v_coduser);
        json_break_params.put('p_codempid', global_v_codempid);
        json_break_params.put('p_lang', global_v_lang);
        json_break_params.put('json_input_str1', json_param_json);
        json_break_params.put('json_input_str2', json_param_break);
        json_str_output := json_break_params.to_clob;
        json_break_output := json_object_t(hcm_breaklevel.get_breaklevel(json_str_output));
        json_break_output_row   := hcm_util.get_json_t(json_break_output, 'param_json');
        for i in 0..json_break_output_row.get_size - 1 loop
          insert_ttemprpt_ot(hcm_util.get_json_t(json_break_output_row, to_char(i)));
        end loop;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      end if;
      insert_ttemprpt_head(obj_data);
    end if;
    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tpaysum');
      return;
    end if;
    if flg_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_summary(json_str_output out clob) as
    json_obj        json_object_t := json_object_t();
    json_row        json_object_t;
    v_secur         boolean := false;
    v_exist         boolean := false;
    v_permission    boolean := false;
    v_r_codcomp     tcenter.codcomp%type;
    v_namcentlvl    varchar2(4000 char);
    v_namcent       varchar2(4000 char);
    v_comlevel      number;
    v_chken         varchar2(4000 char) := hcm_secur.get_v_chken;
    v_count         number  := 0;
    cursor c_tpaysum is
      select  codempid,codcomp,codpos,
              nvl(amtday ,0) amtday,nvl(qtyday,0) qtyday,
              nvl(qtymin ,0) qtymin,nvl(amtpay,0) amtpay,
              nvl(amtothr,0) amtothr
        from  tpaysum
       where  dteyrepay  = p_dteyrepay
         and  dtemthpay  = p_dtemthpay
         and  numperiod  = p_numperiod
         and  codpay     = p_codpay
         and  codalw     = p_codalw
         and  codempid   = nvl(p_codempid,codempid)
         and  codcomp    like p_codcomp || '%'
         and  typpayroll = nvl(p_typpayroll,typpayroll)
    order by  codcomp,codempid;

  begin
    for r1 in c_tpaysum loop
      v_exist := true;
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
        v_permission := true;
        json_row := json_object_t();
        json_row.put('image'        , get_emp_img(r1.codempid));

        json_row.put('codempid'     , r1.codempid);
        json_row.put('v_row', (v_count+1));
        json_row.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        json_row.put('codcomp' , r1.codcomp);
        json_row.put('desc_codcomp' , get_tcenter_name(r1.codcomp,global_v_lang));
        json_row.put('desc_codcomp_' , get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp,1),global_v_lang));
        json_row.put('codpos'       , r1.codpos);
        json_row.put('desc_codpos'  , get_tpostn_name(r1.codpos,global_v_lang));
        json_row.put('typpayroll' , p_typpayroll);
        json_row.put('numperiod' , p_numperiod);
        json_row.put('dtemthpay' , p_dtemthpay);
        json_row.put('dteyrepay' , p_dteyrepay);
        json_row.put('codpay' , p_codpay);
        json_row.put('codalw' , p_codalw);

        if p_codalw not in ('AWARD','RET_AWARD') then
          json_row.put('qtyhrs',to_char(trunc(r1.qtymin /60,0)||':'||lpad(round(mod(r1.qtymin,60),0),2,'0')));
          if v_zupdsal = 'Y' then
            json_row.put('amtothr',stddec(r1.amtothr,r1.codempid,v_chken));
          end if;
        end if;
        if v_zupdsal = 'Y' then
          json_row.put('amtpay',stddec(r1.amtpay,r1.codempid,v_chken));
        end if;
        if isInsertReport then

          if json_param_break.get_size <= 0 then

            insert_ttemprpt_summary(json_row);
          end if;
        end if;
        json_row.put('coderror','200');
        json_obj.put(to_char(v_count),json_row);
        v_count := v_count + 1;
      end if;
    end loop;
    if isInsertReport then

      if json_param_break.get_size > 0 then
        begin
        json_break_params := json_object_t();
        json_param_json.put('data', json_obj);
        json_break_params.put('codapp', 'HRAL73X');
        json_break_params.put('p_coduser', global_v_coduser);
        json_break_params.put('p_codempid', global_v_codempid);
        json_break_params.put('p_lang', global_v_lang);
        json_break_params.put('json_input_str1', json_param_json);
        json_break_params.put('json_input_str2', json_param_break);
        json_str_output := json_break_params.to_clob;
        json_break_output := json_object_t(hcm_breaklevel.get_breaklevel(json_str_output));
        json_break_output_row   := hcm_util.get_json_t(json_break_output, 'param_json');

        for i in 0..json_break_output_row.get_size - 1 loop
          insert_ttemprpt_summary(hcm_util.get_json_t(json_break_output_row, to_char(i)));
        end loop;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      end if;
      insert_ttemprpt_head(json_row);
    end if;
    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tpaysum');
      return;
    end if;
    if not v_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function getLevelCodcomp (v_codcomp varchar2) return number as
    v_level number;
  begin
    select comlevel
      into v_level
      from tcenter
     where codcomp = v_codcomp;
    return v_level;
  exception when no_data_found then
    return 0;
  end;

  function getTrueLevel (v_level varchar2) return number as
    v_truelevel number := 0;
  begin
    if p_breaklevel10 and v_level > 9 then
      return 10;
    end if;
    if p_breaklevel9 and v_level > 8 then
      return 9;
    end if;
    if p_breaklevel8 and v_level > 7 then
      return 8;
    end if;
    if p_breaklevel7 and v_level > 6 then
      return 7;
    end if;
    if p_breaklevel6 and v_level > 5 then
      return 6;
    end if;
    if p_breaklevel5 and v_level > 4 then
      return 5;
    end if;
    if p_breaklevel4 and v_level > 3 then
      return 4;
    end if;
    if p_breaklevel3 and v_level > 2 then
      return 3;
    end if;
    if p_breaklevel2 and v_level > 1 then
      return 2;
    end if;
    if p_breaklevel1 and v_level > 0 then
      return 1;
    end if;
    return v_truelevel;
  end;

  function isBreakLevel(v_codcomp1 varchar2,v_codcomp2 varchar2) return boolean as
    v_level1 number;
    v_level2 number;
  begin
    v_level1 := getTrueLevel(getLevelCodcomp(v_codcomp1));
    v_level2 := getTrueLevel(getLevelCodcomp(v_codcomp2));
    if hcm_util.get_codcomp_level(v_codcomp1,v_level1) <> hcm_util.get_codcomp_level(v_codcomp2,v_level2) or v_level1 > v_level2 then
      return true;
    else
      return false;
    end if;
  end;

  function isAddSummary(v_codcomp1 varchar2,v_codcomp2 varchar2) return boolean as
    v_level1 number;
    v_level2 number;
  begin
    v_level1 := getTrueLevel(getLevelCodcomp(v_codcomp1));
    v_level2 := getTrueLevel(getLevelCodcomp(v_codcomp2));
    if hcm_util.get_codcomp_level(v_codcomp1,v_level1) <> hcm_util.get_codcomp_level(v_codcomp2,v_level2) or v_level1 > v_level2
      and v_level2 > 0 then
      return true;
    else
      return false;
    end if;
  end;

  procedure findDiff (v_codcomp1 in varchar2,v_codcomp2 in varchar2,v_start out number,v_end out number) as
    v_level number;
    v_st    number := 0;
    v_count number := 1;
  begin
    v_end   := getTrueLevel(getLevelCodcomp(v_codcomp1));
    v_level := getTrueLevel(getLevelCodcomp(v_codcomp2));
    if v_codcomp2 is not null then
      v_start := v_end;
      while v_level > 0 loop
        if hcm_util.get_codcomp_level(v_codcomp1,v_end) like hcm_util.get_codcomp_level(v_codcomp2,v_level) || '%' then
          return;
        end if;
        v_start := v_level;
        v_level := getTrueLevel(v_level - 1);
      end loop;
    else
      while v_st = 0 and v_count <= 10 loop
        v_st := getTrueLevel(v_count);
        v_count := v_count + 1;
      end loop;
      v_start := v_st;
    end if;
  end;

  procedure countSummary(v_json in json_object_t) as
    v_qtymin  number;
    v_amtpay  number;
    v_codcomp tcenter.codcomp%type;
    v_level   number;
  begin
    v_qtymin  := nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(v_json,'qtyhrs')),0);
    v_amtpay  := nvl(hcm_util.get_string_t(v_json,'amount'),0);
    v_codcomp := hcm_util.get_string_t(v_json,'codcomp');
    v_level   := getLevelCodcomp(v_codcomp);
    if v_level > 0 then
      p_qtymin1 := p_qtymin1 + v_qtymin;
      p_amtpay1 := p_amtpay1 + v_amtpay;
    end if;
    if v_level > 1 then
      p_qtymin2 := p_qtymin2 + v_qtymin;
      p_amtpay2 := p_amtpay2 + v_amtpay;
    end if;
    if v_level > 2 then
      p_qtymin3 := p_qtymin3 + v_qtymin;
      p_amtpay3 := p_amtpay3 + v_amtpay;
    end if;
    if v_level > 3 then
      p_qtymin4 := p_qtymin4 + v_qtymin;
      p_amtpay4 := p_amtpay4 + v_amtpay;
    end if;
    if v_level > 4 then
      p_qtymin5 := p_qtymin5 + v_qtymin;
      p_amtpay5 := p_amtpay5 + v_amtpay;
    end if;
    if v_level > 5 then
      p_qtymin6 := p_qtymin6 + v_qtymin;
      p_amtpay6 := p_amtpay6 + v_amtpay;
    end if;
    if v_level > 6 then
      p_qtymin7 := p_qtymin7 + v_qtymin;
      p_amtpay7 := p_amtpay7 + v_amtpay;
    end if;
    if v_level > 7 then
      p_qtymin8 := p_qtymin8 + v_qtymin;
      p_amtpay8 := p_amtpay8 + v_amtpay;
    end if;
    if v_level > 8 then
      p_qtymin9 := p_qtymin9 + v_qtymin;
      p_amtpay9 := p_amtpay9 + v_amtpay;
    end if;
    if v_level > 9 then
      p_qtymin10 := p_qtymin10 + v_qtymin;
      p_amtpay10 := p_amtpay10 + v_amtpay;
    end if;
    p_qtyminCodempid := p_qtyminCodempid + v_qtymin;
    p_amtpayCodempid := p_amtpayCodempid + v_amtpay;
  end;

  function getQtyminSum (v_level number) return number as
  begin
    if v_level = 1 then
      return p_qtymin1;
    elsif v_level = 2 then
      return p_qtymin2;
    elsif v_level = 3 then
      return p_qtymin3;
    elsif v_level = 4 then
      return p_qtymin4;
    elsif v_level = 5 then
      return p_qtymin5;
    elsif v_level = 6 then
      return p_qtymin6;
    elsif v_level = 7 then
      return p_qtymin7;
    elsif v_level = 8 then
      return p_qtymin8;
    elsif v_level = 9 then
      return p_qtymin9;
    elsif v_level = 10 then
      return p_qtymin10;
    end if;
  end;

  function getAmtpaySum (v_level number) return number as
  begin
    if v_level = 1 then
      return p_amtpay1;
    elsif v_level = 2 then
      return p_amtpay2;
    elsif v_level = 3 then
      return p_amtpay3;
    elsif v_level = 4 then
      return p_amtpay4;
    elsif v_level = 5 then
      return p_amtpay5;
    elsif v_level = 6 then
      return p_amtpay6;
    elsif v_level = 7 then
      return p_amtpay7;
    elsif v_level = 8 then
      return p_amtpay8;
    elsif v_level = 9 then
      return p_amtpay9;
    elsif v_level = 10 then
      return p_amtpay10;
    end if;
    return 0;
  end;

  procedure resetSummary(v_level number) as
  begin
    if v_level = 1 then
      p_amtpay1 := 0;
      p_qtymin1 := 0;
    elsif v_level = 2 then
      p_amtpay2 := 0;
      p_qtymin2 := 0;
    elsif v_level = 3 then
      p_amtpay3 := 0;
      p_qtymin3 := 0;
    elsif v_level = 4 then
      p_amtpay4 := 0;
      p_qtymin4 := 0;
    elsif v_level = 5 then
      p_amtpay5 := 0;
      p_qtymin5 := 0;
    elsif v_level = 6 then
      p_amtpay6 := 0;
      p_qtymin6 := 0;
    elsif v_level = 7 then
      p_amtpay7 := 0;
      p_qtymin7 := 0;
    elsif v_level = 8 then
      p_amtpay8 := 0;
      p_qtymin8 := 0;
    elsif v_level = 9 then
      p_amtpay9 := 0;
      p_qtymin9 := 0;
    elsif v_level = 10 then
      p_amtpay10 := 0;
      p_qtymin10 := 0;
    end if;
  end;

  procedure initial_break (json_str_input in clob) as
    obj_initial        json_object_t := json_object_t(json_str_input);
    obj_breaklevel     json_object_t;
    v_flgsum           varchar2(1 char);
    v_level1           varchar2(1 char);
    v_level2           varchar2(1 char);
    v_level3           varchar2(1 char);
    v_level4           varchar2(1 char);
    v_level5           varchar2(1 char);
    v_level6           varchar2(1 char);
    v_level7           varchar2(1 char);
    v_level8           varchar2(1 char);
    v_level9           varchar2(1 char);
    v_level10          varchar2(1 char);
  begin
    global_chken        := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(obj_initial,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(obj_initial,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(obj_initial,'p_lang');

    obj_breaklevel := json_object_t(hcm_util.get_string_t(obj_initial,'breaklevel'));
    if obj_breaklevel is not null then
      v_level1   := hcm_util.get_string_t(obj_breaklevel,'level1');
      v_level2   := hcm_util.get_string_t(obj_breaklevel,'level2');
      v_level3   := hcm_util.get_string_t(obj_breaklevel,'level3');
      v_level4   := hcm_util.get_string_t(obj_breaklevel,'level4');
      v_level5   := hcm_util.get_string_t(obj_breaklevel,'level5');
      v_level6   := hcm_util.get_string_t(obj_breaklevel,'level6');
      v_level7   := hcm_util.get_string_t(obj_breaklevel,'level7');
      v_level8   := hcm_util.get_string_t(obj_breaklevel,'level8');
      v_level9   := hcm_util.get_string_t(obj_breaklevel,'level9');
      v_level10  := hcm_util.get_string_t(obj_breaklevel,'level10');
      if v_level1 is not null and v_level1 = 'Y' then
        p_breaklevel1 := true;
      end if;
      if v_level2 is not null and v_level2 = 'Y' then
        p_breaklevel2 := true;
      end if;
      if v_level3 is not null and v_level3 = 'Y' then
        p_breaklevel3 := true;
      end if;
      if v_level4 is not null and v_level4 = 'Y' then
        p_breaklevel4 := true;
      end if;
      if v_level5 is not null and v_level5 = 'Y' then
        p_breaklevel5 := true;
      end if;
      if v_level6 is not null and v_level6 = 'Y' then
        p_breaklevel6 := true;
      end if;
      if v_level7 is not null and v_level7 = 'Y' then
        p_breaklevel7 := true;
      end if;
      if v_level8 is not null and v_level8 = 'Y' then
        p_breaklevel8 := true;
      end if;
      if v_level9 is not null and v_level9 = 'Y' then
        p_breaklevel9 := true;
      end if;
      if v_level10 is not null and v_level10 = 'Y' then
        p_breaklevel10 := true;
      end if;
    end if;
    v_flgsum       := hcm_util.get_string_t(obj_initial,'flgsum');
    if v_flgsum is not null and v_flgsum = 'Y' then
      p_breaklevelAll := true;
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;

  procedure get_breaklevel (json_str_input in clob,json_str_output out clob) as
    obj_rows_old    json_object_t;
    obj_data_old    json_object_t;

    obj_rows        json_object_t := json_object_t();
    obj_data        json_object_t;
    v_count         number := 0;

    obj_token       json_object_t;

    v_codcomp1      tcenter.codcomp%type;
    v_codcomp2      tcenter.codcomp%type;
    v_codempid1     temploy1.codempid%type;
    v_codempid2     temploy1.codempid%type;
    v_start         number;
    v_end           number;

    v_level         number;
    v_namcent       tcompnyc.namcente%type;
    v_label         varchar2(4000 char);
    v_label2        varchar2(4000 char);

    v_flgbreak      varchar2(1 char);
  begin
    obj_rows_old := hcm_util.get_json_t(json_object_t(json_str_input),'rows');
    initial_break(json_str_input);
    begin
      select decode (global_v_lang,'101',desclabele,
                                   '102',desclabelt,
                                   '103',desclabel3,
                                   '104',desclabel4,
                                   '105',desclabel5)
        into v_label
        from tapplscr
       where codapp = 'HRAL73X'
         and numseq = '40';
      v_label := v_label || ' ';
    exception when no_data_found then
      null;
    end;
    begin
      select decode (global_v_lang,'101',DESCLABELE,
                                   '102',DESCLABELT,
                                   '103',DESCLABEL3,
                                   '104',DESCLABEL4,
                                   '105',DESCLABEL5)
        into v_label2
        from tapplscr
       where codapp = 'HRAL73X'
         and numseq = '50';
    exception when no_data_found then
      v_namcent := null;
    end;
    for j in 0..obj_rows_old.get_size-1 loop
      obj_data_old  := hcm_util.get_json_t(obj_rows_old,to_char(j));
      v_flgbreak    := hcm_util.get_string_t(obj_data_old,'flgbreak');
      if v_flgbreak <> 'Y' or v_flgbreak is null then
        v_codcomp1 := hcm_util.get_string_t(obj_data_old,'codcomp'); -- current
        v_codcomp2 := hcm_util.get_string_t(obj_token   ,'codcomp'); -- before
        if p_breaklevelAll then
          v_codempid1 := hcm_util.get_string_t(obj_data_old,'codempid'); -- current
          v_codempid2 := hcm_util.get_string_t(obj_token   ,'codempid'); -- before
          if obj_token is not null and v_codempid1 <> v_codempid2 then
            obj_data := json_object_t();
            obj_data.put('flgbreak','Y');
            obj_data.put('coderror','200');
            obj_data.put('desc_codempid'     ,v_label || v_label2);
            obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(p_qtyminCodempid));
            obj_data.put('amount'       ,to_char(nvl(p_amtpayCodempid,0),'fm999999999990.00'));
            obj_rows.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
            p_qtyminCodempid := 0;
            p_amtpayCodempid := 0;
          end if;
          if obj_token is not null and isAddSummary(v_codcomp1,v_codcomp2) then -- if not start and add sum
            findDiff (v_codcomp1,v_codcomp2,v_start,v_end);
            for i in v_start..v_end loop
              v_level := v_end - i + v_start;
              if v_level = getTrueLevel(v_level) and v_level > 0 then
                obj_data := json_object_t();
                obj_data.put('flgbreak','Y');
                obj_data.put('coderror','200');
--                begin
--                  select decode (global_v_lang,'101',namcente,
--                                               '102',namcentt,
--                                               '103',namcent3,
--                                               '104',namcent4,
--                                               '105',namcent5)
--                    into v_namcent
--                    from tsetcomp
--                   where numseq = v_level;
--                exception when no_data_found then
--                  v_namcent := null;
--                end;
                v_namcent   := replace(get_comp_label(v_codcomp1,v_level,global_v_lang),'*',null);
                obj_data.put('desc_codempid'     ,v_label || v_namcent);
                obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(getQtyminSum(v_level)));
                obj_data.put('amount'       ,to_char(nvl(getAmtpaySum(v_level),0),'fm999999999990.00'));
                obj_rows.put(to_char(v_count),obj_data);
                v_count := v_count + 1;
                resetSummary(v_level);
              end if;
            end loop;
          end if;
        end if;
        if obj_token is null or isBreakLevel(v_codcomp1,v_codcomp2) then -- if start or notsame breaklevel
          findDiff (v_codcomp1,v_codcomp2,v_start,v_end);
          for i in v_start..v_end loop
            if i = getTrueLevel(i) and i > 0 then
              obj_data := json_object_t();
              obj_data.put('flgbreak','Y');
              obj_data.put('coderror','200');
--              begin
--                select decode (global_v_lang,'101',namcente,
--                                             '102',namcentt,
--                                             '103',namcent3,
--                                             '104',namcent4,
--                                             '105',namcent5)
--                  into v_namcent
--                  from tsetcomp
--                 where numseq = i;
--              exception when no_data_found then
--                v_namcent := null;
--              end;
              v_namcent   := replace(get_comp_label(v_codcomp1,i,global_v_lang),'*',null);
              obj_data.put('codempid',v_namcent);
              obj_data.put('codcomp',hcm_util.get_codcomp_level(v_codcomp1,i));
              obj_data.put('desc_codempid',get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp1,i),global_v_lang));
              obj_rows.put(to_char(v_count),obj_data);
              v_count := v_count + 1;
            end if;
          end loop;
        end if;
        -- add current
        obj_rows.put(to_char(v_count),obj_data_old);
        countSummary(obj_data_old);
        v_count   := v_count + 1;
        obj_token := obj_data_old;
      end if;
    end loop;

    if p_breaklevelAll then
      if obj_token is not null then -- if have more than 0 add sum
        obj_data := json_object_t();
        obj_data.put('flgbreak','Y');
        obj_data.put('coderror','200');
        obj_data.put('desc_codempid'    ,v_label || v_label2);
        obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(p_qtyminCodempid));
        obj_data.put('amount'       ,to_char(nvl(p_amtpayCodempid,0),'fm999999999990.00'));
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
        p_qtyminCodempid := 0;
        p_amtpayCodempid := 0;

        v_codcomp2 := hcm_util.get_string_t(obj_token   ,'codcomp'); -- last
        v_level := getLevelCodcomp(v_codcomp2);
        for i in 0..v_level-1 loop
          if v_level-i = getTrueLevel(v_level-i) then
            obj_data := json_object_t();
            obj_data.put('flgbreak','Y');
            obj_data.put('coderror','200');
--            begin
--              select decode (global_v_lang,'101',namcente,
--                                           '102',namcentt,
--                                           '103',namcent3,
--                                           '104',namcent4,
--                                           '105',namcent5)
--                into v_namcent
--                from tsetcomp
--               where numseq = v_level-i;
--            exception when no_data_found then
--              v_namcent := null;
--            end;
            v_namcent   := replace(get_comp_label(v_codcomp2,v_level-i,global_v_lang),'*',null);
            obj_data.put('desc_codempid'     ,v_label || v_namcent);
            obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(getQtyminSum(v_level-i)));
            obj_data.put('amount'       ,to_char(nvl(getAmtpaySum(v_level-i),0),'fm999999999990.00'));
            obj_rows.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
--            resetSummary(i);
          end if;
        end loop;
      end if;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin

    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_numperiod         := hcm_util.get_string_t(json_obj, 'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_report            := hcm_util.get_string_t(json_obj, 'p_report');


    json_param_break    := hcm_util.get_json_t(json_obj, 'param_break');
    json_param_json     := hcm_util.get_json_t(json_obj, 'param_json');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codpay          := hcm_util.get_string_t(p_index_rows, 'codpay');
        p_codalw          := hcm_util.get_string_t(p_index_rows, 'codalw');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        if p_report = '1' then
          if p_codalw = 'OT' then
             p_codapp := 'HRAL73X1';
             gen_detail_ot(json_output);
          else
            p_codapp := 'HRAL73X3';
            gen_detail(json_output);
          end if;
        else
          p_codapp := 'HRAL73X2';
          gen_detail_summary(json_str_output);
        end if;

      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

   procedure insert_ttemprpt_head(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_year_             varchar2(100 char);
    v_month             varchar2(100 char);
    v_period            number := 0;
    v_report            varchar2(100 char);
    v_numperiod         varchar2(100 char);
    v_date              date;
    v_dtework           varchar2(100 char) := '';

    v_codpay           	varchar2(1000 char) := '';
    v_codalw           	varchar2(1000 char) := '';
    v_codcomp          	varchar2(1000 char) := '';
    v_desc_codcomp    	varchar2(1000 char) := '';
    v_typpayroll       	varchar2(1000 char) := '';
    v_desc_typpayroll   varchar2(1000 char) := '';
    v_desc_codpay    	  varchar2(1000 char) := '';
    v_desc_codalw    	  varchar2(1000 char) := '';

  begin
    v_codpay       		  := nvl(hcm_util.get_string_t(obj_data, 'codpay'), p_codpay);
    v_codalw       		  := nvl(hcm_util.get_string_t(obj_data, 'codcalen'), p_codalw);
    v_codcomp       	  := nvl(hcm_util.get_string_t(obj_data, 'codcomp'), '');
    v_desc_codcomp      := nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp_'), '');
    v_typpayroll        := nvl(hcm_util.get_string_t(obj_data, 'typpayroll'), '');
    v_desc_typpayroll   := get_tcodec_name('tcodtypy', hcm_util.get_string_t(obj_data, 'typpayroll'), global_v_lang);
    v_desc_codpay       := get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codpay'), global_v_lang);
    v_desc_codalw       := get_tlistval_name('CODALW',hcm_util.get_string_t(obj_data, 'codalw'),global_v_lang);
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;

    v_year      := hcm_appsettings.get_additional_year;
    v_period    := nvl(hcm_util.get_string_t(obj_data, 'numperiod'), ' ');
    v_month     := nvl(get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_data, 'dtemthpay'),global_v_lang), ' ');
    v_year_     := nvl((to_char(to_number(hcm_util.get_string_t(obj_data, 'dteyrepay'))+ v_year)), ' ');
    v_numperiod := v_period || ' ' || v_month || ' ' || v_year_ ;

    v_date      := to_date(hcm_util.get_string_t(obj_data, 'dtework'), 'DD/MM/YYYY');
    v_dtework   := to_char(v_date, 'DD/MM/') || (to_number(to_char(v_date, 'YYYY')) + v_year);

    if p_report = '1' then
      v_report := get_label_name('HRAL73X', global_v_lang, '20');
    elsif p_report = '2' then
      v_report := get_label_name('HRAL73X', global_v_lang, '30');
    end if;


    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4,item5, item6, item7, item8, item9, item10
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             'header',
             v_codpay,
             v_codalw,
             v_codcomp,
             v_desc_codcomp,
             v_typpayroll || ' - ' || v_desc_typpayroll,
             v_codpay || ' - ' || v_desc_codpay,
             v_report,
             v_numperiod,
             v_desc_codalw
      );
    exception when others then
    null;
    end;
  end insert_ttemprpt_head;

  procedure insert_ttemprpt_ot(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_date              date;
    v_dtework           varchar2(100 char) := '';

    v_codpay           	varchar2(1000 char) := '';
    v_codalw           	varchar2(1000 char) := '';
    v_codempid         	varchar2(1000 char) := '';
    v_desc_codempid    	varchar2(1000 char) := '';
    v_typot       		  varchar2(1000 char) := '';
    v_codcomp_charge    varchar2(1000 char) := '';
    v_coscent   		    varchar2(1000 char) := '';
    v_time    			    varchar2(1000 char) := '';
    v_qtyhrs    		    varchar2(1000 char) := '';
    v_rteotpay    		  varchar2(1000 char) := '';
    v_amtday    		    varchar2(1000 char) := '';
    v_amtothr    		    varchar2(1000 char) := '';
    v_amtpay    		    varchar2(1000 char) := '';

  begin
    v_codpay       		:= nvl(hcm_util.get_string_t(obj_data, 'codpay'), p_codpay);
    v_codalw       		:= nvl(hcm_util.get_string_t(obj_data, 'codalw'), p_codalw);
    v_codempid       	:= nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_desc_codempid   := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), '');
    v_typot        		:= nvl(hcm_util.get_string_t(obj_data, 'typot'), '');
    v_codcomp_charge  := nvl(hcm_util.get_string_t(obj_data, 'codcomp_charge'), '');
    v_coscent       	:= nvl(hcm_util.get_string_t(obj_data, 'coscent'), '');
    v_time       		  := nvl(hcm_util.get_string_t(obj_data, 'time'), '');
    v_qtyhrs       		:= nvl(hcm_util.get_string_t(obj_data, 'qtyhrs'), '');
    v_rteotpay       	:= nvl(hcm_util.get_string_t(obj_data, 'rteotpay'), '');
--    v_amtday       		:= nvl(hcm_util.get_string_t(obj_data, 'amtday'), '');
--    v_amtothr       	:= nvl(hcm_util.get_string_t(obj_data, 'amtothr'), '');
    v_amtday       	:= nvl(to_char(hcm_util.get_string_t(obj_data, 'amtday'), 'fm999,999,990.00'), ' ');
    v_amtothr       	:= nvl(to_char(hcm_util.get_string_t(obj_data, 'amtothr'), 'fm999,999,990.00'), ' ');
--    v_amtpay       		:= nvl(to_char(hcm_util.get_string_t(obj_data, 'amtpay'), 'fm999,999,990.00'), ' ');
    v_amtpay := hcm_util.get_string_t(obj_data, 'amtpay');
    if v_amtpay is null then
        v_amtpay := ' ';
      else
        v_amtpay := replace(v_amtpay,',','');
        v_amtpay       	:= nvl(to_char(v_amtpay, 'fm999,999,990.00'), ' ');
      end if;
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;
    v_year      := hcm_appsettings.get_additional_year;
    v_date      := to_date(hcm_util.get_string_t(obj_data, 'dtework'), 'DD/MM/YYYY');
    v_dtework   := to_char(v_date, 'DD/MM/') || (to_number(to_char(v_date, 'YYYY')) + v_year);

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4,item5, item6, item7, item8, item9, item10, item11, item12, item13,
             item14, item15
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             'ot',
             v_codpay,
             v_codalw,
             v_codempid,
             v_desc_codempid,
             nvl(v_dtework, ' '),
             v_typot,
             v_codcomp_charge,
             v_coscent,
             v_time,
             v_qtyhrs,
             v_rteotpay,
             v_amtday,
             v_amtothr,
             v_amtpay
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_ot;

  procedure insert_ttemprpt_summary(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_codpay           	varchar2(1000 char) := '';
    v_codalw           	varchar2(1000 char) := '';
    v_codempid         	varchar2(1000 char) := '';
    v_desc_codempid    	varchar2(1000 char) := '';
    v_desc_codpos       varchar2(1000 char) := '';
    v_qtyhrs    		    varchar2(1000 char) := '';
    v_amtothr   		    varchar2(1000 char) := '';
    v_amtpay    		    varchar2(1000 char) := '';

  begin
    v_codpay       		:= nvl(hcm_util.get_string_t(obj_data, 'codpay'), p_codpay);
    v_codalw       		:= nvl(hcm_util.get_string_t(obj_data, 'codalw'), p_codalw);
    v_codempid       	:= nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_desc_codempid   := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), '');
    v_desc_codpos     := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), '');
    v_qtyhrs       		:= nvl(hcm_util.get_string_t(obj_data, 'qtyhrs'), '');
    v_amtothr       	:= nvl(to_char(hcm_util.get_string_t(obj_data, 'amtothr'), 'fm999,999,990.00'), ' ');
    v_amtpay := hcm_util.get_string_t(obj_data, 'amtpay');
    if v_amtpay is null then
      v_amtpay := ' ';
    else
      v_amtpay := replace(v_amtpay,',','');
      v_amtpay       	:= nvl(to_char(v_amtpay, 'fm999,999,990.00'), ' ');
    end if;
--    v_amtpay       	:= nvl(to_char(hcm_util.get_string_t(obj_data, 'amtpay'), 'fm999,999,990.00'), ' ');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             'summary',
             v_codpay,
             v_codalw,
             v_codempid,
             v_desc_codempid,
             v_desc_codpos,
             v_qtyhrs,
             v_amtothr,
             v_amtpay
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_summary;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_date              date;
    v_dtework           varchar2(100 char) := '';

    v_codpay           	varchar2(1000 char) := '';
    v_codalw           	varchar2(1000 char) := '';
    v_codempid         	varchar2(1000 char) := '';
    v_desc_codempid    	varchar2(1000 char) := '';
    v_codshift       	  varchar2(1000 char) := '';
    v_codcomp_charge   	varchar2(1000 char) := '';
    v_coscent   		    varchar2(1000 char) := '';
    v_time    			    varchar2(1000 char) := '';
    v_qtyhrs    		    varchar2(1000 char) := '';
    v_amtday    		    varchar2(1000 char) := '';
    v_amtothr    		    varchar2(1000 char) := '';
    v_amtpay    		    varchar2(1000 char) := '';
    v_amtpay_t    		  varchar2(1000 char) := '';

  begin
    v_codpay       		:= nvl(hcm_util.get_string_t(obj_data, 'codpay'), p_codpay);
    v_codalw       		:= nvl(hcm_util.get_string_t(obj_data, 'codalw'), p_codalw);
    v_codempid       	:= nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_desc_codempid   := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), '');
    v_codshift       	:= nvl(hcm_util.get_string_t(obj_data, 'codshift'), '');
    v_codcomp_charge  := nvl(hcm_util.get_string_t(obj_data, 'codcomp_charge'), '');
    v_coscent       	:= nvl(hcm_util.get_string_t(obj_data, 'coscent'), '');
    v_time       		  := nvl(hcm_util.get_string_t(obj_data, 'time'), '');
    v_qtyhrs       		:= nvl(hcm_util.get_string_t(obj_data, 'qtyhrs'), '');
    v_amtday       		:= nvl(to_char(hcm_util.get_string_t(obj_data, 'amtday'), 'fm999,999,990.00'), ' ');
    v_amtothr       		:= nvl(to_char(hcm_util.get_string_t(obj_data, 'amtothr'), 'fm999,999,990.00'), ' ');

--    if hcm_util.get_string_t(obj_data,'amtpay') is not null and hcm_util.get_json_t(obj_data,'amtpay').get_size > 0 then
--      v_amtpay  := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtpay'), 'fm999,999,990.00'), ' ');
--    end if;
    v_amtpay := hcm_util.get_string_t(obj_data, 'amtpay');
    if v_amtpay is null then
      v_amtpay := ' ';
    else
      v_amtpay := replace(v_amtpay,',','');
      v_amtpay       	:= nvl(to_char(v_amtpay, 'fm999,999,990.00'), ' ');
    end if;


    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;

    v_year      := hcm_appsettings.get_additional_year;
    v_date      := to_date(hcm_util.get_string_t(obj_data, 'dtework'), 'DD/MM/YYYY');
    v_dtework   := to_char(v_date, 'DD/MM/') || (to_number(to_char(v_date, 'YYYY')) + v_year);

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4, item5 , item6, item7, item8, item9, item10, item11, item12,
             item13, item14
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             'noOT',
             v_codpay,
             v_codalw,
             v_codempid,
             v_desc_codempid,
             nvl(v_dtework, ' '),
             v_codshift,
             v_codcomp_charge,
             v_coscent,
             v_time,
             v_qtyhrs,
             v_amtday,
             v_amtothr,
             v_amtpay
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt;

end HRAL73X;

/
