--------------------------------------------------------
--  DDL for Package Body HRAL99E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL99E" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_typpayroll  := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_grpcodpay   := hcm_util.get_string_t(json_obj,'p_grpcodpay');
    p_dteyrepay   := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));

    p_codcompyQuery    := hcm_util.get_string_t(json_obj, 'p_codcompyQuery');
    p_typpayrollQuery  := hcm_util.get_string_t(json_obj, 'p_typpayrollQuery');
    p_grpcodpayQuery   := hcm_util.get_string_t(json_obj, 'p_grpcodpayQuery');
    p_dteyrepayQuery   := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepayQuery'));
    forceAdd           := hcm_util.get_string_t(json_obj, 'forceAdd');
    isCopy             := hcm_util.get_string_t(json_obj, 'isCopy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure check_index is
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
      return;
    end if;
--    begin
--      select codcompy into p_codcompy TINEXINFC
--        from tcompny
--       where codcompy = p_codcompy;
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcompy');
--      return;
--    end;
    --:p.desc_codpay2  := get_tinexinf_name(:p.codpay2,:global.v_lang);
    if p_grpcodpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'grpcodpay');
      return;
    end if;
--    begin
--      select codpay into p_grpcodpay
--        from tinexinf
--       where codpay = p_grpcodpay;
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codpay');
--      return;
--    end;
--    begin
--      select codpay into p_grpcodpay
--        from tinexinfc
--       where codpay = p_grpcodpay
--         and codcompy = hcm_util.get_codcomp_level(p_codcompy,1);
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('PY0044',global_v_lang,'codpay');
--      return;
--    end;
    --:h_tpriodal.desc_typpayroll := get_tcodec_name('TCODTYPY',:h_tpriodal.typpayroll,:global.v_lang);
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    begin
      select codcodec into p_typpayroll
        from tcodtypy
       where codcodec = p_typpayroll;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcodec');
      return;
    end;
  end check_index;
  --
  function check_codpay return boolean is
    v_check   boolean;
    cursor c1 is
      select distinct codpay
        from tpriodal
       where codcompy   = p_codcompy
         and typpayroll = p_typpayroll
         and dteyrepay  = p_dteyrepay;
  begin
    v_check := true;
    for i in c1 loop
      if i.codpay = p_codpay then
        v_check := false;
      end if;
    end loop;
    return v_check;
  end check_codpay;
  --
  -- procedure save_tpriodalgp is
  -- begin
  --   begin
  --     insert into tpriodalgp(codcompy,typpayroll,grpcodpay,dteyrepay,dtemthpay,
  --                            numperiod,dtestrt,dteend,dtecutst,dtecuten)
  --                    values (p_codcompy,p_typpayroll,p_grpcodpay,p_dteyrepay,p_dtemthpay,
  --                            p_numperiod,p_dtestrt,p_dteend,p_dtecutst,p_dtecuten);
  --   exception when dup_val_on_index then
  --     begin
  --       update  tpriodalgp
  --       set     dtestrt    = p_dtestrt,
  --               dteend     = p_dteend,
  --               dtecutst   = p_dtecutst,
  --               dtecuten   = p_dtecuten
  --         where codcompy   = p_codcompy
  --           and dteyrepay  = p_dteyrepay
  --           and typpayroll = p_typpayroll
  --           and grpcodpay  = p_grpcodpay
  --           and dtemthpay  = p_dtemthpay
  --           and numperiod  = p_numperiod;
  --     exception when others then
  --       param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  --       rollback;
  --     end;
  --   end;
  -- end;
  -- --
  -- procedure save_tpriodal is
  -- begin
  --   begin
  --     insert into tpriodal(codcompy,typpayroll,codpay,dteyrepay,dtemthpay,numperiod,
  --                          dtestrt,dteend,dtecutst,dtecuten,flgcal,grpcodpay)
  --                  values (p_codcompy,p_typpayroll,p_codpay,p_dteyrepay,p_dtemthpay,p_numperiod,
  --                          p_dtestrt,p_dteend,p_dtecutst,p_dtecuten,p_flgcal,p_grpcodpay);
  --   exception when dup_val_on_index then
  --     begin
  --       update  tpriodal
  --       set     dtestrt    = p_dtestrt,
  --               dteend     = p_dteend,
  --               dtecutst   = p_dtecutst,
  --               dtecuten   = p_dtecuten,
  --               flgcal     = p_flgcal,
  --               grpcodpay  = p_grpcodpay
  --         where codcompy   = p_codcompy
  --           and typpayroll = p_typpayroll
  --           and codpay     = p_codpay
  --           and dteyrepay  = p_dteyrepay
  --           and dtemthpay  = p_dtemthpay
  --           and numperiod  = p_numperiod;
  --     exception when others then
  --       param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  --       rollback;
  --     end;
  --   end;
  -- end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_main        json_object_t;
    obj_data_main   json_object_t;
    obj_row         json_object_t;
    obj_row_mom     json_object_t;
    obj_header      json_object_t;
    v_row           number := 0;
    v_dtestrt       varchar2(10 char);
    v_dteend        varchar2(10 char);
    v_dtecutst      varchar2(10 char);
    v_dtecuten      varchar2(10 char);
    v_flgtrnbank    ttaxcur.flgtrnbank%type;
    v_flgtrnbank_bool   boolean := false;
    v_flgtrnbank_main   boolean := false;
    v_dtemthpay     tpriodalgp.dtemthpay%type;
    v_numperiod     tpriodalgp.numperiod%type;
    v_flgadd_row    boolean;

--    cursor c1 is
--      select codcompy,dteyrepay,typpayroll,grpcodpay,dtemthpay,
--             numperiod,dtestrt,dteend,dtecutst,dtecuten
--        from tpriodalgp
--       where codcompy   = nvl(p_codcompyQuery, p_codcompy)
--         and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
--         and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
--         and dtemthpay = v_dtemthpay
--         and dteyrepay  = (
--                              select max(dteyrepay)
--                                from tpriodalgp
--                               where codcompy   = nvl(p_codcompyQuery, p_codcompy)
--                                 and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
--                                 and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
--                                 and dteyrepay  <= nvl(p_dteyrepayQuery, p_dteyrepay) )
--    order by grpcodpay,dtemthpay,numperiod;

    cursor c1 is
      select codcompy,dteyrepay,typpayroll,grpcodpay,dtemthpay,
             numperiod,dtestrt,dteend,dtecutst,dtecuten
        from tpriodalgp
       where codcompy   = p_codcompy
         and typpayroll = p_typpayroll
         and grpcodpay  = p_grpcodpay
         and dtemthpay = v_dtemthpay
         and dteyrepay  =  p_dteyrepay
         and get_flgtrnbank (p_codcompy, null, p_dteyrepay, dtemthpay,numperiod) = 'Y'
      union
      select codcompy,dteyrepay,typpayroll,grpcodpay,dtemthpay,
             numperiod,dtestrt,dteend,dtecutst,dtecuten
        from tpriodalgp
       where codcompy   = nvl(p_codcompyQuery, p_codcompy)
         and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
         and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
         and dtemthpay = v_dtemthpay
         and dteyrepay  = (
                              select max(dteyrepay)
                                from tpriodalgp
                               where codcompy   = nvl(p_codcompyQuery, p_codcompy)
                                 and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
                                 and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
                                 and dteyrepay  <= nvl(p_dteyrepayQuery, p_dteyrepay) )

         and get_flgtrnbank (p_codcompy, null, p_dteyrepay, dtemthpay,numperiod) = 'N'
    order by grpcodpay,dtemthpay,numperiod;

    cursor c2 is
      select distinct dtemthpay
        from tpriodalgp
       where codcompy   = p_codcompy
         and typpayroll = p_typpayroll
         and grpcodpay  = p_grpcodpay
         and dteyrepay  =  p_dteyrepay
         and get_flgtrnbank (p_codcompy, null, p_dteyrepay, dtemthpay,numperiod) = 'Y'
      union
      select distinct dtemthpay
        from tpriodalgp
       where codcompy   = nvl(p_codcompyQuery, p_codcompy)
         and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
         and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
--         and dteyrepay  = nvl(p_dteyrepayQuery, p_dteyrepay)
         and dteyrepay  = (
                              select max(dteyrepay)
                                from tpriodalgp
                               where codcompy   = nvl(p_codcompyQuery, p_codcompy)
                                 and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
                                 and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
                                 and dteyrepay  <= nvl(p_dteyrepayQuery, p_dteyrepay) )
         and get_flgtrnbank (p_codcompy, null, p_dteyrepay, dtemthpay,numperiod) = 'N'
         order by dtemthpay;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_flg_status;
        obj_header      := json_object_t();
        obj_row_mom    := json_object_t();
        for i in c2 loop
          v_dtemthpay := i.dtemthpay;
          v_row := v_row + 1;
          obj_data_main := json_object_t();
          obj_data_main.put('coderror','200');
          obj_data_main.put('dtemthpay',i.dtemthpay);
          v_flgtrnbank_bool   := false;
          obj_row    := json_object_t();
          for i in c1 loop
            v_flgtrnbank := get_flgtrnbank (p_codcompy, null, p_dteyrepay, i.dtemthpay,i.numperiod);
            if forceAdd = 'Y' then
              if v_flgtrnbank = 'Y' then
                  begin
                      select to_char(dtestrt, 'dd/mm/yyyy'),to_char(dteend, 'dd/mm/yyyy'),
                             to_char(dtecutst, 'dd/mm/yyyy'),to_char(dtecuten, 'dd/mm/yyyy')
                        into v_dtestrt,v_dteend,v_dtecutst,v_dtecuten
                        from tpriodalgp
                       where codcompy   = p_codcompy
                         and typpayroll = p_typpayroll
                         and grpcodpay  = p_grpcodpay
                         and dtemthpay = i.dtemthpay
                         and numperiod = i.numperiod
                         and dteyrepay  = p_dteyrepay;
                      v_flgadd_row := false;
                  exception when no_data_found then
                      v_flgadd_row      := isAdd;
                      v_dtestrt         := to_char(add_months(i.dtestrt, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
                      v_dteend          := to_char(add_months(i.dteend, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
                      v_dtecutst        := to_char(add_months(i.dtecutst, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
                      v_dtecuten        := to_char(add_months(i.dtecuten, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
                  end;
              else
                  v_flgadd_row      := isAdd;
                  v_dtestrt         := to_char(add_months(i.dtestrt, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
                  v_dteend          := to_char(add_months(i.dteend, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
                  v_dtecutst        := to_char(add_months(i.dtecutst, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
                  v_dtecuten        := to_char(add_months(i.dtecuten, ((p_dteyrepay - p_dteyrepayQuery) * 12)), 'dd/mm/yyyy');
              end if;
            else
              if i.dteyrepay <> p_dteyrepay then
                  v_dtestrt         := to_char(add_months(i.dtestrt, ((p_dteyrepay - i.dteyrepay) * 12)), 'dd/mm/yyyy');
                  v_dteend          := to_char(add_months(i.dteend, ((p_dteyrepay - i.dteyrepay) * 12)), 'dd/mm/yyyy');
                  v_dtecutst        := to_char(add_months(i.dtecutst, ((p_dteyrepay - i.dteyrepay) * 12)), 'dd/mm/yyyy');
                  v_dtecuten        := to_char(add_months(i.dtecuten, ((p_dteyrepay - i.dteyrepay) * 12)), 'dd/mm/yyyy');
              else
                  v_dtestrt         := to_char(i.dtestrt, 'dd/mm/yyyy');
                  v_dteend          := to_char(i.dteend, 'dd/mm/yyyy');
                  v_dtecutst        := to_char(i.dtecutst, 'dd/mm/yyyy');
                  v_dtecuten        := to_char(i.dtecuten, 'dd/mm/yyyy');
              end if;
              v_flgadd_row          := isAdd;
            end if;

            obj_header.put('codcompy',i.codcompy);
            obj_header.put('dteyrepay',p_dteyrepay);
            obj_header.put('typpayroll',i.typpayroll);
            obj_header.put('grpcodpay',i.grpcodpay);

            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('dteyrepay', p_dteyrepay);
            obj_data.put('typpayroll',i.typpayroll);
            obj_data.put('grpcodpay',i.grpcodpay);
            obj_data.put('dtemthpay',i.dtemthpay);
            obj_data.put('numperiod',i.numperiod);
            obj_data.put('dtestrt', v_dtestrt);
            obj_data.put('dteend', v_dteend);
            obj_data.put('dtecutst', v_dtecutst);
            obj_data.put('dtecuten', v_dtecuten);
            obj_data.put('dtecuten', v_dtecuten);
            obj_data.put('flgAdd', v_flgadd_row);
            obj_data.put('flgtrnbank', v_flgtrnbank);
            if v_flgtrnbank = 'Y' then
                v_flgtrnbank_bool := true;
                v_flgtrnbank_main := true;
            end if;
            obj_row.put(to_char(v_row-1),obj_data);
          end loop;
          if v_flgtrnbank_bool then
            obj_data_main.put('flgtrnbank','Y');
          else
            obj_data_main.put('flgtrnbank','N');
          end if;

          obj_data_main.put('children',obj_row);
          obj_row_mom.put(to_char(v_row-1),obj_data_main);
        end loop;
--
        obj_main    := json_object_t();
        obj_main.put('coderror','200');
        obj_main.put('isCopy',nvl(forceAdd, 'N'));
        obj_main.put('flgDisable',v_flgtrnbank_main);
        obj_main.put('headerIndex',obj_header);
        obj_main.put('indexTable',obj_row_mom);
        json_str_output := obj_main.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure get_group(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select distinct dtemthpay
        from tpriodalgp
       where codcompy   = nvl(p_codcompyQuery, p_codcompy)
         and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
         and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
--         and dteyrepay  = nvl(p_dteyrepayQuery, p_dteyrepay)
         and dteyrepay  = (
                              select max(dteyrepay)
                                from tpriodalgp
                               where codcompy   = nvl(p_codcompyQuery, p_codcompy)
                                 and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
                                 and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
                                 and dteyrepay  <= nvl(p_dteyrepayQuery, p_dteyrepay) )
         order by dtemthpay;
  begin
    initial_value(json_str_input);
    check_index;

    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dtemthpay',i.dtemthpay);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_group;
  --
  procedure get_codpay(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select distinct codpay
        from tpriodal
       where codcompy   = nvl(p_codcompyQuery, p_codcompy)
         and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
         and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)        
--         and dteyrepay  = nvl(p_dteyrepayQuery, p_dteyrepay)
         and dteyrepay  = (
                              select max(dteyrepay)
                                from tpriodalgp
                               where codcompy   = nvl(p_codcompyQuery, p_codcompy)
                                 and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
                                 and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
                                 and dteyrepay  <= nvl(p_dteyrepayQuery, p_dteyrepay) )
    order by codpay;
  begin
    initial_value(json_str_input);
    check_index;
    gen_flg_status;
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpay',i.codpay);
--      obj_data.put('flgAdd', isAdd);
      obj_data.put('flgEdit', true);
      --
--      if isAdd then
--        obj_data.put('flg', 'add');
--      else
--        obj_data.put('flg', 'edit');
--      end if;
      --
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codpay;
  --
  procedure get_codpay_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select  codpay,decode(global_v_lang,'101',descpaye,
                                          '102',descpayt,
                                          '103',descpay3,
                                          '104',descpay4,
                                          '105',descpay5) desc_codpay
        from  tinexinf
       where  typpay like '%'
         and  codpay in (select codpay from TINEXINFC where codcompy = p_codcompy)
    order by  codpay;
  begin
    initial_value(json_str_input);
    check_index;
    gen_flg_status;
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpay',i.codpay);
      obj_data.put('desc_codpay',i.desc_codpay);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codpay_all;
  --
  procedure get_copy_codpay(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select distinct codpay
        from tpriodal
       where codcompy = p_codcompyQuery
         and typpayroll = p_typpayrollQuery
         and grpcodpay = p_grpcodpayQuery
         and dteyrepay = p_dteyrepayQuery
         and codpay not in (select distinct codpay
                              from tpriodal
                             where codcompy = p_codcompy
                               and typpayroll = p_typpayroll
                               and grpcodpay <> p_grpcodpay
                               and dteyrepay = p_dteyrepay)
         and codpay in (select codpay from TINEXINFC where codcompy = p_codcompy)
       order by codpay;
  begin
    initial_value(json_str_input);
    check_index;
    gen_flg_status;
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpay',i.codpay);
      obj_data.put('flgAdd', isAdd);
      obj_data.put('flgEdit', true);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_copy_codpay;
  --
  procedure initial_save_data(json_data json_object_t) as
  begin
    p_codcompy   := hcm_util.get_string_t(json_data,'codcompy');
    p_dteyrepay  := to_number(hcm_util.get_string_t(json_data,'dteyrepay'));
    p_typpayroll := hcm_util.get_string_t(json_data,'typpayroll');
    p_grpcodpay  := hcm_util.get_string_t(json_data,'grpcodpay');
  end;

  procedure check_save_data as
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
      return;
    end if;

    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    else
      begin
        select codcodec into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcodec');
        return;
      end;
    end if;

    if p_grpcodpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'tcodgppay');
      return;
    else
      begin
        select codcodec into p_grpcodpay
          from tcodgppay
         where codcodec = p_grpcodpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodgppay');
        return;
      end;
--      begin
--        select codpay into p_grpcodpay
--          from tinexinfc
--         where codpay = p_grpcodpay
--           and codcompy = hcm_util.get_codcomp_level(p_codcompy,1);
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('PY0044',global_v_lang);
--        return;
--      end;
    end if;
  end;

  procedure check_py(p_codcompy varchar2, p_typpayroll varchar2, p_grpcodpay varchar2,p_dteyrepay number, p_dtemthpay number, p_numperiod number) as
    v_countpy number;
  begin
    begin
        select count(codpay)
          into v_countpy
          from tpriodal a
         where a.codcompy = p_codcompy
           and a.typpayroll = p_typpayroll
           and a.dteyrepay = p_dteyrepay
           and a.dtemthpay = p_dtemthpay
           and a.numperiod = nvl(p_numperiod,a.numperiod)
           and a.grpcodpay = p_grpcodpay
           and exists (select codpay
                         from tpaysum
                        where dteyrepay = a.dteyrepay
                          and dtemthpay = a.dtemthpay
                          and numperiod = a.numperiod
                          and typpayroll = a.typpayroll
                          and codpay = a.codpay
                          and hcm_util.get_codcomp_level(codcomp,1) = a.codcompy);
    exception when others then
        v_countpy := 0;
    end;
    if v_countpy > 0 then
        param_msg_error := get_error_msg_php('HR1510',global_v_lang);
    end if;
  end;

  procedure save_data(json_str_input in clob, json_str_output out clob) is
    param_json_input    json_object_t;
    param_json          json_object_t;
    param_json_row      json_object_t;
    param_header        json_object_t;
    param_index         json_object_t;
    param_paycode       json_object_t;
    param_index_row     json_object_t;
    param_children      json_object_t;
    param_paycode_row   json_object_t;
    v_parent_flg        varchar2(10 char);
    v_child_flg         varchar2(10 char);
    v_flg               varchar2(10 char);
  begin
    initial_value(json_str_input);
    --check_index;
    param_json_input := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_header     := hcm_util.get_json_t(param_json_input, 'headerIndex');
    param_index      := hcm_util.get_json_t(param_json_input, 'indexTable');
    param_paycode_row    := hcm_util.get_json_t(param_json_input, 'paycodeTable');

    initial_save_data(param_header);
    check_save_data;
    if param_msg_error is null then
      delete_case_copy;
      if param_index.get_size <> 0 then
      for j in 0..param_index.get_size-1 loop
        param_index_row  := hcm_util.get_json_t(param_index, to_char(j));
        param_children   := hcm_util.get_json_t(param_index_row, 'children');
        v_parent_flg     := hcm_util.get_string_t(param_index_row,'flg');
        p_dtemthpay      := to_number(hcm_util.get_string_t(param_index_row,'dtemthpay'));
        p_dtemthpayOld   := to_number(hcm_util.get_string_t(param_index_row,'dtemthpayOld'));
        if v_parent_flg = 'delete' then
          delete_month;
        else
          if p_dtemthpay <> p_dtemthpayOld then
            edit_month(param_children,param_paycode_row); -- edit a??a??a??a?-a?? a??a??a?<a?#a??a?sa??a??a?-a?!a??a?Ya??a??a?'a?! a??a??a??a??a?!a??a?!a??a??a??a?#a?Ya?s a?<a?#a??a?- a??a??a??a??a??
          end if;
          for k in 0..param_children.get_size-1 loop
            param_json_row := hcm_util.get_json_t(param_children,to_char(k));
            v_child_flg    := hcm_util.get_string_t(param_json_row,'flg');
            if v_child_flg = 'add' then -- /
              add_TPRIODALGP(param_json_row);
            elsif v_child_flg = 'edit' then
              p_flgchkpy := false;
              delete_TPRIODALGP(param_json_row);
              add_TPRIODALGP(param_json_row);
            elsif v_child_flg = 'delete' then            
              p_flgchkpy := true;
              delete_TPRIODALGP(param_json_row);
            end if;
            if param_msg_error is not null then
              json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
              rollback;
              return;
            end if;
          end loop;
        end if;
        if param_msg_error is not null then
          json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
      end loop;
      end if;
      if param_paycode_row.get_size <> 0 then
      for j in 0..param_paycode_row.get_size-1 loop
        param_index_row := hcm_util.get_json_t(param_paycode_row,to_char(j));
        v_flg           := hcm_util.get_string_t(param_index_row,'flg');
        if v_flg = 'add' then
          add_TPRIODAL(param_index_row);
        elsif v_flg = 'edit' then
          delete_TPRIODAL(param_index_row);
          add_TPRIODAL(param_index_row);
        elsif v_flg = 'delete' then
          delete_TPRIODAL(param_index_row);
        end if;
        if param_msg_error is not null then
          json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
      end loop;
      end if;
    end if;
    if param_msg_error is not null then
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
    else

    if v_parent_flg = 'delete' then
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
      json_str_output := get_response_message('200',param_msg_error,global_v_lang);
      commit;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_data;
  --
  procedure check_paycode(json_str_input in clob, json_str_output out clob) is
    param_json_input    json_object_t;
    param_json          json_object_t;
    param_json_row      json_object_t;
    param_header        json_object_t;
    param_paycode       json_object_t;
    param_paycode_row   json_object_t;
    v_codpay            varchar2(100 char);
    v_listcodpay        varchar2(1000 char);
    v_flg               varchar2(100 char);
  begin
    initial_value(json_str_input);
    v_listcodpay := null;
    param_json_input := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_header     := hcm_util.get_json_t(param_json_input, 'headerIndex');
    param_paycode    := hcm_util.get_json_t(param_json_input, 'paycodeTable');

    if param_msg_error is null then
      p_codcompy   := hcm_util.get_string_t(param_header,'codcompy');
      p_dteyrepay  := to_number(hcm_util.get_string_t(param_header,'dteyrepay'));
      p_typpayroll := hcm_util.get_string_t(param_header,'typpayroll');
      p_grpcodpay  := hcm_util.get_string_t(param_header,'grpcodpay');
      for i in 0..param_paycode.get_size-1 loop
        param_paycode_row  := hcm_util.get_json_t(param_paycode, to_char(i));
        v_flg              := hcm_util.get_string_t(param_paycode_row,'flg'); 
        p_codpay           := hcm_util.get_string_t(param_paycode_row,'codpay');        
        if v_flg <> 'delete' then                   
          begin
            select distinct codpay
              into v_codpay
              from tpriodal
             where codcompy   = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay  = p_dteyrepay
               and grpcodpay not in(p_grpcodpay)
               and codpay = p_codpay;
          exception when no_data_found then
            v_codpay := null;
          end;
          if v_codpay is not null then
            if v_listcodpay is null then
              v_listcodpay := v_codpay;
            else
              v_listcodpay := v_listcodpay||', '||v_codpay;
            end if;
          end if;
        end if; 
      end loop;

      if v_listcodpay is not null then
        param_msg_error := get_error_msg_php('AL0065',global_v_lang,'CODPAY :'||v_listcodpay);
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end check_paycode;

  procedure add_TPRIODALGP(json_child in json_object_t) as
    v_numperiod number;
    v_dtemthpay number;
    v_dtecutst  date;
    v_dtecuten  date;
    v_dtestrt   date;
    v_dteend    date;
    v_check     varchar2(4000 char);
    cursor c_tpriodal is
      select distinct codpay
        from tpriodal
       where codcompy   = hcm_util.get_codcomp_level(p_codcompy,1)
         and typpayroll = p_typpayroll
         and grpcodpay  = p_grpcodpay
         and dteyrepay  = p_dteyrepay
    order by codpay;
  begin
    v_numperiod := to_number(hcm_util.get_string_t(json_child,'numperiod'));
    v_dtemthpay := p_dtemthpay;
    v_dtecutst  := to_date(hcm_util.get_string_t(json_child,'dtecutst'),'dd/mm/yyyy');
    v_dtecuten  := to_date(hcm_util.get_string_t(json_child,'dtecuten'),'dd/mm/yyyy');
    v_dtestrt   := to_date(hcm_util.get_string_t(json_child,'dtestrt' ),'dd/mm/yyyy');
    v_dteend    := to_date(hcm_util.get_string_t(json_child,'dteend'  ),'dd/mm/yyyy');
    validate_date_input (v_dtestrt, v_dteend, v_dtecutst, v_dtecuten);
    if param_msg_error is not null then
      return;
    end if;
    begin
      insert into tpriodalgp (codcompy   ,numperiod   ,dtemthpay  ,dteyrepay  ,
                              grpcodpay  ,typpayroll  ,dteupd     ,dtecreate  ,
                              dtecutst   ,dtecuten    ,dtestrt    ,dteend     ,
                              coduser    ,codcreate)
                      values (p_codcompy ,v_numperiod ,v_dtemthpay,p_dteyrepay,
                              p_grpcodpay,p_typpayroll,sysdate    ,sysdate    ,
                              v_dtecutst ,v_dtecuten  ,v_dtestrt  ,v_dteend   ,
                              global_v_coduser       ,global_v_coduser);
    exception when dup_val_on_index then
      update tpriodalgp
         set dtestrt    = v_dtestrt,
             dteend     = v_dteend,
             dtecutst   = v_dtecutst,
             dtecuten   = v_dtecuten,
             dteupd     = sysdate,
             coduser    = global_v_coduser
       where codcompy   = p_codcompy
         and dteyrepay  = p_dteyrepay
         and typpayroll = p_typpayroll
         and grpcodpay  = p_grpcodpay
         and dtemthpay  = v_dtemthpay
         and numperiod  = v_numperiod;
    end;
    for r_tpriodal in c_tpriodal loop
      begin
        insert into tpriodal (codpay     ,flgcal      ,
                              codcompy   ,numperiod   ,dtemthpay  ,dteyrepay  ,
                              grpcodpay  ,typpayroll  ,dteupd     ,dtecreate  ,
                              dtecutst   ,dtecuten    ,dtestrt    ,dteend     ,
                              coduser    ,codcreate)
                      values (r_tpriodal.codpay       ,'N'         ,
                              p_codcompy ,v_numperiod ,v_dtemthpay,p_dteyrepay,
                              p_grpcodpay,p_typpayroll,sysdate    ,sysdate    ,
                              v_dtecutst ,v_dtecuten  ,v_dtestrt  ,v_dteend   ,
                              global_v_coduser       ,global_v_coduser);
      exception when dup_val_on_index then
        begin
          select grpcodpay
            into v_check
            from tpriodal
           where codcompy   = p_codcompy
             and dteyrepay  = p_dteyrepay
             and typpayroll = p_typpayroll
             and codpay     = r_tpriodal.codpay
             and dtemthpay  = v_dtemthpay
             and numperiod  = v_numperiod;
          if v_check = p_grpcodpay then
            update tpriodal
               set dtestrt    = v_dtestrt,
                   dteend     = v_dteend,
                   dtecutst   = v_dtecutst,
                   dtecuten   = v_dtecuten,
                   dteupd     = sysdate,
                   coduser    = global_v_coduser,
                   flgcal     = 'N'
             where codcompy   = p_codcompy
               and dteyrepay  = p_dteyrepay
               and typpayroll = p_typpayroll
               and codpay     = r_tpriodal.codpay
               and grpcodpay  = p_grpcodpay
               and dtemthpay  = v_dtemthpay
               and numperiod  = v_numperiod;
          else
            param_msg_error := get_error_msg_php('AL0065',global_v_lang);
            return;
          end if;
        end;
      end;
    end loop;
--    commit;
  end;

  procedure delete_TPRIODALGP(json_child in json_object_t) as
    v_numperiod number;
    v_dtemthpay number;
    v_dtecutst  date;
    v_dtecuten  date;
    v_dtestrt   date;
    v_dteend    date;
    v_countpy   number;
  begin
    v_numperiod := to_number(hcm_util.get_string_t(json_child,'numperiodOld'));
    v_dtemthpay := p_dtemthpayOld;
    v_dtecutst  := to_date(hcm_util.get_string_t(json_child,'dtecutstOld'),'dd/mm/yyyy');
    v_dtecuten  := to_date(hcm_util.get_string_t(json_child,'dtecutenOld'),'dd/mm/yyyy');
    v_dtestrt   := to_date(hcm_util.get_string_t(json_child,'dtestrtOld' ),'dd/mm/yyyy');
    v_dteend    := to_date(hcm_util.get_string_t(json_child,'dteendOld'  ),'dd/mm/yyyy');
    if p_flgchkpy = true then
        check_py(p_codcompy, p_typpayroll, p_grpcodpay, p_dteyrepay, v_dtemthpay, v_numperiod);
    end if;
    if param_msg_error is null then
        begin
          delete tpriodalgp
           where codcompy   = p_codcompy
             and dteyrepay  = p_dteyrepay
             and typpayroll = p_typpayroll
             and grpcodpay  = p_grpcodpay
             and dtemthpay  = v_dtemthpay
             and numperiod  = v_numperiod;
        end;
        begin
          delete tpriodal
           where codcompy   = p_codcompy
             and dteyrepay  = p_dteyrepay
             and typpayroll = p_typpayroll
             and grpcodpay  = p_grpcodpay
             and dtemthpay  = v_dtemthpay
             and numperiod  = v_numperiod;
        end;
    end if;
--    commit;
  end;


  procedure delete_month as
    v_count_trnbank     number;
  begin
    check_py(p_codcompy, p_typpayroll, p_grpcodpay, p_dteyrepay, p_dtemthpayOld, null);
    if param_msg_error is null then
          select count(*)
            into v_count_trnbank
            from tpriodalgp
           where codcompy   = p_codcompy
             and dteyrepay  = p_dteyrepay
             and typpayroll = p_typpayroll
             and grpcodpay  = p_grpcodpay
             and dtemthpay  = p_dtemthpayOld
             and get_flgtrnbank (codcompy, null, dteyrepay, dtemthpay,numperiod) = 'N' ;

        if v_count_trnbank = 0 then
            param_msg_error     := get_error_msg_php('AL0076', global_v_lang);
            return;
        else
            begin
              delete tpriodalgp
               where codcompy   = p_codcompy
                 and dteyrepay  = p_dteyrepay
                 and typpayroll = p_typpayroll
                 and grpcodpay  = p_grpcodpay
                 and dtemthpay  = p_dtemthpayOld;
            end;
            begin
              delete tpriodal
               where codcompy   = p_codcompy
                 and dteyrepay  = p_dteyrepay
                 and typpayroll = p_typpayroll
                 and grpcodpay  = p_grpcodpay
                 and dtemthpay  = p_dtemthpayOld;
            end;
        end if;



    end if;
  end;
  procedure edit_month(json_TPRIODALGP_child_list in json_object_t,json_TPRIODAL_child_list in json_object_t) as
    param_json_row json_object_t;
    v_child_flg    varchar2(4000 char);
    v_edit_flg     boolean;
    v_tpriodal_flg boolean;
    v_numperiod    number;
    v_codpay       varchar2(1000 char);
    cursor c_tpriodalgp is
      select numperiod,dtestrt,dteend,dtecutst,dtecuten
        from tpriodalgp
       where codcompy   = p_codcompy
         and dtemthpay  = p_dtemthpayOld
         and dteyrepay  = p_dteyrepay
         and grpcodpay  = p_grpcodpay
         and typpayroll = p_typpayroll;
    cursor c_tpriodal is
      select codpay,dtestrt,dteend,dtecutst,dtecuten
        from tpriodal
       where codcompy   = p_codcompy
         and dtemthpay  = p_dtemthpayOld
         and dteyrepay  = p_dteyrepay
         and grpcodpay  = p_grpcodpay
         and typpayroll = p_typpayroll
         and numperiod  = v_numperiod;
  begin
    for r1 in c_tpriodalgp loop
      v_edit_flg     := true;
      for k in 0..json_TPRIODALGP_child_list.get_size-1 loop
        param_json_row := hcm_util.get_json_t(json_TPRIODALGP_child_list,to_char(k));
        v_child_flg    := hcm_util.get_string_t(param_json_row,'flg');
        if (v_child_flg  = 'edit' or v_child_flg = 'delete') and
           (r1.numperiod = hcm_util.get_string_t(param_json_row,'numperiodOld')) then
          v_edit_flg     := false;
        end if;
      end loop;
      if v_edit_flg then
        v_numperiod := r1.numperiod;
        for r2 in c_tpriodal loop
          begin
            v_tpriodal_flg := true;
            if json_TPRIODAL_child_list.get_size <> 0 then
              for k in 0..json_TPRIODAL_child_list.get_size-1 loop
                param_json_row := hcm_util.get_json_t(json_TPRIODAL_child_list,to_char(k));
                v_child_flg    := hcm_util.get_string_t(param_json_row,'flg');
                if (v_child_flg = 'delete' or v_child_flg = 'edit') and
                   (r2.codpay = hcm_util.get_string_t(param_json_row,'codpayOld')) then
                   v_tpriodal_flg := false;
                 end if;
              end loop;
            end if;
            if v_tpriodal_flg then
              insert into tpriodal (codpay     ,flgcal      ,
                                    codcompy   ,numperiod   ,dtemthpay  ,dteyrepay  ,
                                    grpcodpay  ,typpayroll  ,dteupd     ,dtecreate  ,
                                    dtecutst   ,dtecuten    ,dtestrt    ,dteend     ,
                                    coduser    ,codcreate)
                            values (r2.codpay   ,'N'         ,
                                    p_codcompy  ,v_numperiod ,p_dtemthpay,p_dteyrepay,
                                    p_grpcodpay ,p_typpayroll,sysdate    ,sysdate    ,
                                    r2.dtecutst ,r2.dtecuten ,r2.dtestrt ,r2.dteend  ,
                                    global_v_coduser       ,global_v_coduser);
            end if;
            begin
              delete tpriodal
               where codcompy   = p_codcompy
                 and dteyrepay  = p_dteyrepay
                 and typpayroll = p_typpayroll
                 and grpcodpay  = p_grpcodpay
                 and dtemthpay  = p_dtemthpayOld
                 and codpay     = r2.codpay
                 and numperiod  = v_numperiod;
            end;
          exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('AL0065',global_v_lang);
            return;
          end;
        end loop;
        if json_TPRIODAL_child_list.get_size <> 0 then
          for k in 0..json_TPRIODAL_child_list.get_size-1 loop
            param_json_row := hcm_util.get_json_t(json_TPRIODAL_child_list,to_char(k));
            v_child_flg    := hcm_util.get_string_t(param_json_row,'flg');
            if (v_child_flg = 'add' or v_child_flg = 'edit') then
              v_codpay := hcm_util.get_string_t(param_json_row,'codpay');
              begin
                insert into tpriodal (codpay     ,flgcal      ,
                                      codcompy   ,numperiod   ,dtemthpay  ,dteyrepay  ,
                                      grpcodpay  ,typpayroll  ,dteupd     ,dtecreate  ,
                                      dtecutst   ,dtecuten    ,dtestrt    ,dteend     ,
                                      coduser    ,codcreate)
                              values (v_codpay,'N' ,
                                      p_codcompy  ,v_numperiod ,p_dtemthpay,p_dteyrepay,
                                      p_grpcodpay ,p_typpayroll,sysdate    ,sysdate    ,
                                      r1.dtecutst ,r1.dtecuten ,r1.dtestrt ,r1.dteend  ,
                                      global_v_coduser       ,global_v_coduser);
              exception when dup_val_on_index then
                param_msg_error := get_error_msg_php('AL0065',global_v_lang);
                return;
              end;
            end if;
          end loop;
        end if;
        begin
          insert into tpriodalgp (codcompy   ,numperiod   ,dtemthpay  ,dteyrepay  ,
                                  grpcodpay  ,typpayroll  ,dteupd     ,dtecreate  ,
                                  dtecutst   ,dtecuten    ,dtestrt    ,dteend     ,
                                  coduser    ,codcreate)
                          values (p_codcompy ,r1.numperiod,p_dtemthpay,p_dteyrepay,
                                  p_grpcodpay,p_typpayroll,sysdate    ,sysdate    ,
                                  r1.dtecutst,r1.dtecuten ,r1.dtestrt ,r1.dteend   ,
                                  global_v_coduser       ,global_v_coduser);
          begin
            delete tpriodalgp
             where codcompy   = p_codcompy
               and dteyrepay  = p_dteyrepay
               and typpayroll = p_typpayroll
               and grpcodpay  = p_grpcodpay
               and dtemthpay  = p_dtemthpayOld
               and numperiod  = r1.numperiod;
          end;
        exception when dup_val_on_index then
          param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tpriodalgp');
          return;
        end;
      end if;
      if param_msg_error is not null then
        return;
      end if;
    end loop;
  end;
  procedure add_TPRIODAL(json_child in json_object_t) as
    v_codpay varchar2(4000 char);
    v_check  varchar2(4000 char);
    cursor c_tpriodalgp is
      select grpcodpay,numperiod,dtemthpay,dtecutst,dtecuten,dtestrt,dteend
        from tpriodalgp
       where codcompy   = hcm_util.get_codcomp_level(p_codcompy,1)
         and typpayroll = p_typpayroll
         and dteyrepay  = p_dteyrepay
         and grpcodpay  = p_grpcodpay
    order by grpcodpay,numperiod;
  begin
    v_codpay := hcm_util.get_string_t(json_child,'codpay');
    for r1 in c_tpriodalgp loop
      begin
        insert into tpriodal (codpay      ,flgcal       ,
                              codcompy    ,numperiod    ,dtemthpay   ,dteyrepay   ,
                              grpcodpay   ,typpayroll   ,dteupd      ,dtecreate   ,
                              dtecutst    ,dtecuten     ,dtestrt     ,dteend      ,
                              coduser     ,codcreate)
                      values (v_codpay    ,'N'          ,
                              p_codcompy  ,r1.numperiod ,r1.dtemthpay,p_dteyrepay ,
                              r1.grpcodpay,p_typpayroll ,sysdate     ,sysdate     ,
                              r1.dtecutst ,r1.dtecuten  ,r1.dtestrt  ,r1.dteend   ,
                              global_v_coduser         ,global_v_coduser);
      exception when dup_val_on_index then
        begin
          select grpcodpay
            into v_check
            from tpriodal
           where codcompy   = p_codcompy
             and dteyrepay  = p_dteyrepay
             and typpayroll = p_typpayroll
             and codpay     = v_codpay
             and dtemthpay  = r1.dtemthpay
             and numperiod  = r1.numperiod;
          if v_check = r1.grpcodpay then
            update tpriodal
               set dtestrt    = r1.dtestrt,
                   dteend     = r1.dteend,
                   dtecutst   = r1.dtecutst,
                   dtecuten   = r1.dtecuten,
                   dteupd     = sysdate,
                   coduser    = global_v_coduser,
                   flgcal     = 'N'
             where codcompy   = p_codcompy
               and dteyrepay  = p_dteyrepay
               and typpayroll = p_typpayroll
               and codpay     = v_codpay
               and grpcodpay  = r1.grpcodpay
               and dtemthpay  = r1.dtemthpay
               and numperiod  = r1.numperiod;
          else
            param_msg_error := get_error_msg_php('AL0065',global_v_lang);
            return;
          end if;
        end;
      end;
    end loop;
--    commit;
  end;

  procedure delete_TPRIODAL(json_child in json_object_t) as
    v_codpay varchar2(4000 char);
  begin
    v_codpay := hcm_util.get_string_t(json_child,'codpayOld');
    begin
      delete tpriodal
       where codcompy   = p_codcompy
         and dteyrepay  = p_dteyrepay
         and typpayroll = p_typpayroll
         and codpay     = v_codpay
         and grpcodpay  = p_grpcodpay;
    exception when others then
      null;
    end;
--    commit;
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
    v_codcompy          TPRIODALGP.CODCOMPY%TYPE;
  begin
    if forceAdd = 'Y' then
      isEdit := false;
      isAdd  := true;
    else
      begin
        select codcompy
          into v_codcompy
          from tpriodalgp
         where codcompy   = nvl(p_codcompyQuery, p_codcompy)
           and typpayroll = nvl(p_typpayrollQuery, p_typpayroll)
           and grpcodpay  = nvl(p_grpcodpayQuery, p_grpcodpay)
           and dteyrepay  = nvl(p_dteyrepayQuery, p_dteyrepay)
           and rownum <= 1;
        isEdit := true;
        isAdd  := false;
      exception when no_data_found then
        isEdit := false;
        isAdd  := true;
      end;
    end if;
  end gen_flg_status;

  procedure get_copy_list (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_copy_list(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_copy_list;

  procedure gen_copy_list (json_str_output out clob) is
    json_row          json_object_t;
    json_data         json_object_t;
    v_rcnt            number;

    cursor c1 is
      select codcompy, typpayroll, grpcodpay, dteyrepay
        from tpriodalgp
       where (codcompy, typpayroll, grpcodpay, dteyrepay)
             not in (select codcompy, typpayroll, grpcodpay, dteyrepay
                       from tpriodalgp
                      where codcompy   = p_codcompy
                        and typpayroll = p_typpayroll
                        and grpcodpay  = p_grpcodpay
                        and dteyrepay  = p_dteyrepay
                   group by codcompy, typpayroll, grpcodpay, dteyrepay)
    group by codcompy, typpayroll, grpcodpay, dteyrepay
    order by dteyrepay desc, codcompy, grpcodpay, typpayroll;

--    select codcompy, typpayroll, codpay, dteyrepay
--        from tpriodal
--    group by codcompy, typpayroll, codpay, dteyrepay
--    order by dteyrepay desc, codcompy, codpay, typpayroll;
  begin
    json_data         := json_object_t();
    v_rcnt            := 0;
    for r1 in c1 loop
        if secur_main.secur7(r1.codcompy,global_v_coduser) then
            json_row        := json_object_t();
            json_row.put('coderror', 200);
            json_row.put('codcompy', r1.codcompy);
            json_row.put('grpcodpay', r1.grpcodpay);
            json_row.put('desc_grpcodpay', r1.grpcodpay || ' ' || get_tcodec_name('tcodgppay', r1.grpcodpay, global_v_lang));
            json_row.put('typpayroll', r1.typpayroll);
            json_row.put('desc_typpayroll', r1.typpayroll || ' ' || get_tcodec_name('tcodtypy', r1.typpayroll, global_v_lang));
            json_row.put('dteyrepay', r1.dteyrepay);

            json_data.put(to_char(v_rcnt), json_row);
            v_rcnt          := v_rcnt + 1;
        end if;

    end loop;
    json_str_output := json_data.to_clob;
  end gen_copy_list;

  procedure validate_date_input (v_dtestrt date, v_dteend date, v_dtecutst date, v_dtecuten date) is
  begin
    if abs(to_number(p_dteyrepay) - to_number(to_char(v_dtestrt, 'yyyy'))) > 1 then
      param_msg_error     := get_error_msg_php('HR2016', global_v_lang, 'dtestrt');
    elsif abs(to_number(p_dteyrepay) - to_number(to_char(v_dteend, 'yyyy'))) > 1 then
      param_msg_error     := get_error_msg_php('HR2016', global_v_lang, 'dteend');
    elsif abs(to_number(p_dteyrepay) - to_number(to_char(v_dtecutst, 'yyyy'))) > 1 then
      param_msg_error     := get_error_msg_php('HR2016', global_v_lang, 'dtecutst');
    elsif abs(to_number(p_dteyrepay) - to_number(to_char(v_dtecuten, 'yyyy'))) > 1 then
      param_msg_error     := get_error_msg_php('HR2016', global_v_lang, 'dtecuten');
    end if;
  end validate_date_input;

  procedure delete_case_copy is
  begin
    if isCopy = 'Y' then
      begin
        delete tpriodalgp
         where codcompy   = p_codcompy
           and dteyrepay  = p_dteyrepay
           and typpayroll = p_typpayroll
           and grpcodpay  = p_grpcodpay
           and get_flgtrnbank (p_codcompy, null, p_dteyrepay, dtemthpay,numperiod) = 'N';
      end;
      begin
        delete tpriodal
         where codcompy   = p_codcompy
           and dteyrepay  = p_dteyrepay
           and typpayroll = p_typpayroll
           and grpcodpay  = p_grpcodpay
           and get_flgtrnbank (p_codcompy, null, p_dteyrepay, dtemthpay,numperiod) = 'N';
      end;
    end if;
  end;

end HRAL99E;

/
