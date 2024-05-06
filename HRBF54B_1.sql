--------------------------------------------------------
--  DDL for Package Body HRBF54B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF54B" as

/*
	code by 	  : User14/Krisanai Mokkapun
	date        : 29/01/2021 15:01 redmine#4144
*/
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj              := json_object_t(json_str);
    -- global
    v_chken               := hcm_secur.get_v_chken;
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid     := hcm_util.get_string_t(json_obj,'p_codempid');


    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_flgbonus          := hcm_util.get_string_t(json_obj,'p_flgbonus');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure chk_tloaninf is
    v_flgpass		boolean:= false;
    v_data      varchar2(1):='N';

 cursor c_tloaninf is
            select a.codempid ,b.codcomp,b.numlvl
            from   tloaninf a,temploy1 b
            where  a.codempid = b.codempid
            and    b.codcomp like p_codcomp||'%'
            and    b.typpayroll =  nvl(p_typpayroll,b.typpayroll)
            and    a.codempid = nvl( p_codempid,a.codempid)
            and    a.dteissue  <= v_dteend
            and    a.staappr    = 'Y'
            and    a.stalon     <> 'C'
            and   (a.dteaccls >= v_dtestrt  or a.dteaccls is null)
            and a.numcont not in (select c.numcont
                                             from tloanpay c
                                             where c.dteyrepay = p_dteyrepay
                                             and c.dtemthpay = p_dtemthpay
                                             and c.numperiod = p_numperiod
                                             and c.flgtranpy = 'Y')
--<<user14 redmine#4144
            and not exists   (select x.numcont
                                         from tloanpay x
                                       where x.numcont  = a.numcont  and x.flgtranpy = 'N'
                                           and x.dteyrepay||lpad(x.dtemthpay,2,0)||x.numperiod < p_dteyrepay||lpad(p_dtemthpay,2,0)||p_numperiod)
-->>user14 redmine#4144
            order by a.dtelonst;

  begin
    for r1 in c_tloaninf loop
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

  end;

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
          param_msg_error := 'A'||get_error_msg_php('HR2010', global_v_lang, 'TCODTYPY');
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
           param_msg_error := 'B'||get_error_msg_php('HR2010',global_v_lang,'temploy1');
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
      chk_tloaninf;

  end check_index;


  procedure get_process(json_str_input in clob, json_str_output out clob) is
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
    obj_response    json_object_t;
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
    v_dteen  	date;

    v_numerr	  number;
    v_time      varchar2(100 char);
    v_err       varchar2(4000 char);
    v_response  varchar2(4000 char);


  begin
      check_index;
      v_dtestr := sysdate;
      HRBF54B_batch.start_process (p_codcomp ,
                                   p_typpayroll	 ,
                                   p_codempid	 ,
                                   p_numperiod  ,
                                   p_dtemthpay  ,
                                   p_dteyrepay  ,
                                   p_flgbonus   ,
                                   global_v_coduser);



		-------------------------------------------------------
		v_numproc   := nvl(get_tsetup_value('QTYPARALLEL'),5);
		v_numrec  := 0;
	   v_numerr  := 0;
		for j in 1..v_numproc loop
              --dbms_lock.sleep(10);
              begin
               select qtyproc,qtyerr
                 into v_qtyproc,v_qtyerr
                 from tprocount
                where codapp  like 'HRBF54B%'
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

      ----------------------------------------------------------------------
		v_dteen := sysdate;
		v_time   := cal_hhmiss(v_dtestr,v_dteen);
		----------------------------------------------------------------------

    ----------
    begin
	   select codempid||' - '||remark
	     into v_err
	     from tprocount
	    where codapp  like 'HRBF54B%'--= v_codapp
	      and coduser = global_v_coduser
	      and flgproc = 'E'
	      and rownum  = 1 ;
	  exception when no_data_found then
	  	 v_err := null ;
	  end;
    ----------

    if v_exist = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TLOANINF');
      rollback;
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      commit;
      obj_data := json_object_t();
      obj_data.put('stdate' , to_char(v_dtestrt,'dd/mm/yyyy'));
      obj_data.put('endate' , to_char(v_dteend,'dd/mm/yyyy'));
      obj_data.put('numrec', nvl(v_numrec,0));
      obj_data.put('minute', nvl(v_time,0));
      --obj_data.put('message',p_file_path || p_filename);

      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);

      obj_response  := json_object_t();
      obj_response.put('coderror', '200');
      obj_response.put('detail', obj_data);
      obj_response.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      json_str_output := obj_response.to_clob;
    end if;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end process_data;

  procedure get_tdtepay(json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t;
    v_data          varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_flg           varchar2(1 char);
    v_dteupd        date;
    v_numperiod     number;
    v_dtemthpay     number;
    v_dteyrepay     number;
    v_numtext       varchar2(100 char);

  begin
    initial_value(json_str_input);
    check_index;

    --v_dtestrt ,v_dteend
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtestrt' , to_char(v_dtestrt,'dd/mm/yyyy'));
    obj_data.put('dteend' , to_char(v_dteend,'dd/mm/yyyy'));


    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tdtepay;

end HRBF54B;

/
