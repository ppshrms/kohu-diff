--------------------------------------------------------
--  DDL for Package Body HRPY5JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5JX" is
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
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_month');
    if p_dtemthpay = 'A' then
      p_dtemthpay       := '';
    end if;
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_period'));
    p_flgpay            := upper(hcm_util.get_string_t(json_obj, 'p_flgpay'));

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

    cursor c_tcodrevn is
      select codcodec, decode(global_v_lang, '101', descode
                                          , '102', descodt
                                          , '103', descod3
                                          , '104', descod4
                                          , '105', descod5
                                          , '') descod
        from tcodrevn;

    cursor c_tcodslip_codinc is
      select codcodec, decode(global_v_lang, '101', descode
                                          , '102', descodt
                                          , '103', descod3
                                          , '104', descod4
                                          , '105', descod5
                                          , '') descod
        from tcodslip
       where substr(codcodec, 4, 1) = 1;

    cursor c_tcodslip_codded is
      select codcodec, decode(global_v_lang, '101', descode
                                          , '102', descodt
                                          , '103', descod3
                                          , '104', descod4
                                          , '105', descod5
                                          , '') descod
        from tcodslip
       where substr(codcodec, 4, 1) = 3;

    cursor c_tcodcert is
      select codcodec, decode(global_v_lang, '101', descode
                                          , '102', descodt
                                          , '103', descod3
                                          , '104', descod4
                                          , '105', descod5
                                          , '') descod
        from tcodcert;
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
    elsif p_typcode = '2' then
      for c1 in c_tcodrevn loop
        obj_codinc.put(c1.codcodec, c1.descod);
        obj_codded.put(c1.codcodec, c1.descod);
      end loop;
    elsif p_typcode = '3' then
      for c1 in c_tcodslip_codinc loop
        obj_codinc.put(c1.codcodec, c1.descod);
      end loop;
      for c2 in c_tcodslip_codded loop
        obj_codded.put(c2.codcodec, c2.descod);
      end loop;
    elsif p_typcode = '4' then
      for c1 in c_tcodcert loop
        obj_codinc.put(c1.codcodec, c1.descod);
        obj_codded.put(c1.codcodec, c1.descod);
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

    v_exist       boolean := false;
    v_secur       boolean := false;
    v_flgsecu     boolean := false;
    v_codempid    varchar2(30 char);
    v_codapp      varchar2(30 char) := 'HRPY5JX';
    v_amtincom    number  := 0;
    v_codprovc    tcontrpy.codpaypy7%type;
    v_amtprovc    number  := 0;
    v_numbank     temploy3.numbank%type;
    v_numseq      number  := 0;
    v_totinc      number  := 0;
    v_totded      number  := 0;
    v_max         number  := 0;
    v_row         number := 0;
    r1_numlvl     number;
    r1_othinc     number;
    r1_othded     number;
    r1_codcomp    varchar2(100 char);
    v_codcomp     varchar2(40 char);
    v_codempmt    varchar2(10 char);
    v_typpayroll  varchar2(10 char);
    v_num         number := 0;
    v_maxpay      number := 0;
    v_amtpay      number := 0;
    v_flgover     varchar2(1 char);
    v_ttaxcur     number := 0; --<< add  By: User25/Thanittha.y Date: 12/05/2018   ErrorNo: STA4610117

    type tcode is table of varchar2(20 char) index by binary_integer;
      v_codincom  tcode;
    type amtmax is table of number index by binary_integer;
      v_amtmax  amtmax;

    type v_char is table of varchar2(4 char) index by binary_integer;
      v_codcompy	v_char;
      v_codpaypy7 v_char;

--    obj_row         T_TSINCEXP := T_TSINCEXP();
--    json_str_output json;

    v_stmt        clob;
    v_stmt_inc    clob;
    v_stmt_othinc clob;
    v_stmt_ded    clob;
    v_stmt_othded clob;
    v_concat      varchar2(2 char);

    type curtype is ref cursor;
    src_cur       curtype;
    curid         number;
    desctab       dbms_sql.desc_tab;
    colcnt        number;
    namevar       varchar2(4000 char);
    numvar        number;
    datevar       date;
    empno         number := 100;
    v_dummy       integer;
    v_rcnt        number := 0;
    v_rcnt_inc    number := 0;
    v_rcnt_ded    number := 0;
    v_amtsso      ttaxcur.amtsocc%type;
    v_sumamtsso   number :=0;
    type amtinc_arr is table of number index by binary_integer;
      v_amtinc_arr  amtinc_arr;
    type amtded_arr is table of number index by binary_integer;
      v_amtded_arr  amtded_arr;

    cursor c_tcontrpy is
        select codcompy
          from tcontrpy
      group by codcompy
      order by codcompy;

    cursor c_tinitregd is
      select a.numseq, a.codinc, a.codded,a.codapp,a.codrep
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp = b.codapp
         and a.codapp  = p_codapp
         and a.codrep  = nvl(p_codrep, 'TEMP')
         and b.typcode = p_typcode
       order by a.numseq;

  begin
    obj_row          := json_object_t();
    v_max := 0;
    for r_tcontrpy in c_tcontrpy loop
      v_max := v_max + 1;
      v_codcompy(v_max) := r_tcontrpy.codcompy;
      begin
        select codpaypy7
          into v_codpaypy7(v_max)
          from tcontrpy
        where codcompy = r_tcontrpy.codcompy
          and dteeffec = (select max(dteeffec)
                            from tcontrpy
                            where	codcompy = r_tcontrpy.codcompy
                              and	dteeffec <= trunc(sysdate)
                          );
      exception when no_data_found then
        v_codpaypy7(v_max) := null;
      end;
    end loop;

    begin
      delete from ttemprpt
       where codempid = global_v_coduser
         and codapp   = p_codapp_report;
      commit;
    end;

    v_stmt := 'select codempid, codcomp, numlvl';
    v_concat := ',';
    for r0 in c_tinitregd loop
    -- INCOME
      if r0.codinc is not null then
        v_rcnt_inc := v_rcnt_inc + 1;
        v_stmt_inc := v_stmt_inc || v_concat || '
        sum(
          decode(
            decode(''' || p_typcode || ''', 1, codpay, 2, typinc, 3, typpayr, 4, typpayt, typpayr),
            ''' || r0.codinc || ''',
            nvl(stddec(amtpay, codempid, ''' || v_chken || '''), 0) * decode(''' || p_typcode || ''', 1, decode(typincexp, 4, -1, 5, -1, 6, -1, 1), 3, decode(typincexp, 4, -1, 5, -1, 6, -1, 1), decode(typincexp, 1, 1, 2, 1, 3, 1, 4, -1, 5, -1, 0)), 0)
        ) amtinc' || to_char(r0.numseq);
        v_stmt_othinc := nvl(v_stmt_othinc,'') || '
          ,''' || r0.codinc || ''', 0';
      end if;

      -- DEDUCT
      if r0.codded is not null then
        v_rcnt_ded := v_rcnt_ded + 1;
        v_stmt_ded := v_stmt_ded || v_concat || '
        sum(
          decode(
            decode(''' || p_typcode || ''', 1, codpay, 2, typinc, 3, typpayr, 4, typpayt, typpayr),
            ''' || r0.codded || ''',
            nvl(stddec(amtpay, codempid, ''' || v_chken || '''), 0) * decode(''' || p_typcode || ''', 1, decode(typincexp, 1, -1, 2, -1, 3, -1, 1), 3,decode(typincexp, 1, -1, 2, -1, 3, -1, 1), decode(typincexp, 6, 1, 0)), 0)
        ) amtded' || to_char(r0.numseq);
        v_stmt_othded := nvl(v_stmt_othded,'') || '
          ,''' || r0.codded || ''', 0';
      end if;
    end loop;

    if v_stmt_othinc is not null then
      v_stmt := v_stmt || v_concat || '
      sum(
        decode(
          decode(''' || p_typcode || ''', 1, codpay, 2, typinc, 3, typpayr, 4, typpayt, typpayr)
          ' || v_stmt_othinc || ',
          nvl(stddec(amtpay, codempid, ''' || v_chken || '''), 0)
            * decode(typincexp, 4, -1, 5, -1, 6, -1, 1)
            * decode(
              decode(''' || p_typcode || ''', 1,
                decode(typincexp, ''1'', ''1'',
                                  ''2'', ''1'',
                                  ''3'', ''1'',
                                  ''4'', ''3'',
                                  ''5'', ''3'',
                                  ''6'', ''3'',
                                  '' ''
                ), 2,
                substr(typinc, 4, 1), 3,
                substr(typpayr, 4, 1), 4,
                substr(typpayt, 4, 1), substr(typpayr, 4, 1)),
                1, 1,
                0
              )
            )
          ) othinc';
    end if;

    if v_stmt_othded is not null then
      v_stmt := v_stmt || v_concat || '
      sum(
        decode(
          decode(''' || p_typcode || ''', 1, codpay, 2, typinc, 3, typpayr, 4, typpayt, typpayr)
            ' || v_stmt_othded || ',
            nvl(stddec(amtpay, codempid, ''' || v_chken || '''), 0)
              * decode(typincexp, 1, -1, 2, -1, 3, -1, 1)
              * decode(
                  decode(''' || p_typcode || ''', 1,
                    decode(typincexp, ''1'', ''1'',
                                      ''2'', ''1'',
                                      ''3'', ''1'',
                                      ''4'', ''3'',
                                      ''5'', ''3'',
                                      ''6'', ''3'',
                                      '' ''
                    ), 2,
                  substr(typinc, 4, 1), 3,
                  substr(typpayr, 4, 1), 4,
                  substr(typpayt, 4, 1), substr(typpayr, 4, 1)
                ),
            3, 1,
            0
          )
        )
      ) othded';
    end if;
    v_stmt := v_stmt || v_stmt_inc || v_stmt_ded;
    v_stmt := v_stmt || '
        from tsincexp
      where dteyrepay = ''' || to_char(p_dteyrepay) || '''
        and dtemthpay = nvl(''' || to_char(p_dtemthpay) || ''', dtemthpay)
        and numperiod = nvl(''' || to_char(p_numperiod) || ''', numperiod)
        and codcomp like ''' || p_codcomp || ''' || ''%''
        and ((''' || p_comgrp || ''' is not null and hcm_util.get_codcomp_level(codcomp,1)
              in (select codcompy
                    from tcompny
                    where compgrp = ''' || p_comgrp || '''))
              or (''' || p_comgrp || ''' is null)
            )
        and typpayroll = nvl(''' || p_typpayroll || ''',typpayroll)
        and ((''' || p_flgpay || ''' = ''I'' and flgslip = ''1'')
              or (''' || p_flgpay || ''' = ''O'' and flgslip = ''2'')
              or (''' || p_flgpay || ''' = ''A'')
            )
        and decode(''' || p_typcode || ''', 1, codpay, 2, typinc, 3, typpayr, 4, typpayt, typpayr) is not null
        and typincexp in(''1'', ''2'', ''3'', ''4'', ''5'', ''6'')
        group by codcomp,codempid,numlvl
        order by codcomp,codempid,numlvl';
        
    /*v_stmt := v_stmt || '
        from tsincexp
      where dteyrepay = ''' || to_char(p_dteyrepay) || '''
        and dtemthpay = nvl(''' || to_char(p_dtemthpay) || ''', dtemthpay)
        and numperiod = nvl(''' || to_char(p_numperiod) || ''', numperiod)
        and codcomp like ''' || p_codcomp || ''' || ''%''
        and ((''' || p_comgrp || ''' is not null and codcomp
              in (select codcomp
                    from tcenter
                    where compgrp = ''' || p_comgrp || '''))
              or (''' || p_comgrp || ''' is null)
            )
        and typpayroll = nvl(''' || p_typpayroll || ''',typpayroll)
        and ((''' || p_flgpay || ''' = ''I'' and flgslip = ''1'')
              or (''' || p_flgpay || ''' = ''O'' and flgslip = ''2'')
              or (''' || p_flgpay || ''' = ''A'')
            )
        and decode(''' || p_typcode || ''', 1, codpay, 2, typinc, 3, typpayr, 4, typpayt, typpayr) is not null
        and typincexp in(''1'', ''2'', ''3'', ''4'', ''5'', ''6'')
        group by codcomp,codempid,numlvl
        order by codcomp,codempid,numlvl';*/  -- user18 27/12/2021

    for i in 1..v_rcnt_inc loop
--    for i in 1..100 loop
      v_amtinc_arr(i) := 0;
    end loop;

    for i in 1..v_rcnt_ded loop
--    for i in 1..100 loop
      v_amtded_arr(i) := 0;
    end loop;
    curid  := dbms_sql.open_cursor;
    dbms_sql.parse(curid, v_stmt, dbms_sql.native);
    dbms_sql.describe_columns(curid, colcnt, desctab);

    -- Define columns:
    for i in 1 .. colcnt loop
      if desctab(i).col_type = 2 then
        dbms_sql.define_column(curid, i, numvar);
      elsif desctab(i).col_type = 12 then
        dbms_sql.define_column(curid, i, datevar);
      else
        dbms_sql.define_column(curid, i, namevar, 4000);
      end if;
    end loop;

    -- Fetch rows with DBMS_SQL package:
    v_dummy := dbms_sql.execute(curid);
    while dbms_sql.fetch_rows(curid) > 0 loop
      v_rcnt := 0;
      obj_data    := json_object_t();
      for i in 1 .. colcnt loop
        if (desctab(i).col_name = upper('codempid')) then
          dbms_sql.column_value(curid, i, v_codempid);
        elsif (desctab(i).col_name = upper('codcomp')) then
          dbms_sql.column_value(curid, i, r1_codcomp);
        elsif (desctab(i).col_name = upper('numlvl')) then
          dbms_sql.column_value(curid, i, r1_numlvl);
        elsif (desctab(i).col_name = upper('othinc')) then
          dbms_sql.column_value(curid, i, r1_othinc);
        elsif (desctab(i).col_name = upper('othded')) then
          dbms_sql.column_value(curid, i, r1_othded);

        -- elsif (desctab(i).col_type = 1) then
        --   dbms_sql.column_value(curid, i, namevar);
        elsif (desctab(i).col_type = 2) then
          v_rcnt := v_rcnt + 1;
          dbms_sql.column_value(curid, i, numvar);
          if v_rcnt <= v_rcnt_inc then
            v_amtinc_arr(v_rcnt) := numvar;
          elsif (v_rcnt - v_rcnt_inc) <= v_rcnt_ded then
            v_amtded_arr((v_rcnt - v_rcnt_inc)) := numvar;
          end if;
        -- elsif (desctab(i).col_type = 12) then
        --   dbms_sql.column_value(curid, i, datevar);
        end if;
      end loop;

      v_exist := true;
      v_flgsecu := secur_main.secur1(r1_codcomp,r1_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,global_v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_flgsecu then
        v_secur := true;

        for i in 1..10 loop
          v_codincom(i) := null;
          v_amtmax(i)   := null;
        end loop;

        begin
          select codcomp, codempmt,numbank
            into v_codcomp, v_codempmt,v_numbank
            from temploy1 a, temploy3 b
          where a.codempid = b.codempid
          and   a.codempid = v_codempid;
        exception when no_data_found then
          v_numbank := null;
        end;
        
       begin
          select amtmax1,amtmax2,amtmax3,amtmax4,amtmax5,
                  amtmax6,amtmax7,amtmax8,amtmax9,amtmax10
            into v_amtmax(1),v_amtmax(2),v_amtmax(3),v_amtmax(4),v_amtmax(5),
                  v_amtmax(6),v_amtmax(7),v_amtmax(8),v_amtmax(9),v_amtmax(10)
            from tcontpmd
          where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
            and codempmt = v_codempmt
            and dteeffec = (select max(dteeffec)
                              from   tcontpmd
                              where  codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                                and  codempmt = v_codempmt
                                and  dteeffec <= sysdate)
            and  amtmax1||amtmax2||amtmax3||amtmax4||amtmax5||
                  amtmax6||amtmax7||amtmax8||amtmax9||amtmax10 is not null;
        exception when no_data_found then
          goto normal_process;
        end;

        begin
          select codincom1,codincom2,codincom3,codincom4,codincom5,
                  codincom6,codincom7,codincom8,codincom9,codincom10
            into v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),
                  v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
            from tcontpms
          where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
            and dteeffec = (select max(dteeffec)
                              from tcontpms
                             where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                               and dteeffec <= trunc(sysdate));
        exception when no_data_found then
          null;
        end;

--        for i in 1..10 loop
--          if v_codincom(i) is not null and v_amtmax(i) is not null then
--            chk_over_income_rep(v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codincom(i), global_v_coduser, global_v_lang, v_maxpay, v_amtpay, v_flgover);
--          end if; --v_codincom(i) is not null and v_amtmax(i) is not null
--        end loop; --for i in 1..10
        <<normal_process>>
        null;
        begin
          select avg(stddec(amtincom1,codempid,v_chken)) , sum(nvl(stddec(amtnet,codempid,v_chken),0)) 
            into v_amtincom ,v_ttaxcur
            from ttaxcur
          where dteyrepay = p_dteyrepay
            and dtemthpay = nvl(p_dtemthpay, dtemthpay)
            and numperiod = nvl(p_numperiod, numperiod)
            and codempid  = v_codempid;
        exception when no_data_found then
          v_amtincom := 0;
          v_ttaxcur  := 0;
        end ;      
        v_codprovc := null;
        for i in 1..v_max loop
          if v_codcompy(i) = hcm_util.get_codcomp_level(r1_codcomp, 1) then
            v_codprovc := v_codpaypy7(i);
            exit;
          end if;
        end loop;
        begin
          select nvl(sum(stddec(amtpay,codempid,v_chken)),0) sum_amtpay
            into v_amtprovc
            from tsincexp
            where codempid  = v_codempid
              and dteyrepay = p_dteyrepay
              and dtemthpay = nvl(p_dtemthpay, dtemthpay)
              and numperiod = nvl(p_numperiod, numperiod)
              and codpay		 = v_codprovc
              and flgslip	 = '1';
        exception when no_data_found then
          v_amtprovc := 0;
        end ;

        if p_dtemthpay is null then
          for k in 1..12 loop
           begin
              select sum(stddec(a.amtsocc,a.codempid,v_chken))--User37 #1940 Final Test Phase 1 V11 08/03/2021 stddec(a.amtsocc,a.codempid,v_chken)
                into v_amtsso
                from ttaxcur a,temploy1 b
              where a.codempid   = b.codempid
                and a.dteyrepay  = p_dteyrepay
                and a.dtemthpay  = nvl(k, dtemthpay)
                and a.numperiod  = nvl(p_numperiod, numperiod)
                and a.codempid   = v_codempid;
            exception when no_data_found then
              v_amtsso := 0;
            end;
            v_sumamtsso := v_sumamtsso + v_amtsso;
          end loop;
        else
          begin
            select sum(stddec(a.amtsocc,a.codempid,v_chken))--User37 #1940 Final Test Phase 1 V11 08/03/2021 stddec(a.amtsocc,a.codempid,v_chken)
              into v_amtsso
              from ttaxcur a,temploy1 b
            where a.codempid   = b.codempid
              and a.dteyrepay  = p_dteyrepay
              and a.dtemthpay  = nvl(p_dtemthpay, dtemthpay)
              and a.numperiod  = nvl(p_numperiod, numperiod)
              and a.codempid   = v_codempid;
          exception when no_data_found then
            v_amtsso := null;
          end;
          v_sumamtsso := v_amtsso;
        end if;

        v_numseq := v_numseq + 1;
        v_totinc := 0;
        for i in 1..v_amtinc_arr.count loop
          v_totinc := v_totinc + v_amtinc_arr(i);
        end loop;
        v_totinc := v_totinc + r1_othinc;

        v_totded := 0;
        for i in 1..v_amtded_arr.count loop
          v_totded := v_totded + v_amtded_arr(i);
        end loop;
        v_totded := v_totded + r1_othded;

        if p_flgpay = 'O' then
          v_ttaxcur := v_totinc - v_totded;
          v_sumamtsso := 0;
          v_amtprovc := 0;
        end if;

        obj_data.put('coderror', 200);
        obj_data.put('response','');
        obj_data.put('image',nvl(get_emp_img(v_codempid), ''));
        obj_data.put('codcomp',nvl(r1_codcomp, ''));
        obj_data.put('numseq',nvl(to_char(v_numseq), ''));
        obj_data.put('codempid',nvl(v_codempid, ''));
        obj_data.put('desc_codempid',nvl(get_temploy_name(v_codempid,global_v_lang), ''));
        obj_data.put('amtincom',to_char(nvl(v_amtincom, 0),'fm999,999,999,990.00'));
        obj_data.put('numbank',nvl(to_char(v_numbank), ''));
        obj_data.put('othinc',to_char(nvl(r1_othinc, 0),'fm999,999,999,990.00'));
        obj_data.put('amtinc',to_char(nvl(v_totinc, 0),'fm999,999,999,990.00'));
        obj_data.put('amtpay',to_char(nvl(v_amtprovc, 0),'fm999,999,999,990.00'));
        obj_data.put('othded',to_char(nvl(r1_othded, 0),'fm999,999,999,990.00'));
        obj_data.put('amtded',to_char(nvl(v_totded, 0),'fm999,999,999,990.00'));
        obj_data.put('amtnet',to_char(nvl(v_ttaxcur, 0),'fm999,999,999,990.00'));
        obj_data.put('amtsso',to_char(nvl(v_sumamtsso, 0),'fm999,999,999,990.00'));

        for i in 1 .. v_rcnt_inc loop
            obj_data.put('amtinc'||to_char(i),to_char(v_amtinc_arr(i),'fm999,999,999,990.00'));
        end loop;
        for i in 1 .. v_rcnt_ded loop
            obj_data.put('amtded'||to_char(i),to_char(v_amtded_arr(i),'fm999,999,999,990.00'));
        end loop;

        obj_row.put(to_char(v_row), obj_data);
        v_row        := v_row + 1;
      end if; -- v_flgsecu
    end loop;
    dbms_sql.close_cursor(curid);

    if not v_exist then
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

  procedure get_abnormal_amount (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
    v_abnormal          number := 0;
  begin
    initial_value (json_str_input);
    begin
      select count(*) into v_abnormal
        from ttemprpt
       where codapp   = p_codapp_report
         and codempid = global_v_coduser;
    exception when no_data_found then
      v_abnormal := 0;
    end;
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('abnormal', v_abnormal);


    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_abnormal_amount;

  procedure gen_data_over (json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    cursor c_over is
      select numseq, item1, item2, item3, item4, temp31, temp32, temp33
        from ttemprpt
       where codapp = p_codapp_report
         and codempid = global_v_coduser
       order by numseq;
  begin
    initial_value (json_str_input);
    obj_row             := json_object_t();
    for r1 in c_over loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codempid', r1.item1);
      obj_data.put('desc_codempid', r1.item2);
      obj_data.put('codpay', r1.item3);
      obj_data.put('typpay', r1.item4);
      obj_data.put('amtpay', to_char(r1.temp31,'9,999,990.00'));
      obj_data.put('amtmax', to_char(r1.temp32,'9,999,990.00'));
      obj_data.put('numperiod', r1.temp33);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'tsincexp');
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_data_over;
end HRPY5JX;

/
