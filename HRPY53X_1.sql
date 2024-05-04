--------------------------------------------------------
--  DDL for Package Body HRPY53X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY53X" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_typbank           := hcm_util.get_string_t(json_obj,'p_typbank');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcodec    varchar2(10 char);
    v_codcomp     varchar2(100 char);
    v_secur       boolean := false;
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numperiod');
		end if;

		if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dtemthpay');
		end if;

		if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyrepay');
		end if;

		if p_typbank is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codbank');
		end if;

    if p_typpayroll is not null then
	 	  begin
			  select codcodec
			    into v_codcodec
				  from tcodtypy
				 where codcodec = p_typpayroll
				  and rownum <= 1;
 			exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'p_typpayroll');
 			end;
		end if;

    if p_codcomp is not null then
      begin
         select codcomp
           into v_codcomp
           from tcenter
          where codcomp like p_codcomp||'%'
         AND ROWNUM <= 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
      end;
      v_secur := secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
 		end if;
  end check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) is
    obj_row           json_object_t := json_object_t();
    obj_data          json_object_t;
    v_flgpass			    boolean := true;
    v_row             number := 0;
    v_data            varchar2(1 char) := 'N';
    v_secur           varchar2(1 char) := 'N';
    v_numbank         varchar2(100 char);
    v_amtnet          number;
    v_codbank_temp    varchar2(100 char) := '@#%';
    v_bankdesc        varchar2(100 char);

    cursor c1 is
      select a.codcomp,a.codempid,a.codbank,a.codbank2,
             to_number(stddec(a.amtnet1,a.codempid,v_chken)) amtnet1,
             to_number(stddec(a.amtnet2,a.codempid,v_chken)) amtnet2,
             a.numbank,a.numbank2,b.codbank codbank3,a.rowid,
             a.dtemthpay,a.dteyrepay,a.numperiod,b.codcompy,b.typbank
        from ttaxcur a,tbnkmdi2 b,temploy1 c
       where a.dteyrepay = p_dteyrepay
         and a.dtemthpay = p_dtemthpay
         and a.numperiod = p_numperiod
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codcomp like p_codcomp||'%'
         and (a.codbank = b.codbank or a.codbank2 = b.codbank )
         and b.typbank  = p_typbank
         and hcm_util.get_codcomp_level(a.codcomp,'1') = b.codcompy
         and stddec(a.amtnet,a.codempid,v_chken) > 0
         and a.codempid = c.codempid
    order by b.codbank,a.codcomp,a.codempid;

  begin
    begin
      select decode(global_v_lang,'101',desclabele,'102',desclabelt,'103',desclabel3,'104',desclabel4,'105',desclabel5,desclabele)
        into v_bankdesc
        from tapplscr
       where codapp = 'HRPY53X'
         and numseq = '150';
    exception when no_data_found then
      v_bankdesc := '';
    end;

    for r1 in c1 loop
      v_data := 'Y';
      v_flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass = true then
        v_secur  := 'Y';
        if v_codbank_temp <> r1.codbank3 then
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', '');
          obj_data.put('codempid','');
          obj_data.put('desc_codempid', v_bankdesc||' '||r1.codbank3 );
          obj_data.put('codcomp', '');
          obj_data.put('desc_codcomp', get_tcodec_name('TCODBANK',r1.codbank3,global_v_lang));
          obj_data.put('numbank', '');
          obj_data.put('amtnet', '');
          obj_data.put('flgskip', 'Y');
          obj_row.put(to_char(v_row - 1), obj_data);
          v_codbank_temp := r1.codbank3;
        end if;
        if r1.codbank3 = r1.codbank and r1.numbank is not null then
          v_numbank := r1.numbank;
          v_amtnet := r1.amtnet1;
          --v_sumbank := nvl(v_sumbank,0) + r1.amtnet1;
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
          obj_data.put('dtemthpay', r1.dtemthpay);
          obj_data.put('dteyrepay', r1.dteyrepay);
          obj_data.put('numperiod', r1.numperiod);
          obj_data.put('codbank', r1.codbank3);
          obj_data.put('desc_codbank', get_tcodec_name('TCODBANK',r1.codbank3,global_v_lang));
          obj_data.put('codcompy', r1.codcompy);
          obj_data.put('typbank', r1.typbank);
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codcomp', r1.codcomp);
          obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('numbank', v_numbank);
          obj_data.put('amtnet', to_char(v_amtnet));
          obj_data.put('flgskip', '');
          obj_row.put(to_char(v_row - 1), obj_data);
        end if;
        if r1.codbank3 = r1.codbank2 and r1.numbank2 is not null then
          v_numbank := r1.numbank2;
          v_amtnet := r1.amtnet2;
          --v_sumbank := nvl(v_sumbank,0) + r1.amtnet2;
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
          obj_data.put('dtemthpay', r1.dtemthpay);
          obj_data.put('dteyrepay', r1.dteyrepay);
          obj_data.put('numperiod', r1.numperiod);
          obj_data.put('codbank', r1.codbank3);
          obj_data.put('desc_codbank', get_tcodec_name('TCODBANK',r1.codbank3,global_v_lang));
          obj_data.put('codcompy', r1.codcompy);
          obj_data.put('typbank', r1.typbank);
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codcomp', r1.codcomp);
          obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('numbank', v_numbank);
          obj_data.put('amtnet', to_char(v_amtnet));
          obj_data.put('flgskip', '');
          obj_row.put(to_char(v_row - 1), obj_data);
        end if;
      end if;
    end loop;

    if v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTAXCUR');
   	elsif v_secur = 'N'   then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
		end if;

    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

end HRPY53X;

/
