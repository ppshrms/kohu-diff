--------------------------------------------------------
--  DDL for Package Body HRPY2EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2EE" is
-- last update: 14/04/2018 16:15
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
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid'));
    p_codpay            := upper(hcm_util.get_string_t(json_obj, 'p_codpay'));
    -- save
    json_params         := hcm_util.get_json_t(json_obj, 'params');
    p_flgimport         := upper(hcm_util.get_string_t(json_obj, 'flgimport'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_staemp          temploy1.staemp%type;
    v_codcomp         temploy1.codcomp%type;
  begin
    if p_codempid is not null then
      begin
        select staemp, codcomp
          into v_staemp, v_codcomp
          from temploy1
          where codempid = p_codempid;
        if v_staemp = 0 then
          param_msg_error := get_error_msg_php('HR2102', global_v_lang);
          return;
        end if;
        p_codcompy := hcm_util.get_codcomp_level(v_codcomp, 1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,global_v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure check_import(v_codempid_imprt varchar2) is
    v_staemp          temploy1.staemp%type;
    v_codcomp         temploy1.codcomp%type;
  begin
    if v_codempid_imprt is not null then
      begin
        select staemp, codcomp
          into v_staemp, v_codcomp
          from temploy1
          where codempid = v_codempid_imprt;
        if v_staemp = 0 then
          param_msg_error := get_error_msg_php('HR2102', global_v_lang);
          return;
        end if;
        p_codcompy := hcm_util.get_codcomp_level(v_codcomp, 1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(v_codempid_imprt,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,global_v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end;
  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index (json_str_output);
    else
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_desc_flgprort     varchar2(100 char);
    v_rcnt              number := 0;
--2000
    v_count	    	    number := 0;
    v_flgsecu           boolean := false;
    v_secur             boolean := false;
    v_zupdsal	        varchar2(30);
    v_codcompy          temploy1.codcomp%type;
    v_typpayroll        temploy1.typpayroll%type;
    v_flgcal            tdtepay.flgcal%type := 'N';
    v_next_flgcal       tdtepay.flgcal%type := 'N';
    
    v_dteyrepay         tdtepay.dteyrepay%type;
    v_dtemthpay         tdtepay.dtemthpay%type;
    v_numperiod         tdtepay.numperiod%type;
--2000
    -- r1
    cursor c_tempinc is
        select codempid, codpay, dtestrt, dteend, dtecancl,
             amtfix, periodpay, flgprort, dteupd, coduser, codcreate
        from tempinc
        where codempid = p_codempid
        order by codpay, dtestrt;
    -- r2
    cursor c_tdtepay is
        select rownum,flgcal
        from tdtepay
        where codcompy = v_codcompy
            and typpayroll = v_typpayroll
            and dteyrepay >= v_dteyrepay
            and dtemthpay >= v_dtemthpay
            and numperiod >= decode(v_numperiod,'N',0,v_numperiod) --and numperiod >= v_numperiod
            and (rownum <= 2)
        order by dteyrepay,dtemthpay,numperiod;
        
  begin
  
    -- get codcompy & typpayroll
    begin
        select hcm_util.get_codcompy(codcomp),typpayroll 
        into v_codcompy,v_typpayroll
        from temploy1 
        where codempid = p_codempid;
    exception when no_data_found then
        v_codcompy :='';
        v_typpayroll :='';
    end;
    
    obj_row           := json_object_t();
    for r1 in c_tempinc loop
    -- << add surachai | 14/03/2023 | #545
        -- get v_dteyrepay & v_dtemthpay & v_numperiod
         v_numperiod := r1.periodpay ;
        begin
            select dteyrepay,dtemthpay
            into v_dteyrepay,v_dtemthpay
            -- into v_dteyrepay,v_dtemthpay,v_numperiod
            from tdtepay
            where codcompy = v_codcompy
            and typpayroll = v_typpayroll
            and r1.dtestrt between dtestrt and dteend;
        exception when no_data_found then
            v_dteyrepay :='';
            v_dtemthpay :='';
            -- v_numperiod :='';
        end;
        
        -- get v_flgcal
        for r2 in c_tdtepay loop
            if r2.rownum = 1 then
                v_flgcal := r2.flgcal;
            else
                v_next_flgcal := r2.flgcal;
            end if;
        end loop;
    -- >>
--2000
        v_count := v_count + 1;
        v_flgsecu := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
              v_secur := true;
--2000
              v_desc_flgprort := '';
              if r1.flgprort = 'Y' then
                v_desc_flgprort := 'Yes';
              else
                v_desc_flgprort := 'No';
              end if;
              v_rcnt              := v_rcnt + 1;
              obj_data            := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('codpay', r1.codpay);
              obj_data.put('desc_codpay', get_tinexinf_name(r1.codpay, global_v_lang));
              obj_data.put('periodpay', to_char(r1.periodpay));
              obj_data.put('flgform', get_flgform(r1.codpay));
              obj_data.put('flgprort', r1.flgprort);
              obj_data.put('desc_flgprort', v_desc_flgprort);
              obj_data.put('dtestrt', to_char(r1.dtestrt, 'DD/MM/YYYY'));
              obj_data.put('dteend', to_char(r1.dteend, 'DD/MM/YYYY'));
              obj_data.put('amtfix', stddec(r1.amtfix, r1.codempid, v_chken));
              obj_data.put('dtecancl', to_char(r1.dtecancl, 'DD/MM/YYYY'));
              obj_data.put('dteupd', to_char(r1.dteupd, 'DD/MM/YYYY'));
              obj_data.put('coduser', get_temploy_name(get_codempid(nvl(r1.coduser, r1.codcreate)), global_v_lang));
              obj_data.put('sysdate',to_char(sysdate,'dd/mm/yyyy'));
              -- << add surachai | 14/03/2023 | #545
              obj_data.put('flgcal',v_flgcal);
              obj_data.put('next_flgcal',v_next_flgcal);
              -- > 
              obj_row.put(to_char(v_rcnt - 1), obj_data);
--2000
        elsif v_count = 0 then
             param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tempinc');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
        elsif not v_secur then
             param_msg_error := get_error_msg_php('HR3007',global_v_lang);
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
        end if;
--2000
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  function get_flgform (v_codpay varchar2) return varchar2 is
    v_flgform            tinexinf.flgform%type;
  begin
    begin
      select flgform
        into v_flgform
        from tinexinf
       where codpay = v_codpay;
    exception when no_data_found then
      null;
    end;
    return v_flgform;
  end get_flgform;

  procedure get_descpay (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
    v_codtax            ttaxtab.codtax%type;
    v_formula           tformula.formula%type;
    v_desc_codtax       varchar2(4000 char) := '-';
    v_desc_formula      varchar2(4000 char) := '-';

  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      check_codpay(p_codpay);
    end if;
    if param_msg_error is null then
      begin
        select codtax
          into v_codtax
          from ttaxtab
         where codpay = p_codpay;
      exception when no_data_found then
        v_codtax := null;
      end;
      begin
        select formula
          into v_formula
          from tformula
         where codpay   = p_codpay
           and dteeffec = (select max(dteeffec)
                             from tformula
                            where codpay    = p_codpay
                              and dteeffec <= trunc(sysdate));
      exception when no_data_found then
        v_formula := null;
      end;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codpay', p_codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(p_codpay, global_v_lang));
      obj_data.put('flgform', get_flgform(p_codpay));
      obj_data.put('codtax', v_codtax);
      if v_codtax is not null then
        v_desc_codtax := get_tinexinf_name(v_codtax, global_v_lang);
      end if;
      obj_data.put('desc_codtax', v_desc_codtax);
      obj_data.put('formula', v_formula);
      if v_formula is not null then
        v_desc_formula := get_formula_name(v_formula);
      end if;
      obj_data.put('desc_formula', v_desc_formula);
    end if;

    if param_msg_error is not null then
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_data.to_clob;
    end if;
  end get_descpay;

  procedure check_codpay (b_codpay in varchar2) is
    v_codpay              tinexinf.codpay%type;
    v_codincom1           tcontpms.codincom1%type;
    v_codincom2           tcontpms.codincom2%type;
    v_codincom3           tcontpms.codincom3%type;
    v_codincom4           tcontpms.codincom4%type;
    v_codincom5           tcontpms.codincom5%type;
    v_codincom6           tcontpms.codincom6%type;
    v_codincom7           tcontpms.codincom7%type;
    v_codincom8           tcontpms.codincom8%type;
    v_codincom9           tcontpms.codincom9%type;
    v_codincom10          tcontpms.codincom10%type;

  begin
    if b_codpay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, null, null, p_flgdisp_err_table);
      return;
    end if;
    begin
      select codpay
        into v_codpay
        from tinexinf
       where codpay   = b_codpay;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf', null, p_flgdisp_err_table);
      return;
    end;
    begin
      select codpay
        into v_codpay
        from tinexinfc
       where codcompy = p_codcompy
         and codpay   = b_codpay;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('PY0044', global_v_lang, null, null, p_flgdisp_err_table);
      return;
    end;
    begin
      select codincom1, codincom2, codincom3, codincom4, codincom5,
             codincom6, codincom7, codincom8, codincom9, codincom10
        into v_codincom1, v_codincom2, v_codincom3, v_codincom4, v_codincom5,
             v_codincom6, v_codincom7, v_codincom8, v_codincom9, v_codincom10
        from tcontpms
       where codcompy = p_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy  = p_codcompy
                            and dteeffec <= trunc(sysdate))
         and (
           codincom1 = b_codpay
           or codincom2 = b_codpay
           or codincom3 = b_codpay
           or codincom4 = b_codpay
           or codincom5 = b_codpay
           or codincom6 = b_codpay
           or codincom7 = b_codpay
           or codincom8 = b_codpay
           or codincom9 = b_codpay
           or codincom10 = b_codpay
         );
      param_msg_error := get_error_msg_php('PY0043', global_v_lang, null, null, p_flgdisp_err_table);
      return;
    exception when no_data_found then
      null;
    end;
  end check_codpay;

  function get_formula_name(v_formula varchar2) return varchar2 is
    v_stmt    varchar2(4000) := v_formula;
    v_chk     number := 0 ;
    cursor c1 is
      select codpay
        from tinexinf
    order by codpay;

  begin
    v_chk  := instr(v_stmt, '&');
    if v_chk <> 0 then
      for i in c1 loop
        v_stmt := replace(v_stmt, '&' || i.codpay, get_tinexinf_name(i.codpay, global_v_lang));
      end loop;
    end if;
    return v_stmt;
  end;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_obj            json_object_t;
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        if param_msg_error is null then
          json_obj           := hcm_util.get_json_t(json_params, to_char(i));
          save_tempinc(json_obj);
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  procedure save_tempinc (json_obj in json_object_t) is
    v_flg             varchar2(100 char)  := null;
    v_codpay          tempinc.codpay%type := null;
    v_periodpay       tempinc.periodpay%type := null;
    v_flgprort        tempinc.flgprort%type := null;
    v_dtestrt         tempinc.dtestrt%type;
    v_dteend          tempinc.dteend%type;
    b_dteend          tempinc.dteend%type;
    v_dtecancl        tempinc.dtecancl%type;
    v_amtfix          number:= 0;
    v_codempid_imprt  tempinc.codempid%type := null;
    v_codempid        tempinc.codempid%type := null;
    v_error           varchar2(4000 char) := null;
    chkFlgform        varchar2(1 char)    := null;
--2000
    v_count	    	    number := 0;
    v_flgsecu           boolean := false;
    v_secur             boolean := false;
    v_zupdsal	        varchar2(30);
--2000
  begin

    v_flg             := hcm_util.get_string_t(json_obj, 'flg');
    v_codpay          := hcm_util.get_string_t(json_obj, 'codpay');
    v_codempid_imprt  := hcm_util.get_string_t(json_obj, 'codempid');
    v_dtestrt         := to_date(hcm_util.get_string_t(json_obj, 'dtestrt'), 'dd/mm/yyyy');
    v_dteend          := to_date(hcm_util.get_string_t(json_obj, 'dteend'), 'dd/mm/yyyy');
    v_dtecancl        := to_date(hcm_util.get_string_t(json_obj, 'dtecancl'), 'dd/mm/yyyy');
    v_amtfix          := hcm_util.get_string_t(json_obj, 'amtfix');
    v_periodpay       := hcm_util.get_string_t(json_obj, 'periodpay');
    v_flgprort        := hcm_util.get_string_t(json_obj, 'flgprort');
    p_json_str_row    := v_codempid_imprt || '|' || v_codpay || '|' || to_char(v_dtestrt,'dd/mm/yyyy') || '|' || to_char(v_dteend,'dd/mm/yyyy') || '|' || to_char(v_dtecancl,'dd/mm/yyyy') || '|' || v_amtfix || '|' || v_periodpay || '|' || v_flgprort;

    v_dtestrt         := hcm_util.get_date_excel(v_dtestrt);
    v_dteend          := hcm_util.get_date_excel(v_dteend);
    v_dtecancl        := hcm_util.get_date_excel(v_dtecancl);

    if v_codempid_imprt is not null then
      check_import(v_codempid_imprt);
    end if;
    if v_codempid_imprt is null and nvl(p_flgimport,'N') <> 'Y'then
       v_codempid_imprt := p_codempid;
    end if;

    if v_flg = 'delete' then
      delete from tempinc
       where codempid = v_codempid_imprt
         and codpay   = v_codpay
         and dtestrt  = v_dtestrt;
    else
      if param_msg_error is not null then
        return;
      end if;
      check_codpay(v_codpay);
      if v_codempid_imprt is null then
        v_error         := get_label_name('HRPY2EEC1', global_v_lang, '10');
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, v_error, null, p_flgdisp_err_table);
        return;
      end if;

--2000
      v_flgsecu := secur_main.secur2(v_codempid_imprt,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flgsecu then
         param_msg_error := get_error_msg_php('HR3007',global_v_lang, null, null, p_flgdisp_err_table);
         return;
      end if;-- v_flgsecu then
--2000

      if param_msg_error is null then
        if v_dteend < v_dtestrt then
          param_msg_error := get_error_msg_php('HR2021', global_v_lang, null, null, p_flgdisp_err_table);
          return;
        end if;
        chkFlgform := get_flgform(v_codpay);
        if chkFlgform = 'Y' then
          v_amtfix := null;
        elsif chkFlgform = 'N' then
          if v_amtfix is null or v_amtfix = 0 then
            v_error         := get_label_name('HRPY2EEC1', global_v_lang, '100');
            param_msg_error := get_error_msg_php('HR2045', global_v_lang, v_error, null, p_flgdisp_err_table);
            return;
          elsif v_amtfix < 0 then
            param_msg_error := get_error_msg_php('HR2023', global_v_lang, null, null, p_flgdisp_err_table);
            return;
          end if;
        end if;
        if v_dtecancl is not null then
          if v_dtecancl < v_dtestrt then
            param_msg_error := get_error_msg_php('PY0013', global_v_lang, null, null, p_flgdisp_err_table);
            return;
          end if;
          if v_dtecancl > v_dteend then
            param_msg_error := get_error_msg_php('PY0014', global_v_lang, null, null, p_flgdisp_err_table);
            return;
          end if;
        end if;
        begin
          b_dteend := nvl(nvl((v_dtecancl - 1), v_dteend), to_date('01/01/9999', 'dd/mm/yyyy'));
          select codempid into v_codempid
            from tempinc
           where codempid = v_codempid_imprt
             and codpay   = v_codpay
             and dtestrt  <> v_dtestrt
             and (
              dtestrt between v_dtestrt and b_dteend
              or nvl(nvl((dtecancl - 1), dteend), to_date('01/01/9999', 'dd/mm/yyyy')) between v_dtestrt and b_dteend
              or v_dtestrt between dtestrt and nvl(nvl((dtecancl - 1), dteend), to_date('01/01/9999', 'dd/mm/yyyy'))
              or b_dteend  between dtestrt and nvl(nvl((dtecancl - 1), dteend), to_date('01/01/9999', 'dd/mm/yyyy'))
             )
            and rownum <= 1;

          param_msg_error := get_error_msg_php('PY0007', global_v_lang, null, null, p_flgdisp_err_table);
          return;
        exception when no_data_found then
          null;
        end;
        if v_periodpay is null then
          v_error         := get_label_name('HRPY2EEC1', global_v_lang, '40');
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, v_error, null, p_flgdisp_err_table);
          return;
        else
          if v_periodpay not in ('1','2','3','4','N') then
            v_error         := get_label_name('HRPY2EEC1', global_v_lang, '40');
            param_msg_error := get_error_msg_php('PY0057', global_v_lang, v_error, null, p_flgdisp_err_table);
            return;
          end if;
        end if;
        if v_flgprort is null then
          v_error         := get_label_name('HRPY2EEC1', global_v_lang, '55');
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, v_error, null, p_flgdisp_err_table);
          return;
        end if;

        begin
          insert into tempinc
          (codempid, codpay, periodpay, flgprort, dtestrt, dteend, amtfix, dtecancl, codcreate)
          values
          (v_codempid_imprt, v_codpay, v_periodpay, v_flgprort, v_dtestrt, v_dteend, stdenc(v_amtfix, v_codempid_imprt, v_chken), v_dtecancl, global_v_coduser);
        exception when dup_val_on_index then
          if p_flgimport is null and v_flg = 'add' then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tempinc', null, p_flgdisp_err_table);
            return;
          else
            update tempinc
               set periodpay = v_periodpay,
                   flgprort  = v_flgprort,
                   dteend    = v_dteend,
                   amtfix    = stdenc(v_amtfix, v_codempid_imprt, v_chken),
                   dtecancl  = v_dtecancl,
                   coduser   = global_v_coduser
             where codpay    = v_codpay
               and dtestrt   = v_dtestrt
               and codempid  = v_codempid_imprt;
          end if;
        end;
      end if;
    end if;
  exception when others then
    param_msg_error := get_error_msg_php('HR2508', global_v_lang, null, null, p_flgdisp_err_table);
    p_flgerror := true;
    return;
  end save_tempinc;

  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    json_obj            json_object_t;
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_rec_tran          number := 0;
    v_rec_err           number := 0;
    v_rcnt              number  := 0;
    json_result         json_object_t;

  begin
    p_flgdisp_err_table := false;
    initial_value(json_str_input);
    if param_msg_error is null then
      obj_row    := json_object_t();
      for i in 0..json_params.get_size - 1 loop
        param_msg_error := null;
        json_obj           := hcm_util.get_json_t(json_params, to_char(i));
        save_tempinc(json_obj);
        if param_msg_error is null then
          v_rec_tran        := v_rec_tran + 1;
        elsif p_flgerror then
          exit;
        else
          v_rec_err         := v_rec_err + 1;
          v_rcnt            := v_rcnt + 1;
          json_result       := json_object_t(get_response_message(null, param_msg_error, global_v_lang));
          obj_data          := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_json_str_row);
          obj_data.put('error_code', hcm_util.get_string_t(json_result, 'response'));
          obj_data.put('numseq', i + 1);
          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
      if p_flgerror then
        json_result       := json_object_t(get_response_message('400', get_error_msg_php('HR2508', global_v_lang, null, null, p_flgdisp_err_table), global_v_lang));
        obj_data := json_object_t();
        obj_data.put('coderror', '400');
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response', hcm_util.get_string_t(json_result, 'response'));
--
        obj_result := json_object_t();
        obj_result.put('details', obj_data);
        obj_result.put('table', obj_row);
        rollback;
        json_str_output := obj_result.to_clob;
      else
        json_result       := json_object_t(get_response_message(null, get_error_msg_php('HR2715', global_v_lang, null, null, p_flgdisp_err_table), global_v_lang));
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response', hcm_util.get_string_t(json_result, 'response'));

        obj_result := json_object_t();
        obj_result.put('details', obj_data);
        obj_result.put('table', obj_row);
        commit;
        json_str_output := obj_result.to_clob;
      end if;
    else
      rollback;
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRPY2EE;

/
