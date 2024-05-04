--------------------------------------------------------
--  DDL for Package Body HRPY5SX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5SX" is
-- last update: 24/08/2018 16:15
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    -- index
    p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_comgrp            := upper(hcm_util.get_string_t(json_obj,'p_comgrp'));
    p_typpayroll        := upper(hcm_util.get_string_t(json_obj,'p_typpayroll'));
    p_codrep            := upper(hcm_util.get_string_t(json_obj, 'p_codrep'));
    p_namrep            := hcm_util.get_string_t(json_obj, 'p_namrep');
    p_namrepe           := hcm_util.get_string_t(json_obj, 'p_namrepe');
    p_namrept           := hcm_util.get_string_t(json_obj, 'p_namrept');
    p_namrep3           := hcm_util.get_string_t(json_obj, 'p_namrep3');
    p_namrep4           := hcm_util.get_string_t(json_obj, 'p_namrep4');
    p_namrep5           := hcm_util.get_string_t(json_obj, 'p_namrep5');
    p_typcode           := hcm_util.get_string_t(json_obj, 'p_typcode');

    p_codinc            := hcm_util.get_json_t(json_obj, 'p_codinc');
    p_codded            := hcm_util.get_json_t(json_obj, 'p_codded');

    -- detail
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj, 'p_year'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj, 'p_month'));
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_period'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_typpayroll        varchar2(100 char);
    v_comgrp            varchar2(100 char);
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

    if p_comgrp is not null then
      begin
        select codcodec
          into v_comgrp
          from tcompgrp
         where codcodec = p_comgrp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcompgrp');
        return;
      end;
    end if;

    if p_codcomp is null and p_comgrp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
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
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_data            json_object_t;
    v_rcnt_codinc       number := 0;
    v_rcnt_codded       number := 0;

    obj_codinc          json_object_t;
    obj_codded          json_object_t;

    cursor c_tinitregh is
      select descode, descodt, descod3, descod4, descod5,
             decode(global_v_lang, '101', descode
                                 , '102', descodt
                                 , '103', descod3
                                 , '104', descod4
                                 , '105', descod5, '') namrep
        from tinitregh
       where codapp  = p_codapp
         and codrep  = nvl(p_codrep, 'TEMP');

    cursor c_tinitregd is
      select a.numseq, a.codinc, a.codded
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp  = p_codapp
         and a.codrep  = nvl(p_codrep, 'TEMP')
         and b.typcode = p_typcode
       order by a.numseq;
  begin
    obj_codinc         := json_object_t();
    obj_codded         := json_object_t();
    obj_data           := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('namrep', '');
    obj_data.put('namrepe', '');
    obj_data.put('namrept', '');
    obj_data.put('namrep3', '');
    obj_data.put('namrep4', '');
    obj_data.put('namrep5', '');
    obj_data.put('codinc', obj_codinc);
    obj_data.put('codded', obj_codded);
    for r1 in c_tinitregh loop
      obj_data.put('coderror', '200');
      obj_data.put('namrep', r1.namrep);
      obj_data.put('namrepe', r1.descode);
      obj_data.put('namrept', r1.descodt);
      obj_data.put('namrep3', r1.descod3);
      obj_data.put('namrep4', r1.descod4);
      obj_data.put('namrep5', r1.descod5);

      for r2 in c_tinitregd loop
        if r2.codinc is not null then
          v_rcnt_codinc   := v_rcnt_codinc + 1;
          obj_codinc.put(to_char(v_rcnt_codinc - 1), to_char(r2.codinc));
        end if;
        if r2.codded is not null then
          v_rcnt_codded   := v_rcnt_codded + 1;
          obj_codded.put(to_char(v_rcnt_codded - 1), to_char(r2.codded));
        end if;
      end loop;
      obj_data.put('codinc', obj_codinc);
      obj_data.put('codded', obj_codded);
    end loop;
    json_str_output := obj_data.to_clob;
  end gen_index;

  procedure get_codpay (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_codpay (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_codpay;

  procedure gen_codpay (json_str_output out clob) is
    obj_data          json_object_t;
    obj_codinc        json_object_t;
    obj_codded        json_object_t;

    cursor c_tinexinf_codinc is
      select codpay, decode(global_v_lang, '101', descpaye
                                          , '102', descpayt
                                          , '103', descpay3
                                          , '104', descpay4
                                          , '105', descpay5
                                          , '') descpay
        from tinexinf
       where typpay in (1, 2, 3);

    cursor c_tinexinf_codded is
      select codpay, decode(global_v_lang, '101', descpaye
                                          , '102', descpayt
                                          , '103', descpay3
                                          , '104', descpay4
                                          , '105', descpay5
                                          , '') descpay
        from tinexinf
       where typpay in (4, 5, 6);

  begin
    obj_codinc        := json_object_t();
    obj_codded        := json_object_t();

    if p_typcode = '1' then
      for c1 in c_tinexinf_codinc loop
        obj_codinc.put(c1.codpay, c1.descpay);
      end loop;
      for c2 in c_tinexinf_codded loop
        obj_codded.put(c2.codpay, c2.descpay);
      end loop;

    end if;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codinc', obj_codinc);
    obj_data.put('codded', obj_codded);

    json_str_output := obj_data.to_clob;
  end gen_codpay;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    v_maxrcnt           number := 0;
    v_rcnt              number := 0;
    v_codinc            varchar2(4 char);
    v_codded            varchar2(4 char);
  begin
    initial_value (json_str_input);

    if global_v_lang = '101' then
      p_namrepe := p_namrep;
    elsif global_v_lang = '102' then
      p_namrept := p_namrep;
    elsif global_v_lang = '103' then
      p_namrep3 := p_namrep;
    elsif global_v_lang = '104' then
      p_namrep4 := p_namrep;
    elsif global_v_lang = '105' then
      p_namrep5 := p_namrep;
    end if;
    begin
      insert
        into tinitregh (
          codapp, codrep, typcode,
          descode, descodt, descod3, descod4, descod5,
          codcreate
        )
      values (
        p_codapp, nvl(p_codrep, 'TEMP'), p_typcode,
        p_namrepe, p_namrept, p_namrep3, p_namrep4, p_namrep5,
        global_v_coduser
      );
    exception when dup_val_on_index then
      update tinitregh
          set typcode = p_typcode,
              descode = p_namrepe,
              descodt = p_namrept,
              descod3 = p_namrep3,
              descod4 = p_namrep4,
              descod5 = p_namrep5,
              coduser = global_v_coduser
        where codapp = p_codapp
          and codrep = nvl(p_codrep, 'TEMP');
    end;

    if param_msg_error is null then
      v_maxrcnt        := p_codinc.get_size;
      if p_codded.get_size > v_maxrcnt then
        v_maxrcnt       := p_codded.get_size;
      end if;
      for i in 0..v_maxrcnt - 1 loop
        v_rcnt          := i + 1;
        v_codinc        := hcm_util.get_string_t(p_codinc, to_char(i));
        v_codded        := hcm_util.get_string_t(p_codded, to_char(i));
        begin
          insert
            into tinitregd (
              codapp, codrep, numseq, codinc, codded, codcreate
            )
          values (
            p_codapp, nvl(p_codrep, 'TEMP'), v_rcnt, v_codinc, v_codded, global_v_coduser
          );
        exception when dup_val_on_index then
          update tinitregd
            set codinc = v_codinc,
                codded = v_codded,
                coduser = global_v_coduser
          where codapp = p_codapp
            and codrep = nvl(p_codrep, 'TEMP')
            and numseq = v_rcnt;
        end;
      end loop;
      delete from tinitregd
       where codapp = p_codapp
         and codrep = nvl(p_codrep, 'TEMP')
         and numseq > v_rcnt;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
   begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;


  procedure gen_detail (json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row         number := 0;
    v_secur       boolean := false;
    v_codempid    varchar2(30 char);
    v_amtincom    number  := 0;
    v_codprovc    tcontrpy.codpaypy7%type;
    v_amtprovc    number  := 0;
    v_numbank     temploy3.numbank%type;
    v_numseq      number  := 0;
    v_totinc      number  := 0;
    v_totded      number  := 0;
    v_count       number  := 0;

    r1_qtyemp     number;
    r1_costcent   varchar2(4000 char);
    r1_othinc     number;
    r1_othded     number;
    r1_codcomp    varchar2(40 char);

    v_stmt        clob;
    v_stmt_inc    clob;
    v_stmt_othinc clob;
    v_stmt_ded    clob;
    v_stmt_othded clob;
    v_concat      clob;

    v_stmt_data   clob;--User37 #5035 Final Test Phase 1 V11 15/03/2021

    curid         number;
    desctab       dbms_sql.desc_tab;
    colcnt        number;
    numvar        number;
    v_dummy       integer;
    v_rcnt        number := 0;
    v_rcnt_inc    number := 0;
    v_rcnt_ded    number := 0;
    type amtinc_arr is table of number index by binary_integer;
      v_amtinc_arr  amtinc_arr;
    type amtded_arr is table of number index by binary_integer;
      v_amtded_arr  amtded_arr;

    cursor c_tinitregd is
      select a.numseq, a.codinc, a.codded
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp = b.codapp
         and a.codapp  = p_codapp
         and a.codrep  = nvl(p_codrep, 'TEMP')
         and b.typcode = p_typcode
       order by a.numseq;

  begin
    obj_row          := json_object_t();

    begin
      delete from ttemprpt
       where codempid = global_v_coduser
         and codapp   = p_codapp_report;
      commit;
    end;

    v_stmt := 'select count(distinct(t1.codempid)) qtyemp, t3.costcent';
    v_concat := ',';
    for r0 in c_tinitregd loop

      -- INCOME
      if r0.codinc is not null then
        v_rcnt_inc := v_rcnt_inc + 1;
        v_stmt_inc := v_stmt_inc || v_concat || to_clob('
        sum(
          decode(
            decode(''' || p_typcode || ''', 1, t1.codpay, 2, t1.typinc, 3, t1.typpayr, 4, t1.typpayt, t1.typpayr),
            ''' || r0.codinc || ''',
            nvl(stddec(t3.amtpay, t3.codempid, ''' || v_chken || '''), 0) * decode(''' || p_typcode || ''', 1, decode(t1.typincexp, 4, -1, 5, -1, 6, -1, 1), 3, decode(t1.typincexp, 4, -1, 5, -1, 6, -1, 1), decode(t1.typincexp, 1, 1, 2, 1, 3, 1, 4, -1, 5, -1, 0)), 0)
        ) amtinc' || to_char(r0.numseq));
        v_stmt_othinc := v_stmt_othinc || '
          ,''' || r0.codinc || ''', 0';

      end if;

      if r0.codded is not null then
        v_rcnt_ded := v_rcnt_ded + 1;
        v_stmt_ded := v_stmt_ded || v_concat || to_clob('
        sum(
          decode(
            decode(''' || p_typcode || ''', 1, t3.codpay, 2, t1.typinc, 3, t1.typpayr, 4, t1.typpayt, t1.typpayr),
            ''' || r0.codded || ''',
            nvl(stddec(t3.amtpay, t3.codempid, ''' || v_chken || '''), 0) * decode(''' || p_typcode || ''', 1, decode(t1.typincexp, 1, -1, 2, -1, 3, -1, 1), 3,decode(t1.typincexp, 1, -1, 2, -1, 3, -1, 1), decode(t1.typincexp, 6, 1, 0)), 0)
        ) amtded' || to_char(r0.numseq));
        v_stmt_othded := v_stmt_othded || '
          ,''' || r0.codded || ''', 0';
      end if;
    end loop;

    if v_stmt_othinc is not null then
      v_stmt := v_stmt || v_concat || to_clob('
      sum(
        decode(
          decode(''' || p_typcode || ''', 1, t3.codpay, 2, t1.typinc, 3, t1.typpayr, 4, t1.typpayt, t1.typpayr)
          ' || v_stmt_othinc || ',
          nvl(stddec(t3.amtpay, t3.codempid, ''' || v_chken || '''), 0)
            * decode(t1.typincexp, 4, -1, 5, -1, 6, -1, 1)
            * decode(
              decode(''' || p_typcode || ''', 1,
                decode(t1.typincexp, ''1'', ''1'',
                                  ''2'', ''1'',
                                  ''3'', ''1'',
                                  ''4'', ''3'',
                                  ''5'', ''3'',
                                  ''6'', ''3'',
                                  '' ''
                ), 2,
                substr(t1.typinc, 4, 1), 3,
                substr(t1.typpayr, 4, 1), 4,
                substr(t1.typpayt, 4, 1), substr(t1.typpayr, 4, 1)),
                1, 1,
                0
              )
            )
          ) othinc');
    end if;

    if v_stmt_othded is not null then
      v_stmt := v_stmt || v_concat || to_clob('
      sum(
        decode(
          decode(''' || p_typcode || ''', 1, t3.codpay, 2, t1.typinc, 3, t1.typpayr, 4, t1.typpayt, t1.typpayr)
          ' || v_stmt_othded || ',
            nvl(stddec(t3.amtpay, t3.codempid, ''' || v_chken || '''), 0)
              * decode(t1.typincexp, 1, -1, 2, -1, 3, -1, 1)
              * decode(
                  decode(''' || p_typcode || ''', 1,
                    decode(t1.typincexp, ''1'', ''1'',
                                      ''2'', ''1'',
                                      ''3'', ''1'',
                                      ''4'', ''3'',
                                      ''5'', ''3'',
                                      ''6'', ''3'',
                                      '' ''
                    ), 2,
                  substr(t1.typinc, 4, 1), 3,
                  substr(t1.typpayr, 4, 1), 4,
                  substr(t1.typpayt, 4, 1), substr(t1.typpayr, 4, 1)
                ),
            3, 1,
            0
          )
        )
      ) othded');
    end if;

    v_stmt := to_clob(v_stmt) || to_clob(v_stmt_inc) || to_clob(v_stmt_ded);

    --<<User37 #5035 Final Test Phase 1 V11 15/03/2021
    v_stmt_data := v_stmt || to_clob('
        from tsincexp t1, tcenter t2, tsinexct t3
       where t1.dteyrepay = t3.dteyrepay
        and t1.dtemthpay = t3.dtemthpay
        and t1.numperiod = t3.numperiod
        and t1.codempid  = t3.codempid
        and t1.codpay    = t3.codpay
        and t1.dteyrepay = ''' || to_char(p_dteyrepay) || '''
        and t3.codcomp  = t2.codcomp
        and t1.dtemthpay = nvl(''' || to_char(p_dtemthpay) || ''', t1.dtemthpay)
        and t1.numperiod = nvl(''' || to_char(p_numperiod) || ''', t1.numperiod)
        and t3.codcomp like ''' || p_codcomp || ''' || ''%''
        and ((''' || p_comgrp || ''' is not null and hcm_util.get_codcomp_level(t3.codcomp,1)
              in (select codcompy
                    from tcompny
                    where compgrp = ''' || to_char(p_comgrp) || '''))
              or (''' || to_char(p_comgrp) || ''' is null)
            )
        and t1.typpayroll = nvl(''' || to_char(p_typpayroll) || ''', t1.typpayroll)
        and ((t1.flgslip = ''1'') or (t1.flgslip = ''2''))
        and decode(''' || to_char(p_typcode) || ''', 1, t1.codpay, 2, t1.typinc, 3, t1.typpayr, 4, t1.typpayt, t1.typpayr) is not null
        and t1.typincexp in(''1'', ''2'', ''3'', ''4'', ''5'', ''6'')
        group by t3.costcent
        order by t3.costcent ');
    curid  := dbms_sql.open_cursor;
    dbms_sql.parse(curid, v_stmt_data, dbms_sql.native);
    dbms_sql.describe_columns(curid, colcnt, desctab);
    v_dummy := dbms_sql.execute(curid);
    while dbms_sql.fetch_rows(curid) > 0 loop
        v_count := v_count +1;
        exit; -- exit when found data
    end loop;
    dbms_sql.close_cursor(curid);
    -->>User37 #5035 Final Test Phase 1 V11 15/03/2021

    if v_count > 0 then --User37 #5035 Final Test Phase 1 V11 15/03/2021
    v_stmt := v_stmt || to_clob('
        from tsincexp t1, tcenter t2, tsinexct t3
       where t1.dteyrepay = t3.dteyrepay
        and t1.dtemthpay = t3.dtemthpay
        and t1.numperiod = t3.numperiod
        and t1.codempid  = t3.codempid
        and t1.codpay    = t3.codpay
        and t1.dteyrepay = ''' || to_char(p_dteyrepay) || '''
        and t3.codcomp  = t2.codcomp
        and t1.dtemthpay = nvl(''' || to_char(p_dtemthpay) || ''', t1.dtemthpay)
        and t1.numperiod = nvl(''' || to_char(p_numperiod) || ''', t1.numperiod)
        and t3.codcomp like ''' || p_codcomp || ''' || ''%''
        and ((''' || p_comgrp || ''' is not null and hcm_util.get_codcomp_level(t3.codcomp,1)
              in (select codcompy
                    from tcompny
                    where compgrp = ''' || to_char(p_comgrp) || '''))
              or (''' || to_char(p_comgrp) || ''' is null)
            )
        and t1.typpayroll = nvl(''' || to_char(p_typpayroll) || ''', t1.typpayroll)
        and ((t1.flgslip = ''1'') or (t1.flgslip = ''2''))
        and decode(''' || to_char(p_typcode) || ''', 1, t1.codpay, 2, t1.typinc, 3, t1.typpayr, 4, t1.typpayt, t1.typpayr) is not null
        and t1.typincexp in(''1'', ''2'', ''3'', ''4'', ''5'', ''6'')
        and hcm_secur.secur_main7(t2.codcomp, ''' ||to_char(global_v_coduser) || ''') = ''Y''
        and t1.numlvl between '||to_char(global_v_numlvlsalst) ||' and '||to_char(global_v_numlvlsalen)||'
        group by t3.costcent
        order by t3.costcent ');     

    for i in 1..v_rcnt_inc loop
      v_amtinc_arr(i) := 0;
    end loop;

    for i in 1..v_rcnt_ded loop
      v_amtded_arr(i) := 0;
    end loop;
    curid  := dbms_sql.open_cursor;
    dbms_sql.parse(curid, v_stmt, dbms_sql.native);
    dbms_sql.describe_columns(curid, colcnt, desctab);

    -- Define columns:
    for i in 1 .. colcnt loop
      if (desctab(i).col_name = upper('qtyemp')) then
        dbms_sql.define_column(curid, i, r1_qtyemp);
      elsif (desctab(i).col_name = upper('costcent')) then
        dbms_sql.define_column(curid, i, r1_costcent, 4000);
      elsif (desctab(i).col_name = upper('othinc')) then
        dbms_sql.define_column(curid, i, r1_othinc);
      elsif (desctab(i).col_name = upper('othded')) then
        dbms_sql.define_column(curid, i, r1_othded);
      else
        if (desctab(i).col_type = 2) then
          dbms_sql.define_column(curid, i, numvar);
        end if;
      end if;
    end loop;
    --User37 #5035 Final Test Phase 1 V11 15/03/2021 v_count := v_count +1;
    -- Fetch rows with DBMS_SQL package:
    v_dummy := dbms_sql.execute(curid);
    while dbms_sql.fetch_rows(curid) > 0 loop
      obj_data    := json_object_t();
      v_secur := true;
      v_rcnt := 0;
      for i in 1 .. colcnt loop
        if (desctab(i).col_name = upper('qtyemp')) then
          dbms_sql.column_value(curid, i, r1_qtyemp);
        elsif (desctab(i).col_name = upper('costcent')) then
          dbms_sql.column_value(curid, i, r1_costcent);
        elsif (desctab(i).col_name = upper('othinc')) then
          dbms_sql.column_value(curid, i, r1_othinc);
        elsif (desctab(i).col_name = upper('othded')) then
          dbms_sql.column_value(curid, i, r1_othded);
        elsif (desctab(i).col_type = 2) then
          v_rcnt := v_rcnt + 1;
          dbms_sql.column_value(curid, i, numvar);
          if v_rcnt <= v_rcnt_inc then
            v_amtinc_arr(v_rcnt) := numvar;
          elsif (v_rcnt - v_rcnt_inc) <= v_rcnt_ded then
            v_amtded_arr((v_rcnt - v_rcnt_inc)) := numvar;
          end if;
        end if;
      end loop;

        --<< user4 || 30/03/2023 || IPO-SS2101 4449#884
        begin
            select codpaypy7
            into v_codprovc
            from tcontrpy
            where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
            and dteeffec = (select max(dteeffec)
                            from tcontrpy
                            where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                            and dteeffec <= trunc(sysdate));
        exception when no_data_found then
            v_codprovc := null;
        end;
        --<< user4 || 30/03/2023 || IPO-SS2101 4449#884

      begin
          select nvl(sum(stddec(t3.amtpay, t3.codempid, v_chken)),0) sum_amtpay
            into v_amtprovc
            from tsincexp t1, tcenter t2, tsinexct t3
           where t1.dteyrepay = t3.dteyrepay
             and t1.dtemthpay = t3.dtemthpay
             and t1.numperiod = t3.numperiod
             and t1.codempid  = t3.codempid
             and t1.codpay    = t3.codpay
             and t2.codcomp   = t3.codcomp
             and t2.costcent  = t3.costcent
             and t2.costcent  = r1_costcent -- user4 || 30/03/2023 || IPO-SS2101 4449#884
             and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
             and t1.dteyrepay = p_dteyrepay
             and t1.dtemthpay = nvl(p_dtemthpay, t1.dtemthpay)
             and t1.numperiod = nvl(p_numperiod, t1.numperiod)
             and t1.codpay		= v_codprovc
             and t1.flgslip	  = '1'
             and t1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
             and hcm_secur.secur_main7(t2.codcomp, global_v_coduser) = 'Y';
      exception when no_data_found then
        v_amtprovc := 0;
      end ;

      v_totinc := 0;
      v_totded := 0;

      v_numseq := v_numseq + 1;
      for i in 1..v_amtinc_arr.count loop
        v_totinc := v_totinc + v_amtinc_arr(i);
      end loop;
      v_totinc := v_totinc + r1_othinc;
      for i in 1..v_amtded_arr.count loop
        v_totded := v_totded + v_amtded_arr(i);
      end loop;

      v_totded := v_totded + r1_othded;

        obj_data.put('coderror', 200);
        obj_data.put('response',' ');
--        obj_data.put('costcent',nvl(r1_costcent, ' '));
        obj_data.put('codcenter',nvl(r1_costcent, ' '));
--        obj_data.put('desc_costcent',nvl(get_tcoscent_name(r1_costcent,global_v_lang), ' '));
        obj_data.put('desc_codcenter',nvl(get_tcoscent_name(r1_costcent,global_v_lang), ' '));
        obj_data.put('countinc',nvl(to_char(v_rcnt_inc), '0'));
        obj_data.put('countded',nvl(to_char(v_rcnt_ded), '0'));
        obj_data.put('item3', ' ');
        obj_data.put('item4', ' ');
        obj_data.put('qtyemp',nvl(to_char(r1_qtyemp,'fm9999,999,999') , 0));
        obj_data.put('othinc',nvl(r1_othinc, 0));
        obj_data.put('amtinc',nvl(v_totinc, 0));
        obj_data.put('amtpay',nvl(v_amtprovc, 0));
        obj_data.put('othded',nvl(r1_othded, 0));
        obj_data.put('amtded',nvl(v_totded, 0));
        obj_data.put('amtnet',nvl(v_totinc - v_totded, 0));

        obj_data.put('image',nvl(v_codempid, ' '));
        obj_data.put('codcomp',nvl(r1_codcomp, ' '));
        obj_data.put('numseq',nvl(to_char(v_numseq), ' '));
        obj_data.put('codempid',nvl(v_codempid, ' '));
        obj_data.put('desc_codempid',nvl(get_temploy_name(v_codempid,global_v_lang), ' '));
        obj_data.put('amtincom',nvl(v_amtincom, 0));
        obj_data.put('numbank',nvl(to_char(v_numbank), ' '));

        for i in 1 .. v_rcnt_inc loop
            obj_data.put('amtinc'||to_char(i),v_amtinc_arr(i));
        end loop;
        for i in 1 .. v_rcnt_ded loop
            obj_data.put('amtded'||to_char(i),v_amtded_arr(i));
        end loop;

        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
    end loop;
    dbms_sql.close_cursor(curid);
    end if;--User37 #5035 Final Test Phase 1 V11 15/03/2021

    if v_count =  0  then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
    elsif not v_secur then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;
end HRPY5SX;

/
