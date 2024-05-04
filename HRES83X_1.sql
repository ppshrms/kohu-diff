--------------------------------------------------------
--  DDL for Package Body HRES83X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES83X" is
-- last update: 26/07/2016 11:58


  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    p_mode              := hcm_util.get_string_t(json_obj,'p_mode');
    p_start             := to_number(hcm_util.get_string_t(json_obj,'p_start'));
    p_end               := to_number(hcm_util.get_string_t(json_obj,'p_end'));
    p_limit             := to_number(hcm_util.get_string_t(json_obj,'p_limit'));

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_sdate             := hcm_util.get_string_t(json_obj,'p_sdate');
    b_amtintaccu        := hcm_util.get_string_t(json_obj,'p_amtintaccu');


  end initial_value;
  --
  procedure get_index_table1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_table1(json_str_output);
    else
      obj_row := json_object_t();
      obj_row.put('coderror','400');
      obj_row.put('desc_coderror',param_msg_error);
      json_str_output := obj_row.to_clob;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_table1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_pathweb       varchar2(4000 char);
    amtprove_sum1    number :=0;
    amtprovc_sum2    number :=0;
    amtprovc_amtprovc_sum3  number :=0;
    v_flg_found      boolean := false;

    cursor c1 is
      select item7,item8,item9,item10,item11,item12 from (
        select numperiod||'/'||lpad(dtemthpay,2,'0')||'/'||dteyrepay item7,
               pctemppf item8,
               get_amt_func(amtprove) item9,
               pctcompf item10,
               get_amt_func(amtprovc) item11,
               get_amt_func(nvl(stddec(amtprove,codempid, v_chken),0)+nvl(stddec(amtprovc,codempid, v_chken),0)) item12
         from  ttaxcur
        where  codempid  = b_index_codempid
          and  dteyrepay = b_sdate
          and  nvl(stddec(amtprove,codempid, v_chken),0)+nvl(stddec(amtprovc,codempid, v_chken),0) <> 0
        order by   dteyrepay ,dtemthpay,numperiod );
  begin
    for r1 in c1 loop
      v_flg_found := true;
      exit;
    end loop;
    if not v_flg_found then -- if not found -> error
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxcur');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('period_no',to_char( i.item7));
      obj_data.put('con_rate1',i.item8);
      obj_data.put('amount1',i.item9);
      obj_data.put('con_rate2',i.item10);
      obj_data.put('amount2',i.item11);
      obj_data.put('total1',i.item12);
      obj_data.put('sum1',get_amt_func(stdenc(amtprove_sum1,b_index_codempid,v_chken)));
      obj_data.put('sum2',get_amt_func(stdenc(amtprovc_sum2,b_index_codempid,v_chken)));
      obj_data.put('sum3',get_amt_func(stdenc(amtprovc_amtprovc_sum3,b_index_codempid,v_chken)));

      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;

    if v_total > 1 then
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', '');
      obj_data.put('httpcode', '');
      obj_data.put('flg', 'SUM');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('period_no',get_label_name('HRES83XC1', global_v_lang, 170));
      obj_data.put('con_rate1','');
      obj_data.put('amount1',get_amt_func(stdenc(amtprove_sum1,b_index_codempid,v_chken)));
      obj_data.put('con_rate2','');
      obj_data.put('amount2',get_amt_func(stdenc(amtprovc_sum2,b_index_codempid,v_chken)));
      obj_data.put('total1',get_amt_func(stdenc(amtprovc_amtprovc_sum3,b_index_codempid,v_chken)));
      obj_data.put('sum1',get_amt_func(stdenc(amtprove_sum1,b_index_codempid,v_chken)));
      obj_data.put('sum2',get_amt_func(stdenc(amtprovc_sum2,b_index_codempid,v_chken)));
      obj_data.put('sum3',get_amt_func(stdenc(amtprovc_amtprovc_sum3,b_index_codempid,v_chken)));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);

    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_data        json_object_t;
    b_codempid        varchar2(400 char);
    temploy_name      varchar2(500 char);
    b_codpfinf        varchar2(500 char);
    desc_codpfinf     varchar2(500 char);
    v_flg_found      boolean := false;

      cursor c1 is
        select  to_char(dteeffec,'dd/mm/yyyy')    item5,
                get_amt_func(amteaccu)    item6,
                get_amt_func(amtintaccu)  item7,
                get_amt_func(amtcaccu)    item8,
                get_amt_func(amtinteccu)  item9
          from  tpfmemb
         where  codempid = b_index_codempid;
  begin
    begin
      select  codempid
        into  b_codempid
        from  tusrprof
        where coduser   = global_v_coduser;
        temploy_name := get_temploy_name(b_codempid,global_v_lang);
    exception when no_data_found then
      b_codempid        := null;
      temploy_name   := null;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TUSRPROF');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;

    begin
      select codpfinf
        into b_codpfinf
        from tpfmemb
        where	 codempid = b_codempid;
        desc_codpfinf := get_tcodec_name('TCODPFINF',b_codpfinf,global_v_lang);
    exception when no_data_found then null;
    end;
    --
    for r1 in c1 loop
      v_flg_found := true;
      exit;
    end loop;
    if not v_flg_found then -- if not found -> error
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpfmemb');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    obj_data := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('dteeffec', r1.item5);
      obj_data.put('amteaccu', r1.item6);
      obj_data.put('amtintaccu', r1.item7);
      obj_data.put('amtcaccu', r1.item8);
      obj_data.put('amtinteccu', r1.item9);
      obj_data.put('b_codempid', b_codempid);
      obj_data.put('temploy_name', temploy_name);
      obj_data.put('b_codpfinf', b_codpfinf);
      obj_data.put('desc_codpfinf', desc_codpfinf);
    end loop;
    json_str_output := obj_data.to_clob;
  end;
  --
  procedure get_index_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);

    begin
      select amtintaccu, amtinteccu
        into v_amtintaccu, v_amtinteccu
        from tpfmemb
       where codempid = b_index_codempid;
      v_amtintaccu := to_char(stddec(v_amtintaccu,b_index_codempid,v_chken),'fm999,999,990.00');
      v_amtinteccu := to_char(stddec(v_amtinteccu,b_index_codempid,v_chken),'fm999,999,990.00');
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPFMEMB');
    end;
--      check_index;
    if param_msg_error is null then
      gen_data_popup(json_str_output);
    else
      obj_row := json_object_t();
      obj_row.put('coderror','400');
      obj_row.put('desc_coderror',json_str_input);
      json_str_output := obj_row.to_clob;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data_popup(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number := 0;
    v_rcnt          number := 0;
    v_numseq        number := 0;
    v_concat        varchar2(10 char);
    v_real_numseq   number := 0;
    b_codempid      varchar2(400 char);
    temploy_name    varchar2(500 char);
    b_codpfinf      varchar2(500 char);
    desc_codpfinf   varchar2(500 char);
    v_codpfinf			varchar2(4);
    v_dteeffec			date := to_date('01011000','dd/mm/yyyy');

--    cursor c1 is
--      select codempid,dteeffec,codpolicy,
--                1 qtycompst,1 amtcaccu,
--               1 amteaccu,
--               ratecsbt,rateesbt,
--               dtecalen
--          from tpfirinf
--         where codempid = b_index_codempid
--         --  and nvl(qtycompst,0) <> 0
--        order by dteeffec desc,codpolicy;

      cursor c_table1 is  
            select a.codempid,a.codplan, (a.dteeffec),b.codpolicy,b.codpfinf,b.pctinvt
              from tpfirinf a, tpfpcinf b ,tpfmemb c
             where a.codempid = b_index_codempid
                 and  a.codempid = c.codempid
                  and b.codcompy = hcm_util.get_codcomp_level(c.codcomp,1)
                  and b.codpfinf = a.codpfinf
                  and b.codplan = a.codplan
                  and b.dteeffec = ( select max(d.dteeffec) from tpfpcinf d
                                 where codcompy = hcm_util.get_codcomp_level(c.codcomp,1)
                                   and codpfinf = a.codpfinf
                                   and codplan  = a.codplan
                                   and dteeffec <= a.dteeffec)

            order by a.dteeffec desc,a.codplan,b.codpolicy;

  begin
--    begin
--      select count(*)
--        into v_total
--        from tpfirinf
--       where codempid = b_index_codempid
--         and nvl(qtycompst,0) <> 0;
--    exception when no_data_found then
--      v_total := 0;
--    end;
    v_real_numseq := p_start-1;

    obj_row  := json_object_t();
    obj_data := json_object_t();
    for r1 in c_table1 loop
      v_numseq      := v_numseq+1;
      v_real_numseq := v_real_numseq+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codplan', r1.codplan);
      obj_data.put('desc_codplan', get_tcodec_name('TCODPFPLN', r1.codplan,global_v_lang));
      obj_data.put('codpolicy', r1.codpolicy);
      obj_data.put('desc_codpolicy', get_tcodec_name('TCODPFPLC', r1.codpolicy, global_v_lang));
      obj_data.put('pctinvt', r1.pctinvt);
      obj_row.put(to_char(v_numseq-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --

   procedure check_index is
  begin
      if  b_sdate is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
  end;
  --

  procedure get_popup_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      gen_popup_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_detail(json_str_output out clob) is
    obj_data        json_object_t;
    b_codempid        varchar2(400 char);
    temploy_name      varchar2(500 char);
    b_codpfinf        varchar2(500 char);
    desc_codpfinf     varchar2(500 char);

    s_codpfinf    varchar2(500 char);
    s_codempid    varchar2(500 char);

  begin
    begin
      select  codempid
        into  b_codempid
        from  tusrprof
        where coduser   = global_v_coduser;
        temploy_name := get_temploy_name(b_codempid,global_v_lang);
    exception when no_data_found then
      b_codempid        := null;
      temploy_name   := null;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TUSRPROF');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;

    begin
      select codpfinf
        into b_codpfinf
        from tpfmemb
        where	 codempid = b_codempid;
        desc_codpfinf := get_tcodec_name('TCODPFINF',b_codpfinf,global_v_lang);
    exception when no_data_found then null;
    end;
    --

    s_codpfinf := b_codpfinf||' '||desc_codpfinf;
    s_codempid := b_codempid||' '||temploy_name;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codpfinf', s_codpfinf);
    obj_data.put('codempid', b_codempid);
    obj_data.put('desc_codempid', temploy_name);
    json_str_output := obj_data.to_clob;
  end;
  --

  function get_amt_func(p_amt in varchar2) return varchar2 is
    v_amt   varchar2(4000 char);
    v_key   varchar2(4000 char);
    v_aaa   number := 0;
  begin

    begin
      select lterminal
        into v_key
        from tlogin
       where lrunning = global_v_lrunning;
    exception when no_data_found then null;
    end;

    begin
      v_amt := to_char(to_number(p_amt),'fm99,999,990.00');
    exception when others then
      v_amt := to_char(stddec(p_amt,b_index_codempid,v_chken),'fm99,999,990.00');
    end;
    return v_amt;
--    return hcm_secur.hcmenc_with_key(v_amt,v_key);
  end;

end;

/
