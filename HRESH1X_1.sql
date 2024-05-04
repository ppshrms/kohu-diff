--------------------------------------------------------
--  DDL for Package Body HRESH1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRESH1X" is
  procedure initial_value(json_clob in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_clob);
    --global
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    --block b_index
    b_index_dtestrt     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtestrt')),'dd/mm/yyyy');
    b_index_dteend      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteend')),'dd/mm/yyyy');

    b_index_dteeffec    := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteeffec')),'dd/mm/yyyy');
    b_index_codpunsh    := hcm_util.get_string_t(json_obj,'p_codpunsh');

    begin
      select codcomp, codempmt
        into b_index_codcomp, b_index_codempmt
        from temploy1
       where codempid = global_v_codempid;
     exception when no_data_found then
      null;
    end;
  end initial_value;
  --
  function gen_index return clob is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    v_ocodempid       varchar2(100 char);
    json_str_output   clob;
    v_exist           boolean := false;

    cursor c1 is
      select a.dteeffec,a.codpunsh,a.codempid,a.numseq,b.dtemistk,
             a.typpun,a.dtestart,a.dteend,a.remark,b.codmist
        from thispun a,thismist b
       where (a.codempid = global_v_codempid or v_ocodempid like '[%'||a.codempid||']%' )
         and trunc(nvl(b.dtemistk,sysdate)) between nvl(b_index_dtestrt,trunc(nvl(b.dtemistk,sysdate))) and nvl(b_index_dteend,trunc(nvl(b.dtemistk,sysdate)))
         and a.codempid  = b.codempid
         and a.dteeffec  = b.dteeffec
      order by b.dtemistk,a.codpunsh;
   begin
    v_ocodempid :=  get_ocodempid(global_v_codempid);
    obj_row  := json_object_t();
    for i in c1 loop
      v_exist   := true;
      obj_data  := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codempid',i.codempid);
      obj_data.put('numseq',i.numseq);
      obj_data.put('dtemistk',to_char(i.dtemistk,'dd/mm/yyyy'));
      obj_data.put('codmist',i.codmist);
      obj_data.put('desc_codmist',get_tcodec_name('TCODMIST',i.codmist,global_v_lang));
      obj_data.put('codpunsh',i.codpunsh);
      obj_data.put('desc_codpunsh',get_tcodec_name('TCODPUNH',i.codpunsh,global_v_lang));
      obj_data.put('typpun',i.typpun);
      obj_data.put('desc_typpun',get_tlistval_name('NAMTPUN',i.typpun,global_v_lang));
      obj_data.put('dtestart',to_char(i.dtestart,'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
      obj_data.put('remark',i.remark);

      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt := v_rcnt + 1;
    end loop;

    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTMISTK');
      return get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;

    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function get_index(json_clob in clob) return clob is
    json_str_output     clob;
  begin
    initial_value(json_clob);
    if param_msg_error is null then
      json_str_output    := gen_index;
    end if;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function hresh1x_detail_tab1(json_clob in clob) return clob is
    obj_data        json_object_t;
    v_folder        varchar2(4000 char);
    v_path_filename varchar2(4000 char);
    rec_ttmistk     thismist%rowtype;
  begin
    initial_value(json_clob);
    begin
      select * into rec_ttmistk
        from thismist
       where codempid = global_v_codempid
         and dteeffec = b_index_dteeffec;
    exception when no_data_found then
      rec_ttmistk := null;
    end;
    begin
      select value||'/document'
        into v_folder
        from tsetup
       where codvalue = 'PATHWEB';
    exception when no_data_found then
      null;
    end;
    obj_data  := json_object_t();
    if rec_ttmistk.refdoc is not null and v_folder is not null then
      v_path_filename := v_folder||'/'||rec_ttmistk.refdoc;
    else
      v_path_filename := '';
    end if;
    obj_data.put('coderror','200');
    obj_data.put('numhmref',rec_ttmistk.numhmref);
    obj_data.put('dtemistk',to_char(rec_ttmistk.dtemistk,'dd/mm/yyyy'));
    obj_data.put('filename',rec_ttmistk.refdoc);
    obj_data.put('desmist1',rec_ttmistk.desmist1);
    obj_data.put('codmist',rec_ttmistk.codmist);
    obj_data.put('descmist',get_tcodec_name('TCODMIST',rec_ttmistk.codmist,global_v_lang));
    obj_data.put('path_filename',v_path_filename);
    return obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hresh1x_detail_tab1;

  function hresh1x_detail_tab2(json_clob in clob) return clob is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;

    v_out_objrow		json_object_t;
		v_out_amtdoth		number;
		v_out_sum_in_period	number;
		v_out_sum_period	number;

		v_out_dteyearst		ttpunded.dteyearst%type;
		v_out_dtemthst		ttpunded.dtemthst%type;
		v_out_numprdst		ttpunded.numprdst%type;
		v_out_dteyearen		ttpunded.dteyearen%type;
		v_out_dtemthen		ttpunded.dtemthen%type;
		v_out_numprden		ttpunded.numprden%type;
		v_out_codempid		ttpunded.codempid%type;
		v_out_dteeffec		ttpunded.dteeffec%type;
		v_out_codpunsh		ttpunded.codpunsh%type;
		v_out_codpay		  ttpunded.codpay%type;
		v_out_amtded		  ttpunded.amtded%type;
		v_out_amttotded		ttpunded.amttotded%type;
		v_out_mode_ttpunded	varchar2(10 char);
    cursor c1 is
      select to_char(numseq)
                item5,
             codpunsh
                item6,
             get_tcodec_name('TCODPUNH',codpunsh,global_v_lang)
                item7,
             typpun
                item8,
             get_tlistval_name('NAMTPUN',typpun,global_v_lang)
                item9,
             to_char(dtestart,'dd/mm/yyyy')
                item10,
             to_char(dteend,'dd/mm/yyyy')
                item11,
             remark
                item12,
             flgexempt
                item13,
             codexemp
                item14,
             get_tcodec_name('TCODEXEM',codexemp,global_v_lang)
                item15,
             flgblist
                item16,
             coduser
                item17,
             to_char(dteupd,'dd/mm/yyyy')
                item18,
             get_codempid(coduser)
                item19,
             flgssm
        from thispun
       where codempid = global_v_codempid
         and dteeffec = b_index_dteeffec
         and codpunsh = b_index_codpunsh;
  begin
    initial_value(json_clob);

    obj_row := json_object_t();

    if param_msg_error is null then
      for i in c1 loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror',' ');
        obj_data.put('httpcode',' ');
        obj_data.put('flg',' ');
        obj_data.put('numseq',i.item5);
        obj_data.put('codpunsh',i.item6);
        obj_data.put('desc_codpunsh',i.item7);
        obj_data.put('typpun',i.item8);
        obj_data.put('desc_typpun',i.item9);
        obj_data.put('dtestart',i.item10);
        obj_data.put('dteend',i.item11);
        obj_data.put('remark',i.item12);
        obj_data.put('flgexempt',i.item13);
        obj_data.put('codexemp',i.item14);
        obj_data.put('desc_codexemp',i.item15);
        obj_data.put('flgblist',i.item16);
        obj_data.put('coduser',i.item17);
        obj_data.put('dteupd',i.item18);
        obj_data.put('empupd',i.item19);
        obj_data.put('flgssm',get_tlistval_name('FLGSSM',i.flgssm,global_v_lang));
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;
      end loop;
    else
      return get_response_message(null,param_msg_error,global_v_lang);
    end if;
    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hresh1x_detail_tab2;

  function hresh1x_detail_tab3(json_clob in clob) return clob is
    obj_data          json_object_t;
    v_codcomp     temploy1.codcomp%type;
    v_codempmt    temploy1.codempmt%type;

    v_out_objrow		json_object_t;
		v_out_amtdoth		number;
		v_out_sum_in_period	number;
		v_out_sum_period	number;

		v_out_dteyearst		ttpunded.dteyearst%type;
		v_out_dtemthst		ttpunded.dtemthst%type;
		v_out_numprdst		ttpunded.numprdst%type;
		v_out_dteyearen		ttpunded.dteyearen%type;
		v_out_dtemthen		ttpunded.dtemthen%type;
		v_out_numprden		ttpunded.numprden%type;
		v_out_codempid		ttpunded.codempid%type;
		v_out_dteeffec		ttpunded.dteeffec%type;
		v_out_codpunsh		ttpunded.codpunsh%type;
		v_out_codpay		  ttpunded.codpay%type;
		v_out_amtded		  ttpunded.amtded%type;
		v_out_amttotded		ttpunded.amttotded%type;
		v_out_mode_ttpunded	varchar2(10 char);

    cursor c1 is
      select to_char(numprdst)
                item5,
             get_nammthful(dtemthst,global_v_lang)
                item6,
             to_char(dteyearst)
                item7,
             to_char(numprden)
                item8,
             get_nammthful(dtemthen,global_v_lang)
                item9,
             to_char(dteyearen)
                item10,
             codpay
                item11,
             get_tinexinf_name(codpay,global_v_lang)
                item12,
             get_codempid(coduser) as codempupd,
             coduser,
             dteupd
        from thispund--ttpunded
       where codempid = global_v_codempid
         and dteeffec = b_index_dteeffec
         and codpunsh = b_index_codpunsh;

    --<<User37 #5064 4.ES.MS Module 30/04/2021 
    cursor c2 is
      select to_char(dteupd,'dd/mm/yyyy') dteupd,
             get_temploy_name(get_codempid(coduser),global_v_lang) coduser
        from thispun
       where codempid = global_v_codempid
         and dteeffec = b_index_dteeffec
         and codpunsh = b_index_codpunsh;
    -->>User37 #5064 4.ES.MS Module 30/04/2021 
  begin
    initial_value(json_clob);
    begin
      select codcomp,codempmt
        into v_codcomp,v_codempmt
        from temploy1
       where codempid = global_v_codempid;
    exception when no_data_found then
      v_codcomp   := null;
      v_codempmt  := null;
    end;
    v_codcomp   := hcm_util.get_codcomp_level(v_codcomp,1);
    hrpm4ge.getamtincom ( global_v_codempid , b_index_dteeffec , v_codcomp, v_codempmt, b_index_codpunsh,
                          global_v_lang, v_chken, v_out_objrow, v_out_amtdoth, v_out_sum_in_period,
                          v_out_sum_period, v_out_dteyearst, v_out_dtemthst, v_out_numprdst,
                          v_out_dteyearen, v_out_dtemthen, v_out_numprden, v_out_codempid,
                          v_out_dteeffec, v_out_codpunsh, v_out_codpay, v_out_amtded, v_out_amttotded, v_out_mode_ttpunded );
    obj_data := json_object_t();
    if param_msg_error is null then
      for i in c1 loop
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror',' ');
        obj_data.put('httpcode',' ');
        obj_data.put('flg',' ');
        obj_data.put('numprdst',i.item5);
        obj_data.put('dtemthst',i.item6);
        obj_data.put('dteyearst',i.item7);
        obj_data.put('numprden',i.item8);
        obj_data.put('dtemthen',i.item9);
        obj_data.put('dteyearen',i.item10);
        obj_data.put('codpay',i.item11);
        obj_data.put('desc_codpay',i.item12);
        obj_data.put('suminperiod',v_out_sum_in_period);
        obj_data.put('sumperiod',v_out_sum_period);
        obj_data.put('codempupd',i.codempupd);
        --<<User37 #5064 4.ES.MS Module 30/04/2021 
        --obj_data.put('coduser',get_temploy_name(i.codempupd,global_v_lang));
        --obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
        -->>User37 #5064 4.ES.MS Module 30/04/2021 
      end loop;
      --<<User37 #5064 4.ES.MS Module 30/04/2021 
      for i in c2 loop
        obj_data.put('coduser',i.coduser);
        obj_data.put('dteupd',i.dteupd);
      end loop;
      -->>User37 #5064 4.ES.MS Module 30/04/2021 
    else
      return get_response_message(null,param_msg_error,global_v_lang);
    end if;
    return obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;

  function get_amt_func(p_amt in varchar2) return varchar2 is
    v_amt   varchar2(4000 char);
  begin
    v_amt := to_char(stddec(p_amt,global_v_codempid,v_chken),'fm99,999,990.00');

--    return web_service.essenc(v_amt); ##################################
    return v_amt;
  end;

  function get_amt_percentage(p_amtincom in varchar2, p_amtincded in varchar2) return varchar2 is
    v_amtincded   varchar2(4000 char);
    v_amtincom    varchar2(4000 char);
    v_amt_percent varchar2(4000 char);
  begin
    v_amtincded := stddec(p_amtincded,global_v_codempid,v_chken);
    v_amtincom  := stddec(p_amtincom,global_v_codempid,v_chken);
    if v_amtincom = 0 or v_amtincded = 0 then
      v_amt_percent := 0;
    else
      v_amt_percent := v_amtincded / v_amtincom * 100;
    end if;
    v_amt_percent := to_char(v_amt_percent,'fm99,999,990.00');

--    return web_service.essenc(v_amt_percent); ######################################
    return v_amt_percent;
  end;

  function hresh1x_detail_tab3_table(json_clob in clob) return clob is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_numseq      number := 0;
    v_item5       varchar2(4000 char);
    v_item6       varchar2(4000 char);
    v_item7       varchar2(4000 char);
    v_item8       varchar2(4000 char);
    v_item9       varchar2(4000 char);
    v_item10      varchar2(4000 char);
    v_details     varchar2(4000 char);
    v_codcomp     temploy1.codcomp%type;
    v_codempmt    temploy1.codempmt%type;

    v_out_objrow		json_object_t;
		v_out_amtdoth		number;
		v_out_sum_in_period	number;
		v_out_sum_period	number;

		v_out_dteyearst		ttpunded.dteyearst%type;
		v_out_dtemthst		ttpunded.dtemthst%type;
		v_out_numprdst		ttpunded.numprdst%type;
		v_out_dteyearen		ttpunded.dteyearen%type;
		v_out_dtemthen		ttpunded.dtemthen%type;
		v_out_numprden		ttpunded.numprden%type;
		v_out_codempid		ttpunded.codempid%type;
		v_out_dteeffec		ttpunded.dteeffec%type;
		v_out_codpunsh		ttpunded.codpunsh%type;
		v_out_codpay		  ttpunded.codpay%type;
		v_out_amtded		  ttpunded.amtded%type;
		v_out_amttotded		ttpunded.amttotded%type;
		v_out_mode_ttpunded	varchar2(10 char);
    type arr is table of varchar2(4000 char) index by binary_integer;
      v_code	  arr;
      v_unit    arr;

    cursor c1 is
      select get_amt_func(amtincom1)  item8_1,
             get_amt_func(amtincom2)  item8_2,
             get_amt_func(amtincom3)  item8_3,
             get_amt_func(amtincom4)  item8_4,
             get_amt_func(amtincom5)  item8_5,
             get_amt_func(amtincom6)  item8_6,
             get_amt_func(amtincom7)  item8_7,
             get_amt_func(amtincom8)  item8_8,
             get_amt_func(amtincom9)  item8_9,
             get_amt_func(amtincom10) item8_10,
             get_amt_percentage(amtincom1, amtincded1) item9_1,
             get_amt_percentage(amtincom2, amtincded2) item9_2,
             get_amt_percentage(amtincom3, amtincded3) item9_3,
             get_amt_percentage(amtincom4, amtincded4) item9_4,
             get_amt_percentage(amtincom5, amtincded5) item9_5,
             get_amt_percentage(amtincom6, amtincded6) item9_6,
             get_amt_percentage(amtincom7, amtincded7) item9_7,
             get_amt_percentage(amtincom8, amtincded8) item9_8,
             get_amt_percentage(amtincom9, amtincded9) item9_9,
             get_amt_percentage(amtincom10,amtincded10) item9_10,
             get_amt_func(amtincded1) item10_1,
             get_amt_func(amtincded2) item10_2,
             get_amt_func(amtincded3) item10_3,
             get_amt_func(amtincded4) item10_4,
             get_amt_func(amtincded5) item10_5,
             get_amt_func(amtincded6) item10_6,
             get_amt_func(amtincded7) item10_7,
             get_amt_func(amtincded8) item10_8,
             get_amt_func(amtincded9) item10_9,
             get_amt_func(amtincded10) item10_10,
             get_nammthful(dtemthen,global_v_lang) item9,
             get_amt_func(amtded) item11,
             get_amt_func(amttotded) item12
        from thispund
       where codempid = global_v_codempid
         and dteeffec = b_index_dteeffec
         and codpunsh = b_index_codpunsh;
  begin
    initial_value(json_clob);
    obj_row := json_object_t();
    begin
      select codcomp,codempmt
        into v_codcomp,v_codempmt
        from temploy1
       where codempid = global_v_codempid;
    exception when no_data_found then
      v_codcomp   := null;
      v_codempmt  := null;
    end;
    v_codcomp   := hcm_util.get_codcomp_level(v_codcomp,1);
    hrpm4ge.getamtincom ( global_v_codempid , b_index_dteeffec , v_codcomp, v_codempmt, b_index_codpunsh,
                          global_v_lang, v_chken, v_out_objrow, v_out_amtdoth, v_out_sum_in_period,
                          v_out_sum_period, v_out_dteyearst, v_out_dtemthst, v_out_numprdst,
                          v_out_dteyearen, v_out_dtemthen, v_out_numprden, v_out_codempid,
                          v_out_dteeffec, v_out_codpunsh, v_out_codpay, v_out_amtded, v_out_amttotded, v_out_mode_ttpunded );
    select count(*)
      into v_rcnt
      from thispund
     where codempid = global_v_codempid
       and dteeffec = b_index_dteeffec
       and codpunsh = b_index_codpunsh;

    if v_rcnt > 0 then
      for i in 1..10 loop
        v_code(i)   :=  '';
        v_unit(i)   :=  '';
      end loop;
      hcm_util.get_cod_income(hcm_util.get_codcomp_level(b_index_codcomp,'1'),b_index_codempmt,
                              v_code(1), v_code(2), v_code(3), v_code(4), v_code(5),
                              v_code(6), v_code(7), v_code(8), v_code(9), v_code(10),
                              v_unit(1), v_unit(2), v_unit(3), v_unit(4), v_unit(5),
                              v_unit(6), v_unit(7), v_unit(8), v_unit(9), v_unit(10));
      v_numseq := 0;
      for i in c1 loop
        for numrow in 1..10 loop
          hcm_util.get_income(global_v_lang, v_code(numrow),v_details);
          v_item5   := to_char(v_code(numrow));
          v_item6   := to_char(v_details);
          v_item7   := get_tlistval_name('NAMEUNIT',v_unit(numrow),global_v_lang);

          if v_item5 is not null then
            if    numrow = 1 then
              v_item8   := i.item8_1;
              v_item9   := i.item9_1;
              v_item10  := i.item10_1;
            elsif numrow = 2 then
              v_item8   := i.item8_2;
              v_item9   := i.item9_2;
              v_item10  := i.item10_2;
            elsif numrow = 3 then
              v_item8   := i.item8_3;
              v_item9   := i.item9_3;
              v_item10  := i.item10_3;
            elsif numrow = 4 then
              v_item8   := i.item8_4;
              v_item9   := i.item9_4;
              v_item10  := i.item10_4;
            elsif numrow = 5 then
              v_item8   := i.item8_5;
              v_item9   := i.item9_5;
              v_item10  := i.item10_5;
            elsif numrow = 6 then
              v_item8   := i.item8_6;
              v_item9   := i.item9_6;
              v_item10  := i.item10_6;
            elsif numrow = 7 then
              v_item8   := i.item8_7;
              v_item9   := i.item9_7;
              v_item10  := i.item10_7;
            elsif numrow = 8 then
              v_item8   := i.item8_8;
              v_item9   := i.item9_8;
              v_item10  := i.item10_8;
            elsif numrow = 9 then
              v_item8   := i.item8_9;
              v_item9   := i.item9_9;
              v_item10  := i.item10_9;
            elsif numrow = 10 then
              v_item8   := i.item8_10;
              v_item9   := i.item9_10;
              v_item10  := i.item10_10;
            end if;

            v_numseq := v_numseq + 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('desc_coderror',' ');
            obj_data.put('httpcode',' ');
            obj_data.put('flg',' ');
            obj_data.put('total',to_char(numrow));
            obj_data.put('no',to_char(numrow));
            obj_data.put('code',v_item5);
            obj_data.put('detail',v_item6);
            obj_data.put('unit',v_item7);
            obj_data.put('amt',v_item8);
            obj_data.put('adjp',v_item9);
            obj_data.put('amtcded',v_item10);
            obj_data.put('amtded',i.item11);
            obj_data.put('amttotded',i.item12);

            obj_row.put(to_char(v_numseq-1),obj_data);
          end if; --v_item5 is not null
        end loop; --numrow
      end loop; --c1
    end if; --v_rcnt
--    return obj_row.to_clob;
    return v_out_objrow.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
