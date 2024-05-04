--------------------------------------------------------
--  DDL for Package Body HRAP5AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP5AB" AS

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');   
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codbon      := hcm_util.get_string_t(json_obj,'p_codbon');
    b_index_codcompy    := get_comp_split(b_index_codcomp,1);
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
    v_codbon    varchar2(10 char);
  begin
    if nvl(b_index_dteyreap,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyreap');
      return;
    end if;
    if nvl(b_index_numtime,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numtime');
      return;
    end if;    
    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;        
    end if;
    if b_index_codbon is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codbon');
      return;        
    end if;

    if b_index_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,b_index_codcomp);
        if param_msg_error is not null then
          return;
        end if;
    end if;

	begin
		select codcodec into v_codbon
		  from tcodbons
		 where codcodec = b_index_codbon;
	exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodbons');
      return; 
	end;      

  end check_index;

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
    v_codpay        tsincexp.codpay%type;
    v_codcompy      tcompny.codcompy%type; 

    cursor c_tbonuspy is
        select codcomp,typpayroll,codpay,numperiod,dtemthpay,dteyrepay
          from tbonuspy
         where dteyreap = b_index_dteyreap
           and numtime  = b_index_numtime
           and codbon   = b_index_codbon
           and codcomp  like b_index_codcomp||'%'
        order by typpayroll,codpay;    

  begin
    obj_row  := json_object_t();
    v_rcnt   := 0;
    for i in c_tbonuspy loop
        v_rcnt       := v_rcnt+1;
        obj_data     := json_object_t();
        obj_data.put('coderror', '200');    
        v_codcompy   := hcm_util.get_codcomp_level(i.codcomp,1);
        obj_data.put('typpayroll', i.typpayroll);
        obj_data.put('desc_typpayroll', get_tcodec_name('TCODTYPY',i.typpayroll,global_v_lang));
        obj_data.put('codpay', i.codpay);
        obj_data.put('desc_codpay', get_tinexinf_name(i.codpay,global_v_lang));
        obj_data.put('numperiod', i.numperiod);
        obj_data.put('dtemthpay', i.dtemthpay);
        obj_data.put('dteyrepay', i.dteyrepay);
        obj_data.put('numemp', '');
        obj_data.put('amtbon', '');
        obj_data.put('codcompy', v_codcompy);
        obj_data.put('codcomp', i.codcomp);
        obj_row.put(to_char(v_rcnt), obj_data);        
    end loop;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;

  procedure check_transfer_data is
    v_numperiod     tdtepay.numperiod%type; 
    v_dtemthpay     tdtepay.dtemthpay%type;
    v_dteyrepay     tdtepay.dteyrepay%type; 
    v_typpayroll    temploy1.typpayroll%type; 
    v_codpay        tsincexp.codpay%type; 
    v_rec1          number := 0;
    v_rec2          number := 0;
    v_flgcal        varchar2(10 char);
    v_found         varchar2(10 char);
	v_period 		varchar2(20);
	v_period_max 	varchar2(20);	 


    cursor c_tdtepay is
        select typpayroll,numperiod,dtemthpay,dteyrepay
          from tdtepay
         where codcompy   = p_codcompy
           and typpayroll = p_typpayroll
           and flgcal     = 'Y'
        order by dteyrepay desc,dtemthpay desc, numperiod desc;

	cursor c1 is
		select dteyrepay,dtemthpay,numperiod,flgcal
		  from tdtepay
		  where codcompy    = p_codcompy
		    and typpayroll  = p_typpayroll 
		    and dteyrepay||lpad(dtemthpay,2,'0')||numperiod > p_dteyrepay||lpad(p_dtemthpay,2,'0')||p_numperiod
		order by dteyrepay,dtemthpay,numperiod ;

  begin
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;

    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;

    begin
        select codcodec into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'typpayroll');
        return;
    end;

    begin
        select codpay into v_codpay
          from tinexinf
         where codpay = p_codpay
           and rownum <= 1;
    exception when no_data_found then							
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
        return;
    end;

    begin
        select codpay into v_codpay
          from tinexinf
         where codpay = p_codpay
           and typpay in (2,3);
    exception when no_data_found then						
        param_msg_error := get_error_msg_php('AP0012', global_v_lang, 'codpay');
        return;
    end; 

    for j in c_tdtepay loop
        v_numperiod := j.numperiod;
        v_dtemthpay := j.dtemthpay;
        v_dteyrepay := j.dteyrepay;
        exit;
    end loop;

    if p_dteyrepay||lpad(p_dtemthpay,2,'0')||p_numperiod < v_dteyrepay||lpad(v_dtemthpay,2,'0')||v_numperiod then
        param_msg_error := get_error_msg_php('HR7517', global_v_lang);
        return;        
    end if;

	begin
		select nvl(flgcal,'N') into v_flgcal
		  from tdtepay
		 where codcompy   = p_codcompy
		   and typpayroll = p_typpayroll 
		   and dteyrepay  = p_dteyrepay
		   and dtemthpay  = p_dtemthpay
		   and numperiod  = p_numperiod	;
	exception when no_data_found then
		v_flgcal := 'N';
	end;

	v_period := to_char(p_dteyrepay||lpad(p_dtemthpay,2,0)||p_numperiod);

	if v_flgcal = 'Y' then
        v_flgcal := null;
        v_found  := 'N' ;
        for i in c1 loop
            v_flgcal := i.flgcal ;
            v_found  := 'Y' ;
            exit;
        end loop;
        if v_found = 'Y' and nvl(v_flgcal,'N') = 'Y' then
            param_msg_error := get_error_msg_php('AP0013', global_v_lang, 'typpayroll');
            return;
        end if;
	else
        for r_tdtepay in c_tdtepay loop  
            v_typpayroll := r_tdtepay.typpayroll;  
            v_dteyrepay  := r_tdtepay.dteyrepay;  
            v_dtemthpay  := r_tdtepay.dtemthpay;  
            v_numperiod  := r_tdtepay.numperiod; 	
            exit;
        end loop;	

		v_period_max :=	to_char(v_dteyrepay||lpad(v_dtemthpay,2,0)||v_numperiod);

		if v_period < v_period_max then
            param_msg_error := get_error_msg_php('AP0014', global_v_lang, 'typpayroll');
            return;
		end if;
	end if;


  end check_transfer_data;

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
    if param_msg_error is null then
      json_obj := json_object_t();
      obj_row  := json_object_t();
      v_rcnt   := 0;
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        p_typpayroll    := hcm_util.get_string_t(param_json_row,'typpayroll');
        p_codpay        := hcm_util.get_string_t(param_json_row,'codpay');
        p_numperiod     := hcm_util.get_string_t(param_json_row,'numperiod');
        p_dtemthpay     := hcm_util.get_string_t(param_json_row,'monthperiod');
        p_dteyrepay     := hcm_util.get_string_t(param_json_row,'yearperiod');
        p_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
        p_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
        check_transfer_data;
        if param_msg_error is null then
            transfer_data;
            v_rcnt       := v_rcnt+1;
            obj_data     := json_object_t();
            obj_data.put('typpayroll', p_typpayroll);
            obj_data.put('desc_typpayroll', get_tcodec_name('TCODTYPY',p_typpayroll,global_v_lang));
            obj_data.put('codpay', p_codpay);
            obj_data.put('desc_codpay', p_codpay||' - '||get_tinexinf_name(p_codpay,global_v_lang));
            obj_data.put('numperiod', p_numperiod);
            obj_data.put('monthperiod', p_dtemthpay);
            obj_data.put('yearperiod', p_dteyrepay);
            obj_data.put('numemp', nvl(p_numemp,0));
            obj_data.put('amtbon', nvl(p_amtbon,0));
            obj_row.put(to_char(v_rcnt-1), obj_data);
        else
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            rollback;
            return;
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

  procedure transfer_data is
    v_flgsecu		boolean;
    v_codempid	    temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_typpayroll    temploy1.typpayroll%type;
    v_flgfound      boolean := false;
    v_typpay        varchar2(40 char);
    v_zupdsal       varchar2(40 char);

	cursor c_tbonus is
		select codempid,codcomp,typpayroll,stddec(amtnbon,codempid,v_chken) amtnbon,rowid
		  from tbonus
		 where dteyreap     = b_index_dteyreap
		   and numtime      = b_index_numtime
		   and codbon       = b_index_codbon
		   and codcomp      like p_codcomp || '%' -- Adisak redmine#9283
		   and typpayroll   = p_typpayroll
		   and nvl(flgtrnpy,'N')   = 'N'
		   and nvl(staappr,'N')    = 'Y'
		   and nvl(stddec(amtnbon,codempid,v_chken),0) <> 0
	order by codempid
		for update;	

    cursor c_tbonuspy is
        select dteyreap,numtime,codbon,codcomp,typpayroll,codpay,numperiod,dtemthpay,dteyrepay
          from tbonuspy
         where dteyreap   = b_index_dteyreap
           and codcomp    = v_codcomp
           and typpayroll = v_typpayroll;

  begin
    for r_tbonus in c_tbonus loop
        << main_loop >> loop
            if secur_main.secur2(r_tbonus.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then						 
                --create tothinc   
                ins_tothinc(r_tbonus.codempid,p_dteyrepay,p_dtemthpay,p_numperiod,p_codpay,r_tbonus.codcomp,r_tbonus.typpayroll,r_tbonus.amtnbon);  
                --update tbonus
                update tbonus set   numperiod = p_numperiod,
                                    dtemthpay = p_dtemthpay,
                                    dteyrepay = p_dteyrepay,
                                    flgtrnpy  = 'Y' ,
                                    coduser   = global_v_coduser
                where rowid = r_tbonus.rowid;
                p_numemp := nvl(p_numemp,0) + 1;
                p_amtbon := nvl(p_amtbon,0) + r_tbonus.amtnbon;	 
                v_codcomp    := r_tbonus.codcomp;
                v_typpayroll := r_tbonus.typpayroll;
                for r_tbonuspy in c_tbonuspy loop
                    v_flgfound := true;
                    update tbonuspy set numperiod = p_numperiod,
                                        dtemthpay = p_dtemthpay,
                                        dteyrepay = p_dteyrepay,
                                        coduser   = global_v_coduser
                    where dteyreap   = r_tbonuspy.dteyreap
                      and numtime    = r_tbonuspy.numtime
                      and codbon     = r_tbonuspy.codbon
                      and codcomp    = r_tbonuspy.codcomp
                      and typpayroll = r_tbonuspy.typpayroll;                                 
                end loop;
                if not v_flgfound then 
                    insert into tbonuspy (dteyreap,numtime,codbon,
                                         codcomp,typpayroll,numperiod,
                                         dtemthpay,dteyrepay,codcreate,
                                         coduser) 
                            values     (b_index_dteyreap,b_index_numtime,b_index_codbon,
                                        r_tbonus.codcomp,r_tbonus.typpayroll,
                                        p_numperiod,p_dtemthpay,p_dteyrepay,
                                        global_v_coduser,global_v_coduser);
                end if;
            else
                exit main_loop;
            end if;
        exit main_loop;
        end loop;
	end loop;

  end;

  procedure ins_tothinc (v_codempid   in temploy1.codempid%type,
                         v_dteyrepay  in tothinc.dteyrepay%type,
                         v_dtemthpay  in tothinc.dtemthpay%type,
                         v_numperiod  in tothinc.numperiod%type,
                         v_codpay     in tothinc.codpay%type,
                         v_codcomp	  in tothinc.codcomp%type,
                         v_typpayroll in tothinc.typpayroll%type,
                         v_amtnbon    in tothinc.amtpay%type) is

	  v_amtpaynet     	varchar2(40 char);
	  v_count           number := 0;
      v_codcompw        temploy1.codcomp%type;
      v_codcompgl       temploy1.codcomp%type;
      v_flgfound        boolean := false;
      v_typemp          varchar2(40);

    cursor c_tothinc is
        select codempid,stddec(amtpay,p_codempid,v_chken) amtpay,rowid
          from tothinc
         where codempid  = v_codempid
           and dteyrepay = v_dteyrepay	
           and dtemthpay = v_dtemthpay	
           and numperiod = v_numperiod
           and codpay    = v_codpay
        order by codempid,dteyrepay,dtemthpay,numperiod,codpay;


      cursor c_tothinc2 is
        select rowid,codempid,amtpay
          from tothinc2
         where codempid   = v_codempid
           and dteyrepay  = v_dteyrepay
           and dtemthpay  = v_dtemthpay
           and numperiod  = v_numperiod
           and codpay     = v_codpay
           and codcompw   = v_codcompw;

  begin

      v_codcompw  := v_codcomp;
      begin
        select costcent into v_codcompgl
          from tcenter
         where codcomp = v_codcompw;
      exception when no_data_found then
        v_codcompgl := null;
      end;

	begin 
		select typemp into  v_typemp 
		 from temploy1 
		where codempid = v_codempid;
	exception when no_data_found then 
		null;
	end;
	v_flgfound := false;  
	for r_tothinc in c_tothinc loop
		v_flgfound  := true;    
		v_amtpaynet := stdenc(round((r_tothinc.amtpay + v_amtnbon),2),v_codempid,v_chken);  
		update tothinc set  codcomp 	= v_codcomp,
                            typpayroll  = v_typpayroll,
                            typemp  	= v_typemp, 
                            amtpay  	= v_amtpaynet,
                            codsys  	= 'AP',
                            coduser 	= global_v_coduser
                            where rowid = r_tothinc.rowid;		 
	end loop;   
	if not v_flgfound then
		v_amtpaynet := stdenc(v_amtnbon,p_codempid,v_chken);  
        insert into tothinc(
                            codempid,dteyrepay,dtemthpay,
                            numperiod,codpay,codcomp,
                            typpayroll,typemp,amtpay,
                            codsys,coduser,codcreate
                            )
                values      (
                            v_codempid,v_dteyrepay,v_dtemthpay,
                            v_numperiod,v_codpay,v_codcomp,
                            v_typpayroll,v_typemp,v_amtpaynet,
                            'AP',global_v_coduser,global_v_coduser
                            );
	end if;	


    for r_tothinc2 in c_tothinc2 loop
        v_flgfound := true;
        v_amtpaynet := nvl(stddec(r_tothinc2.amtpay,r_tothinc2.codempid,v_chken),0) + nvl(stddec(v_amtnbon,r_tothinc2.codempid,v_chken),0);

        update tothinc2
           set amtpay     = stdenc(v_amtpaynet,codempid,v_chken),
               costcent   = v_codcompgl,
               codsys	  = 'AP',
               coduser    = global_v_coduser
         where rowid = r_tothinc2.rowid;
    end loop;

    if not v_flgfound then
        v_amtpaynet := stdenc(round(v_amtnbon,2),v_codempid,v_chken);
        insert into tothinc2 (codempid,dteyrepay,dtemthpay,
                              numperiod,codpay,codcompw,
                              costcent,amtpay,codsys,
                              coduser,codcreate)
               values        (v_codempid,v_dteyrepay,v_dtemthpay,
                              v_numperiod,v_codpay,v_codcompw,
                              v_codcompgl,v_amtpaynet,'AP',
                              global_v_coduser,global_v_coduser);
    end if;

  end;

END HRAP5AB;

/
