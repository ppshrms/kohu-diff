--------------------------------------------------------
--  DDL for Package Body HRPY7AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY7AX" as

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    p_codcomp           := hcm_util.get_string_t(obj_detail,'p_codcomp');
    p_month             := to_number(hcm_util.get_string_t(obj_detail,'p_month'));
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'p_year'));
    p_typpayroll        := hcm_util.get_string_t(obj_detail,'p_typpayroll');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if not (p_month between 1 and 12) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_row             json_object_t := json_object_t();
    obj_data            json_object_t;
    v_count             number := 0;
    v_flg_data_found    boolean := false;
    v_flg_secure        boolean := false;
    v_flg_permission    boolean := false;

    v_codcomp           tloanslf.codcomp%type;
    v_typpayroll        tloanslf.typpayroll%type;
    v_codremark         tloanslf.codremark%type;
    v_numcotax          tcompny.numcotax%type;
    v_dtepaymt          tdtepay.dtepaymt%type;

    v_amount_amtdedstu      number :=0;
    v_count_amtdedstu       number :=0;

    v_amount_amtdiffstu     number :=0;
    v_count_amtdiffstu      number :=0;

    v_amount_amtdedstuf     number :=0;
    v_count_amtdedstuf      number :=0;

    v_amount_amtdiffstuf    number :=0;
    v_count_amtdiffstuf     number :=0;

    v_amount_amtdedtot      number :=0;
    v_amount_amtdifftot     number :=0;

    cursor c1 is
      select b.numoffid,a.codempid,
             stddec(a.amtloanstu,a.codempid,global_v_chken) amtloanstu,
             stddec(a.amtloanstuf,a.codempid,global_v_chken) amtloanstuf,
             stddec(a.amtdedstu,a.codempid,global_v_chken) amtdedstu,
             stddec(a.amtdedstuf,a.codempid,global_v_chken) amtdedstuf,
             greatest(stddec(a.amtloanstu,a.codempid,global_v_chken) - stddec(a.amtdedstu,a.codempid,global_v_chken),0) amtdiffstu,
             greatest(stddec(a.amtloanstuf,a.codempid,global_v_chken) - stddec(a.amtdedstuf,a.codempid,global_v_chken),0) amtdiffstuf,
             stddec(a.amtloanstu,a.codempid,global_v_chken) + stddec(a.amtloanstuf,a.codempid,global_v_chken) totloan,
             stddec(a.amtdedstu,a.codempid,global_v_chken) + stddec(a.amtdedstuf,a.codempid,global_v_chken) totded,
             greatest(stddec(a.amtloanstu,a.codempid,global_v_chken) - stddec(a.amtdedstu,a.codempid,global_v_chken),0) +
             greatest(stddec(a.amtloanstuf,a.codempid,global_v_chken) - stddec(a.amtdedstuf,a.codempid,global_v_chken),0) totdiff,

             a.codcomp
        from tloanslf a, temploy2 b
       where a.codempid = b.codempid
         and a.codcomp like p_codcomp ||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.dteyrepay = p_year
         and a.dtemthpay = p_month
    order by b.numoffid;
  begin
    for r1 in c1 loop
      v_flg_data_found  := true;
      v_flg_secure      := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_flg_secure then
        v_flg_permission    := true;
        obj_data            := json_object_t();
        begin
            select codcomp, typpayroll, codremark
              into v_codcomp, v_typpayroll, v_codremark
              from tloanslf
             where codempid = r1.codempid
               and dtemthpay = p_month
               and dteyrepay = p_year;
        exception when no_data_found then
          null;
        end;

        begin
            select numcotax
              into v_numcotax
              from tcompny
             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1);
        exception when no_data_found then
          v_numcotax := null;
        end;

        begin
            select max(dtepaymt)
              into v_dtepaymt
              from tdtepay
             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
               and typpayroll = v_typpayroll
               and dteyrepay = p_year
               and dtemthpay = p_month;
        exception when no_data_found then
          v_dtepaymt := null;
        end;

        if r1.amtdedstu is not null and r1.amtdedstu > 0 then
            v_amount_amtdedstu          := v_amount_amtdedstu + r1.amtdedstu;
            v_count_amtdedstu           := v_count_amtdedstu + 1;
        end if;

        if r1.amtloanstu - r1.amtdedstu > 0 then
            v_amount_amtdiffstu         := v_amount_amtdiffstu + (r1.amtloanstu - r1.amtdedstu);
            v_count_amtdiffstu          := v_count_amtdiffstu + 1;
        end if;

        if r1.amtdedstuf is not null and r1.amtdedstuf > 0 then
            v_amount_amtdedstuf         := v_amount_amtdedstuf + r1.amtdedstuf;
            v_count_amtdedstuf          := v_count_amtdedstuf + 1;
        end if;

        if r1.amtloanstuf - r1.amtdedstuf > 0 then
            v_amount_amtdiffstuf        := v_amount_amtdiffstuf + (r1.amtloanstuf - r1.amtdedstuf);
            v_count_amtdiffstuf         := v_count_amtdiffstuf + 1;
        end if;

        v_amount_amtdedtot              := v_amount_amtdedtot + r1.totded;
        v_amount_amtdifftot             := v_amount_amtdifftot + r1.totdiff;

        obj_data.put('codempid', r1.codempid);
        obj_data.put('numoffid', r1.numoffid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('amtloanstu', to_char(r1.amtloanstu,'fm999,999,999,990.00'));
        obj_data.put('amtdedstu', to_char(r1.amtdedstu,'fm999,999,999,990.00'));
        obj_data.put('amtdiffstu', to_char(r1.amtdiffstu,'fm999,999,999,990.00'));
        obj_data.put('amtloanstuf', to_char(r1.amtloanstuf,'fm999,999,999,990.00'));
        obj_data.put('amtdedstuf', to_char(r1.amtdedstuf,'fm999,999,999,990.00'));
        obj_data.put('amtdiffstuf', to_char(r1.amtdiffstuf,'fm999,999,999,990.00'));
        obj_data.put('totloan', to_char(r1.totloan,'fm999,999,999,990.00'));
        obj_data.put('totded', to_char(r1.totded,'fm999,999,999,990.00'));
        obj_data.put('totdiff', to_char(r1.totdiff,'fm999,999,999,990.00'));
        obj_data.put('numcotax', v_numcotax);
        obj_data.put('codbranch','');
        obj_data.put('dtemthpay', p_month);
        obj_data.put('dteyrepay', p_year);
        obj_data.put('dtepaymnt', to_char(v_dtepaymt,'dd/mm/yyyy'));
       -- if (r1.totloan - r1.totded) = 0 then --<<user25 Date : 08/10/2021 #6261


/*--<<user20 Date : 12/10/2022 #8419
        if v_codremark is null then --<<user25 Date : 08/10/2021 #6261
            obj_data.put('flgpay','NO');
        else
            obj_data.put('flgpay','YES');
        end if;
--<<user20 Date : 12/10/2022 #8419 */
--<<user20 Date : 12/10/2022 #8419
        if v_codremark is null then --<<user25 Date : 08/10/2021 #6261
            obj_data.put('flgpay','');
        else
            obj_data.put('flgpay','Y');
        end if;
--<<user20 Date : 12/10/2022 #8419
        obj_data.put('flgsum',false);
        obj_data.put('codremark',v_codremark);
        obj_data.put('desc_codremark',GET_TLISTVAL_NAME ('REMLOANSLF',v_codremark, global_v_lang));
        obj_data.put('coderror','200');
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;

    if v_flg_data_found then
        obj_data            := json_object_t();
        obj_data.put('codempid', '');
        obj_data.put('numoffid', '');
        obj_data.put('desc_codempid', get_label_name('HRPY7AXC1',global_v_lang,160));
        obj_data.put('amtloanstu', '');
        obj_data.put('amtdedstu', to_char(v_amount_amtdedstu,'fm999,999,999,990.00'));
        obj_data.put('amtdiffstu', to_char(v_amount_amtdiffstu,'fm999,999,999,990.00'));
        obj_data.put('amtloanstuf', '');
        obj_data.put('amtdedstuf', to_char(v_amount_amtdedstuf,'fm999,999,999,990.00'));
        obj_data.put('amtdiffstuf', to_char(v_amount_amtdiffstuf,'fm999,999,999,990.00'));
        obj_data.put('totloan', '');
        obj_data.put('totded', to_char(v_amount_amtdedtot,'fm999,999,999,990.00'));
        obj_data.put('totdiff', to_char(v_amount_amtdifftot,'fm999,999,999,990.00'));
        obj_data.put('numcotax', '');
        obj_data.put('codbranch','');
        obj_data.put('dtemthpay', '');
        obj_data.put('dteyrepay', '');
        obj_data.put('dtepaymnt', '');
        obj_data.put('flgpay','');
        obj_data.put('flgsum',true);
        obj_data.put('codremark','');
        obj_data.put('coderror','200');
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;

        obj_data            := json_object_t();
        obj_data.put('codempid', '');
        obj_data.put('numoffid', '');
        obj_data.put('desc_codempid', get_label_name('HRPY7AXC1',global_v_lang,170));
        obj_data.put('amtloanstu', '');
        obj_data.put('amtdedstu', v_count_amtdedstu);
        obj_data.put('amtdiffstu', v_count_amtdiffstu);
        obj_data.put('amtloanstuf', '');
        obj_data.put('amtdedstuf', v_count_amtdedstuf);
        obj_data.put('amtdiffstuf', v_count_amtdiffstuf);
        obj_data.put('totloan', '');
        obj_data.put('totded', '');
        obj_data.put('totdiff', '');
        obj_data.put('numcotax', '');
        obj_data.put('codbranch','');
        obj_data.put('dtemthpay', '');
        obj_data.put('dteyrepay', '');
        obj_data.put('dtepaymnt', '');
        obj_data.put('flgpay','');
        obj_data.put('flgsum',true);
        obj_data.put('codremark','');
        obj_data.put('coderror','200');
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
    end if;

    if not v_flg_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLOANSLF');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
      return;
    elsif not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure save_data(json_str_input in clob,json_str_output out clob) is
    v_json_input    json_object_t := json_object_t(json_str_input);
    v_json_comp     json_object_t;
    v_json_comp_row json_object_t;

    t_tloanslf      tloanslf%rowtype;
    v_staemp        temploy1.staemp%type;

    v_zupdsal       varchar2(1);
  begin
    initial_value(json_str_input);
    v_json_comp                     := hcm_util.get_json_t(v_json_input,'params_json');
    for i in 0..(v_json_comp.get_size - 1) loop
      v_json_comp_row               := hcm_util.get_json_t(v_json_comp,to_char(i));
      t_tloanslf.codempid           := hcm_util.get_string_t(v_json_comp_row,'codempid');
      t_tloanslf.dteyrepay          := hcm_util.get_string_t(v_json_comp_row,'dteyrepay');
      t_tloanslf.dtemthpay          := hcm_util.get_string_t(v_json_comp_row,'dtemthpay');
      t_tloanslf.codremark          := hcm_util.get_string_t(v_json_comp_row,'codremark');

      update tloanslf
         set codremark = t_tloanslf.codremark
       where codempid = t_tloanslf.codempid
         and dteyrepay =  t_tloanslf.dteyrepay
         and dtemthpay = t_tloanslf.dtemthpay;
    end loop;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    else
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRPY7AX;

/
