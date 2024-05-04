--------------------------------------------------------
--  DDL for Package Body HRAL11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL11E" is

  procedure initial_value(json_str in clob) is
    json_obj      json_object_t := json_object_t(json_str);
  begin

    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_typleave  := hcm_util.get_string_t(json_obj,'p_typleave');
    b_index_codleave  := hcm_util.get_string_t(json_obj,'p_codleave');

    p_typleave    := hcm_util.get_string_t(json_obj,'typleave');
    p_qtydlepay   := to_number(hcm_util.get_string_t(json_obj,'qtydlepay'));
    p_flgdlemx    := hcm_util.get_string_t(json_obj,'flgdlemx');
    p_qtydlepery  := to_number(hcm_util.get_string_t(json_obj,'qtydlepery'));
    p_qtytimle    := to_number(hcm_util.get_string_t(json_obj,'qtytimle'));
    p_flgtimle    := hcm_util.get_string_t(json_obj,'flgtimle');
    p_flgtype     := hcm_util.get_string_t(json_obj,'flgtype');
    p_daylevst    := to_number(hcm_util.get_string_t(json_obj,'daylevst'));
    p_mthlevst    := to_number(hcm_util.get_string_t(json_obj,'mthlevst'));
    p_dayleven    := to_number(hcm_util.get_string_t(json_obj,'dayleven'));
    p_mthleven    := to_number(hcm_util.get_string_t(json_obj,'mthleven'));
    p_flgchol     := hcm_util.get_string_t(json_obj,'flgchol');
    p_flgwkcal    := hcm_util.get_string_t(json_obj,'flgwkcal');
    p_codpay      := hcm_util.get_string_t(json_obj,'codpay');
    p_pctded      := to_number(hcm_util.get_string_t(json_obj,'pctded'));
    -- paternity leave --
    p_codlvprgnt  := hcm_util.get_string_t(json_obj,'codlvprgnt');
    p_flgchkprgnt  := hcm_util.get_string_t(json_obj,'flgchkprgnt');

    p_codleave    := hcm_util.get_string_t(json_obj,'codleave');
    p_syncond     := hcm_util.get_string_t(json_obj,'syncond');
    p_statement   := hcm_util.get_string_t(json_obj,'statement');
    p_qtydlefw    := hcm_util.get_string_t(json_obj,'qtydlefw');
    p_qtydlebw    := hcm_util.get_string_t(json_obj,'qtydlebw');
    p_flgleave    := hcm_util.get_string_t(json_obj,'flgleave');
    p_qtyminle    := hcm_util.get_string_t(json_obj,'qtyminle');
    p_qtyminunit  := hcm_util.get_string_t(json_obj,'qtyminunit');

    p_namleavty   := hcm_util.get_string_t(json_obj,'desc_typleave');
    p_namleavtye	:= hcm_util.get_string_t(json_obj,'desc_typleavee');
    p_namleavtyt	:= hcm_util.get_string_t(json_obj,'desc_typleavet');
    p_namleavty3	:= hcm_util.get_string_t(json_obj,'desc_typleave3');
    p_namleavty4	:= hcm_util.get_string_t(json_obj,'desc_typleave4');
    p_namleavty5	:= hcm_util.get_string_t(json_obj,'desc_typleave5');
    begin
      if global_v_lang = '101' then
        p_namleavtye  := hcm_util.get_string_t(json_obj,'desc_typleave');
      end if;
      if global_v_lang = '102' then
        p_namleavtyt	:= hcm_util.get_string_t(json_obj,'desc_typleave');
      end if;
      if global_v_lang = '103' then
        p_namleavty3	:= hcm_util.get_string_t(json_obj,'desc_typleave');
      end if;
      if global_v_lang = '104' then
        p_namleavty4	:= hcm_util.get_string_t(json_obj,'desc_typleave');
      end if;
      if global_v_lang = '105' then
        p_namleavty5	:= hcm_util.get_string_t(json_obj,'desc_typleave');
      end if;
    end;

    p_namleavcd   := hcm_util.get_string_t(json_obj,'desc_codleave');
    p_namleavcde	:= hcm_util.get_string_t(json_obj,'desc_codleavee');
    p_namleavcdt	:= hcm_util.get_string_t(json_obj,'desc_codleavet');
    p_namleavcd3	:= hcm_util.get_string_t(json_obj,'desc_codleave3');
    p_namleavcd4	:= hcm_util.get_string_t(json_obj,'desc_codleave4');
    p_namleavcd5	:= hcm_util.get_string_t(json_obj,'desc_codleave5');
    begin
      if global_v_lang = '101' then
        p_namleavcde  := hcm_util.get_string_t(json_obj,'desc_codleave');
      end if;
      if global_v_lang = '102' then
        p_namleavcdt	:= hcm_util.get_string_t(json_obj,'desc_codleave');
      end if;
      if global_v_lang = '103' then
        p_namleavcd3	:= hcm_util.get_string_t(json_obj,'desc_codleave');
      end if;
      if global_v_lang = '104' then
        p_namleavcd4	:= hcm_util.get_string_t(json_obj,'desc_codleave');
      end if;
      if global_v_lang = '105' then
        p_namleavcd5	:= hcm_util.get_string_t(json_obj,'desc_codleave');
      end if;
    end;
  end initial_value;
  --P_CODE  IN VARCHAR2) RETURN VARCHAR2
  function check_delete(p_codleave in varchar2) return boolean is
    v_count   number := 0;
    v_del     boolean;

    cursor c1 is
      select codleave
        from tleavecd
       where typleave = p_codleave;
  begin
    for r1 in c1 loop
      begin
        select count(codleave) into v_count
          from tlereqst
         where codleave = r1.codleave
           and rownum = 1;
      exception when others then
        v_count := 0;
      end;
      if v_count > 0 then
        exit;
      end if;
    end loop;

    if v_count = 0 then
      begin
        select count(codleave) into v_count
          from tlereqst
         where codleave = p_codleave
           and rownum = 1;
      exception when others then
        v_count := 0;
      end;
    end if;

    if v_count > 0 then
      v_del := false;
    else
      v_del := true;
    end if;
    return v_del;
  end check_delete;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row		    number := 0;
    cursor c1 is
      select typleave
        from tleavety
    order by typleave;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();

    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('typleave',i.typleave);
      obj_data.put('desc_typleave',get_tleavety_name(i.typleave,global_v_lang));
      obj_data.put('flgcorr',check_delete(i.typleave));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure get_tab_typeleave(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_tab_typeleave(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab_typeleave;

  procedure gen_tab_typeleave(json_str_output out clob) as
    obj_row       json_object_t;
    v_qtydlepay   number;
    v_flgdlemx    varchar2(1 char);
    v_qtydlepery  number;
    v_qtytimle    number;
    v_flgtimle    varchar2(1 char);
    v_flgtype     varchar2(1 char);
    v_flgchkprgnt varchar2(1 char);
    v_daylevst    number;
    v_mthlevst    number;
    v_dayleven    number;
    v_mthleven    number;
    v_flgchol     varchar2(1 char);
    v_flgwkcal    varchar2(1 char);
    v_codpay      tinexinf.codpay%type;
    v_pctded      number;
    v_codlvprgnt  varchar2(1000 char);
    v_namleavty   varchar2(4000 char);
    v_namleavtye  varchar2(4000 char);
    v_namleavtyt  varchar2(4000 char);
    v_namleavty3  varchar2(4000 char);
    v_namleavty4  varchar2(4000 char);
    v_namleavty5  varchar2(4000 char);

  begin
--    initial_value(json_str_input);
    begin
      select namleavtye,namleavtyt,namleavty3,namleavty4,namleavty5,qtydlepay,flgdlemx,qtydlepery,qtytimle,flgchkprgnt,
             flgtimle,daylevst,mthlevst,dayleven,mthleven,flgtype,flgchol,flgwkcal,codpay,pctded,
             decode(global_v_lang, '101', namleavtye,
                                   '102', namleavtyt,
                                   '103', namleavty3,
                                   '104', namleavty4,
                                   '105', namleavty5,
                                   '') namleavty
        into v_namleavtye,v_namleavtyt,v_namleavty3,v_namleavty4,v_namleavty5,v_qtydlepay,v_flgdlemx,v_qtydlepery,v_qtytimle,v_flgchkprgnt,
             v_flgtimle,v_daylevst,v_mthlevst,v_dayleven,v_mthleven,v_flgtype,v_flgchol,v_flgwkcal,v_codpay,v_pctded,v_namleavty
        from tleavety
       where typleave = b_index_typleave;
    exception when no_data_found then
      v_namleavty   := null;
      v_namleavtye  := null;
      v_namleavtyt  := null;
      v_namleavty3  := null;
      v_namleavty4  := null;
      v_namleavty5  := null;
      v_qtydlepay   := null;
      v_flgdlemx    := null;
      v_qtydlepery  := null;
      v_qtytimle    := null;
      v_flgtimle    := null;
      v_flgtype     := null;
      v_flgchol     := null;
      v_flgwkcal    := null;
      v_codpay      := null;
      v_pctded      := null;
      v_flgchkprgnt := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('typleave', b_index_typleave);
    obj_row.put('desc_typleave',v_namleavty);
    obj_row.put('desc_typleavee',v_namleavtye);
    obj_row.put('desc_typleavet',v_namleavtyt);
    obj_row.put('desc_typleave3',v_namleavty3);
    obj_row.put('desc_typleave4',v_namleavty4);
    obj_row.put('desc_typleave5',v_namleavty5);
    obj_row.put('qtydlepay', v_qtydlepay);
    obj_row.put('flgdlemx', v_flgdlemx);
    obj_row.put('qtydlepery', v_qtydlepery);
    obj_row.put('qtytimle', v_qtytimle);
    obj_row.put('flgtimle', v_flgtimle);
    obj_row.put('flgtype', v_flgtype);
    obj_row.put('daylevst', v_daylevst);
    obj_row.put('mthlevst', v_mthlevst);
    obj_row.put('dayleven', v_dayleven);
    obj_row.put('mthleven', v_mthleven);
    obj_row.put('flgchol', v_flgchol);
    obj_row.put('flgwkcal', v_flgwkcal);
    obj_row.put('codpay', v_codpay);
    obj_row.put('desc_codpay', get_tinexinf_name(v_codpay, global_v_lang));
    obj_row.put('pctded', v_pctded);
--    obj_row.put('codlvprgnt', v_codlvprgnt);
    obj_row.put('flgchkprgnt', nvl(v_flgchkprgnt,'N'));
    if isInsertReport then
        insert_ttemprpt_detail(obj_row);
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab_typeleave;

  procedure get_tab_codeleave(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_tab_codeleave(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab_codeleave;

  procedure gen_tab_codeleave(json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_data_att  json_object_t;
    obj_row_att   json_object_t;
    v_row		      number := 0;
    v_row_att     number := 0;
    v_codleave    tleavecd.codleave%type;
    cursor c1 is
      select codleave,namleavcde,namleavcdt,namleavcd3,namleavcd4,namleavcd5,typleave,
             syncond,flgleave,qtyminle,staleave,qtydlefw,qtydlebw,statement,
             decode(global_v_lang, '101', namleavcde,
                                   '102', namleavcdt,
                                   '103', namleavcd3,
                                   '104', namleavcd4,
                                   '105', namleavcd5,
                                   '') namleavcd,qtyminunit
        from tleavecd
       where typleave = b_index_typleave
    order by codleave;


    cursor c_tleavecdatt is
      select numseq,  filename, flgattach
        from tleavecdatt
       where codleave = v_codleave;
  begin
    obj_row    := json_object_t();
    for i in c1 loop
      v_row      := v_row + 1;
      v_codleave := i.codleave;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codleave',i.codleave);
      obj_data.put('desc_codleave',i.namleavcd);
      obj_data.put('desc_codleavee',i.namleavcde);
      obj_data.put('desc_codleavet',i.namleavcdt);
      obj_data.put('desc_codleave3',i.namleavcd3);
      obj_data.put('desc_codleave4',i.namleavcd4);
      obj_data.put('desc_codleave5',i.namleavcd5);
      obj_data.put('typleave', i.typleave);
      obj_data.put('desc_typleave',get_tleavety_name(i.typleave,global_v_lang));
      obj_data.put('syncond',i.syncond);
--      obj_data.put('desc_syncond',get_logical_name('HRAL11E',i.syncond,global_v_lang));
      obj_data.put('desc_syncond', get_logical_desc(i.statement));
      obj_data.put('statement', i.statement);
      obj_data.put('flgtype', i.staleave);
      obj_data.put('qtydlefw', i.qtydlefw);
      obj_data.put('qtydlebw', i.qtydlebw);
      obj_data.put('flgleave', i.flgleave);
      obj_data.put('qtyminle', hcm_util.convert_minute_to_time(i.qtyminle));
      obj_data.put('qtyminunit', to_number(i.qtyminunit));
      obj_data.put('numseq', v_row);
      -- loop document attactment file --
      obj_row_att := json_object_t();
      for r1 in c_tleavecdatt loop
        obj_data_att := json_object_t();
        obj_data_att.put('coderror', '200');
        obj_data_att.put('numseq',r1.numseq);
        obj_data_att.put('filename',r1.filename);
        obj_data_att.put('flgattach',r1.flgattach);

        obj_row_att.put(to_char(v_row_att),obj_data_att);
        v_row_att := v_row_att + 1;
      end loop;
      obj_data.put('document_att', obj_row_att);
      -- insert temp report --
      if isInsertReport then
        insert_ttemprpt_table(obj_data);
      end if;
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab_codeleave;
  --
  procedure get_detail_codleave(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    v_typleave    varchar2(4 char);
    v_syncond     varchar2(1000 char);
    v_flgleave    varchar2(1 char);
    v_qtyminle    number;
    v_qtyminunit  number;
    v_flgtype     varchar2(1 char);
    v_qtydlefw    number;
    v_qtydlebw    number;
    v_statement   clob;
    v_namleavcd   varchar2(4000 char);
    v_namleavcde  varchar2(4000 char);
    v_namleavcdt  varchar2(4000 char);
    v_namleavcd3  varchar2(4000 char);
    v_namleavcd4  varchar2(4000 char);
    v_namleavcd5  varchar2(4000 char);
  begin
    initial_value(json_str_input);
    begin
      select namleavcde,namleavcdt,namleavcd3,namleavcd4,namleavcd5,typleave,
             syncond,flgleave,qtyminle,staleave,qtydlefw,qtydlebw,statement,
             decode(global_v_lang, '101', namleavcde,
                                   '102', namleavcdt,
                                   '103', namleavcd3,
                                   '104', namleavcd4,
                                   '105', namleavcd5,
                                   '') namleavcd, qtyminunit
        into v_namleavcde,v_namleavcdt,v_namleavcd3,v_namleavcd4,v_namleavcd5,v_typleave,
             v_syncond,v_flgleave,v_qtyminle,v_flgtype,v_qtydlefw,v_qtydlebw,v_statement,v_namleavcd, v_qtyminunit
        from tleavecd
       where codleave = b_index_codleave;
    exception when no_data_found then
      v_namleavcde  := null;
      v_namleavcdt  := null;
      v_namleavcd3  := null;
      v_namleavcd4  := null;
      v_namleavcd5  := null;
      v_typleave    := null;
      v_syncond     := null;
      v_flgleave    := null;
      v_qtyminle    := null;
      v_qtyminunit  := null;
      v_flgtype     := null;
      v_qtydlefw    := null;
      v_qtydlebw    := null;
      v_statement   := null;
      v_namleavcd   := null;
    end;

    if v_typleave is not null and v_typleave != b_index_typleave then
      param_msg_error := get_error_msg_php('AL0066', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codleave',b_index_codleave);
    obj_row.put('desc_codleave',v_namleavcd);
    obj_row.put('desc_codleavee',v_namleavcde);
    obj_row.put('desc_codleavet',v_namleavcdt);
    obj_row.put('desc_codleave3',v_namleavcd3);
    obj_row.put('desc_codleave4',v_namleavcd4);
    obj_row.put('desc_codleave5',v_namleavcd5);
    obj_row.put('typleave', v_typleave);
    obj_row.put('desc_typleave',get_tleavety_name(v_typleave,global_v_lang));
    obj_row.put('syncond',v_syncond);
--    obj_row.put('desc_syncond',get_logical_name('HRAL11E',v_syncond,global_v_lang));
    obj_row.put('desc_syncond', get_logical_desc(v_statement));
    obj_row.put('statement', v_statement);
    obj_row.put('flgtype', v_flgtype);
    obj_row.put('qtydlefw', v_qtydlefw);
    obj_row.put('qtydlebw', v_qtydlebw);
    obj_row.put('flgleave', v_flgleave);
    obj_row.put('qtyminle', hcm_util.convert_minute_to_time(v_qtyminle));
    obj_row.put('qtyminunit', v_qtyminunit);


    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_codleave;
  --
  procedure save_detail(json_str_input in clob, json_str_output out clob) is
    param_json        json_object_t;
    param_json_row    json_object_t;
    obj_syncond       json_object_t;
    v_namleavcde      varchar2(1000 char);
    v_namleavcdt      varchar2(1000 char);
    v_namleavcd3      varchar2(1000 char);
    v_namleavcd4      varchar2(1000 char);
    v_namleavcd5      varchar2(1000 char);
    v_codleave        varchar2(4 char);
    v_namleavcd       varchar2(1000 char);
    v_syncond         varchar2(1000 char);
    v_statement       clob;
    v_qtydlefw        number;
    v_qtydlebw        number;
    v_flgleave        varchar2(1 char);
    v_qtyminle        number;
    v_qtyminunit      number;
    v_flgtype         varchar2(1 char);
    v_flgv            number;
    v_flgc            number;
    v_flg_action      varchar2(100 char);
    v_json_leave      json_object_t;
    json_leave_row    json_object_t;
    v_leave_flg       varchar2(100 char);
    v_numseq          tleavecdatt.numseq%type;
    v_filename        tleavecdatt.filename%type;
    v_flgattach       tleavecdatt.flgattach%type;
    v_chk_typleave    TLEAVETY.TYPLEAVE%TYPE;
    v_chk_codleave    TLEAVECD.CODLEAVE%TYPE;

    cursor check_paternity is
      select codleave
        from tleavecd
       where typleave = p_typleave;
  begin
    initial_value(json_str_input);
    --check_index;

    if param_msg_error is null then
      begin
        select typleave
          into v_chk_typleave
          from tleavety
         where flgtype = 'V'
           and rownum <= 1;  -- a?za??a??a?#a??a?-a??
      exception when no_data_found then
        v_chk_typleave := null;
      end;
      if p_flgtype = 'V' and p_typleave != v_chk_typleave then
        param_msg_error := get_error_msg_php('AL0036',global_v_lang,'flgtype');
      end if;

      begin
        select typleave
          into v_chk_typleave
          from tleavety
         where flgtype = 'C'
           and rownum <= 1;  -- a?Sa??a??a?Sa??
      exception when no_data_found then
        v_chk_typleave := null;
      end;
      if p_flgtype = 'C' and p_typleave != v_chk_typleave then
        param_msg_error := get_error_msg_php('AL0035',global_v_lang);
      end if;

      -- check codleave --
      for r1 in check_paternity loop
        if r1.codleave = p_codlvprgnt then
          param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TLEAVECD');
        end if;
      end loop;
      if p_flgtype = 'M' then
        p_flgdlemx  :=  'P';
      end if;
      begin
        insert into tleavety(typleave, namleavtye, namleavtyt, namleavty3, namleavty4,
                             namleavty5, qtydlepay, flgdlemx, qtydlepery, qtytimle,
                             flgtimle, flgtype, daylevst, mthlevst, dayleven, mthleven,
                             flgchol, flgwkcal, codpay, pctded, codcreate, coduser,
                             -- paternity leave --
                             flgchkprgnt)
                     values (p_typleave, p_namleavtye, p_namleavtyt, p_namleavty3, p_namleavty4,
                             p_namleavty5, p_qtydlepay, p_flgdlemx, p_qtydlepery, p_qtytimle,
                             p_flgtimle, p_flgtype, p_daylevst, p_mthlevst, p_dayleven, p_mthleven,
                             p_flgchol, p_flgwkcal, p_codpay, p_pctded, global_v_coduser, global_v_coduser,
                             -- paternity leave --
                             p_flgchkprgnt);
      exception when dup_val_on_index then
        begin
          update  tleavety
          set     namleavtye  = p_namleavtye,
                  namleavtyt  = p_namleavtyt,
                  namleavty3  = p_namleavty3,
                  namleavty4  = p_namleavty4,
                  namleavty5  = p_namleavty5,
                  qtydlepay   = p_qtydlepay,
                  flgdlemx    = p_flgdlemx,
                  qtydlepery  = p_qtydlepery,
                  qtytimle    = p_qtytimle,
                  flgtimle    = p_flgtimle,
                  flgtype     = p_flgtype,
                  daylevst    = p_daylevst,
                  mthlevst    = p_mthlevst,
                  dayleven    = p_dayleven,
                  mthleven    = p_mthleven,
                  flgchol     = p_flgchol,
                  flgwkcal    = p_flgwkcal,
                  codpay      = p_codpay,
                  pctded      = p_pctded,
                  coduser     = global_v_coduser,
                  -- paternity leave --
                  flgchkprgnt = p_flgchkprgnt
          where   typleave = p_typleave;
        exception when others then
          rollback;
        end;
      end;

      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      for i in 0..param_json.get_size-1 loop
        param_json_row   := hcm_util.get_json_t(param_json,to_char(i));
        v_flg_action     := hcm_util.get_string_t(param_json_row, 'flg');
        v_codleave       := hcm_util.get_string_t(param_json_row,'codleave');
        v_namleavcd      := hcm_util.get_string_t(param_json_row,'desc_codleave');
        v_namleavcde     := hcm_util.get_string_t(param_json_row,'desc_codleavee');
        v_namleavcdt     := hcm_util.get_string_t(param_json_row,'desc_codleavet');
        v_namleavcd3     := hcm_util.get_string_t(param_json_row,'desc_codleave3');
        v_namleavcd4     := hcm_util.get_string_t(param_json_row,'desc_codleave4');
        v_namleavcd5     := hcm_util.get_string_t(param_json_row,'desc_codleave5');
        obj_syncond      := hcm_util.get_json_t(param_json_row,'syncond');
        v_syncond        := hcm_util.get_string_t(obj_syncond, 'code');
        v_statement      := hcm_util.get_string_t(obj_syncond, 'statement');
        v_flgtype        := hcm_util.get_string_t(param_json_row,'flgtype');
        v_qtydlefw       := to_number(hcm_util.get_string_t(param_json_row,'qtydlefw'));
        v_qtydlebw       := to_number(hcm_util.get_string_t(param_json_row,'qtydlebw'));
        v_flgleave       := hcm_util.get_string_t(param_json_row,'flgleave');
        v_qtyminle       := hcm_util.convert_time_to_minute(hcm_util.get_string_t(param_json_row,'qtyminle'));
        v_qtyminunit     := to_number(hcm_util.get_string_t(param_json_row,'qtyminunit'));
        v_json_leave     := hcm_util.get_json_t(param_json_row,'param_json_sub');

        if global_v_lang = '101' then
          v_namleavcde := v_namleavcd;
        elsif global_v_lang = '102' then
          v_namleavcdt := v_namleavcd;
        elsif global_v_lang = '103' then
          v_namleavcd3 := v_namleavcd;
        elsif global_v_lang = '104' then
          v_namleavcd4 := v_namleavcd;
        elsif global_v_lang = '105' then
          v_namleavcd5 := v_namleavcd;
        end if;

        begin
          select codleave
            into v_chk_codleave
            from tleavecd
           where staleave = 'V'
             and rownum <= 1;  -- a?za??a??a?#a??a?-a??
        exception when no_data_found then
          v_chk_codleave := null;
        end;
        if v_flgtype = 'V' and v_codleave != v_chk_codleave then
          param_msg_error := get_error_msg_php('AL0036', global_v_lang, 'flgtype');
        end if;

        begin
          select codleave
            into v_chk_codleave
            from tleavecd
           where staleave = 'C'
             and rownum <= 1;  -- a?Sa??a??a?Sa??
        exception when no_data_found then
          v_chk_codleave := null;
        end;
        if v_flgtype = 'C' and v_codleave != v_chk_codleave then
          param_msg_error := get_error_msg_php('AL0035', global_v_lang);
        end if;

        if lower(v_flg_action) = 'delete' then
          if check_delete(v_codleave) then
            begin
              delete from tleavecd
                    where codleave = v_codleave;
            exception when others then
              null;
            end;
          else
            param_msg_error := get_error_msg_php('CO0030',global_v_lang);
          end if;
        else
          begin
            insert into tleavecd(codleave, typleave, namleavcde, namleavcdt, namleavcd3, namleavcd4, namleavcd5,
                                 syncond, flgleave, qtyminle, qtyminunit, staleave,  qtydlefw, qtydlebw, statement, codcreate)
                         values (v_codleave, p_typleave, v_namleavcde, v_namleavcdt, v_namleavcd3, v_namleavcd4, v_namleavcd5,
                                 v_syncond, v_flgleave, v_qtyminle, v_qtyminunit, v_flgtype, v_qtydlefw, v_qtydlebw, v_statement, global_v_coduser);
          exception when dup_val_on_index then
            begin
              update  tleavecd
              set     typleave    = p_typleave,
                      namleavcde  = v_namleavcde,
                      namleavcdt  = v_namleavcdt,
                      namleavcd3  = v_namleavcd3,
                      namleavcd4  = v_namleavcd4,
                      namleavcd5  = v_namleavcd5,
                      syncond     = v_syncond,
                      flgleave    = v_flgleave,
                      qtyminle    = v_qtyminle,
                      qtyminunit  = v_qtyminunit,
                      staleave    = v_flgtype,
                      qtydlefw    = v_qtydlefw,
                      qtydlebw    = v_qtydlebw,
                      statement   = v_statement,
                      coduser     = global_v_coduser
              where   codleave = v_codleave;
            exception when others then
              rollback;
            end;
          end;
        end if;
        -- document attachment files --
        for i in 0..v_json_leave.get_size-1 loop
          json_leave_row   := hcm_util.get_json_t(v_json_leave,to_char(i));
          v_leave_flg      := hcm_util.get_string_t(json_leave_row, 'flg');
          v_numseq         := hcm_util.get_string_t(json_leave_row,'numseq');
          v_filename       := hcm_util.get_string_t(json_leave_row,'filename');
          v_flgattach      := hcm_util.get_string_t(json_leave_row,'flgattach');

          if lower(v_leave_flg) = 'delete' then
            begin
              delete from tleavecdatt
                    where codleave = v_codleave
                      and numseq   = v_numseq;
            exception when others then null;
            end;
          elsif lower(v_leave_flg) in ('add','edit') then
            if nvl(v_numseq,0) < 1 then
              begin
                select max(numseq) into v_numseq
                  from tleavecdatt
                 where codleave = v_codleave;
                 v_numseq := nvl(v_numseq,0) + 1;
              exception when no_data_found then
                v_numseq := 1;
              end;
            end if;
            --
            begin
              insert into tleavecdatt(codleave, numseq, filename, flgattach, codcreate, dtecreate)
                              values (v_codleave, v_numseq, v_filename, nvl(v_flgattach,'N'), global_v_coduser, trunc(sysdate));
            exception when dup_val_on_index then
              begin
                update  tleavecdatt
                set     filename  = v_filename,
                        flgattach = v_flgattach,
                        coduser   = global_v_coduser,
                        dteupd    = trunc(sysdate)
                where   codleave  = v_codleave
                  and   numseq    = v_numseq;
              exception when others then
                rollback;
              end;
            end;
          end if;
        end loop;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;
  --
  procedure save_codleave(json_str_input in clob, json_str_output out clob) is
    v_namleavcde  varchar2(1000 char);
    v_namleavcdt  varchar2(1000 char);
    v_namleavcd3  varchar2(1000 char);
    v_namleavcd4  varchar2(1000 char);
    v_namleavcd5  varchar2(1000 char);
    v_qtyminle    number;
    v_qtyminunit  number;
  begin
    initial_value(json_str_input);
    --check_index;
    if param_msg_error is null then
      v_qtyminle := hcm_util.convert_time_to_minute(p_qtyminle);
      v_qtyminunit := to_number(p_qtyminunit);
      begin
        insert into tleavecd(codleave, typleave, namleavcde, namleavcdt, namleavcd3,
                             namleavcd4, namleavcd5, syncond, flgleave, qtyminle, qtyminunit, codcreate, coduser)
                     values (p_codleave, p_typleave, p_namleavcde, p_namleavcdt, p_namleavcd3,
                             p_namleavcd4, p_namleavcd5, p_syncond, p_flgleave, v_qtyminle, v_qtyminunit, global_v_coduser, global_v_coduser);

      exception when dup_val_on_index then
        begin
          update  tleavecd
          set     typleave    = p_typleave,
                  namleavcde  = p_namleavcde,
                  namleavcdt  = p_namleavcdt,
                  namleavcd3  = p_namleavcd3,
                  namleavcd4  = p_namleavcd4,
                  namleavcd5  = p_namleavcd5,
                  syncond     = p_syncond,
                  flgleave    = p_flgleave,
                  qtyminle    = v_qtyminle,
                  qtyminunit  = v_qtyminunit,
                  coduser     = global_v_coduser
          where   codleave = p_codleave;
        exception when others then
          rollback;
        end;
      end;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_codleave;
  --
  procedure delete_index(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;

    cursor c1 is
      select codleave
        from tleavecd
       where typleave = p_typleave;

  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        p_typleave      := hcm_util.get_string_t(param_json_row,'typleave');

        if check_delete(p_typleave) then
          -- delete document leave --
          for r1 in c1 loop
            delete from tleavecdatt
                  where codleave = r1.codleave;
          end loop;
          --
          delete from tleavety
                where typleave = p_typleave;
          delete from tleavecd
                where typleave = p_typleave;
        else
          param_msg_error := get_error_msg_php('CO0030',global_v_lang);
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  ----- start Specific Report ------
  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
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
--        b_index_typleave := hcm_util.get_string_t(json_index_rows, to_char(i));
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        b_index_typleave  := hcm_util.get_string_t(p_index_rows, 'typleave');

        p_codapp := 'HRAL11E';
        gen_tab_typeleave(json_output);
        p_codapp := 'HRAL11E1';
        gen_tab_codeleave(json_output);
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

  procedure insert_ttemprpt_detail(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_flgchol           varchar2(100 char);
    v_desc_codpay       varchar2(1000 char);
    v_typleave          varchar2(1000 char) := '';
    v_desc_typleave    	varchar2(1000 char) := '';
    v_qtydlepery       	varchar2(1000 char) := '';
    v_qtydlepay         varchar2(1000 char) := '';
    v_flgdlemx    	  	varchar2(1000 char) := '';
    v_flgtype    	  		varchar2(1000 char) := '';
    v_qtytimle    	  	varchar2(1000 char) := '';
    v_flgtimle    	  	varchar2(1000 char) := '';
    v_daylevst    	  	varchar2(1000 char) := '';
    v_mthlevst    	  	varchar2(1000 char) := '';
    v_dayleven    	  	varchar2(1000 char) := '';
    v_mthleven    	  	varchar2(1000 char) := '';
    v_flgwkcal    	  	varchar2(1000 char) := '';
    v_pctded    	  		varchar2(1000 char) := '';
    v_codlvprgnt    	  varchar2(1000 char) := '';
    v_desc_codlvprgnt   varchar2(1000 char) := '';

  begin
    v_typleave       		  := nvl(hcm_util.get_string_t(obj_data, 'typleave'), '');
    v_desc_typleave       := nvl(hcm_util.get_string_t(obj_data, 'desc_typleave'), ' ');
    v_qtydlepery       		:= nvl(hcm_util.get_string_t(obj_data, 'qtydlepery'), '');
    v_qtydlepay      			:= nvl(hcm_util.get_string_t(obj_data, 'qtydlepay'), '');
    v_flgdlemx        	  := nvl(get_tlistval_name('LVLIMIT',hcm_util.get_string_t(obj_data, 'flgdlemx'),global_v_lang), ' ');
    v_flgtype        			:= nvl(get_tlistval_name('GRPLEAVE',hcm_util.get_string_t(obj_data, 'flgtype'),global_v_lang), ' ');
    v_qtytimle        		:= nvl(hcm_util.get_string_t(obj_data, 'qtytimle'), '');
    v_flgtimle        	  := nvl(get_tlistval_name('LVCOUNT',hcm_util.get_string_t(obj_data, 'flgtimle'),global_v_lang), ' ');
    v_daylevst        	  := nvl(hcm_util.get_string_t(obj_data, 'daylevst'), '');
    v_mthlevst        	  := nvl(get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_data, 'mthlevst'),global_v_lang), ' ');
    v_dayleven        	  := nvl(hcm_util.get_string_t(obj_data, 'dayleven'), '');
    v_mthleven        	  := nvl(get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_data, 'mthleven'),global_v_lang), ' ');
    v_flgwkcal        	  := nvl(get_tlistval_name('LVCOND',hcm_util.get_string_t(obj_data, 'flgwkcal'),global_v_lang), ' ');
    v_pctded        	    := nvl(hcm_util.get_string_t(obj_data, 'pctded'), '');
    v_codlvprgnt        	:= nvl(hcm_util.get_string_t(obj_data, 'codlvprgnt'), '');
    v_desc_codlvprgnt     := nvl(get_tleavecd_name(v_codlvprgnt,global_v_lang), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;

    v_desc_codpay := hcm_util.get_string_t(obj_data, 'codpay');
    if v_desc_codpay is not null then
      v_desc_codpay := v_desc_codpay || ' - ' || hcm_util.get_string_t(obj_data, 'desc_codpay');
    else
      v_desc_codpay := '-';
    end if;

    v_flgchol := nvl(hcm_util.get_string_t(obj_data, 'flgchol'), ' ');
    if v_flgchol = 'Y' then
      v_flgchol := get_label_name('HRAL11E2', global_v_lang, '110');
    elsif v_flgchol = 'N' then
      v_flgchol := get_label_name('HRAL11E2', global_v_lang, '120');
    end if;

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4,item5, item6, item7, item8, item9, item10, item11, item12, item13,
             item14, item15, item16, item17, item18
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
            v_typleave,
            v_typleave || ' - ' || v_desc_typleave,
            v_desc_typleave,
            v_qtydlepery,
            v_qtydlepay,
            v_flgdlemx,
            v_flgtype,
            v_qtytimle,
            v_flgtimle,
            v_daylevst,
            v_mthlevst,
            v_dayleven,
            v_mthleven,
            v_flgchol,
            v_flgwkcal,
            v_desc_codpay,
            v_pctded,
            v_codlvprgnt || '-' || v_desc_codlvprgnt
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_detail;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_typleave          varchar2(1000 char) := '';
    v_codleave          varchar2(1000 char) := '';
    v_desc_codleave    	varchar2(1000 char) := '';
    v_numseq_       		varchar2(1000 char) := '';
  begin
    v_typleave       		  := nvl(hcm_util.get_string_t(obj_data, 'typleave'), '');
    v_codleave       		  := nvl(hcm_util.get_string_t(obj_data, 'codleave'), '');
    v_desc_codleave       := nvl(hcm_util.get_string_t(obj_data, 'desc_codleave'), '');
    v_numseq_      				:= nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1, item2, item3, item4
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
            v_typleave,
            v_codleave,
            v_desc_codleave,
            v_numseq_
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_table;

end HRAL11E;

/
