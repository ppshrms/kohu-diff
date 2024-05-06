--------------------------------------------------------
--  DDL for Package Body HRAL92E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL92E" is
  procedure chk_tinexinf (p_type in varchar2, v_code in tinexinf.codpay%type) is
    v_typpay	tinexinf.typpay%type;
  begin
    if v_code is not null then
      begin
        select typpay into v_typpay
        from tinexinf
        where codpay = v_code;
        if p_type = 'INC' and v_typpay not in('1','2','3') then
          param_msg_error := get_error_msg_php('AL0001',global_v_lang);
          return;
        elsif p_type = 'DED' and v_typpay not in('4','5') then
          param_msg_error := get_error_msg_php('AL0002',global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
        return;
      end;
    end if;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := '';--web_service.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_dteeffecOld       := p_dteeffec;
    p_codcompyQuery     := upper(hcm_util.get_string_t(json_obj,'p_codcompyQuery'));
    p_dteeffecQuery     := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecQuery'),'dd/mm/yyyy');
    p_codot             := hcm_util.get_string_t(json_obj,'p_codot');
    p_codrtot           := hcm_util.get_string_t(json_obj,'p_codrtot');
    p_codotalw          := hcm_util.get_string_t(json_obj,'p_codotalw');

    p_flgchglv          := hcm_util.get_string_t(json_obj,'p_flgchglv');
    p_condot            := hcm_util.get_string_t(json_obj,'p_condot');
    p_condextr          := hcm_util.get_string_t(json_obj,'p_condextr');
    --<< user25 Date: 02/08/2021 TDKU-SS-2101
    p_typalert          := hcm_util.get_string_t(json_obj,'typalert');
    p_qtymxotwk         := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtymxotwk'));
    p_qtymxallwk        := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtymxallwk'));  
    -->> user25 Date: 02/08/2021 TDKU-SS-2101    
    p_codapp            := hcm_util.get_string_t(json_obj,'p_codapp');
    p_flgcopy           := hcm_util.get_string_t(json_obj,'p_flgcopy');
    forceAdd            := hcm_util.get_string_t(json_obj,'forceAdd');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_count         number;
    v_maxdteeffec   date;
    v_secur         varchar2(4000 char);
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
    if param_msg_error is not null then
      return;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
  end;

  procedure check_tcontrot is
  begin
    if p_codot is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'tcontrot.codot');
      return;
    end if;

    chk_tinexinf('INC', p_codot);
    chk_tinexinf('INC', p_codrtot);
    chk_tinexinf('INC', p_codotalw);
  end;

  procedure check_tcontot1 is
    v_codcompy    varchar2(400);
  BEGIN

    if nvl(p_qtymstot,0) = 0 then
      param_msg_error := get_error_msg_php('HR2020',global_v_lang,'qtymstot');
      return;
    end if;

    if nvl(p_qtymenot,0) = 0 then
      param_msg_error := get_error_msg_php('HR2020',global_v_lang,'qtymenot');
      return;
    end if;

    if p_qtymacot is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtymacot');
      return;
    end if;

    if p_qtymstot > p_qtymenot then
      param_msg_error := get_error_msg_php('HR2022',global_v_lang,'timest');
      return;
    end if;
  end;

  procedure check_totbreak is
  begin
    if nvl(p_numseq,0) = 0 then
      param_msg_error := get_error_msg_php('HR2005',global_v_lang,'totbreak.numseq');
      return;
    end if;
  end;

  procedure check_totratep is
  begin
    if nvl(p_numseq,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'totratep.numseq');
      return;
    end if;
  end;

  procedure check_totmeal is
  begin
    if nvl(p_qtyminst,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'totmeal.v_qtyminst');
      return;
    end if;
    if nvl(p_qtyminen,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'totmeal.v_qtyminen');
      return;
    end if;
--    if nvl(p_amtmeal,0) = 0 then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'totmeal.amtmeal');
--      return;
--    end if;
    if p_qtyminst > p_qtyminen then
      param_msg_error := get_error_msg_php('HR2022',global_v_lang,'totmeal.v_qtyminst');
      return;
    end if;

    if mod(p_qtyminen,1) >= .6 then
      param_msg_error := get_error_msg_php('AL0004',global_v_lang);
      return;
    end if;

    if mod(p_qtyminst,1) >= .6 then
      param_msg_error := get_error_msg_php('AL0004',global_v_lang);
      return;
    end if;
  end;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('isEdit', isEdit);
      obj_data.put('isAdd', isAdd);
      obj_data.put('isCopy', nvl(forceAdd, 'N'));

      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    if forceAdd = 'Y' then
      isEdit := false;
      isAdd  := true;
      v_indexdteeffec := p_dteeffec;
    else
      begin
       select count(*) 
         into v_count
         from tcontrot
        where codcompy = p_codcompy
         and dteeffec  = p_dteeffec;
        v_indexdteeffec := p_dteeffec;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        select max(dteeffec) 
          into v_maxdteeffec
          from tcontrot
         where codcompy = p_codcompy
           and dteeffec <= p_dteeffec;
        if p_dteeffec < trunc(sysdate) then
          v_indexdteeffec   := v_maxdteeffec;
          isEdit            := false;
        else
          v_indexdteeffec   := p_dteeffec;
          isEdit            := false;
          isAdd             := true;
        end if;

        if v_maxdteeffec is null then
            select min(dteeffec) 
              into v_maxdteeffec
              from tcontrot
             where codcompy = p_codcompy
               and dteeffec > p_dteeffec;   
          If v_maxdteeffec is null then    
            isedit := true;
            isAdd  := true;
          else
            isedit              := false;
            isAdd               := false;
            v_indexdteeffec     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
          end if;
        else
            p_dteeffec := v_maxdteeffec;
        end if;
      else
        if p_dteeffec < trunc(sysdate) then
          isEdit := false;
        else
          isedit := true;
        end if;
         v_indexdteeffec := p_dteeffec;
      end if;
    end if;
  end;

  procedure get_copy_list(json_str_input in clob, json_str_output out clob) is
    v_row      number := 0;
    obj_row    json_object_t;
    obj_data   json_object_t;

    cursor c1 is
      select codcompy, dteeffec
        from tcontrot
       where codcompy like nvl(p_codcompy,'%')
    order by codcompy, dteeffec desc;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    for r1 in c1 loop
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,r1.codcompy);
      if param_msg_error is null then
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));

        obj_row.put(to_char(v_row-1),obj_data);
      end if;
      param_msg_error := null;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_logical_statement(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_logical_statement(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_logical_statement;

  procedure get_upd_data(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_upd_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_upd_data;

  procedure gen_upd_data(json_str_output out clob) is
    v_row         number := 0;
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_dteeffec    date;
    v_dteupd      date;
    v_coduser     varchar2(100 char);
    v_flgrateot   varchar2(1 char);

  begin
--    initial_value(json_str_input);
--    check_index;

    if param_msg_error is null then
      gen_flg_status;

      begin
        select dteupd, coduser, flgrateot
          into v_dteupd, v_coduser, v_flgrateot
          from tcontrot
         where codcompy = nvl(p_codcompyQuery, p_codcompy)
           and dteeffec = nvl(p_dteeffecQuery, p_dteeffec);
      exception when no_data_found then
        v_dteupd     := null;
        v_coduser    := null;
        v_flgrateot  := '1';
      end;

      begin
        select dteeffec
          into v_dteeffec
          from tcontrot
         where codcompy = nvl(p_codcompyQuery, p_codcompy)
           and rownum <= 1;

        if isAdd or isEdit then
          v_dteeffec    := p_dteeffecOld;
          v_msqerror        := '';
          v_detailDisabled  := false; 
        else
          v_dteeffec    := v_indexdteeffec;
          v_msqerror        := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400','');
          v_detailDisabled  := true; 
        end if;
      exception when no_data_found then
        v_dteeffec    := p_dteeffecOld;
      end;

      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('coduser', v_coduser||' - '||get_temploy_name(GET_CODEMPID(v_coduser), global_v_lang));
      obj_row.put('userid', GET_CODEMPID(v_coduser));
      obj_row.put('dteupd', to_char(v_dteupd,'dd/mm/yyyy'));
      obj_row.put('flgrateot', v_flgrateot);
      obj_row.put('dteeffec', to_char(v_dteeffec,'dd/mm/yyyy'));
      obj_row.put('codcompy', p_codcompy);
      obj_row.put('msqerror', v_msqerror);  
      obj_row.put('detailDisabled', v_detailDisabled);  
      --gen report--
      if isInsertReport then
        update_ttemprpt_user_updte(obj_row);
      end if;

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_rounding_minutes_tab1(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_rounding_minutes_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_rounding_minutes_tab1;

  procedure get_time_analysis_tab1(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_time_analysis_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_time_analysis_tab1;

  procedure get_payment_rate_labr_law_tab2(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    --check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_payment_rate_labr_law_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_payment_rate_labr_law_tab2;

  procedure get_payment_rate_tab2(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_payment_rate_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_payment_rate_tab2;

  procedure get_special_allowance_tab3(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_special_allowance_tab3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_special_allowance_tab3;

  procedure get_revenue_code_tab4(json_str_input in clob, json_str_output out clob) is
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_revenue_code_tab4(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_revenue_code_tab4;

  procedure gen_logical_statement(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;

    cursor c_logical is
      select numseq, namfld, namtbl, datatype,
             nambrowe, nambrowt, nambrow3, nambrow4, nambrow5
        from treport2
       where codapp = p_codapp;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c_logical loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('numseq',r1.numseq);
      obj_data.put('namfld', r1.namtbl||'.'||r1.namfld);
      obj_data.put('nambrowe',r1.nambrowe);
      obj_data.put('nambrowt',r1.nambrowt);
      obj_data.put('nambrow3',r1.nambrow3);
      obj_data.put('nambrow4',r1.nambrow4);
      obj_data.put('nambrow5',r1.nambrow5);
      obj_data.put('datatype',r1.datatype);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_rounding_minutes_tab1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    cursor c_tcontot1 is
      select codcompy,dteeffec,qtymstot,
             qtymenot,qtymacot
        from tcontot1
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
      order by qtymstot;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c_tcontot1 loop
      v_rcnt     := v_rcnt+1;
      obj_data   := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('codcompy',i.codcompy);
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('qtymstot',i.qtymstot);
      obj_data.put('qtymenot',i.qtymenot);
      obj_data.put('qtymacot',i.qtymacot);
      obj_data.put('flgAdd',isAdd);
      --gen report--
      if isInsertReport then
        insert_ttemprpt_tab1_table1(obj_data);
      end if;
      --
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_rounding_minutes_tab1;

  procedure gen_time_analysis_tab1(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;

    v_rcnt            number := 0;
    v_rcnt2           number := 0;

    cursor c_totbreak is
      select rowId, codcompy, dteeffec, numseq, syncond, typbreak, statement
        from totbreak
        where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and  dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
      order by numseq;

    cursor c_totbreak2_child (v_codcompy in varchar2, v_dteeffec in date, v_numseq in number) is
      select rowId, numseq2, timstrt, timend, qtyminst, qtyminen, qtyminbk
        from totbreak2
       where codcompy = v_codcompy
         and dteeffec = v_dteeffec
         and numseq   = v_numseq
      order by numseq2;
  begin
    obj_row := json_object_t();
    v_rcnt  := 0;
    for c1 in c_totbreak loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');

      if isAdd = true then
        v_rowid := null;
      else
        v_rowid := c1.rowId;
      end if;

      obj_data.put('rowId', v_rowid);
      obj_data.put('numseq',c1.numseq);
      obj_data.put('codcompy',c1.codcompy);
      obj_data.put('dteeffec',to_char(c1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('syncond',c1.syncond);
      obj_data.put('desc_syncond', get_logical_desc(c1.statement));
      obj_data.put('statement', c1.statement);
      obj_data.put('typbreak',c1.typbreak);
      v_rcnt2             := 0;
      obj_row_child       := json_object_t();
      for c2 in c_totbreak2_child(c1.codcompy, c1.dteeffec, c1.numseq) loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');

        if isAdd = true then
          v_rowid := null;
        else
          v_rowid := c2.rowid;
        end if;
        obj_data_child.put('rowId2', v_rowid);
        obj_data_child.put('numseq2', c2.numseq2);
--        obj_data_child.put('qtyminbk', c2.qtyminbk);
        obj_data_child.put('qtyminbk', hcm_util.convert_minute_to_hour(c2.qtyminbk));
        if c1.typbreak = 'H' then
          obj_data_child.put('timstrtot', hcm_util.convert_minute_to_hour(c2.qtyminst));
          obj_data_child.put('timendot', hcm_util.convert_minute_to_hour(c2.qtyminen));
        elsif c1.typbreak = 'T' then
          obj_data_child.put('timstrtot', c2.timstrt);
          obj_data_child.put('timendot', c2.timend);
        else
          obj_data_child.put('timstrtot', '');
          obj_data_child.put('timendot', '');
        end if;
--        obj_data_child.put('qtyminst', hcm_util.convert_minute_to_hour(c2.qtyminst));
--        obj_data_child.put('qtyminen', hcm_util.convert_minute_to_hour(c2.qtyminen));
--        obj_data_child.put('timstrt', hcm_util.convert_minute_to_time(c2.timstrt));
--        obj_data_child.put('timend', hcm_util.convert_minute_to_time(c2.timend));
        obj_data_child.put('flgAdd',isAdd);

        obj_row_child.put(to_char(v_rcnt2-1), obj_data_child);
      end loop;
      obj_data.put('children', obj_row_child);
      obj_data.put('flgAdd',isAdd);
      --gen report--
      if isInsertReport then
        insert_ttemprpt_tab1_table2(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_time_analysis_tab1;

  procedure gen_payment_rate_labr_law_tab2(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;

    v_rcnt            number := 0;
    v_rcnt2           number := 0;
    cursor c_totratep is
      select rowId, numseq, syncond, typrate, statement
        from ttotratep
        -- update change totratep -> ttotratep by user03 -28/11/2018
--       where codcompy = 'XXXX'
--         and dteeffec = '01-JAN-18'
      order by numseq;

    cursor c_totratep2_child (v_numseq in number) is --(v_codcompy in varchar2, v_dteeffec in date, v_numseq in number) is
      select rowId, numseq2, qtyminst, qtyminen, timstrt, timend, rteotpay
        from ttotratep2
       where numseq   = v_numseq
        -- update change totratep2 -> ttotratep2 by user03 -28/11/2018
--       where codcompy = v_codcompy
--         and dteeffec = v_dteeffec
      order by numseq2;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for c1 in c_totratep loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');

--      obj_data.put('rowId', c1.rowId);
      obj_data.put('flgAdd',true);
      obj_data.put('numseq',c1.numseq);
      obj_data.put('codcompy',p_codcompy);
      obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_data.put('syncond',c1.syncond);
      obj_data.put('desc_syncond', get_logical_desc(c1.statement));
--      obj_data.put('desc_syncond',get_logical_name('HRAL92M2',c1.syncond,global_v_lang));
      obj_data.put('statement',c1.statement);
      obj_data.put('typrate',c1.typrate);
      v_rcnt2             := 0;
      obj_row_child       := json_object_t();
      for c2 in c_totratep2_child(c1.numseq) loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');

--        obj_data_child.put('rowId2', c2.rowId);
        obj_data_child.put('numseq2', c2.numseq2);
        obj_data_child.put('flgAdd',true);
        if p_flgcopy = 'Y' then
          if c1.typrate = 'H' then
            obj_data_child.put('qtyminst', hcm_util.convert_minute_to_hour(c2.qtyminst));
            obj_data_child.put('qtyminen', hcm_util.convert_minute_to_hour(c2.qtyminen));
          elsif c1.typrate = 'T' then
            obj_data_child.put('qtyminst', c2.timstrt);
            obj_data_child.put('qtyminen', c2.timend);
--            obj_data_child.put('qtyminst', hcm_util.convert_minute_to_time(c2.timstrt));
--            obj_data_child.put('qtyminen', hcm_util.convert_minute_to_time(c2.timend));
          end if;
        else
          obj_data_child.put('qtyminst', hcm_util.convert_minute_to_hour(c2.qtyminst));
          obj_data_child.put('qtyminen', hcm_util.convert_minute_to_hour(c2.qtyminen));
          obj_data_child.put('timstrt', c2.timstrt);
          obj_data_child.put('timend', c2.timend);
--          obj_data_child.put('timstrt', hcm_util.convert_minute_to_time(c2.timstrt));
--          obj_data_child.put('timend', hcm_util.convert_minute_to_time(c2.timend));
        end if;
        obj_data_child.put('flgcopy', p_flgcopy);
        obj_data_child.put('rteotpay', c2.rteotpay);

        obj_row_child.put(to_char(v_rcnt2-1), obj_data_child);
      end loop;
      obj_data.put('children', obj_row_child);
      --gen report--
      if isInsertReport then
        insert_ttemprpt_tab2_table1(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_payment_rate_labr_law_tab2;

  procedure gen_payment_rate_tab2(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;

    v_rcnt            number  := 0;
    v_rcnt2           number  := 0;
    cursor c_totratep is
      select rowId, codcompy, dteeffec, numseq, syncond, typrate, statement
        from totratep
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
      order by numseq;

    cursor c_totratep2_child (v_codcompy in varchar2, v_dteeffec in date, v_numseq in number) is
      select rowId, numseq2, qtyminst, qtyminen, timstrt, timend, rteotpay
        from totratep2
       where codcompy = v_codcompy
         and dteeffec = v_dteeffec
         and numseq   = v_numseq
      order by numseq2;
  begin
    obj_row := json_object_t();
    v_rcnt  := 0;
    for c1 in c_totratep loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');

      if isAdd = true then
        v_rowid := null;
      else
        v_rowid := c1.rowid;
      end if;
      obj_data.put('rowId', v_rowid);
      obj_data.put('numseq',c1.numseq);
      obj_data.put('codcompy',c1.codcompy);
      obj_data.put('dteeffec',to_char(c1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('syncond',c1.syncond);
      obj_data.put('desc_syncond', get_logical_desc(c1.statement));
      obj_data.put('statement',c1.statement);
      obj_data.put('typrate', c1.typrate);
      v_rcnt2             := 0;
      obj_row_child       := json_object_t();
      for c2 in c_totratep2_child(c1.codcompy, c1.dteeffec, c1.numseq) loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');

        if isAdd = true then
          v_rowid := null;
        else
          v_rowid := c2.rowid;
        end if;
        obj_data_child.put('rowId2', v_rowid);
        obj_data_child.put('numseq2', c2.numseq2);
        if c1.typrate = 'H' then
          obj_data_child.put('qtyminst', hcm_util.convert_minute_to_hour(c2.qtyminst));
          obj_data_child.put('qtyminen', hcm_util.convert_minute_to_hour(c2.qtyminen));
        elsif c1.typrate = 'T' then
          obj_data_child.put('qtyminst', c2.timstrt);
          obj_data_child.put('qtyminen', c2.timend);
--          obj_data_child.put('qtyminst', hcm_util.convert_minute_to_time(c2.timstrt));
--          obj_data_child.put('qtyminen', hcm_util.convert_minute_to_time(c2.timend));
        end if;
--        obj_data_child.put('timstrt', c2.timstrt);
--        obj_data_child.put('timend', c2.timend);
        obj_data_child.put('rteotpay', c2.rteotpay);
        obj_data_child.put('flgAdd',isAdd);

        obj_row_child.put(to_char(v_rcnt2-1), obj_data_child);
      end loop;
      obj_data.put('children', obj_row_child);
      obj_data.put('flgAdd',isAdd);
      --gen report--
      if isInsertReport then
        insert_ttemprpt_tab2_table2(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_payment_rate_tab2;

  procedure gen_special_allowance_tab3(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;

    v_rcnt            number := 0;
    v_rcnt2           number := 0;

    cursor c_totmeal is
      select rowId, codcompy, dteeffec, numseq, syncond, statement
        from totmeal
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
      order by numseq;

    cursor c_totmeal2_child (v_codcompy in varchar2, v_dteeffec in date, v_numseq in number) is
      select rowId, numseq2, qtyminst, qtyminen, amtmeal
        from totmeal2
       where codcompy = v_codcompy
         and dteeffec = v_dteeffec
         and numseq   = v_numseq
      order by numseq2;
  begin
    obj_row := json_object_t();
    v_rcnt  := 0;
    for c1 in c_totmeal loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');

      if isAdd = true then
        v_rowid := null;
      else
        v_rowid := c1.rowid;
      end if;
      obj_data.put('rowId', v_rowid);
      obj_data.put('numseq',c1.numseq);
      obj_data.put('codcompy',c1.codcompy);
      obj_data.put('dteeffec',to_char(c1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('syncond',c1.syncond);
      obj_data.put('desc_syncond', get_logical_desc(c1.statement));
      obj_data.put('statement',c1.statement);
      v_rcnt2             := 0;
      obj_row_child       := json_object_t();

      for c2 in c_totmeal2_child(c1.codcompy, c1.dteeffec, c1.numseq) loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');

        if isAdd = true then
          v_rowid := null;
        else
          v_rowid := c2.rowid;
        end if;
        obj_data_child.put('rowId2', v_rowid);
        obj_data_child.put('numseq2', c2.numseq2);
        obj_data_child.put('qtyminst', hcm_util.convert_minute_to_hour(c2.qtyminst));
        obj_data_child.put('qtyminen', hcm_util.convert_minute_to_hour(c2.qtyminen));
        obj_data_child.put('amtmeal', c2.amtmeal);
--        obj_data_child.put('desc_amtmeal',get_logical_name('HRAL92M6',c2.amtmeal,global_v_lang));
        obj_data_child.put('desc_amtmeal', hcm_formula.get_description(c2.amtmeal, global_v_lang));
        obj_data_child.put('flgAdd',isAdd);

        obj_row_child.put(to_char(v_rcnt2-1), obj_data_child);
      end loop;
      obj_data.put('children', obj_row_child);
      obj_data.put('flgAdd',isAdd);
      --gen report--
      if isInsertReport then
        insert_ttemprpt_tab3(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_special_allowance_tab3;

  procedure gen_revenue_code_tab4(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number;
    v_exist         boolean := false;
    cursor c_tcontrot is
    select  condot,condextr,statementot,statementex,codcompy,dteeffec,flgchglv,
            codot,codrtot,codotalw,dteupd,coduser,qtymincal,
            typalert,qtymxotwk,qtymxallwk,startday,otcalflg--<< user25 Date: 02/08/2021 TDKU-SS-2101
      from  tcontrot
     where  codcompy = nvl(p_codcompyQuery, p_codcompy)
       and  dteeffec = nvl(p_dteeffecQuery, p_dteeffec);
  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c_tcontrot loop
      v_exist     := true;
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);

      -- Revenue code
      obj_data.put('codot',i.codot);
      obj_data.put('desc_codot',get_tinexinf_name(i.codot,global_v_lang));
      obj_data.put('codrtot',i.codrtot);
      obj_data.put('desc_codrtot',get_tinexinf_name(i.codrtot,global_v_lang));
      obj_data.put('codotalw',i.codotalw);
      obj_data.put('desc_codotalw',get_tinexinf_name(i.codotalw,global_v_lang));

      -- Condition
      obj_data.put('condot',i.condot);
      obj_data.put('desc_condot', get_logical_desc(i.statementot));
      obj_data.put('statementot',i.statementot);
      obj_data.put('condextr',i.condextr);
      obj_data.put('desc_condextr', get_logical_desc(i.statementex));
      obj_data.put('statementex',i.statementex);
      obj_data.put('flgchglv',i.flgchglv);
      obj_data.put('qtymincal',hcm_util.convert_minute_to_hour(i.qtymincal));
    --<< user25 Date: 02/08/2021 TDKU-SS-2101
      obj_data.put('typalert',nvl(i.typalert,'N'));
      if nvl(i.qtymxotwk,0) <> 0 then
        obj_data.put('qtymxotwk',hcm_util.convert_minute_to_hour(i.qtymxotwk));
      else
        obj_data.put('qtymxotwk','');
      end if;
      if nvl(i.qtymxallwk,0) <> 0 then
        obj_data.put('qtymxallwk',hcm_util.convert_minute_to_hour(i.qtymxallwk));
      else
        obj_data.put('qtymxallwk','');
      end if;
      obj_data.put('startday',i.startday);
      obj_data.put('desc_startday',get_tlistval_name('NAMDAYFUL',i.startday,global_v_lang));
      obj_data.put('otcalflg',nvl(i.otcalflg,'N'));
      obj_data.put('desc_otcalflg',get_tlistval_name('OTMETHOD',nvl(i.otcalflg,'N'),global_v_lang));
    -->> user25 Date: 02/08/2021 TDKU-SS-2101   
      obj_data.put('codcompy',p_codcompy);
      obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));

      --gen report--
      if isInsertReport then
        insert_ttemprpt_tab1_detail(obj_data);
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if not v_exist then
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('condot', '');
      obj_data.put('desc_condot', '');
      obj_data.put('statementot', '');
      obj_data.put('condextr', '');
      obj_data.put('desc_condextr', '');
      obj_data.put('statementex', '');
      obj_data.put('flgchglv', '');
    --<< user25 Date: 02/08/2021 TDKU-SS-2101
      obj_data.put('typalert', '');
      obj_data.put('qtymxotwk', '');
      obj_data.put('qtymxallwk', '');
      obj_data.put('startday','');
      obj_data.put('otcalflg','N');
    -->> user25 Date: 02/08/2021 TDKU-SS-2101   


      obj_row.put(to_char(v_rcnt-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;
  end gen_revenue_code_tab4;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := '';--web_service.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      p_codapp := 'HRAL92E1';
      gen_flg_status;
      gen_revenue_code_tab4(json_output);
      gen_upd_data(json_output);
      p_codapp := 'HRAL92E2';
      gen_rounding_minutes_tab1(json_output);
      p_codapp := 'HRAL92E3';
      gen_time_analysis_tab1(json_output);
      p_codapp := 'HRAL92E4';
      gen_payment_rate_labr_law_tab2(json_output);
      p_codapp := 'HRAL92E5';
      gen_payment_rate_tab2(json_output);
      p_codapp := 'HRAL92E6';
      gen_special_allowance_tab3(json_output);
--      p_codapp := 'HRAL92E7';
--      gen_upd_data(json_output);
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
       where codempid = p_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt_tab1_detail(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_flgchglv          varchar2(100 char);

    v_flgrateot         varchar2(100 char);
    v_year              number := 0;
    v_dteeffec          date;
    v_dteupd            date;
    v_dteeffec_         varchar2(100 char) := '';
    v_dteupd_           varchar2(100 char) := '';

    v_codcompy      		varchar2(1000 char) := '';
    v_desc_codcompy  		varchar2(1000 char) := '';
    v_desc_condot       varchar2(1000 char) := '';
    v_desc_condextr     varchar2(1000 char) := '';
    v_codot    					varchar2(1000 char) := '';
    v_desc_codot    		varchar2(1000 char) := '';
    v_codrtot    	  		varchar2(1000 char) := '';
    v_desc_codrtot    	varchar2(1000 char) := '';
    v_codotalw    	  	varchar2(1000 char) := '';
    v_desc_codotalw    	varchar2(1000 char) := '';
    v_coduser    	  	  varchar2(1000 char) := '';
    v_userid    	  		varchar2(1000 char) := '';
   --<< user25 Date: 09/08/2021 TDKU-SS-2101
    v_typalert          varchar2(100 char);
    v_qtymxotwk         varchar2(100 char);
    v_qtymxallwk        varchar2(100 char);
    v_startday          varchar2(500 char);
    v_otcalflg          varchar2(500 char);
    -->> user25 Date: 09/08/2021 TDKU-SS-2101
  begin
    v_codcompy       			:= nvl(hcm_util.get_string_t(obj_data, 'codcompy'), '');
    v_desc_codcompy   		:= get_tcenter_name(hcm_util.get_codcomp_level(hcm_util.get_string_t(obj_data, 'codcompy'),1),global_v_lang);
    v_desc_condot       	:= nvl(hcm_util.get_string_t(obj_data, 'desc_condot'), '');
    v_desc_condextr      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_condextr'), '');
    v_codot      					:= nvl(hcm_util.get_string_t(obj_data, 'codot'), '');
    v_desc_codot      		:= nvl(hcm_util.get_string_t(obj_data, 'desc_codot'), '');
    v_codrtot      				:= nvl(hcm_util.get_string_t(obj_data, 'codrtot'), '');
    v_desc_codrtot      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_codrtot'), '');
    v_codotalw      			:= nvl(hcm_util.get_string_t(obj_data, 'codotalw'), '');
    v_desc_codotalw      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_codotalw'), '');
    v_coduser      		    := nvl(hcm_util.get_string_t(obj_data, 'coduser'), '');
    v_userid      				:= nvl(hcm_util.get_string_t(obj_data, 'userid'), '');

    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);

    v_dteupd     := to_date(hcm_util.get_string_t(obj_data, 'dteupd'), 'DD/MM/YYYY');
    v_dteupd_    := to_char(v_dteupd, 'DD/MM/') || (to_number(to_char(v_dteupd, 'YYYY')) + v_year);

    v_flgchglv    :=  nvl(hcm_util.get_string_t(obj_data, 'flgchglv'), '');
    if v_flgchglv = 'Y' then
      v_flgchglv := get_label_name('HRAL92E1', global_v_lang, '70');
    elsif v_flgchglv = 'N' then
      v_flgchglv := get_label_name('HRAL92E1', global_v_lang, '80');
    end if;

--<< user25 Date: 09/08/2021 TDKU-SS-2101
    v_typalert    :=  hcm_util.get_string_t(obj_data, 'typalert');
    if v_typalert = '1' then
      v_typalert := get_label_name('HRAL92E1', global_v_lang, '160');
    elsif v_typalert = '2' then
      v_typalert := get_label_name('HRAL92E1', global_v_lang, '170');
    elsif v_typalert = 'N' then
      v_typalert := get_label_name('HRAL92E1', global_v_lang, '158');
    end if;

    v_qtymxotwk   :=  hcm_util.get_string_t(obj_data, 'qtymxotwk');
    v_qtymxallwk  :=  hcm_util.get_string_t(obj_data, 'qtymxallwk');
    v_startday    :=  hcm_util.get_string_t(obj_data, 'desc_startday');
    v_otcalflg    :=  hcm_util.get_string_t(obj_data, 'desc_otcalflg');
-->> user25 Date: 09/08/2021 TDKU-SS-2101

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = p_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
      v_numseq := v_numseq + 1;
      begin
        insert
         into ttemprpt
             (
             codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13,

             item15, item16, item17, item18, item19 --<< user25 Date: 09/08/2021 TDKU-SS-2101
             )
        values
             (
               p_codempid, p_codapp, v_numseq,
               v_codcompy,
               v_codcompy || ' - ' || v_desc_codcompy,
               v_dteeffec_,
               v_desc_condot,
               v_flgchglv,
               v_desc_condextr,
               v_codot || ' - ' || v_desc_codot,
               v_codrtot || ' - ' || v_desc_codrtot,
               v_codotalw || ' - ' || v_desc_codotalw,
               v_coduser,
               v_userid,
               v_dteupd_,
               v_flgrateot,

               v_typalert, v_qtymxotwk, v_qtymxallwk, v_startday, v_otcalflg --<< user25 Date: 09/08/2021 TDKU-SS-2101              
             );
      exception when others then
        null;
      end;
  end insert_ttemprpt_tab1_detail;

  procedure insert_ttemprpt_tab1_table1(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dteeffec          date;
    v_dteeffec_         varchar2(100 char) := '';
    v_item1             varchar2(1000 char);
    v_item3             varchar2(1000 char);
    v_item4             varchar2(1000 char);
    v_item5             varchar2(1000 char);
  begin
    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = p_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
      v_numseq := v_numseq + 1;
      v_item1 := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), '');
      v_item3 := nvl(hcm_util.get_string_t(obj_data, 'qtymstot'), '');
      v_item4 := nvl(hcm_util.get_string_t(obj_data, 'qtymenot'), '');
      v_item5 := nvl(hcm_util.get_string_t(obj_data, 'qtymacot'), '');
      begin
        insert
         into ttemprpt
             (
             codempid, codapp, numseq, item1, item2, item3, item4 ,item5
             )
        values
             (
               p_codempid, p_codapp, v_numseq,
               v_item1,
               v_dteeffec_,
               v_item3,
               v_item4,
               v_item5
             );
      exception when others then
        null;
      end;
  end insert_ttemprpt_tab1_table1;

  procedure insert_ttemprpt_tab1_table2(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_typbreak          varchar2(100 char);
    json_row            json_object_t;
    json_row_child      json_object_t;
    v_year              number := 0;
    v_dteeffec          date;
    v_dteeffec_         varchar2(100 char) := '';
    v_timstrtot         date;
    v_timendot          date;
    v_timstrtot_t         varchar2(100 char) := '';
    v_timendot_t       varchar2(100 char) := '';
    v_item1 	          varchar2(1000 char);
    v_item3 	          varchar2(1000 char);
    v_item4 	          varchar2(1000 char);
    v_item6 	          varchar2(1000 char);
    v_item7 	          varchar2(1000 char);
    v_item8 	          varchar2(1000 char);
  begin
    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);

    v_typbreak    :=  nvl(hcm_util.get_string_t(obj_data, 'typbreak'), '');
    if v_typbreak = 'T' then
      v_typbreak := get_label_name('HRAL92E1', global_v_lang, '240');
    elsif v_typbreak = 'H' then
      v_typbreak := get_label_name('HRAL92E1', global_v_lang, '250');
    end if;

    json_row            := hcm_util.get_json_t(obj_data, 'children');
    if json_row.get_size > 0 then
      for j in 0..json_row.get_size -1 loop
        begin
          select nvl(max(numseq), 0)
            into v_numseq
            from ttemprpt
           where codempid = p_codempid
             and codapp   = p_codapp;
        exception when no_data_found then
          null;
        end;
        v_numseq := v_numseq + 1;
        json_row_child := hcm_util.get_json_t(json_row, to_char(j));
--        v_timstrtot    := to_date(hcm_util.get_string_t(json_row_child, 'timstrtot'),'HH24:MI');
--        v_timendot     := to_date(hcm_util.get_string_t(json_row_child, 'timendot'),'HH24:MI');
        v_timstrtot_t    := hcm_util.get_string_t(json_row_child, 'timstrtot');
        v_timendot_t     := hcm_util.get_string_t(json_row_child, 'timendot');
        v_item1 := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), '');
        v_item3 := nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
        v_item4 := nvl(hcm_util.get_string_t(obj_data, 'desc_syncond'), '');
--        v_item6 := nvl(to_char(v_timstrtot,'HH24:MI'), ' ');
--        v_item7 := nvl(to_char(v_timendot,'HH24:MI'), ' ');
        v_item6 := nvl(v_timstrtot_t, ' ');
        v_item7 := nvl(v_timendot_t, ' ');
        v_item8 := nvl(hcm_util.get_string_t(json_row_child, 'qtyminbk'), ' ');
        begin
          insert
           into ttemprpt
               ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8 )
          values
               (
                 p_codempid, p_codapp, v_numseq,
                 v_item1,
                 v_dteeffec_,
                 v_item3,
                 v_item4,
                 v_typbreak,
                 v_item6,
                 v_item7,
                 v_item8
               );
        end;
      end loop;
    end if;

  end insert_ttemprpt_tab1_table2;

  procedure insert_ttemprpt_tab2_table1(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_desc_syncond      varchar2(1000 char);
    json_row            json_object_t;
    json_row_child      json_object_t;
    v_year              number := 0;
    v_dteeffec          date;
    v_dteeffec_         varchar2(100 char) := '';
    v_item1 	          varchar2(1000 char);
    v_item3 	          varchar2(1000 char);
    v_item4 	          varchar2(1000 char);
    v_item5 	          varchar2(1000 char);
    v_item6 	          varchar2(1000 char);
    v_item7 	          varchar2(1000 char);
    v_item8 	          varchar2(1000 char);
  begin
    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);

    v_desc_syncond      := hcm_util.get_string_t(obj_data, 'desc_syncond');
    json_row            := hcm_util.get_json_t(obj_data, 'children');
    if json_row.get_size > 0 then
      for j in 0..json_row.get_size -1 loop
        begin
          select nvl(max(numseq), 0)
            into v_numseq
            from ttemprpt
           where codempid = p_codempid
             and codapp   = p_codapp;
        exception when no_data_found then
          null;
        end;
        v_numseq := v_numseq + 1;
        json_row_child := hcm_util.get_json_t(json_row, to_char(j));
        v_item1 := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), ' ');
        v_item3 := nvl(hcm_util.get_string_t(obj_data, 'desc_syncond'), ' ');
        v_item4 := nvl(hcm_util.get_string_t(json_row_child, 'timstrt'), ' ');
        v_item5 := nvl(hcm_util.get_string_t(json_row_child, 'timend'), ' ');
        v_item6 := nvl(hcm_util.get_string_t(json_row_child, 'qtyminst'), '');
        v_item7 := nvl(hcm_util.get_string_t(json_row_child, 'qtyminen'), ' ');
        v_item8 := nvl(hcm_util.get_string_t(json_row_child, 'rteotpay'), ' ');
        begin
          insert
           into ttemprpt
               ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8 )
          values
               (
                 p_codempid, p_codapp, v_numseq,
                 v_item1,
                 v_dteeffec_,
                 v_item3,
                 v_item4,
                 v_item5,
                 v_item6,
                 v_item7,
                 v_item8
               );
        end;
      end loop;
    end if;
  end insert_ttemprpt_tab2_table1;

  procedure insert_ttemprpt_tab2_table2(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_desc_syncond      varchar2(1000 char);
    v_typrate           varchar2(100 char);
    json_row            json_object_t;
    json_row_child      json_object_t;
    v_year              number := 0;
    v_dteeffec          date;
    v_dteeffec_         varchar2(100 char) := '';
    v_item1 	          varchar2(1000 char);
    v_item3 	          varchar2(1000 char);
    v_item4 	          varchar2(1000 char);
    v_item6 	          varchar2(1000 char);
    v_item7 	          varchar2(1000 char);
    v_item8 	          varchar2(1000 char);
    v_item9 	          varchar2(1000 char);
    v_item10 	          varchar2(1000 char);
  begin
    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);

    v_typrate    :=  nvl(hcm_util.get_string_t(obj_data, 'typrate'), '');
    if v_typrate = 'T' then
      v_typrate := get_label_name('HRAL92E1', global_v_lang, '240');
    elsif v_typrate = 'H' then
      v_typrate := get_label_name('HRAL92E1', global_v_lang, '250');
    end if;

    v_desc_syncond      := hcm_util.get_string_t(obj_data, 'desc_syncond');
    json_row            := hcm_util.get_json_t(obj_data, 'children');
    if json_row.get_size > 0 then
      for j in 0..json_row.get_size -1 loop
        begin
          select nvl(max(numseq), 0)
            into v_numseq
            from ttemprpt
           where codempid = p_codempid
             and codapp   = p_codapp;
        exception when no_data_found then
          null;
        end;
        v_numseq := v_numseq + 1;
        json_row_child := hcm_util.get_json_t(json_row, to_char(j));
        v_item1 := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), ' ');
        v_item3 := nvl(hcm_util.get_string_t(obj_data, 'numseq'), ' ');
        v_item4 := nvl(hcm_util.get_string_t(obj_data, 'desc_syncond'), ' ');
        v_item6 := nvl(hcm_util.get_string_t(json_row_child, 'timstrt'), ' ');
        v_item7 := nvl(hcm_util.get_string_t(json_row_child, 'timend'), ' ');
        v_item8 := nvl(hcm_util.get_string_t(json_row_child, 'qtyminst'), '');
        v_item9 := nvl(hcm_util.get_string_t(json_row_child, 'qtyminen'), ' ');
        v_item10 := nvl(hcm_util.get_string_t(json_row_child, 'rteotpay'), ' ');
        begin
          insert
           into ttemprpt
               ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9 ,item10 )
          values
               (
                 p_codempid, p_codapp, v_numseq,
                 v_item1,
                 v_dteeffec_,
                 v_item3,
                 v_item4,
                 v_typrate,
                 v_item6,
                 v_item7,
                 v_item8,
                 v_item9,
                 v_item10
               );
        end;
      end loop;
    end if;
  end insert_ttemprpt_tab2_table2;

  procedure insert_ttemprpt_tab3(obj_data in json_object_t) is
    v_numseq            number := 0;
    json_row            json_object_t;
    json_row_child      json_object_t;
    v_year              number := 0;
    v_dteeffec          date;
    v_dteeffec_         varchar2(100 char) := '';
    v_item1 	          varchar2(1000 char);
    v_item3 	          varchar2(1000 char);
    v_item4 	          varchar2(1000 char);
    v_item5 	          varchar2(1000 char);
    v_item6 	          varchar2(1000 char);
    v_item7 	          varchar2(1000 char);
  begin
    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);

  json_row            := hcm_util.get_json_t(obj_data, 'children');
    if json_row.get_size > 0 then
      for j in 0..json_row.get_size -1 loop
        begin
          select nvl(max(numseq), 0)
            into v_numseq
            from ttemprpt
           where codempid = p_codempid
             and codapp   = p_codapp;
        exception when no_data_found then
          null;
        end;
          v_numseq := v_numseq + 1;
          json_row_child := hcm_util.get_json_t(json_row, to_char(j));
          v_item1 := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), '');
          v_item3 := nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
          v_item4 := nvl(hcm_util.get_string_t(obj_data, 'desc_syncond'), '');
          v_item5 := nvl(hcm_util.get_string_t(json_row_child, 'qtyminst'), '');
          v_item6 := nvl(hcm_util.get_string_t(json_row_child, 'qtyminen'), '');
          v_item7 := nvl(hcm_util.get_string_t(json_row_child, 'desc_amtmeal'), '');
          begin
            insert
             into ttemprpt
                 (
                 codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7
                 )
            values
                 (
                   p_codempid, p_codapp, v_numseq,
                   v_item1,
                   v_dteeffec_,
                   v_item3,
                   v_item4,
                   v_item5,
                   v_item6,
                   v_item7
                 );
          exception when others then
            null;
          end;
       end loop;
    end if;
  end insert_ttemprpt_tab3;

  procedure update_ttemprpt_user_updte(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_flgrateot         varchar2(100 char);
    v_year              number := 0;
    v_dteeffec          varchar2(100 char) := '';
--    v_dteeffec_         varchar2(100 char) := '';
    v_dteupd            date;
    v_dteupd_           varchar2(100 char) := '';
    v_item10            varchar2(1000 char);
    v_item11            varchar2(1000 char);
    v_item14            varchar2(1000 char);
  begin
    v_year       := hcm_appsettings.get_additional_year;
--    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec  := to_char(p_dteeffec, 'DD/MM/') || (to_number(to_char(p_dteeffec, 'YYYY')) + v_year);

    v_dteupd     := to_date(hcm_util.get_string_t(obj_data, 'dteupd'), 'DD/MM/YYYY');
    v_dteupd_    := to_char(v_dteupd, 'DD/MM/') || (to_number(to_char(v_dteupd, 'YYYY')) + v_year);


    v_flgrateot    :=  hcm_util.get_string_t(obj_data, 'flgrateot');
    if v_flgrateot = '1' then
      v_flgrateot := get_label_name('HRAL92E2', global_v_lang, '30');
    elsif v_flgrateot = '2' then
      v_flgrateot := get_label_name('HRAL92E2', global_v_lang, '40');
    end if;
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = p_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;

    v_item10 := hcm_util.get_string_t(obj_data, 'coduser');
    v_item11 := hcm_util.get_string_t(obj_data, 'userid');
    v_item14 := hcm_util.get_string_t(obj_data, 'flgrateot');
    begin
      update ttemprpt set item10 =  v_item10,
                          item11  = v_item11,
                          item12  = v_dteupd_,
                          item13  = v_flgrateot,
                          item14  = v_item14
                    where codempid = p_codempid
                     and  codapp   = 'HRAL92E1'
                     and  numseq   = v_numseq
                     and  item1    = p_codcompy
                     and  item3    = v_dteeffec ;
      exception when others then
        null;
      end;
  end update_ttemprpt_user_updte;

  procedure post_detail(json_str_input in clob, json_str_output out clob) as
    param_json        json_object_t;
    param_json_detail json_object_t;
    param_json_tab1   json_object_t;
    param_json_tab2   json_object_t;
    param_json_tab3   json_object_t;
    param_json_tab4   json_object_t;
    detail_tab1       json_object_t;
    detail_tab3       json_object_t;
    table_tab1_1      json_object_t;
    table_tab1_2      json_object_t;
    table_tab2        json_object_t;
    table_tab3        json_object_t;
    v_json_condot     json_object_t;
    v_json_condextr   json_object_t;
  begin
    initial_value(json_str_input);
    param_json        := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_json_detail := hcm_util.get_json_t(param_json,'detail');
    param_json_tab1   := hcm_util.get_json_t(param_json,'condition');
    param_json_tab2   := hcm_util.get_json_t(param_json,'overtimeRate');
    param_json_tab3   := hcm_util.get_json_t(param_json,'overtimePay');
    param_json_tab4   := hcm_util.get_json_t(param_json,'codpaySet');

    isCopy            := hcm_util.get_string_t(param_json_detail, 'isCopy');

    if param_msg_error is null then
      -- get flag rate ot
      p_flgrateot     := hcm_util.get_string_t(param_json_detail,'flgrateot');
      -- get flag copy rate ot
      p_flgcopyot     := hcm_util.get_string_t(param_json_detail,'flgCopyOvertimeRate');
      -- get parameter tab1
      detail_tab1     := hcm_util.get_json_t(param_json_tab1,to_char('detail'));
      v_json_condot   := hcm_util.get_json_t(detail_tab1,to_char('condot'));
      p_condot        := hcm_util.get_string_t(v_json_condot,'code');
      p_statementot   := hcm_util.get_string_t(v_json_condot,'statement');
      p_flgchglv      := hcm_util.get_string_t(detail_tab1,'flgchglv');
      p_qtymincal     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(detail_tab1,'qtymincal'));
      --<< user25 Date: 02/08/2021 TDKU-SS-2101
      p_typalert      := hcm_util.get_string_t(detail_tab1,'typalert');
      p_qtymxotwk     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(detail_tab1,'qtymxotwk'));
      p_qtymxallwk    := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(detail_tab1,'qtymxallwk'));
      p_startday      := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(detail_tab1,'startday'));
      if p_startday = 0 then
        p_startday := null;
      end if;
      p_otcalflg      := hcm_util.get_string_t(detail_tab1,'otcalflg');
      -->> user25 Date: 02/08/2021 TDKU-SS-2101    
      -- get parameter tab3
      detail_tab3     := hcm_util.get_json_t(param_json_tab3,to_char('detail'));
      v_json_condextr := hcm_util.get_json_t(detail_tab3,to_char('condextr'));
      p_condextr      := hcm_util.get_string_t(v_json_condextr,'code');
      p_statementex   := hcm_util.get_string_t(v_json_condextr,'statement');
      -- get parameter tab4
      p_codot         := hcm_util.get_string_t(param_json_tab4,'codot');
      p_codrtot       := hcm_util.get_string_t(param_json_tab4,'codrtot');
      p_codotalw      := hcm_util.get_string_t(param_json_tab4,'codotalw');

      check_tcontrot;
      save_revenue_code;
    end if;

    if param_msg_error is null then
      table_tab1_1    := hcm_util.get_json_t(param_json_tab1,to_char('table1'));
      post_rounding_minutes_tab1(table_tab1_1);
    end if;

    if param_msg_error is null then
      table_tab1_2    := hcm_util.get_json_t(param_json_tab1,to_char('table2'));
      post_time_analysis_tab1(table_tab1_2);
    end if;

    if param_msg_error is null then
      if p_flgrateot = '1' then
        delete from totratep
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec;
        delete from totratep2
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec;
        save_payment_rate_labr_law;
      elsif p_flgrateot = '2' then
        table_tab2     := hcm_util.get_json_t(param_json_tab2,to_char('table2'));
        if p_flgcopyot = 'Y' then
          delete from totratep
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec;
          delete from totratep2
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec;
        end if;
        post_payment_rate_tab2(table_tab2);
      end if;
    end if;

    if param_msg_error is null then
      table_tab3     := hcm_util.get_json_t(param_json_tab3,to_char('table'));
      post_special_allowance_tab3(table_tab3);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure post_rounding_minutes_tab1(json_str_input in json_object_t) as
    param_json_row  json_object_t;
    v_flg           varchar2(1000 char);
    v_qtymstotOld   number;

--    v_tmp_rownum          number;
--    v_tmp_codcompy        tabsdedd.codcompy%type;
--    v_tmp_dteeffec        tabsdedd.dteeffec%type;
--    v_tmp_typabs          tabsdedd.typabs%type;
--    v_tmp_numseq          tabsdedd.numseq%type;

--    json_item_insert      json;
--    v_rcnt_insert         number;
--    json_item_update      json;
--    v_rcnt_update         number;
    v_max_num_loop        number := 20;
    v_current_loop        number := 0;

  begin
    if isCopy = 'Y' then
      begin
        delete from tcontot1
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec;
      exception when others then
        null;
      end;
    end if;


    for i in 0..json_str_input.get_size-1 loop
      param_json_row   := hcm_util.get_json_t(json_str_input,to_char(i));
--      p_codcompy       := hcm_util.get_string_t(param_json_row,'codcompy');
--      p_dteeffec       := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      p_qtymstot       := to_number(hcm_util.get_string_t(param_json_row,'qtymstot'));
      p_qtymenot       := to_number(hcm_util.get_string_t(param_json_row,'qtymenot'));
      p_qtymacot       := to_number(hcm_util.get_string_t(param_json_row,'qtymacot'));
      v_qtymstotOld    := to_number(hcm_util.get_string_t(param_json_row,'qtymstotOld'));
      v_flg            := hcm_util.get_string_t(param_json_row,'flg');
      check_tcontot1;
      if param_msg_error is null then
        if  v_flg = 'delete' then
          begin
            delete from tcontot1
                  where codcompy = p_codcompy
                    and dteeffec = p_dteeffec
                    and qtymstot = p_qtymstot;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||
                               dbms_utility.format_error_backtrace;
            return;
          end;
        elsif v_flg = 'add' then
          begin
            insert into tcontot1 (codcompy, dteeffec, qtymstot, qtymenot,
                                  qtymacot, coduser, codcreate)
                 values (p_codcompy, p_dteeffec, p_qtymstot, p_qtymenot,
                         p_qtymacot, global_v_coduser, global_v_coduser);
          exception when others then null;
          end;
        else
          begin
            update tcontot1 set coduser  = global_v_coduser,
                                qtymstot = p_qtymstot,
                                qtymenot = p_qtymenot,
                                qtymacot = p_qtymacot
                          where codcompy = p_codcompy
                            and dteeffec = p_dteeffec
                            and qtymstot = v_qtymstotOld;
          exception when others then null;
          end;
        end if;
      end if;
    end loop;
    --
/*
    if json_item_update.get_size > 0 then
      while (v_current_loop < v_max_num_loop)
      loop
        v_current_loop    := v_current_loop + 1;
        rounding_minutes_tab1_update(json_item_update);
        if (json_item_update.get_size = 0) then
          exit;
        end if;
      end loop;
      if json_item_update.get_size > 0 then
        param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontot1');
        rollback;
        return;
      end if;
    end if;

    if v_rcnt_insert > 0 then
      while (v_current_loop < v_max_num_loop)
      loop
        v_current_loop    := v_current_loop + 1;
        rounding_minutes_tab1_insert(json_item_insert);
        if (json_item_insert.get_size = 0) then
          exit;
        end if;
      end loop;
      if json_item_insert.get_size > 0 then
        param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontot1');
        rollback;
        return;
      end if;
    end if;
*/
  end post_rounding_minutes_tab1;

  procedure post_time_analysis_tab1(json_str_input in json_object_t) as
    param_json_row  json_object_t;
    param_json_obj2 json_object_t;
    json_row2       json_object_t;
    obj_syncond     json_object_t;
--    v_numseq        number;
    v_flg           varchar2(1000 char);
    v_flg_child     varchar2(1000 char);
    v_rowId         varchar2(1000 char);
    v_rowId2        varchar2(1000 char);
    v_numseqOld     number;
  begin
    if isCopy = 'Y' then
      begin
        delete from totbreak a
              where a.codcompy = p_codcompy
                and a.dteeffec = p_dteeffec;
      exception when others then
        null;
      end;

      begin
        delete from totbreak2
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec;
      exception when others then
        null;
      end;
    end if;

    p_numseq     := 0;
    p_numseq2    := 0;
    for i in 0..json_str_input.get_size-1 loop
      param_json_row   := hcm_util.get_json_t(json_str_input,to_char(i));

      p_numseq         := hcm_util.get_string_t(param_json_row,'numseq');
      v_numseqOld      := hcm_util.get_string_t(param_json_row,'numseqOld');
--      p_codcompy       := hcm_util.get_string_t(param_json_row,'codcompy');
--      p_dteeffec       := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      obj_syncond      := hcm_util.get_json_t(param_json_row,'syncond');
      p_syncond        := hcm_util.get_string_t(obj_syncond, 'code');
      p_statement      := hcm_util.get_string_t(obj_syncond, 'statement');
      p_typbreak       := hcm_util.get_string_t(param_json_row,'typbreak');
      v_flg            := hcm_util.get_string_t(param_json_row,'flg');
      v_rowId          := hcm_util.get_string_t(param_json_row,'rowidOld');
      param_json_obj2  := hcm_util.get_json_t(param_json_row,'children');

      if v_flg = 'delete' then
        -- case delete parent table
        begin
          delete from totbreak a
                where a.codcompy = p_codcompy
                  and a.dteeffec = p_dteeffec
                  and a.numseq   = nvl(v_numseqOld, p_numseq);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
        -- case delete child table
        begin
          delete from totbreak2
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec
                  and numseq   = nvl(v_numseqOld, p_numseq);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
      else
        begin
          -- case check row (only update)
          select numseq into p_numseq
            from totbreak
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec
             and numseq   = p_numseq
             and rowId <> v_rowId
             and v_flg = 'edit';

          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'totbreak');
          return;
        exception when no_data_found then
          begin
            -- case insert parent table
            if v_rowId is null then
              if nvl(p_numseq,0) = 0 then
                select (nvl(max(numseq),0) + 1)
                  into p_numseq
                  from totbreak
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec;
              end if;
              check_totbreak;
              begin
                insert into totbreak (codcompy, dteeffec, coduser,
                                      numseq, syncond, statement, typbreak, codcreate)
                     values (p_codcompy, p_dteeffec, global_v_coduser,
                             p_numseq, p_syncond, p_statement, p_typbreak, global_v_coduser);
              exception when dup_val_on_index then
                update totbreak set syncond = p_syncond,
                                    statement = p_statement,
                                    typbreak = p_typbreak,
                                    coduser = global_v_coduser
                              where codcompy = p_codcompy
                                and dteeffec = p_dteeffec
                                and numseq = p_numseq;
              end;
            else
              -- case update parent table
              if (v_numseqOld is not null) and (p_numseq is not null) then
                -- update change primary key
                update totbreak
                   set dteupd   = trunc(sysdate),
                       coduser  = global_v_coduser,
                       syncond  = p_syncond,
                       statement = p_statement,
                       typbreak = p_typbreak,
                       numseq   = p_numseq
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseqOld;

                update totbreak2
                   set numseq   = p_numseq
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseqOld;
              else
                -- update default value
                update totbreak
                   set dteupd   = trunc(sysdate),
                       coduser  = global_v_coduser,
                       syncond  = p_syncond,
                       statement = p_statement,
                       typbreak = p_typbreak
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = p_numseq;
              end if;
            end if;
          end;
        end;

        for i in 0..param_json_obj2.get_size-1 loop
          json_row2        := hcm_util.get_json_t(param_json_obj2,to_char(i));
          p_numseq2        := hcm_util.get_string_t(json_row2,'numseq2');
          p_qtyminst       := null;
          p_qtyminen       := null;
          p_timstrt        := null;
          p_timend         := null;
          if p_typbreak = 'H' then
            p_qtyminst       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'timstrtot'));
            p_qtyminen       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'timendot'));
          elsif p_typbreak = 'T' then
            p_str_timstrt     := replace(hcm_util.get_string_t(json_row2,'timstrtot'), ':');
            p_str_timend      := replace(hcm_util.get_string_t(json_row2,'timendot'), ':');
          end if;
--          p_qtyminst       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminst'));
--          p_qtyminen       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminen'));
--          p_timstrt        := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_row2,'timstrt'));
--          p_timend         := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_row2,'timend'));
--          p_qtyminbk       := hcm_util.get_string_t(json_row2,'qtyminbk');
          p_qtyminbk       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminbk'));
          v_rowId2         := hcm_util.get_string_t(json_row2,'rowidOld2');
          v_flg_child      := hcm_util.get_string_t(json_row2,'flg');

          -- case delete child table
          if v_flg_child = 'delete' then
            begin
              delete from totbreak2
                    where codcompy = p_codcompy
                      and dteeffec = p_dteeffec
                      and numseq   = nvl(v_numseqOld, p_numseq)
                      and numseq2  = p_numseq2;
            exception when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
              return;
            end;
          elsif v_flg_child = 'add' then
            -- case insert child table
            if nvl(p_numseq2,0) = 0 then
              select (nvl(max(numseq2),0) + 1)
                into p_numseq2
                from totbreak2
               where codcompy = p_codcompy
                 and dteeffec = p_dteeffec
                 and numseq   = p_numseq;
            end if;
            begin
              insert into totbreak2 (codcompy, dteeffec, coduser, numseq,
                                    numseq2, qtyminst, qtyminen, timstrt,
                                    timend, qtyminbk, codcreate)
                   values (p_codcompy, p_dteeffec, global_v_coduser, p_numseq,
                           p_numseq2, p_qtyminst, p_qtyminen, p_str_timstrt,
                           p_str_timend, p_qtyminbk, global_v_coduser);
            exception when dup_val_on_index then
              update totbreak2 set coduser = global_v_coduser,
                                   qtyminst = p_qtyminst,
                                   qtyminen = p_qtyminen,
                                   timstrt = p_str_timstrt,
                                   timend = p_str_timend,
                                   qtyminbk = p_qtyminbk
                             where codcompy = p_codcompy
                               and dteeffec = p_dteeffec
                               and numseq = p_numseq
                               and numseq2 = p_numseq2;
            end;
          elsif v_flg_child = 'edit' then
            update totbreak2
               set dteupd   = trunc(sysdate),
                   coduser  = global_v_coduser,
                   qtyminst = p_qtyminst,
                   qtyminen = p_qtyminen,
                   timstrt  = p_str_timstrt,
                   timend   = p_str_timend,
                   qtyminbk = p_qtyminbk
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and numseq   = p_numseq
               and numseq2  = p_numseq2;
          end if;
        end loop;
      end if;
    end loop;
  end post_time_analysis_tab1;

  procedure post_payment_rate_tab2(json_str_input in json_object_t) as
    param_json_row  json_object_t;
    param_json_obj2 json_object_t;
    json_row2       json_object_t;
    obj_syncond     json_object_t;
    v_flg           varchar2(1000 char);
    v_flg_child     varchar2(1000 char);
    v_rowId         varchar2(1000 char);
    v_rowId2        varchar2(1000 char);
    v_numseqOld     number;
  begin
    if isCopy = 'Y' then
        begin
          delete from totratep a
                where a.codcompy = p_codcompy
                  and a.dteeffec = p_dteeffec;
        exception when others then
          null;
        end;

        begin
          delete from totratep2
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec;
        exception when others then
          null;
        end;
      end if;

    p_numseq     := 0;
    p_numseq2    := 0;
    for i in 0..json_str_input.get_size-1 loop
      param_json_row   := hcm_util.get_json_t(json_str_input,to_char(i));
      p_numseq         := hcm_util.get_string_t(param_json_row,'numseq');
      v_numseqOld      := hcm_util.get_string_t(param_json_row,'numseqOld');
--      p_codcompy       := hcm_util.get_string_t(param_json_row,'codcompy');
--      p_dteeffec       := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      obj_syncond      := hcm_util.get_json_t(param_json_row,'syncond');
      p_syncond        := hcm_util.get_string_t(obj_syncond, 'code');
      p_statement      := hcm_util.get_string_t(obj_syncond, 'statement');
      p_typrate        := hcm_util.get_string_t(param_json_row,'typrate');
      v_flg            := hcm_util.get_string_t(param_json_row,'flg');
      v_rowId          := hcm_util.get_string_t(param_json_row,'rowidOld');
      param_json_obj2  := hcm_util.get_json_t(param_json_row,'children');

      if v_flg = 'delete' then
        -- delete parent
        begin
          delete from totratep a
                where a.codcompy = p_codcompy
                  and a.dteeffec = p_dteeffec
                  and a.numseq   = p_numseq;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
        -- delete child
        begin
          delete from totratep2
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec
                  and numseq   = p_numseq;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
      else
        begin
          -- case check row (only update)
          select numseq into p_numseq
            from totratep
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec
             and numseq   = p_numseq
             and rowId <> v_rowId
             and v_flg = 'edit';

          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'totratep');
          return;
        exception when no_data_found then
          begin
            -- case insert parent table
            if v_rowId is null then
              if nvl(p_numseq,0) = 0 then
                select (nvl(max(numseq),0) + 1)
                  into p_numseq
                  from totratep
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec;
              end if;
              check_totratep;
              insert into totratep (codcompy, dteeffec, coduser, codcreate,
                                    numseq, syncond, statement, typrate)
                   values (p_codcompy, p_dteeffec, global_v_coduser, global_v_coduser,
                           p_numseq, p_syncond, p_statement, p_typrate);
            else
              -- case update parent table
              if (v_numseqOld is not null) and (p_numseq is not null) then
                -- update change primary key
                update totratep
                   set dteupd   = trunc(sysdate),
                       coduser  = global_v_coduser,
                       syncond  = p_syncond,
                       statement = p_statement,
                       typrate  = p_typrate,
                       numseq   = p_numseq
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseqOld;

                update totratep2
                   set numseq   = p_numseq
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseqOld;
              else
                -- update default value
                update totratep
                   set dteupd   = trunc(sysdate),
                       coduser  = global_v_coduser,
                       syncond  = p_syncond,
                       statement = p_statement,
                       typrate  = p_typrate
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = p_numseq;
              end if;
            end if;
          end;
        end;
        for i in 0..param_json_obj2.get_size-1 loop
          json_row2        := hcm_util.get_json_t(param_json_obj2,to_char(i));
          p_qtyminst       := null;     p_timstrt        := null;
          p_qtyminen       := null;     p_timend         := null;
          p_numseq2        := hcm_util.get_string_t(json_row2,'numseq2');
          p_rteotpay       := hcm_util.get_string_t(json_row2,'rteotpay');
          -- check flgrateot
          if p_flgrateot = '1' then
              p_qtyminst     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminst'));
              p_qtyminen     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminen'));
              p_timstrt      := replace(hcm_util.get_string_t(json_row2,'timstrt'), ':');
              p_timend       := replace(hcm_util.get_string_t(json_row2,'timend'), ':');
--              p_timstrt      := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_row2,'timstrt'));
--              p_timend       := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_row2,'timend'));
          elsif  p_flgrateot = '2' then
            if p_typrate = 'H' then
              p_qtyminst     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminst'));
              p_qtyminen     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminen'));
            elsif p_typrate = 'T' then
              p_timstrt      := replace(hcm_util.get_string_t(json_row2,'qtyminst'), ':');
              p_timend       := replace(hcm_util.get_string_t(json_row2,'qtyminen'), ':');
--              p_timstrt      := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_row2,'qtyminst'));
--              p_timend       := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_row2,'qtyminen'));
            end if;
          end if;
          v_flg_child      := hcm_util.get_string_t(json_row2,'flg');
          v_rowId2         := hcm_util.get_string_t(json_row2,'rowidOld2');

          -- case delete child table
          if v_flg_child = 'delete' then
            begin
              delete from totratep2
                    where codcompy = p_codcompy
                      and dteeffec = p_dteeffec
                      and numseq   = p_numseq
                      and numseq2  = p_numseq2;
            exception when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
              return;
            end;
          elsif v_flg_child = 'add' then
            if nvl(p_numseq2,0) = 0 then
              select (nvl(max(numseq2),0) + 1)
                into p_numseq2
                from totratep2
               where codcompy = p_codcompy
                 and dteeffec = p_dteeffec
                 and numseq   = p_numseq;
            end if;
            insert into totratep2 (codcompy, dteeffec, coduser, codcreate, numseq,
                                numseq2, qtyminst, qtyminen, timstrt, timend, rteotpay)
               values (p_codcompy, p_dteeffec, global_v_coduser, global_v_coduser, p_numseq,
                       p_numseq2, p_qtyminst, p_qtyminen, p_timstrt, p_timend, p_rteotpay);
          elsif v_flg_child = 'edit' then
            update totratep2
               set dteupd   = trunc(sysdate),
                   coduser  = global_v_coduser,
                   qtyminst = p_qtyminst,
                   qtyminen = p_qtyminen,
                   timstrt  = p_timstrt,
                   timend   = p_timend,
                   rteotpay = p_rteotpay
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and numseq   = p_numseq
               and numseq2  = p_numseq2;
          end if;
        end loop;
      end if;
    end loop;
  end post_payment_rate_tab2;

  procedure post_special_allowance_tab3(json_str_input in json_object_t) as
    param_json_row  json_object_t;
    param_json_obj2 json_object_t;
    obj_syncond     json_object_t;
    obj_amtmeal     json_object_t;
    json_row2       json_object_t;
    v_flg           varchar2(1000 char);
    v_flg_child     varchar2(1000 char);
    v_rowId         varchar2(1000 char);
    v_rowId2        varchar2(1000 char);
    v_numseqOld     number;
  begin
    if isCopy = 'Y' then
        begin
          delete from totmeal
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec;
        exception when others then
          null;
        end;

        begin
          delete from totmeal2
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec;
        exception when others then
          null;
        end;
      end if;

    p_numseq     := 0;
    p_numseq2    := 0;
    for i in 0..json_str_input.get_size-1 loop
      param_json_row   := hcm_util.get_json_t(json_str_input,to_char(i));
      p_numseq         := hcm_util.get_string_t(param_json_row,'numseq');
      v_numseqOld      := hcm_util.get_string_t(param_json_row,'numseqOld');
      obj_syncond      := hcm_util.get_json_t(param_json_row,'syncond');
      p_syncond        := hcm_util.get_string_t(obj_syncond, 'code');
      p_statement      := hcm_util.get_string_t(obj_syncond, 'statement');
      v_flg            := hcm_util.get_string_t(param_json_row,'flg');
      v_rowId          := hcm_util.get_string_t(param_json_row,'rowidOld');
      param_json_obj2  := hcm_util.get_json_t(param_json_row,'children');

      if v_flg = 'delete' then
        -- delete parent
        begin
          delete from totmeal
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec
                  and numseq   = p_numseq;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
        -- delete child
        begin
          delete from totmeal2
                where codcompy = p_codcompy
                  and dteeffec = p_dteeffec
                  and numseq   = p_numseq;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
      else
        begin
          -- case check row (only update)
          select numseq into p_numseq
            from totmeal
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec
             and numseq   = p_numseq
             and rowId <> v_rowId
             and v_flg = 'edit';

          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'totmeal');
          return;
        exception when no_data_found then
          begin
            -- case insert parent table
            if v_rowId is null then
              if nvl(p_numseq,0) = 0 then
                select (nvl(max(numseq),0) + 1)
                  into p_numseq
                  from totmeal
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec;
              end if;

              begin
                insert into totmeal (codcompy, dteeffec, coduser, codcreate,
                                     numseq, syncond, statement)
                     values (p_codcompy, p_dteeffec, global_v_coduser, global_v_coduser,
                             p_numseq, p_syncond, p_statement);
              exception when dup_val_on_index then
                update totmeal set coduser = global_v_coduser,
                                   syncond = p_syncond,
                                   statement = p_statement
                             where codcompy = p_codcompy
                               and dteeffec = p_dteeffec
                               and numseq = p_numseq;
              end;
            else
              -- case update parent table
              if (v_numseqOld is not null) and (p_numseq is not null) then
                -- update change primary key
                update totmeal
                   set dteupd   = trunc(sysdate),
                       coduser  = global_v_coduser,
                       syncond  = p_syncond,
                       statement = p_statement,
                       numseq   = p_numseq
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseqOld;

                update totmeal2
                   set numseq   = p_numseq
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseqOld;
              else
                -- update default value
                update totmeal
                   set dteupd   = trunc(sysdate),
                       coduser  = global_v_coduser,
                       syncond  = p_syncond,
                       statement = p_statement
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq   = p_numseq;
              end if;
            end if;
          end;
        end;

        for i in 0..param_json_obj2.get_size-1 loop
          json_row2        := hcm_util.get_json_t(param_json_obj2, to_char(i));
          p_numseq2        := hcm_util.get_string_t(json_row2,'numseq2');
          p_qtyminst       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminst'));
          p_qtyminen       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2,'qtyminen'));
          obj_amtmeal      := hcm_util.get_json_t(json_row2, 'amtmeal_calculator');
          p_amtmeal        := hcm_util.get_string_t(obj_amtmeal, 'code');
          v_rowId2         := hcm_util.get_string_t(json_row2,'rowidOld2');
          v_flg_child      := hcm_util.get_string_t(json_row2,'flg');

          -- case delete child table
          if v_flg_child = 'delete' then
            begin
              delete from totmeal2
                    where codcompy = p_codcompy
                      and dteeffec = p_dteeffec
                      and numseq   = p_numseq
                      and numseq2  = p_numseq2;
            exception when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
              return;
            end;
          elsif v_flg_child = 'add' then
            check_totmeal;
            if nvl(p_numseq2,0) = 0 then
              select (nvl(max(numseq2),0) + 1)
                into p_numseq2
                from totmeal2
               where codcompy = p_codcompy
                 and dteeffec = p_dteeffec
                 and numseq   = p_numseq;
            end if;
            begin
              insert into totmeal2 (codcompy, dteeffec, coduser, codcreate, numseq, numseq2,
                                    qtyminst, qtyminen, amtmeal)
                   values (p_codcompy, p_dteeffec, global_v_coduser, global_v_coduser, p_numseq, p_numseq2,
                           p_qtyminst, p_qtyminen, p_amtmeal);
            exception when dup_val_on_index then
              update totmeal2 set coduser = global_v_coduser,
                                 qtyminst = p_qtyminst,
                                 qtyminen = p_qtyminen,
                                 amtmeal = p_amtmeal
                           where codcompy = p_codcompy
                             and dteeffec = p_dteeffec
                             and numseq = p_numseq
                             and numseq2 = p_numseq2;
            end;
          elsif v_flg_child = 'edit' then
            update totmeal2
               set dteupd   = trunc(sysdate),
                   coduser  = global_v_coduser,
                   qtyminst = p_qtyminst,
                   qtyminen = p_qtyminen,
                   amtmeal  = p_amtmeal
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and numseq   = p_numseq
               and numseq2  = p_numseq2;
          end if;
        end loop;
      end if;
    end loop;
  end post_special_allowance_tab3;

  procedure save_revenue_code is
  begin
    begin
      insert into tcontrot (codcompy, dteeffec, dteupd, coduser, codcreate, codot, codrtot, codotalw,
                            condot, condextr, flgchglv, flgrateot, statementot, statementex, qtymincal,
                            typalert, qtymxotwk,qtymxallwk,startday,otcalflg--<< user25 Date: 02/08/2021 TDKU-SS-2101
                            )
           values (p_codcompy, p_dteeffec, trunc(sysdate), global_v_coduser, global_v_coduser, p_codot, p_codrtot, p_codotalw,
                   p_condot, p_condextr, p_flgchglv, p_flgrateot, p_statementot, p_statementex, p_qtymincal,
                   p_typalert, p_qtymxotwk,p_qtymxallwk,p_startday,p_otcalflg--<< user25 Date: 02/08/2021 TDKU-SS-2101
                   );
    exception when dup_val_on_index then
      update tcontrot set dteupd    = trunc(sysdate),
                          coduser   = global_v_coduser,
                          codot     = p_codot,
                          codrtot   = p_codrtot,
                          codotalw  = p_codotalw,
                          condot    = p_condot,
                          condextr  = p_condextr,
                          flgchglv  = p_flgchglv,
                          flgrateot = p_flgrateot,
                          statementot = p_statementot,
                          statementex = p_statementex,
                          qtymincal   = p_qtymincal,
                          --<< user25 Date: 02/08/2021 TDKU-SS-2101
                          typalert    = p_typalert,
                          qtymxotwk   = p_qtymxotwk,
                          qtymxallwk  = p_qtymxallwk,
                          startday  = p_startday,
                          otcalflg  = p_otcalflg
                          -->> user25 Date: 02/08/2021 TDKU-SS-2101
                    where codcompy  = p_codcompy
                      and dteeffec  = p_dteeffec;
    end;
  end save_revenue_code;

  procedure save_payment_rate_labr_law is
--    v_temp_codcompy   varchar2(100 char):= 'XXXX';
--    v_temp_dteeffec   date := '01-JAN-18';
  begin
    -- select insert parent table
    insert into totratep (codcompy, dteeffec, coduser, codcreate,
                          numseq, syncond, statement, typrate)
    select p_codcompy, p_dteeffec, global_v_coduser, global_v_coduser,
           numseq, syncond, statement, typrate
      from ttotratep;
      -- update change table totratep -> ttotratep by user03 - 28/11/2018
--     where codcompy = v_temp_codcompy
--       and dteeffec = v_temp_dteeffec;

    -- select insert child table
    insert into totratep2 (codcompy, dteeffec, coduser, codcreate, numseq,
                           numseq2, qtyminst, qtyminen, timstrt, timend, rteotpay)
    select p_codcompy, p_dteeffec, global_v_coduser, global_v_coduser, numseq,
           numseq2, qtyminst, qtyminen, timstrt, timend, rteotpay
      from ttotratep2;
      -- update change table totratep2 -> ttotratep2 by user03 - 28/11/2018
--     where codcompy = v_temp_codcompy
--       and dteeffec = v_temp_dteeffec;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return;
  end save_payment_rate_labr_law;

  procedure rounding_minutes_tab1_update (json_current in out json_object_t) is
    param_json_row        json_object_t;
    v_flg                 varchar2(1000 char);
    v_qtymstotOld         number;
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new            := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      param_json_row    := json_object_t(json_current.get(to_char(k)).to_clob);
      p_qtymstot        := to_number(hcm_util.get_string_t(param_json_row, 'qtymstot'));
      p_qtymenot        := to_number(hcm_util.get_string_t(param_json_row, 'qtymenot'));
      p_qtymacot        := to_number(hcm_util.get_string_t(param_json_row, 'qtymacot'));
      v_qtymstotOld     := to_number(hcm_util.get_string_t(param_json_row, 'qtymstotOld'));
      v_flg             := hcm_util.get_string_t(param_json_row, 'flg');

      begin
            update tcontot1 set coduser  = global_v_coduser,
                                qtymstot = p_qtymstot,
                                qtymenot = p_qtymenot,
                                qtymacot = p_qtymacot
                          where codcompy = p_codcompy
                            and dteeffec = p_dteeffec
                            and qtymstot = v_qtymstotOld;
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), param_json_row);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end rounding_minutes_tab1_update;

  procedure rounding_minutes_tab1_insert (json_current in out json_object_t) is
    param_json_row        json_object_t;
    v_flg                 varchar2(1000 char);
    v_qtymstotOld         number;
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new            := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      param_json_row    := json_object_t(json_current.get(to_char(k)).to_clob);
      p_qtymstot        := to_number(hcm_util.get_string_t(param_json_row, 'qtymstot'));
      p_qtymenot        := to_number(hcm_util.get_string_t(param_json_row, 'qtymenot'));
      p_qtymacot        := to_number(hcm_util.get_string_t(param_json_row, 'qtymacot'));
      v_qtymstotOld     := to_number(hcm_util.get_string_t(param_json_row, 'qtymstotOld'));
      v_flg             := hcm_util.get_string_t(param_json_row, 'flg');

      begin
        insert into tcontot1 (codcompy, dteeffec, qtymstot, qtymenot,
                              qtymacot, coduser, codcreate)
             values (p_codcompy, p_dteeffec, p_qtymstot, p_qtymenot,
                     p_qtymacot, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), param_json_row);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end rounding_minutes_tab1_insert;

END HRAL92E;

/
