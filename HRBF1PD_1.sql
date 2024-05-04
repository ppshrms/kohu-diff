--------------------------------------------------------
--  DDL for Package Body HRBF1PD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1PD" as

/*
	code by 	  : User14/Krisanai Mokkapun
	date        : 13/09/2021 16:01
*/

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_typcal            := hcm_util.get_string_t(json_obj,'p_typcal');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure chk_typcal1 is
    v_flgpass1		boolean:= false;
    v_data1        varchar2(1):='N';


       cursor c1 is
         select a.codempid, a.codcomp,b.numlvl
           from tclnsinf a,temploy1 b
        where a.codempid = b.codempid
            and a.codcomp like p_codcomp||'%'
            and b.typpayroll   = nvl(p_typpayroll, b.typpayroll)
            and a.codempid   = nvl(p_codempid, a.codempid)
            and a.flgtranpy    = 'Y'
            and a.dteyrepay  = p_dteyrepay
            and a.dtemthpay = p_dtemthpay
            and a.numperiod  = p_numperiod
            and  not exists (select x.codempid
                             from ttaxcur x
                          where x.codempid = a.codempid
                              AND nvl(x.flgtrnbank,'N') = 'Y'
                              and x.dteyrepay  = a.dteyrepay
                              and x.dtemthpay = a.dtemthpay
                              and x.numperiod  = a.numperiod )
       union all
       select a.codempid, b.codcomp,b.numlvl
            from trepay a,temploy1 b
         where a.codempid = b.codempid
             and b.codcomp like p_codcomp||'%'
             and b.typpayroll   = nvl(p_typpayroll, b.typpayroll)
             and a.codempid   = nvl(p_codempid, a.codempid)
             and a.dtelstpay =   p_dteyrepay||lpad(p_dtemthpay,2,0)|| p_numperiod
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               AND nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  =  p_dteyrepay
                               and x.dtemthpay =  p_dtemthpay
                               and x.numperiod  =  p_numperiod ) 
     order by codempid ;


  begin
    for r1 in c1 loop
      v_data1 := 'Y';
      v_flgpass1 := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass1 then
          exit;
      end if;
    end loop;

    if v_data1 = 'N' then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TCLNSINF');
       return;
    end if;

    if not v_flgpass1 then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;
  end chk_typcal1;

  procedure chk_typcal2 is
   v_flgpass		boolean:= false;
    v_data      varchar2(1):='N';

       cursor c2 is
          select a.codempid, b.codcomp,b.numlvl
            from trepay a,temploy1 b
         where a.codempid = b.codempid
             and b.codcomp like p_codcomp||'%'
             and b.typpayroll   = nvl(p_typpayroll, b.typpayroll)
             and a.codempid   = nvl(p_codempid, a.codempid)
             and a.dtelstpay =   p_dteyrepay||lpad(p_dtemthpay,2,0)|| p_numperiod
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               AND nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  =  p_dteyrepay
                               and x.dtemthpay =  p_dtemthpay
                               and x.numperiod  =  p_numperiod )
      order by a.codempid ;

  begin
    for r1 in c2 loop
      v_data := 'Y';
      v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
          exit;
      end if;
    end loop;

    if v_data = 'N' then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREPAY');
       return;
    end if;

    if not v_flgpass then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;
  end chk_typcal2;

  procedure chk_typcal3 is
 v_flgpass		boolean:= false;
 v_data      varchar2(1):='N';
 v_codincbf  tcontrbf.codincbf%type;
 v_codcomp  temploy1.codcomp%type;


          cursor c3 is
              select a.codempid, a.codcomp,b.numlvl
                from tobfinf a,temploy1 b
             where a.codempid = b.codempid
                 and a.codcomp like p_codcomp||'%'
                 and b.typpayroll   = nvl(p_typpayroll, b.typpayroll)
                 and a.codempid   = nvl(p_codempid, a.codempid)
                 and a.flgtranpy    = 'Y' and a.typepay = '2'
                 and a.dteyrepay  = p_dteyrepay
                 and a.dtemthpay = p_dtemthpay
                 and a.numperiod  = p_numperiod
                 and  not exists (select x.codempid
                                  from ttaxcur x
                               where x.codempid = a.codempid
                                   AND nvl(x.flgtrnbank,'N') = 'Y'
                                   and x.dteyrepay  = a.dteyrepay
                                   and x.dtemthpay = a.dtemthpay
                                   and x.numperiod  = a.numperiod )
          order by a.codempid ;
  begin
    for r1 in c3 loop
      v_data := 'Y';
      v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
          exit;
      end if;
    end loop;

    if v_data = 'N' then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBFINF');
       return;
    end if;

    if not v_flgpass then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;


  end chk_typcal3;

  procedure chk_typcal4 is
 v_flgpass		boolean:= false;
    v_data      varchar2(1):='N';

       cursor c4 is
          select a.codempid, a.codcomp,b.numlvl
            from ttravinf a,temploy1 b
         where a.codempid = b.codempid
             and a.codcomp like p_codcomp||'%'
             and b.typpayroll   = nvl( p_typpayroll, b.typpayroll)
             and a.codempid   = nvl( p_codempid, a.codempid)
             and a.flgtranpy    = 'Y'
             and a.dteyrepay  = p_dteyrepay
             and a.dtemthpay = p_dtemthpay
             and a.numperiod  = p_numperiod
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               AND nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  = a.dteyrepay
                               and x.dtemthpay = a.dtemthpay
                               and x.numperiod  = a.numperiod )
      order by a.codempid ;

  begin
    for r1 in c4 loop
      v_data := 'Y';
      v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
          exit;
      end if;
    end loop;

    if v_data = 'N' then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTRAVINF');
       return;
    end if;

    if not v_flgpass then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;
  end chk_typcal4;

  procedure chk_typcal5 is
    v_flgpass		boolean:= false;
    v_data      varchar2(1):='N';

   cursor c5 is
         select a.codempid,b.codcomp,b.numlvl
         from   tloaninf a,temploy1 b
         where  b.codempid = a.codempid
         and    b.codcomp 	 like p_codcomp||'%'
         and    b.typpayroll   =  nvl(p_typpayroll,b.typpayroll)
         and    a.codempid  	=  nvl(p_codempid,a.codempid)
         and    a.dteyrpay	   =  p_dteyrepay
         and    a.mthpay	   =  p_dtemthpay
         and    a.prdpay	   =  p_numperiod
         and    a.typpayamt  = '1'
         and    a.staappr   	 = 'Y'
         and    nvl(a.flgpay,'N')  = 'Y'
        and  not exists (select x.codempid
                          from ttaxcur x
                       where x.codempid = a.codempid
                           AND nvl(x.flgtrnbank,'N') = 'Y'
                           and x.dteyrepay  = a.dteyrpay
                           and x.dtemthpay = a.mthpay
                           and x.numperiod  = a.prdpay )
         and  not exists (select x.numcont
                                   from tloanpay x
                                 where x.numcont  = a.numcont
                                     and x.flgtranpy = 'Y')
         order by a.codempid , numcont;


  begin
    for r1 in c5 loop
      v_data := 'Y';
      v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
          exit;
      end if;
    end loop;

    if v_data = 'N' then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TLOANINF');
       return;
    end if;

    if not v_flgpass then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;
  end chk_typcal5;

  procedure chk_typcal6 is
    v_flgpass		boolean:= false;
    v_data      varchar2(1):='N';

    cursor c6 is
         select a.codempid,b.codcomp,b.numlvl
           from tloanpay a,temploy1 b
         where b.codempid = a.codempid
             and a.codcomp like p_codcomp||'%'
             and a.typpayroll    = nvl( p_typpayroll,  b.typpayroll)
             and a.codempid  	= nvl( p_codempid, b.codempid)
             and a.numperiod   = p_numperiod
             and a.dtemthpay  = p_dtemthpay
             and a.dteyrepay   = p_dteyrepay
             and a.typpay = '1'
             and nvl(a.flgtranpy,'N') = 'Y'
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               AND nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  = a.dteyrepay
                               and x.dtemthpay = a.dtemthpay
                               and x.numperiod  = a.numperiod )
            and  not exists (select x.numcont
                                from tloanpay x
                              where x.numcont  = a.numcont
                                  and x.dteyrepay||lpad(x.dtemthpay,2,0)||x.numperiod  > a.dteyrepay||lpad(a.dtemthpay,2,0)||a.numperiod)
         order by a.numcont, a.dterepmt desc;

  begin

   for r1 in c6 loop
      v_data := 'Y';
      v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
          exit;
      end if;
    end loop;

    if v_data = 'N' then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TLOANPAY');
       return;
    end if;

    if not v_flgpass then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;

  end chk_typcal6;

  procedure chk_typcal7 is
  v_flgpass		boolean:= false;
    v_data      varchar2(1):='N';

       cursor c7 is
          select a.codempid, a.codcomp,b.numlvl
            from tinsdinf a,temploy1 b
         where a.codempid = b.codempid
             and a.codcomp like  p_codcomp||'%'
             and b.typpayroll   = nvl( p_typpayroll, b.typpayroll)
             and a.codempid   = nvl( p_codempid, a.codempid)
             and a.flgtranpy    = 'Y'
             and a.dteyrepay  = p_dteyrepay
             and a.dtemthpay = p_dtemthpay
             and a.numprdpay  = p_numperiod
             and  not exists (select x.codempid
                              from ttaxcur x
                           where x.codempid = a.codempid
                               and nvl(x.flgtrnbank,'N') = 'Y'
                               and x.dteyrepay  = a.dteyrepay
                               and x.dtemthpay = a.dtemthpay
                               and x.numperiod  = a.numprdpay )
      order by a.codempid ;

  begin
    for r1 in c7 loop
      v_data := 'Y';
      v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
          exit;
      end if;
    end loop;

    if v_data = 'N' then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TINSDINF');
       return;
    end if;

    if not v_flgpass then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;
  end chk_typcal7;

  function cal_hhmiss (p_st	date,p_en date) return varchar is
      v_num   number	:= 0;
      v_sc   	number	:= 0;
      v_mi   	number	:= 0;
      v_hr   	   number	:= 0;
      v_time   varchar2(500);
  begin
      v_num	  :=  ((p_en - p_st) * 86400) + 1;  ---- 86400 = 24*60*60
      v_hr    :=  trunc(v_num/3600);
      v_mi    :=  mod(v_num,3600);
      v_sc    :=  mod(v_mi,60);
      v_mi    :=  trunc(v_mi/60);
      v_time  :=  lpad(v_hr,2,0)||':'||lpad(v_mi,2,0)||':'||lpad(v_sc,2,0);
      return(v_time);
  end; --function cal_hhmiss

  procedure check_index is
     flgsecu            boolean := false;
     v_check          varchar2(1);

     v_codcomp        temploy1.codcomp%type;
     v_typpayroll       temploy1.typpayroll%type;

  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

     if p_typpayroll is not null then
        begin
          select 'X'
            into v_check
            from tcodtypy
           where codcodec = p_typpayroll;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODTYPY');
          return;
        end;
   end if;

    if p_codempid is not null then
         begin
           select codcomp,typpayroll
             into v_codcomp,  v_typpayroll
             from temploy1
            where codempid = p_codempid;
         exception when no_data_found then null;
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
           return;
         end;

         if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
           param_msg_error := get_error_msg_php('HR3007',global_v_lang);
           return;
         end if;
    end if;

    if p_codempid is null then
        v_codcomp   := p_codcomp;
        v_typpayroll  := p_typpayroll;
     end if;

      begin
          select dtestrt,dteend into v_dtestrt ,v_dteend
             from tdtepay
          where codcompy   = hcm_util.get_codcomp_level(v_codcomp, '1')
              and typpayroll    = v_typpayroll
              and dteyrepay   = p_dteyrepay
              and dtemthpay  = p_dtemthpay
              and numperiod   = p_numperiod;
         exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TDTEPAY');
          return;
      end ;

      if p_typcal = '1' then
         chk_typcal1;
      elsif p_typcal = '2' then
         chk_typcal2;
      elsif p_typcal = '3' then
         chk_typcal3;
      elsif p_typcal = '4' then
         chk_typcal4;
      elsif p_typcal = '5' then
         chk_typcal5;
      elsif p_typcal = '6' then
         chk_typcal6;
      elsif p_typcal = '7' then
         chk_typcal7;
      end if;


  end check_index;


  procedure get_process(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
      global_v_batch_flgproc := 'Y'; -- 18/08/2021
    else
       global_v_batch_flgproc := 'N'; -- 18/08/2021
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;


    -- set complete batch process
    hcm_batchtask.finish_batch_process(
      p_codapp    => global_v_batch_codapp,
      p_coduser   => global_v_coduser,
      p_codalw    => global_v_batch_codalw,
      p_dtestrt   => global_v_batch_dtestrt,
      p_flgproc   => global_v_batch_flgproc,
      p_qtyproc   => global_v_batch_qtyproc,
      p_qtyerror  => global_v_batch_qtyerror,
      p_oracode   => param_msg_error
    );

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end get_process;

  procedure process_data(json_str_output out clob) is
    obj_data        json_object_t;
    v_data          varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_flg           varchar2(1 char);
    data_file 			varchar2(4000 char);
    v_exist			varchar2(1) := 'N';
    v_secur			varchar2(1) := 'N';
    --v_timeout 	number:= get_tsetup_value('TIMEOUT') ;
    v_numproc  	number:= 5;
    v_qtyproc   number:= 0;
    v_qtyerr    number:= 0;
    v_dtestr  	date;
    v_dteend  	date;

    v_numerr	  number;
    v_time      varchar2(100 char);
    v_err       varchar2(4000 char);
    v_response  varchar2(4000 char);


  begin
      check_index;
		v_dtestr := sysdate;
      HRBF1PD_batch.start_process ( p_typcal,
                                                 p_codcomp ,
                                                 p_typpayroll	 ,
                                                 p_codempid	 ,
                                                 p_numperiod  ,
                                                 p_dtemthpay  ,
                                                 p_dteyrepay  ,
                                                 global_v_coduser);
		-------------------------------------------------------
		v_numproc   := nvl(get_tsetup_value('QTYPARALLEL'),5);
		v_numrec  := 0;
	   v_numerr  := 0;
		for j in 1..v_numproc loop
		  begin
		   select qtyproc,qtyerr
		     into v_qtyproc,v_qtyerr
		     from tprocount
		    where codapp  like 'HRBF1PD%'
		      and coduser = global_v_coduser
		      and flgproc = 'Y'
		      and numproc = j;
		  exception when no_data_found then
		  	 v_qtyproc  := 0;
		  	 v_qtyerr   := 0;
		  end;

          v_numrec  := nvl(v_numrec,0) + nvl(v_qtyproc,0);
		    v_numerr  := nvl(v_numerr,0) + nvl(v_qtyerr,0);
		end loop;

		if nvl(v_numrec,0) > 0 or nvl(v_numerr,0) > 0 then
			v_exist := 'Y';
		end if;

      v_dteend := sysdate;
      if p_typcal = '1' then
          process_trepay (v_numrec ,v_numerr ,v_dteend);
      end if;
      ----------------------------------------------------------------------
		--v_dteend := sysdate;
		v_time   := cal_hhmiss(v_dtestr,v_dteend);
		----------------------------------------------------------------------

    ----------
    begin
	   select codempid||' - '||remark
	     into v_err
	     from tprocount
	    where codapp  like 'HRBF1PD%'--= v_codapp
	      and coduser = global_v_coduser
	      and flgproc = 'E'
	      and rownum  = 1 ;
	  exception when no_data_found then
	  	 v_err := null ;
	  end;
    ----------

--    if v_exist = 'N' then
--      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TLOANINF');
--      rollback;
--    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      commit;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numrec', nvl(v_numrec,0));
      obj_data.put('timeprocess', nvl(v_time,0));
      --obj_data.put('message',p_file_path || p_filename);

      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      json_str_output := obj_data.to_clob;

      -- set complete batch process
      param_msg_error := null;
      global_v_batch_qtyproc := nvl(v_numrec,0);
      global_v_batch_qtyerror:= nvl(v_numerr,0);
    end if;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end process_data;


  procedure process_trepay (p_numrec in out number, p_numerr in out number,p_dteend in out date)  is
    obj_data        json_object_t;
    v_data          varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_flg           varchar2(1 char);
    data_file 			varchar2(4000 char);
    v_exist			varchar2(1) := 'N';
    v_secur			varchar2(1) := 'N';
    --v_timeout 	number:= get_tsetup_value('TIMEOUT') ;
    v_numproc  	number:= 5;
    v_qtyproc   number:= 0;
    v_qtyerr    number:= 0;
    v_dteend  	date;
    v_numerr	  number;


  begin
      HRBF1PD_batch.start_process ( '2',
                                                 p_codcomp ,
                                                 p_typpayroll	 ,
                                                 p_codempid	 ,
                                                 p_numperiod  ,
                                                 p_dtemthpay  ,
                                                 p_dteyrepay  ,
                                                 global_v_coduser);
		-------------------------------------------------------
		v_numproc   := nvl(get_tsetup_value('QTYPARALLEL'),5);
		v_numrec  := 0;
	   v_numerr  := 0;
		for j in 1..v_numproc loop
		  begin
		   select qtyproc,qtyerr
		     into v_qtyproc,v_qtyerr
		     from tprocount
		    where codapp  like 'HRBF1PD%'
		      and coduser = global_v_coduser
		      and flgproc = 'Y'
		      and numproc = j;
		  exception when no_data_found then
		  	 v_qtyproc  := 0;
		  	 v_qtyerr   := 0;
		  end;

          v_numrec  := nvl(v_numrec,0) + nvl(v_qtyproc,0);
		    v_numerr  := nvl(v_numerr,0) + nvl(v_qtyerr,0);
		end loop;
		  v_dteend := sysdate;
        p_numrec  := nvl(p_numrec,0) + v_numrec;
        p_numerr  := nvl(p_numerr,0) + v_numerr;
        p_dteend  := v_dteend;

  end process_trepay;


end HRBF1PD;

/
