--------------------------------------------------------
--  DDL for Package Body HRBF47E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF47E" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codobf            := hcm_util.get_string_t(json_obj, 'p_codobf');
    p_dteyre            := to_number(hcm_util.get_number_t(json_obj, 'p_dteyre'));
    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    -- save
    p_warning           := hcm_util.get_string_t(json_obj, 'p_warning');
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_staemp            temploy1.staemp%type;
  begin
    if p_codempid_query is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid_query, 'staemp');
      if v_staemp is not null then
        if not secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  function check_statement (v_syncond tobfcde.syncond%type, v_table varchar2 default 'TEMPLOY1') return boolean AS
    v_flgfound        boolean := false;
    v_statment        varchar2(1000 char);
    v_staemp          temploy1.staemp%type;
    v_codcomp         temploy1.codcomp%type;
    v_codpos          temploy1.codpos%type;
    v_numlvl          temploy1.numlvl%type;
    v_codjob          temploy1.codjob%type;
    v_codempmt        temploy1.codempmt%type;
    v_typemp          temploy1.typemp%type;
    v_typpayroll      temploy1.typpayroll%type;
    v_codbrlc         temploy1.codbrlc%type;
    v_codcalen        temploy1.codcalen%type;
    v_jobgrade        temploy1.jobgrade%type;
    v_codgrpgl        temploy1.codgrpgl%type;
    v_dteeffec        ttmovemt.dteeffec%type;
    v_amthour         number;
    v_amtday          number;
    v_amtmth          number;

  begin
    if v_syncond is not null then
      v_flgfound        := false;
      v_dteeffec        := '31/12/' || p_dteyre;
      
      begin
        select staemp, codcomp, codpos, numlvl, codjob, codempmt, typemp, typpayroll, codbrlc, codcalen, jobgrade, codgrpgl
          into v_staemp, v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl
          from temploy1
         where codempid = p_codempid_query;
      exception when no_data_found then
        null;
      end;
      std_al.get_movemt (p_codempid_query, v_dteeffec, 'C', 'U',
                         v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl,
                         v_amthour, v_amtday, v_amtmth);
      v_statment := v_syncond;
      v_statment := replace(v_statment, v_table || '.STAEMP','''' || v_staemp || '''');
      v_statment := replace(v_statment, v_table || '.CODCOMP','''' || v_codcomp || '''');
      v_statment := replace(v_statment, v_table || '.CODPOS','''' || v_codpos || '''');
      v_statment := replace(v_statment, v_table || '.NUMLVL', v_numlvl);
      v_statment := replace(v_statment, v_table || '.CODJOB','''' || v_codjob || '''');
      v_statment := replace(v_statment, v_table || '.CODEMPMT','''' || v_codempmt || '''');
      v_statment := replace(v_statment, v_table || '.TYPEMP','''' || v_typemp || '''');
      v_statment := replace(v_statment, v_table || '.TYPPAYROLL','''' || v_typpayroll || '''');
      v_statment := replace(v_statment, v_table || '.CODBRLC','''' || v_codbrlc || '''');
      v_statment := replace(v_statment, v_table || '.CODCALEN','''' || v_codcalen || '''');
      v_statment := replace(v_statment, v_table || '.JOBGRADE','''' || v_jobgrade || '''');
      v_statment := replace(v_statment, v_table || '.CODGRPGL','''' || v_codgrpgl || '''');
      v_statment := 'select count(*) from dual where ' || v_statment;
      v_flgfound := execute_stmt(v_statment);
      return v_flgfound;
    end if;
    return true;
  end check_statement;

  procedure find_tobfcft (v_dtestart out tobfcft.dtestart%type, v_amtalwyr out tobfcft.amtalwyr%type) AS
  begin
    begin
      select dtestart, amtalwyr
        into v_dtestart, v_amtalwyr
        from tobfcft
        where codempid = p_codempid_query
          and dtestart >= to_date('01/01/' || p_dteyre, 'DD/MM/YYYY')
          and (dteend  <= to_date('31/12/' || p_dteyre, 'DD/MM/YYYY')
              or dteend is null
            )
        order by dtestart desc
        fetch first 1 rows only;
    exception when no_data_found then
      null;
    end;
  end find_tobfcft;

  procedure find_tobfcftd (
    v_dtestart in tobfcftd.dtestart%type,
    v_codobf   in tobfcftd.codobf%type,
    v_found    out boolean,
    v_qtyalw   in out tobfcftd.qtyalw%type,
    v_qtytalw  in out tobfcftd.qtytalw%type,
    v_flglimit in out tobfcftd.flglimit%type,
    v_amtvalue in out tobfcftd.amtvalue%type
  ) AS
  begin
    begin
      select qtyalw, qtytalw, flglimit, amtvalue
        into v_qtyalw, v_qtytalw, v_flglimit, v_amtvalue
        from tobfcftd
       where codempid = p_codempid_query
         and dtestart = v_dtestart
         and codobf   = v_codobf;
      v_found       := true;
    exception when no_data_found then
      v_found       := false;
    end;
  end find_tobfcftd;

  procedure find_tobfcdet (
    v_codobf      tobfcdet.codobf%type,
    v_data_found  out boolean,
    v_qtyalw      in out tobfcftd.qtyalw%type,
    v_qtytalw     in out tobfcftd.qtytalw%type
  ) AS
    cursor c1 is
      select qtyalw, qtytalw, syncond
        from tobfcdet
       where codobf = v_codobf
       order by numobf asc;
  begin
    for i in c1 loop
      if check_statement(i.syncond, 'V_HRBF41') then
        v_qtyalw      := i.qtyalw;
        v_qtytalw     := i.qtytalw;
        v_data_found  := true;
        exit;
      else
        v_data_found  := false;
      end if;
    end loop;
  end find_tobfcdet;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_dtestart          tobfcft.dtestart%type;
    v_amtalwyr          tobfcft.amtalwyr%type := 0;
    v_typrelate         tobfcde.typrelate%type;
    v_qtyalw            tobfcftd.qtyalw%type;
    v_qtytalw           tobfcftd.qtytalw%type;
    v_desc_qtyalw       varchar2(100 char);
    v_flglimit          tobfcftd.flglimit%type;
    v_amtvalue          tobfcftd.amtvalue%type;
    v_remain            varchar2(100 char);
    v_data_found        boolean := false;
    
    v_total_qtywidrw    number := 0;
    v_total_qtytwidrw   number := 0;
    
    v_sum_qtywidrw      number := 0;
    v_sum_qtytwidrw     number := 0;

    cursor c1 is
     select a.codempid, a.dteyre, a.dtemth, a.codobf, a.qtywidrw, a.qtytwidrw, a.amtwidrw, a.qtyalw, a.qtytalw, a.dtelwidrw,
            b.typebf typepay, ----b.typepay
            b.syncond, b.dtestart, b.dteend, b.flglimit, b.amtvalue
       from tobfsum a, tobfcde b
      where a.codobf   = b.codobf(+)
        and a.codempid = p_codempid_query
        and a.dteyre   = p_dteyre
        and a.dtemth   <> 13
        and a.codobf = p_codobf
      order by codobf;
      
  begin
    obj_rows    := json_object_t();
    
    find_tobfcft(v_dtestart, v_amtalwyr);
    
    for i in c1 loop
      if param_msg_error is null then
        v_data_found      := false;
        v_qtyalw          := i.qtyalw;
        v_qtytalw         := i.qtytalw;
        v_flglimit        := 0;
        v_amtvalue        := 0;
        
        -- check data start
        if v_dtestart is not null then
          if check_statement(i.syncond, 'V_HRBF41') then
            find_tobfcftd(v_dtestart, i.codobf, v_data_found, v_qtyalw, v_qtytalw, v_flglimit, v_amtvalue);
          end if;
        end if;
        
        if not v_data_found then
          if trunc(i.dtestart) <= to_date('31/12/' || p_dteyre, 'DD/MM/YYYY') then
          ----if trunc(i.dtestart) >= to_date('01/01/' || p_dteyre, 'DD/MM/YYYY') and trunc(i.dteend) <= to_date('31/12/' || p_dteyre, 'DD/MM/YYYY') then
            if check_statement(i.syncond, 'V_HRBF41') then
              find_tobfcdet(i.codobf, v_data_found, v_qtyalw, v_qtytalw);
              v_flglimit        := i.flglimit;
              v_amtvalue        := i.amtvalue;
            end if;
          end if;
        end if;
        -- check data end
        
        v_rcnt        := v_rcnt + 1;
        obj_data      := json_object_t();
        v_remain      := to_char(v_qtyalw - i.qtywidrw);
        v_desc_qtyalw := to_char(v_qtyalw);
        
        if i.typepay = 'C' then
          v_desc_qtyalw := to_char(v_qtyalw, 'fm99,999,990.90');
          v_remain      := to_char(v_remain, 'fm99,999,990.90');
        end if;
        
        obj_data.put('coderror', '200');
        obj_data.put('codempid', p_codempid_query);
        obj_data.put('dteyre', p_dteyre);
        obj_data.put('codobf', i.codobf);
        obj_data.put('desc_codobf', get_tobfcde_name(i.codobf, global_v_lang));
        obj_data.put('typepay', i.typepay);
        obj_data.put('inputType', i.typepay);
        obj_data.put('dtemth', i.dtemth);
        obj_data.put('desc_dtemth', get_nammthful(i.dtemth, global_v_lang));
        
        obj_data.put('desc_flglimit', get_tlistval_name('TYPELIMIT', i.flglimit, global_v_lang));
        obj_data.put('qtyalw', v_qtyalw);
        obj_data.put('desc_qtyalw', v_desc_qtyalw);
        obj_data.put('qtywidrw', i.qtywidrw);
        obj_data.put('remain', v_remain);
        obj_data.put('qtytalw', v_qtytalw);
        obj_data.put('qtytwidrw', i.qtytwidrw);
        obj_data.put('amtvalue', v_amtvalue);              
        obj_rows.put(to_char(v_rcnt - 1), obj_data);
        
        v_total_qtywidrw := v_total_qtywidrw + i.qtywidrw;
        v_total_qtytwidrw := v_total_qtytwidrw + i.qtytwidrw;
      end if;
    end loop;
    
    --> Summary Selected Years
    v_rcnt := v_rcnt + 1;
    obj_data      := json_object_t();
    obj_data.put('desc_flglimit', '');
    obj_data.put('desc_dtemth', 'รวมทั้งปี');
    obj_data.put('qtywidrw', to_char(v_total_qtywidrw));
    obj_data.put('qtytwidrw', to_char(v_total_qtytwidrw));
    obj_data.put('inputType', 'S');
    obj_rows.put(to_char(v_rcnt - 1), obj_data);
    
    --> Summary All Years
    begin
      select sum(qtywidrw), sum(qtytwidrw)
        into v_sum_qtywidrw, v_sum_qtytwidrw
         from tobfsum a
        where a.codempid = p_codempid_query
          and a.dtemth   = 13
          and a.codobf   = p_codobf;
    end;
    
    v_rcnt := v_rcnt + 1;
    obj_data      := json_object_t();
    obj_data.put('desc_flglimit', '');
    obj_data.put('desc_dtemth', 'รวมตลอดอายุงาน');
    obj_data.put('qtywidrw', to_char(v_sum_qtywidrw));
    obj_data.put('qtytwidrw', to_char(v_sum_qtytwidrw));
    obj_data.put('inputType', 'S');
    obj_rows.put(to_char(v_rcnt - 1), obj_data);
    
    if param_msg_error is null then
      if v_rcnt > 0 then
        json_str_output := obj_rows.to_clob;
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobfsum');
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end gen_index;

  procedure get_tobfcft (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tobfcft(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tobfcft;

  procedure gen_tobfcft (json_str_output out clob) AS
    obj_data            json_object_t;
    v_dtestart          tobfcft.dtestart%type;
    v_amtalwyr          tobfcft.amtalwyr%type;
    v_amtwidrw          tobfsum.amtwidrw%type := 0;
    v_codcomp           temploy1.codcomp%type;
    v_codcompy          tobfbgyr.codcompy%type;

    cursor c1 is
      select numseq, syncond, amtalwyr
        from tobfbgyr
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                           from tobfbgyr
                          where codcompy = v_codcompy
                            and trunc(dteeffec) <= trunc(to_date('31/12/' || p_dteyre, 'DD/MM/YYYY')))
       order by numseq;
  begin
    v_codcomp           := hcm_util.get_temploy_field(p_codempid_query, 'codcomp');
    v_codcompy          := hcm_util.get_codcomp_level(v_codcomp, 1);
    
    find_tobfcft(v_dtestart, v_amtalwyr);
    
    if v_amtalwyr is null then
      for i in c1 loop
        if check_statement(i.syncond, 'V_HRBF41') then
          v_amtalwyr    := i.amtalwyr;
          exit;
        end if;
      end loop;
    end if;
    
    begin
     select sum(amtwidrw)
       into v_amtwidrw
       from tobfsum
      where codempid = p_codempid_query
        and dteyre   = p_dteyre
        and dtemth   = 13
      order by codobf;
    exception when no_data_found then
      null;
    end;
    
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid_query);
    obj_data.put('dteyre', p_dteyre);
    obj_data.put('amtalwyr', v_amtalwyr);
    obj_data.put('remain', (v_amtalwyr - v_amtwidrw));
    json_str_output := obj_data.to_clob;
  end gen_tobfcft;

  procedure save_tobflog (v_fldedit varchar2, v_dtemth varchar2, v_desold varchar2, v_desnew varchar2) AS
  begin
    
    begin
      insert into tobflog
             (codempid, dteyre, dtemth, codobf, fldedit, desold, desnew, dtecreate, coduser)
      values (p_codempid_query, p_dteyre, v_dtemth, p_codobf, v_fldedit, v_desold, v_desnew, sysdate, global_v_coduser);
    exception when dup_val_on_index then
      update tobflog
         set desold   = v_desold,
             desnew   = v_desnew,
             dteupd   = sysdate,
             coduser  = global_v_coduser
       where codempid = p_codempid_query
         and dteyre   = p_dteyre
         and dtemth   = v_dtemth
         and codobf   = p_codobf
         and fldedit  = v_fldedit;
    end;
  end save_tobflog;

--  procedure check_save_log AS
--    v_codempid                tobfsum.codempid%type;
--    v_dteyre                  tobfsum.dteyre%type;
--    v_codobf                  tobfsum.codobf%type;
--    v_dtemth                  tobfsum.dtemth%type;
--    v_qtytwidrw               tobfsum.qtytwidrw%type;
--    v_qtywidrw                tobfsum.qtywidrw%type;
--    v_amtwidrw                tobfsum.amtwidrw%type;
--    v_qtyalw                  tobfsum.qtyalw%type;
--    v_qtytalw                 tobfsum.qtytalw%type;
--    
--  begin
--    begin
--      select codempid, dteyre, codobf, dtemth, qtytwidrw, qtywidrw, amtwidrw, qtyalw, qtytalw
--        into v_codempid, v_dteyre, v_codobf, v_dtemth, v_qtytwidrw, v_qtywidrw, v_amtwidrw, v_qtyalw, v_qtytalw
--        from tobfsum
--       where codempid  = p_codempid_query
--         and dteyre    = p_dteyre
--         and codobf    = p_codobf
--         and dtemth    = 13;
--    exception when no_data_found then
--      null;
--    end;
--    /*----if nvl(v_codempid, '@#$%') <> nvl(p_codempid_query, '@#$%') then
--      save_tobflog('codempid', v_codempid, p_codempid_query);
--    end if;
--    if nvl(v_dteyre, 0) <> nvl(p_dteyre, 0) then
--      save_tobflog('dteyre', v_dteyre, p_dteyre);
--    end if;
--    if nvl(v_codobf, '@#$%') <> nvl(p_codobf, '@#$%') then
--      save_tobflog('codobf', v_codobf, p_codobf);
--    end if;
--    if nvl(v_dtemth, 0) <> 13 then
--      save_tobflog('dtemth', v_dtemth, 13);
--    end if;*/
--    if nvl(v_qtytwidrw, 0) <> nvl(p_qtytwidrw, 0) then
--      save_tobflog('qtytwidrw', v_qtytwidrw, p_qtytwidrw);
--    end if;
--    
--    if nvl(v_qtywidrw, 0) <> nvl(p_qtywidrw, 0) then
--      if p_typepay = 'C' then
--        save_tobflog('qtywidrw', to_char(v_qtywidrw, 'fm99,999,990.90'), to_char(p_qtywidrw, 'fm99,999,990.90'));
--      else
--        save_tobflog('qtywidrw', v_qtywidrw, p_qtywidrw);
--      end if;
--    end if;
--    /*----if nvl(v_amtwidrw, 0) <> nvl(p_amtwidrw, 0) then
--      save_tobflog('amtwidrw', to_char(v_amtwidrw, 'fm99,999,990.90'), to_char(p_amtwidrw, 'fm99,999,990.90'));
--    end if;
--    if nvl(v_qtyalw, 0) <> nvl(p_qtyalw, 0) then
--      save_tobflog('qtyalw', v_qtyalw, p_qtyalw);
--    end if;
--    if nvl(v_qtytalw, 0) <> nvl(p_qtytalw, 0) then
--      save_tobflog('qtytalw', v_qtytalw, p_qtytalw);
--    end if;*/
--  end check_save_log;

--  procedure save_tobfsum AS
--  begin
--    if p_typepay = 'T' then
--      p_amtwidrw    := p_amtvalue * p_qtywidrw;
--    elsif p_typepay = 'C' then
--      p_amtwidrw    := p_qtywidrw;
--    end if;
--    
--    check_save_log;
--    
--    if param_msg_error is null then
--      begin
--        insert into tobfsum
--                (codempid, dteyre, codobf, dtemth, qtytwidrw, qtywidrw, amtwidrw, qtyalw, qtytalw, dtecreate, codcreate)
--        values (p_codempid_query, p_dteyre, p_codobf, 13, p_qtytwidrw, p_qtywidrw, p_amtwidrw, p_qtyalw, p_qtytalw, sysdate, global_v_coduser);
--      exception when dup_val_on_index then
--        update tobfsum
--            set qtytwidrw = p_qtytwidrw,
--                qtywidrw  = p_qtywidrw,
--                amtwidrw  = p_amtwidrw,
--                qtyalw    = p_qtyalw,
--                qtytalw   = p_qtytalw,
--                dteupd    = sysdate,
--                coduser   = global_v_coduser
--          where codempid  = p_codempid_query
--            and dteyre    = p_dteyre
--            and codobf    = p_codobf
--            and dtemth    = 13;
--      end;
--    end if;
--  end save_tobfsum;    
  
  procedure save_tobfsum_per_month AS
  begin
    if p_typepay = 'T' then
      p_amtwidrw    := p_amtvalue * p_qtywidrw;
    elsif p_typepay = 'C' then
      p_amtwidrw    := p_qtywidrw;
    end if;
    
    
    
    if param_msg_error is null then
      begin
        insert into tobfsum
                (codempid, dteyre, codobf, dtemth, qtytwidrw, qtywidrw, amtwidrw, qtyalw, qtytalw, dtecreate, codcreate)
        values (p_codempid_query, p_dteyre, p_codobf, p_dtemth, p_qtytwidrw, p_qtywidrw, p_amtwidrw, p_qtyalw, p_qtytalw, sysdate, global_v_coduser);
      exception when dup_val_on_index then
        update tobfsum
            set qtytwidrw = p_qtytwidrw,
                qtywidrw  = p_qtywidrw,
                amtwidrw  = p_amtwidrw,
                qtyalw    = p_qtyalw,
                qtytalw   = p_qtytalw,
                dteupd    = sysdate,
                coduser   = global_v_coduser
          where codempid  = p_codempid_query
            and dteyre    = p_dteyre
            and codobf    = p_codobf
            and dtemth    = p_dtemth;
      end;
    end if;
  end save_tobfsum_per_month;
  
  procedure save_tobfsum_per_year AS
    v_sum_qtywidrw      number := 0;
    v_sum_qtytwidrw     number := 0;
    v_sum_amtwidrw      number := 0;
    v_sum_qtyalw        number := 0;
    v_sum_qtytalw       number := 0;
    
  begin
    if p_typepay = 'T' then
      p_amtwidrw    := p_amtvalue * p_qtywidrw;
    elsif p_typepay = 'C' then
      p_amtwidrw    := p_qtywidrw;
    end if;
    
    if p_qtywidrw <> p_qtywidrwOld then
        save_tobflog ('qtywidrw', p_dtemth, p_qtywidrwOld, p_qtywidrw);
      end if;
      
      if p_qtytwidrw <> p_qtytwidrwOld then
        save_tobflog ('qtytwidrw', p_dtemth, p_qtytwidrwOld, p_qtytwidrw);
      end if;          
      --> Check Save TOBFLOG

    begin
      select sum(qtywidrw), sum(qtytwidrw), sum(amtwidrw), sum(qtyalw), sum(qtytalw)
        into v_sum_qtywidrw, v_sum_qtytwidrw, v_sum_amtwidrw, v_sum_qtyalw, v_sum_qtytalw
        from tobfsum a
       where a.codempid = p_codempid_query
         and a.dteyre = p_dteyre
         and a.dtemth <> 13
         and a.codobf = p_codobf;
    exception when no_data_found then
      v_sum_qtywidrw := 0;
      v_sum_qtytwidrw := 0;
      v_sum_amtwidrw := 0;
      v_sum_qtyalw := 0;
      v_sum_qtytalw := 0;
    end;
    
--    check_save_log;
    
    if param_msg_error is null then
      begin
        update tobfsum
          set dtemth        = 13,
              qtywidrw      = v_sum_qtywidrw,
              qtytwidrw     = v_sum_qtytwidrw,
              amtwidrw      = amtwidrw,
              qtyalw        = v_sum_qtyalw,
              qtytalw       = qtytalw,
              dteupd        = sysdate,
              coduser       = global_v_coduser
          where codempid  = p_codempid_query
            and dteyre    = p_dteyre
            and codobf    = p_codobf
            and dtemth    = 13;
      end;
    end if;
  end save_tobfsum_per_year;

  procedure check_save AS
    v_staemp            temploy1.staemp%type;
  begin
    if p_codempid_query is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid_query, 'staemp');
      if v_staemp is not null then
        if not secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_save;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    obj_tmp             json_object_t;
    
    v_sum_qtywidrw_old     number := 0;
    v_sum_qtytwidrw_old    number := 0;
    
    v_sum_qtywidrw_new      number := 0;
    v_sum_qtytwidrw_new     number := 0;
    
  begin
    initial_value(json_str_input);
    
    --> Select Sum For Old Data
    begin
      select sum(qtywidrw), sum(qtytwidrw)
        into v_sum_qtywidrw_old, v_sum_qtytwidrw_old
        from tobfsum a
       where a.codempid = p_codempid_query
         and a.dteyre = p_dteyre
         and a.dtemth = 13
         and a.codobf = p_codobf;
    exception when others then
      v_sum_qtywidrw_old := 0;
      v_sum_qtytwidrw_old := 0;
    end;
    --> Select Sum For Old Data
    
    for i in 0 .. json_params.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(json_params, to_char(i));
      
      if param_msg_error is null then
        p_codobf          := hcm_util.get_string_t(obj_data, 'codobf');
        p_qtytwidrw       := to_number(hcm_util.get_number_t(obj_data, 'qtytwidrw'));
        p_qtytwidrwOld    := to_number(hcm_util.get_number_t(obj_data, 'qtytwidrwOld'));
        
        p_qtywidrw        := to_number(hcm_util.get_number_t(obj_data, 'qtywidrw'));
        p_qtywidrwOld     := to_number(hcm_util.get_number_t(obj_data, 'qtywidrwOld'));
        p_amtvalue        := nvl(to_number(hcm_util.get_number_t(obj_data, 'amtvalue')), 0);
        p_typepay         := hcm_util.get_string_t(obj_data, 'typepay');
        p_qtyalw          := to_number(hcm_util.get_number_t(obj_data, 'qtyalw'));
        p_qtytalw         := to_number(hcm_util.get_number_t(obj_data, 'qtytalw'));
        p_dtemth          := to_number(hcm_util.get_number_t(obj_data, 'dtemth'));
        
        --> Check Save TOBFLOG
        if p_qtywidrw <> p_qtywidrwOld then
          save_tobflog ('qtywidrw', p_dtemth, p_qtywidrwOld, p_qtywidrw);
        end if;
        
        if p_qtytwidrw <> p_qtytwidrwOld then
          save_tobflog ('qtytwidrw', p_dtemth, p_qtytwidrwOld, p_qtytwidrw);
        end if;          
        --> Check Save TOBFLOG
        
        check_save;
        
        if p_warning is null then
          if param_msg_error is null then
            if p_qtywidrw > p_qtyalw then
              param_msg_error := get_error_msg_php('BF0053', global_v_lang);
              p_warning       := 'W';
            end if;
          end if;
          
          if param_msg_error is null then
            if p_qtytwidrw > p_qtytalw then
              param_msg_error := get_error_msg_php('BF0054', global_v_lang);
              p_warning       := 'W';
            end if;
          end if;
        end if;
        
        if param_msg_error is null then
          save_tobfsum_per_month;
        end if;
        
--        if param_msg_error is null then
--          save_tobfsum;
--        end if;
      end if;
    end loop;
    
    if param_msg_error is null then
      save_tobfsum_per_year;
    end if;
    
    --> Select Sum For New Data
    begin
      select sum(qtywidrw), sum(qtytwidrw)
        into v_sum_qtywidrw_new, v_sum_qtytwidrw_new
        from tobfsum a
       where a.codempid = p_codempid_query
         and a.dteyre = p_dteyre
         and a.dtemth = 13
         and a.codobf = p_codobf;
    exception when no_data_found then
      v_sum_qtywidrw_new := 0;
      v_sum_qtytwidrw_new := 0;
    end;
    
    --> Select Sum For New Data
    --> Check Save TOBFLOG
      if v_sum_qtywidrw_old <> v_sum_qtywidrw_new then
        save_tobflog ('qtywidrw', '13', v_sum_qtywidrw_old, v_sum_qtywidrw_new);
      end if;
      
      if v_sum_qtytwidrw_old <> v_sum_qtytwidrw_new then
        save_tobflog ('qtytwidrw', '13', v_sum_qtytwidrw_old, v_sum_qtytwidrw_new);
      end if;          
      --> Check Save TOBFLOG
        
    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      if p_warning = 'W' then
        rollback;
        obj_tmp         := json_object_t(get_response_message('200', param_msg_error, global_v_lang));
        obj_tmp.put('warning', p_warning);
        json_str_output := obj_tmp.to_clob;
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;
end HRBF47E;

/
