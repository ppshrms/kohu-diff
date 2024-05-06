--------------------------------------------------------
--  DDL for Package Body HRAL68X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL68X" as

  function zvl(p_number number) return number is
  begin
    if nvl(p_number,0) = 0 then
        return(null);
    end if;
    return(p_number);
  end;

  function check_award(p_codempid	in varchar2,rt_tcontraw tcontraw%rowtype) return boolean is
	v_flgfound 		boolean;
	v_flgtran   	tpaysum.flgtran%type;
	v_codempid		temploy1.codempid%type;
	v_staemp			temploy1.staemp%type;
	v_codpos			temploy1.codpos%type;
	v_numlvl			temploy1.numlvl%type;
	v_typemp			temploy1.typemp%type;
	v_codcomp			temploy1.codcomp%type;
	v_typpayroll	temploy1.typpayroll%type;
	v_codempmt		temploy1.codempmt%type;
  --
  v_codjob      temploy1.codjob%type;
  v_codbrlc     temploy1.codbrlc%type;
  v_codcalen    temploy1.codcalen%type;
  v_jobgrade    temploy1.jobgrade%type;
  v_codgrpgl    temploy1.codgrpgl%type;
	v_cond				varchar2(1000);
	v_stmt				varchar2(1000);
  cursor c_tcontaw3 is
  	select numseq,syncond
    	from tcontaw3
		 where codcompy = rt_tcontraw.codcompy
	  	 and codaward = rt_tcontraw.codaward
			 and dteeffec = rt_tcontraw.dteeffec
	order by numseq;
  begin

    begin
      select codcomp,typpayroll,codempmt,codpos,typemp,numlvl,staemp,
             codjob,codbrlc,codcalen,jobgrade,codgrpgl
        into v_codcomp,v_typpayroll,v_codempmt,v_codpos,v_typemp,v_numlvl,v_staemp,
             v_codjob,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then null;
    end;
    v_flgfound := true;
    if rt_tcontraw.syncond is not null then
        v_cond := rt_tcontraw.syncond;
        v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
        v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
        v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
        v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
        v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
        v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
        v_stmt := 'select count(*) from dual where '||v_cond;
        v_flgfound := execute_stmt(v_stmt);
    end if;
    if v_flgfound then
        for r_tcontaw3 in c_tcontaw3 loop
            if r_tcontaw3.syncond is not null then
                v_cond := r_tcontaw3.syncond;
                v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'TEMPLOY1.CODJOB',''''||v_codjob||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');
                v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                v_cond := replace(v_cond,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');
                v_stmt := 'select count(*) from dual where '||v_cond;
                v_flgfound := execute_stmt(v_stmt);
            end if;

            if v_flgfound then
                return(true);
            end if;
        end loop; -- for c_tcontaw3
    end if;--if v_flgfound then
    return(false);
  end;

  procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
    v_chken             := hcm_secur.get_v_chken;

    -- index params
    p_codcomp           := replace(hcm_util.get_string(json_obj, 'p_codcomp'),'-',null);
    p_codcompy          := hcm_util.get_codcomp_level(p_codcomp,1);
    p_codaward          := hcm_util.get_string(json_obj, 'p_codaward');
    p_stmonth           := to_number(hcm_util.get_string(json_obj, 'p_stmonth'));
    p_enmonth           := to_number(hcm_util.get_string(json_obj, 'p_enmonth'));
    p_styear            := to_number(hcm_util.get_string(json_obj, 'p_styear'));
    p_enyear            := to_number(hcm_util.get_string(json_obj, 'p_enyear'));

    -- detail params
    p_codempid          := hcm_util.get_string(json_obj, 'p_codempid_query');
    p_codpay            := hcm_util.get_string(json_obj, 'p_codpay');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    flgpass 		boolean;
    v_date			date;
    v_last			date;
  	v_codempid 	varchar2(500 char);
    v_codcomp	 	varchar2(500 char);
    v_dtestr    varchar2(500 char);
    v_dteend    varchar2(500 char);
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    elsif p_codaward is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    elsif p_stmonth is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    elsif p_styear is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    elsif p_enmonth is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    elsif p_enyear is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    -- check secure 7
    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
		if param_msg_error is not null then
      return;
		end if;
    -- check codaward
    begin
      select codcodec into v_codempid
        from tcodawrd
       where codcodec = p_codaward;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodaward');
      return;
    end;
    --check dteend < dtestr
    v_dtestr := p_styear || lpad(p_stmonth,2,'0');
    v_dteend := p_enyear || lpad(p_enmonth,2,'0');
    if v_dteend < v_dtestr then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
    --check condition month not over than 12
    select add_months(to_date('01/'||lpad(p_stmonth,2,'0')||'/'||p_styear, 'dd/mm/yyyy'), 11)
      into v_last
      from dual;
    v_date	:= to_date('01/'||lpad(p_enmonth,2,'0')||'/'||p_enyear , 'dd/mm/yyyy');
    if v_last < v_date then
      param_msg_error := get_error_msg_php('HR8844', global_v_lang);
      return;
    end if;
  end;

  procedure check_detail is
  begin
    begin
      p_codcomp := hcm_util.get_temploy_field(p_codempid, 'codcomp');
      select qtyavgwk into param_qtyavgwk
       from tcontral
       where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
        and dteeffec = (select max(dteeffec)
                  from tcontral
                 where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                   and dteeffec <= sysdate)
        and rownum <= 1;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcontral');
      return;
     end;
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

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
   	v_codapp  	    varchar2(100 char) := 'HRAL68X';
    v_exist         boolean := false;
    v_exist_tpaysum boolean := false;
    v_secur         boolean := false;
    v_flgsecu       boolean;
    v_dteeffec      date;
    v_dtestr        date;
    v_dteend        date;
    v_dteeffec2     date;
    v_codcompy      varchar2(1000 char);
	  v_num           number := 0;
    v_rcnt          number := 0;
    v_rcnt2         varchar2(100 char);
    v_loop          number := 0;
    v_label1        varchar2(100 char):= get_label_name('HRAL68X1',global_v_lang,100) ;
    v_label2        varchar2(100 char):= get_label_name('HRAL68X1',global_v_lang,110) ;
	  rt_tcontraw     tcontraw%rowtype;
    type amtarray is table of number index by binary_integer;
 		a_month			    amtarray;
 		a_amtpay			  amtarray;

    cursor c_temploy1 is
      select codempid,codcomp,dteempmt
        from temploy1
       where codcomp like p_codcomp||'%'
         --and staemp <> 0
	       --and dteempmt <= v_dteend
         --and ((dteeffex is not null and dteeffex > v_dtestr)
          --or   dteeffex is null)
       and   codempid in ( select codempid
                           from tpaysum
                          where to_date(dtemthpay||'/'||dteyrepay,'mm/yyyy') between
                                to_date(p_stmonth||'/'||(p_styear - global_v_zyear),'mm/yyyy')
                            and to_date(p_enmonth||'/'||(p_enyear - global_v_zyear),'mm/yyyy')
                            and ((codalw  = 'AWARD' and codpay  = rt_tcontraw.codpay  ) or 
                                 (codalw  = 'RET_AWARD' and codpay  = rt_tcontraw.codrtawrd  ))) 

      order by codempid;

    cursor c_tpaysum (v_codempid varchar2) is
      select sum(decode(a_month(1), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay1,
             sum(decode(a_month(2), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay2,
             sum(decode(a_month(3), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay3,
             sum(decode(a_month(4), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay4,
             sum(decode(a_month(5), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay5,
             sum(decode(a_month(6), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay6,
             sum(decode(a_month(7), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay7,
             sum(decode(a_month(8), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay8,
             sum(decode(a_month(9), dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay9,
             sum(decode(a_month(10),dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay10,
             sum(decode(a_month(11),dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay11,
             sum(decode(a_month(12),dtemthpay,nvl(stddec(amtpay,codempid,v_chken),0),0)) amtpay12
       from tpaysum
      where codempid = v_codempid
        and to_date(dtemthpay||'/'||dteyrepay,'mm/yyyy') between
            to_date(p_stmonth||'/'||(p_styear - global_v_zyear),'mm/yyyy')
        and to_date(p_enmonth||'/'||(p_enyear - global_v_zyear),'mm/yyyy')
        and ((codalw  = 'AWARD' and codpay  = rt_tcontraw.codpay and v_loop = 1) or 
             (codalw  = 'RET_AWARD' and codpay  = rt_tcontraw.codrtawrd and v_loop = 2 )) ;

  begin
    obj_row    := json_object_t();
    v_rcnt     := 0;
    for j in 1..12 loop
			a_month(j)  := null;
    end loop;
    v_dteeffec := to_date(get_period_date(p_stmonth,p_styear,'S'),'dd/mm/yyyy');
    v_dteend   := to_date(get_period_date(p_enmonth,p_enyear,'S'),'dd/mm/yyyy');
    while v_dteeffec <= v_dteend  loop
        v_num      := v_num + 1;
        a_month(v_num) := to_number(to_char(v_dteeffec,'mm'));
        v_dteeffec := add_months(v_dteeffec,1);
    end loop;

    begin
      select * into rt_tcontraw
        from tcontraw
       where codcompy = p_codcompy
         and codaward = p_codaward
         and dteeffec = (select max(dteeffec)
                           from tcontraw
                          where codcompy = p_codcompy
                            and codaward = p_codaward
                            and dteeffec <= sysdate);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tcontraw');
    end;

    if param_msg_error is null then
      v_dtestr   := to_date(get_period_date(p_stmonth,p_styear,'S'),'dd/mm/yyyy');
      v_dteend   := last_day(to_date(get_period_date(p_enmonth,p_enyear,'S'),'dd/mm/yyyy'));
      for c1 in c_temploy1 loop
        v_exist := true; -- fix issue #5381
        v_flgsecu := secur_main.secur2(c1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
          v_secur := true;
          if check_award(c1.codempid,rt_tcontraw) then
            --v_rcnt       := v_rcnt+1;
            obj_data     := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', c1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(c1.codempid,global_v_lang));
            obj_data.put('dteempmt', to_char(c1.dteempmt,'dd/mm/yyyy'));
            obj_data.put('codpay', rt_tcontraw.codpay);

            for k in 1..2 loop
            v_loop := k ;
            for c2 in c_tpaysum (c1.codempid) loop
              if v_loop = 1 then
                 obj_data.put('typdiligent', v_label1 );
                 obj_data.put('icon','<i class="fa fa-info-circle"></i>'); 
                obj_data.put('codempid2', c1.codempid);
                obj_data.put('desc_codempid2', get_temploy_name(c1.codempid,global_v_lang)); 

              else
                 obj_data.put('typdiligent', v_label2 );
                 obj_data.put('icon',''); 
                obj_data.put('codempid2', '');
                obj_data.put('desc_codempid2', ''); 

              end if;
              --if c2.amtpay1 is not null and c2.amtpay2 is not null 
              --   and c2.amtpay3 is not null and c2.amtpay4 is not null 
              --   and c2.amtpay6 is not null and c2.amtpay7 is not null 
              --   and c2.amtpay7 is not null and c2.amtpay8 is not null 
              --   and c2.amtpay9 is not null and c2.amtpay10 is not null 
              --   and c2.amtpay11 is not null and c2.amtpay12 is not null    then  

                  v_exist_tpaysum := true; -- fix issue #5381
                  -- clear array
                  for i in 1..13 loop
                    a_amtpay(i) := 0;
                  end loop;
                  -- check permissions
                  if nvl(v_zupdsal, 'Y') = 'Y' then
                    a_amtpay(1)  := c2.amtpay1;      a_amtpay(2)  := c2.amtpay2;
                    a_amtpay(3)  := c2.amtpay3;      a_amtpay(4)  := c2.amtpay4;
                    a_amtpay(5)  := c2.amtpay5;      a_amtpay(6)  := c2.amtpay6;
                    a_amtpay(7)  := c2.amtpay7;      a_amtpay(8)  := c2.amtpay8;
                    a_amtpay(9)  := c2.amtpay9;      a_amtpay(10) := c2.amtpay10;
                    a_amtpay(11) := c2.amtpay11;     a_amtpay(12) := c2.amtpay12;
                    -- sum amtpay --
                    a_amtpay(13) := c2.amtpay1 + c2.amtpay2  + c2.amtpay3  + c2.amtpay4 +
                                    c2.amtpay5 + c2.amtpay6  + c2.amtpay7  + c2.amtpay8 +
                                    c2.amtpay9 + c2.amtpay10 + c2.amtpay11 + c2.amtpay12;
                  end if;
                  -- put data
                  v_rcnt       := v_rcnt+1;


                  obj_data.put('amtpay1', to_char(zvl(a_amtpay(1)),'fm9,999,999.00'));
                  obj_data.put('amtpay2', to_char(zvl(a_amtpay(2)),'fm9,999,999.00'));
                  obj_data.put('amtpay3', to_char(zvl(a_amtpay(3)),'fm9,999,999.00'));
                  obj_data.put('amtpay4', to_char(zvl(a_amtpay(4)),'fm9,999,999.00'));
                  obj_data.put('amtpay5', to_char(zvl(a_amtpay(5)),'fm9,999,999.00'));
                  obj_data.put('amtpay6', to_char(zvl(a_amtpay(6)),'fm9,999,999.00'));
                  obj_data.put('amtpay7', to_char(zvl(a_amtpay(7)),'fm9,999,999.00'));
                  obj_data.put('amtpay8', to_char(zvl(a_amtpay(8)),'fm9,999,999.00'));
                  obj_data.put('amtpay9', to_char(zvl(a_amtpay(9)),'fm9,999,999.00'));
                  obj_data.put('amtpay10', to_char(zvl(a_amtpay(10)),'fm9,999,999.00'));
                  obj_data.put('amtpay11', to_char(zvl(a_amtpay(11)),'fm9,999,999.00'));
                  obj_data.put('amtpay12', to_char(zvl(a_amtpay(12)),'fm9,999,999.00'));
                  obj_data.put('sum_amtpay', to_char(zvl(a_amtpay(13)),'fm9,999,999.00'));
                  obj_row.put(to_char(v_rcnt), obj_data);
              --end if; 
            end loop;
            end loop;
            --obj_row.put(to_char(v_rcnt), obj_data);
          end if;
        end if;
      end loop;
      if not v_exist then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TEMPLOY1');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      elsif not v_exist_tpaysum then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TPAYSUM');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      elsif not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      else
        json_str_output := obj_row.to_clob;
      end if;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  end;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_exist         boolean := false;
    v_dteeffec1     date;
    v_dteeffec2     date;
    v_dtestr        date;
    v_dteend        date;
    v_num           number := 0;
    v_late  		    number;
    v_early 		    number;
    v_absent 		    number;
    v_tlate   	    number;
    v_tearly  	    number;
    v_tabsent 	    number;
    v_qtynostam     number;
    v_qtymin		    number;
    v_codcompy      varchar2(100 char);
    param_codcompy  varchar2(100 char);
    v_typpayroll    varchar2(100 char);

    v_rcnt          number := 0;
  begin
    obj_row       := json_object_t();
    v_dteeffec1   := to_date(get_period_date(p_stmonth,p_styear,'S'),'dd/mm/yyyy');
    v_dteeffec2   := to_date(get_period_date(p_enmonth,p_enyear,'S'),'dd/mm/yyyy');
    while v_dteeffec1 <= v_dteeffec2 loop
      begin
        select hcm_util.get_codcomp_level(codcomp,'1'),typpayroll into v_codcompy,v_typpayroll
          from temploy1
         where codempid   = p_codempid;
      exception when no_data_found then v_codcompy := null; v_typpayroll := null;
      end;
      begin
        select min(dtestrt),max(dteend) into v_dtestr,v_dteend
          from tpriodal
         where codcompy   = v_codcompy
           and typpayroll = v_typpayroll
           and codpay     = p_codpay
           and dteyrepay  = to_number(to_char(v_dteeffec1,'yyyy')) - global_v_zyear
           and dtemthpay  = to_number(to_char(v_dteeffec1,'mm'));
      exception when no_data_found then null;
      end;
      v_late      := null;
      v_early     := null;
      v_absent    := null;
      v_tlate     := null;
      v_tearly    := null;
      v_tabsent   := null;
      v_qtynostam := null;
      v_qtymin    := null;
      begin
        select sum(nvl(daylate,0)),  sum(nvl(dayearly,0)),  sum(nvl(dayabsent,0)),
               sum(nvl(qtytlate,0)), sum(nvl(qtytearly,0)), sum(nvl(qtytabs,0))
          into v_late,v_early,v_absent,v_tlate,v_tearly,v_tabsent
          from tlateabs
         where codempid = p_codempid
           and dtework  between v_dtestr and v_dteend;
      end;
      begin
        select codcompy into param_codcompy
          from tcenter
         where codcomp = p_codcomp;
      exception when others then
        param_codcompy := null;
      end;
      begin
        select sum(nvl(qtynostam,0)) into v_qtynostam
          from tattence
         where codempid = p_codempid
           and dtework  between v_dtestr and v_dteend
           and not exists(select codchng
                            from tcontaw5
                            where codcompy = param_codcompy
                              and codaward = p_codaward
                              and dteeffec = v_dteeffec1
                              and codchng = tattence.codchng);
      end;
      begin
        select sum(nvl(qtymin,0)) into v_qtymin
          from tleavetr
         where codempid = p_codempid
           and dtework  between v_dtestr and v_dteend
           and not exists(select codleave
                            from tcontaw2
                            where codcompy = param_codcompy
                              and codaward = p_codaward
                              and dteeffec = v_dteeffec1
                              and codleave = tleavetr.codleave);
      end;
      if v_late > 0 or v_early > 0 or v_absent > 0 or v_tlate > 0 or v_tearly > 0 or v_tabsent > 0 or v_qtynostam >0 or v_qtymin > 0 then
        v_exist   := true;
        v_rcnt    := v_rcnt+1;
        obj_data  := json_object_t();
        obj_data.put('month', get_tlistval_name('NAMMTHFUL',to_number(to_char(v_dteeffec1,'mm')),global_v_lang));
        obj_data.put('late', cal_dhm_concat(v_late, param_qtyavgwk));
        obj_data.put('early', cal_dhm_concat(v_early, param_qtyavgwk));
        obj_data.put('absent', cal_dhm_concat(v_absent, param_qtyavgwk));
        obj_data.put('tlate', v_tlate);
        obj_data.put('tearly', v_tearly);
        obj_data.put('tabsent', v_tabsent);
        obj_data.put('nostam', cal_dhm_concat(v_qtynostam, param_qtyavgwk));
        obj_data.put('leave', cal_dhm_concat(v_qtymin, param_qtyavgwk));

        --gen report--
        if isInsertReport then
          insert_ttemprpt(obj_data);
        end if;
        --

        obj_row.put(to_char(v_rcnt), obj_data);
      end if;
			-------------------------------------------

			v_dteeffec1 := add_months(v_dteeffec1,1);
    end loop;
    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tpaysum');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    p_codaward          := hcm_util.get_string_t(json_obj, 'p_codaward');
    p_stmonth           := to_number(hcm_util.get_string_t(json_obj, 'p_stmonth'));
    p_enmonth           := to_number(hcm_util.get_string_t(json_obj, 'p_enmonth'));
    p_styear            := to_number(hcm_util.get_string_t(json_obj, 'p_styear'));
    p_enyear            := to_number(hcm_util.get_string_t(json_obj, 'p_enyear'));
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
        p_codempid        := hcm_util.get_string_t(p_index_rows, 'codempid');
        p_codpay          := hcm_util.get_string_t(p_index_rows, 'codpay');

        gen_detail(json_output);
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
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_month      				varchar2(1000 char) := '';
    v_late  						varchar2(1000 char) := '';
    v_early       			varchar2(1000 char) := '';
    v_absent      			varchar2(1000 char) := '';
    v_tlate    					varchar2(1000 char) := '';
    v_tearly    	  		varchar2(1000 char) := '';
    v_tabsent    	  		varchar2(1000 char) := '';
    v_nostam    	  	  varchar2(1000 char) := '';
    v_leave    	  			varchar2(1000 char) := '';

  begin
    v_month       		  := nvl(hcm_util.get_string_t(obj_data, 'month'), '');
    v_late   						:= nvl(hcm_util.get_string_t(obj_data, 'late'), ' ');
    v_early       			:= nvl(hcm_util.get_string_t(obj_data, 'early'), '');
    v_absent      			:= nvl(hcm_util.get_string_t(obj_data, 'absent'), '');
    v_tlate      				:= nvl(hcm_util.get_string_t(obj_data, 'tlate'), '');
    v_tearly      			:= nvl(hcm_util.get_string_t(obj_data, 'tearly'), '');
    v_tabsent      			:= nvl(hcm_util.get_string_t(obj_data, 'tabsent'), '');
    v_nostam      			:= nvl(hcm_util.get_string_t(obj_data, 'nostam'), '');
    v_leave      				:= nvl(hcm_util.get_string_t(obj_data, 'leave'), '');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1, item2, item3, item4,item5, item6, item7, item8, item9, item10, item11
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             p_codempid,
             get_temploy_name(p_codempid, global_v_lang),
              v_month,
              v_late,
              v_early,
              v_absent,
              v_tlate,
              v_tearly,
              v_tabsent,
              v_nostam,
              v_leave
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt;

END HRAL68X;

/
