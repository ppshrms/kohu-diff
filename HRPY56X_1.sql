--------------------------------------------------------
--  DDL for Package Body HRPY56X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY56X" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    --
    p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');

    -- get param banknote/coin type --
    for i in 1..11 loop
      p_flgcoin(i)      := hcm_util.get_string_t(json_obj,'p_flgcoin'||i);
    end loop;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcodec    varchar2(10 char);
    v_codcomp     varchar2(100 char);
    v_secur       boolean := false;
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numperiod');
      return;
		end if;

		if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dtemthpay');
      return;
		end if;

		if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyrepay');
      return;
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
        return;
 			end;
		end if;

    if p_codcomp is not null then
      begin
         select codcomp
           into v_codcomp
           from tcenter
          where codcomp like p_codcomp||'%'
            and rownum <= 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return;
      end;
      --
      v_secur := secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
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
    v_typpay_temp     varchar2(100 char) := '@#%';
    v_cs              varchar2(100 char);
    v_ch              varchar2(100 char);
    v_desc            varchar2(100 char);
    obj_flg_col       json_object_t;
    v_max_flg_col     number := 0;
    cursor c1 is
      select a.codempid,a.codcomp,a.numlvl,a.typpayroll,a.typpaymt,
             nvl(stddec(a.amtnet,a.codempid,v_chken),0) amtnet ,a.dtemthpay,a.dteyrepay,a.numperiod
        from ttaxcur a,temploy1 b
       where a.codempid  = b.codempid
         and a.dteyrepay = p_dteyrepay
         and a.dtemthpay = p_dtemthpay
         and a.numperiod = p_numperiod
         and a.codcomp like p_codcomp||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and b.staemp <> 0
         and nvl(stddec(a.amtnet,a.codempid,v_chken),0) > 0
         and upper(a.typpaymt) <> upper('BK')
    order by a.typpaymt,a.codcomp,a.codempid;

  begin
    --????????????????? CS-Cash, CH-Cheque, BK-Bank
    begin
      select decode(global_v_lang,'101',desclabele,'102',desclabelt,'103',desclabel3,'104',desclabel4,'105',desclabel5,desclabele)
        into v_ch
        from tapplscr
       where codapp = 'HRPY56X'
         and numseq = '210';
    exception when no_data_found then
      v_ch := '';
    end;
    begin
      select decode(global_v_lang,'101',desclabele,'102',desclabelt,'103',desclabel3,'104',desclabel4,'105',desclabel5,desclabele)
        into v_cs
        from tapplscr
       where codapp = 'HRPY56X'
         and numseq = '220';
    exception when no_data_found then
      v_cs := '';
    end;
    for r1 in c1 loop
      v_data := 'Y';
      --
      v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass = true then
        v_secur  := 'Y';
        if v_typpay_temp <> r1.typpaymt then
          if r1.typpaymt = 'CH' then
            v_desc := v_ch;
          else
            v_desc := v_cs;
          end if;

          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_codempid', v_desc);
          obj_data.put('flgskip', 'Y');

          obj_row.put(to_char(v_row - 1), obj_data);
          v_typpay_temp := r1.typpaymt;
        end if;
--        if r1.typpaymt = 'CS' then
          calc_bank(r1.amtnet);
--        else
--          for i in p_flgcoin.first..p_flgcoin.last loop
--            p_calcoin(i) := 0;
--          end loop;
--        end if;

        obj_flg_col   := json_object_t();
        v_max_flg_col := 0;
        for i in 1..11 loop
          if p_flgcoin(i) > 0 then
            v_max_flg_col := v_max_flg_col + 1;
            if p_calcoin(i) > 0 then
              obj_flg_col.put(to_char(v_max_flg_col), p_calcoin(i));
            else
              obj_flg_col.put(to_char(v_max_flg_col), '');
            end if;
          end if;
        end loop;

        v_row := v_row + 1;
        obj_data     := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('amtnet', r1.amtnet);
        -- put amount coin/bank --
        for i in 1..obj_flg_col.get_size loop
          obj_data.put('flgcoin'||i, hcm_util.get_string_t(obj_flg_col, to_char(i)));
        end loop;
        -----
        obj_data.put('flgcoin_count', v_max_flg_col);
        obj_data.put('flgcoin_other', p_flgcoin_other);
        obj_data.put('flgskip', '');
        obj_data.put('dtemthpay', r1.dtemthpay);
        obj_data.put('dteyrepay', r1.dteyrepay);
        obj_data.put('numperiod', r1.numperiod);
        obj_row.put(to_char(v_row - 1), obj_data);
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

  procedure calc_bank(v_amtnet number) is
    temp     number := 0;
  begin
    -- set default array--
    for i in p_flgcoin.first..p_flgcoin.last loop
      p_calcoin(i) := 0;
    end loop;
    -- loop get amount coin/bank --
    temp  := v_amtnet;
    for i in p_flgcoin.first ..p_flgcoin.last loop --null;
      if nvl(p_flgcoin(i),0) > 0  then
        if nvl(temp,0) >= p_flgcoin(i) then
          p_calcoin(i) := trunc(temp/p_flgcoin(i));
          temp := temp - (p_calcoin(i)*p_flgcoin(i));
        end if;
      end if;
    end loop;
    -- param other coin --
    p_flgcoin_other := temp;
  end;
end HRPY56X;

/
