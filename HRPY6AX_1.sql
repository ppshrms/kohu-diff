--------------------------------------------------------
--  DDL for Package Body HRPY6AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY6AX" is
-- last update: 24/08/2018 16:15
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');

    json_params         := hcm_util.get_json_t(json_obj, 'params');
    -- detail
    json_params_maxpay  := hcm_util.get_json_t(json_obj, 'params_maxpay');
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_typpayroll        := upper(hcm_util.get_string_t(json_obj, 'p_typpayroll'));
    p_dteyear           := to_number(hcm_util.get_string_t(json_obj, 'p_dteyear'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    null;
  end;

  procedure check_detail is
    v_typpayroll          varchar2(100 char);
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodtypy');
        return;
      end;
    end if;
  end;

  procedure get_tab1 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tab1 (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1;

  procedure gen_tab1 (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

  begin
    obj_row            := json_object_t();

    -- Jan
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq',  '60');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '60'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Feb
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq',  '70');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '70'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Mar
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq',  '80');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '80'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Apr
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq',  '90');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '90'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- May
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '100');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '100'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Jun
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '110');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '110'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Jul
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '120');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '120'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Aug
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '130');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '130'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Sep
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '140');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '140'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Oct
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '150');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '150'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Nov
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '160');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '160'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    -- Dec
    obj_data           := json_object_t();
    v_rcnt             := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('numseq', '170');
    obj_data.put('descMonth', get_label_name(p_codapp, global_v_lang, '170'));
    obj_data.put('maxpay', '0.00');
    obj_row.put(to_char(v_rcnt - 1), obj_data);

    json_str_output := obj_row.to_clob;
  end gen_tab1;

  procedure get_tab2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tab2 (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab2;

  procedure gen_tab2 (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c_twkmencd is
      select codpay, typpay
        from twkmencd
      order by codpay, typpay;

  begin
    obj_row            := json_object_t();
    for r1 in c_twkmencd loop
      obj_data           := json_object_t();
      v_rcnt             := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codpay', r1.codpay);
      obj_data.put('typpay', r1.typpay);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_tab2;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      param_msg_error := save;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  function save return varchar2 is
    v_codpay              twkmencd.codpay%type;
    v_codpay_old          twkmencd.codpay%type;
    v_typpay              twkmencd.typpay%type;
    v_flgTable            varchar2(10 char);
    json_row              json_object_t;
  begin
--    begin
--      delete
--        from twkmencd;
--    end;
    for i in 0..json_params.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_params, to_char(i));
      v_codpay          := hcm_util.get_string_t(json_row, 'codpay');
      v_codpay_old      := hcm_util.get_string_t(json_row, 'codpayOld');
      v_typpay          := hcm_util.get_string_t(json_row, 'typpay');
      v_flgTable        := hcm_util.get_string_t(json_row, 'flg');

      chk_tinexinf(v_codpay);

      if param_msg_error is null then
        if v_flgTable in ('add') then
          begin
            insert into twkmencd
                  (codpay, typpay, coduser)
            values (v_codpay, v_typpay, global_v_coduser);
          exception when dup_val_on_index then
            update twkmencd
              set codpay  = v_codpay,
                  typpay  = v_typpay,
                  coduser = global_v_coduser
            WHERE codpay = v_codpay;
          end;
        elsif v_flgTable = 'edit' then
            begin
                update twkmencd
                  set codpay  = v_codpay,
                      typpay  = v_typpay,
                      coduser = global_v_coduser
                WHERE codpay = v_codpay_old;
            exception
                when dup_val_on_index then
                    delete from twkmencd
                          where codpay = v_codpay;

                    insert into twkmencd (codpay, typpay, coduser)
                         values (v_codpay, v_typpay, global_v_coduser);
                when NO_DATA_FOUND then
                    insert into twkmencd (codpay, typpay, coduser)
                         values (v_codpay, v_typpay, global_v_coduser);
            end;
        elsif v_flgTable = 'delete' then
          begin
            delete from twkmencd
                  where codpay = v_codpay;
          end;
        end if;
      else
        return param_msg_error;
      end if;
    end loop;
    return null;
  end save;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_detail;
    if param_msg_error is null then
      param_msg_error := save;
      if param_msg_error is null then
        commit;
        gen_detail (json_str_output);
      else
        rollback;
        json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_result          json_object_t;
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    json_row            json_object_t;
    v_dtemth            number;
    v_descMonth         varchar2(100 char);
    v_maxpay            number;

    v_empno             number := 0;
    v_amtpay            number := 0;
    v_amtwage           number := 0;
    v_oth               number := 0;
    v_over              number := 0;
    total_sal           number := 0;
    total_wage          number := 0;
    total_oth           number := 0;
    total_incom         number := 0;
    total_over          number := 0;
    total_net           number := 0;
    v_amt_inc           number := 0;
    v_sum               number := 0;
    v_des_typinc        varchar2(200) :=null;
    v_typpay            tinexinf.typpay%type;
    v_count             number := 0;
    v_amt               varchar2(200) :=null;
    v_totalsal          number := 0;

    cursor c_tsincexp is
      select count(distinct(t1.codempid)) amount
        from tsincexp t1 , tusrcom t2, ttaxcur t3
       where t1.dteyrepay  = p_dteyear
         and t1.dtemthpay  = v_dtemth
         and t1.codempid = t3.codempid
         and t1.dteyrepay = t3.dteyrepay
         and t1.dtemthpay = t3.dtemthpay
         and t1.numperiod = t3.numperiod
         and t3.flgsoc = 'Y'
         and t1.codcomp    like p_codcomp || '%'
         and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
         and t1.codpay     in (select codpay from twkmencd)
         and t1.numlvl     between global_v_numlvlsalst and global_v_numlvlsalen
         and t2.coduser    = global_v_coduser
--         and chk_pctsoc(codempid) = 'Y'
         and t1.codcomp    like t2.codcomp || '%';

    cursor c_income is
      select sum(nvl(stddec(t1.amtpay, t1.codempid, v_chken), 0) * decode(t1.typincexp, '1', 1, '2', 1, '3', 1, '4', -1, '5', -1, '6', -1, 0)) amtpay, t3.unitcal1
        from tsincexp t1, tinexinf t2, tcontpmd t3, tusrcom t4, ttaxcur t5
       where t1.codpay     in (select codpay from twkmencd where typpay = '1')
         and t1.codempid = t5.codempid
         and t1.dteyrepay = t5.dteyrepay
         and t1.dtemthpay = t5.dtemthpay
         and t1.numperiod = t5.numperiod
         and t5.flgsoc = 'Y'
         and t1.dteyrepay  = p_dteyear
         and t1.dtemthpay  = v_dtemth
         and t1.codcomp    like p_codcomp || '%'
         and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
         and t2.flgwork    = 'Y'
         and t1.codpay     = t2.codpay
         and t1.codempmt   = t3.codempmt
         and t3.codcompy   = hcm_util.get_codcomp_level(p_codcomp, 1)
         and t3.dteeffec   = (select max(dteeffec)
                                from tcontpmd
                               where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                                 and codempmt = t3.codempmt
                                 and dteeffec <= sysdate)
         and t1.numlvl     between global_v_numlvlsalst and global_v_numlvlsalen
         and t4.coduser    = global_v_coduser
         and t1.codcomp    like t4.codcomp || '%'
       group by t3.unitcal1;

    cursor c_oth is
      select sum(nvl(stddec(t1.amtpay, t1.codempid, v_chken), 0) * decode(t1.typincexp, '1', 1, '2', 1, '3', 1, '4', -1, '5', -1, '6', -1, 0)) amtpay
        from tsincexp t1, tinexinf t2, tusrcom t3
       where t1.dteyrepay  = p_dteyear
         and t1.dtemthpay  = v_dtemth
         and t1.codcomp    like p_codcomp || '%'
         and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
         and t1.codpay     in (select codpay from twkmencd where typpay = '4')
         and t1.codpay     = t2.codpay
         and t2.flgwork    = 'Y'
         and t1.numlvl     between global_v_numlvlsalst and global_v_numlvlsalen
         and t3.coduser    = global_v_coduser
         and t1.codcomp    like t3.codcomp || '%';

    cursor c_tot is
      select sum(nvl(stddec(t1.amtpay, t1.codempid, v_chken), 0) * decode(t1.typincexp, '1', 1, '2', 1, '3', 1, '4', -1, '5', -1, '6', -1, 0)) amtpay
        from tsincexp t1, tinexinf t2, tusrcom t3
       where t1.dteyrepay  = p_dteyear
         and t1.codcomp    like p_codcomp || '%'
         and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
         and t1.codpay     in (select codpay from twkmencd where typpay = v_typpay)
         and t1.codpay     = t2.codpay
         and t1.numlvl     between global_v_numlvlsalst and global_v_numlvlsalen
         and t3.coduser    = global_v_coduser
         and t1.codcomp    like t3.codcomp || '%';

    cursor c_maxpay is
      select sum(nvl(stddec(t1.amtpay, t1.codempid, v_chken), 0) * decode(t1.typincexp, '1', 1, '2', 1, '3', 1, '4', -1, '5', -1, '6', -1, 0)) amtpay, t1.codempid, t1.codcomp
        from tsincexp t1, tinexinf t2, tusrcom t3, ttaxcur t5
       where t1.dteyrepay  = p_dteyear
         and t1.dtemthpay  = v_dtemth
         and t1.codempid = t5.codempid
         and t1.dteyrepay = t5.dteyrepay
         and t1.dtemthpay = t5.dtemthpay
         and t1.numperiod = t5.numperiod
         and t5.flgsoc = 'Y'
         and t1.codcomp    like p_codcomp || '%'
         and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
         and	t1.codpay     in (select codpay from twkmencd where typpay in('1', '4'))
         and t1.codpay     = t2.codpay
         and t2.flgwork    = 'Y'
         and t1.numlvl     between global_v_numlvlsalst and global_v_numlvlsalen
         and t3.coduser    = global_v_coduser
         and t1.codcomp    like t3.codcomp || '%'
       group by t1.codempid, t1.codcomp
       order by t1.codempid, t1.codcomp;

    cursor c_mind is
      select min(to_number(stddec(t2.amtincom1, t2.codempid, v_chken))) amtincom1
        from temploy1 t1, ttaxcur t2, tcontpmd t3
       where t1.codempid  = t2.codempid
         and t2.dteyrepay = p_dteyear
         and t2.codcomp   like p_codcomp || '%'
         and t3.codcompy  = hcm_util.get_codcomp_level(t2.codcomp, 1)
         and t3.codempmt  = t1.codempmt
         and t3.unitcal1  = 'D'
        --<< User37 MTH-610076 15/02/2018 ---
        /*User37 #2374 Final Test Phase 1 V11 10/02/2021 and to_number(stddec(t2.amtincom1, t2.codempid, v_chken)) > 4000
         and to_number(nvl(to_char(t2.dteeffex, 'yyyy'), p_dteyear)) >= p_dteyear*/
        -->> User37 MTH-610076 15/02/2018 ---
         and t3.dteeffec  = (select max(a.dteeffec)
                               from tcontpmd a
                              where a.codcompy = hcm_util.get_codcomp_level(t2.codcomp, 1)
                                and a.codempmt = t1.codempmt
                                and a.unitcal1 = 'D'
                                and a.dteeffec <= sysdate)
       order by to_number(stddec(t2.amtincom1, t2.codempid, v_chken)) asc;

    cursor c_minm is
      select min(to_number(stddec(t2.amtincom1, t2.codempid, v_chken))) amtincom1
        from temploy1 t1, ttaxcur t2, tcontpmd t3
       where t1.codempid  = t2.codempid
         and t2.dteyrepay = p_dteyear
         and t2.codcomp   like p_codcomp || '%'
         and t3.codcompy  = hcm_util.get_codcomp_level(t2.codcomp, 1)
         and t3.codempmt  = t1.codempmt
         and t3.unitcal1  = 'M'
         and t3.dteeffec  = (select max(a.dteeffec)
                               from tcontpmd a
                              where a.codcompy = hcm_util.get_codcomp_level(t2.codcomp, 1)
                                and a.codempmt = t1.codempmt
                                and a.unitcal1 = 'M'
                                and a.dteeffec <= sysdate)
         and to_number(stddec(t2.amtincom1, t2.codempid, v_chken)) > 5000 -- User19 06/01/2015
       order by to_number(stddec(t2.amtincom1, t2.codempid, v_chken)) asc;

  begin
    obj_result         := json_object_t();
    obj_row            := json_object_t();
    for i in 0..json_params_maxpay.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_params_maxpay, to_char(i));
      v_dtemth          := i + 1;
      v_descMonth       := get_label_name(p_codapp, global_v_lang, hcm_util.get_string_t(json_row, 'numseq'));
      v_maxpay          := to_number(hcm_util.get_string_t(json_row, 'maxpay'));
      for j in c_tsincexp loop
        obj_data          := json_object_t();
        v_rcnt            := v_rcnt + 1;
        --<< User37 MTH-610076 15/02/2018 ---
--        v_empno := j.amount;
        v_empno := 0;
        select count(distinct(codempid))
          into v_empno
          from tcodsoc a, ttaxcur b
         where b.codcomp	like (a.codcompy || '%')
           and b.codcomp like p_codcomp || '%'
           and b.typpayroll = nvl(p_typpayroll, b.typpayroll)
           and b.dteyrepay  = p_dteyear
           and b.dtemthpay  = v_dtemth
           and b.flgsoc = 'Y'
           and b.codbrlc    =	a.codbrlc
--           and chk_pctsoc(b.codempid) = 'Y'
           and stddec(b.amtsoca, b.codempid, v_chken) > 0
          order by	a.numbrlvl, a.codcompy,
                    b.codempid, b.dteyrepay, b.dtemthpay, b.numperiod;

         if nvl(v_empno,0) = 0 then
            v_empno := j.amount;
         end if;

        -->> User37 MTH-610076 15/02/2018 ---
        obj_data.put('coderror', '200');
        obj_data.put('month', to_char(v_descMonth));
        obj_data.put('empno', to_char(v_empno));
        obj_data.put('amtpay', '0');
        obj_data.put('amtwage', '0');
        obj_data.put('oth', '0');
        obj_data.put('incom', '0');
        obj_data.put('over', '0');
        obj_data.put('net', '0');
        if j.amount <> 0 then
          ------------salary,wage-------------------
          v_amtpay := 0;
          v_amtwage := 0;
          for r1 in c_income loop
            if r1.unitcal1 = 'M' then
              v_amtpay  := v_amtpay + r1.amtpay;
            else
              v_amtwage := v_amtwage + r1.amtpay;
            end if;
          end loop;
          ------------other-------------------
          v_oth := 0;
          for r1 in c_oth loop
            v_oth := v_oth + r1.amtpay;
          end loop;
          -----------over------------------
          v_over := 0;
          for r1 in c_maxpay loop
            if (r1.amtpay - v_maxpay) > 0 then
              v_over := v_over + (r1.amtpay - v_maxpay);
            end if;
          end loop;
          -------------------------------------
          obj_data.put('amtpay', to_char(nvl(v_amtpay, 0)));
          obj_data.put('amtwage', to_char(nvl(v_amtwage, 0)));
          obj_data.put('oth', to_char(nvl(v_oth, 0)));
          obj_data.put('incom', to_char(nvl(v_amtpay, 0) + nvl(v_amtwage, 0) + nvl(v_oth, 0)));
          obj_data.put('over', to_char(nvl(v_over, 0)));
          obj_data.put('net', to_char((nvl(v_amtpay, 0) + nvl(v_amtwage, 0) + nvl(v_oth, 0)) - nvl(v_over, 0)));

          total_sal        := nvl(total_sal, 0)   + nvl(v_amtpay, 0);
          total_wage       := nvl(total_wage, 0)  + nvl(v_amtwage, 0);
          total_oth        := nvl(total_oth, 0)   + nvl(v_oth, 0);
          total_incom      := nvl(total_incom, 0) + nvl(v_amtpay, 0) + nvl(v_amtwage, 0) + nvl(v_oth, 0);
          total_over       := nvl(total_over, 0)  + nvl(v_over, 0);
          total_net        := nvl(total_net, 0)   + (nvl(v_amtpay, 0) + nvl(v_amtwage, 0) + nvl(v_oth, 0)) - nvl(v_over, 0);
        end if;
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end loop;

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');

    v_sum := 0;
    v_typpay := '1';

    --<< User37 MTH-610076 15/02/2018 ---
    select (count(distinct codempid)) numrec
      into v_count
      from ttaxinc
     where codcomp   like p_codcomp||'%'
       and dteyrepay = p_dteyear
       and to_number(stddec(amtinc, codempid, v_chken)) > 0
       and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
       and exists (select codcomp from tusrcom
                    where coduser = global_v_coduser
                      and ttaxinc.codcomp like codcomp || '%');
    -->> User37 MTH-610076 15/02/2018 ---

      select sum(nvl(stddec(t1.amtpay, t1.codempid, v_chken), 0) * decode(t1.typincexp, '1', 1, '2', 1, '3', 1, '4', -1, '5', -1, '6', -1, 0)) amtpay
        into v_totalsal
        from tsincexp t1, tinexinf t2, tcontpmd t3, tusrcom t4, ttaxcur t5
       where t1.codpay     in (select codpay from twkmencd where typpay = '1')
         and t1.codempid = t5.codempid
         and t1.dteyrepay = t5.dteyrepay
         and t1.dtemthpay = t5.dtemthpay
         and t1.numperiod = t5.numperiod
         and t3.unitcal1 = 'M'
--         and t5.flgsoc = 'Y'
         and t1.dteyrepay  = p_dteyear
         and t1.codcomp    like p_codcomp || '%'
         and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
         and t2.flgwork    = 'Y'
         and t1.codpay     = t2.codpay
         and t1.codempmt   = t3.codempmt
         and t3.codcompy   = hcm_util.get_codcomp_level(p_codcomp, 1)
         and t3.dteeffec   = (select max(dteeffec)
                                from tcontpmd
                               where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                                 and codempmt = t3.codempmt
                                 and dteeffec <= sysdate)
         and t1.numlvl     between global_v_numlvlsalst and global_v_numlvlsalen
         and t4.coduser    = global_v_coduser
         and t1.codcomp    like t4.codcomp || '%' ;

    obj_data.put('person', to_char(nvl(v_count, 0)));
    obj_data.put('amtpay', to_char(total_sal, 'fm999,999,999,999,990.00'));
    obj_data.put('amtpay_notsend', to_char(v_totalsal - total_sal, 'fm999,999,999,999,990.00'));
    obj_data.put('desc_amtpay', get_label_name('HRPY6AX',global_v_lang,180));
    obj_data.put('amtwage', to_char(total_wage, 'fm999,999,999,999,990.00'));
    obj_data.put('desc_amtwage', get_label_name('HRPY6AX',global_v_lang,190));
    obj_data.put('total_oth', to_char(total_oth, 'fm999,999,999,999,990.00'));
    obj_data.put('total_incom', to_char(total_incom, 'fm999,999,999,999,990.00'));
    obj_data.put('total_over', to_char(total_over, 'fm999,999,999,999,990.00'));
    obj_data.put('total_net', to_char(total_net, 'fm999,999,999,999,990.00'));
    for i in 2..6 loop
      v_typpay := to_char(i);
      v_amt_inc := 0;
      for r1 in c_tot loop
        v_amt_inc := v_amt_inc + nvl(r1.amtpay,0);
        v_sum := v_sum + nvl(r1.amtpay, 0);
      end loop;
      v_des_typinc := get_tlistval_name('WORKMEN',i,global_v_lang);
      if v_des_typinc like '***%' then
        v_des_typinc := null;
      end if;
--      v_sum := v_sum + nvl(v_amt_inc, 0);
      obj_data.put('amt_inc' || to_char(i), to_char(nvl(v_amt_inc, 0), 'fm999,999,999,999,990.00'));
      obj_data.put('desc_inc' || to_char(i), v_des_typinc);

      if i = 4 then
        obj_data.put('amtoth', to_char(total_oth, 'fm999,999,999,999,990.00'));
        obj_data.put('amtoth_notsend', to_char(nvl(v_amt_inc, 0) - total_oth, 'fm999,999,999,999,990.00'));
      end if;
    end loop;
    obj_data.put('sumamt', to_char(nvl(v_totalsal,0) + nvl(total_wage,0) + nvl(v_sum,0), 'fm999,999,999,999,990.00'));



    -- ? A?A<? A?A?? A?A#? A?A?? A?A?? A?a?z? A?a??? A?a??? A?a??? A?E?? A?A?? A?A?? A?A?? A?a??? A?a?s? A?A-? A?a?!? A?A#? A?A?? A?A?? A?A?? A?A?? A?a??
--    v_amt := get_label_name('HRPY6AX1', global_v_lang, 200);
    if v_amt is null or v_amt like '%*****%' then
      for i in c_mind loop
        if nvl(i.amtincom1,0) > 0 then
          p_amtday    := to_char(i.amtincom1, 'fm999,999,999,999,990.00');
          obj_data.put('amt_day', to_char(i.amtincom1, 'fm999,999,999,999,990.00'));
          exit;
        end if;
      end loop;
    else
      p_amtday    := to_char(v_amt, 'fm999,999,999,999,990.00');
      obj_data.put('amt_day', to_char(v_amt, 'fm999,999,999,999,990.00'));
    end if;

    --? A?A<? A?A?? A?A#? A?A?? A?A?? A?a?z? A?a??? A?a??? A?a??? A?E?? A?A?? A?A?? A?A?? A?a??? A?a?s? A?A-? A?a?!? A?A#? A?A?? A?A?? A?a??? A?a??? A?A?? A?A-? A?a??
--    v_amt := get_label_name('HRPY6AX1', global_v_lang, 201);
    if v_amt is null or v_amt like '%*****%' then
      for i in c_minm loop
        if nvl(i.amtincom1,0) > 0 then
          p_amtmon    := to_char(i.amtincom1, 'fm999,999,999,999,990.00');
          obj_data.put('amt_month', to_char(i.amtincom1, 'fm999,999,999,999,990.00'));
          exit;
        end if;
      end loop;
    else
      p_amtmon    := to_char(v_amt, 'fm999,999,999,999,990.00');
      obj_data.put('amt_month', to_char(v_amt, 'fm999,999,999,999,990.00'));
    end if;

    obj_result.put('detail', obj_row);
    obj_result.put('summary', obj_data);
    -- insert temp report --
    if isInsertReport then
      insert_temp(obj_result);
    end if;
    json_str_output :=  obj_result.to_clob;
  end gen_detail;

  procedure chk_tinexinf (v_code in tinexinf.codpay%type) is
    v_typpay	tinexinf.typpay%type;
  begin
    if v_code is not null then
      begin
        select typpay into v_typpay
        from tinexinf
        where codpay = v_code
          and typpay not in('6', '7');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
        return;
      end;
    end if;
  end;

  function chk_pctsoc (v_codempid temploy1.codempid%type) return varchar2 is
    v_stmt            clob;
    v_syncond         tcontrpy.syncond%type;
    v_pctsoc          tcontrpy.pctsoc%type;
	  v_flgfound        boolean;
  begin
    begin
      select syncond, pctsoc
        into v_syncond, v_pctsoc
        from tcontrpy
       where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                            and dteeffec < trunc(sysdate));

      v_stmt := 'select count(*) from temploy1 where codempid = ' || v_codempid || ' and (' || v_syncond || ')';
      v_flgfound := execute_stmt(v_stmt);
      if v_flgfound then
        return 'N';
      else
        return 'Y';
      end if;
    exception when no_data_found then
      null;
    end;
    return 'N';
  end;
  --
  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      gen_detail (json_str_output);
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
  --
  procedure insert_temp(json_obj json_object_t) is
    json_detail         json_object_t;
    json_detail_rows    json_object_t;
    json_summary        json_object_t;

    v_codapp            varchar2(20)  := 'HRPY6AX';
    v_num               number := 0 ;

    v_month             varchar2(20);
    v_empno             number;
    v_amtpay            number;
    v_amtwage           number;
    v_oth               number;
    v_incom             number;
    v_over              number;
    v_net               number;

    total_sal           number := 0;
    total_wage          number := 0;
    total_oth           number := 0;
    total_incom         number := 0;
    total_over          number := 0;
    total_net           number := 0;

    v_item1 varchar2(1000 char);
    v_item2 varchar2(1000 char);
    v_item3 varchar2(1000 char);
    v_item4 varchar2(1000 char);
    v_item5 varchar2(1000 char);
    v_item6 varchar2(1000 char);
    v_item7 varchar2(1000 char);
    v_item32 varchar2(1000 char);
    v_item33 varchar2(1000 char);
    v_item34 varchar2(1000 char);
    v_item35 varchar2(1000 char);
    v_item36 varchar2(1000 char);
    v_item37 varchar2(1000 char);
    v_temp31 varchar2(1000 char);
    v_temp32 varchar2(1000 char);
    v_temp33 varchar2(1000 char);
    v_temp34 varchar2(1000 char);
    v_temp35 varchar2(1000 char);
    v_temp36 varchar2(1000 char);
    v_temp37 varchar2(1000 char);
    v_temp38 varchar2(1000 char);
    v_temp39 varchar2(1000 char);


  begin




    del_temp(v_codapp,global_v_codempid);
    del_temp('HRPY6AX1',global_v_codempid);
    json_detail     := hcm_util.get_json_t(json_obj,'detail');
    for i in 0..json_detail.get_size - 1 loop
      json_detail_rows  := hcm_util.get_json_t(json_detail,to_char(i));
      v_num             := v_num + 1;
      v_month           := hcm_util.get_string_t(json_detail_rows,'month');
      v_empno           := to_number(hcm_util.get_string_t(json_detail_rows,'empno'));
      v_amtpay          := to_number(hcm_util.get_string_t(json_detail_rows,'amtpay'));
      v_amtwage         := to_number(hcm_util.get_string_t(json_detail_rows,'amtwage'));
      v_oth             := to_number(hcm_util.get_string_t(json_detail_rows,'oth'));
      v_incom           := to_number(hcm_util.get_string_t(json_detail_rows,'incom'));
      v_over            := to_number(hcm_util.get_string_t(json_detail_rows,'over'));
      v_net             := to_number(hcm_util.get_string_t(json_detail_rows,'net'));
      insert into ttemprpt(codempid,codapp,numseq,
                           item1,temp31,
                           item32,item33,item34,item35,item36,item37,
                           temp32,temp33,temp34,temp35,temp36,temp37)
                    values(global_v_codempid,'HRPY6AX',v_num,
                           v_month,v_empno,
                           to_char(v_amtpay, 'fm999,999,990.00'),
                           to_char(v_amtwage, 'fm999,999,990.00'),
                           to_char(v_oth, 'fm999,999,990.00'),
                           to_char(v_incom, 'fm999,999,990.00'),
                           to_char(v_over, 'fm999,999,990.00'),
                           to_char(v_net, 'fm999,999,990.00'),
                           v_amtpay, v_amtwage, v_oth, v_incom, v_over, v_net);
    end loop;
    --<<Summary
    json_summary     := hcm_util.get_json_t(json_obj,'summary');
    v_item32 := hcm_util.get_string_t(json_summary,'amtpay');
    v_item33 := hcm_util.get_string_t(json_summary,'amtwage');
    v_item34 := hcm_util.get_string_t(json_summary,'total_oth');
    v_item35 := hcm_util.get_string_t(json_summary,'total_incom');
    v_item36 := hcm_util.get_string_t(json_summary,'total_over');
    v_item37 := hcm_util.get_string_t(json_summary,'total_net');
    v_temp32 := to_number(replace(hcm_util.get_string_t(json_summary,'amtpay'),',',''));
    v_temp33 := to_number(replace(hcm_util.get_string_t(json_summary,'amtwage'),',',''));
    v_temp34 := to_number(replace(hcm_util.get_string_t(json_summary,'total_oth'),',',''));
    v_temp35 := to_number(replace(hcm_util.get_string_t(json_summary,'total_incom'),',',''));
    v_temp36 := to_number(replace(hcm_util.get_string_t(json_summary,'total_over'),',',''));
    v_temp37 := to_number(replace(hcm_util.get_string_t(json_summary,'total_net'),',',''));
    begin
      v_num             := v_num + 1;
      insert into ttemprpt(codempid,codapp,numseq,
                             item1,temp31,
                             item32,item33,item34,item35,item36,item37,
                             temp32,temp33,temp34,temp35,temp36,temp37)
                      values(global_v_codempid,'HRPY6AX',v_num,
                             get_label_name('HRPY6AX1',global_v_lang,120),null,
                             v_item32,
                             v_item33,
                             v_item34,
                             v_item35,
                             v_item36,
                             v_item37,
                             v_temp32,
                             v_temp33,
                             v_temp34,
                             v_temp35,
                             v_temp36,
                             v_temp37);
    end;--end sumary>>
    v_temp31 := to_number(replace(hcm_util.get_string_t(json_summary,'person'),',',''));
    v_temp32 := to_number(replace(hcm_util.get_string_t(json_summary,'amtpay'),',',''));
    v_item1  := hcm_util.get_string_t(json_summary,'desc_amtpay');
    v_item2 := hcm_util.get_string_t(json_summary,'desc_amtwage');
    v_item3  := hcm_util.get_string_t(json_summary,'desc_inc2');
    v_item4  := hcm_util.get_string_t(json_summary,'desc_inc3');
    v_item5 := hcm_util.get_string_t(json_summary,'desc_inc4');
    v_item6 := hcm_util.get_string_t(json_summary,'desc_inc5');
    v_item7 := hcm_util.get_string_t(json_summary,'desc_inc6');
    v_temp33 := to_number(replace(hcm_util.get_string_t(json_summary,'sumamt'),',',''));
    v_temp34 := to_number(replace(hcm_util.get_string_t(json_summary,'amtwage'),',',''));
    v_temp35 := to_number(replace(hcm_util.get_string_t(json_summary,'amt_inc2'),',',''));
    v_temp36 := to_number(replace(hcm_util.get_string_t(json_summary,'amt_inc3'),',',''));
    v_temp37 := to_number(replace(hcm_util.get_string_t(json_summary,'amt_inc4'),',',''));
    v_temp38 := to_number(replace(hcm_util.get_string_t(json_summary,'amt_inc5'),',',''));
    v_temp39 := to_number(replace(hcm_util.get_string_t(json_summary,'amt_inc6'),',',''));
    begin
      insert into ttemprpt(codempid,codapp,numseq,
                           temp31,temp32,
                           item1,item2,item3,
                           item4,item5,item6,
                           item7,temp33,temp34,
                           temp35,temp36,temp37,
                           temp38,temp39)
          values(global_v_codempid,'HRPY6AX1',1,
                 v_temp31,
                 v_temp32,
                 v_item1,
                 v_item2,
                 v_item3,
                 v_item4,
                 v_item5,
                 v_item6,
                 v_item7,
                 v_temp33,
                 v_temp34,
                 v_temp35,
                 v_temp36,
                 v_temp37,
                 v_temp38,
                 v_temp39);
    end;
    temp_rpt_header;
    commit;
  end;
  --
  procedure temp_rpt_header is
    v_rpt_label_di_v10    varchar2(500);
    v_rpt_label_di_v20    varchar2(500);
    v_rpt_label_di_v30    varchar2(500);
    v_rpt_label_di_v40    varchar2(500);
    v_rpt_label_di_v50    varchar2(500);
    v_rpt_label_di_v60    varchar2(500);
    f_labdate1            varchar2(100);
    f_labdate2            varchar2(100);
    v_footer1             varchar2(200);
    v_footer2             varchar2(200);
    v_footer3             varchar2(200);
    f_repname             varchar2(100);
    v_namcompny           varchar2(150);
    v_codcomp             tcenter.codcomp%type;
    v_codcompy            varchar2(60);
    v_codapp              varchar2(20)  := 'HRPY6AX';
    v_num                 number := 0 ;
    v_numtele	            tcompny.numtele%type;
    v_numacsoc            tcompny.numacsoc%type;
    v_year                number  := 0;

    v_typsign           tsetsign.typsign%type;
    v_codempid          temploy1.codempid%type;
    v_codcomp2          temploy1.codcomp%type;
    v_codpos            tsetsign.codpos%type;
    v_signname          tsetsign.signname%type;
    v_posname           tsetsign.posname%type;
    v_namsign           tsetsign.namsign%type;
    v_name              varchar2(150 char);
    v_desc_codpos       varchar2(150 char);
    v_folder            tfolderd.folder%type;
    v_has_image         varchar2(1) := 'N';


  begin
    v_codcompy  := hcm_util.get_codcomp_level(p_codcomp,1);
--<< 8.Libary #7417 17/01/2022    
--    v_rpt_label_di_v10          := get_report.get_description_label('HRPY6AX1',10,global_v_lang);
--    v_rpt_label_di_v20          := get_report.get_description_label('HRPY6AX1',20,global_v_lang);
--    v_rpt_label_di_v30          := get_report.get_description_label('HRPY6AX1',30,global_v_lang);
--    v_rpt_label_di_v40          := get_report.get_description_label('HRPY6AX1',40,global_v_lang);
--    v_rpt_label_di_v50          := get_report.get_description_label('HRPY6AX1',50,global_v_lang);
--    v_rpt_label_di_v60          := get_report.get_description_label('HRPY6AX1',60,global_v_lang);

    v_rpt_label_di_v10          := get_label_name('HRPY6AX1',global_v_lang,'310');
    v_rpt_label_di_v20          := get_label_name('HRPY6AX1',global_v_lang,'320');
    v_rpt_label_di_v30          := get_label_name('HRPY6AX1',global_v_lang,'330');
    v_rpt_label_di_v40          := get_label_name('HRPY6AX1',global_v_lang,'340');
    v_rpt_label_di_v50          := get_label_name('HRPY6AX1',global_v_lang,'350');
    v_rpt_label_di_v60          := get_label_name('HRPY6AX1',global_v_lang,'360');
-->> 8.Libary #7417 17/01/2022    

    begin
      select numtele,numacsoc
      into	 v_numtele,v_numacsoc
      from   tcompny
      where  codcompy = hcm_util.get_codcomp_level(p_codcomp, 1);
    exception when no_data_found then
      v_numtele  := null;
      v_numacsoc := null;
    end;

    begin
      select  codcomp
      into    v_codcomp
      from    temploy1
      where   codempid    = get_codempid(global_v_coduser);
    exception when no_data_found then
      null;
    end;
--    f_repname     := get_report.get_report_title(global_v_lang,v_codapp);
--    f_labdate1    := get_report.get_description_label(v_codapp,1,global_v_lang);
--    f_labdate2    := get_report.get_description_label(v_codapp,2,global_v_lang);
--    get_report.get_footer_label(v_codapp,global_v_coduser,v_codcomp,global_v_lang,v_footer1,v_footer2,v_footer3 );
--    get_report.get_codcompy(null,hcm_util.get_codcomp_level(p_codcomp,1),v_codcompy,global_v_lang,v_codcompy,v_namcompny);


    begin
      select typsign,codempid,codcomp,
             codpos ,signname,posname,
             namsign
        into v_typsign,v_codempid,v_codcomp2,
             v_codpos ,v_signname,v_posname,
             v_namsign
        from tsetsign
       where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
         and coddoc = 'HRPY6AX';
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
      return;
    end;

    if v_typsign = '1' then
      begin
        select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
               namfirstt|| ' ' ||namlastt,
               get_tpostn_name(codpos,global_v_lang)
          into v_name,v_desc_codpos
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select namsign into v_namsign
          from tempimge
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select folder  into v_folder
          from tfolderd
         where codapp = 'HRPMC2E2';
      exception when no_data_found then null;
      end;
    elsif v_typsign = '2' then
      begin
        select codempid into v_codempid
          from temploy1
         where codpos = v_codpos
           and codcomp  like nvl(v_codcomp2,'')||'%'
           and staemp in ('1','3')
           and rownum = 1
      order by codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
               namfirstt|| ' ' ||namlastt
          into v_name
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select namsign into v_namsign
          from tempimge
         where codempid = v_codempid;
      exception when no_data_found then v_namsign := null;
      end;
      --
      begin
        select folder into v_folder
          from tfolderd
         where codapp = 'HRPMC2E2';
      exception when no_data_found then null;
      end;
      v_desc_codpos := get_tpostn_name(v_codpos,global_v_lang);
    elsif v_typsign = '3' then
      v_name := v_signname;
      v_desc_codpos := v_posname;
      begin
        select folder into v_folder
          from tfolderd
         where codapp = 'HRCO02E';
      exception when no_data_found then null;
      end;
    end if;
      --<<check existing image
    if v_namsign is not null then
      v_namsign     := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_namsign;
      v_has_image   := 'Y';
    end if;
    -->>



    if p_dteyear < 2400 then
        v_year := p_dteyear + 543;
    else
        v_year := p_dteyear;
    end if;

--<< 8.Libary #7417 17/01/2022   
    begin
      select decode(global_v_lang,101,desrepe
                                 ,102,desrept
                                 ,103,desrep3
                                 ,104,desrep4
                                 ,105,desrep5,desrepe)
        into f_repname
        from tappprof
       where codapp  = v_codapp;
    exception when others then
      f_repname := null;
    end;
    f_labdate1  := get_date_label(1,global_v_lang);
    f_labdate2  := get_date_label(2,global_v_lang);
-->> 8.Libary #7417 17/01/2022   

    begin
    	insert into ttempprm(codempid,codapp,codcomp,namcomp,namcentt,namrep,pdate,ppage,pfooter1,pfooter2,pfooter3,
                           label1,label2,label3,
                           label4,label5,label6,
                           label7,label8,label9,
                           label10,
                           label11,label12,label13,
                           label14,label15,label16,
                           label17,label18,label19,label20)
                    values(global_v_codempid,v_codapp,v_codcompy,v_namcompny,get_tcenter_name(v_codcomp,global_v_lang),f_repname,f_labdate1,f_labdate2,v_footer1,v_footer2,v_footer3,
                           v_year,v_rpt_label_di_v10,v_rpt_label_di_v20,
                           get_tcompny_name(hcm_util.get_codcomp_level(p_codcomp, 1),global_v_lang),v_numacsoc,v_rpt_label_di_v30,
                           v_rpt_label_di_v40,v_numtele,
                           p_amtmon,p_amtday,
                           v_rpt_label_di_v10, v_rpt_label_di_v20,v_rpt_label_di_v30,
                           v_rpt_label_di_v40, v_rpt_label_di_v50,v_rpt_label_di_v60,
                           v_name,v_desc_codpos,v_namsign,v_has_image);
    end;

  end;

 function get_date_label (v_numseq number,v_lang varchar2)return varchar2 is
		get_labdate   varchar2(20);
	begin
    select desc_label	into get_labdate
   	from trptlbl
   	where codrept  = 'HEADRPT' and
          numseq    =  v_numseq   and
          codlang   =  v_lang;
		return get_labdate;
	exception
		when others then
	 	if v_numseq = 1 then return('Date/Time');
	 	else return('Page');
	 	end if;
	end;
--
end HRPY6AX;

/
