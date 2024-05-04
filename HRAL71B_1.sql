--------------------------------------------------------
--  DDL for Package Body HRAL71B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL71B" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    if p_codcomp is not null then
        p_codcomp := replace(p_codcomp,'-');
    end if;
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_codpay            := hcm_util.get_string_t(json_obj,'p_codpay');
    p_flgretprd         := hcm_util.get_string_t(json_obj,'p_flgretprd');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure check_index is
    v_secur       boolean := false;
  begin
    if p_codempid is not null then
      p_codcomp := null;
      p_typpayroll := null;
    end if;
    if p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    end if;
    if p_codcomp is not null then
      if p_typpayroll is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
        return;
      end if;
    end if;
    if nvl(p_numperiod,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if nvl(p_dtemthpay,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtemthpay');
      return;
    end if;
    if nvl(p_dteyrepay,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
      return;
    end if;

    if p_codempid is not null then
      begin
        select codcomp,typpayroll
          into p_codcomp,p_typpayroll
          from temploy1
         where codempid = p_codempid;

        v_secur := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_secur then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codempid');
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
        if param_msg_error is not null then
          return;
        end if;
        v_codcomp := p_codcomp;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
        v_typpayroll := p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'typpayroll');
        return;
      end;
      v_typpayroll := p_typpayroll;
    end if;

    begin
      select dteeffec into v_dteeffec
        from tcontral
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontral
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'));
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcomp');
      return;
    end;
  end check_index;
  --
  function gen_ret_prd(p_flgretprd varchar2, p_dtestrt date, p_qtyretpriod number) return date is
    v_num			number := 0;
    v_dtestrt		date;
    cursor c_priodal is
      select dtestrt
        from tpriodal
       where codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
         and typpayroll = v_typpayroll
         and codpay 		= v_codpay
         and trim(dteyrepay)||lpad(trim(dtemthpay),2,'0')||lpad(trim(numperiod),3,'0') <
             trim(p_dteyrepay)||lpad(trim(p_dtemthpay),2,'0')||lpad(trim(p_numperiod),3,'0')
            -- trim(p_dteyrepay-:global.v_zyear)||lpad(trim(p_dtemthpay),2,'0')||lpad(trim(p_numperiod),3,'0')
    order by dteyrepay desc,dtemthpay desc,numperiod desc;
  begin
    if p_flgretprd = 'N' or nvl(p_qtyretpriod,0) = 0 then
      return(p_dtestrt);
    end if;

    for i in c_priodal loop
      v_dtestrt := i.dtestrt;
      v_num	:= v_num + 1;
      if p_qtyretpriod = v_num then
        return(v_dtestrt);
      end if;
    end loop;
    return(nvl(v_dtestrt,p_dtestrt));
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row		        number := 0;
    v_dtestrt       date;
    v_flgretprd     varchar2(1 char) := 'N';
    v_qtyretpriod   number;

    cursor c1 is
      select codpay,dtestrt,dteend,flgcal,dteupd,coduser--,qtyretpriod
        from tpriodal
	     where codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
         and typpayroll = v_typpayroll
         and dteyrepay  = p_dteyrepay -- - :global.v_zyear
         and dtemthpay  = p_dtemthpay
         and numperiod  = p_numperiod
	  order by codpay;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      obj_row := json_object_t();
      for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
          begin
            select qtyretpriod
              into v_qtyretpriod
              from tcontraw
             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
               and dteeffec = (select max(dteeffec)
                                 from tcontraw
                                where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                  and dteeffec <= sysdate
                                  and codpay = i.codpay)
               and codpay = i.codpay;
          exception when no_data_found then
            v_qtyretpriod := 0;
          end;
        v_codpay := i.codpay;
        if nvl(v_qtyretpriod,0) > 0 then
          v_flgretprd     := 'Y';
          v_dtestrt       := gen_ret_prd(v_flgretprd,i.dtestrt,v_qtyretpriod);
        else
          v_flgretprd     := 'N';
          v_dtestrt       := i.dtestrt;
          v_qtyretpriod   := v_qtyretpriod;
        end if;
        obj_data.put('coderror','200');
        obj_data.put('codpay',i.codpay);
        obj_data.put('despay',i.codpay||' - '||get_tinexinf_name(i.codpay,global_v_lang));
        obj_data.put('dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('flgretprd',v_flgretprd);
        obj_data.put('qtyretpriod',v_qtyretpriod);
        obj_data.put('numrec','');
        obj_data.put('remark','');
        obj_data.put('dtestrtprd',to_char(i.dtestrt,'dd/mm/yyyy'));

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
      json_str_output := obj_row.to_clob;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure get_reperiod(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    v_dtestrt       date;
    v_strt          date;
    v_end           date;
    v_flgretprd     varchar2(1 char) := 'N';
    v_qtyretpriod   number;

  begin
    initial_value(json_str_input);
    check_index;

    if param_msg_error is null then
      begin
        select dtestrt,dteend
          into v_strt,v_end
          from tpriodal
         where codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
           and typpayroll = v_typpayroll
           and dteyrepay  = p_dteyrepay
           and dtemthpay  = p_dtemthpay
           and numperiod  = p_numperiod
           and codpay     = p_codpay;
      exception when no_data_found then
        v_strt := null;
        v_end  := null;
      end;

      begin
        select qtyretpriod
          into v_qtyretpriod
          from tcontraw
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontraw
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteeffec <= sysdate
                              and codpay = p_codpay)
           and codpay = p_codpay
           and rownum = 1;
      exception when no_data_found then
        v_qtyretpriod := 0;
      end;

      v_codpay := p_codpay;
      if nvl(v_qtyretpriod,0) > 0 and p_flgretprd = 'Y' then
        v_flgretprd     := 'Y';
        v_dtestrt       := gen_ret_prd(v_flgretprd,v_strt,v_qtyretpriod);
      else
        v_flgretprd     := 'N';
        v_dtestrt       := v_strt;
        v_qtyretpriod   := v_qtyretpriod;
      end if;

      obj_row := json_object_t();
      obj_row.put('coderror','200');
      obj_row.put('codpay',p_codpay);
      obj_row.put('despay',p_codpay||' - '||get_tinexinf_name(p_codpay,global_v_lang));
      obj_row.put('dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
      obj_row.put('dteend',to_char(v_end,'dd/mm/yyyy'));
      obj_row.put('flgretprd',v_flgretprd);
      obj_row.put('qtyretpriod',v_qtyretpriod);
      obj_row.put('numrec','');
      obj_row.put('remark','');
      obj_row.put('dtestrtprd',to_char(v_strt,'dd/mm/yyyy'));

      json_str_output := obj_row.to_clob;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    null;
  end get_reperiod;
  --
  procedure initial_batchtask is
  begin
    global_v_batch_codalw(1) := 'DED_LEAVE';
    global_v_batch_codalw(2) := 'RET_LEAVE';
    global_v_batch_codalw(3) := 'DED_LEAVEM';
    global_v_batch_codalw(4) := 'RET_LEAVEM';
    global_v_batch_codalw(5) := 'DED_LATE';
    global_v_batch_codalw(6) := 'RET_LATE';
    global_v_batch_codalw(7) := 'DED_EARLY';
    global_v_batch_codalw(8) := 'RET_EARLY';
    global_v_batch_codalw(9) := 'DED_ABSENT';
    global_v_batch_codalw(10) := 'RET_ABSENT';
    global_v_batch_codalw(11) := 'ADJ_LATE';
    global_v_batch_codalw(12) := 'ADJ_EARLY';
    global_v_batch_codalw(13) := 'ADJ_ABSENT';
    global_v_batch_codalw(14) := 'PAY_VACAT';
    global_v_batch_codalw(15) := 'WAGE';
    global_v_batch_codalw(16) := 'RET_WAGE';
    global_v_batch_codalw(17) := 'OT';
    global_v_batch_codalw(18) := 'RET_OT';
    global_v_batch_codalw(19) := 'SHIFT_WAGE';
    global_v_batch_codalw(20) := 'AWARD';
    global_v_batch_codalw(21) := 'PAY_OTHER';
    global_v_batch_codalw(22) := 'HRAL71B';
    for i in 1..global_v_batch_count loop
      global_v_batch_flgproc(i)  := 'N';
      global_v_batch_qtyproc(i)  := 0;
      global_v_batch_qtyerror(i) := 0;
    end loop;
  end;
  --
  procedure process_data(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    json_obj        json_object_t;
    data_row        clob;
    v_row		      NUMBER := 0;
    v_ok 				  boolean;
    v_codempid	  varchar2(100 char);
    v_codpay		  varchar2(100 char);
    v_check       boolean:=false;
    v_setup			  varchar2(1);
    --v_timeout     number:= get_tsetup_value('TIMEOUT') ;
    v_codot		    varchar2(4 char);
    v_codrtot		  varchar2(4 char);
    v_codotalw	  varchar2(4 char);
    v_numrec		  number;
    v_dtetime		  varchar2(30 char);
    v_error			  varchar2(1 char) := 'N';
    o_numrec      number;
    o_timcal      varchar2(30 char);
    v_dtestrt     date;
    v_dteend      date;
    v_flgretprd   varchar2(1 char);
    v_qtyretpriod number;
    v_dtework     date;
    v_remark      clob;
    v_flgcal      varchar2(1 char);
    v_dteupd      date;
    v_coduser     varchar2(1000 char);
    v_codcompy    varchar2(100 char);
    v_response    varchar2(1000);
    v_dtestrtprd  date;
    v_codpay_ori  varchar2(100 char);

    type arr is table of varchar2(30) index by binary_integer;
      v_codincom arr;
      v_codretro arr;

    cursor c_tcontal2 is
      select codlev,codrtlev,codlate,codrtlate,codear,codrtear,codabs,codrtabs,codadjlate,codadjear,codadjabs,codvacat,
             codlevm,codrtlevm,codretro
        from tcontal2
       where codcompy = v_codcompy
         and dteeffec = v_dteeffec;

    cursor c_tcontraw is
      select codaward,max(dteeffec) dteeffec
        from tcontraw
       where codcompy = v_codcompy
         and dteeffec <= trunc(sysdate)
         and codpay		= v_codpay
    group by codaward;

    cursor c_tcontals is
      select dteeffec
        from tcontals
       where codcompy = v_codcompy
         and codpay	  = v_codpay;

  begin
    initial_value(json_str_input);
    check_index;
    initial_batchtask;
    if param_msg_error is null then
        json_obj := json_object_t();
        obj_row  := json_object_t();
        v_codcompy := hcm_util.get_codcomp_level(v_codcomp, 1);
        for a in 1..10 loop
          v_codincom(a)	:= null;
          v_codretro(a)	:= null;
        end loop;
        begin
          select codincom1,codincom2,codincom3,codincom4,codincom5,codincom6,codincom7,codincom8,codincom9,codincom10,
                 codretro1,codretro2,codretro3,codretro4,codretro5,codretro6,codretro7,codretro8,codretro9,codretro10
            into v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10),
                 v_codretro(1),v_codretro(2),v_codretro(3),v_codretro(4),v_codretro(5),v_codretro(6),v_codretro(7),v_codretro(8),v_codretro(9),v_codretro(10)
            from tcontpms
           where codcompy = v_codcompy
             and dteeffec = (select max(dteeffec)
                               from tcontpms
                              where codcompy = v_codcompy
                                and dteeffec <= trunc(sysdate))
             and codcompy = v_codcompy;
        exception when no_data_found then	null;
        end;
        begin
          select codot,codrtot,codotalw	into	v_codot,v_codrtot,v_codotalw
            from tcontrot
           where codcompy = v_codcompy
             and dteeffec = (select max(dteeffec)
                               from tcontrot
                              where codcompy = v_codcompy
                                and dteeffec <= sysdate);
        exception when no_data_found then	null;
        end;
        --
        param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

        for i in 0..param_json.get_size-1 loop
          param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
          v_codpay        := hcm_util.get_string_t(param_json_row,'codpay');                   
          v_dtestrt       := to_date(trim(hcm_util.get_string_t(param_json_row,'dtestrt')),'dd/mm/yyyy');
          v_dteend        := to_date(trim(hcm_util.get_string_t(param_json_row,'dteend')),'dd/mm/yyyy');
          v_flgretprd     := hcm_util.get_string_t(param_json_row,'flgretprd');
          v_qtyretpriod   := to_number(hcm_util.get_string_t(param_json_row,'qtyretpriod'));
          v_dtestrtprd    := to_date(trim(hcm_util.get_string_t(param_json_row,'dtestrtprd')),'dd/mm/yyyy');

          v_numrec := 0;
          v_dtetime	:= '_'||lpad(v_codpay,2,'0')||'_'||to_char(sysdate,'yymmddhh24miss');
          for r1 in c_tcontal2 loop
            if r1.codlev = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(1),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ded_leave;
              hral71b_batch.start_process('DED_LEAVE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(1)  := 'Y';
              global_v_batch_qtyproc(1)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(1) := 0;
            end if;
/*            if r1.codrtlev = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(2),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ret_leave;
              hral71b_batch.start_process('RET_LEAVE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(2)  := 'Y';
              global_v_batch_qtyproc(2)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(2) := 0;
            end if;*/
            if r1.codlevm = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(3),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ded_leavep;
              hral71b_batch.start_process('DED_LEAVEM'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(3)  := 'Y';
              global_v_batch_qtyproc(3)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(3) := 0;
            end if;
/*            if r1.codrtlevm = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(4),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ret_leavep;
              hral71b_batch.start_process('RET_LEAVEM'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(4)  := 'Y';
              global_v_batch_qtyproc(4)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(4) := 0;
            end if;*/

            if r1.codlate = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(5),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ded_late;
              hral71b_batch.start_process('DED_LATE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(5)  := 'Y';
              global_v_batch_qtyproc(5)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(5) := 0;
            end if;
/*            if r1.codrtlate = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(6),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ret_late;
              hral71b_batch.start_process('RET_LATE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(6)  := 'Y';
              global_v_batch_qtyproc(6)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(6) := 0;
            end if;*/
            if r1.codear = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(7),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ded_ear;
              hral71b_batch.start_process('DED_EARLY'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(7)  := 'Y';
              global_v_batch_qtyproc(7)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(7) := 0;
            end if;
/*            if r1.codrtear = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(8),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ret_ear;
              hral71b_batch.start_process('RET_EARLY'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(8)  := 'Y';
              global_v_batch_qtyproc(8)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(8) := 0;
            end if;*/
            if r1.codabs = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(9),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ded_abs;
              hral71b_batch.start_process('DED_ABSENT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(9)  := 'Y';
              global_v_batch_qtyproc(9)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(9) := 0;
            end if;
/*            if r1.codrtabs = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(10),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_ret_abs;
              hral71b_batch.start_process('RET_ABSENT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(10)  := 'Y';
              global_v_batch_qtyproc(10)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(10) := 0;
            end if;*/
            if r1.codadjlate = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(11),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_adj_late;
              hral71b_batch.start_process('ADJ_LATE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(11)  := 'Y';
              global_v_batch_qtyproc(11)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(11) := 0;
            end if;
            if r1.codadjear = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(12),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_adj_ear;
              hral71b_batch.start_process('ADJ_EARLY'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(12)  := 'Y';
              global_v_batch_qtyproc(12)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(12) := 0;
            end if;
            if r1.codadjabs = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(13),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_adj_abs;
              hral71b_batch.start_process('ADJ_ABSENT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(13)  := 'Y';
              global_v_batch_qtyproc(13)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(13) := 0;
            end if;
            if r1.codvacat = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(14),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

              --cal_pay_vacat;
              hral71b_batch.start_process('PAY_VACAT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
              v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

              -- set complete batch process
              global_v_batch_flgproc(14)  := 'Y';
              global_v_batch_qtyproc(14)  := nvl(o_numrec,0);
              global_v_batch_qtyerror(14) := 0;
            end if;
--<< user22 03/07/2021 : cal Retro
            if r1.codretro = v_codpay then
              v_codpay_ori  := v_codpay;
              for a in 1..10 loop
                v_codpay := v_codretro(a);
                if v_codpay is not null then
                    -- start batch process
                    hcm_batchtask.start_batch_process(
                      p_codapp        => global_v_batch_codapp,
                      p_coduser       => global_v_coduser,
                      p_codalw        => global_v_batch_codalw(16),
                      p_param_search  => json_str_input,
                      p_dtestrt       => global_v_batch_dtestrt
                    );

                  --cal_ret_wage;
                  hral71b_batch.start_process('RET_WAGE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                          v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                          v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                          global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
                  v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

                  -- set complete batch process
                  global_v_batch_flgproc(16)  := 'Y';
                  global_v_batch_qtyproc(16)  := nvl(o_numrec,0);
                  global_v_batch_qtyerror(16) := 0;
                end if;
              end loop;
              --
              v_codpay := v_codrtot;
              if v_codpay is not null then
                  -- start batch process
                  hcm_batchtask.start_batch_process(
                    p_codapp        => global_v_batch_codapp,
                    p_coduser       => global_v_coduser,
                    p_codalw        => global_v_batch_codalw(18),
                    p_param_search  => json_str_input,
                    p_dtestrt       => global_v_batch_dtestrt
                  );

                --cal_ret_ot;
                hral71b_batch.start_process('RET_OT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                        v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                        v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                        global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
                v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

                -- set complete batch process
                global_v_batch_flgproc(18)  := 'Y';
                global_v_batch_qtyproc(18)  := nvl(o_numrec,0);
                global_v_batch_qtyerror(18) := 0;
              end if;
              --
              v_codpay := r1.codrtlev;
              if v_codpay is not null then
                -- start batch process
                hcm_batchtask.start_batch_process(
                  p_codapp        => global_v_batch_codapp,
                  p_coduser       => global_v_coduser,
                  p_codalw        => global_v_batch_codalw(2),
                  p_param_search  => json_str_input,
                  p_dtestrt       => global_v_batch_dtestrt
                );

                --cal_ret_leave;
                hral71b_batch.start_process('RET_LEAVE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                      v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                      v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                      global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
                v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

                -- set complete batch process
                global_v_batch_flgproc(2)  := 'Y';
                global_v_batch_qtyproc(2)  := nvl(o_numrec,0);
                global_v_batch_qtyerror(2) := 0;
              end if;
              --
              v_codpay := r1.codrtlevm;
              if v_codpay is not null then
                -- start batch process
                hcm_batchtask.start_batch_process(
                  p_codapp        => global_v_batch_codapp,
                  p_coduser       => global_v_coduser,
                  p_codalw        => global_v_batch_codalw(4),
                  p_param_search  => json_str_input,
                  p_dtestrt       => global_v_batch_dtestrt
                );

                --cal_ret_leavep;
                hral71b_batch.start_process('RET_LEAVEM'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                      v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                      v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                      global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
                v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

                -- set complete batch process
                global_v_batch_flgproc(4)  := 'Y';
                global_v_batch_qtyproc(4)  := nvl(o_numrec,0);
                global_v_batch_qtyerror(4) := 0;
              end if;
              --
              v_codpay := r1.codrtlate;
              if v_codpay is not null then
                -- start batch process
                hcm_batchtask.start_batch_process(
                  p_codapp        => global_v_batch_codapp,
                  p_coduser       => global_v_coduser,
                  p_codalw        => global_v_batch_codalw(6),
                  p_param_search  => json_str_input,
                  p_dtestrt       => global_v_batch_dtestrt
                );

                --cal_ret_late;
                hral71b_batch.start_process('RET_LATE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                      v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                      v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                      global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
                  v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

                -- set complete batch process
                global_v_batch_flgproc(6)  := 'Y';
                global_v_batch_qtyproc(6)  := nvl(o_numrec,0);
                global_v_batch_qtyerror(6) := 0;
              end if;
              --
              v_codpay := r1.codrtear;
              if v_codpay is not null then
                -- start batch process
                hcm_batchtask.start_batch_process(
                  p_codapp        => global_v_batch_codapp,
                  p_coduser       => global_v_coduser,
                  p_codalw        => global_v_batch_codalw(8),
                  p_param_search  => json_str_input,
                  p_dtestrt       => global_v_batch_dtestrt
                );

                --cal_ret_ear;
                hral71b_batch.start_process('RET_EARLY'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                      v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                      v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                      global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
                v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

                -- set complete batch process
                global_v_batch_flgproc(8)  := 'Y';
                global_v_batch_qtyproc(8)  := nvl(o_numrec,0);
                global_v_batch_qtyerror(8) := 0;
              end if;
              --
              v_codpay := r1.codrtabs;
              if v_codpay is not null then
                -- start batch process
                hcm_batchtask.start_batch_process(
                  p_codapp        => global_v_batch_codapp,
                  p_coduser       => global_v_coduser,
                  p_codalw        => global_v_batch_codalw(10),
                  p_param_search  => json_str_input,
                  p_dtestrt       => global_v_batch_dtestrt
                );

                --cal_ret_abs;
                hral71b_batch.start_process('RET_ABSENT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                      v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                      v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                      global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
                v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

                -- set complete batch process
                global_v_batch_flgproc(10)  := 'Y';
                global_v_batch_qtyproc(10)  := nvl(o_numrec,0);
                global_v_batch_qtyerror(10) := 0;
              end if;
              --
              v_codpay  := v_codpay_ori;
            end if; -- v_codrtot = v_codpay
-->> user22 03/07/2021 : cal Retro
          end loop; -- for c_tcontal2
          -------------------------------------------------------------------------------------------------------
          if v_codpay in (nvl(v_codincom(1),'!@'),nvl(v_codincom(2),'!@'),nvl(v_codincom(3),'!@'),nvl(v_codincom(4),'!@'),nvl(v_codincom(5),'!@'),nvl(v_codincom(6),'!@'),nvl(v_codincom(7),'!@'),nvl(v_codincom(8),'!@'),nvl(v_codincom(9),'!@'),nvl(v_codincom(10),'!@')) then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(15),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

            --cal_pay_wage;
            hral71b_batch.start_process('WAGE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
            v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

            -- set complete batch process
            global_v_batch_flgproc(15)  := 'Y';
            global_v_batch_qtyproc(15)  := nvl(o_numrec,0);
            global_v_batch_qtyerror(15) := 0;
          end if;
          -------------------------------------------------------------------------------------------------------
/*          if v_codpay in (nvl(v_codretro(1),'!@'),nvl(v_codretro(2),'!@'),nvl(v_codretro(3),'!@'),nvl(v_codretro(4),'!@'),nvl(v_codretro(5),'!@'),nvl(v_codretro(6),'!@'),nvl(v_codretro(7),'!@'),nvl(v_codretro(8),'!@'),nvl(v_codretro(9),'!@'),nvl(v_codretro(10),'!@')) then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(16),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

            --cal_ret_wage;
            hral71b_batch.start_process('RET_WAGE'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
            v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

            -- set complete batch process
            global_v_batch_flgproc(16)  := 'Y';
            global_v_batch_qtyproc(16)  := nvl(o_numrec,0);
            global_v_batch_qtyerror(16) := 0;
          end if;*/
          -------------------------------------------------------------------------------------------------------          
          if v_codot = v_codpay then

              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(17),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

            --cal_pay_ot(v_codotalw);
            hral71b_batch.start_process('OT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
            v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

            -- set complete batch process
            global_v_batch_flgproc(17)  := 'Y';
            global_v_batch_qtyproc(17)  := nvl(o_numrec,0);
            global_v_batch_qtyerror(17) := 0;
          end if;

/*          if v_codrtot = v_codpay then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(18),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

            --cal_ret_ot;
            hral71b_batch.start_process('RET_OT'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
            v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

            -- set complete batch process
            global_v_batch_flgproc(18)  := 'Y';
            global_v_batch_qtyproc(18)  := nvl(o_numrec,0);
            global_v_batch_qtyerror(18) := 0;
          end if;*/
          -------------------------------------------------------------------------------------------------------
          v_setup := 'N';
          for r1 in c_tcontraw loop
            v_setup := 'Y';
            exit;
          end loop;
          if v_setup = 'Y' then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(20),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

            --cal_pay_award(v_codpay);
            hral71b_batch.start_process('AWARD'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
            v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

            -- set complete batch process
            global_v_batch_flgproc(20)  := 'Y';
            global_v_batch_qtyproc(20)  := nvl(o_numrec,0);
            global_v_batch_qtyerror(20) := 0;
          end if;
          -------------------------------------------------------------------------------------------------------
          v_setup := 'N';
          for r1 in c_tcontals loop
            v_setup := 'Y';
            exit;
          end loop;

          if v_setup = 'Y' then
              -- start batch process
              hcm_batchtask.start_batch_process(
                p_codapp        => global_v_batch_codapp,
                p_coduser       => global_v_coduser,
                p_codalw        => global_v_batch_codalw(21),
                p_param_search  => json_str_input,
                p_dtestrt       => global_v_batch_dtestrt
              );

            --cal_pay_other(v_codpay);
            hral71b_batch.start_process('PAY_OTHER'||v_dtetime,p_codempid,v_codcomp,p_typpayroll,v_typpayroll,
                                    v_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
                                    v_dtestrt,v_dteend,v_flgretprd,v_qtyretpriod,v_dtestrtprd,
                                    global_v_coduser,global_v_codcurr,v_codempid,v_dtework,v_remark,o_numrec,o_timcal);
            v_numrec := nvl(v_numrec,0) + nvl(o_numrec,0);

            -- set complete batch process
            global_v_batch_flgproc(21)  := 'Y';
            global_v_batch_qtyproc(21)  := nvl(o_numrec,0);
            global_v_batch_qtyerror(21) := 0;
          end if;
          -------------------------------------------------------------------------------------------------------
          if v_numrec > 0 then
            v_flgcal  := 'Y';
            v_dteupd  := trunc(sysdate);
            v_coduser := global_v_coduser;
          end if;

          if(not v_check)then
            param_msg_error := get_error_msg_php('HR2030',global_v_lang);
          END IF;
          --commit;

          if v_remark is not null then
            v_error := 'Y';
          end if;

          if v_error = 'Y' then
            param_msg_error := get_error_msg_php('HR2716',global_v_lang);
          else
            param_msg_error := get_error_msg_php('HR2715',global_v_lang);
          end if;

          ----------------------------------------------------------------------
          --set_custom_property('PJC.TIMEOUT',1,'START_TIMER',''||v_timeout||'');
          ----------------------------------------------------------------------
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('codpay', v_codpay);
          obj_data.put('numrec', to_char(nvl(v_numrec,0),'fm999,999,990'));
          obj_data.put('remark', v_remark);
          obj_data.put('timcal', o_timcal);
          obj_row.put(to_char(v_row-1),obj_data);

        end loop;
        data_row := obj_row.to_clob;

        v_response := get_response_message(null,param_msg_error,global_v_lang);
    --    json_obj.put('coderror',hcm_util.get_string(json(v_response),'coderror'));
        json_obj.put('coderror', 200);
        json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
        json_obj.put('param_json',data_row);

        json_str_output := json_obj.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    -- set complete batch process
    for i in 1..global_v_batch_count loop
        hcm_batchtask.finish_batch_process(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw(i),
          p_dtestrt  => global_v_batch_dtestrt,
          p_flgproc  => global_v_batch_flgproc(i),
          p_qtyproc  => global_v_batch_qtyproc(i),
          p_qtyerror => global_v_batch_qtyerror(i),
          p_oracode  => param_msg_error
        );
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    for i in 1..global_v_batch_count loop
        hcm_batchtask.finish_batch_process(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw(i),
          p_dtestrt  => global_v_batch_dtestrt,
          p_flgproc  => 'N',
          p_oracode => param_msg_error
        );
    end loop;
  end process_data;
end HRAL71B;

/
