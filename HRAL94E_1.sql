--------------------------------------------------------
--  DDL for Package Body HRAL94E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL94E" is
-- last update: 15/01/2018 10:50
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

    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    p_codempid_query    := upper(hcm_util.get_string_t(json_obj,'p_codempid_query'));
    p_codcompy          := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
    p_codaward          := hcm_util.get_string_t(json_obj,'p_codaward');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_codcompyQuery     := upper(hcm_util.get_string_t(json_obj,'p_codcompyQuery'));
    p_codawardQuery     := upper(hcm_util.get_string_t(json_obj,'p_codawardQuery'));
    p_dteeffecQuery     := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecQuery'),'dd/mm/yyyy');
    p_dteeffecOld       := p_dteeffec;

    forceAdd            := hcm_util.get_string_t(json_obj,'forceAdd');
    p_isAddOrigin       := hcm_util.get_string_t(json_obj,'p_isAddOrigin');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_qtyavgwk          varchar2(4000 char);
    v_flgrdabs          varchar2(4000 char);
    v_secur             boolean := false;
    v_count             number := 0;
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codaward is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codaward');
      return;
    else
      begin
         select count(*) into v_count
           from tcodawrd
          where codcodec = p_codaward;
      end;
      if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codaward');
        return;
      end if;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
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
      obj_data.put('isAddOrigin', isAddOrigin);
      obj_data.put('isCopy', nvl(forceAdd, 'N'));
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('codaward', p_codaward);
      if isAdd or isEdit then
        obj_data.put('dteeffec', to_char(p_dteeffecOld, 'DD/MM/YYYY'));
        obj_data.put('msqerror', '');  
        obj_data.put('detailDisabled', false);  
      else
        obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));
        obj_data.put('msqerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));  
        obj_data.put('detailDisabled', true);  
      end if;

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
    begin
     select count(*) into v_count
       from tcontraw
      where codcompy = p_codcompy
        and codaward = p_codaward
        and dteeffec = p_dteeffec;
      v_flgadd := false;
      v_indexdteeffec := p_dteeffec;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then
      select max(dteeffec) into v_maxdteeffec
        from tcontraw
       where codcompy = p_codcompy
         and codaward = p_codaward
         and dteeffec <= p_dteeffec;
      if p_dteeffec < trunc(sysdate) then
        v_indexdteeffec := v_maxdteeffec;
        isEdit := false;
      else
        v_indexdteeffec := p_dteeffec;
        isAdd := true;
      end if;

      if v_maxdteeffec is null then
          select min(dteeffec) 
            into v_maxdteeffec
            from tcontraw
           where codcompy = p_codcompy
             and codaward = p_codaward
             and dteeffec > p_dteeffec;   
          if v_maxdteeffec is null then
            isEdit := false;
            isAdd  := true;
            isAddOrigin := true;          
          else
            v_indexdteeffec := v_maxdteeffec;
            p_dteeffec      := v_maxdteeffec;
            isEdit := false;
            isAdd := false;
          end if;
      else
        p_dteeffec := v_maxdteeffec;
      end if;
    else
      if p_dteeffec < trunc(sysdate) then
        isEdit := false;
      else
        isEdit := true;
      end if;
       v_indexdteeffec := p_dteeffec;
    end if;
    if forceAdd = 'Y' then
      isEdit := false;
      isAdd  := true;
    elsif p_isAddOrigin = 'Y' then
      isEdit := true;
      isAdd  := false;
      isAddOrigin := true;
    end if;
  end;

  procedure get_tab1_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1_detail(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1_detail;

  procedure gen_tab1_detail (json_str_output out clob) as
    obj_detail          json_object_t;
    cursor c_tcontraw is
      select syncond, codpay, codrtawrd, qtyretpriod, statement,
             qtylate, qtyearly, qtyabsent, qtyall,
             timlate, timearly, timabsent, timall, timnoatm, numprdclr, dtemthclr,
             dteupd, coduser
        from tcontraw
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and codaward = nvl(p_codawardQuery, p_codaward)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec);

  begin
    obj_detail        := json_object_t();
    obj_detail.put('coderror', '200');

    obj_detail.put('syncond', '');
    obj_detail.put('desc_syncond', '');
    obj_detail.put('codpay', '');
    obj_detail.put('codrtawrd', '');
    obj_detail.put('qtyretpriod', '');
    obj_detail.put('numprdclr', '');
    obj_detail.put('dtemthclr', '');
    for c1 in c_tcontraw loop
      obj_detail.put('syncond', c1.syncond);
      obj_detail.put('desc_syncond', get_logical_desc(c1.statement));
      obj_detail.put('statement', c1.statement);
      obj_detail.put('codpay', c1.codpay);
      obj_detail.put('codrtawrd', c1.codrtawrd);
      obj_detail.put('qtyretpriod', c1.qtyretpriod);
      obj_detail.put('numprdclr', c1.numprdclr);
      obj_detail.put('dtemthclr', c1.dtemthclr);
      obj_detail.put('dteupd', to_char(c1.dteupd,'dd/mm/yyyy hh24:mi:ss'));
      obj_detail.put('codupd', get_codempid(c1.coduser));
      obj_detail.put('desc_coduser', c1.coduser || ' - ' || get_temploy_name(get_codempid(c1.coduser),global_v_lang));
      obj_detail.put('codimage', get_emp_img(get_codempid(c1.coduser)));
    end loop;
    if isInsertReport then
      -- insert ttemprpt for report specific
      insert_ttemprpt(obj_detail);
    end if;
    json_str_output := obj_detail.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_tab1_table1 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1_table1(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1_table1;

  procedure gen_tab1_table1 (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_label1            varchar2(4000 char);
    v_label2            varchar2(4000 char);
    v_label3            varchar2(4000 char);
    v_label4            varchar2(4000 char);
    v_label5            varchar2(4000 char);
    cursor c_tcontraw is
      select syncond, codpay, codrtawrd, qtyretpriod,
             qtylate, qtyearly, qtyabsent, qtyall,
             timlate, timearly, timabsent, timall, timnoatm
        from tcontraw
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and codaward = nvl(p_codawardQuery, p_codaward)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec);
  begin
    obj_row           := json_object_t();

    v_label1          := get_label_name('HRAL94EP1', global_v_lang, '220');
    v_rcnt            := v_rcnt+1;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');

    obj_data.put('flgAdd', isAdd);
    obj_data.put('label', v_label1);
    obj_data.put('qty', 0);
    obj_data.put('time', 0);
    obj_row.put(to_char(v_rcnt-1), obj_data);
    if isInsertReport then
      -- insert ttemprpt for report specific
      insert_ttemprpt(obj_data);
    end if;

    v_label2          := get_label_name('HRAL94EP1', global_v_lang, '230');
    v_rcnt            := v_rcnt+1;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');

    obj_data.put('flgAdd', isAdd);
    obj_data.put('label', v_label2);
    obj_data.put('qty', 0);
    obj_data.put('time', 0);
    obj_row.put(to_char(v_rcnt-1), obj_data);
    if isInsertReport then
      -- insert ttemprpt for report specific
      insert_ttemprpt(obj_data);
    end if;

    v_label3          := get_label_name('HRAL94EP1', global_v_lang, '240');
    v_rcnt            := v_rcnt+1;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');

    obj_data.put('flgAdd', isAdd);
    obj_data.put('label', v_label3);
    obj_data.put('qty', 0);
    obj_data.put('time', 0);
    obj_row.put(to_char(v_rcnt-1), obj_data);
    if isInsertReport then
      -- insert ttemprpt for report specific
      insert_ttemprpt(obj_data);
    end if;

    v_label4          := get_label_name('HRAL94EP1', global_v_lang, '250');
    v_rcnt            := v_rcnt+1;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');

    obj_data.put('flgAdd', isAdd);
    obj_data.put('label', v_label4);
    obj_data.put('qty', '');
    obj_data.put('time', '');
    obj_row.put(to_char(v_rcnt-1), obj_data);
    if isInsertReport then
      -- insert ttemprpt for report specific
      insert_ttemprpt(obj_data);
    end if;

    v_label5          := get_label_name('HRAL94EP1', global_v_lang, '260');
    v_rcnt            := v_rcnt+1;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');

    obj_data.put('flgAdd', isAdd);
    obj_data.put('label', v_label5);
    -- obj_data.put('qty', '');
    obj_data.put('time', 0);
    obj_row.put(to_char(v_rcnt-1), obj_data);
    if isInsertReport then
      -- insert ttemprpt for report specific
      insert_ttemprpt(obj_data);
    end if;
    for c1 in c_tcontraw loop
      if isInsertReport then
        -- clear ttemprpt for report specific
        clear_ttemprpt;
      end if;
      v_rcnt            := 0;

      v_rcnt            := v_rcnt+1;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');

      obj_data.put('flgAdd', isAdd);
      obj_data.put('label', v_label1);
      obj_data.put('qty', c1.qtylate);
      obj_data.put('time', c1.timlate);
      obj_row.put(to_char(v_rcnt-1), obj_data);
      if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_data);
      end if;

      v_rcnt            := v_rcnt+1;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');

      obj_data.put('flgAdd', isAdd);
      obj_data.put('label', v_label2);
      obj_data.put('qty', c1.qtyearly);
      obj_data.put('time', c1.timearly);
      obj_row.put(to_char(v_rcnt-1), obj_data);
      if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_data);
      end if;

      v_rcnt            := v_rcnt+1;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');

      obj_data.put('flgAdd', isAdd);
      obj_data.put('label', v_label3);
      obj_data.put('qty', c1.qtyabsent);
      obj_data.put('time', c1.timabsent);
      obj_row.put(to_char(v_rcnt-1), obj_data);
      if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_data);
      end if;

      v_rcnt            := v_rcnt+1;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');

      obj_data.put('flgAdd', isAdd);
      obj_data.put('label', v_label4);
      obj_data.put('qty', c1.qtyall);
      obj_data.put('time', c1.timall);
      obj_row.put(to_char(v_rcnt-1), obj_data);
      if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_data);
      end if;

      v_rcnt            := v_rcnt+1;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');

      obj_data.put('flgAdd', isAdd);
      obj_data.put('label', v_label5);
      -- obj_data.put('qty', '');
      obj_data.put('time', c1.timnoatm);
      obj_row.put(to_char(v_rcnt-1), obj_data);
      if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1_table1;

  procedure get_tab1_table2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1_table2(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1_table2;

  procedure gen_tab1_table2 (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    cursor c_tcontaw5 is
      select rowId, codchng
        from tcontaw5
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and codaward = nvl(p_codawardQuery, p_codaward)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
    order by codchng asc;
  begin
    obj_row             := json_object_t();
    for c1 in c_tcontaw5 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');

      obj_data.put('rowId', c1.rowId);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('flgAdd', isAdd);
      obj_data.put('codchng', c1.codchng);
      obj_data.put('desc_codchng', c1.codchng || ' - ' || get_tcodec_name('tcodtime', c1.codchng, global_v_lang));
      obj_row.put(to_char(v_rcnt-1), obj_data);
      if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1_table2;

  procedure get_tab1_table3 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1_table3(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1_table3;

  procedure gen_tab1_table3 (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    cursor c_tcontaw2 is
      select rowId, codleave, timleave, qtyminlv
        from tcontaw2
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and codaward = nvl(p_codawardQuery, p_codaward)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
    order by codleave asc;
  begin
    obj_row             := json_object_t();
    for c1 in c_tcontaw2 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');

      obj_data.put('rowId', c1.rowId);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('flgAdd', isAdd);
      obj_data.put('codleave', c1.codleave);
      obj_data.put('desc_codleave', c1.codleave || ' - ' || get_tleavecd_name(c1.codleave, global_v_lang));
      obj_data.put('timleave', c1.timleave);
      obj_data.put('qtyminlv', hcm_util.convert_minute_to_hour(c1.qtyminlv));
      obj_row.put(to_char(v_rcnt-1), obj_data);
      if isInsertReport then
        -- insert ttemprpt for report specific
        insert_ttemprpt(obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1_table3;

  procedure get_tab2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    gen_flg_status;
    gen_tab2 (json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab2;

  procedure gen_tab2 (json_str_output out clob) is
    obj_data            json_object_t;
    obj_data2           json_object_t;
    obj_row             json_object_t;
    obj_row2            json_object_t;
    v_rcnt              number := 0;
    v_rcnt2             number := 0;
    v_numseq            number := 0;

    cursor c_tcontaw3 is
      select numseq, syncond, statement
        from tcontaw3
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and codaward = nvl(p_codawardQuery, p_codaward)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
    order by numseq asc;
    cursor c_tcontaw4 is
      select rowId, numseq, qtyaw, formula
        from tcontaw4
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and codaward = nvl(p_codawardQuery, p_codaward)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
         and numseq   = v_numseq
    order by qtyaw asc;
  begin
    obj_row         := json_object_t();
    for i in c_tcontaw3 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');

      v_numseq      := i.numseq;
      obj_data.put('flgAdd', isAdd);
      obj_data.put('numseq', i.numseq);
      obj_data.put('syncond', i.syncond);
      obj_data.put('statement', i.statement);
      obj_data.put('desc_syncond', get_logical_desc(i.statement));
--      obj_data.put('desc_syncond', get_logical_desc(i.statement));


      v_rcnt2       := 0;
      obj_row2      := json_object_t();
      for j in c_tcontaw4 loop
        v_rcnt2      := v_rcnt2+1;
        obj_data2    := json_object_t();

        obj_data2.put('coderror', '200');

        obj_data2.put('rcnt', v_rcnt);
        obj_data2.put('desc_syncond', hcm_util.get_string_t(obj_data, 'desc_syncond'));

        obj_data2.put('rowId', j.rowId);
        obj_data2.put('flgAdd', isAdd);
        obj_data2.put('qtyaw', j.qtyaw);
        obj_data2.put('formula', j.formula);
        -- obj_data2.put('desc_formula', get_logical_name('HRAL94E', j.formula, global_v_lang));
        obj_data2.put('desc_formula', hcm_formula.get_description(j.formula, global_v_lang));
        obj_row2.put(to_char(v_rcnt2-1), obj_data2);
        if isInsertReport then
          -- insert ttemprpt for report specific
          insert_ttemprpt(obj_data2);
        end if;
      end loop;
      obj_data.put('children', obj_row2);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab2;

  procedure get_popup (json_str_input in clob, json_str_output out clob) as
    obj_data              json_object_t;
    obj_row               json_object_t;
    v_secur               varchar2(1000 char);
    v_rcnt                number := 0;
    cursor c_tcontraw is
      select codcompy, codaward, dteeffec
        from tcontraw;
  begin
    initial_value (json_str_input);
    obj_row              := json_object_t();
    for i in c_tcontraw loop
      v_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, i.codcompy);
      if v_secur is null then
        v_rcnt             := v_rcnt+1;
        obj_data           := json_object_t();

        obj_data.put('coderror', '200');

        obj_data.put('codcompy',i.codcompy);
        obj_data.put('desc_codcompy', get_tcompny_name(i.codcompy, global_v_lang));
        obj_data.put('codaward',i.codaward);
        obj_data.put('desc_codaward',i.codaward||' - '||get_tcodec_name('tcodawrd',i.codaward,global_v_lang));
        obj_data.put('dteeffec',to_char(i.dteeffec, 'dd/mm/yyyy'));
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_popup;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    json_input_obj      := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
--    json_input_obj      := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    isCopy              := hcm_util.get_string_t(json_input_obj, 'isCopy');
    if isCopy = 'Y' then
      begin
        delete from tcontraw where codcompy = p_codcompy and codaward = p_codaward and dteeffec = p_dteeffec;
      end;
    end if;

    if param_msg_error is null then
      save_tab1_detail (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab1_table1 (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab1_table2 (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab1_table3 (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab2 (json_str_output);
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

  procedure save_tab1_detail (json_str_output out clob) is
    obj_tab1            json_object_t;
    obj_detail          json_object_t;
    obj_syncond         json_object_t;
    v_syncond           varchar2(4000 char);
    v_statement         clob;
    v_codpay            varchar2(4000 char);
    v_codrtawrd         varchar2(4000 char);
    v_qtyretpriod       varchar2(4000 char);
    v_numprdclr         varchar2(4000 char);
    v_dtemthclr         varchar2(4000 char);
    v_code              varchar2(100 char);
  begin
    obj_tab1            := hcm_util.get_json_t(json_input_obj,'tab1');
    obj_detail          := hcm_util.get_json_t(obj_tab1,'detail');
    obj_syncond         := hcm_util.get_json_t(obj_detail,'syncond');
    v_syncond           := hcm_util.get_string_t(obj_syncond, 'code');
    v_statement         := hcm_util.get_string_t(obj_syncond, 'statement');
    v_codpay            := hcm_util.get_string_t(obj_detail,'codpay');
    v_codrtawrd         := hcm_util.get_string_t(obj_detail,'codrtawrd');
    v_qtyretpriod       := hcm_util.get_string_t(obj_detail,'qtyretpriod');
    v_numprdclr         := hcm_util.get_string_t(obj_detail,'numprdclr');
    v_dtemthclr         := hcm_util.get_string_t(obj_detail,'dtemthclr');

    param_msg_error := checkTcodec('tinexinf', v_codpay);
    if param_msg_error is not null then
      return;
    end if;

/*
    begin
      select 'Y'
        into v_code
        from tcontraw
       where codcompy   = p_codcompy
         and codaward   <> p_codaward
         and (codpay = v_codpay or codrtawrd = v_codrtawrd)
         and rownum     = 1;
       param_msg_error  := get_error_msg_php('AL0074',global_v_lang);
    exception when no_data_found then null; end;
*/

--    param_msg_error := checkTcodec('tinexinf', v_codrtawrd);
--    if param_msg_error is not null then
--      return;
--    end if;

    begin
      insert into tcontraw
             (codcompy, codaward, dteeffec, syncond, statement, codpay, codrtawrd, qtyretpriod, numprdclr, dtemthclr, coduser, codcreate)
      values (p_codcompy, p_codaward, p_dteeffec, v_syncond, v_statement, v_codpay, v_codrtawrd, v_qtyretpriod, 
              v_numprdclr, v_dtemthclr, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update tcontraw
         set syncond     = v_syncond,
             statement   = v_statement,
             codpay      = v_codpay,
             codrtawrd   = v_codrtawrd,
             qtyretpriod = v_qtyretpriod,
             numprdclr   = v_numprdclr,
             dtemthclr   = v_dtemthclr,
             coduser     = global_v_coduser,
             codcreate   = global_v_coduser
       where codcompy  = p_codcompy
         and codaward  = p_codaward
         and dteeffec  = p_dteeffec;
    end;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab1_table1 (json_str_output out clob) is
    obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_qtylate             number := 0;
    v_qtyearly            number := 0;
    v_qtyabsent           number := 0;
    v_qtyall              number := 0;
    v_timlate             number := 0;
    v_timearly            number := 0;
    v_timabsent           number := 0;
    v_timall              number := 0;
    v_timnoatm            number := 0;

  begin
    obj_tab1              := hcm_util.get_json_t(json_input_obj,'tab1');
    json_param_obj        := hcm_util.get_json_t(obj_tab1,'table1');
    for i in 0..json_param_obj .get_size-1 loop
      json_row    := hcm_util.get_json_t(json_param_obj,to_char(i));
      if i = 0 then
        v_qtylate   := hcm_util.get_string_t(json_row, 'qty');
        v_timlate   := hcm_util.get_string_t(json_row, 'time');
      elsif i = 1 then
        v_qtyearly  := hcm_util.get_string_t(json_row, 'qty');
        v_timearly  := hcm_util.get_string_t(json_row, 'time');
      elsif i = 2 then
        v_qtyabsent := hcm_util.get_string_t(json_row, 'qty');
        v_timabsent := hcm_util.get_string_t(json_row, 'time');
      elsif i = 3 then
        v_qtyall    := hcm_util.get_string_t(json_row, 'qty');
        v_timall    := hcm_util.get_string_t(json_row, 'time');
      elsif i = 4 then
        v_timnoatm  := hcm_util.get_string_t(json_row, 'time');
      end if;
    end loop;
    begin
      insert into tcontraw
             (codcompy, codaward, dteeffec, qtylate, qtyearly, qtyabsent, qtyall, timlate, timearly, timabsent, timall, timnoatm, codcreate)
      values (p_codcompy, p_codaward, p_dteeffec, v_qtylate, v_qtyearly, v_qtyabsent, v_qtyall, v_timlate, v_timearly, v_timabsent, v_timall, v_timnoatm, global_v_coduser);
    exception when dup_val_on_index then
      update tcontraw
         set qtylate   = v_qtylate,
             qtyearly  = v_qtyearly,
             qtyabsent = v_qtyabsent,
             qtyall    = v_qtyall,
             timlate   = v_timlate,
             timearly  = v_timearly,
             timabsent = v_timabsent,
             timall    = v_timall,
             timnoatm  = v_timnoatm,
             coduser   = global_v_coduser,
             codcreate = global_v_coduser
       where codcompy = p_codcompy
         and codaward  = p_codaward
         and dteeffec = p_dteeffec;
    end;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab1_table2 (json_str_output out clob) is
    obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_rowId               varchar2(1000 char);
    v_codchngOld          varchar2(100 char);
    v_codchng             varchar2(100 char);
    v_flag                varchar2(100 char);
  begin
    obj_tab1              := hcm_util.get_json_t(json_input_obj,'tab1');
    json_param_obj        := hcm_util.get_json_t(obj_tab1,'table2');
    for i in 0..json_param_obj.get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_rowId             := hcm_util.get_string_t(json_row, 'rowId');
      v_codchngOld        := hcm_util.get_string_t(json_row, 'codchngOld');
      v_codchng           := hcm_util.get_string_t(json_row, 'codchng');
      v_flag              := hcm_util.get_string_t(json_row, 'flg');

      if v_flag = 'delete' then
        delete from tcontaw5
         where codcompy = p_codcompy
           and codaward = p_codaward
           and dteeffec = p_dteeffec
           and codchng  = nvl(v_codchngOld, v_codchng);
      elsif v_flag = 'add' then
        param_msg_error := checkTcodec('tcodtime', v_codchng);
        if param_msg_error is not null then
          return;
        end if;
        begin
          insert into tcontaw5
                 (codcompy, codaward, dteeffec, codchng, codcreate, coduser)
          values (p_codcompy, p_codaward, p_dteeffec, v_codchng, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontaw5');
          return;
        end;
      else
        param_msg_error := checkTcodec('tcodtime', v_codchng);
        if param_msg_error is not null then
          return;
        end if;
        begin
          select codchng
            into v_codchng
            from tcontaw5
           where codcompy = p_codcompy
             and codaward = p_codaward
             and dteeffec = p_dteeffec
             and codchng = v_codchng
             and rowId <> v_rowId;

          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontaw5');
          return;
        exception when no_data_found then
          if v_rowId is null then
            insert into tcontaw5
                   (codcompy, codaward, dteeffec, codchng, codcreate, coduser)
            values (p_codcompy, p_codaward, p_dteeffec, v_codchng, global_v_coduser, global_v_coduser);
          else
            update tcontaw5
               set codchng = v_codchng,
                   coduser = global_v_coduser,
                   codcreate = global_v_coduser
             where codcompy = p_codcompy
               and codaward = p_codaward
               and dteeffec = p_dteeffec
               and codchng = v_codchngOld;
          end if;
        end;
      end if;
    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab1_table3 (json_str_output out clob) is
    obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_rowId               varchar2(1000 char);
    v_codleaveOld         varchar2(100 char);
    v_codleave            varchar2(100 char);
    v_timleave            number;
    v_qtyminlv            number;
    v_flag                varchar2(100 char);
  begin
    obj_tab1              := hcm_util.get_json_t(json_input_obj,'tab1');
    json_param_obj        := hcm_util.get_json_t(obj_tab1,'table3');
    for i in 0..json_param_obj .get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_rowId             := hcm_util.get_string_t(json_row, 'rowId');
      v_codleaveOld       := hcm_util.get_string_t(json_row, 'codleaveOld');
      v_codleave          := hcm_util.get_string_t(json_row, 'codleave');
      v_timleave          := to_number(hcm_util.get_string_t(json_row, 'timleave'));
      v_qtyminlv := null;
      if hcm_util.get_string_t(json_row, 'qtyminlv') is not null then
        v_qtyminlv          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row, 'qtyminlv'));
      end if;
      v_flag              := hcm_util.get_string_t(json_row, 'flg');
      if v_flag = 'delete' then
        delete from tcontaw2
         where codcompy = p_codcompy
           and codaward  = p_codaward
           and dteeffec = p_dteeffec
           and codleave = nvl(v_codleaveOld, v_codleave);
      else
        if v_flag = 'add' then
          param_msg_error := checkTcodec('tleavecd', v_codleave);
          if param_msg_error is not null then
            return;
          end if;
          begin
            insert into tcontaw2
                   (codcompy, codaward, dteeffec, codleave, timleave, qtyminlv, codcreate, coduser)
            values (p_codcompy, p_codaward, p_dteeffec, v_codleave, v_timleave, v_qtyminlv, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontaw2');
            return;
          end;
        else
          param_msg_error := checkTcodec('tleavecd', v_codleave);
          if param_msg_error is not null then
            return;
          end if;
          begin
            select codleave
              into v_codleave
              from tcontaw2
             where codcompy = p_codcompy
               and codaward  = p_codaward
               and dteeffec = p_dteeffec
               and codleave = v_codleave
               and rowId <> v_rowId;

            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal5');
            return;
          exception when no_data_found then
            if v_rowId is null then
              insert into tcontaw2
                     (codcompy, codaward, dteeffec, codleave, timleave, qtyminlv, codcreate, coduser)
              values (p_codcompy, p_codaward, p_dteeffec, v_codleave, v_timleave, v_qtyminlv, global_v_coduser, global_v_coduser);
            else
              update tcontaw2
                 set codleave = v_codleave,
                     timleave = v_timleave,
                     qtyminlv = v_qtyminlv,
                     coduser  = global_v_coduser
               where codcompy = p_codcompy
                 and codaward  = p_codaward
                 and dteeffec = p_dteeffec
                 and codleave = v_codleaveOld;
            end if;
          end;
        end if;
      end if;
    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab2 (json_str_output out clob) is
    json_param_obj        json_object_t;
    json_row              json_object_t;
    json_param_obj2       json_object_t;
    json_row2             json_object_t;
    v_numseq              number;
    obj_syncond           json_object_t;
    v_syncond             varchar2(4000 char);
    v_flag                varchar2(100 char);
    v_statement            clob;

    v_qtyawOld            number;
    v_qtyaw               number;
    obj_formula           json_object_t;
    v_rowId               varchar2(1000 char);
    v_formula             varchar2(4000 char);
    v_flagd               varchar2(100 char);
  begin
    json_param_obj        := hcm_util.get_json_t(json_input_obj,'tab2');
    for i in 0..json_param_obj .get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_numseq            := hcm_util.get_string_t(json_row, 'numseq');
      obj_syncond         := hcm_util.get_json_t(json_row,'syncond');
      v_statement         := hcm_util.get_string_t(obj_syncond, 'statement');
      v_syncond           := hcm_util.get_string_t(obj_syncond, 'code');
      v_flag              := hcm_util.get_string_t(json_row, 'flg');

      if v_flag = 'delete' then
        delete from tcontaw3
         where codcompy = p_codcompy
           and codaward = p_codaward
           and dteeffec = p_dteeffec
           and numseq   = v_numseq;
        delete from tcontaw4
         where codcompy = p_codcompy
           and codaward = p_codaward
           and dteeffec = p_dteeffec
           and numseq   = v_numseq;
      else
        if v_numseq is null then
          begin
            select count(numseq) + 1
              into v_numseq
              from tcontaw3
             where codcompy = p_codcompy
               and codaward = p_codaward
               and dteeffec = p_dteeffec;
          exception when no_data_found then
           v_numseq := 1;
          end;
        end if;
--        elsif v_flagd = 'add' then
        begin
          insert into tcontaw3
                 (codcompy, codaward, dteeffec, numseq, syncond, statement,codcreate, coduser)
          values (p_codcompy, p_codaward, p_dteeffec, v_numseq, v_syncond, v_statement,global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tcontaw3
             set syncond  = v_syncond,
                 statement  = v_statement,
                 coduser    = global_v_coduser,
                 codcreate  = global_v_coduser
           where codcompy = p_codcompy
             and codaward = p_codaward
             and dteeffec = p_dteeffec
             and numseq   = v_numseq;
        end;
--        end if;
        json_param_obj2       := hcm_util.get_json_t(json_row,'children');
        for i in 0..json_param_obj2 .get_size-1 loop
          json_row2           := hcm_util.get_json_t(json_param_obj2,to_char(i));
          v_qtyawOld          := to_number(hcm_util.get_string_t(json_row2, 'qtyawOld'));
          v_qtyaw             := to_number(hcm_util.get_string_t(json_row2, 'qtyaw'));
          obj_formula         := hcm_util.get_json_t(json_row2,'formula');
          v_formula           := hcm_util.get_string_t(obj_formula, 'code');
          v_flagd             := hcm_util.get_string_t(json_row2, 'flg');
          v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

          if v_flagd = 'delete' then
            delete from tcontaw4
                 where codcompy = p_codcompy
                   and codaward = p_codaward
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseq
                   and qtyaw    = nvl(v_qtyawOld, v_qtyaw);
          elsif v_flagd = 'add' then
            begin
              insert into tcontaw4
                     (codcompy, codaward, dteeffec, numseq, qtyaw, formula, codcreate)
              values (p_codcompy, p_codaward, p_dteeffec, v_numseq, v_qtyaw, v_formula, global_v_coduser);
            exception when dup_val_on_index then
              param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontaw4');
              return;
            end;
          else
            begin
              select qtyaw
                into v_qtyaw
                from tcontaw4
               where codcompy = p_codcompy
                 and codaward = p_codaward
                 and dteeffec = p_dteeffec
                 and numseq   = v_numseq
                 and qtyaw    = v_qtyaw
                 and rowId <> v_rowId;

              param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontaw4');
              return;
            exception when no_data_found then
              if v_rowId is null then
                insert into tcontaw4
                       (codcompy, codaward, dteeffec, numseq, qtyaw, formula, codcreate, coduser)
                values (p_codcompy, p_codaward, p_dteeffec, v_numseq, v_qtyaw, v_formula, global_v_coduser, global_v_coduser);
              else
                update tcontaw4
                   set qtyaw    = v_qtyaw,
                       formula  = v_formula,
                       coduser  = global_v_coduser,
                       codcreate  = global_v_coduser
                 where codcompy = p_codcompy
                   and codaward = p_codaward
                   and dteeffec = p_dteeffec
                   and numseq   = v_numseq
                   and qtyaw    = v_qtyawOld;
              end if;
            end;
          end if;
        end loop;
      end if;
    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function checkTcodec (codcodec in varchar2, codcodec_val in varchar2) return varchar2 as
    v_descod      varchar2(1000 char);
    v_typleave    tleavecd.typleave%type;
    v_chk         varchar2(1);
  begin
    if codcodec = 'tcodtime' then
      begin
        select codcodec
          into v_descod
          from tcodtime
         where codcodec = codcodec_val;
        return null;
      exception when no_data_found then
        return get_error_msg_php('HR2010', global_v_lang, 'tcodtime');
      end;
    elsif codcodec = 'tcodawrd' then
      begin
        select codcodec
          into v_descod
          from tcodawrd
         where codcodec = codcodec_val;
        return null;
      exception when no_data_found then
        return get_error_msg_php('HR2010', global_v_lang, 'tcodawrd');
      end;
    elsif codcodec = 'tinexinf' then
      begin
        select codpay
          into v_descod
          from tinexinf
         where codpay = codcodec_val;
        return null;
      exception when no_data_found then
        return get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
      end;
    elsif codcodec = 'tleavecd' then
      begin
        select typleave
          into v_typleave
          from tleavecd
         where codleave = codcodec_val;
      exception when no_data_found then
        return get_error_msg_php('HR2010', global_v_lang, 'tleavecd');
      end;

      begin
        select 'Y'
          into v_chk
          from tleavcom
         where codcompy   = p_codcompy
           and typleave   = v_typleave;
      exception when no_data_found then
        return get_error_msg_php('AL0060', global_v_lang);
      end;
      return null;
    else
      return null;
    end if;
  end;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_codcompy          := upper(hcm_util.get_string_t(json_obj, 'p_codcompy'));
    p_codaward          := upper(hcm_util.get_string_t(json_obj, 'p_codaward'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'), 'dd/mm/yyyy');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    v_codapp          varchar2(10 char);
  begin
    initial_report(json_str_input);
    gen_flg_status;
    isInsertReport := true;
    v_codapp       := p_codapp;
    if param_msg_error is null then
      clear_ttemprpt;
      p_codapp       := v_codapp;
      gen_tab1_detail(json_output);
      p_codapp       := v_codapp || '1';
      gen_tab1_table1(json_output);
      p_codapp       := v_codapp || '2';
      gen_tab1_table2(json_output);
      p_codapp       := v_codapp || '3';
      gen_tab1_table3(json_output);
      p_codapp       := v_codapp || '4';
      gen_tab2(json_output);
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
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_item1             ttemprpt.item1%type;
    v_item2             ttemprpt.item2%type;
    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;
    v_item5             ttemprpt.item5%type;
    v_item6             ttemprpt.item6%type;
    v_item7             ttemprpt.item7%type;
    v_item8             ttemprpt.item8%type;
    v_item9             ttemprpt.item9%type;
    v_item10            ttemprpt.item10%type;
    v_item11            ttemprpt.item11%type;

    v_year              number := 0;
    v_dteeffec          varchar2(100 char) := '';

  begin
    v_year      := hcm_appsettings.get_additional_year;
    v_dteeffec  := to_char(p_dteeffec, 'DD/MM/') || (to_number(to_char(p_dteeffec, 'YYYY')) + v_year);

    v_item1 := p_codcompy;
    v_item2 := p_codaward;
    v_item3 := v_dteeffec; --to_char(p_dteeffec, 'dd/mm/yyyy');
    if p_codapp = 'HRAL94E' then
      v_item4 := get_tcompny_name(p_codcompy, global_v_lang);
      v_item5 := get_tcodec_name('TCODAWRD', p_codaward, global_v_lang);
      v_item6 := hcm_util.get_string_t(obj_data, 'desc_syncond');
      v_item7 := hcm_util.get_string_t(obj_data, 'codpay');
      v_item7 := v_item7 || ' - ' || get_tinexinf_name(v_item7, global_v_lang);
      v_item8 := hcm_util.get_string_t(obj_data, 'codrtawrd');
      v_item8 := v_item8 || ' - ' || get_tinexinf_name(v_item8, global_v_lang);
      v_item9 := hcm_util.get_string_t(obj_data, 'qtyretpriod');
      v_item10 := hcm_util.get_string_t(obj_data, 'numprdclr');
      if v_item9 is null then
        v_item9 := ' ';
      end if;
      if v_item10 is null then
        v_item10 := ' ';
      end if;
      v_item11 := get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_data, 'dtemthclr'),global_v_lang);
      if v_item11 is null then
        v_item11 := ' ';
      end if;
    elsif p_codapp = 'HRAL94E1' then
      v_item4 := hcm_util.get_string_t(obj_data, 'label');
      v_item5 := hcm_util.get_string_t(obj_data, 'qty');
      v_item6 := hcm_util.get_string_t(obj_data, 'time');
    elsif p_codapp = 'HRAL94E2' then
      v_item4 := hcm_util.get_string_t(obj_data, 'rcnt');
      v_item5 := hcm_util.get_string_t(obj_data, 'desc_codchng');
    elsif p_codapp = 'HRAL94E3' then
      v_item4 := hcm_util.get_string_t(obj_data, 'rcnt');
      v_item5 := hcm_util.get_string_t(obj_data, 'desc_codleave');
      v_item6 := hcm_util.get_string_t(obj_data, 'timleave');
      v_item7 := hcm_util.get_string_t(obj_data, 'qtyminlv');
    elsif p_codapp = 'HRAL94E4' then
      v_item4 := hcm_util.get_string_t(obj_data, 'rcnt');
      v_item5 := hcm_util.get_string_t(obj_data, 'desc_syncond');
      v_item6 := hcm_util.get_string_t(obj_data, 'qtyaw');
      v_item7 := hcm_util.get_string_t(obj_data, 'desc_formula');
    end if;

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9,
             item10,item11
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_item1, v_item2, v_item3, v_item4, v_item5,
             v_item6, v_item7, v_item8, v_item9,
             v_item10,v_item11
           );
    exception when others then
      null;
    end;
  end insert_ttemprpt;
end HRAL94E;

/
