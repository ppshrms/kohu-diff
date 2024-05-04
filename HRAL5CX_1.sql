--------------------------------------------------------
--  DDL for Package Body HRAL5CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5CX" as
  function get_qtyavgwk(v_codcomp varchar2, v_codempid varchar2) return number as
  begin
    return hcm_util.get_qtyavgwk(v_codcomp,v_codempid);
  end;

  function day_to_dhhmm(v_day number,v_qtyavgwk number) return varchar2 as
    v_tokenday number;
    v_tokenhr  number;
    v_tokenmin number;
    v_tokendhm varchar2(4000 char);
  begin
    hcm_util.cal_dhm_hm (v_day,0,0,v_qtyavgwk,'1',v_tokenday,v_tokenhr,v_tokenmin,v_tokendhm);
    return v_tokendhm;
  end;
  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_typleave2         := hcm_util.get_string_t(json_obj,'p_typleave');
    p_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
    p_typleave          := hcm_util.get_json_t(json_obj,'param_json');
    p_codleave_array    := hcm_util.get_json_t(json_obj, 'p_codleave');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      str_typleave        := convert_typleave_to_str(p_typleave);
      if p_codempid is not null then
        begin
          select codcomp
            into p_codcomp
            from temploy1
           where codempid = p_codempid;
        exception when no_data_found then
          null;
        end;
      end if;
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_index as
    v_staemp            temploy1.staemp%type;
    v_flgsecu           boolean := true;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      elsif v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      else
        v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      end if;
    end if;

    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_typleave is null or p_typleave.get_size < 1 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    v_typleave   tleavety.typleave%type;
    v_codleave   tleavecd.codleave%type;
    v_codempid   temploy1.codempid%type;
    v_codcomp    temploy1.codcomp%type;
    v_balance    number;
    v_overlimit  number;
    v_qtywkday   number;
    v_flgfound   boolean;
    v_flgsecur   boolean := false;
    v_syncond    varchar2(4000 char);
    v_stmt       clob;
    v_qtypri     number;
    v_qtyleave   number;
    v_qtypriyr   number;
    v_qtyvacat   number;
    v_qtypriot   number;
    v_qtydleot   number;
    v_qtyprimx   number;
    v_qtydlemx   number;
    t_qtypri     number;
    t_qtyleave   number;
    v_remain1    number;
    v_remain2    number;
    v_remain3    number;
    v_use1       number;
    v_use2       number;
    v_use3       number;
    v_bal        number;
    v_over       number;
    v_svyre      number;
    v_svmth      number;
    v_svday      number;
    v_qtyday     number;

    v_dteeffec   date;
    v_qtylepay   number;

    obj_data     json_object_t;
    obj_row      json_object_t := json_object_t();
    v_count      number := 0;
    v_exist      boolean := false;
    v_permission boolean := false;
    v_date       date := to_date('3112'||to_char(p_year),'ddmmyyyy');
    v_qtyavgwk   number;
    v_qtyadjvac  number;
    v_codempido  temploy1.codempid%type := '';

    v_dtecycst	 date;
		v_dtecycen	 date;

    v_staleave      tleavsum.staleave%type;
    v_maincodleave  tleavecd.codleave%type;

    cursor c1 is
      select a.codempid, a.codcomp, a.typpayroll, a.dteempmt, a.dteeffex,
             a.staemp, a.numlvl, a.codpos, a.codsex, a.codempmt, a.typemp,
             nvl(a.qtywkday,0) qtywkday, b.codrelgn, a.jobgrade, c.amtincom1
        from temploy1 a,temploy2 b, temploy3 c
       where a.codempid = b.codempid
         and a.codempid = c.codempid
         and a.codempid = nvl(p_codempid,a.codempid)
         and a.codcomp  like p_codcomp || '%'
         and(a.staemp   in ('1','3')
          or(a.staemp   = '9' and to_char(a.dteeffex - 1,'YYYY') >= p_year))
    order by codcomp,a.codempid;

    cursor c2 is
      select typleave, flgdlemx, nvl(qtydlepay, 0) qtydlepay
        from tleavety
       where typleave in (select typleave
                            from tleavety
                           where typleave in (select x.split_values as res_data
                            from (with t as
                                   (select str_typleave str
                                      from dual
                                     where str_typleave is not null
                                   )
                                 select regexp_substr (str, '[^,]+', 1, level) split_values
                                   from t
                             connect by regexp_substr(str, '[^,]+', 1, level) is not null
                                 ) x
                              )
                         )
    order by typleave;

    cursor c3 is
      select c.*,rownum --15/02/2021
        from (select t1.syncond, t1.codleave, t1.staleave
                from tleavecd t1, tleavcom t2
               where t1.typleave = v_typleave
                 and t1.typleave = t2.typleave
                 and t2.codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
            order by t1.codleave) c;

    cursor c4 is
      select a.codleave,nvl(a.qtypriyr,0) qtypriyr,nvl(a.qtyvacat,0) qtyvacat,nvl(a.qtypriot,0) qtypriot,
             nvl(a.qtydleot,0) qtydleot,nvl(a.qtyprimx,0) qtyprimx,nvl(a.qtydlemx,0) qtydlemx,nvl(a.qtydayle,0) qtydayle,nvl(a.qtylepay,0) qtylepay,
             nvl(a.qtyadjvac,0) qtyadjvac
        from tleavsum a
       where a.codempid = v_codempid
         and a.dteyear  = p_year
         and a.typleave = v_typleave;

  begin
    v_qtyavgwk := get_qtyavgwk(p_codcomp, p_codempid);
    for r1 in c1 loop
      v_codcomp    := r1.codcomp;
      v_permission := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if v_permission then
        v_flgsecur := true;
        for r2 in c2 loop
          v_typleave  := r2.typleave;
          -- init typleave data
          v_flgfound          := false;
          v_balance           := 0;
          v_overlimit         := 0;
          v_qtypri            := 0;
          v_qtyleave          := 0;
          v_qtypriyr          := 0;
          v_qtyvacat          := 0;
          v_qtypriot          := 0;
          v_qtydleot          := 0;
          v_qtyprimx          := 0;
          v_qtydlemx          := 0;
          t_qtypri            := 0;
          t_qtyleave          := 0;
          v_remain1           := 0;
          v_remain2           := 0;
          v_remain3           := 0;
          v_use1              := 0;
          v_use2              := 0;
          v_use3              := 0;
          v_bal               := 0;
          v_over              := 0;
          v_svyre             := 0;
          v_svmth             := 0;
          v_svday             := 0;
          v_qtyday            := 0;
          v_typleave          := r2.typleave;
          v_qtyadjvac         := 0;
          --<<16/06/2021
          --if 1 codleave in 1 p_typleave2 have staleave = 'V' --> v_staleave = 'V'-Vacation Leave
          begin
            select staleave ,codleave
              into v_staleave ,v_maincodleave
              from tleavecd
             where typleave = r2.typleave
               and staleave = 'V'
               and rownum = 1;
          exception when no_data_found then null;

            begin
              select staleave ,codleave
                into v_staleave ,v_maincodleave
                from tleavecd
               where typleave = r2.typleave
                 and rownum = 1;
            exception when no_data_found then null;
            end;
          end;
          std_al.cycle_leave2(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempid,v_maincodleave,p_year,v_dtecycst,v_dtecycen);
--          v_date := v_dtecycen;
          if r1.staemp = '9' then --26/07/2021
            v_date := v_dtecycst;
          else
            --24/09/2021--v_date := trunc(sysdate);
            if p_year >= to_char(sysdate,'yyyy') then --24/09/2021
              v_date := trunc(sysdate);
            else
              v_date := v_dtecycst;
            end if;
          end if;
          -->>16/06/2021
          for r3 in c3 loop
            v_codleave        := r3.codleave;
            --<<15/02/2021
            --16/06/2021
            /*if r3.rownum = 1 then
              std_al.cycle_leave2(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempid,v_codleave,p_year,v_dtecycst,v_dtecycen);
              v_date := v_dtecycen;
            end if;*/
            -->>15/02/2021
            begin
              -- check syncond
              v_flgfound := false;
              v_flgfound := hral56b_batch.check_condition_leave(r1.codempid,v_codleave,sysdate,'1');
              if v_flgfound then
                v_exist      := true;
                --<<16/06/2021
                std_al.entitlement(r1.codempid, v_maincodleave, v_date
                , global_v_zyear, v_qtyleave, v_qtypriyr, v_dteeffec);
                v_qtypri := nvl(v_qtypriyr,0);
                begin
                  select nvl(qtyadjvac,0),nvl(qtylepay,0)
                        ,nvl(qtypriyr,0),nvl(qtyvacat,0) --27/09/2021
                    into v_qtyadjvac,v_qtylepay
                        ,v_qtypriyr,v_qtyvacat --27/09/2021
                    from tleavsum
                   where codempid = r1.codempid
                     and dteyear  = p_year
                     and codleave = v_codleave;
                exception when no_data_found then
                  v_qtyadjvac := 0;
                  v_qtylepay  := 0;
                  v_qtypriyr  := 0;
                  v_qtyvacat  := 0;
                end;
                if v_staleave = 'V' then --27/09/2021
                  v_qtypri    := nvl(v_qtypriyr,0);
                  v_qtyleave  := greatest(v_qtyvacat - v_qtylepay,0);
                end if;
                v_qtyleave := nvl(v_qtyleave,0) - v_qtypri - v_qtyadjvac + v_qtylepay;
                exit;
              end if; --if v_flgfound
            exception when no_data_found then null;
            end;
          end loop; --c3 loop
          --
          if v_flgfound then
            v_codempid := r1.codempid;
            ----v_qtyadjvac := 0;
            for r4 in c4 loop
              v_use1      := v_use1 + r4.qtydayle;
              v_use2      := v_use2 + r4.qtylepay;
              ----v_qtyadjvac := v_qtyadjvac + r4.qtyadjvac;
            end loop;
            v_remain1   := nvl(v_qtypri,0);
            v_remain2   := nvl(v_qtyleave,0); --test comment - v_qtyadjvac;
            v_remain3   := v_remain1 + v_remain2;

            v_use3      := v_use1 + v_use2 ;
            v_bal       := nvl(v_remain3,0) - nvl(v_use3,0) + v_qtyadjvac;
            v_bal       := v_bal + v_balance + (-1*v_overlimit);
            if v_bal > 0 then
              v_balance   := v_bal;
              v_overlimit := 0;
            else
              v_balance   := 0;
              v_overlimit := (-1)*v_bal;
            end if;
            obj_data      := json_object_t();
            obj_data.put('coderror', 200);
            obj_data.put('image2', get_emp_img(v_codempid));
            obj_data.put('codempid2', v_codempid);
            obj_data.put('desc_codempid2', get_temploy_name(v_codempid, global_v_lang));

            if nvl(v_codempido,'') = v_codempid then
                obj_data.put('flgskip', 'Y');
                obj_data.put('image', '');
                obj_data.put('codempid', '');
                obj_data.put('desc_codempid', '');
            else
                obj_data.put('image', get_emp_img(v_codempid));
                obj_data.put('codempid', v_codempid);
                obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));

                v_codempido := v_codempid;
            end if;
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('codleave', v_typleave);
            obj_data.put('desc_codleave', get_tleavety_name(v_typleave, global_v_lang));
            obj_data.put('carryover', cal_dhm_concat(v_remain1, v_qtyavgwk));
            obj_data.put('thisyear', cal_dhm_concat(v_remain2 , v_qtyavgwk));
            obj_data.put('totalava', cal_dhm_concat(v_remain3 , v_qtyavgwk));
            obj_data.put('actleave', cal_dhm_concat(v_use1  , v_qtyavgwk));
            obj_data.put('cashout', cal_dhm_concat(v_use2  , v_qtyavgwk));
            obj_data.put('totaluse', cal_dhm_concat(v_use3  , v_qtyavgwk));
            obj_data.put('qtyadjvac', cal_dhm_concat(v_qtyadjvac  , v_qtyavgwk));
            obj_data.put('balance', nvl(cal_dhm_concat(v_balance  , v_qtyavgwk),'0:00:00'));
            obj_data.put('overlimit', cal_dhm_concat(v_overlimit, v_qtyavgwk));
            obj_row.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
          end if;
        end loop;-- c2 loop
      end if;
    end loop;-- c1 loop

    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tleavsum');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif not v_flgsecur then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
			json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_detail as
    v_staemp            temploy1.staemp%type;
    v_flgsecu           boolean := true;
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_typleave2 is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      elsif v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      else
        v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      end if;
    end if;

    if p_typleave2 is not null then
      begin
        select typleave
          into p_typleave2
          from tleavety
         where typleave = p_typleave2;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tleavety');
        return;
      end;
    end if;
  end;

  procedure gen_detail(json_str_output out clob) as
    obj_table          json_object_t := json_object_t();
    obj_detail         json_object_t := json_object_t();
    obj_detail2        json_object_t;
    obj_rows           json_object_t := json_object_t();
    obj_data           json_object_t;
    obj_data_last      json_object_t := json_object_t();
    v_count            number := 0;
    v_qtyavgwk         number;

    v_codcomp          temploy1.codcomp%type;
    v_staemp           temploy1.staemp%type;

    v_qtyprimx         tleavsum.qtyprimx%type;
    v_qtypriyr         tleavsum.qtypriyr%type;
    v_qtypriot         tleavsum.qtypriot%type;
    v_qtydlemx         tleavsum.qtydlemx%type;
    v_qtyvacat         tleavsum.qtyvacat%type;
    v_qtydleot         tleavsum.qtydleot%type;
    v_staleave         tleavsum.staleave%type;
    ----vv_staleave        tleavsum.staleave%type;
    v_codleave         tleavsum.codleave%type;
    v_flgdlemx         tleavety.flgdlemx%type;

    v_balance          number := 0;
    v_qtypri_all       number := 0;
    v_qtyleave_all     number := 0;
    v_qtypri           number := 0;
    v_qtyleave         number := 0;
    v_date             date := to_date('31/12/'||p_year,'dd/mm/yyyy');
    v_dteeffect        date;

    v_syncond          varchar2(4000 char);
    v_stmt             clob;
    v_flgfound         boolean;
    v_qtywkday         number;

    v_dtestr           date;
    v_dteend           date;

    v_qtylepay         number;

    v_year             number;
    v_dtecycst         date;
    v_dtecycen         date;

    v_curr_month       number;
    v_curr_year        number;

    v_count_month      number;

    v_tmpdate          date;
    v_coll_lv          number := 0;
    v_coll_lv_hide     number := 0;
    v_qtyday           number := 0;
    v_qtyadjvac        number := 0;
    v_prev_qtypriyr    number := 0;
    v_rndst            varchar2(100 char);
    v_rnden            varchar2(100 char);
    v_qtyvacat_show    tleavsum.qtyvacat%type;

  	cursor c1 is
      select t1.syncond, t1.codleave, t1.staleave
        from tleavecd t1,tleavcom t2
       where t1.typleave = t2.typleave
         and t1.typleave = p_typleave2
         and t2.codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
    order by t1.codleave;

    cursor c2 is
      select nvl(sum(qtyday),0) v_qtyday --,codleave
        from tleavetr
       where codempid = p_codempid
         and dtework between v_dtestr and v_dteend
         and codleave = v_codleave
    --group by codleave
    ;

    cursor c3 is --06/03/2021
      select nvl(sum(qtyday),0) v_qtyday
        from tleavetr
       where codempid = p_codempid
         and dtework between v_dtestr and v_dteend
         and codleave in (select t1.codleave
                            from tleavecd t1, tleavcom t2
                           where t1.typleave = t2.typleave
                             and t1.typleave = p_typleave2
                             and t2.codcompy = hcm_util.get_codcomp_level(v_codcomp,1));

    --<<16/02/2021
    cursor c_tleavsum2 is
      select nvl(sum(nvl(qtypriyr,0)),0) qtypriyr
            , nvl(sum(nvl(qtyvacat,0)),0) qtyvacat
            , nvl(sum(nvl(qtyvacat,0) - nvl(qtypriyr,0)),0) qtyvacat_dedpri --21/04/2021
        from tleavsum2
       where codempid = p_codempid
         and dteyear  = p_year
         and monthno  = v_curr_month
         and codleave in (select t1.codleave
                            from tleavecd t1, tleavcom t2
                           where t1.typleave = t2.typleave
                             and t1.typleave = p_typleave2
                             and t2.codcompy = hcm_util.get_codcomp_level(v_codcomp,1));
    -->>16/02/2021

  begin
    begin
      select codcomp,staemp --26/07/2021
        into v_codcomp,v_staemp --26/07/2021
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := null;
    end;

    begin
      select flgdlemx
        into v_flgdlemx
        from tleavety
       where typleave = p_typleave2;
    exception when no_data_found then null;
    end;

    --<<16/02/2021
    --if 1 codleave in 1 p_typleave2 have staleave = 'V' --> v_staleave = 'V'-Vacation Leave
    begin
      select codleave
            ,staleave --16/02/2021
        into v_codleave
            ,v_staleave --16/02/2021
        from tleavecd
       where typleave = p_typleave2
         and staleave = 'V'
         and rownum = 1;
    exception when no_data_found then null;

    -->>16/02/2021
      begin
        select codleave
              ,staleave --16/02/2021
          into v_codleave
              ,v_staleave --16/02/2021
          from tleavecd
         where typleave = p_typleave2
           and rownum = 1;
      exception when no_data_found then null;
      end;
    end;--16/02/2021
    --<<15/02/2021
    /*std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,v_codleave,to_date('0101'||to_char(p_year),'ddmmyyyy'),v_year,v_dtecycst,v_dtecycen);
    if v_year <> p_year then
      std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,v_codleave,to_date('0101'||to_char(p_year+(p_year-v_year)),'ddmmyyyy'),v_year,v_dtecycst,v_dtecycen);
    end if;*/
    std_al.cycle_leave2(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,v_codleave,p_year,v_dtecycst,v_dtecycen);
--    v_date := v_dtecycen;
    if v_staemp = '9' then --26/07/2021
      v_date := v_dtecycst;
    else
      --24/09/2021--v_date := trunc(sysdate);
      if p_year >= to_char(sysdate,'yyyy') then --24/09/2021
        v_date := trunc(sysdate);
      else
        v_date := v_dtecycst;
      end if;
    end if;
    -->>15/02/2021
    --09/04/2021
    if v_dtecycst is null or v_dtecycen is null then
      v_dtecycst := to_date('0101'||to_char(p_year),'ddmmyyyy');
      v_dtecycen := to_date('3112'||to_char(p_year),'ddmmyyyy');
    end if;

    v_qtyavgwk := get_qtyavgwk(null, p_codempid);

    obj_table.put('codempid',p_codempid);
    obj_table.put('desc_codempid',get_temploy_name(p_codempid,global_v_lang));
    obj_table.put('codleave',p_typleave2);
    obj_table.put('desc_codleave',get_tleavety_name(p_typleave2,global_v_lang));
    --10/06/2021--obj_table.put('year',p_year);

    obj_detail.put('index','#');
    obj_detail.put('detail',get_label_name('HRAL5CXC1',global_v_lang,'90') || ' ' || to_char(p_year));
    for i in 0..11 loop
      v_curr_month := to_number(to_char(v_dtecycst,'mm')) + i;
      v_curr_year  := to_number(to_char(v_dtecycst,'yyyy'));
      if v_curr_month > 12 then
        v_curr_month := v_curr_month - 12;
        v_curr_year  := v_curr_year + 1;
      end if;
      if to_date('01'||to_char(v_curr_month,'00')||to_char(v_curr_year,'0000'),'ddmmyyyy') > v_dtecycen then
        exit;
      end if;
      v_count_month := i;
      obj_detail2 := json_object_t();
      obj_detail2.put('description',get_label_name('HRAL5CXC2',global_v_lang,to_char(4 + v_curr_month) || '0'));
      obj_detail2.put('year',to_char(v_curr_year));
      if i = 0 then --10/06/2021--
        v_rndst := get_label_name('HRAL5CXC2',global_v_lang,to_char(4 + v_curr_month) || '0')||' '||to_char(v_curr_year+hcm_appsettings.get_additional_year);
      end if;
      if i = 11 then --10/06/2021--
        v_rnden := get_label_name('HRAL5CXC2',global_v_lang,to_char(4 + v_curr_month) || '0')||' '||to_char(v_curr_year+hcm_appsettings.get_additional_year);
      end if;
      obj_detail.put('month' || to_char(i + 1),obj_detail2);
    end loop;
    obj_table.put('year',to_char(p_year+hcm_appsettings.get_additional_year)||' ('||v_rndst||' - '||v_rnden||')'); --10/06/2021--


    obj_table.put('count_month',to_char(v_count_month + 1));
    obj_table.put('header',obj_detail);

    for r1 in c1 loop
      if hral56b_batch.check_condition_leave(p_codempid,r1.codleave,sysdate,'1') then
        if v_staleave <> 'V' then --16/06/2021
          std_al.entitlement(p_codempid,/*r1.codleave*/v_codleave,v_date,0,/*v_qtyleave*/v_qtyvacat,v_qtypri,v_dteeffect);
        end if;
      end if;
    end loop;
    v_qtypri_all   := nvl(v_qtypri,0);

    --add 1st line header [Previous Year's Privilege]
    obj_data := json_object_t();
    obj_data.put('index',to_char(v_count + 1));
    obj_data.put('detail',get_label_name('HRAL5CXC1',global_v_lang,'101'));
    if v_staleave = 'V' then
      for i in 0..v_count_month loop
        v_curr_month := i + 1;
        for j in c_tleavsum2 loop
          if j.qtypriyr > 0 then
            obj_data.put('month' || to_char(i+1),nvl(day_to_dhhmm(j.qtypriyr,v_qtyavgwk),' '));
          end if;
        end loop;
      end loop;
    else
    -->>16/02/2021
      obj_data.put('month1',nvl(day_to_dhhmm(v_qtypri_all,v_qtyavgwk),'0:00:00'));
    end if; --16/02/2021
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    --add 2nd line header [This Year's Privilege]
    obj_data := json_object_t();
    obj_data.put('index',to_char(v_count + 1));
    obj_data.put('detail',get_label_name('HRAL5CXC1',global_v_lang,'140'));
    obj_data_last.put('detail',get_label_name('HRAL5CXC1',global_v_lang,'120')); -- summary last line
    v_coll_lv_hide := 0; --21/04/2021
    for i in 0..v_count_month loop -- v_dtecycst, v_dtecycen
--      -- init start end
--      v_curr_month := to_number(to_char(v_dtecycst,'mm')) + i;
--      v_curr_year  := to_number(to_char(v_dtecycst,'yyyy'));
--      if v_curr_month > 12 then
--        v_curr_month := v_curr_month - 12;
--        v_curr_year  := v_curr_year + 1;
--      end if;
      --<<16/02/2021 if staleave = 'V' ,find new v_qtyleave from tleavsum2
      if v_staleave = 'V' then
        if i = 0 then
          v_coll_lv := 0;
          v_qtylepay := 0;
        else
          get_day(v_dtecycst,0,v_dtestr,v_tmpdate); --18/02/2021 --for fix first day of leave year
          get_day(v_dtecycst,(i-1),v_tmpdate,v_dteend); --18/02/2021
          for r2 in c3 loop --06/03/2021 ||c2 loop
            v_coll_lv := nvl(r2.v_qtyday,0);
          end loop;
          begin --21/04/2021
            select nvl(sum(qtylepay),0)
              into v_qtylepay
              from tpayvac
             where codempid   = p_codempid
               and dteyrepay  = p_year
--               and dtemthpay  between to_number(to_char(v_dtestr,'mm')) and to_number(to_char(v_dteend,'mm')) ----between 1 and (i + 1)
               and to_number(to_char(dteyrepay)||lpad(to_char(dtemthpay),2,'0')) between to_number(to_char(v_dtestr,'yyyy')||to_char(v_dtestr,'mm'))
                                                                         and to_number(to_char(v_dteend,'yyyy')||to_char(v_dteend,'mm')) --21/04/2021
               and staappr    = 'Y';
            v_coll_lv := v_coll_lv + v_qtylepay;
          exception when no_data_found then
            v_qtylepay := 0;
          end;
        end if;
        v_curr_month := i + 1; --18/02/2021
        for j in c_tleavsum2 loop
--          v_qtypri   := j.qtypriyr;
--          v_qtyleave := j.qtyvacat;
          if j.qtypriyr - v_coll_lv >= 0 then
            v_qtypriyr := j.qtypriyr - v_coll_lv;
            v_qtyleave := j.qtyvacat_dedpri
                          + v_qtypriyr --24/04/2021
                          ;
          else
            --if v_coll_lv_hide = 0 then --find first time
              v_coll_lv_hide := least(v_coll_lv,v_prev_qtypriyr);----
            --end if;
            if v_qtypriyr > 0 and j.qtypriyr = 0
            then --This month end of tleavsum2.qtypriyr(=0)
              ----v_coll_lv_hide := least(v_coll_lv,v_qtypriyr);
              v_qtypriyr := 0;
            end if;

            v_qtyleave := j.qtyvacat_dedpri - (v_coll_lv - v_coll_lv_hide); --21/04/2021 ----v_qtyleave := j.qtyvacat + (j.qtypriyr - v_coll_lv);
          end if;
          if j.qtypriyr > 0 then --keep previous priyr if value > 0 only. ----
            v_prev_qtypriyr := j.qtypriyr;
          end if;

          if v_curr_month = 1 then
            begin
              select nvl(sum(nvl(qtyadjvac,0)),0) into v_qtyadjvac
              from   tleavsum
              where  codempid = p_codempid
              and    dteyear  = p_year
              and    codleave in (select t1.codleave
                                    from tleavecd t1, tleavcom t2
                                   where t1.typleave = t2.typleave
                                     and t1.typleave = p_typleave2
                                     and t2.codcompy = hcm_util.get_codcomp_level(v_codcomp,1));
            end;
            v_qtyvacat := j.qtyvacat - v_qtyadjvac;
          else
            v_qtyvacat := j.qtyvacat;
          end if;
          v_qtyvacat_show := v_qtyvacat - j.qtypriyr; --14/06/2021
        end loop;

      else
--        if i = 0 then
--          get_day(v_dtecycst,i,v_dtestr,v_tmpdate); --for fix first day of leave year
--        end if;
        get_day(v_dtecycst,0,v_dtestr,v_tmpdate); --for fix first day of leave year
        get_day(v_dtecycst,(i-1),v_tmpdate,v_dteend);
        for r2 in c3 loop --16/06/2021 ||c2 loop
          v_coll_lv := nvl(r2.v_qtyday,0);
        end loop;
--        v_qtyleave := v_qtyleave - v_coll_lv;
--
--        v_qtyvacat := v_qtyleave;
--        v_qtyvacat_show := v_qtyvacat - nvl(v_qtypriyr,0); --14/06/2021
        v_qtyleave := v_qtyvacat - v_coll_lv;
        v_qtyvacat_show := v_qtyleave - nvl(v_qtypri_all,0); --14/06/2021
      end if; --if v_staleave = 'V'
--      v_balance      := nvl(v_qtyleave,0); ----
      v_qtyleave_all := nvl(v_qtyleave,0);
      v_qtyleave_all := greatest(v_qtyleave_all,0); --21/04/2021

      obj_data.put('month' || to_char(i+1),nvl(day_to_dhhmm(v_qtyvacat_show,v_qtyavgwk),'0:00:00')); --14/06/2021
      --14/06/2021 ||obj_data.put('month' || to_char(i+1),nvl(day_to_dhhmm(v_qtyvacat,v_qtyavgwk),'0:00:00'));

      for r1 in c1 loop
        v_codleave := r1.codleave;
        v_flgfound := hral56b_batch.check_condition_leave(p_codempid,v_codleave,sysdate,'1');
        -- user03 --
--        begin --09/04/2021 comment
--          select  staleave
--            into  v_staleave
--            from  tleavecd
--           where  codleave = r1.codleave;
--        exception when no_data_found then
--          v_staleave := null;
--        end;
--        --
--        if v_staleave = 'V' and v_staleave is not null then
        get_day(v_dtecycst,i,v_dtestr,v_dteend); --21/04/2021
        if r1.staleave = 'V' then --21/04/2021
          begin
            select nvl(sum(qtylepay),0)
              into v_qtylepay
              from tpayvac
             where codempid   = p_codempid
               and dteyear    = p_year
               and dteyrepay  = to_number(to_char(v_dteend,'yyyy')) ----=p_year
               and dtemthpay  = to_number(to_char(v_dteend,'mm')) ----= i + 1
               and staappr    = 'Y';
          exception when no_data_found then
            v_qtylepay := 0;
          end;
          if (i+1) = 12 then --12th Month, find payment in next year too. ----
            begin
              select nvl(sum(qtylepay),0)
                into v_qtylepay
                from tpayvac
               where codempid = p_codempid
                 and dteyear  = p_year
                 and to_number(to_char(dteyrepay)||lpad(to_char(dtemthpay),2,'0'))
                             >= to_number(to_char(v_dteend,'yyyy')||to_char(v_dteend,'mm'))
                 and staappr  = 'Y';
            end;
          end if;
          v_qtyleave_all := v_qtyleave_all - v_qtylepay;
        end if;
        --
        if v_flgfound then
          for r2 in c2 loop
            v_qtyleave_all := v_qtyleave_all - nvl(r2.v_qtyday,0);
          end loop;
        end if;
      end loop;
      --add Summary Last line
      v_qtyleave_all := greatest(v_qtyleave_all,0); --21/04/2021
      obj_data_last.put('month' || to_char(i+1),nvl(day_to_dhhmm(v_qtyleave_all,v_qtyavgwk),'0:00:00')); -- summary last line
    end loop;

    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    --add 3-4-5 line body
    for r1 in c1 loop
      v_codleave := r1.codleave;
      v_flgfound := hral56b_batch.check_condition_leave(p_codempid,v_codleave,sysdate,'1');
      if v_flgfound then
        -- add line 3 [Leave Name]
        obj_data   := json_object_t();
        obj_data.put('index',to_char(v_count + 1));
        obj_data.put('detail',r1.codleave || ' - ' || get_tleavecd_name(r1.codleave,global_v_lang));
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;

        -- add line 4 [Leave Days]
        obj_data   := json_object_t();
        obj_data.put('index',to_char(v_count + 1));
        obj_data.put('detail',get_label_name('HRAL5CXC1',global_v_lang,'111'));
        for i in 0..v_count_month loop
          get_day(v_dtecycst,i,v_dtestr,v_dteend); --18/02/2021
          for r2 in c2 loop
            v_qtyday := r2.v_qtyday; ----obj_data.put('month' || to_char(i+1),nvl(day_to_dhhmm(nvl(r2.v_qtyday,0),v_qtyavgwk),'0:00:00'));
          end loop;
          if v_qtyday > 0 then
            obj_data.put('month' || to_char(i+1),nvl(day_to_dhhmm(nvl(v_qtyday,0),v_qtyavgwk),'0:00:00'));
          else
            obj_data.put('month' || to_char(i+1),'');
          end if;
        end loop;
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;

        if r1.staleave = 'V' then --21/04/2021
        -- add line 5 [Payment by Leave]
        obj_data   := json_object_t();
        obj_data.put('index',to_char(v_count + 1));
        obj_data.put('detail',get_label_name('HRAL5CXC1',global_v_lang,'112'));
--        begin
--          select  staleave
--            into  v_staleave
--            from  tleavsum
--           where  codempid = p_codempid
--             and  dteyear  = p_year
--             and  codleave = r1.codleave;
--        exception when no_data_found then
--          v_staleave := null;
--        end;
--        if v_staleave = 'V' and v_staleave is not null then
        if r1.staleave = 'V' then --21/04/2021
          for j in 1..(v_count_month + 1) loop
            get_day(v_dtecycst,(j-1),v_dtestr,v_dteend); --21/04/2021
            begin
              select nvl(sum(qtylepay),0)
                into v_qtylepay
                from tpayvac
               where codempid   = p_codempid
                 and dteyear    = p_year
                 and dteyrepay  = to_number(to_char(v_dteend,'yyyy')) ----p_year
                 and dtemthpay  = to_number(to_char(v_dteend,'mm')) ---- = j
                 and staappr    = 'Y';
            end;
            if j = 12 then --12th Month, find payment in next year too. ----
              begin
                select nvl(sum(qtylepay),0)
                  into v_qtylepay
                  from tpayvac
                 where codempid = p_codempid
                   and dteyear  = p_year
                   and to_number(to_char(dteyrepay)||lpad(to_char(dtemthpay),2,'0'))
                               >= to_number(to_char(v_dteend,'yyyy')||to_char(v_dteend,'mm'))
                   and staappr  = 'Y';
              end;
            end if;
            if v_qtylepay > 0 then
              obj_data.put('month' || to_char(j),day_to_dhhmm(v_qtylepay,v_qtyavgwk));
            else
              obj_data.put('month' || to_char(j),'');
            end if;
          end loop;
        end if;
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;

        -- add line 6 [Adjust Days] ----
        obj_data   := json_object_t();
        obj_data.put('index',to_char(v_count + 1));
        obj_data.put('detail',get_label_name('HRAL5CXC1',global_v_lang,'150'));
        for i in 0..v_count_month loop
          if (i+1) = 1 then
            v_qtyadjvac := 0;
            begin
              select nvl(sum(nvl(qtyadjvac,0)),0) into v_qtyadjvac
              from   tleavsum
              where  codempid = p_codempid
              and    dteyear  = p_year
              and    codleave = v_codleave;
            end;
            if v_qtyadjvac > 0 then
              obj_data.put('month' || to_char(i+1),nvl(day_to_dhhmm(nvl(v_qtyadjvac,0),v_qtyavgwk),'0:00:00'));
            else
              obj_data.put('month' || to_char(i+1),'');
            end if;
          else
            obj_data.put('month' || to_char(i+1),'');
          end if;
        end loop;
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;

        end if;
      end if;
    end loop;

    -- add 6th line [FOOTER]
    obj_data_last.put('index',to_char(v_count + 1));
    obj_rows.put(to_char(v_count),obj_data_last);

    -- add to table
    obj_table.put('table',obj_rows);
    obj_table.put('coderror','200');

    --Print Report--
    if isInsertReport then
      insert_ttemprpt(obj_table, v_dtecycst);
    end if;
    json_str_output := obj_table.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_label(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_label;
    if param_msg_error is null then
      gen_label(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_label;

  procedure check_label as
    v_staemp            temploy1.staemp%type;
    v_flgsecu           boolean := true;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      elsif v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      else
        v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      end if;
    end if;
  end check_label;

  procedure gen_label (json_str_output out clob) as
    obj_json        json_object_t := json_object_t();
    obj_json1       json_object_t := json_object_t();
    obj_json2       json_object_t := json_object_t();
    obj_data1       json_object_t;
    obj_data2       json_object_t;
    obj_rows1       json_object_t := json_object_t();
    obj_rows2       json_object_t := json_object_t();
    v_count         number := 0;
    v_codcompy      tleavcom.codcompy%type;
    v_desc_typleave tleavety.namleavtye%type;
    v_exist         boolean := false;
    v_count_tinitregd number;

    cursor c1 is
      select distinct(t2.typleave) typleave
        from tleavcom t1,tleavecd t2
       where t1.codcompy = v_codcompy
         and t1.typleave = t2.typleave
    order by t2.typleave;

    cursor c_tinitregd is
      select a.numseq, a.codinc
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp  = b.codapp
         and a.codapp  = p_codapp
         and a.codrep  = 'TEMP'
         and b.typcode = 5
       order by a.numseq;
  begin
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
    elsif p_codempid is not null then
      begin
        select t2.codcompy
          into v_codcompy
          from temploy1 t1,tcenter t2
        where t1.codempid = p_codempid
          and t1.codcomp = t2.codcomp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
    end if;
    for r1 in c1 loop
      v_exist := true;
      select count(a.codinc)
        into v_count_tinitregd
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp  = b.codapp
         and a.codapp  = p_codapp
         and a.codrep  = 'TEMP'
         and a.codinc  = r1.typleave
         and b.typcode = 5;

      if v_count_tinitregd = 0 then
        obj_data1 := json_object_t();
        obj_data1.put('coderror','200');
        obj_data1.put('codleave',r1.typleave);
        obj_data1.put('desc_codleave', get_tleavety_name(r1.typleave, global_v_lang));
        obj_rows1.put(to_char(v_count),obj_data1);
        v_count := v_count + 1;
      end if;
    end loop;

    v_count := 0;
    for r2 in c_tinitregd loop
      obj_data2 := json_object_t();
      obj_data2.put('coderror','200');
      obj_data2.put('codleave',r2.codinc);
      obj_data2.put('desc_codleave', get_tleavety_name(r2.codinc, global_v_lang));
      obj_rows2.put(to_char(v_count),obj_data2);
      v_count := v_count + 1;
    end loop;

    obj_json1.put('rows',obj_rows1);
    obj_json2.put('rows',obj_rows2);
    obj_json.put('typleave'  ,obj_json1);
    obj_json.put('listFields'  ,obj_json1);
    obj_json.put('formatFields',obj_json2);
    obj_json.put('coderror','200');

    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tleavcom');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_json.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_label;

  procedure initial_report(json_str in varchar2) is
    json_obj        json_object_t;
  begin

    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_year              := hcm_util.get_string_t(json_obj, 'p_year');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

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
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codempid        := hcm_util.get_string_t(p_index_rows, 'codempid2');
        p_typleave2        := hcm_util.get_string_t(p_index_rows,'codleave');

       gen_detail(json_output);

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
      delete ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp||'%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt(obj_data in json_object_t, p_dtecycst date) is
    obj_data_table      json_object_t;
    p_data_rows         json_object_t;
    v_numseq            number := 0;
    v_numseqt           number := 0;
    v_year              number := 0;
    v_year_             varchar2(100 char);
    v_curr_year_        varchar2(100 char);

    v_index             varchar2(1000 char);
    v_detail            varchar2(1000 char);
    v_month1            varchar2(1000 char);
    v_month2            varchar2(1000 char);
    v_month3            varchar2(1000 char);
    v_month4            varchar2(1000 char);
    v_month5            varchar2(1000 char);
    v_month6            varchar2(1000 char);
    v_month7            varchar2(1000 char);
    v_month8            varchar2(1000 char);
    v_month9            varchar2(1000 char);
    v_month10           varchar2(1000 char);
    v_month11           varchar2(1000 char);
    v_month12           varchar2(1000 char);
    v_year_n            varchar2(1000 char);
    v_month             varchar2(1000 char);
    v_curr_month        number;
    v_curr_year         number;

    v_codempid          varchar2(1000 char) := '';
    v_codleave    			varchar2(1000 char) := '';
    v_desc_codempid     varchar2(1000 char) := '';
    v_desc_codleave     varchar2(1000 char) := '';

    type arr_1d is table of varchar2(4000 char) index by binary_integer;
      arr_month           arr_1d;

  begin
    -- insert header --
    v_year      := hcm_appsettings.get_additional_year;
    v_year_     := to_char((hcm_util.get_string_t(obj_data, 'year')));
    for i in 0..11 loop
      v_curr_month  := to_number(to_char(p_dtecycst,'mm')) + i;
      v_curr_year   := to_number(to_char(p_dtecycst,'yyyy'));
      v_curr_year_  := to_char(to_number(v_curr_year)+ v_year);
      if v_curr_month > 12 then
        v_curr_month := v_curr_month - 12;
        v_curr_year_  := v_curr_year_ + 1;
      end if;
      v_month := get_label_name('HRAL5CXC2', global_v_lang, 40 + (10*v_curr_month));
      arr_month(i+1) := v_month||' '||v_curr_year_;
    end loop;

    v_codempid   			:= hcm_util.get_string_t(obj_data, 'codempid');
    v_codleave         := hcm_util.get_string_t(obj_data, 'codleave');
    v_desc_codempid   	:= hcm_util.get_string_t(obj_data, 'desc_codempid');
    v_desc_codleave    := hcm_util.get_string_t(obj_data, 'desc_codleave');

    p_codapp := 'HRAL5CX';
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
             item6, item7, item8, item9, item10, item11,
             item12, item13, item14, item15, item16, item17
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_codempid,
             v_codleave,
             v_codempid || ' - ' || v_desc_codempid,
             v_codleave || ' - ' || v_desc_codleave,
             v_year_,
             arr_month(1),arr_month(2),arr_month(3),arr_month(4),arr_month(5),arr_month(6),
             arr_month(7),arr_month(8),arr_month(9),arr_month(10),arr_month(11),arr_month(12)
           );
    exception when others then
      null;
    end;
    -- insert table --
    obj_data_table := hcm_util.get_json_t(obj_data, 'table');
    for i in 0..obj_data_table.get_size-1 loop
      p_codapp := 'HRAL5CX1';

      begin
        select nvl(max(numseq), 0)
          into v_numseqt
          from ttemprpt
         where codempid = global_v_codempid
           and codapp   = p_codapp;
      exception when no_data_found then
        null;
      end;
      v_numseqt      := v_numseqt + 1;
      p_data_rows    := hcm_util.get_json_t(obj_data_table, to_char(i));
      v_index        := nvl(hcm_util.get_string_t(p_data_rows, 'index'), ' ');
      v_detail       := nvl(hcm_util.get_string_t(p_data_rows,'detail'), ' ');
      v_month1       := nvl(hcm_util.get_string_t(p_data_rows,'month1'), ' ');
      v_month2       := nvl(hcm_util.get_string_t(p_data_rows,'month2'), ' ');
      v_month3       := nvl(hcm_util.get_string_t(p_data_rows,'month3'), ' ');
      v_month4       := nvl(hcm_util.get_string_t(p_data_rows,'month4'), ' ');
      v_month5       := nvl(hcm_util.get_string_t(p_data_rows,'month5'), ' ');
      v_month6       := nvl(hcm_util.get_string_t(p_data_rows,'month6'), ' ');
      v_month7       := nvl(hcm_util.get_string_t(p_data_rows,'month7'), ' ');
      v_month8       := nvl(hcm_util.get_string_t(p_data_rows,'month8'), ' ');
      v_month9       := nvl(hcm_util.get_string_t(p_data_rows,'month9'), ' ');
      v_month10      := nvl(hcm_util.get_string_t(p_data_rows,'month10'), ' ');
      v_month11      := nvl(hcm_util.get_string_t(p_data_rows,'month11'), ' ');
      v_month12      := nvl(hcm_util.get_string_t(p_data_rows,'month12'), ' ');
      v_year_n       := v_year_;

      --
      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq,
               item1, item2, item3, item4, item5,
               item6, item7, item8, item9, item10,item11,item12, item13,item14, item15, item16, item17
             )
        values
             (
               global_v_codempid, p_codapp, v_numseqt,
               v_codempid,
               v_codleave,
               v_year_n,
               v_index,
               v_detail, v_month1, v_month2, v_month3,
               v_month4, v_month5, v_month6, v_month7, v_month8, v_month9, v_month10, v_month11, v_month12
             );
      exception when others then
        null;
      end;
    end loop;

  end insert_ttemprpt;

  function convert_typleave_to_str (json_typleave json_object_t) return varchar2 is
    str_output          varchar2(4000 char) := '';
  begin
    for i in 0..json_typleave.get_size - 1 loop
      if str_output is not null then
        str_output  := str_output || ',';
      end if;
      str_output    := str_output || hcm_util.get_string_t(json_typleave, to_char(i));
    end loop;
    return str_output;
  end convert_typleave_to_str;

  function cal_dhm_concat (p_qtyday number, v_qtyavgwk number) return varchar2 is
    v_min       number;
    v_hour      number;
    v_day       number;
    v_num       number;
    v_dhm       varchar2(30);
    v_qtyday    number;
    v_con       varchar2(30);
  begin
    v_qtyday := p_qtyday;
    if nvl(v_qtyday,0) <> 0 then
      if v_qtyday < 0 then
        v_qtyday := v_qtyday * (-1);
        v_con    := '-';
      end if;
      v_day   := trunc(v_qtyday / 1);
      v_num   := round(mod((v_qtyday * v_qtyavgwk), v_qtyavgwk),0);
      v_hour  := trunc(v_num / 60);
      v_min   := mod(v_num,60);
      v_dhm   := v_con||to_char(v_day)||':'||
                 lpad(to_char(v_hour),2,'0')||':'||
                 lpad(to_char(v_min),2,'0');
    else
      v_dhm := '';
    end if;
    /*if v_qtyday is not null then
      if v_qtyday < 0 then
        v_qtyday := v_qtyday * (-1);
        v_con    := '-';
      end if;
      v_day   := trunc(v_qtyday / 1);
      v_num   := round(mod((v_qtyday * v_qtyavgwk), v_qtyavgwk),0);
      v_hour  := trunc(v_num / 60);
      v_min   := mod(v_num,60);
      v_dhm   := v_con||to_char(v_day)||':'||
                 lpad(to_char(v_hour),2,'0')||':'||
                 lpad(to_char(v_min),2,'0');
    else
      v_dhm := '-';
    end if;*/
    return(v_dhm);
  end;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    v_maxrcnt           number := 0;
    v_rcnt              number := 0;
    v_codleave          tinitregd.codinc%type;
  begin
    initial_value (json_str_input);
    begin
      insert
        into tinitregh (
          codapp, codrep, typcode,
          descode, descodt, descod3, descod4, descod5,
          codcreate
        )
      values (
        p_codapp, 'TEMP', 5,
        null, null, null, null, null,
        global_v_coduser
      );
    exception when dup_val_on_index then
      update tinitregh
          set typcode = 5,
              descode = null,
              descodt = null,
              descod3 = null,
              descod4 = null,
              descod5 = null,
              coduser = global_v_coduser
        where codapp = p_codapp
          and codrep = 'TEMP';
    end;
    if param_msg_error is null then
      v_maxrcnt        := p_codleave_array.get_size;

      for i in 0..v_maxrcnt - 1 loop
        v_rcnt          := i + 1;
        v_codleave        := hcm_util.get_string_t(p_codleave_array, to_char(i));
        begin
          insert
            into tinitregd (
              codapp, codrep, numseq, codinc,  codcreate
            )
          values (
            p_codapp,'TEMP', v_rcnt, v_codleave, global_v_coduser
          );
        exception when dup_val_on_index then
          update tinitregd
            set codinc = v_codleave,
                coduser = global_v_coduser
          where codapp = p_codapp
            and codrep = 'TEMP'
            and numseq = v_rcnt;
        end;
      end loop;
      delete from tinitregd
       where codapp = p_codapp
         and codrep = 'TEMP'
         and numseq > v_rcnt;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure get_day(p_dtecycst in date,p_month in number,p_dtestr out date,p_dteend out date) is
    v_curr_month        number;
    v_curr_year         number;
  begin
    -- init start end
    v_curr_month := to_number(to_char(p_dtecycst,'mm')) + p_month;
    v_curr_year  := to_number(to_char(p_dtecycst,'yyyy'));
    if v_curr_month > 12 then
      v_curr_month := v_curr_month - 12;
      v_curr_year  := v_curr_year + 1;
    elsif v_curr_month = 0 then
      v_curr_month := 12;
      v_curr_year  := v_curr_year - 1;
    end if;
    p_dtestr := to_date('01' || to_char(v_curr_month,'00') || to_char(v_curr_year,'0000'),'ddmmyyyy');
    p_dteend := last_day(p_dtestr);
--    if i = 0 then
--      p_dtestr := p_dtecycst;
--    end if;
--    if to_char(p_dtecycen,'mmyyyy') = to_char(v_curr_month,'00') || to_char(v_curr_year,'0000') then
--      p_dteend := p_dtecycen;
--    end if;
--exception when others then
  end;
end HRAL5CX;

/
