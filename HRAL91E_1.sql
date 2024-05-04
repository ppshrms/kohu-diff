--------------------------------------------------------
--  DDL for Package Body HRAL91E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL91E" is
-- last update: 04/01/2018 12:23
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
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_codcompyQuery     := upper(hcm_util.get_string_t(json_obj,'p_codcompyQuery'));
    p_dteeffecQuery     := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecQuery'),'dd/mm/yyyy');
    p_dteeffecOld       := p_dteeffec;
    p_typabs            := hcm_util.get_string_t(json_obj,'p_typabs');

    forceAdd            := hcm_util.get_string_t(json_obj,'forceAdd');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_qtyavgwk          varchar2(4000 char);
    v_flgrdabs          varchar2(4000 char);
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
      obj_data.put('isCopy', nvl(forceAdd, 'N'));
      obj_data.put('codcompy', p_codcompy);
      if isAdd or isEdit then
        obj_data.put('dteeffec', to_char(p_dteeffecOld, 'DD/MM/YYYY'));
      else
        obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));
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
  begin
    if forceAdd = 'Y' then
      isEdit := false;
      isAdd  := true;
    else
      begin
        select dteeffec
          into v_dteeffec
          from tcontral
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec;
        if p_dteeffec >= trunc(sysdate) then
            isEdit              := true;
            v_msqerror          := '';
            v_detailDisabled    := false;
        else
            v_msqerror          := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400','');
            v_detailDisabled    := true; 
        end if;
      exception when no_data_found then
        if p_dteeffec < trunc(sysdate) then
          isEdit := false;
        else
          isAdd := true;
        end if;
        begin
          select max(dteeffec)
            into v_dteeffec
            from tcontral
           where codcompy = p_codcompy
             and dteeffec <= p_dteeffec;
        end;
        if v_dteeffec is null then
            begin
              select min(dteeffec)
                into v_dteeffec
                from tcontral
               where codcompy = p_codcompy
                 and dteeffec > p_dteeffec;
            end;      

            if v_dteeffec is null then
              isAdd := true;
              v_msqerror          := '';
              v_detailDisabled    := false;            
            else
              isAdd := false;
              v_msqerror          := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400','');
              v_detailDisabled    := true;   
              p_dteeffec    := v_dteeffec;
            end if;
        else
          if trunc(p_dteeffec) < trunc(sysdate) then
            v_msqerror          := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400','');
            v_detailDisabled    := true; 
          else
            v_msqerror          := '';
            v_detailDisabled    := false;
          end if;
          p_dteeffec    := v_dteeffec;
        end if;
      end;
    end if;
  end;

  procedure get_tab1_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1_detail (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1_detail;

  procedure gen_tab1_detail (json_str_output out clob) is
    obj_data            json_object_t;
    v_qtyavgwk          number           := 0;
    v_flgrdabs          varchar2(1 char) := 'F';
    v_coduser           tcontral.coduser%type;
    v_dteupd            tcontral.dteupd%type;
  begin
    obj_data            := json_object_t();
    begin
      select qtyavgwk, flgrdabs, coduser, dteupd
        into v_qtyavgwk, v_flgrdabs, v_coduser, v_dteupd
        from tcontral
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec);
    exception when no_data_found then
      null;
    end;

    -- Detail --
    obj_data.put('coderror', '200');
    obj_data.put('qtyavgwk', hcm_util.convert_minute_to_hour(to_char(v_qtyavgwk)));
    obj_data.put('flgrdabs', v_flgrdabs);
--    obj_data.put('codimage', p_dteeffec);
    obj_data.put('codimage', get_codempid(v_coduser));
    obj_data.put('desc_coduser', v_coduser || ' - ' || get_temploy_name(get_codempid(v_coduser), global_v_lang));
    obj_data.put('dteupd', to_char(v_dteupd,'dd/mm/yyyy'));
    obj_data.put('msqerror', v_msqerror);  
    obj_data.put('detailDisabled', v_detailDisabled);  

    if isInsertReport then
      insert_ttemprpt(obj_data);
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1_detail;

  procedure get_tab1_table1 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1_table1 (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1_table1;

  procedure gen_tab1_table1 (json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    v_dteeffec        date;
    -- Table 1 --
    cursor c_tcontal5 is
    select rowId, codchng
      from tcontal5
     where codcompy = nvl(p_codcompyQuery, p_codcompy)
       and dteeffec = nvl(p_dteeffecQuery, p_dteeffec);
  begin
    -- Table 1 --
    obj_row := json_object_t();
    v_rcnt  := 0;
    for i in c_tcontal5 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');

      obj_data.put('rowId', i.rowId);
      obj_data.put('flgAdd', isAdd);
      obj_data.put('codchng', i.codchng);
      obj_data.put('desc_codchng', get_tcodec_name('tcodtime', i.codchng, global_v_lang));
      obj_data.put('numseq', v_rcnt);

      if isInsertReport then
        insert_ttemprpt(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tab1_table1;

  procedure get_tab1_table2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1_table2 (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1_table2;

  procedure gen_tab1_table2 (json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;
    v_rcnt            number := 0;
    v_rcnt2           number := 0;
    v_typabs          varchar2(100 char);
    -- Table 2 --
    cursor c_tcontal3 is
      select typabs
        from tcontal3
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
    group by typabs
    order by typabs;
    cursor c_tcontal3_child is
      select rowId, typabs, qtyminst, qtyminen, qtymin
        from tcontal3
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
         and typabs = v_typabs
    order by qtyminst;
  begin
    -- Table 2 --
    obj_row := json_object_t();
    v_rcnt  := 0;
    for c1 in c_tcontal3 loop
      v_rcnt              := v_rcnt+1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('flgAdd', isAdd);
      obj_data.put('typabs', c1.typabs);
      obj_data.put('numseq', v_rcnt);
      v_typabs            := c1.typabs;
      v_rcnt2             := 0;
      obj_row_child       := json_object_t();
      for c2 in c_tcontal3_child loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');
        obj_data_child.put('flgAdd', isAdd);
        obj_data_child.put('qtyminst', hcm_util.convert_minute_to_hour(c2.qtyminst));
        obj_data_child.put('qtyminen', hcm_util.convert_minute_to_hour(c2.qtyminen));
        obj_data_child.put('qtymin', hcm_util.convert_minute_to_hour(c2.qtymin));
        obj_data_child.put('rowId', c2.rowId);
        obj_row_child.put(to_char(v_rcnt2-1), obj_data_child);
      end loop;
      obj_data.put('children', obj_row_child);

      if isInsertReport then
        insert_ttemprpt_tab1_table2(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tab1_table2;

  procedure get_data_tcontal4 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_data_tcontal4 (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_data_tcontal4;

  procedure gen_data_tcontal4 (json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;
    v_rcnt            number := 0;
    v_rcnt2           number := 0;
    v_typabs          varchar2(100 char);
    -- Table 3 --
    cursor c_tcontal4 is
      select typabs
        from tcontal4
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
    group by typabs
    order by typabs;
    cursor c_tcontal4_child is
      select rowId, typecal, qtyminst, qtyminen, qtymin
        from tcontal4
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
         and typabs = v_typabs;
  begin
    -- Table 3 --
    obj_row             := json_object_t();
    v_rcnt              := 0;
    for c1 in c_tcontal4 loop
      v_rcnt              := v_rcnt+1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('flgAdd', isAdd);
      obj_data.put('typabs', c1.typabs);
      obj_data.put('numseq', v_rcnt);
      v_typabs            := c1.typabs;
      v_rcnt2             := 0;
      obj_row_child       := json_object_t();
      for c2 in c_tcontal4_child loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');
        obj_data_child.put('flgAdd', isAdd);
        obj_data_child.put('rowId', c2.rowId);
        obj_data_child.put('typecal', c2.typecal);
        obj_data_child.put('qtyminst', hcm_util.convert_minute_to_hour(c2.qtyminst));
        obj_data_child.put('qtyminen', hcm_util.convert_minute_to_hour(c2.qtyminen));
        obj_data_child.put('qtymin', hcm_util.convert_minute_to_hour(c2.qtymin));
        obj_row_child.put(to_char(v_rcnt2-1),obj_data_child);
      end loop;
      obj_data.put('children', obj_row_child);

      if isInsertReport then
        insert_ttemprpt_tab1_table3(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_data_tcontal4;

  procedure get_tab2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab2 (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab2;

  procedure gen_tab2 (json_str_output out clob) is
    obj_result          json_object_t;
    obj_data            json_object_t;
    obj_data2           json_object_t;
    obj_row             json_object_t;
    obj_row2            json_object_t;
    v_rcnt              number := 0;
    v_rcnt2             number := 0;
    v_typabs            varchar2(1 char);
    v_numseq            number := 0;

    cursor c_tabsdedh is
      select typabs, numseq, syncond, statement
        from tabsdedh
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
         and typabs = nvl(p_typabs, typabs)
    order by typabs, numseq;
    cursor c_tabsdedd is
      select rowId, numseq, qtyabsst, qtyabsen, qtyded, typecal
        from tabsdedd
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec)
         and typabs   = v_typabs
         and numseq   = v_numseq
    order by numseq, qtyabsst;
  begin
    obj_row         := json_object_t();
    for i in c_tabsdedh loop
      v_rcnt       := v_rcnt+1;
      v_rcnt2      := 0;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');

      obj_data.put('flgAdd', isAdd);
      obj_data.put('typabs', i.typabs);
      obj_data.put('numseq', i.numseq);
      obj_data.put('syncond', i.syncond);
      obj_data.put('desc_syncond', get_logical_desc(i.statement));
      obj_data.put('statement', i.statement);

      v_typabs      := i.typabs;
      v_numseq      := i.numseq;

      obj_row2      := json_object_t();
      for j in c_tabsdedd loop
        v_rcnt2      := v_rcnt2+1;
        obj_data2    := json_object_t();
        obj_data2.put('coderror', '200');
        obj_data2.put('flgAdd', isAdd);
        obj_data2.put('rowId', j.rowId);
        obj_data2.put('typecal', j.typecal);
        obj_data2.put('qtyabsst', hcm_util.convert_minute_to_hour(j.qtyabsst));
        obj_data2.put('qtyabsen', hcm_util.convert_minute_to_hour(j.qtyabsen));
        obj_data2.put('qtyded', hcm_util.convert_minute_to_hour(j.qtyded));
        obj_row2.put(to_char(v_rcnt2-1),obj_data2);
      end loop;
      obj_data.put('children', obj_row2);

      if isInsertReport then
        insert_ttemprpt_tab2(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab2;

  procedure get_tab3 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab3 (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab3;

  procedure gen_tab3 (json_str_output out clob) is
    obj_data            json_object_t;

    cursor c_tcontal2 is
      select codlev, codrtlev, codlate, codrtlate,
             codear, codrtear, codabs, codrtabs,
             codadjlate, codadjear, codadjabs,
             codvacat, codlevm, codrtlevm, codretro
        from tcontal2
       where codcompy = nvl(p_codcompyQuery, p_codcompy)
         and dteeffec = nvl(p_dteeffecQuery, p_dteeffec);
  begin
    obj_data        := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codlate', ' ');
    obj_data.put('codrtlate', ' ');
    obj_data.put('codear', ' ');
    obj_data.put('codrtear', ' ');
    obj_data.put('codabs', ' ');
    obj_data.put('codrtabs', ' ');
    obj_data.put('codadjlate', ' ');
    obj_data.put('codadjear', ' ');
    obj_data.put('codadjabs', ' ');
    obj_data.put('codlevm', ' ');
    obj_data.put('codrtlevm', ' ');
    obj_data.put('codlev', ' ');
    obj_data.put('codrtlev', ' ');
    obj_data.put('codvacat', ' ');
    obj_data.put('codretro', '');
    for i in c_tcontal2 loop
      obj_data.put('codlate', i.codlate);
      obj_data.put('codrtlate', i.codrtlate);
      obj_data.put('codear', i.codear);
      obj_data.put('codrtear', i.codrtear);
      obj_data.put('codabs', i.codabs);
      obj_data.put('codrtabs', i.codrtabs);
      obj_data.put('codadjlate', i.codadjlate);
      obj_data.put('codadjear', i.codadjear);
      obj_data.put('codadjabs', i.codadjabs);
      obj_data.put('codlevm', i.codlevm);
      obj_data.put('codrtlevm', i.codrtlevm);
      obj_data.put('codlev', i.codlev);
      obj_data.put('codrtlev', i.codrtlev);
      obj_data.put('codvacat', i.codvacat);
      obj_data.put('codretro', i.codretro);

      if isInsertReport then
        insert_ttemprpt_tab3(obj_data);
      end if;

    end loop;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab3;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'),'DD/MM/YYYY');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_report(json_str_input);

    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      gen_flg_status;
      p_codapp := 'HRAL91E';
      gen_tab1_detail(json_output);
      p_codapp := 'HRAL91E1';
      gen_tab1_table1(json_output);
      p_codapp := 'HRAL91E2';
      gen_tab1_table2(json_output);
      p_codapp := 'HRAL91E3';
      gen_data_tcontal4(json_output);
      p_codapp := 'HRAL91E4';
      p_typabs := '1';
      gen_tab2(json_output);
      p_typabs := '2';
      gen_tab2(json_output);
      p_typabs := '3';
      gen_tab2(json_output);
      p_codapp := 'HRAL91E5';
      gen_tab3(json_output);
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

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_flgrdabs          varchar2(100 char);
    v_qtyavgwk      		varchar2(1000 char) := '';
    v_numseq_  					varchar2(1000 char) := '';
    v_codchng       		varchar2(1000 char) := '';
    v_desc_codchng      varchar2(1000 char) := '';
  begin
    v_qtyavgwk       			:= nvl(hcm_util.get_string_t(obj_data, 'qtyavgwk'), '');
    v_numseq_   					:= nvl(hcm_util.get_string_t(obj_data, 'numseq'), ' ');
    v_codchng       			:= nvl(hcm_util.get_string_t(obj_data, 'codchng'), '');
    v_desc_codchng      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_codchng'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = p_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq      := v_numseq + 1;
    v_flgrdabs    :=  nvl(hcm_util.get_string_t(obj_data, 'flgrdabs'), '');
    if v_flgrdabs = 'H' then
      v_flgrdabs := get_label_name('HRAL91EP1', global_v_lang, '51');
    elsif v_flgrdabs = 'F' then
      v_flgrdabs := get_label_name('HRAL91EP1', global_v_lang, '52');
    end if;
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4, item5 )
      values
           (
             p_codempid, p_codapp, v_numseq,
             v_qtyavgwk,
             v_flgrdabs,
             v_numseq_,
             v_codchng,
             v_desc_codchng
           );

    exception when others then
      null;
    end;
  end insert_ttemprpt;

  procedure insert_ttemprpt_tab1_table2(obj_data in json_object_t) is
    v_numseq            number := 0;
    json_row            json_object_t;
    json_row_child      json_object_t;
    v_typabs            tcontal3.typabs%type;
    v_desc_typabs       varchar2(100 char);
    v_qtyminst          varchar2(1000 char);
    v_qtyminen          varchar2(1000 char);
    v_qtymin            varchar2(1000 char);
  begin
    v_typabs            := hcm_util.get_string_t(obj_data, 'typabs');
    v_desc_typabs       := get_tlistval_name('TYPABS', v_typabs, global_v_lang);
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
        v_qtyminst := nvl(hcm_util.get_string_t(json_row_child, 'qtyminst'), ' ');
        v_qtyminen := nvl(hcm_util.get_string_t(json_row_child, 'qtyminen'), ' ');
        v_qtymin := nvl(hcm_util.get_string_t(json_row_child, 'qtymin'), ' ');
        begin
          insert
           into ttemprpt
               ( codempid, codapp, numseq, item1, item2, item3, item4, item5 )
          values
               (
                 p_codempid, p_codapp, v_numseq,
                 v_typabs,
                 v_desc_typabs,
                 v_qtyminst,
                 v_qtyminen,
                 v_qtymin
               );
        end;
      end loop;
    end if;
  end insert_ttemprpt_tab1_table2;

  procedure insert_ttemprpt_tab1_table3(obj_data in json_object_t) is
    v_numseq            number := 0;
    json_row            json_object_t;
    json_row_child      json_object_t;
    v_typabs            tcontal3.typabs%type;
    v_desc_typabs       varchar2(100 char);
    v_desc_typecal      varchar2(1000 char);
    v_qtyminst          varchar2(1000 char);
    v_qtyminen          varchar2(1000 char);
    v_qtymin            varchar2(1000 char);
  begin
    v_typabs            := hcm_util.get_string_t(obj_data, 'typabs');
    v_desc_typabs       := get_tlistval_name('TYPABS', v_typabs, global_v_lang);
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
        v_desc_typecal := nvl(get_tlistval_name('TYPECAL',hcm_util.get_string_t(json_row_child, 'typecal'),global_v_lang), ' ');
        v_qtyminst  := nvl(hcm_util.get_string_t(json_row_child, 'qtyminst'), ' ');
        v_qtyminen  := nvl(hcm_util.get_string_t(json_row_child, 'qtyminen'), ' '); 
        v_qtymin    := nvl(hcm_util.get_string_t(json_row_child, 'qtymin'), ' ');
        begin
          insert
           into ttemprpt
               ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6 )
          values
               (
                 p_codempid, p_codapp, v_numseq,
                 v_typabs,
                 v_desc_typabs,
                 v_desc_typecal,
                 v_qtyminst,
                 v_qtyminen,
                 v_qtymin
               );
        end;
      end loop;
    end if;
  end insert_ttemprpt_tab1_table3;

  procedure insert_ttemprpt_tab2(obj_data in json_object_t) is
    v_numseq            number := 0;
    json_row            json_object_t;
    json_row_child      json_object_t;
    v_syncond           varchar2(1000 char);
    v_desc_syncond      varchar2(1000 char);
    v_item1	            varchar2(1000 char);
    v_item2	            varchar2(1000 char);
    v_item4	            varchar2(1000 char);
    v_item5	            varchar2(1000 char);
    v_item6	            varchar2(1000 char);
  begin
    v_syncond           := hcm_util.get_string_t(obj_data, 'syncond');
    v_desc_syncond      := hcm_util.get_string_t(obj_data, 'desc_syncond');
    json_row            := hcm_util.get_json_t(obj_data, 'children');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = p_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    if json_row.get_size > 0 then
      for j in 0..json_row.get_size -1 loop

        v_numseq := v_numseq + 1;
        json_row_child := hcm_util.get_json_t(json_row, to_char(j));
        v_item1	  := nvl(hcm_util.get_string_t(obj_data, 'typabs'), '');
        v_item2	  := nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
        v_item4 	:= nvl(hcm_util.get_string_t(json_row_child, 'qtyabsst'), ' ');
        v_item5	  := nvl(hcm_util.get_string_t(json_row_child, 'qtyabsen'), ' ');
        v_item6	  := nvl(hcm_util.get_string_t(json_row_child, 'qtyded'), ' ');
        begin
          insert
           into ttemprpt
               ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6 )
          values
               (
                 p_codempid, p_codapp, v_numseq,
                 v_item1,
                 v_item2,
                 v_desc_syncond,
                 v_item4,
                 v_item5,
                 v_item6
               );
        end;
      end loop;
    end if;
  end insert_ttemprpt_tab2;

  procedure insert_ttemprpt_tab3(obj_data in json_object_t) is
    v_numseq        number := 0;
    v_item2		      varchar2(1000 char);
    v_item3		      varchar2(1000 char);
    v_item4	        varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = p_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    -- a??a??a??
    v_numseq := v_numseq + 1;
    v_item2    := nvl(hcm_util.get_string_t(obj_data, 'codlate'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codlate'), global_v_lang);
    v_item3  := nvl(hcm_util.get_string_t(obj_data, 'codrtlate'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codrtlate'), global_v_lang);
    v_item4 := nvl(hcm_util.get_string_t(obj_data, 'codadjlate'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codadjlate'), global_v_lang);
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4 )
      values
           (
             p_codempid, p_codapp, v_numseq,
             get_label_name('HRAL91EP3', global_v_lang, '70'),
             v_item2,
             v_item3,
             v_item4
           );
    exception when dup_val_on_index then
      null;
    end;
    -- a??a?Ya??a?sa??a??a?-a??
    v_numseq := v_numseq + 1;
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'codear'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codear'), global_v_lang);
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'codrtear'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codrtear'), global_v_lang);
    v_item4 := nvl(hcm_util.get_string_t(obj_data, 'codadjear'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codadjear'), global_v_lang);
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4 )
      values
           (
             p_codempid, p_codapp, v_numseq,
             get_label_name('HRAL91EP3', global_v_lang, '80'),
             v_item2,
             v_item3,
             v_item4
           );
    exception when dup_val_on_index then
      null;
    end;
    -- a??a??a??a??a??a??
    v_numseq := v_numseq + 1;
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'codabs'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codabs'), global_v_lang);
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'codrtabs'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codrtabs'), global_v_lang);
    v_item4 := nvl(hcm_util.get_string_t(obj_data, 'codadjabs'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codadjabs'), global_v_lang);
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4 )
      values
           (
             p_codempid, p_codapp, v_numseq,
             get_label_name('HRAL91EP3', global_v_lang, '90'),
             v_item2,
             v_item3,
             v_item4
           );
    exception when dup_val_on_index then
      null;
    end;
    -- a?Ya??a??a??a?'a??a??a??a?<a??a??
    v_numseq := v_numseq + 1;
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'codlev'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codlev'), global_v_lang);
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'codrtlev'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codrtlev'), global_v_lang);
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4 )
      values
           (
             p_codempid, p_codapp, v_numseq,
             get_label_name('HRAL91EP3', global_v_lang, '160'),
             v_item2,
             v_item3,
             ' '
           );
    exception when dup_val_on_index then
      null;
    end;
    -- a?Ya??a?za??a??a?#a??a?-a??
    v_numseq := v_numseq + 1;
    v_item4 := nvl(hcm_util.get_string_t(obj_data, 'codvacat'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codvacat'), global_v_lang);
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4 )
      values
           (
             p_codempid, p_codapp, v_numseq,
             get_label_name('HRAL91EP3', global_v_lang, '170'),
             ' ',
             ' ',
             v_item4
           );
    exception when dup_val_on_index then
      null;
    end;
    -- a?Ya??a??a?Ya?-a??a??a??a?'a??a??a??a?<a??a??
    v_numseq := v_numseq + 1;
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'codlevm'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codlevm'), global_v_lang);
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'codrtlevm'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codrtlevm'), global_v_lang);
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4)
      values
           (
             p_codempid, p_codapp, v_numseq,
             get_label_name('HRAL91EP3', global_v_lang, '100'),
             v_item2,
             v_item3,
             ' '
           );
    exception when dup_val_on_index then
      null;
    end;
    -- 
    v_numseq := v_numseq + 1;
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'codretro'), '') || ' - ' || get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codretro'), global_v_lang);
    begin
      insert
       into ttemprpt
           ( codempid, codapp, numseq, item1, item2, item3, item4)
      values
           (
             p_codempid, p_codapp, v_numseq,
             get_label_name('HRAL91EP3', global_v_lang, '180'),
             '',
             v_item3,
             ''
           );
    exception when dup_val_on_index then
      null;
    end;
  end insert_ttemprpt_tab3;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    json_input_obj      := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    isCopy              := hcm_util.get_string_t(json_input_obj, 'isCopy');
    if isCopy = 'Y' then
      begin
        delete from tcontral where codcompy = p_codcompy and dteeffec = p_dteeffec;
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
      save_data_tcontal4 (json_str_output);
    end if;

    if param_msg_error is null then
      save_tab2 (json_str_output);
    end if;

    if param_msg_error is null then
      save_tab3 (json_str_output);
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
    obj_tab1          json_object_t;
    obj_detail        json_object_t;
    v_qtyavgwk        number           := 0;
    v_flgrdabs        varchar2(1 char) := 'F';
    v_rowId           varchar2(1000 char);
  begin
    obj_tab1          := hcm_util.get_json_t(json_input_obj, 'tab1');
    obj_detail        := hcm_util.get_json_t(obj_tab1, 'detail');
    v_qtyavgwk        := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_detail,'qtyavgwk'));
    v_rowId           := hcm_util.get_string_t(obj_detail,'rowId');
    v_flgrdabs        := hcm_util.get_string_t(obj_detail,'flgrdabs');
    begin
      insert into tcontral
             (codcompy, dteeffec, qtyavgwk, flgrdabs, codcreate, coduser)
      values (p_codcompy, p_dteeffec, v_qtyavgwk, v_flgrdabs, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update tcontral
         set qtyavgwk = v_qtyavgwk,
             flgrdabs = v_flgrdabs,
             coduser  = global_v_coduser
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec;
    end;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab1_table1 (json_str_output out clob) is
    obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_codchng             varchar2(4 char);
    v_codchngOld          varchar2(4 char);
    v_flag                varchar2(100 char);
    v_rowId               varchar2(1000 char);
  begin
    obj_tab1              := hcm_util.get_json_t(json_input_obj, 'tab1');
    json_param_obj        := hcm_util.get_json_t(obj_tab1, 'table1');

    for i in 0..json_param_obj.get_size-1 loop
      json_row     := hcm_util.get_json_t(json_param_obj, to_char(i));
      v_codchng    := hcm_util.get_string_t(json_row, 'codchng');
      v_codchngOld := hcm_util.get_string_t(json_row, 'codchngOld');
      v_flag       := hcm_util.get_string_t(json_row, 'flg');
      v_rowId      := hcm_util.get_string_t(json_row, 'rowId');

      if v_flag = 'delete' then
        delete from tcontal5
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and codchng  = nvl(v_codchngOld, v_codchng);
      elsif v_flag = 'add' then
        param_msg_error := checkTcodec('tcodtime', v_codchng);
        if param_msg_error is not null then
          return;
        end if;
        begin
          insert into tcontal5
                 (codcompy, dteeffec, codchng, codcreate, coduser)
          values (p_codcompy, p_dteeffec, v_codchng, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal5');
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
            from tcontal5
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec
             and codchng = v_codchng
             and rowId <> v_rowId;

          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal5');
          return;
        exception when no_data_found then
          if v_rowId is null then
            insert into tcontal5
                   (codcompy, dteeffec, codchng, codcreate, coduser)
            values (p_codcompy, p_dteeffec, v_codchng, global_v_coduser, global_v_coduser);
          else
            update tcontal5
               set codchng  = v_codchng,
                   coduser  = global_v_coduser
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and codchng  = v_codchngOld;
          end if;
        end;
      end if;
    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab1_table2 (json_str_output out clob) is
    obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_param_obj2       json_object_t;
    json_row              json_object_t;
    json_row2             json_object_t;
    v_typabs              varchar2(1 char);
    v_qtyminst            number;
    v_qtyminstOld         number;
    v_qtyminen            number;
    v_qtymin              number;
    v_qtyminst_check      number := 0;
    v_qtyminen_check      number := 0;
    v_flag                varchar2(100 char);
    v_flag_child          varchar2(100 char);
    v_rowId               varchar2(1000 char);

    v_tmp_rownum          number;
    v_tmp_codcompy        tabsdedd.codcompy%type;
    v_tmp_dteeffec        tabsdedd.dteeffec%type;
    v_tmp_typabs          tabsdedd.typabs%type;
    v_tmp_numseq          tabsdedd.numseq%type;

    json_item_insert      json_object_t;
    v_rcnt_insert         number;
    json_item_update      json_object_t;
    v_rcnt_update         number;
    v_max_num_loop        number := 20;
    v_total_loop          number := 0;
    v_current_loop        number := 0;

    cursor c1 is
      select a.*, a.rowId
        from tcontal3 a
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec
         and typabs = v_typabs
    order by qtyminst;

  begin
    obj_tab1              := hcm_util.get_json_t(json_input_obj, 'tab1');
    json_param_obj        := hcm_util.get_json_t(obj_tab1, 'table2');
    for i in 0..json_param_obj.get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_typabs            := hcm_util.get_string_t(json_row, 'typabs');
      v_flag              := hcm_util.get_string_t(json_row, 'flg');

      json_item_insert      := json_object_t();
      v_rcnt_insert         := 0;
      json_item_update      := json_object_t();
      v_rcnt_update         := 0;
      json_param_obj2       := hcm_util.get_json_t(json_row,'children');
      for i in 0..json_param_obj2.get_size-1 loop
        json_row2           := hcm_util.get_json_t(json_param_obj2, to_char(i));
        v_qtyminst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminst'));
        v_qtyminstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminstOld'));
        v_qtyminen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminen'));
        v_qtymin            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtymin'));
        v_flag_child        := hcm_util.get_string_t(json_row2, 'flg');
        v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');
--        if v_qtyminst is null and v_flag_child <> 'delete' then
--          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtyminst');
--        end if;
--        if v_qtyminen is null and v_flag_child <> 'delete' then
--          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtyminen');
--        end if;
--        if v_qtymin is null and v_flag_child <> 'delete' then
--          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtymin');
--        end if;

        if v_flag_child = 'delete' or (v_qtyminst is null and v_qtyminen is null and v_qtymin is null) then
          if nvl(v_qtyminstOld, v_qtyminst) is not null then
            delete from tcontal3
            where codcompy = p_codcompy
              and dteeffec = p_dteeffec
              and typabs   = v_typabs
              and qtyminst = nvl(v_qtyminstOld, v_qtyminst);
          end if;
        elsif v_flag_child = 'add' then
          begin
            insert into tcontal3
                   (codcompy, dteeffec, typabs, qtyminst, qtyminen, qtymin, codcreate, coduser)
            values (p_codcompy, p_dteeffec, v_typabs, v_qtyminst, v_qtyminen, v_qtymin, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            json_item_insert.put(to_char(v_rcnt_insert), json_row2);
            v_rcnt_insert         := v_rcnt_insert + 1;
          end;
        else
          begin
            update tcontal3
               set qtyminst = v_qtyminst,
                   qtyminen = v_qtyminen,
                   qtymin   = v_qtymin,
                   coduser  = global_v_coduser
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and typabs   = v_typabs
               and qtyminst = v_qtyminstOld;
          exception when dup_val_on_index then
            json_item_update.put(to_char(v_rcnt_update), json_row2);
            v_rcnt_update         := v_rcnt_update + 1;
          end;
        end if;
      end loop;

      v_total_loop          := json_item_update.get_size + v_max_num_loop;
      if json_item_update.get_size > 0 then
        while (v_current_loop < v_total_loop)
        loop
          v_current_loop    := v_current_loop + 1;
          save_tab1_table2_update(json_item_update, v_typabs);
          if (json_item_update.get_size = 0) then
            exit;
          end if;
        end loop;
        if json_item_update.get_size > 0 then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal3');
          return;
        end if;
      end if;

      v_total_loop          := json_item_insert.get_size + v_max_num_loop;
      if json_item_insert.get_size > 0 then
        while (v_current_loop < v_total_loop)
        loop
          v_current_loop    := v_current_loop + 1;
          save_tab1_table2_insert(json_item_insert, v_typabs);
          if (json_item_insert.get_size = 0) then
            exit;
          end if;
        end loop;
        if json_item_insert.get_size > 0 then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal3');
          return;
        end if;
      end if;

      -- Check cross time
      for r1 in c1 loop
        v_tmp_codcompy    := r1.codcompy;
        v_tmp_dteeffec    := r1.dteeffec;
        v_tmp_typabs      := r1.typabs;
        v_rowId           := r1.rowId;
        v_qtyminst        := r1.qtyminst;
        v_qtyminen        := r1.qtyminen;

        begin
          select rownum
            into v_tmp_rownum
            from tcontal3
           where codcompy = v_tmp_codcompy
             and dteeffec = v_tmp_dteeffec
             and typabs = v_tmp_typabs
             and rowId <> v_rowId
             and (
               qtyminst between v_qtyminst and v_qtyminen
               or qtyminen between v_qtyminst and v_qtyminen
               or v_qtyminst between qtyminst and qtyminen
               or v_qtyminen between qtyminst and qtyminen
             )
             and rownum <= 1;

          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal3');
          return;
        exception when no_data_found then
          null;
        end;
      end loop;

    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_data_tcontal4 (json_str_output out clob) is
    obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_param_obj2       json_object_t;
    json_row              json_object_t;
    json_row2             json_object_t;
    v_typabs              varchar2(1 char);
    v_typecal             varchar2(1 char);
    v_qtyminst            number := 0;
    v_qtyminstOld         number := 0;
    v_qtyminen            number := 0;
    v_qtymin              number;
    v_qtyminst_check      number := 0;
    v_qtyminen_check      number := 0;
    v_flag                varchar2(100 char);
    v_flag_child          varchar2(100 char);
    v_rowId               varchar2(1000 char);

    v_tmp_rownum          number;
    v_tmp_codcompy        tabsdedd.codcompy%type;
    v_tmp_dteeffec        tabsdedd.dteeffec%type;
    v_tmp_typabs          tabsdedd.typabs%type;
    v_tmp_numseq          tabsdedd.numseq%type;

    json_item_insert      json_object_t;
    v_rcnt_insert         number;
    json_item_update      json_object_t;
    v_rcnt_update         number;
    v_max_num_loop        number := 20;
    v_total_loop          number := 0;
    v_current_loop        number := 0;

    cursor c1 is
      select a.*, a.rowId
        from tcontal4 a
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec
         and typabs = v_typabs
    order by qtyminst;

  begin
    obj_tab1              := hcm_util.get_json_t(json_input_obj, 'tab1');
    json_param_obj        := hcm_util.get_json_t(obj_tab1, 'table3');
    for i in 0..json_param_obj.get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj, to_char(i));
      v_typabs            := hcm_util.get_string_t(json_row, 'typabs');
      v_flag              := hcm_util.get_string_t(json_row, 'flg');
      v_qtyminst_check    := 0;
      v_qtyminen_check    := 0;

      json_item_insert      := json_object_t();
      v_rcnt_insert         := 0;
      json_item_update      := json_object_t();
      v_rcnt_update         := 0;
      json_param_obj2     := hcm_util.get_json_t(json_row, 'children');
      for i in 0..json_param_obj2.get_size-1 loop
        json_row2           := hcm_util.get_json_t(json_param_obj2, to_char(i));
        v_typecal           := hcm_util.get_string_t(json_row2, 'typecal');
        v_qtyminstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminstOld'));
        v_qtyminst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminst'));
        v_qtyminen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminen'));
        v_qtymin            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtymin'));
        v_flag_child        := hcm_util.get_string_t(json_row2, 'flg');

        v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');
        if v_typecal = 1 and v_qtymin is null and v_flag_child <> 'delete' then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtymin');
          return;
        end if;
        if v_qtyminst > v_qtyminen or (i > 0 and (v_qtyminst between v_qtyminst_check and v_qtyminen_check or v_qtyminst <= v_qtyminen_check)) then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal4');
          return;
        end if;

        if v_flag_child = 'delete' then
          if nvl(v_qtyminstOld, v_qtyminst) is not null then
            delete from tcontal4
            where codcompy = p_codcompy
              and dteeffec = p_dteeffec
              and typabs   = v_typabs
              and qtyminst = nvl(v_qtyminstOld, v_qtyminst);
          end if;
        elsif v_flag_child = 'add' then
          begin
            insert into tcontal4
                   (codcompy, dteeffec, typabs, typecal, qtyminst, qtyminen, qtymin, codcreate, coduser)
            values (p_codcompy, p_dteeffec, v_typabs, v_typecal, v_qtyminst, v_qtyminen, v_qtymin, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            json_item_insert.put(to_char(v_rcnt_insert), json_row2);
            v_rcnt_insert         := v_rcnt_insert + 1;
          end;
        else
          begin
            update tcontal4
               set qtyminst = v_qtyminst,
                   qtyminen = v_qtyminen,
                   typecal  = v_typecal,
                   qtymin   = v_qtymin,
                   coduser  = global_v_coduser
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and typabs   = v_typabs
               and qtyminst = v_qtyminstOld;
          exception when dup_val_on_index then
            json_item_update.put(to_char(v_rcnt_update), json_row2);
            v_rcnt_update         := v_rcnt_update + 1;
          end;
        end if;
      end loop;

      v_total_loop          := json_item_update.get_size + v_max_num_loop;
      if json_item_update.get_size > 0 then
        while (v_current_loop < v_total_loop)
        loop
          v_current_loop    := v_current_loop + 1;
          save_tab1_tcontal4_update(json_item_update, v_typabs);
          if (json_item_update.get_size = 0) then
            exit;
          end if;
        end loop;
        if json_item_update.get_size > 0 then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal4');
          return;
        end if;
      end if;

      v_total_loop          := json_item_insert.get_size + v_max_num_loop;
      if json_item_insert.get_size > 0 then
        while (v_current_loop < v_total_loop)
        loop
          v_current_loop    := v_current_loop + 1;
          save_tab1_tcontal4_insert(json_item_insert, v_typabs);
          if (json_item_insert.get_size = 0) then
            exit;
          end if;
        end loop;
        if json_item_insert.get_size > 0 then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal4');
          return;
        end if;
      end if;

      -- Check cross time
      for r1 in c1 loop
        v_tmp_codcompy    := r1.codcompy;
        v_tmp_dteeffec    := r1.dteeffec;
        v_tmp_typabs      := r1.typabs;
        v_rowId           := r1.rowId;
        v_qtyminst        := r1.qtyminst;
        v_qtyminen        := r1.qtyminen;

        begin
          select rownum
            into v_tmp_rownum
            from tcontal4
           where codcompy = v_tmp_codcompy
             and dteeffec = v_tmp_dteeffec
             and typabs = v_tmp_typabs
             and rowId <> v_rowId
             and (
               qtyminst between v_qtyminst and v_qtyminen
               or qtyminen between v_qtyminst and v_qtyminen
               or v_qtyminst between qtyminst and qtyminen
               or v_qtyminen between qtyminst and qtyminen
             )
             and rownum <= 1;

          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal4');
          return;
        exception when no_data_found then
          null;
        end;
      end loop;
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
    obj_syncond           json_object_t;
    v_typabs              varchar2(1 char);
    v_numseq              number;
    v_syncond             varchar2(4000 char);
    v_statement           clob;
    v_flag                varchar2(100 char);

    v_typecal             varchar2(1 char);
    v_qtyabsst            number;
    v_qtyabsstOld         number;
    v_qtyabsen            number;
    v_qtyded              number;
    v_flagd               varchar2(100 char);
    v_rowId               varchar2(1000 char);

    v_tmp_rownum          number;
    v_tmp_codcompy        tabsdedd.codcompy%type;
    v_tmp_dteeffec        tabsdedd.dteeffec%type;
    v_tmp_typabs          tabsdedd.typabs%type;
    v_tmp_numseq          tabsdedd.numseq%type;

    json_item_insert      json_object_t;
    v_rcnt_insert         number;
    json_item_update      json_object_t;
    v_rcnt_update         number;
    v_max_num_loop        number := 20;
    v_total_loop          number := 0;
    v_current_loop        number := 0;

    cursor c1 is
      select a.*, a.rowId
        from tabsdedd a
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec
         and typabs = v_typabs
         and numseq = v_numseq
    order by numseq;

  begin
    json_param_obj        := hcm_util.get_json_t(json_input_obj, 'tab2');
    for i in 0..json_param_obj.get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj, to_char(i));
      v_typabs            := hcm_util.get_string_t(json_row, 'typabs');
      v_numseq            := hcm_util.get_string_t(json_row, 'numseq');
      obj_syncond         := hcm_util.get_json_t(json_row, 'syncond');
      v_syncond           := hcm_util.get_string_t(obj_syncond, 'code');
      v_statement         := hcm_util.get_string_t(obj_syncond, 'statement');
      v_flag              := hcm_util.get_string_t(json_row, 'flg');
      if v_flag = 'delete' then
        delete from tabsdedh
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and typabs   = v_typabs
           and numseq   = v_numseq;
      else
        if v_numseq is null then
          select (nvl(max(numseq), 0) + 1)
            into v_numseq
            from tabsdedh
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec
             and typabs   = v_typabs;
        end if;
        begin
          insert into tabsdedh
                 (codcompy, dteeffec, typabs, numseq, syncond, codcreate, statement, coduser)
          values (p_codcompy, p_dteeffec, v_typabs, v_numseq, v_syncond, global_v_coduser, v_statement, global_v_coduser);
        exception when dup_val_on_index then
          update tabsdedh
             set syncond = v_syncond,
                 statement = v_statement,
                 coduser  = global_v_coduser
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec
             and typabs   = v_typabs
             and numseq   = v_numseq;
        end;

        json_item_insert      := json_object_t();
        v_rcnt_insert         := 0;
        json_item_update      := json_object_t();
        v_rcnt_update         := 0;
        json_param_obj2       := hcm_util.get_json_t(json_row, 'children');
        for i in 0..json_param_obj2.get_size-1 loop
          json_row2           := hcm_util.get_json_t(json_param_obj2, to_char(i));
          v_typecal           := hcm_util.get_string_t(json_row2, 'typecal');
          v_qtyabsst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsst'));
          v_qtyabsstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsstOld'));
          v_qtyabsen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsen'));
          v_qtyded            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyded'));
          v_flagd             := hcm_util.get_string_t(json_row2, 'flg');
          v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

          if v_typecal = 1 and v_qtyded is null and v_flag <> 'delete' then
            param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtyded');
          return;
          end if;
          if v_qtyabsst is null then
            param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtyabsst');
          end if;
          if v_qtyabsen is null then
            param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtyabsen');
          end if;
--          if v_qtyded is null then
--            param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'qtyded');
--          end if;

          -- Manage case
          if v_flagd = 'delete' then
            delete from tabsdedd
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
               and typabs   = v_typabs
               and numseq   = v_numseq
               and qtyabsst = nvl(v_qtyabsstOld, v_qtyabsst);
          elsif v_flagd = 'add' then
            begin
              insert into tabsdedd
                     (codcompy, dteeffec, typabs, numseq, typecal, qtyabsst, qtyabsen, qtyded, codcreate, coduser)
              values (p_codcompy, p_dteeffec, v_typabs, v_numseq, v_typecal, v_qtyabsst, v_qtyabsen, v_qtyded, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              json_item_insert.put(to_char(v_rcnt_insert), json_row2);
              v_rcnt_insert   := v_rcnt_insert + 1;
            end;
          else
            begin
              update tabsdedd
                 set qtyabsst = v_qtyabsst,
                     qtyabsen = v_qtyabsen,
                     qtyded   = v_qtyded,
                     typecal  = v_typecal,
                     coduser  = global_v_coduser
               where codcompy = p_codcompy
                 and dteeffec = p_dteeffec
                 and typabs   = v_typabs
                 and numseq   = v_numseq
                 and qtyabsst = v_qtyabsstOld;
            exception when dup_val_on_index then
              json_item_update.put(to_char(v_rcnt_update), json_row2);
              v_rcnt_update   := v_rcnt_update + 1;
            end;
          end if;
        end loop;

        v_total_loop          := json_item_update.get_size + v_max_num_loop;
        if json_item_update.get_size > 0 then
          while (v_current_loop < v_total_loop)
          loop
            v_current_loop    := v_current_loop + 1;
            save_tab2_update(json_item_update, v_typabs, v_numseq);
            if (json_item_update.get_size = 0) then
              exit;
            end if;
          end loop;
          if json_item_update.get_size > 0 then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal5');
            return;
          end if;
        end if;

        v_total_loop          := json_item_insert.get_size + v_max_num_loop;
        if json_item_insert.get_size > 0 then
          while (v_current_loop < v_total_loop)
          loop
            v_current_loop    := v_current_loop + 1;
            save_tab2_insert(json_item_insert, v_typabs, v_numseq);
            if (json_item_insert.get_size = 0) then
              exit;
            end if;
          end loop;
          if json_item_insert.get_size > 0 then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal5');
            return;
          end if;
        end if;

        -- Check cross time
        for r1 in c1 loop
          v_tmp_codcompy    := r1.codcompy;
          v_tmp_dteeffec    := r1.dteeffec;
          v_tmp_typabs      := r1.typabs;
          v_tmp_numseq      := r1.numseq;
          v_rowId           := r1.rowId;
          v_qtyabsst        := r1.qtyabsst;
          v_qtyabsen        := r1.qtyabsen;

          begin
            select rownum
              into v_tmp_rownum
              from tabsdedd
             where codcompy = v_tmp_codcompy
               and dteeffec = v_tmp_dteeffec
               and typabs = v_tmp_typabs
               and numseq = v_tmp_numseq
               and rowId <> v_rowId
               and (
                 qtyabsst between v_qtyabsst and v_qtyabsen
                 or qtyabsen between v_qtyabsst and v_qtyabsen
                 or v_qtyabsst between qtyabsst and qtyabsen
                 or v_qtyabsen between qtyabsst and qtyabsen
               )
               and rownum <= 1;

            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontal5');
            return;
          exception when no_data_found then
            null;
          end;

        end loop;
      end if;
    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab3 (json_str_output out clob) is
    json_param_obj        json_object_t;

    v_codlate             varchar2(100 char);
    v_codrtlate           varchar2(100 char);
    v_codear              varchar2(100 char);
    v_codrtear            varchar2(100 char);
    v_codabs              varchar2(100 char);
    v_codrtabs            varchar2(100 char);
    v_codadjlate          varchar2(100 char);
    v_codadjear           varchar2(100 char);
    v_codadjabs           varchar2(100 char);
    v_codlevm             varchar2(100 char);
    v_codrtlevm           varchar2(100 char);
    v_codlev              varchar2(100 char);
    v_codrtlev            varchar2(100 char);
    v_codvacat            varchar2(100 char);
    v_codretro            varchar2(100 char);

    v_exists              number := 0;
  begin
    json_param_obj        := hcm_util.get_json_t(json_input_obj, 'tab3');
    v_codlate             := hcm_util.get_string_t(json_param_obj, 'codlate');
    v_codrtlate           := hcm_util.get_string_t(json_param_obj, 'codrtlate');
    v_codear              := hcm_util.get_string_t(json_param_obj, 'codear');
    v_codrtear            := hcm_util.get_string_t(json_param_obj, 'codrtear');
    v_codabs              := hcm_util.get_string_t(json_param_obj, 'codabs');
    v_codrtabs            := hcm_util.get_string_t(json_param_obj, 'codrtabs');
    v_codadjlate          := hcm_util.get_string_t(json_param_obj, 'codadjlate');
    v_codadjear           := hcm_util.get_string_t(json_param_obj, 'codadjear');
    v_codadjabs           := hcm_util.get_string_t(json_param_obj, 'codadjabs');
    v_codlevm             := hcm_util.get_string_t(json_param_obj, 'codlevm');
    v_codrtlevm           := hcm_util.get_string_t(json_param_obj, 'codrtlevm');
    v_codlev              := hcm_util.get_string_t(json_param_obj, 'codlev');
    v_codrtlev            := hcm_util.get_string_t(json_param_obj, 'codrtlev');
    v_codvacat            := hcm_util.get_string_t(json_param_obj, 'codvacat');
    v_codretro            := hcm_util.get_string_t(json_param_obj, 'codretro');

    if v_codlate is not null then
      param_msg_error := checkTcodec('tinexinf', v_codlate, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codrtlate is not null then
      param_msg_error := checkTcodec('tinexinf', v_codrtlate, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codear is not null then
      param_msg_error := checkTcodec('tinexinf', v_codear, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codrtear is not null then
      param_msg_error := checkTcodec('tinexinf', v_codrtear, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codabs is not null then
      param_msg_error := checkTcodec('tinexinf', v_codabs, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codrtabs is not null then
      param_msg_error := checkTcodec('tinexinf', v_codrtabs, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codadjlate is not null then
      param_msg_error := checkTcodec('tinexinf', v_codadjlate, '3');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codadjear is not null then
      param_msg_error := checkTcodec('tinexinf', v_codadjear, '3');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codadjabs is not null then
      param_msg_error := checkTcodec('tinexinf', v_codadjabs, '3');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codlevm is not null then
      param_msg_error := checkTcodec('tinexinf', v_codlevm, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codrtlevm is not null then
      param_msg_error := checkTcodec('tinexinf', v_codrtlevm, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codlev is not null then
      param_msg_error := checkTcodec('tinexinf', v_codlev, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codrtlev is not null then
      param_msg_error := checkTcodec('tinexinf', v_codrtlev, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codvacat is not null then
      param_msg_error := checkTcodec('tinexinf', v_codvacat, '3');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if v_codretro is not null then
      param_msg_error := checkTcodec('tinexinf', v_codretro, '5');
      if param_msg_error is not null then
        return;
      end if;
    end if;
    begin
      select 1
        into v_exists
        from tcontal2
       where codcompy   = p_codcompy
         and dteeffec   = p_dteeffec;
    exception when no_data_found then
      v_exists := 0;
    end;
    if v_exists = 0 and (
        v_codlate is not null
        or v_codrtlate is not null
        or v_codear is not null
        or v_codrtear is not null
        or v_codabs is not null
        or v_codrtabs is not null
        or v_codadjlate is not null
        or v_codadjear is not null
        or v_codadjabs is not null
        or v_codlevm is not null
        or v_codrtlevm is not null
        or v_codlev is not null
        or v_codrtlev is not null
        or v_codvacat is not null
        or v_codretro is not null
      )
      then
      insert into tcontal2
                  (codcompy, dteeffec,
                   codlate, codrtlate,
                   codear, codrtear, codabs, codrtabs,
                   codadjlate, codadjear, codadjabs,
                   codlevm, codrtlevm, codcreate,
                   codlev, codrtlev, codvacat, coduser,
                   codretro)
           values (p_codcompy, p_dteeffec,
                  v_codlate, v_codrtlate,
                  v_codear, v_codrtear, v_codabs, v_codrtabs,
                  v_codadjlate, v_codadjear, v_codadjabs,
                  v_codlevm, v_codrtlevm, global_v_coduser,
                  v_codlev, v_codrtlev, v_codvacat, global_v_coduser,
                  v_codretro);
    else
      update tcontal2
         set codlate    = v_codlate,
             codrtlate  = v_codrtlate,
             codear     = v_codear,
             codrtear   = v_codrtear,
             codabs     = v_codabs,
             codrtabs   = v_codrtabs,
             codadjlate = v_codadjlate,
             codadjear  = v_codadjear,
             codadjabs  = v_codadjabs,
             codlevm    = v_codlevm,
             codrtlevm  = v_codrtlevm,
             coduser    = global_v_coduser,
             codlev     = v_codlev,
             codrtlev   = v_codrtlev,
             codvacat   = v_codvacat,
             codretro   = v_codretro
       where codcompy   = p_codcompy
         and dteeffec   = p_dteeffec;
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_popup (json_str_input in clob, json_str_output out clob) is
    obj_data              json_object_t;
    obj_row               json_object_t;
    v_rcnt                number := 0;
    cursor c_contral is
      select codcompy, dteeffec, qtyavgwk, flgrdabs
        from tcontral
       where 0 <> (select count(ts.codcomp)
                      from tusrcom ts
                    where ts.coduser = global_v_coduser
                      and ts.codcomp like tcontral.codcompy || '%'
                      and rownum <= 1)
      order by codcompy, dteeffec desc;
  begin
    initial_value (json_str_input);
    obj_row              := json_object_t();
    for i in c_contral loop
      v_rcnt             := v_rcnt+1;
      obj_data           := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('codcompy',i.codcompy);
      obj_data.put('desc_codcompy', get_tcompny_name(i.codcompy, global_v_lang));
      obj_data.put('dteeffec',to_char(i.dteeffec, 'dd/mm/yyyy'));
      obj_data.put('qtyavgwk',hcm_util.convert_minute_to_hour(i.qtyavgwk));
      obj_data.put('flgrdabs',i.flgrdabs);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_popup;

  function checkTcodec (codcodec in varchar2, codcodec_val in varchar2, v_typpay in varchar2 default null) return varchar2 as
    v_descod      varchar2(1000 char);
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
    elsif codcodec = 'tinexinf' then
      begin
        select codpay
          into v_descod
          from tinexinf
         where codpay = codcodec_val
           and typpay like nvl(v_typpay, '%');
        begin
          select codpay
            into v_descod
            from tinexinfc
           where codcompy = p_codcompy
             and codpay = codcodec_val;
        exception when no_data_found then
          return get_error_msg_php('PY0044', global_v_lang, 'tinexinfc');
        end;
        return null;
      exception when no_data_found then
        if codcodec_val is not null and v_typpay = '5' then
          return get_error_msg_php('AL0002', global_v_lang, 'tinexinf');
        elsif codcodec_val is not null and v_typpay = '3' then
          return get_error_msg_php('AL0001', global_v_lang, 'tinexinf');
        else
          return get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
        end if;
      end;
    else
      return null;
    end if;
  end;

  procedure save_tab1_table2_update (json_current in out json_object_t, v_typabs number) is
    json_row2             json_object_t;
    v_qtyminst            number;
    v_qtyminstOld         number;
    v_qtyminen            number;
    v_qtymin              number;
    v_flag_child          varchar2(100 char);
    v_rowId               varchar2(1000 char);
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new              := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      json_row2           := hcm_util.get_json_t(json_current, to_char(k));
      v_qtyminst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminst'));
      v_qtyminstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminstOld'));
      v_qtyminen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminen'));
      v_qtymin            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtymin'));
      v_flag_child        := hcm_util.get_string_t(json_row2, 'flg');
      v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

      begin
        update tcontal3
           set qtyminst = v_qtyminst,
               qtyminen = v_qtyminen,
               qtymin   = v_qtymin,
               coduser  = global_v_coduser
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and typabs   = v_typabs
           and qtyminst = v_qtyminstOld;
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), json_row2);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end save_tab1_table2_update;

  procedure save_tab1_table2_insert (json_current in out json_object_t, v_typabs number) is
    json_row2             json_object_t;
    v_qtyminst            number;
    v_qtyminstOld         number;
    v_qtyminen            number;
    v_qtymin              number;
    v_flag_child          varchar2(100 char);
    v_rowId               varchar2(1000 char);
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new              := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      json_row2           := hcm_util.get_json_t(json_current, to_char(k));
      v_qtyminst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminst'));
      v_qtyminstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminstOld'));
      v_qtyminen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminen'));
      v_qtymin            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtymin'));
      v_flag_child        := hcm_util.get_string_t(json_row2, 'flg');
      v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

      begin
        insert into tcontal3
               (codcompy, dteeffec, typabs, qtyminst, qtyminen, qtymin, codcreate, coduser)
        values (p_codcompy, p_dteeffec, v_typabs, v_qtyminst, v_qtyminen, v_qtymin, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), json_row2);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end save_tab1_table2_insert;

  procedure save_tab1_tcontal4_update (json_current in out json_object_t, v_typabs number) is
    json_row2             json_object_t;
    v_typecal             varchar2(1 char);
    v_qtyminst            number;
    v_qtyminstOld         number;
    v_qtyminen            number;
    v_qtymin              number;
    v_flag_child          varchar2(100 char);
    v_rowId               varchar2(1000 char);
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new              := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      json_row2           := hcm_util.get_json_t(json_current, to_char(k));
      v_typecal           := hcm_util.get_string_t(json_row2, 'typecal');
      v_qtyminstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminstOld'));
      v_qtyminst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminst'));
      v_qtyminen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminen'));
      v_qtymin            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtymin'));
      v_flag_child        := hcm_util.get_string_t(json_row2, 'flg');
      v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

      begin
        update tcontal4
           set qtyminst = v_qtyminst,
               qtyminen = v_qtyminen,
               typecal  = v_typecal,
               qtymin   = v_qtymin,
               coduser  = global_v_coduser
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and typabs   = v_typabs
           and qtyminst = v_qtyminstOld;
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), json_row2);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end save_tab1_tcontal4_update;

  procedure save_tab1_tcontal4_insert (json_current in out json_object_t, v_typabs number) is
    json_row2             json_object_t;
    v_typecal             varchar2(1 char);
    v_qtyminst            number;
    v_qtyminstOld         number;
    v_qtyminen            number;
    v_qtymin              number;
    v_flag_child          varchar2(100 char);
    v_rowId               varchar2(1000 char);
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new              := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      json_row2           := hcm_util.get_json_t(json_current, to_char(k));
      v_typecal           := hcm_util.get_string_t(json_row2, 'typecal');
      v_qtyminstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminstOld'));
      v_qtyminst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminst'));
      v_qtyminen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyminen'));
      v_qtymin            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtymin'));
      v_flag_child        := hcm_util.get_string_t(json_row2, 'flg');
      v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

      begin
        insert into tcontal4
               (codcompy, dteeffec, typabs, typecal, qtyminst, qtyminen, qtymin, codcreate, coduser)
        values (p_codcompy, p_dteeffec, v_typabs, v_typecal, v_qtyminst, v_qtyminen, v_qtymin, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), json_row2);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end save_tab1_tcontal4_insert;

  procedure save_tab2_update (json_current in out json_object_t, v_typabs number, v_numseq number) is
    json_row2             json_object_t;
    v_qtyabsst            number;
    v_qtyabsstOld         number;
    v_qtyabsen            number;
    v_qtyded              number;
    v_flagd               varchar2(100 char);
    v_rowId               varchar2(1000 char);
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new              := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      json_row2           := hcm_util.get_json_t(json_current, to_char(k));
      v_qtyabsst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsst'));
      v_qtyabsstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsstOld'));
      v_qtyabsen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsen'));
      v_qtyded            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyded'));
      v_flagd             := hcm_util.get_string_t(json_row2, 'flg');
      v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

      begin
        update tabsdedd
           set qtyabsst = v_qtyabsst,
               qtyabsen = v_qtyabsen,
               qtyded   = v_qtyded,
               coduser  = global_v_coduser
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and typabs   = v_typabs
           and numseq   = v_numseq
           and qtyabsst = v_qtyabsstOld;
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), json_row2);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end save_tab2_update;

  procedure save_tab2_insert (json_current in out json_object_t, v_typabs number, v_numseq number) is
    json_row2             json_object_t;
    v_qtyabsst            number;
    v_qtyabsstOld         number;
    v_qtyabsen            number;
    v_qtyded              number;
    v_flagd               varchar2(100 char);
    v_rowId               varchar2(1000 char);
    json_new              json_object_t;

    v_rcnt                number := 0;
  begin
    json_new              := json_object_t();
    for k in 0..json_current.get_size - 1 loop
      json_row2           := hcm_util.get_json_t(json_current, to_char(k));
      v_qtyabsst          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsst'));
      v_qtyabsstOld       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsstOld'));
      v_qtyabsen          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyabsen'));
      v_qtyded            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_row2, 'qtyded'));
      v_flagd             := hcm_util.get_string_t(json_row2, 'flg');
      v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

      begin
        insert into tabsdedd
               (codcompy, dteeffec, typabs, numseq, qtyabsst, qtyabsen, qtyded, codcreate, coduser)
        values (p_codcompy, p_dteeffec, v_typabs, v_numseq, v_qtyabsst, v_qtyabsen, v_qtyded, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        json_new.put(to_char(v_rcnt), json_row2);
        v_rcnt          := v_rcnt + 1;
      end;
    end loop;
    json_current        := json_new;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end save_tab2_insert;

end HRAL91E;

/
