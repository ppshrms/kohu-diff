--------------------------------------------------------
--  DDL for Package Body HRAL5LE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5LE" is
-- last update: 27/03/2018 14:16
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    -- index
    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    p_dteyear           := to_number(hcm_util.get_string_t(json_obj,'p_dteyear'));
    p_codleave          := upper(hcm_util.get_string_t(json_obj,'p_codleave'));

    -- save
    p_day11             := to_number(hcm_util.get_string_t(json_obj,'day11'));
    p_hour11            := to_number(hcm_util.get_string_t(json_obj,'hour11'));
    p_min11             := to_number(hcm_util.get_string_t(json_obj,'min11'));
    p_day22             := to_number(hcm_util.get_string_t(json_obj,'day22'));
    p_hour22            := to_number(hcm_util.get_string_t(json_obj,'hour22'));
    p_min22             := to_number(hcm_util.get_string_t(json_obj,'min22'));
    p_day33             := to_number(hcm_util.get_string_t(json_obj,'day33'));
    p_hour33            := to_number(hcm_util.get_string_t(json_obj,'hour33'));
    p_min33             := to_number(hcm_util.get_string_t(json_obj,'min33'));
    p_day44             := to_number(hcm_util.get_string_t(json_obj,'day44'));
    p_hour44            := to_number(hcm_util.get_string_t(json_obj,'hour44'));
    p_min44             := to_number(hcm_util.get_string_t(json_obj,'min44'));
    p_day55             := to_number(hcm_util.get_string_t(json_obj,'day55'));
    p_hour55            := to_number(hcm_util.get_string_t(json_obj,'hour55'));
    p_min55             := to_number(hcm_util.get_string_t(json_obj,'min55'));
    p_day66             := to_number(hcm_util.get_string_t(json_obj,'day66'));
    p_hour66            := to_number(hcm_util.get_string_t(json_obj,'hour66'));
    p_min66             := to_number(hcm_util.get_string_t(json_obj,'min66'));
    p_day77             := to_number(hcm_util.get_string_t(json_obj,'day77'));
    p_hour77            := to_number(hcm_util.get_string_t(json_obj,'hour77'));
    p_min77             := to_number(hcm_util.get_string_t(json_obj,'min77'));
    p_day88             := to_number(hcm_util.get_string_t(json_obj,'day88'));
    p_hour88            := to_number(hcm_util.get_string_t(json_obj,'hour88'));
    p_min88             := to_number(hcm_util.get_string_t(json_obj,'min88'));
    p_remark            := hcm_util.get_string_t(json_obj,'remark');
    p_qtytleav          := to_number(hcm_util.get_string_t(json_obj,'qtytleav'));
    p_dtelastle         := to_date(hcm_util.get_string_t(json_obj,'dtelastle'), 'dd/mm/yyyy');
    p_day1             := to_number(hcm_util.get_string_t(json_obj,'day1'));
    p_hour1            := to_number(hcm_util.get_string_t(json_obj,'hour1'));
    p_min1             := to_number(hcm_util.get_string_t(json_obj,'min1'));
    p_day2             := to_number(hcm_util.get_string_t(json_obj,'day2'));
    p_hour2            := to_number(hcm_util.get_string_t(json_obj,'hour2'));
    p_min2             := to_number(hcm_util.get_string_t(json_obj,'min2'));
    p_day3             := to_number(hcm_util.get_string_t(json_obj,'day3'));
    p_hour3            := to_number(hcm_util.get_string_t(json_obj,'hour3'));
    p_min3             := to_number(hcm_util.get_string_t(json_obj,'min3'));
    p_day4             := to_number(hcm_util.get_string_t(json_obj,'day4'));
    p_hour4            := to_number(hcm_util.get_string_t(json_obj,'hour4'));
    p_min4             := to_number(hcm_util.get_string_t(json_obj,'min4'));
    p_day5             := to_number(hcm_util.get_string_t(json_obj,'day5'));
    p_hour5            := to_number(hcm_util.get_string_t(json_obj,'hour5'));
    p_min5             := to_number(hcm_util.get_string_t(json_obj,'min5'));
    p_day6             := to_number(hcm_util.get_string_t(json_obj,'day6'));
    p_hour6            := to_number(hcm_util.get_string_t(json_obj,'hour6'));
    p_min6             := to_number(hcm_util.get_string_t(json_obj,'min6'));
    p_day7             := to_number(hcm_util.get_string_t(json_obj,'day7'));
    p_hour7            := to_number(hcm_util.get_string_t(json_obj,'hour7'));
    p_min7             := to_number(hcm_util.get_string_t(json_obj,'min7'));
    p_day8             := to_number(hcm_util.get_string_t(json_obj,'day8'));
    p_hour8            := to_number(hcm_util.get_string_t(json_obj,'hour8'));
    p_min8             := to_number(hcm_util.get_string_t(json_obj,'min8'));
    p_o_qtytleav       := to_number(hcm_util.get_string_t(json_obj,'o_qtytleav'));
    p_o_dtelastle      := to_date(hcm_util.get_string_t(json_obj,'o_dtelastle'), 'dd/mm/yyyy');


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codleave        varchar(4 char);
    v_typleave        varchar(4 char);
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codempid');
      return;
    end if;
    if p_codempid is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid,false);
      if param_msg_error is not null then
        return;
      else
        begin
          select codcomp, typpayroll
            into p_codcomp, p_typpayroll
            from temploy1
           where codempid = p_codempid;
        exception when no_data_found then null; --10/03/2021
        end;
      end if;
    end if;

    if p_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'dteyear');
      return;
    end if;

    if p_codleave is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codleave');
      return;
    else
      begin
        select codleave, typleave, staleave
          into v_codleave, p_typleave, p_staleave
          from tleavecd
         where codleave = p_codleave;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tleavecd');
        return;
      end;
      begin
        select typleave
          into v_typleave
          from tleavcom t1,temploy1 t2,tcenter t3
         where t1.codcompy = t3.codcompy
           and t3.codcomp  = t2.codcomp
           and t2.codempid = p_codempid
           and typleave    = (select typleave from tleavecd where codleave = p_codleave);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('AL0060', global_v_lang, 'tleavcom');
        return;
      end;
    end if;
    --<<user36 15/02/2021
    begin
      select codleave into v_codleave
        from tleavsum
       where codempid = p_codempid
         and dteyear  = (p_dteyear - global_v_zyear)
         and codleave = p_codleave;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tleavsum');
      return;
    end;
    -->>user36 15/02/2021

    begin
      select flgdlemx into p_flgdlemx
        from tleavety
       where typleave = p_typleave;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tleavety');
    end;

    begin
      select qtyavgwk into p_qtyavgwk
      from   tcontral
      where  codcompy	= hcm_util.get_codcomp_level(p_codcomp,1)
      and		 dteeffec	= ( select max(dteeffec)
                          from	 tcontral
                          where  codcompy	= hcm_util.get_codcomp_level(p_codcomp,1)
                          and	   dteeffec <= sysdate);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0012', global_v_lang, 'tcontral');
    end;
  end check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_staleave (p_codleave, v_staleave);
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_config_data(json_str_input in clob, json_str_output out clob) as
    obj_data          json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('hour', trunc(p_qtyavgwk / 60));
--      obj_data.put('min', MOD(p_qtyavgwk, 60));
      obj_data.put('min', 60);

      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) as
    obj_data          json_object_t;
    obj_dhm           json_object_t;
    v_rcnt            number := 0;

    v_day             number;
    v_date            date;
    v_qtypri          number;
    v_qtylev          number;
    v_qtyprilev       number;
    cursor c1_tleavsum is
      select codempid, codleave, dteyear, staleave,
             qtypriyr, qtyvacat, qtypriot, qtydleot, qtyprimx, qtydlemx,
             qtydayle, qtylepay, qtyadjvac, qtytleav, dtelastle, remark,
             dteupd, coduser
        from tleavsum
       where codempid = p_codempid
         and dteyear  = p_dteyear - global_v_zyear
         and codleave = p_codleave;
  begin
    obj_data        := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('desc_codempid', get_temploy_name(p_codempid, global_v_lang));
    obj_data.put('codleave', p_codleave);
    obj_data.put('desc_codleave', get_tleavecd_name(p_codleave, global_v_lang));
    obj_data.put('dteyear', p_dteyear);
    obj_data.put('staleave', v_staleave);
    obj_data.put('day1', '0');
    obj_data.put('hour1', '0');
    obj_data.put('min1', '0');
    obj_data.put('day11', '0');
    obj_data.put('hour11', '0');
    obj_data.put('min11', '0');
    obj_data.put('day2', '0');
    obj_data.put('hour2', '0');
    obj_data.put('min2', '0');
    obj_data.put('day22', '0');
    obj_data.put('hour22', '0');
    obj_data.put('min22', '0');
    obj_data.put('day3', '0');
    obj_data.put('hour3', '0');
    obj_data.put('min3', '0');
    obj_data.put('day33', '0');
    obj_data.put('hour33', '0');
    obj_data.put('min33', '0');
    obj_data.put('day4', '0');
    obj_data.put('hour4', '0');
    obj_data.put('min4', '0');
    obj_data.put('day44', '0');
    obj_data.put('hour44', '0');
    obj_data.put('min44', '0');
    obj_data.put('day5', '0');
    obj_data.put('hour5', '0');
    obj_data.put('min5', '0');
    obj_data.put('day55', '0');
    obj_data.put('hour55', '0');
    obj_data.put('min55', '0');
    obj_data.put('day6', '0');
    obj_data.put('hour6', '0');
    obj_data.put('min6', '0');
    obj_data.put('day66', '0');
    obj_data.put('hour66', '0');
    obj_data.put('min66', '0');
    obj_data.put('day7', '0');
    obj_data.put('hour7', '0');
    obj_data.put('min7', '0');
    obj_data.put('day77', '0');
    obj_data.put('hour77', '0');
    obj_data.put('min77', '0');
    obj_data.put('day8', '0');
    obj_data.put('hour8', '0');
    obj_data.put('min8', '0');
    obj_data.put('day88', '0');
    obj_data.put('hour88', '0');
    obj_data.put('min88', '0');
    obj_data.put('o_qtytleav', '0');
    obj_data.put('qtytleav', '0');
    obj_data.put('dtelastle', '');
    obj_data.put('o_dtelastle', '');
    obj_data.put('remark', '');
    obj_data.put('image', '');
    obj_data.put('codupd', '');
    obj_data.put('dteupd', '');
    obj_data.put('coduser', '');
    for c1 in c1_tleavsum loop
      v_rcnt          := v_rcnt + 1;
      obj_data.put('coderror', '200');
      if c1.staleave = 'V' then -- ????????????
        v_qtypri    := nvl(c1.qtypriyr, 0);
	      v_qtylev    := nvl(c1.qtyvacat, 0); ---- + nvl(c1.qtylepay, 0);
      elsif c1.staleave = 'C' then -- ?????????? OT
        v_qtypri    := nvl(c1.qtypriot, 0);
        v_qtylev    := nvl(c1.qtydleot, 0);
      elsif c1.staleave = 'F' then -- ????????????? (???????????)
        v_qtypri    := nvl(c1.qtyprimx, 0);
        v_qtylev    := nvl(c1.qtydlemx, 0);
      else -- ??????????
        std_al.entitlement(p_codempid, p_codleave, trunc(sysdate), global_v_zyear, v_qtylev, v_qtypri, v_date);
      end if;
      v_qtyprilev := v_qtylev - nvl(c1.qtyadjvac, 0);

      obj_dhm     := json_object_t();
      cal_dhm_t(v_qtypri, p_qtyavgwk, obj_dhm);

      obj_data.put('day1', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour1', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min1', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day11', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour11', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min11', hcm_util.get_string_t(obj_dhm, 'min'));

      v_day       := nvl(v_qtylev,0) - nvl(v_qtypri,0) - nvl(c1.qtyadjvac, 0);
      obj_dhm     := json_object_t();
      cal_dhm_t(v_day, p_qtyavgwk, obj_dhm);

      obj_data.put('day2', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour2', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min2', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day22', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour22', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min22', hcm_util.get_string_t(obj_dhm, 'min'));

      obj_dhm     := json_object_t();
      cal_dhm_t(v_qtyprilev, p_qtyavgwk, obj_dhm);

      obj_data.put('day3', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour3', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min3', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day33', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour33', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min33', hcm_util.get_string_t(obj_dhm, 'min'));

      obj_dhm     := json_object_t();
      cal_dhm_t(c1.qtydayle, p_qtyavgwk, obj_dhm);

      obj_data.put('day4', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour4', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min4', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day44', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour44', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min44', hcm_util.get_string_t(obj_dhm, 'min'));

      obj_dhm     := json_object_t();
      cal_dhm_t(c1.qtylepay, p_qtyavgwk, obj_dhm);

      obj_data.put('day5', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour5', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min5', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day55', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour55', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min55', hcm_util.get_string_t(obj_dhm, 'min'));

      v_day := nvl(v_qtyprilev,0) - nvl(c1.qtydayle, 0) - nvl(c1.qtylepay, 0);
      obj_dhm     := json_object_t();
      cal_dhm_t(v_day, p_qtyavgwk, obj_dhm);

      obj_data.put('day6', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour6', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min6', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day66', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour66', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min66', hcm_util.get_string_t(obj_dhm, 'min'));

      obj_dhm     := json_object_t();
      cal_dhm_t(c1.qtyadjvac, p_qtyavgwk, obj_dhm);

      obj_data.put('day7', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour7', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min7', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day77', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour77', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min77', hcm_util.get_string_t(obj_dhm, 'min'));

      v_day := nvl(v_day,0) + nvl(c1.qtyadjvac,0);
      obj_dhm     := json_object_t();
      cal_dhm_t(v_day, p_qtyavgwk, obj_dhm);

      obj_data.put('day8', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour8', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min8', hcm_util.get_string_t(obj_dhm, 'min'));
      obj_data.put('day88', hcm_util.get_string_t(obj_dhm, 'day'));
      obj_data.put('hour88', hcm_util.get_string_t(obj_dhm, 'hour'));
      obj_data.put('min88', hcm_util.get_string_t(obj_dhm, 'min'));

      obj_data.put('o_qtytleav', nvl(c1.qtytleav,0));
      obj_data.put('qtytleav', nvl(c1.qtytleav,0));
      obj_data.put('dtelastle', to_char(c1.dtelastle, 'dd/mm/yyyy'));
      obj_data.put('o_dtelastle', to_char(c1.dtelastle, 'dd/mm/yyyy'));
      obj_data.put('remark', c1.remark);
      obj_data.put('image', '');
      obj_data.put('codupd', get_emp_img(get_codempid(c1.coduser)));
      obj_data.put('dteupd', to_char(c1.dteupd, 'dd/mm/yyyy'));
      obj_data.put('coduser', c1.coduser || ' - ' || get_temploy_name(get_codempid(c1.coduser), global_v_lang));
    end loop;

    json_str_output := obj_data.to_clob;
  end;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    /*user37 #1595 Final Test Phase 1 V11 11/02/2021  if param_msg_error is null then
      if p_dtelastle is not null and p_dtelastle > sysdate then
        param_msg_error := get_error_msg_php('HR7018', global_v_lang, 'dtelastle');
      end if;
    end if;*/
    if param_msg_error is null then
      ins_tloglvsm;
    end if;
    if param_msg_error is null then
      ins_tleavsum;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure ins_tleavsum is
    v_qtyvacat        tleavsum.qtyvacat%type;
    v_qtypriyr        tleavsum.qtypriyr%type;
    v_qtydleot        tleavsum.qtydleot%type;
    v_qtypriot        tleavsum.qtypriot%type;
    v_numrec          number;
    v_dtecycst        date;
    v_dtecycen        date;
  begin
    begin
      p_qtydayle      := nvl(p_day44, 0) + (((nvl(p_hour44, 0) * 60) + nvl(p_min44, 0)) / p_qtyavgwk);
      p_qtylepay      := nvl(p_day55, 0) + (((nvl(p_hour55, 0) * 60) + nvl(p_min55, 0)) / p_qtyavgwk);
      p_qtyadjvac     := nvl(p_day77, 0) + (((nvl(p_hour77, 0) * 60) + nvl(p_min77, 0)) / p_qtyavgwk);
      if p_staleave = 'V' then
        v_qtyvacat  := nvl(p_day33, 0) + (((nvl(p_hour33, 0) * 60) + nvl(p_min33, 0)) / p_qtyavgwk);
        v_qtyvacat  := nvl(v_qtyvacat, 0) + p_qtyadjvac; ----  - nvl(nvl(p_qtylepay, 0), 0);
        v_qtypriyr  := nvl(p_day11, 0) + (((nvl(p_hour11, 0) * 60) + nvl(p_min11, 0)) / p_qtyavgwk);
      elsif p_staleave = 'C' then
        v_qtydleot  := nvl(p_day33, 0) + (((nvl(p_hour33, 0) * 60) + nvl(p_min33, 0)) / p_qtyavgwk);
        v_qtydleot  := nvl(v_qtydleot, 0) + p_qtyadjvac;
        v_qtypriot  := nvl(p_day11, 0) + (((nvl(p_hour11, 0) * 60) + nvl(p_min11, 0)) / p_qtyavgwk);
      end if;
    exception when others then
      param_msg_error := get_error_msg_php('HR2020', global_v_lang);
      return;
    end;

    begin
      insert into tleavsum
             (codempid, dteyear, codleave, typleave,
              typpayroll, codcomp, staleave,
              qtydayle, qtytleav, dtelastle,
              qtypriyr, qtyvacat, qtypriot, qtydleot,
              qtylepay, qtyadjvac, remark,
              codcreate, dtecreate, coduser)
      values (p_codempid, (p_dteyear - global_v_zyear), p_codleave, p_typleave,
              p_typpayroll, p_codcomp, p_staleave,
              p_qtydayle, p_qtytleav, p_dtelastle,
              v_qtypriyr, v_qtyvacat, v_qtypriot, v_qtydleot,
              p_qtylepay, p_qtyadjvac, p_remark,
              global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
      update tleavsum
         set qtydayle  = p_qtydayle,
             qtytleav  = p_qtytleav,
             dtelastle = p_dtelastle,
             qtypriyr  = v_qtypriyr,
             qtyvacat  = v_qtyvacat,
             qtypriot  = v_qtypriot,
             qtydleot  = v_qtydleot,
             qtylepay  = p_qtylepay,
             qtyadjvac = p_qtyadjvac,
             remark    = p_remark,
             coduser   = global_v_coduser,
             dteupd    = sysdate
       where codempid = p_codempid
         and dteyear  = (p_dteyear - global_v_zyear)
         and codleave = p_codleave;
    end;
    --
--<< user22 : 17/01/2023 : ST11 ||    
    std_al.cycle_leave2(hcm_util.get_codcomp_level(p_codcomp,1),p_codempid,p_codleave,p_dteyear,v_dtecycst,v_dtecycen);
    hral82b_batch.gen_vacation(p_codempid,p_codcomp,v_dtecycst,global_v_coduser,v_numrec);
    --hral82b_batch.gen_vacation(p_codempid,p_codcomp,sysdate,global_v_coduser,v_numrec);
-->> user22 : 17/01/2023 : ST11 ||
  end;

  procedure ins_tloglvsm is
    v_numseq        number := 0;
    v_day           number;
    v_hour          number;
    v_min           number;
    v_qtypri        number;
    v_qtylev        number;
    obj_dhm         json_object_t;

    v_o_qtypri      number;
    v_o_qtylev      number;
    v_o_qtydayle    number;
    v_o_qtylepay    number;
    v_o_qtyadjvac   number;
    v_o_qtytleav    number;
    v_o_dtelastle   date;

    v_remark        varchar2(4000 char);
    v_o_remark      varchar2(4000 char);

    type char1 is table of varchar2(100) index by binary_integer;
      v_desfld        char1;
      v_desold        char1;
      v_desnew        char1;

    cursor c1_tleavsum is
      select qtydayle, qtylepay, qtyadjvac, qtytleav, dtelastle, remark
        from tleavsum
       where codempid = p_codempid
         and dteyear  = p_dteyear - global_v_zyear
         and codleave = p_codleave;
  begin
    begin
      p_qtydayle      := nvl(p_day44, 0) + (((nvl(p_hour44, 0) * 60) + nvl(p_min44, 0)) / p_qtyavgwk);
      p_qtylepay      := nvl(p_day55, 0) + (((nvl(p_hour55, 0) * 60) + nvl(p_min55, 0)) / p_qtyavgwk);
      p_qtyadjvac     := nvl(p_day77, 0) + (((nvl(p_hour77, 0) * 60) + nvl(p_min77, 0)) / p_qtyavgwk);
    exception when others then
      param_msg_error := get_error_msg_php('HR2020', global_v_lang);
      return;
    end;
    v_remark        := p_remark;
    for c1 in c1_tleavsum loop
      v_o_qtydayle  := nvl(c1.qtydayle,0);
      v_o_qtylepay  := nvl(c1.qtylepay,0);
      v_o_qtyadjvac := nvl(c1.qtyadjvac,0);
      v_o_qtytleav  := nvl(c1.qtytleav,0);
      v_o_dtelastle := c1.dtelastle;
      v_o_remark    := c1.remark;
    end loop;
    v_qtypri := nvl(p_day11,0) + (((nvl(p_hour11,0) * 60) + nvl(p_min11,0)) / p_qtyavgwk);
    v_o_qtypri := nvl(p_day1,0) + (((nvl(p_hour1,0) * 60) + nvl(p_min1,0)) / p_qtyavgwk);
    v_desfld(1) := 'QTYPRIYR';
    v_desold(1) := round(nvl(v_o_qtypri,0),10);
    v_desnew(1) := round(nvl(v_qtypri,0),10);

    v_qtylev := nvl(p_day22,0) + (((nvl(p_hour22,0) * 60) + nvl(p_min22,0)) / p_qtyavgwk);
    v_o_qtylev := nvl(p_day2,0) + (((nvl(p_hour2,0) * 60) + nvl(p_min2,0)) / p_qtyavgwk);
    v_desfld(2) := 'QTYVACAT';
    v_desold(2) := round(nvl(v_o_qtylev,0),10);
    v_desnew(2) := round(nvl(v_qtylev,0),10);

    v_desfld(3) := 'QTYDAYLE';
    v_desold(3) := round(nvl(v_o_qtydayle,0),10);
    v_desnew(3) := round(nvl(p_qtydayle,0),10);

    v_desfld(4) := 'QTYLEPAY';
    v_desold(4) := round(nvl(v_o_qtylepay,0),10);
    v_desnew(4) := round(nvl(p_qtylepay,0),10);

    v_desfld(5) := 'QTYADJVAC';
    v_desold(5) := round(nvl(v_o_qtyadjvac,0),10);
    v_desnew(5) := round(nvl(p_qtyadjvac,0),10);

    v_desfld(6) := 'QTYTLEAV';
    v_desold(6) := nvl(v_o_qtytleav,0);
    v_desnew(6) := nvl(p_qtytleav,0);

    v_desfld(7) := 'REMARK';
    v_desold(7) := nvl(v_o_remark,'NULL');
    v_desnew(7) := nvl(p_remark,'NULL');

    for i in 1..7 loop
      if v_desold(i) <> v_desnew(i) then
        v_numseq := v_numseq + 1;
        if i <= 5 then
          /*10/03/2021 cancel format day:hour:min in data for keep log
          obj_dhm := json_object_t();
          cal_dhm_t(v_desold(i), p_qtyavgwk, obj_dhm);
          v_desold(i) := hcm_util.get_string_t(obj_dhm, 'day')||':'||lpad(hcm_util.get_string_t(obj_dhm, 'hour'),2,'0')||':'||lpad(hcm_util.get_string_t(obj_dhm, 'min'),2,'0');

          obj_dhm := json_object_t();
          cal_dhm_t(v_desnew(i), p_qtyavgwk, obj_dhm);
          v_desnew(i) := hcm_util.get_string_t(obj_dhm, 'day')||':'||lpad(hcm_util.get_string_t(obj_dhm, 'hour'),2,'0')||':'||lpad(hcm_util.get_string_t(obj_dhm, 'min'),2,'0');
          */
          --<<10/03/2021
          if v_desold(i) is not null and v_desold(i) - trunc(v_desold(i)) > 0 then
            v_desold(i) := to_char(v_desold(i), 'fm999999999999990.9999999999');
          end if;
          if v_desnew(i) is not null and v_desnew(i) - trunc(v_desnew(i)) > 0 then
            v_desnew(i) := to_char(v_desnew(i), 'fm999999999999990.9999999999');
          end if;
          -->>10/03/2021
        end if;

        if i = 7 then
            v_desold(i) := replace(v_desold(i),'NULL','');
            v_desnew(i) := replace(v_desnew(i),'NULL','');
        end if;

        begin
          insert into tloglvsm(dteupd, codempid, dteyear, codleave, numseq,
                              codcomp, desfld, desold, desnew, coduser, remark, codcreate)
                        values(sysdate, p_codempid, (p_dteyear - global_v_zyear), p_codleave, v_numseq,
                              p_codcomp, v_desfld(i), v_desold(i), v_desnew(i), global_v_coduser, v_remark, global_v_coduser);
        exception when others then
          null;
        end;
      end if;
    end loop;
    if (nvl(v_o_dtelastle, to_date('01/01/1111', 'dd/mm/yyyy')) <> nvl(p_dtelastle, to_date('01/01/1111', 'dd/mm/yyyy'))) then
      v_numseq := v_numseq + 1;
      begin
        insert into tloglvsm(dteupd, codempid, dteyear, codleave, numseq,
                            codcomp, desfld, desold, desnew, coduser, remark, codcreate)
                      values(sysdate, p_codempid, (p_dteyear - global_v_zyear), p_codleave, v_numseq,
                            p_codcomp, 'DTELASTLE', to_char(v_o_dtelastle, 'dd/mm/yyyy'), to_char(p_dtelastle, 'dd/mm/yyyy'), global_v_coduser, v_remark, global_v_coduser);
      exception when others then
        null;
      end;
    end if;
  end;

  procedure gen_staleave (v_codleave in TLEAVECD.CODLEAVE%TYPE, flg_staleave out TLEAVECD.STALEAVE%TYPE) is
  begin
    begin
      select staleave
        into flg_staleave
        from tleavecd
       where codleave = v_codleave
         and rownum = 1;
    exception when no_data_found then
      flg_staleave := '';
    end;
  end gen_staleave;

end HRAL5LE;

/
