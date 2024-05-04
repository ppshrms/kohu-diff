--------------------------------------------------------
--  DDL for Package Body HRPY5HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5HX" is
  function gtempded (v_empid 			varchar2,
                     v_codeduct 	varchar2,
                     v_type 			varchar2,
                     v_amtcode 		number,
                     p_amtsalyr 	number) return number is

    v_amtdeduct 	number(14,2);
    v_amtdemax		tdeductd.amtdemax%type;
    v_pctdemax		tdeductd.pctdemax%type;
    v_formula			tdeductd.formula%type;
    v_pctamt 			number(14,2);
    v_check  			varchar2(20);
    v_typeded  		varchar2(1);
  begin
    v_amtdeduct := v_amtcode;
    if v_amtdeduct = 0 then
      begin
        select decode(v_type,'1',stddec(amtdeduct,codempid,v_chken),stddec(amtspded,codempid,v_chken))
          into v_amtdeduct
          from ttaxmasd
         where dteyrepay = (p_dteyrepay - global_v_zyear)
           and dtemthpay = p_dtemthpay
           and numperiod = p_numperiod
           and codempid  = p_codempid
           and coddeduct = v_codeduct;
      exception when others then
        v_amtdeduct := 0;
      end;
    end if;
    --
    if v_amtdeduct > 0 then
      begin
        select amtdemax, pctdemax, formula
          into v_amtdemax, v_pctdemax, v_formula
          from tdeductd
         where dteyreff = (select max(dteyreff)
                             from tdeductd
                            where dteyreff <= p_dteyrepay - global_v_zyear
                              and coddeduct = v_codeduct)
           and coddeduct = v_codeduct;
      exception when others then
        v_amtdemax := null;
        v_pctdemax := null;
        v_formula  := null;
      end;
      ------ Check amt max
      if (v_amtdemax > 0) then
        if v_codeduct = 'E001' then
          if v_amtdeduct < 10000 then
            v_amtdeduct := 0;
          else
            v_amtdeduct := v_amtdeduct - 10000;
            v_amtdeduct := least(v_amtdeduct,v_amtdemax);
          end if;
        elsif v_codeduct = 'D001' then
          v_amtdeduct := least(v_amtdeduct,10000);
        else
          v_amtdeduct := least(v_amtdeduct,v_amtdemax);
        end if;
      end if;
      ------ Check amt %
      if v_pctdemax > 0 then
        v_pctamt := p_amtsalyr * (v_pctdemax / 100);
        v_amtdeduct := least(v_amtdeduct,v_pctamt);
      end if;
      ------ Check formula ------
      if v_formula is not null then
        if instr(v_formula,'[') > 1 then
          loop
            v_check  := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
            exit when v_check is null;
            if get_deduct(v_check) = 'E' then
              v_formula := replace(v_formula,'['||v_check||']',nvl(evalue_code(substr(v_check,2)),0));
            elsif get_deduct(v_check) = 'D' then
              v_formula := replace(v_formula,'['||v_check||']',nvl(dvalue_code(substr(v_check,2)),0));
            else
              v_formula := replace(v_formula,'['||v_check||']',nvl(ovalue_code(substr(v_check,2)),0));
            end if;
          end loop;
          v_amtdeduct := least(v_amtdeduct,execute_sql('select '||v_formula||' from dual'));
        end if;
      end if;
    end if;
    v_typeded := get_deduct(v_codeduct);
    if v_typeded = 'E' then
      evalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
    elsif v_typeded = 'D' then
      dvalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
    else
      ovalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
    end if;
    --
    return 	nvl(v_amtdeduct,0);
  end;

  function get_deduct(v_codeduct varchar2) return char is
     v_type varchar2(1);
  begin
     select typdeduct
       into v_type
       from tcodeduct
      where coddeduct = v_codeduct;
     return (v_type);
  exception when others then
     return ('D');
  end;

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_typemp            := upper(hcm_util.get_string_t(json_obj, 'p_typemp'));
    p_staemp            := upper(hcm_util.get_string_t(json_obj, 'p_staemp'));

    -- detail
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_count       number;
    v_flgsecu   	boolean;
    v_codempid    temploy1.codempid%type;
    v_codcodec    tcodcatg.codcodec%type;
  begin
  	if p_codempid is not null then
      begin
        select codempid into v_codempid
        from   temploy1
        where  codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
        return;
      end;
      --
      v_flgsecu := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if not v_flgsecu  then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    else
      begin
        select count(*) into v_count
        from   tcenter
        where  codcomp like p_codcomp||'%' ;
      exception when no_data_found then
        v_count := 0;
      end;
      --
      if nvl(v_count,0) = 0 then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
      end if;
      --
      v_flgsecu := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      --
      if p_typemp is not null then
        begin
          select codcodec into v_codcodec
            from tcodcatg
           where codcodec = p_typemp;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodcatg');
          return;
        end;
      end if;
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index (json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_flgdata           varchar2(100 char) := 'N';
    v_flg_secure        boolean := false;
    v_flg_permission    boolean := false;
    v_rcnt              number  := 0;
    cursor c1 is
      select codempid, codpos, codcomp from temploy1
       where codcomp  like p_codcomp||'%'
         and codempid like p_codempid||'%'
         and typemp = nvl(p_typemp,typemp)
         and staemp = decode(p_staemp,'A',staemp,nvl(p_staemp,staemp))
         and exists (select t2.codempid from ttaxmasl t2
                          where temploy1.codempid  = t2.codempid
                            and t2.dteyrepay = (p_dteyrepay - global_v_zyear)
                            and t2.dtemthpay =  p_dtemthpay
                            and t2.numperiod =  p_numperiod);
  begin
    obj_row       := json_object_t();
    --
    for r1 in c1 loop
      v_flgdata   := 'Y';
      exit;
    end loop;
    --
    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,global_v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt   := v_rcnt + 1;
      end if;
    end loop;
    --
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
    obj_data         json_object_t;
    obj_detail_tab1  clob;
    obj_detail_tab2  clob;
    obj_temp  clob;

    TYPE char1 IS TABLE OF varchar(4000 char) INDEX BY BINARY_INTEGER;
    obj_detail_arr	  char1;
    obj_deduct_arr    char1;
  begin
    initial_value (json_str_input);

    if p_codcomp is not null then
      p_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
    else
      begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into p_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        p_codcompy := null;
      end;
    end if;

    -- gen data detail --
    gen_detail_tab1 (obj_detail_tab1);
    gen_detail_tab2 (obj_detail_tab2);
    -- fetch_deductd --
    obj_deduct_arr(1) := 'E';
    obj_deduct_arr(2) := 'D';
    obj_deduct_arr(3) := 'O';
    obj_detail_arr(1) := null;
    obj_detail_arr(2) := null;
    obj_detail_arr(3) := null;

    if param_msg_error is null then
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');

      obj_data.put('detail_tab1', obj_detail_tab1);
      obj_data.put('detail_tab2', obj_detail_tab2);
       for i in 1..3 loop
        p_coddeduct := obj_deduct_arr(i);
        obj_temp := '';
        fetch_deductd (obj_temp);
        obj_data.put('detail_tab'||(i+2), obj_temp);
       end loop;

      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab1 (json_str_output out clob) is
    obj_data          json_object_t;
    v_codempid        temploy1.codempid%type;
    v_codpos          temploy1.codpos%type;
    v_codcomp         temploy1.codcomp%type;
    v_stamarry        temploy1.stamarry%type;
    v_dteempmt        temploy1.dteempmt%type;
    v_dteeffex        temploy1.dteeffex%type;
    --
    v_flgtax          temploy3.flgtax%type;
    v_typtax          temploy3.typtax%type;
    v_numtaxid        temploy3.numtaxid%type;
    --
    v_amtincct        number;
    v_amtexpct        number;
    v_amtproyr        number;
    v_amtsocyr        number;
    v_amtcalet		    number;
    v_amtcalct		    number;
    v_amtgrstxt		    number;
    v_amt					    number;
    --
    v_codempid_desc   varchar2(4000 char);
    v_codpos_desc     varchar2(4000 char);
    v_typtax_desc     varchar2(4000 char);
    v_codcomp_desc    varchar2(4000 char);
    v_stamarry_desc   varchar2(4000 char);
    v_flgtax_desc     varchar2(4000 char);
    --
    v_amttax          number;
    v_amtsalyr        number;
    v_amtcalt         number;
    --
    v_amtincbf        number;
    v_amtincsp        number;
    v_amttaxbf        number;
    v_amttaxsp        number;
    v_amtsaid         number;
    v_amtsasp         number;
    v_amtpf           number;
    v_amtpfsp         number;
  begin
    begin
      select codempid, codpos, codcomp, stamarry, dteempmt, dteeffex
        into v_codempid, v_codpos, v_codcomp, v_stamarry,
             v_dteempmt, v_dteeffex
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codempid := null;
      v_codpos   := null;
      v_codcomp  := null;
      v_stamarry := null;
      v_dteempmt := null;
      v_dteeffex := null;
    end;
    --
    begin
      select flgtax, typtax, numtaxid
        into v_flgtax, v_typtax, v_numtaxid
        from temploy3
       where codempid = v_codempid;
    exception when no_data_found then
      v_flgtax   := null;
      v_typtax   := null;
      v_numtaxid := null;
    end;
    -- for get data --
    v_codempid_desc := get_temploy_name(v_codempid,global_v_lang);
    v_codpos_desc   := get_tpostn_name(v_codpos,global_v_lang);
    v_typtax_desc   := get_tlistval_name('NAMTAXDD',v_typtax,global_v_lang);
    v_codcomp_desc  := get_tcenter_name(v_codcomp,global_v_lang);
    v_stamarry_desc := get_tlistval_name('NAMMARRY',v_stamarry,global_v_lang);
    --
    begin
      select /*nvl(stddec(amtcalt,codempid,v_chken),0) +
             nvl(stddec(amtinclt,codempid,v_chken),0) +
             nvl(stddec(amtincct,codempid,v_chken),0) -
             nvl(stddec(amtexplt,codempid,v_chken),0) -
             nvl(stddec(amtexpct,codempid,v_chken),0),
             nvl(stddec(amttaxt,codempid,v_chken),0),*/
             nvl(stddec(amtproyr,codempid,v_chken),0),
             nvl(stddec(amtsocyr,codempid,v_chken),0),
             nvl(stddec(amtcalet,codempid,v_chken),0),
             nvl(stddec(amtcalct,codempid,v_chken),0),
             nvl(stddec(amtgrstxt,codempid,v_chken),0)
        into /*v_amtincct,
             v_amtexpct,*/
             v_amtproyr,
             v_amtsocyr,
             v_amtcalet,
             v_amtcalct,
             v_amtgrstxt
        from ttaxmas
       where codempid = v_codempid
         and dteyrepay = (p_dteyrepay - global_v_zyear);
    exception when no_data_found then
      /*v_amtincct  := 0;
      v_amtexpct  := 0; */
      v_amtproyr  := 0;
      v_amtsocyr  := 0;
      v_amtcalet  := 0;
      v_amtcalct  := 0;
      v_amtgrstxt := 0;
    end;
    --
    begin
      select sum(nvl(stddec(amtcal,codempid,v_chken),0)) +
             sum(nvl(stddec(amtincl,codempid,v_chken),0)) +
             sum(nvl(stddec(amtincc,codempid,v_chken),0)) -
             sum(nvl(stddec(amtexpl,codempid,v_chken),0)) -
             sum(nvl(stddec(amtexpc,codempid,v_chken),0)),
             sum(nvl(stddec(amttax,codempid,v_chken),0))+
             sum(nvl(stddec(amttaxoth,codempid,v_chken),0))
        into v_amtincct,v_amtexpct
        from ttaxcur
       where codempid    = p_codempid
         and dteyrepay   = (p_dteyrepay - global_v_zyear)
         and ((dtemthpay = p_dtemthpay
         and numperiod  <= p_numperiod)
          or dtemthpay  <  p_dtemthpay);
    exception when no_data_found then
      v_amtincct  := 0;
      v_amtexpct  := 0;
    end;
    --
    begin
      select nvl(stddec(a.amttax,codempid,v_chken),0),
             nvl(stddec(a.amtsalyr,codempid,v_chken),0),
             nvl(stddec(a.amttaxyr,codempid,v_chken),0),flgtax
        into v_amttax,v_amtsalyr,v_amtcalt,v_flgtax
        from ttaxcur a
       where a.codempid  = p_codempid
         and a.dteyrepay = (p_dteyrepay - global_v_zyear)
         and a.dtemthpay = p_dtemthpay
         and a.numperiod = p_numperiod;
    exception when no_data_found then
      v_amttax    := 0;
      v_amtsalyr  := 0;
      v_amtcalt   := 0;
      v_flgtax    := 0;
    end;
    --
    v_flgtax_desc   := get_tlistval_name('NAMTSTAT',v_flgtax,global_v_lang);
    --
    begin
      select nvl(stddec(amtincbf,codempid,v_chken),0),
             nvl(stddec(amtincsp,codempid,v_chken),0),
             nvl(stddec(amttaxbf,codempid,v_chken),0),
             nvl(stddec(amttaxsp,codempid,v_chken),0),
             nvl(stddec(amtsaid,codempid,v_chken),0),
             nvl(stddec(amtsasp,codempid,v_chken),0),
             nvl(stddec(amtpf,codempid,v_chken),0),
             nvl(stddec(amtpfsp,codempid,v_chken),0)
        into v_amtincbf , v_amtincsp ,
             v_amttaxbf , v_amttaxsp ,
             v_amtsaid  , v_amtsasp  ,
             v_amtpf    , v_amtpfsp
        from ttaxmasl
       where codempid  = p_codempid
         and dteyrepay = (p_dteyrepay - global_v_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod;
    exception when no_data_found then
      v_amtincbf := 0;
      v_amtincsp := 0;
      v_amttaxbf := 0;
      v_amttaxsp := 0;
      v_amtsaid  := 0;
      v_amtsasp  := 0;
      v_amtpf		 := 0;
      v_amtpfsp  := 0;
    end;
    -- global_value --
    p_stamarry  := v_stamarry;
    p_typtax    := v_typtax;
    --
    p_amtsalyr  := v_amtsalyr;
    p_amtproyr  := v_amtproyr;
    p_amtsocyr  := v_amtsocyr;
    -- put data to json --
    if param_msg_error is null then
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numtaxid'     , v_numtaxid);
      obj_data.put('desc_codempid', v_codempid_desc);
      obj_data.put('desc_codpos'  , v_codpos_desc);
      obj_data.put('desc_typtax'  , v_typtax_desc);
      obj_data.put('desc_codcomp' , v_codcomp_desc);
      obj_data.put('desc_stamarry', v_stamarry_desc);
      obj_data.put('desc_flgtax'  , v_flgtax_desc);
      --
      if v_dteempmt is not null then
        obj_data.put('dteempmt' , hcm_util.get_date_buddhist_era(v_dteempmt));
      else
        obj_data.put('dteempmt' , '');
      end if;

      if v_dteeffex is not null then
        obj_data.put('dteeffex' , hcm_util.get_date_buddhist_era(v_dteeffex));
      else
        obj_data.put('dteeffex' , '');
      end if;      
      --
      obj_data.put('amtincct' , v_amtincct);
      obj_data.put('amtexpct' , v_amtexpct);
      obj_data.put('amtproyr' , v_amtproyr);
      obj_data.put('amtsocyr' , v_amtsocyr);
      obj_data.put('amtcalet' , v_amtcalet);
      obj_data.put('amtcalct' , v_amtcalct);
      obj_data.put('amtgrstxt', v_amtgrstxt);
      --
      obj_data.put('amttax'   , v_amttax);
      obj_data.put('amtsalyr' , v_amtsalyr);
      obj_data.put('amtcalt'  , v_amtcalt);
      obj_data.put('flgtax'   , v_flgtax);
      --
      obj_data.put('amtincbf' , v_amtincbf);
      obj_data.put('amtincsp' , v_amtincsp);
      obj_data.put('amttaxbf' , v_amttaxbf);
      obj_data.put('amttaxsp' , v_amttaxsp);
      obj_data.put('amtsaid'  , v_amtsaid);
      obj_data.put('amtsasp'  , v_amtsasp);
      obj_data.put('amtpf'    , v_amtpf);
      obj_data.put('amtpfsp'  , v_amtpfsp);
      --report--
        if isInsertReport then
          insert_ttemprpt_detail_tab1(obj_data);
        end if;
      --

      json_str_output := obj_data.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure gen_detail_tab2 (json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_flgdata           varchar2(100 char);
    v_amt               number := 0;
    v_rcnt              number := 0;
    v_numseq            amtnet_array;
    v_desproc           amtnet_array;
    v_amtfml            amtnet_array;
  begin
    obj_row       := json_object_t();
    v_rcnt        := 0;
    v_flgdata     := 'N';
    cal_amtnet (p_amtsalyr,p_amtsalyr,p_amtproyr,p_amtsocyr,v_amt,v_numseq,v_desproc,v_amtfml);
    v_tab_numseq    := 0;
    for r1 in v_numseq.first..v_numseq.last loop
      v_flgdata        := 'Y';
      obj_data         := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', nvl(to_number(v_numseq(r1)),0));
      obj_data.put('desproc', v_desproc(r1));
      obj_data.put('amtfml', nvl(to_number(v_amtfml(r1)),0));

      --report--
        if isInsertReport then
          insert_ttemprpt_detail_tab2(obj_data);
        end if;

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt   := v_rcnt + 1;
    end loop;
    --
    if v_flgdata = 'Y' then

      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure fetch_deductd (json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_flgdata           varchar2(100 char);
    v_flg_secure        boolean := false;
    v_rcnt              number := 0;
    v_year			        number := p_dteyrepay - global_v_zyear;
    cursor c_deduct is
      select codempid, coddeduct, get_tcodeduct_name(coddeduct,global_v_lang) tcodeduct_name,
             nvl(stddec(amtdeduct,codempid,v_chken),0) amtdeduct,
             nvl(stddec(amtspded,codempid,v_chken),0)  amtspded
      from ttaxmasd
      where dteyrepay = v_year
        and codempid = p_codempid
        and substr(coddeduct,1,1) = p_coddeduct
        and dtemthpay = p_dtemthpay
        and numperiod = p_numperiod
      order by coddeduct;
  begin
    obj_row       := json_object_t();
    v_rcnt        := 0;
    v_flgdata     := 'N';
    --
    v_tab_numseq    := 0;
    for r1 in c_deduct loop
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,global_v_zupdsal);
      if v_flg_secure then
        v_flgdata        := 'Y';
        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('coddeduct', r1.coddeduct);
        obj_data.put('desc_coddeduct', r1.tcodeduct_name);
        obj_data.put('amtdeduct', r1.amtdeduct);
        obj_data.put('amtspded', r1.amtspded);

        --report--
        if isInsertReport then
          insert_ttemprpt_detail(obj_data);
        end if;

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt   := v_rcnt + 1;
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end fetch_deductd;

  procedure cal_amtnet (p_amtincom  in number,
                        p_amtsalyr  in number,  -- ?????????????????
                        p_amtproyr	in number,  -- ???????????????????? (??? Estimate)
                        p_amtsocyr  in number,  -- ????????????????????? (??? Estimate)
                        p_amtnet	  out number,
                        p_numseq    out amtnet_array,
                        p_desproc   out amtnet_array,
                        p_amtfml    out amtnet_array) is
    v_formula       varchar2(1000 char);
    v_fmlmax        varchar2(1000 char);
    v_check         varchar2(100 char);
    v_maxseq        number(3);
    v_chknum        number(20);
    v_amt           number;
    v_stmt          varchar2(2000 char);
    v_row           number := 0;
    cursor c_proctax is
        select numseq,formula,fmlmax,fmlmaxtot,desproce,desproct,desproc3,desproc4,desproc5
          from tproctax
         where dteyreff = (select max(dteyreff)
                             from tproctax
                            where dteyreff <= p_dteyrepay - global_v_zyear)
               and codcompy = p_codcompy
      order by numseq;
  begin
    p_amtnet := p_amtincom;
    for r_proctax in c_proctax loop
      v_row := v_row + 1;
      if r_proctax.numseq = 1 then  ------- 1. ????????????????????????????????
        v_formula := to_char(p_amtincom);
      else
        if r_proctax.formula is not null then
            v_formula := r_proctax.formula;
            v_amt := 0;
            if instr(v_formula,'[') > 0 then
                loop 	--- ??????????? ????????? ???????????????????/???????
                    v_check := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
                    exit when v_check is null;
                    if v_check in ('E001','D001') then --- ????????????????????????????
                        v_amt := v_amt + gtempded(p_codempid,v_check,'1',p_amtproyr,p_amtsalyr);
                    elsif v_check = 'D002' then --- ?????????????????????????
                        v_amt := v_amt + gtempded(p_codempid,v_check,'1',p_amtsocyr,p_amtsalyr);
                    else
                        v_amt := v_amt + gtempded(p_codempid,v_check,'1',0,p_amtsalyr);
                        if p_stamarry = 'M' and p_typtax = '2' then
                            v_amt := v_amt + gtempded(p_codempid,v_check,'2',0,p_amtsalyr);
                        end if;
                    end if;
                    v_formula := replace(v_formula,'['||v_check||']',v_amt);
                end loop;
                v_formula := to_char(v_amt);
                end if;
                if instr(v_formula,'}') > 1 then
                    loop --- ??????????? ????????? ????????? seq
                        v_check := substr(v_formula,instr(v_formula,'{') +5,(instr(v_formula,'}') -1) - instr(v_formula,'{')-4);
                        exit when v_check is null;
                        v_formula := replace(v_formula,'{item'||v_check||'}',v_text(v_check));
                    end loop;
                end if;
                ---- Check ????????? ???????? ??????
                if v_formula <> '0' then
                    if p_typtax = '1' then -- ???????????
                        v_fmlmax := r_proctax.fmlmax;
                    else
                        v_fmlmax := r_proctax.fmlmaxtot;
                    end if;
                    if v_fmlmax is not null then
                        v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
                        begin
                            v_chknum := nvl(to_number(v_fmlmax),0); --????????????????
                            if v_chknum > 0 then
                                v_formula := to_char(least(v_amt,v_chknum));
                            end if;
                        exception when others then
                            if instr(v_fmlmax,'[') > 0 then
                                loop  --- ??????????? ????????? ????????? codededuct
                                    v_check  := substr(v_fmlmax,instr(v_fmlmax,'[') +1,(instr(v_fmlmax,']') -1) - instr(v_fmlmax,'['));
                                    exit when v_check is null;
                                    if get_deduct(v_check) = 'E' then
                                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(evalue_code(substr(v_check,2)),0));
                                    elsif get_deduct(v_check) = 'D' then
                                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(dvalue_code(substr(v_check,2)),0));
                                    else
                                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(ovalue_code(substr(v_check,2)),0));
                                    end if;
                                end loop;
                            end if;
                            if instr(v_fmlmax,'{') > 0 then
                                loop --- ??????????? ????????? ????????? SEQ
                                    v_check := substr(v_fmlmax,instr(v_fmlmax,'{') +5,(instr(v_fmlmax,'}') -1) - instr(v_fmlmax,'{')-4);
                                    exit when v_check is null;
                                    v_fmlmax := replace(v_fmlmax,'{item'||v_check||'}',v_text(v_check));
                                end loop;
                            end if;
                            v_chknum := execute_sql('select '||v_fmlmax||' from dual');
                            v_formula := to_char(least(v_amt,v_chknum));
                        end;
                        if r_proctax.numseq = 4 then
                            v_amtexp := to_number(v_formula);
                            v_maxexp := v_chknum;
                        end if;
                    end if;
                end if;
            end if;
        end if;--- end if of 1. ????????????????????????????????
        v_text(r_proctax.numseq) := '('||v_formula||')';
        v_maxseq := r_proctax.numseq;
        v_amt := execute_sql('select '||v_text(r_proctax.numseq)||' from dual');
      --
	  	p_numseq(v_row) := r_proctax.numseq;
        if global_v_lang = '101' then
            p_desproc(v_row) := r_proctax.desproce;
        elsif global_v_lang = '102' then
            p_desproc(v_row) := r_proctax.desproct;
        elsif global_v_lang = '103' then
            p_desproc(v_row) := r_proctax.desproc3;
        elsif global_v_lang = '104' then
            p_desproc(v_row) := r_proctax.desproc4;
        elsif global_v_lang = '105' then
            p_desproc(v_row) := r_proctax.desproc5;
        end if;
        p_amtfml(v_row) := nvl(v_amt,0);
    end loop;
    --
    if v_maxseq is not null then
        v_stmt := v_text(v_maxseq);
        p_amtnet := execute_sql('select '||v_stmt||' from dual');
    else
        p_amtnet := 0;
    end if;
    v_amtdiff := p_amtincom - p_amtnet;
    if nvl(v_row,0) < 1 then
        p_numseq(1)  := null;
        p_desproc(1) := null;
        p_amtfml(1)  := null;
    end if;
  end cal_amtnet;

  ----- Specific Report ------
  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
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
        p_codempid        := upper(hcm_util.get_string_t(p_index_rows, 'codempid'));

          begin
            select hcm_util.get_codcomp_level(codcomp,1)
              into p_codcompy
              from temploy1
             where codempid = p_codempid;
          exception when no_data_found then
            p_codcompy := null;
          end;

        p_codapp := 'HRPY5HX1';
        gen_detail_tab1(json_output);
        p_codapp := 'HRPY5HX2';
        gen_detail_tab2(json_output);
        p_codapp := 'HRPY5HX3';
        p_coddeduct := 'E';
        fetch_deductd(json_output);
        p_codapp := 'HRPY5HX4';
        p_coddeduct := 'D';
        fetch_deductd(json_output);
        p_codapp := 'HRPY5HX5';
        p_coddeduct := 'O';
        fetch_deductd(json_output);
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

  procedure insert_ttemprpt_detail_tab1(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dteempmt          date;
    v_dteempmt_         varchar2(100 char) := '';
    v_dteeffex          date;
    v_dteeffex_         varchar2(100 char) := '';
    v_item1 varchar2(1000 char);
    v_item2 varchar2(1000 char);
    v_item3 varchar2(1000 char);
    v_item6 varchar2(1000 char);
    v_item7 varchar2(1000 char);
    v_item8 varchar2(1000 char);
    v_item9 varchar2(1000 char);
    v_item10 varchar2(1000 char);
    v_item11 varchar2(1000 char);
    v_item12 varchar2(1000 char);
    v_item13 varchar2(1000 char);
    v_item14 varchar2(1000 char);
    v_item15 varchar2(1000 char);
    v_item16 varchar2(1000 char);
    v_item17 varchar2(1000 char);
    v_item18 varchar2(1000 char);
    v_item19 varchar2(1000 char);
    v_item20 varchar2(1000 char);
    v_item21 varchar2(1000 char);
    v_item22 varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq     := v_numseq + 1;
    v_year       := hcm_appsettings.get_additional_year;
    v_dteempmt   := to_date(hcm_util.get_string_t(obj_data, 'dteempmt'), 'DD/MM/YYYY');
    v_dteempmt_  := to_char(v_dteempmt, 'DD/MM/YYYY');
    v_dteeffex   := to_date(hcm_util.get_string_t(obj_data, 'dteeffex'), 'DD/MM/YYYY');
    v_dteeffex_  := to_char(v_dteeffex, 'DD/MM/YYYY');
    v_item1 := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), ' ');
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), ' ');
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp'), ' ');

    v_item6  := nvl(hcm_util.get_string_t(obj_data, 'numtaxid'), ' ');
    v_item7 := nvl(hcm_util.get_string_t(obj_data, 'desc_flgtax'), ' ');
    v_item8 := nvl(hcm_util.get_string_t(obj_data, 'desc_typtax'), ' ');
    v_item9 := nvl(hcm_util.get_string_t(obj_data, 'desc_stamarry'), ' ');
    v_item10 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtincct'),'FM9,999,999,990.00'), ' ');
    v_item11 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtexpct'),'FM9,999,999,990.00'), ' ');
    v_item12 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtsalyr'),'FM9,999,999,990.00'), ' ');
    v_item13 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtcalt'),'FM9,999,999,990.00'), ' ');
    v_item14 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amttax'),'FM9,999,999,990.00'), ' ');
    v_item15 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtincbf'),'FM9,999,999,990.00'), ' ');
    v_item16 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtincsp'),'FM9,999,999,990.00'), ' ');
    v_item17 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amttaxbf'),'FM9,999,999,990.00'), ' ');
    v_item18 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amttaxsp'),'FM9,999,999,990.00'), ' ');
    v_item19 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtsaid'),'FM9,999,999,990.00'), ' ');
    v_item20 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtsasp'),'FM9,999,999,990.00'), ' ');
    v_item21 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtpf'),'FM9,999,999,990.00'), ' ');
    v_item22 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtpfsp'),'FM9,999,999,990.00'), ' ');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11,
             item12, item13, item14, item15, item16, item17, item18, item19, item20, item21, item22,item23
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             v_item1,
             v_item2,
             v_item3,
             v_dteempmt_,
             v_dteeffex_,          
             v_item6,
             v_item7,
             v_item8,
             v_item9,
             v_item10,
             v_item11,
             v_item12,
             v_item13,
             v_item14,
             v_item15,
             v_item16,
             v_item17,
             v_item18,
             v_item19,
             v_item20,
             v_item21,
             v_item22,
             p_codempid
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_detail_tab1;

  procedure insert_ttemprpt_detail_tab2(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_item1 varchar2(1000 char);
    v_item2 varchar2(1000 char);
    v_item3 varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq        := v_numseq + 1;
    v_tab_numseq    := v_tab_numseq +1;
    v_item1 := nvl(hcm_util.get_string_t(obj_data, 'numseq'), ' ');
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'desproc'), ' ');
    v_item3 := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtfml'),'FM9,999,999,990.00'), ' ');

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3,item5,item6
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             v_item1,
             v_item2,
             v_item3,
             p_codempid,
             v_tab_numseq
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_detail_tab2;

 procedure insert_ttemprpt_detail(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_flgchol           varchar2(100 char);
    v_desc_codpay       varchar2(1000 char);
    v_item1       varchar2(1000 char);
    v_item2       varchar2(1000 char);
    v_item3       varchar2(1000 char);
    v_item4       varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq        := v_numseq + 1;
    v_tab_numseq    := v_tab_numseq + 1;
    v_item1         := nvl(hcm_util.get_string_t(obj_data, 'coddeduct'), ' ');
    v_item2         := nvl(hcm_util.get_string_t(obj_data, 'desc_coddeduct'), ' ');
    v_item3         := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtdeduct'),'FM9,999,999,990.00'), ' ');
    v_item4         := nvl(to_char(hcm_util.get_string_t(obj_data, 'amtspded'),'FM9,999,999,990.00'), ' ');

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4,item5, item6
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             v_item1,
             v_item2,
             v_item3,
             v_item4,
             p_codempid,
             v_tab_numseq
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_detail;

end HRPY5HX;

/
