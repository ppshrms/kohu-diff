--------------------------------------------------------
--  DDL for Package Body HRPY36X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY36X" as
-- last update: 12/09/2018 16:30
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcompy           := upper(hcm_util.get_string_t(json_obj, 'p_codcompy'));
    p_numperiod          := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));
    p_dtemthpay          := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay          := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_typpayroll         := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codgrpgl           := hcm_util.get_string_t(json_obj,'p_codgrpgl');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin

    if p_codcompy is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtemthpay');
      return;
    end if;
    if nvl(p_dteyrepay,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
      return;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data (json_str_output out clob) is
    v_flgdata              varchar2(1 char) := 'N';
    v_flgdrcr              varchar2(2 char);

    obj_row                json_object_t;
    obj_data               json_object_t;
    v_rcnt                 number;
    v_codcomp              varchar2(4000 char);

    v_dr                   number := 0;
    v_cr                   number := 0;
    v_sumdr                number := 0;
    v_sumcr                number := 0;
    v_apcode_old           varchar2(4000 char);
    v_apcode               varchar2(4000 char);
    v_count                number := 0;
    v_sumap                number;

    v_dr_text              varchar2(4000 char);
    v_cr_text              varchar2(4000 char);

    v_flg_secure           boolean := false;
    v_flg_exist            boolean := false;
    v_flg_permission       boolean := false;

    cursor c1 is
      select codcompy, apcode, costcent, codacc, scodacc,
             stddec(amtgl, codcompy, v_chken) amtgl, flgdrcr,
             dteyrepay, dtemthpay, numperiod, typpaymt,  rowid
        from tgltrans
       where codcompy  = p_codcompy
         and numperiod = p_numperiod
         and dtemthpay = p_dtemthpay
         and dteyrepay = p_dteyrepay
         and apcode    = nvl(p_codgrpgl,apcode)
    order by apcode ,codacc ,costcent ;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    --
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tgltrans');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      v_flg_secure := secur_main.secur7(r1.codcompy,global_v_coduser);
      if v_flg_secure then
        v_flg_permission := true;
        if v_apcode_old <> r1.apcode or v_apcode_old is null then
         begin
           select count(*)
                into v_sumap
                from tgltrans
               where codcompy  = p_codcompy
                 and numperiod = p_numperiod
                 and dtemthpay = p_dtemthpay
                 and dteyrepay = p_dteyrepay
                 and apcode    = r1.apcode;
          exception when no_data_found then
            v_sumap := 0;
          end;
          v_apcode_old := r1.apcode;
          v_count := 0;
        end if;

        v_flgdata            := 'Y';

         if upper(r1.flgdrcr) = 'DR' then
          v_dr    := r1.amtgl;
          v_cr    := 0;
          v_sumdr := v_sumdr + r1.amtgl;
        elsif upper(r1.flgdrcr) = 'CR' then
          v_dr    := 0;
          v_cr    := r1.amtgl;
          v_sumcr := v_sumcr + r1.amtgl;
        end if;

        if v_cr = 0 then
          v_cr_text := '';
        else
          v_cr_text := v_cr;
        end if;
        if v_dr = 0 then
          v_dr_text := '';
        else
          v_dr_text := v_dr;
        end if;

        v_rcnt          := v_rcnt + 1;
        obj_data             := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('apcode', r1.apcode);
        obj_data.put('rowid', r1.rowid);
        obj_data.put('desc_apcode', get_tcodec_name('tcodgrpgl',r1.apcode, global_v_lang ));
        obj_data.put('costcent', r1.costcent);
        obj_data.put('codacc', r1.codacc);
        obj_data.put('desc_codacc', get_taccodb_name('taccodb' ,r1.codacc ,global_v_lang ));
        obj_data.put('scodacc', r1.scodacc);
        obj_data.put('dramount', v_dr_text);
        obj_data.put('cramount', v_cr_text);
        obj_data.put('codcompy', r1.codcompy);       
        obj_data.put('dteyrepay', r1.dteyrepay);
        obj_data.put('dtemthpay', r1.dtemthpay);
        obj_data.put('numperiod', r1.numperiod);
        obj_data.put('typpaymt', r1.typpaymt);
        obj_data.put('flgdrcr', r1.flgdrcr);
        obj_row.put(to_char(v_rcnt-1), obj_data);
        v_count := v_count+1;
        if v_count = v_sumap then
          v_rcnt          := v_rcnt + 1;
          obj_data        := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('apcode', '');
          obj_data.put('desc_apcode',  get_tlistval_name('HRPY36X', '1', global_v_lang) ||' '|| r1.apcode );
          obj_data.put('costcent', '');
          obj_data.put('codacc', '');
          obj_data.put('desc_codacc', '');
          obj_data.put('scodacc', '');
          obj_data.put('dramount', v_sumdr);
          obj_data.put('cramount', v_sumcr);
        obj_data.put('codcompy', r1.codcompy);       
        obj_data.put('dteyrepay', r1.dteyrepay);
        obj_data.put('dtemthpay', r1.dtemthpay);
        obj_data.put('numperiod', r1.numperiod);
        obj_data.put('typpaymt', r1.typpaymt);
        obj_data.put('flgdrcr', r1.flgdrcr);
          obj_row.put(to_char(v_rcnt-1), obj_data);
          v_sumdr := 0;
          v_sumcr := 0;
        end if;
      end if;
    end loop;

    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

end HRPY36X;

/
