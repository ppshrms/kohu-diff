--------------------------------------------------------
--  DDL for Package Body HRPMB2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMB2E" is
-- last update: 20/05/2020 16:40
-- last update: 02/02/2021 19:55
procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_yearst            := to_char(hcm_util.get_string_t(json_obj,'p_yearst'));
    p_yearen            := to_char(hcm_util.get_string_t(json_obj,'p_yearen'));

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempmt          := hcm_util.get_string_t(json_obj,'p_codempmt');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codtrn            := hcm_util.get_string_t(json_obj,'p_codtrn');

    if p_codempmt is null then
      begin
        select codempmt, codcomp
          into p_codempmt, p_codcomp
          from temploy1
         where codempid     = p_codempid_query;
      exception when no_data_found then
        null;
      end;
    end if;
  end;
  --
  procedure check_index is
    v_secur     boolean := false;
  begin
    if p_codempid_query is null then
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    else
      v_secur     := secur_main.secur2( p_codempid_query,global_v_coduser,
                                      global_v_zminlvl,global_v_zwrklvl,p_zupdsal,
                                      global_v_numlvlsalst,global_v_numlvlsalen);
      if not v_secur then
        param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_yearst is null then
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_yearen is null then
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_rcnt      number  := 0;
    v_ocodempid varchar2(20 char);
    cursor c1 is
      select codempid,dteeffec,numseq,codtrn,codcomp,codpos,numannou,ocodempid,codempmt
        from thismove
       where (codempid = p_codempid_query or instr(v_ocodempid,'['||ocodempid||']') > 0)
         and to_char(dteeffec,'yyyy') between p_yearst and p_yearen
      order by dteeffec desc,numseq;
  begin
     v_ocodempid   := get_ocodempid(p_codempid_query);
    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('numseq',i.numseq);
      obj_data.put('codtrn',i.codtrn);
      obj_data.put('desc_codtrn',get_tcodec_name('TCODMOVE',i.codtrn,global_v_lang));
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('codpos',get_tpostn_name(i.codpos,global_v_lang));
      obj_data.put('numannou',i.numannou);
      obj_data.put('ocodempid',i.ocodempid);
      obj_data.put('codempmt',i.codempmt);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_submit is
    v_sysdate   date  := trunc(sysdate);
    v_code      varchar2(100 char);
    v_typmove   tcodmove.typmove%type;
    v_secur     boolean := false;
    v_count     number;
    v_codtrn    thismove.codtrn%type;
  begin
    if p_dteeffec > v_sysdate then --//Question
      param_msg_error   := get_error_msg_php('PM0001',global_v_lang);
      return;
    end if;

    begin
      select 'Y',typmove
        into v_code,v_typmove
        from tcodmove
       where codcodec   = p_codtrn;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODMOVE');
      return;
    end;

    if v_typmove = '5' then
      param_msg_error   := get_error_msg_php('PM0003',global_v_lang);
      return;
    end if;

    begin
        select count(*)
          into v_count
          from thismove
         where codempid = p_codempid_query
           and dteeffec = p_dteeffec
           and numseq = p_numseq;
    exception when others then
        v_count := 0;
    end;

    if v_count > 0 then
        begin
            select codtrn
              into v_codtrn
              from thismove
             where codempid = p_codempid_query
               and dteeffec = p_dteeffec
               and numseq = p_numseq;
        exception when others then
            v_codtrn := 'xxx';
        end;

        if v_codtrn <> p_codtrn then
            param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'thismove');
            return;
        end if;

    end if;

    v_secur     := secur_main.secur2( p_codempid_query,global_v_coduser,
                                      global_v_zminlvl,global_v_zwrklvl,p_zupdsal,
                                      global_v_numlvlsalst,global_v_numlvlsalen);
--    if v_typmove = 'A' and p_zupdsal = 'N' then
--      param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
--      return;
--    end if;
  end;
  --
  procedure gen_move_detail(json_str_output out clob) is
    obj_data      json_object_t;
    v_qtydatrqy   number;
    v_qtydatrqm   number;
    v_qtydue      number;
    v_exists      boolean := false;
    v_typmove     tcodmove.typmove%type;
    v_secur       boolean := false;
    v_qty_duepr   number;
    v_hireyear    number;
    v_hiremonth   number;
    cursor c1 is
      select codempid,dteeffec,numseq,codtrn,
             ocodempid,typmove,numannou,codcomp,
             codpos,codjob,numlvl,codbrlc,codempmt,codcalen,
             typemp,typpayroll,jobgrade,codgrpgl,staemp,
             stapost2,convert(desnote,'utf8') as desnote,qtydatrq,dteduepr,
             dteeval,scoreget,codrespr,flgadjin,codexemp,
             codcurr
        from thismove
       where codempid   = p_codempid_query
         and dteeffec   = p_dteeffec
         and numseq     = p_numseq
         and codtrn     = p_codtrn;

    cursor c2 is
      select codempid,ocodempid,codcomp,
             codpos,codjob,numlvl,codbrlc,codempmt,codcalen,
             typemp,typpayroll,jobgrade,codgrpgl,staemp
        from temploy1
       where codempid   = p_codempid_query
         and codempid not in (select codempid
                                from thismove
                               where codempid   = p_codempid_query
                                 and dteeffec   = p_dteeffec
                                 and numseq     = p_numseq
                                 and codtrn     = p_codtrn) ;
  begin
    if is_report then
      for i in c1 loop
        v_qty_duepr   := (i.dteduepr - i.dteeffec) + 1;
        if i.qtydatrq >= 12 then
          v_hireyear    := floor(i.qtydatrq / 12);
          v_hiremonth   := mod(i.qtydatrq, 12);
        else
          v_hireyear    := 0;
          v_hiremonth   := i.qtydatrq;
        end if;

        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,
                              item5,item6,item7,item8,item9,
                              item10,item11,item12,item13,item14,
                              item15,item16,item17,item18,item19,
                              item20,item21,item22,item23,item24,
                              item25,item26,item27,item28,item29,
                              item30,item31,item32,item33,item34,
                              item35,item36,item37,item38)
            values (global_v_codempid, 'HRPMB2E',r_numseq,'DETAIL',i.codempid,i.codtrn,to_char(i.dteeffec,'dd/mm/yyyy'),
                    i.numannou,
                    i.typemp ||' - '||get_tcodec_name('TCODCATG',i.typemp,global_v_lang),
                    get_tcenter_name(i.codcomp ,global_v_lang),
                    i.typpayroll ||' - '||get_tcodec_name('TCODTYPY',i.typpayroll,global_v_lang),
                    i.codpos ||' - '|| get_tpostn_name (i.codpos ,global_v_lang ),
                    i.jobgrade ||' - '||get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang) ,
                    i.numlvl,
                    i.codjob ||' - '||get_tjobcode_name(i.codjob,global_v_lang),
                    i.codgrpgl ||' - '||get_tcodec_name('TCODGRPGL',i.codgrpgl,global_v_lang),
                    i.numlvl,
                    get_tlistval_name('NAMESTAT',i.staemp,global_v_lang),
                    get_tlistval_name('STAPOST2', i.stapost2, global_v_lang),
                    i.codbrlc ||' - '||get_tcodec_name('TCODLOCA',i.codbrlc,global_v_lang),
                    i.typemp,
                    i.codempmt ||' - '||get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang),
                    i.codcalen ||' - '||get_tcodec_name('TCODWORK',i.codcalen,global_v_lang),
                    i.desnote,
                    i.codcurr ||' - '||get_tcodec_name('TCODCURR',i.codcurr,global_v_lang),
                    v_hireyear ||' '||get_label_name('HRPMB2E2',global_v_lang,290)||' '||v_hiremonth||' '||get_label_name('HRPMB2E2',global_v_lang,300),
                    v_hiremonth,
                    v_qty_duepr ||' '||get_label_name('HRPMB2E2',global_v_lang,280),
                    i.flgadjin,
                    to_char(add_months(i.dteduepr,global_v_zyear*12),'dd/mm/yyyy'),
                    to_char(add_months(i.dteeval,global_v_zyear*12),'dd/mm/yyyy'),
                    i.scoreget,
                    case i.codrespr
                      when 'P' then
                        get_label_name('HRPMB2E3',global_v_lang,120)
                      when 'N' then
                        get_label_name('HRPMB2E3',global_v_lang,130)
                      when 'E' then
                        get_label_name('HRPMB2E3',global_v_lang,140)
                     end,
                    i.codexemp ||' - '||get_tcodec_name('TCODEXEM',i.codexemp,global_v_lang),
                    i.codrespr,
                    i.ocodempid,
                    p_numseq,
                    get_temploy_name(p_codempid_query, global_v_lang),
                    p_numseq,
                    get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang),
                    to_char(add_months(p_dteeffec,global_v_zyear*12),'dd/mm/yyyy')
                    );
        r_numseq := r_numseq + 1;
      end loop;
    else
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codempid',p_codempid_query);
      obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_data.put('numseq',p_numseq);
      obj_data.put('codtrn',p_codtrn);
      for i in c1 loop
        v_exists      := true;
        v_qtydatrqy   := trunc(i.qtydatrq/12);
        v_qtydatrqm   := mod(i.qtydatrq,12);
        v_qtydue      := (i.dteduepr - i.dteeffec) + 1;
        obj_data.put('ocodempid',i.ocodempid);
        obj_data.put('typmove',i.typmove);
        obj_data.put('numannou',i.numannou);
        obj_data.put('codcomp',i.codcomp);
        obj_data.put('codpos',i.codpos);
        obj_data.put('codjob',i.codjob);
        obj_data.put('numlvl',i.numlvl);
        obj_data.put('codbrlc',i.codbrlc);
        obj_data.put('codempmt',i.codempmt);
        obj_data.put('codcalen',i.codcalen);
        obj_data.put('typemp',i.typemp);
        obj_data.put('typpayroll',i.typpayroll);
        obj_data.put('jobgrade',i.jobgrade);
        obj_data.put('codgrpgl',i.codgrpgl);
        obj_data.put('staemp',i.staemp);
        obj_data.put('stapost2',i.stapost2);
        obj_data.put('desnote',i.desnote);---dd
        obj_data.put('probation',v_qtydue);
        obj_data.put('qtydatrqy',v_qtydatrqy);
        obj_data.put('qtydatrqm',v_qtydatrqm);
        obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy'));
        obj_data.put('dteeval',to_char(i.dteeval,'dd/mm/yyyy'));
        obj_data.put('scoreget',i.scoreget);
        obj_data.put('codrespr',i.codrespr);
        obj_data.put('flgadjin',i.flgadjin);
        obj_data.put('codexemp',i.codexemp);
--        if i.codtrn = '0003' and i.codrespr = 'N' then
--            p_zupdsal := 'N';
--        end if;
      end loop;
      if not v_exists then
        begin
          select typmove
            into v_typmove
            from tcodmove
           where codcodec   = p_codtrn;
        exception when no_data_found then
          null;
        end;
        for i in c2 loop
          obj_data.put('ocodempid',i.ocodempid);
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('codpos',i.codpos);
          obj_data.put('codjob',i.codjob);
          obj_data.put('numlvl',i.numlvl);
          obj_data.put('codbrlc',i.codbrlc);
          obj_data.put('codempmt',i.codempmt);
          obj_data.put('codcalen',i.codcalen);
          obj_data.put('typemp',i.typemp);
          obj_data.put('typpayroll',i.typpayroll);
          obj_data.put('jobgrade',i.jobgrade);
          obj_data.put('codgrpgl',i.codgrpgl);
          obj_data.put('staemp',i.staemp);
        end loop;
        obj_data.put('typmove',v_typmove);
      end if;
      obj_data.put('zupdsal',p_zupdsal);
      json_str_output   := obj_data.to_clob;
    end if;
  end;
  --
  procedure get_move_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_submit;
    if param_msg_error is null then
      gen_move_detail(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_adj_income_table(json_str_output out clob) is
    v_json_str_income   clob;
    v_rcnt              number  := 0;
    v_json_income       json_object_t;
    v_json_income_row   json_object_t;
    obj_data            json_object_t;
    obj_row             json_object_t;

    arr_amtincomo       t_amt;
    arr_amtincom        t_amt;
    arr_amtincadj       t_amt;

    v_codincome         tcontpms.codincom1%type;
    v_amount            number;
    v_amtmax            number;

    v_item5 varchar2(1000 char);
    v_item6 varchar2(1000 char);
    v_item7 varchar2(1000 char);
  begin
    --//assign null for error no_data_found
    for i in 1..10 loop
      arr_amtincomo(i)  := null;
      arr_amtincom(i)   := null;
      arr_amtincadj(i)  := null;
    end loop;

    begin
      select stddec(amtincom1,p_codempid_query,global_v_chken),
             stddec(amtincom2,p_codempid_query,global_v_chken),
             stddec(amtincom3,p_codempid_query,global_v_chken),
             stddec(amtincom4,p_codempid_query,global_v_chken),
             stddec(amtincom5,p_codempid_query,global_v_chken),
             stddec(amtincom6,p_codempid_query,global_v_chken),
             stddec(amtincom7,p_codempid_query,global_v_chken),
             stddec(amtincom8,p_codempid_query,global_v_chken),
             stddec(amtincom9,p_codempid_query,global_v_chken),
             stddec(amtincom10,p_codempid_query,global_v_chken)
        into arr_amtincomo(1),arr_amtincomo(2),arr_amtincomo(3),arr_amtincomo(4),arr_amtincomo(5),
             arr_amtincomo(6),arr_amtincomo(7),arr_amtincomo(8),arr_amtincomo(9),arr_amtincomo(10)
        from temploy3
       where codempid   = p_codempid_query;
    exception when no_data_found then
      null;
    end;

    begin
      select stddec(amtincom1,p_codempid_query,global_v_chken),
             stddec(amtincom2,p_codempid_query,global_v_chken),
             stddec(amtincom3,p_codempid_query,global_v_chken),
             stddec(amtincom4,p_codempid_query,global_v_chken),
             stddec(amtincom5,p_codempid_query,global_v_chken),
             stddec(amtincom6,p_codempid_query,global_v_chken),
             stddec(amtincom7,p_codempid_query,global_v_chken),
             stddec(amtincom8,p_codempid_query,global_v_chken),
             stddec(amtincom9,p_codempid_query,global_v_chken),
             stddec(amtincom10,p_codempid_query,global_v_chken),
             stddec(amtincadj1,p_codempid_query,global_v_chken),
             stddec(amtincadj2,p_codempid_query,global_v_chken),
             stddec(amtincadj3,p_codempid_query,global_v_chken),
             stddec(amtincadj4,p_codempid_query,global_v_chken),
             stddec(amtincadj5,p_codempid_query,global_v_chken),
             stddec(amtincadj6,p_codempid_query,global_v_chken),
             stddec(amtincadj7,p_codempid_query,global_v_chken),
             stddec(amtincadj8,p_codempid_query,global_v_chken),
             stddec(amtincadj9,p_codempid_query,global_v_chken),
             stddec(amtincadj10,p_codempid_query,global_v_chken)
        into arr_amtincom(1),arr_amtincom(2),arr_amtincom(3),arr_amtincom(4),arr_amtincom(5),
             arr_amtincom(6),arr_amtincom(7),arr_amtincom(8),arr_amtincom(9),arr_amtincom(10),
             arr_amtincadj(1),arr_amtincadj(2),arr_amtincadj(3),arr_amtincadj(4),arr_amtincadj(5),
             arr_amtincadj(6),arr_amtincadj(7),arr_amtincadj(8),arr_amtincadj(9),arr_amtincadj(10)
        from thismove
       where codempid   = p_codempid_query
         and dteeffec   = p_dteeffec
         and numseq     = p_numseq
         and codtrn     = p_codtrn;
    exception when no_data_found then
      null;
    end;

    for i in 1..10 loop

      if arr_amtincom(i) is not null and arr_amtincom(i) <> 0 then
        arr_amtincom(i)   := greatest(arr_amtincom(i),0);
        arr_amtincadj(i)  := greatest(arr_amtincadj(i),0);
        arr_amtincomo(i)  := greatest(arr_amtincom(i),0) - greatest(arr_amtincadj(i),0);
      else
        arr_amtincom(i)   := 0;
        arr_amtincadj(i)  := 0;
        arr_amtincomo(i)  := greatest(arr_amtincomo(i),0);
      end if;

    end loop;

    v_json_str_income   := hcm_pm.get_codincom('{"p_codcompy":"'||hcm_util.get_codcomp_level(p_codcomp,1)||
                                              '","p_dteeffec":"'||to_char(p_dteeffec,'dd/mm/yyyy')||
                                              '","p_codempmt":"'||p_codempmt||
                                              '","p_lang":"'||global_v_lang||'"}');
    v_json_income       := json_object_t(v_json_str_income);

    obj_row     := json_object_t();
    if is_report then
      for i in 0..(v_json_income.get_size - 1) loop
        v_json_income_row   := hcm_util.get_json_t(v_json_income,to_char(i));
        v_codincome         := hcm_util.get_string_t(v_json_income_row,'codincom');
        if v_codincome is not null then
          v_amtmax    := hcm_util.get_string_t(v_json_income_row,'amtmax');
          v_amount    := nvl(arr_amtincadj(i + 1),0) + arr_amtincomo(i + 1);
          v_item5 := hcm_util.get_string_t(v_json_income_row,'codincom');
          v_item6 := hcm_util.get_string_t(v_json_income_row,'desincom');
          v_item7 := hcm_util.get_string_t(v_json_income_row,'desunit');
          insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,
                                item5,item6,item7,item8,item9,
                                item10,item11)
          values (global_v_codempid, 'HRPMB2E',r_numseq,'TABLE',p_codempid_query,p_codtrn,to_char(p_dteeffec,'dd/mm/yyyy'),
                  v_item5,
                  v_item6,
                  v_item7,
                  trim(to_char(nvl(arr_amtincomo(i + 1),0), '999,999,990.00')),
                  trim(to_char(nvl(arr_amtincadj(i + 1),0), '999,999,990.00')),
                  trim(to_char(nvl(v_amount,0), '999,999,990.00')),p_numseq);

          r_numseq := r_numseq + 1;
        end if;
      end loop;
    else
      for i in 0..(v_json_income.get_size - 1) loop
        v_json_income_row   := hcm_util.get_json_t(v_json_income,to_char(i));
        v_codincome         := hcm_util.get_string_t(v_json_income_row,'codincom');
        if v_codincome is not null then
          obj_data  := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('codincom',hcm_util.get_string_t(v_json_income_row,'codincom'));
          obj_data.put('desincom',hcm_util.get_string_t(v_json_income_row,'desincom'));
          obj_data.put('desunit',hcm_util.get_string_t(v_json_income_row,'desunit'));
          obj_data.put('amtmax',hcm_util.get_string_t(v_json_income_row,'amtmax'));
          obj_data.put('amtincomo',arr_amtincomo(i + 1));
          obj_data.put('amtincom',nvl(arr_amtincomo(i + 1),0) + nvl(arr_amtincadj(i + 1),0));
          obj_data.put('amtincadj',arr_amtincadj(i + 1));
          obj_row.put(to_char(v_rcnt),obj_data);
          v_rcnt    := v_rcnt + 1;
        end if;
      end loop;
    end if;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure gen_cal_adj_income(json_str_input in clob,json_str_output out clob) is
    arr_amtincomo       t_amt;
    arr_amtincadj       t_amt;

    v_amthr_oincome     number;
    v_amtday_oincome    number;
    v_amtmth_oincome    number;
    v_amthr_incadj      number;
    v_amtday_incadj     number;
    v_amtmth_incadj     number;

    v_json              json_object_t;
    v_json_input        json_object_t;
    v_json_income_row   json_object_t;
    obj_data            json_object_t;

    v_codcurr           tcontrpy.codcurr%type;
    v_desc_codcurr      varchar2(1000 char);
    v_codcompy          tcompny.codcompy%type;
    v_codempmt          temploy1.codempmt%type;
  begin
    --//assign null for error no_data_found
    for i in 1..10 loop
      arr_amtincomo(i)  := null;
      arr_amtincadj(i)  := null;
    end loop;
    v_json        := json_object_t(json_str_input);
    v_json_input  := hcm_util.get_json_t(v_json,'param_json');
    begin
      select hcm_util.get_codcomp_level(codcomp,1),codempmt
        into v_codcompy,v_codempmt
        from temploy1
       where codempid   = p_codempid_query;
    exception when no_data_found then
      null;
    end;
    for i in 0..(v_json_input.get_size - 1) loop
      v_json_income_row       := hcm_util.get_json_t(v_json_input,to_char(i));
      arr_amtincomo(i + 1)    := hcm_util.get_string_t(v_json_income_row,'amtincomo');
      arr_amtincadj(i + 1)    := hcm_util.get_string_t(v_json_income_row,'amtincadj');
    end loop;
    --//Old income
    get_wage_income(v_codcompy, v_codempmt,
                    arr_amtincomo(1), arr_amtincomo(2), arr_amtincomo(3), arr_amtincomo(4), arr_amtincomo(5),
                    arr_amtincomo(6), arr_amtincomo(7), arr_amtincomo(8), arr_amtincomo(9), arr_amtincomo(10),
                    v_amthr_oincome, v_amtday_oincome, v_amtmth_oincome);
    --//Adjust income
    get_wage_income(v_codcompy, p_codempmt,
                    arr_amtincadj(1), arr_amtincadj(2), arr_amtincadj(3), arr_amtincadj(4), arr_amtincadj(5),
                    arr_amtincadj(6), arr_amtincadj(7), arr_amtincadj(8), arr_amtincadj(9), arr_amtincadj(10),
                    v_amthr_incadj, v_amtday_incadj, v_amtmth_incadj);

    begin
      select  codcurr,get_tcodec_name('TCODCURR',codcurr,global_v_lang)
      into    v_codcurr,v_desc_codcurr
      from    tcontrpy
      where   codcompy    = v_codcompy
      and     dteeffec    = ( select  max(t2.dteeffec)
                              from    tcontrpy  t2
                              where   t2.codcompy   = v_codcompy
                              and     t2.dteeffec   <= trunc(sysdate));
    exception when no_data_found then
      null;
    end;
    if is_report then
      insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,
                            item5,item6,item7,item8,item9,
                            item10,item11)
      values (global_v_codempid, 'HRPMB2E',r_numseq,'TABLE',p_codempid_query,p_codtrn,to_char(p_dteeffec,'dd/mm/yyyy'),
              '',
              '',
              get_label_name('HRPMB2E3',global_v_lang,150),
              trim(to_char(v_amtmth_oincome, '999,999,990.00')),
              trim(to_char(v_amtmth_incadj, '999,999,990.00')),
              trim(to_char(v_amtmth_oincome + v_amtmth_incadj, '999,999,990.00')),
              p_numseq);
      r_numseq := r_numseq + 1;
      --
      insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,
                            item5,item6,item7,item8,item9,
                            item10,item11)
      values (global_v_codempid, 'HRPMB2E',r_numseq,'TABLE',p_codempid_query,p_codtrn,to_char(p_dteeffec,'dd/mm/yyyy'),
              '',
              '',
              get_label_name('HRPMB2E3',global_v_lang,160),
              trim(to_char(v_amtday_oincome, '999,999,990.00')),
              trim(to_char(v_amtday_incadj, '999,999,990.00')),
              trim(to_char(v_amtday_oincome + v_amtday_incadj, '999,999,990.00')),
              p_numseq);
      r_numseq := r_numseq + 1;
      --
      insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,
                            item5,item6,item7,item8,item9,
                            item10,item11)
      values (global_v_codempid, 'HRPMB2E',r_numseq,'TABLE',p_codempid_query,p_codtrn,to_char(p_dteeffec,'dd/mm/yyyy'),
              '',
              '',
              get_label_name('HRPMB2E3',global_v_lang,170),
              trim(to_char(v_amthr_oincome, '999,999,990.00')),
              trim(to_char(v_amthr_incadj, '999,999,990.00')),
              trim(to_char(v_amthr_oincome + v_amthr_incadj, '999,999,990.00')),
              p_numseq);
      r_numseq := r_numseq + 1;

      update ttemprpt
        set item22 = v_codcurr || ' - ' ||v_desc_codcurr
      where codempid = global_v_codempid
        and codapp = 'HRPMB2E'
        and item1 = 'DETAIL';
    else
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codcurr',v_codcurr);
      obj_data.put('desc_codcurr',v_codcurr||' - '||v_desc_codcurr);

      obj_data.put('amtincomm',to_char(v_amtmth_oincome,'fm999,999,999,990.00'));
      obj_data.put('amtmaxm',to_char(v_amtmth_incadj,'fm999,999,999,990.00'));
      obj_data.put('amountm',to_char(v_amtmth_oincome + v_amtmth_incadj,'fm999,999,999,990.00'));

      obj_data.put('amtincomd',to_char(v_amtday_oincome,'fm999,999,999,990.00'));
      obj_data.put('amtmaxd',to_char(v_amtday_incadj,'fm999,999,999,990.00'));
      obj_data.put('amountd',to_char(v_amtday_oincome + v_amtday_incadj,'fm999,999,999,990.00'));

      obj_data.put('amtincomh',to_char(v_amthr_oincome,'fm999,999,999,990.00'));
      obj_data.put('amtmaxh',to_char(v_amthr_incadj,'fm999,999,999,990.00'));
      obj_data.put('amounth',to_char(v_amthr_oincome + v_amthr_incadj,'fm999,999,999,990.00'));
      json_str_output     := obj_data.to_clob;
    end if;
  end;
  --
  procedure gen_adj_income_detail(json_str_output out clob) is
    v_json_str_income_table     clob;
    v_json_param                json_object_t;
    v_json_output               json_object_t;
    is_report_tmp               boolean;
  begin
    is_report_tmp           := is_report;
    is_report               := false;
    gen_adj_income_table(v_json_str_income_table);
    is_report               := is_report_tmp;
    v_json_output           := json_object_t(v_json_str_income_table);
    v_json_param            := json_object_t();
    v_json_param.put('param_json',v_json_output);
    v_json_str_income_table   := v_json_param.to_clob;
    gen_cal_adj_income(v_json_str_income_table,json_str_output);
  end;
  --
  procedure get_adj_income_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_adj_income_detail(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_adj_income_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_adj_income_table(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_cal_adj_income(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_cal_adj_income(json_str_input,json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save(t_thismove thismove%rowtype) is
    v_code      varchar2(100 char);
    v_dteeffex  date;
  begin
    if t_thismove.codcomp is not null then
      begin
        select 'Y'
          into v_code
          from tcenter
         where codcomp   = get_compful(t_thismove.codcomp);
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.codpos is not null then
      begin
        select 'Y'
          into v_code
          from tpostn
         where codpos   = t_thismove.codpos;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.codjob is not null then
      begin
        select 'Y'
          into v_code
          from tjobcode
         where codjob   = t_thismove.codjob;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TJOBCODE');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.codbrlc is not null then
      begin
        select 'Y'
          into v_code
          from tcodloca
         where codcodec   = t_thismove.codbrlc;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODLOCA');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.codempmt is not null then
      begin
        select 'Y'
          into v_code
          from tcodempl
         where codcodec   = t_thismove.codempmt;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODEMPL');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.codcalen is not null then
      begin
        select 'Y'
          into v_code
          from tcodwork
         where codcodec   = t_thismove.codcalen;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODWORK');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.typemp is not null then
      begin
        select 'Y'
          into v_code
          from tcodcatg
         where codcodec   = t_thismove.typemp;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODCATG');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.typpayroll is not null then
      begin
        select 'Y'
          into v_code
          from tcodtypy
         where codcodec   = t_thismove.typpayroll;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.jobgrade is not null then
      begin
        select 'Y'
          into v_code
          from tcodjobg
         where codcodec   = t_thismove.jobgrade;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODJOBG');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.codgrpgl is not null then
      begin
        select 'Y'
          into v_code
          from tcodgrpgl
         where codcodec   = t_thismove.codgrpgl;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODGRPGL');
        return;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if t_thismove.codexemp is not null then
      begin
        select 'Y'
          into v_code
          from tcodexem
         where codcodec   = t_thismove.codexemp;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCODEXEM');
        return;
      end;
    end if;

    if t_thismove.dteduepr is not null then
      if t_thismove.dteduepr < t_thismove.dteeffec then
        param_msg_error   := get_error_msg_php('PM0006',global_v_lang);
        return;
      end if;
    end if;
    if t_thismove.dteeval is not null then
      if t_thismove.dteeval < t_thismove.dteeffec then
        param_msg_error   := get_error_msg_php('PM0007',global_v_lang);
        return;
      end if;
    end if;
    begin
      select dteeffex
        into v_dteeffex
        from temploy1
       where codempid = t_thismove.codempid;
    exception when no_data_found then
      null;
    end;
    if t_thismove.dteeval > nvl(v_dteeffex,to_date('31/12/9999','dd/mm/yyyy')) then

      param_msg_error   := get_error_msg_php('PM0004',global_v_lang);
      return;
    end if;

    if t_thismove.codtrn = '0003' and t_thismove.codrespr = 'E' and v_probation is null or v_probation = 0 then
        param_msg_error   := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end;
  --
  procedure insert_thismove(t_thismove thismove%rowtype,arr_amtincom t_amt,arr_amtincadj t_amt) is
  begin
    begin
      insert into thismove(codempid,dteeffec,numseq,codtrn,ocodempid,
                           typmove,numannou,codcomp,codpos,codjob,
                           numlvl,codbrlc,codempmt,codcalen,typemp,
                           typpayroll,jobgrade,codgrpgl,staemp,stapost2,
                           desnote,qtydatrq,dteduepr,dteeval,scoreget,
                           codrespr,flgadjin,codexemp,
                           amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                           amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                           amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
                           amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
                           codcreate,coduser,flginput,dteempmt)
                   values (t_thismove.codempid,t_thismove.dteeffec,t_thismove.numseq,t_thismove.codtrn,t_thismove.ocodempid,
                           t_thismove.typmove,t_thismove.numannou,get_compful(t_thismove.codcomp),t_thismove.codpos,t_thismove.codjob,
                           t_thismove.numlvl,t_thismove.codbrlc,t_thismove.codempmt,t_thismove.codcalen,t_thismove.typemp,
                           t_thismove.typpayroll,t_thismove.jobgrade,t_thismove.codgrpgl,t_thismove.staemp,t_thismove.stapost2,
                           t_thismove.desnote,t_thismove.qtydatrq,t_thismove.dteduepr,t_thismove.dteeval,t_thismove.scoreget,
                           t_thismove.codrespr,t_thismove.flgadjin,t_thismove.codexemp,
                           stdenc(arr_amtincom(1),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(2),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(3),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(4),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(5),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(6),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(7),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(8),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(9),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincom(10),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(1),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(2),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(3),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(4),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(5),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(6),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(7),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(8),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(9),t_thismove.codempid,global_v_chken),
                           stdenc(arr_amtincadj(10),t_thismove.codempid,global_v_chken),
                           global_v_coduser,global_v_coduser,'Y',t_thismove.dteempmt);
    exception when dup_val_on_index then
      update  thismove
      set     ocodempid       = t_thismove.ocodempid,
              typmove         = t_thismove.typmove,
              numannou        = t_thismove.numannou,
              codcomp         = get_compful(t_thismove.codcomp),
              codpos          = t_thismove.codpos,
              codjob          = t_thismove.codjob,
              numlvl          = t_thismove.numlvl,
              codbrlc         = t_thismove.codbrlc,
              codempmt        = t_thismove.codempmt,
              codcalen        = t_thismove.codcalen,
              typemp          = t_thismove.typemp,
              typpayroll      = t_thismove.typpayroll,
              jobgrade        = t_thismove.jobgrade,
              codgrpgl        = t_thismove.codgrpgl,
              staemp          = t_thismove.staemp,
              stapost2        = t_thismove.stapost2,
              desnote         = t_thismove.desnote,
              qtydatrq        = t_thismove.qtydatrq,
              dteduepr        = t_thismove.dteduepr,
              dteeval         = t_thismove.dteeval,
              scoreget        = t_thismove.scoreget,
              codrespr        = t_thismove.codrespr,
              flgadjin        = t_thismove.flgadjin,
              codexemp        = t_thismove.codexemp,
              amtincom1       = stdenc(arr_amtincom(1),t_thismove.codempid,global_v_chken),
              amtincom2       = stdenc(arr_amtincom(2),t_thismove.codempid,global_v_chken),
              amtincom3       = stdenc(arr_amtincom(3),t_thismove.codempid,global_v_chken),
              amtincom4       = stdenc(arr_amtincom(4),t_thismove.codempid,global_v_chken),
              amtincom5       = stdenc(arr_amtincom(5),t_thismove.codempid,global_v_chken),
              amtincom6       = stdenc(arr_amtincom(6),t_thismove.codempid,global_v_chken),
              amtincom7       = stdenc(arr_amtincom(7),t_thismove.codempid,global_v_chken),
              amtincom8       = stdenc(arr_amtincom(8),t_thismove.codempid,global_v_chken),
              amtincom9       = stdenc(arr_amtincom(9),t_thismove.codempid,global_v_chken),
              amtincom10      = stdenc(arr_amtincom(10),t_thismove.codempid,global_v_chken),
              amtincadj1      = stdenc(arr_amtincadj(1),t_thismove.codempid,global_v_chken),
              amtincadj2      = stdenc(arr_amtincadj(2),t_thismove.codempid,global_v_chken),
              amtincadj3      = stdenc(arr_amtincadj(3),t_thismove.codempid,global_v_chken),
              amtincadj4      = stdenc(arr_amtincadj(4),t_thismove.codempid,global_v_chken),
              amtincadj5      = stdenc(arr_amtincadj(5),t_thismove.codempid,global_v_chken),
              amtincadj6      = stdenc(arr_amtincadj(6),t_thismove.codempid,global_v_chken),
              amtincadj7      = stdenc(arr_amtincadj(7),t_thismove.codempid,global_v_chken),
              amtincadj8      = stdenc(arr_amtincadj(8),t_thismove.codempid,global_v_chken),
              amtincadj9      = stdenc(arr_amtincadj(9),t_thismove.codempid,global_v_chken),
              amtincadj10     = stdenc(arr_amtincadj(10),t_thismove.codempid,global_v_chken),
              coduser         = global_v_coduser,
              dteempmt        = t_thismove.dteempmt
      where   codempid        = t_thismove.codempid
      and     dteeffec        = t_thismove.dteeffec
      and     numseq          = t_thismove.numseq
      and     codtrn          = t_thismove.codtrn;
    end;
  end;
  --
  procedure update_ttnewemp(t_thismove thismove%rowtype,arr_amtincom t_amt,p_amtothr number) is
  begin
    update  ttnewemp
    set     dteempmt    = t_thismove.dteeffec,
            codempmt    = t_thismove.codempmt,
            codcomp     = get_compful(t_thismove.codcomp),
            codpos      = t_thismove.codpos,
            codjob      = t_thismove.codjob,
            numlvl      = t_thismove.numlvl,
            codbrlc     = t_thismove.codbrlc,
            codcalen    = t_thismove.codcalen,
            typemp      = t_thismove.typemp,
            typpayroll  = t_thismove.typpayroll,
            qtydatrq    = t_thismove.qtydatrq,
            dteduepr    = t_thismove.dteduepr,
            amtincom1   = stdenc(arr_amtincom(1),t_thismove.codempid,global_v_lang),
            amtincom2   = stdenc(arr_amtincom(2),t_thismove.codempid,global_v_lang),
            amtincom3   = stdenc(arr_amtincom(3),t_thismove.codempid,global_v_lang),
            amtincom4   = stdenc(arr_amtincom(4),t_thismove.codempid,global_v_lang),
            amtincom5   = stdenc(arr_amtincom(5),t_thismove.codempid,global_v_lang),
            amtincom6   = stdenc(arr_amtincom(6),t_thismove.codempid,global_v_lang),
            amtincom7   = stdenc(arr_amtincom(7),t_thismove.codempid,global_v_lang),
            amtincom8   = stdenc(arr_amtincom(8),t_thismove.codempid,global_v_lang),
            amtincom9   = stdenc(arr_amtincom(9),t_thismove.codempid,global_v_lang),
            amtincom10  = stdenc(arr_amtincom(10),t_thismove.codempid,global_v_lang),
            amtothr     = p_amtothr
    where   codempid    = t_thismove.codempid;
  end;
  --
  procedure save_detail_move(json_str_input in clob, json_str_output out clob) is
    v_json_input          json_object_t;
    v_json_param          json_object_t;
    v_json_move_detail    json_object_t;
    v_json_adj_income     json_object_t;
    v_json_income_detail  json_object_t;
    v_json_income_table   json_object_t;
    v_json_income_row     json_object_t;

    arr_amtincom          t_amt;
    arr_amtincadj         t_amt;
    t_thismove            thismove%rowtype;

    v_qtydatrqy           number;
    v_qtydatrqm           number;
    v_amtothr             temploy3.amtothr%type;
  begin
    v_json_input          := json_object_t(json_str_input);
    v_json_param          := hcm_util.get_json_t(v_json_input, 'param_json');
    v_json_move_detail    := hcm_util.get_json_t(v_json_param, 'move_detail');
    v_json_adj_income     := hcm_util.get_json_t(v_json_param, 'adj_income');
    v_json_income_detail  := hcm_util.get_json_t(v_json_adj_income, 'detail');
    v_json_income_table   := hcm_util.get_json_t(hcm_util.get_json_t(v_json_adj_income, 'table'),'rows');
    for i in 1..10 loop
      arr_amtincom(i)   := null;
      arr_amtincadj(i)  := null;
    end loop;
    t_thismove.codempid       := hcm_util.get_string_t(v_json_move_detail,'codempid');
    t_thismove.dteeffec       := to_date(hcm_util.get_string_t(v_json_move_detail,'dteeffec'),'dd/mm/yyyy');
    t_thismove.numseq         := hcm_util.get_string_t(v_json_move_detail,'numseq');
    t_thismove.codtrn         := hcm_util.get_string_t(v_json_move_detail,'codtrn');
    t_thismove.ocodempid      := hcm_util.get_string_t(v_json_move_detail,'ocodempid');
    t_thismove.typmove        := hcm_util.get_string_t(v_json_move_detail,'typmove');
    t_thismove.numannou       := hcm_util.get_string_t(v_json_move_detail,'numannou');
    t_thismove.codcomp        := hcm_util.get_string_t(v_json_move_detail,'codcomp');
    t_thismove.codpos         := hcm_util.get_string_t(v_json_move_detail,'codpos');
    t_thismove.codjob         := hcm_util.get_string_t(v_json_move_detail,'codjob');
    t_thismove.numlvl         := hcm_util.get_string_t(v_json_move_detail,'numlvl');
    t_thismove.codbrlc        := hcm_util.get_string_t(v_json_move_detail,'codbrlc');
    t_thismove.codempmt       := hcm_util.get_string_t(v_json_move_detail,'codempmt');
    t_thismove.codcalen       := hcm_util.get_string_t(v_json_move_detail,'codcalen');
    t_thismove.typemp         := hcm_util.get_string_t(v_json_move_detail,'typemp');
    t_thismove.typpayroll     := hcm_util.get_string_t(v_json_move_detail,'typpayroll');
    t_thismove.jobgrade       := hcm_util.get_string_t(v_json_move_detail,'jobgrade');
    t_thismove.codgrpgl       := hcm_util.get_string_t(v_json_move_detail,'codgrpgl');
    t_thismove.staemp         := hcm_util.get_string_t(v_json_move_detail,'staemp');
    t_thismove.stapost2       := hcm_util.get_string_t(v_json_move_detail,'stapost2');
    t_thismove.desnote        := hcm_util.get_string_t(v_json_move_detail,'desnote');
    v_qtydatrqy               := hcm_util.get_string_t(v_json_move_detail,'qtydatrqy');
    v_qtydatrqm               := hcm_util.get_string_t(v_json_move_detail,'qtydatrqm');
    t_thismove.qtydatrq       := (v_qtydatrqy * 12) + v_qtydatrqm;
    t_thismove.dteduepr       := to_date(hcm_util.get_string_t(v_json_move_detail,'dteduepr'),'dd/mm/yyyy');
    t_thismove.dteeval        := to_date(hcm_util.get_string_t(v_json_move_detail,'dteeval'),'dd/mm/yyyy');
    t_thismove.scoreget       := hcm_util.get_string_t(v_json_move_detail,'scoreget');
    t_thismove.codrespr       := hcm_util.get_string_t(v_json_move_detail,'codrespr');
    t_thismove.flgadjin       := nvl(hcm_util.get_string_t(v_json_move_detail,'flgadjin'),'N');
    t_thismove.codexemp       := hcm_util.get_string_t(v_json_move_detail,'codexemp');
--    t_thismove.codexemp       := hcm_util.get_string_t(v_json_move_detail,'codexemp');
    v_probation             := hcm_util.get_string_t(v_json_move_detail,'probation');


    begin
        select dteempmt
          into t_thismove.dteempmt
          from temploy1
         where codempid = t_thismove.codempid;
    exception when others then
        t_thismove.dteempmt := null;
    end;

    v_amtothr                 := hcm_util.get_string_t(v_json_income_detail,'amounth');
    for i in 0..(v_json_income_table.get_size - 1) loop
      v_json_income_row     := hcm_util.get_json_t(v_json_income_table,to_char(i));
      arr_amtincom(i + 1)   := hcm_util.get_string_t(v_json_income_row,'amtincom');
      arr_amtincadj(i + 1)  := hcm_util.get_string_t(v_json_income_row,'amtincadj');
    end loop;

    check_save(t_thismove);
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      insert_thismove(t_thismove,arr_amtincom,arr_amtincadj);
      if t_thismove.codtrn = '0001' then
        update_ttnewemp(t_thismove,arr_amtincom,v_amtothr);
      end if;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      commit;
    end if;
  end;
  --
  procedure save_data(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    save_detail_move(json_str_input, json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure delete_index(json_str_input in clob, json_str_output out clob) is
    v_json_index      json_object_t;
    v_json_index_row  json_object_t;
    v_codempid        temploy1.codempid%type;
    v_dteeffec        thismove.dteeffec%type;
    v_numseq          thismove.numseq%type;
    v_codtrn          thismove.codtrn%type;
  begin
    initial_value(json_str_input);
    v_json_index      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    for i in 0..(v_json_index.get_size - 1) loop
      v_json_index_row    := hcm_util.get_json_t(v_json_index,to_char(i));
      v_codempid          := hcm_util.get_string_t(v_json_index_row,'codempid');
      v_dteeffec          := to_date(hcm_util.get_string_t(v_json_index_row,'dteeffec'),'dd/mm/yyyy');
      v_numseq            := hcm_util.get_string_t(v_json_index_row,'numseq');
      v_codtrn            := hcm_util.get_string_t(v_json_index_row,'codtrn');

      delete from thismove
      where codempid    = v_codempid
      and   dteeffec    = v_dteeffec
      and   numseq      = v_numseq
      and   codtrn      = v_codtrn;

    end loop;
    commit;
    param_msg_error     := get_error_msg_php('HR2425',global_v_lang);
    json_str_output     := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_report(json_str_input in clob,json_str_output out clob) is
--    v_zyear         number := hcm_appsettings.get_additional_year;
    json_rows       json_object_t;
    json_data_row   json_object_t;
    t_thismove      thismove%rowtype;
  begin
    initial_value(json_str_input);
    is_report   := true;
    r_numseq    := 1;
    json_rows   := hcm_util.get_json_t(json_object_t(json_str_input),'p_index_rows');
    begin
        delete from ttemprpt
         where codempid = global_v_codempid
		   and codapp = 'HRPMB2E';
    exception when others then
        null;
    end;

    for i in 0..(json_rows.get_size - 1) loop
      json_data_row         := hcm_util.get_json_t(json_rows, to_char(i));
      t_thismove.codempid   := hcm_util.get_string_t(json_data_row,'codempid');
      t_thismove.dteeffec   := to_date(hcm_util.get_string_t(json_data_row,'dteeffec'),'dd/mm/yyyy');
      t_thismove.numseq     := hcm_util.get_string_t(json_data_row,'numseq');
      t_thismove.codtrn     := hcm_util.get_string_t(json_data_row,'codtrn');
      t_thismove.codcomp    := hcm_util.get_string_t(json_data_row,'codcomp');
      t_thismove.codempmt    := hcm_util.get_string_t(json_data_row,'codempmt');

      p_codempid_query      := t_thismove.codempid;
      p_dteeffec            := t_thismove.dteeffec;
      p_numseq              := t_thismove.numseq;
      p_codtrn              := t_thismove.codtrn;
      p_codcomp             := t_thismove.codcomp;
      p_codempmt            := t_thismove.codempmt;

      if p_codempmt is null then
          begin
            select codempmt--, codcomp
              into p_codempmt--, p_codcomp
              from temploy1
             where codempid     = p_codempid_query;
          exception when no_data_found then
            null;
          end;
      end if;

--      insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,
--                            item5,item6,item7,item8)
--      values (global_v_codempid, 'HRPMB2E',r_numseq,'HEAD',p_codempid_query,p_codtrn,to_char(p_dteeffec,'dd/mm/yyyy'),
--              get_temploy_name(p_codempid_query, global_v_lang),
--              p_numseq,
--              get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang),
--              to_char(add_months(p_dteeffec,global_v_zyear*12),'dd/mm/yyyy'));
--      r_numseq  := r_numseq + 1;

      gen_move_detail(json_str_output);
      gen_adj_income_table(json_str_output);
      gen_adj_income_detail(json_str_output);
    end loop;
    commit;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
