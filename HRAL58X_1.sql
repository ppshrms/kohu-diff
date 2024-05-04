--------------------------------------------------------
--  DDL for Package Body HRAL58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL58X" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_typleave          := hcm_util.get_string_t(json_obj,'p_typleave');
    p_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

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

  procedure check_index as
  begin
    if p_dtestr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang);
        return;
    end if;

    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    json_obj    json_object_t;
    json_row    json_object_t;
    json_row2   json_object_t;

    v_count     number:= 0;
    v_flg_data  varchar2(100 char) := 'N';
    v_secur     boolean;
    v_r_codempid varchar2(4000 char) := null;
    v_r_codcomp  varchar2(4000 char) := null;
    v_lvlst     number;
    v_lvlen     number;
    v_namcentlvl varchar2(4000 char);
    v_namcent    varchar2(4000 char);
    v_desc_typleave varchar2(4000 char);
    v_qtyavgwk  number;

    v_qtyleave number;
    v_qtypriyr number;
    v_dteeffec date;
    v_qty1     number;
    v_qty2     number;
    v_qty3     number;
    v_qtytime  number;
    v_flgdlemx varchar2(4000 char);
    v_change_id boolean;
    v_comlevel tcenter.comlevel%type;

    v_day     number;
    v_hour    number;
    v_minute  number;
    v_dhm     varchar2(30 char);

    cursor c1 is
        select	a.codempid	,a.codcomp	,a.numlvl,
                b.typleave	,b.codleave	,b.qtydayle,
                b.qtylate	  ,b.qtyearly	,b.qtyabsent,
                b.qtynostam
        from	temploy1 a,
                ((	select 	codempid    ,typleave   ,codleave       ,sum(nvl(qtyday,0)) qtydayle,
                            0 qtylate   ,0 qtyearly ,0	qtyabsent   ,null 	qtynostam
                    from	tleavetr
                    where	dtework between p_dtestr and p_dteend
                    and		codcomp 	like nvl(p_codcomp||'%','%')
                    and		codempid	= nvl(p_codempid,codempid)
                    and		qtyday > 0
                    group by codempid,typleave,codleave)
                    union all
                (	select	codempid,' ',' ',0,
                          nvl(sum(qtylate),0),nvl(sum(qtyearly),0),nvl(sum(qtyabsent),0),nvl(sum(qtynostam),0)
                    from	tlateabs
                    where	dtework between p_dtestr and p_dteend
                    and		codcomp like nvl(p_codcomp||'%','%')
                    and		codempid = nvl(p_codempid,codempid)
                    and		(qtylate > 0 or qtyearly > 0 or qtyabsent > 0 or qtynostam > 0)
                    group by codempid)) b
        where	a.codempid 	= b.codempid
        and		a.codcomp 	like nvl(p_codcomp||'%','%')
        and		a.codempid 	= nvl(p_codempid,a.codempid)
        order by a.codcomp,a.codempid,b.typleave,b.codleave;
  begin
    json_obj := json_object_t();
    for r1 in c1 loop
        v_flg_data := 'Y';
        exit;
    end loop;
    if v_flg_data like 'N' then
        -- no data found
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlateabs');
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    v_flg_data := 'N';
    for r1 in c1 loop
        if (v_r_codempid is null or not (v_r_codempid like r1.codempid)) and r1.codempid is not null then
            v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--            v_secur := null;
            v_r_codempid := r1.codempid;
            v_change_id := true;
        end if;
        if v_secur then
            if (v_r_codcomp is null or not(v_r_codcomp like r1.codcomp)) and r1.codcomp is not null then
                v_change_id := true;
                v_r_codcomp := r1.codcomp;
                begin
                  select qtyavgwk into v_qtyavgwk
                    from tcontral
                   where codcompy	= hcm_util.get_codcomp_level(r1.codcomp,1)
                     and dteeffec	= ( select max(dteeffec)
                                        from tcontral
                                       where codcompy	= hcm_util.get_codcomp_level(r1.codcomp,1)
                                         and dteeffec <= sysdate);
                exception when no_data_found then v_qtyavgwk := 0;
                end;
            end if;
            v_flg_data := 'Y';
            json_row := json_object_t();
--            if v_change_id then
                json_row.put('image',get_emp_img(r1.codempid));
                json_row.put('codempid',r1.codempid);
                json_row.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                json_row.put('codcomp',r1.codcomp);
--                v_change_id := false;
--            end if;
            if r1.codleave like ' ' then -- HRAL58XC1	120
                json_row.put('codleave','');
                json_row.put('desc_codleave',get_label_name('HRAL58XC1',global_v_lang,'120'));
            else
                json_row.put('codleave',r1.codleave);
                json_row.put('desc_codleave',get_tleavecd_name(r1.codleave,global_v_lang));
                json_row.put('typleave',r1.typleave);
            end if;
            if r1.qtydayle <> 0 then
                hcm_util.cal_dhm_hm(r1.qtydayle,0,0,v_qtyavgwk,'1',v_day,v_hour,v_minute,v_dhm);
                json_row.put('qtydayle',v_dhm);
            end if;
            if r1.qtylate <> 0 then
                hcm_util.cal_dhm_hm(0,0,r1.qtylate,v_qtyavgwk,'2',v_day,v_hour,v_minute,v_dhm);
                json_row.put('qtylate',v_dhm);
            end if;
            if r1.qtyearly <> 0 then
                hcm_util.cal_dhm_hm(0,0,r1.qtyearly,v_qtyavgwk,'2',v_day,v_hour,v_minute,v_dhm);
                json_row.put('qtyearly',v_dhm);
            end if;
            if r1.qtyabsent <> 0 then
                hcm_util.cal_dhm_hm(0,0,r1.qtyabsent,v_qtyavgwk,'1',v_day,v_hour,v_minute,v_dhm);
                json_row.put('dayabsent',v_dhm);
            end if;

            json_row.put('codempid2',r1.codempid);
            if r1.qtynostam <> 0 then
                json_row.put('qtynostam',r1.qtynostam);
            end if;
            json_row.put('coderror','200');
            json_obj.put(to_char(v_count),json_row);
            v_count := v_count + 1;
        end if;
    end loop;
    if v_flg_data like 'N' then
        -- permission denied
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
		json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure check_popup as
  begin
    if p_dtestr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_typleave is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang);
        return;
    end if;

    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
  end;

  procedure get_popup(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_popup;
  if param_msg_error is null then
    gen_popup(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_popup(json_str_output out clob) as
    json_obj        json_object_t;
    v_desc_typleave varchar2(4000 char);
    v_flgdlemx      varchar2(4000 char);
    v_qtypriyr      number;
    v_qtyleave      number;
    v_dteeffec      date;
    v_qty1          number;
    v_qty2          number;
    v_qty3          number;
    v_qtytime       number;
    v_qtyavgwk      number;
    v_hr            number;
    v_token1        number := 0;
    v_token2        number := 0;
    v_token3        number := 0;
    v_token4        varchar2(4000 char);
    v_codcomp       varchar2(100 char);
  begin
    begin
      select codcomp into v_codcomp
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then v_codcomp := null;
    end;
    begin
      select qtyavgwk into v_qtyavgwk
        from tcontral
       where codcompy	= hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec	= ( select max(dteeffec)
                            from tcontral
                           where codcompy	= hcm_util.get_codcomp_level(v_codcomp,1)
                             and dteeffec <= sysdate);
    exception when no_data_found then v_qtyavgwk := 0;
    end;

    json_obj := json_object_t();
    json_obj.put('typleave',p_typleave);
    begin
        select  decode(global_v_lang   ,'101',namleavtye,
                                        '102',namleavtyt,
                                        '103',namleavty3,
                                        '104',namleavty4,
                                        '105',namleavty5) ,flgdlemx
        into    v_desc_typleave,v_flgdlemx
        from    tleavety
        where   typleave like p_typleave;
        json_obj.put('desc_typleave',v_desc_typleave);
        std_al.entitlement(p_codempid,p_codleave,p_dtestr,0,v_qtyleave,v_qtypriyr,v_dteeffec);
        v_qty1 := nvl(v_qtyleave,0);
        begin
            select nvl(sum(qtyday),0),count(*)
            into   v_qty2,v_qtytime
            from   tleavetr
            where  codempid = p_codempid
            and    dtework between p_dtestr and p_dteend
            and    typleave = p_typleave;
        exception when no_data_found then
            v_qty2 := 0;
            v_qtytime := 0;
        end;
        v_qty3 := v_qty1 - v_qty2;
        hcm_util.cal_dhm_hm (v_qty1,null,null,v_qtyavgwk ,1 ,v_token1 ,v_token2,v_token3,v_token4);

        json_obj.put('day1',to_char(v_token1));
        json_obj.put('hr1' ,to_char(v_token2));
        json_obj.put('min1',to_char(v_token3));
        --
        hcm_util.cal_dhm_hm (v_qty2,null,null,v_qtyavgwk ,1 ,v_token1 ,v_token2,v_token3,v_token4);
        json_obj.put('day2',to_char(v_token1));
        json_obj.put('hr2' ,to_char(v_token2));
        json_obj.put('min2',to_char(v_token3));
        --
        hcm_util.cal_dhm_hm (v_qty3,null,null,v_qtyavgwk ,1 ,v_token1 ,v_token2,v_token3,v_token4);
        json_obj.put('day3',to_char(greatest(v_token1,0)));
        json_obj.put('hr3' ,to_char(greatest(v_token2,0)));
        json_obj.put('min3',to_char(greatest(v_token3,0)));
--        json_obj.put('day1',to_char(round(v_qty1)));
--        json_obj.put('day2',to_char(round(v_qty2)));
--        json_obj.put('day3',to_char(round(v_qty3)));
--        json_obj.put('hr1',to_char(round(((nvl(v_qty1,0)-round(nvl(v_qty1,0)))*nvl(v_qtyavgwk,0))/60)));
--        json_obj.put('hr2',to_char(round(((nvl(v_qty2,0)-round(nvl(v_qty2,0)))*nvl(v_qtyavgwk,0))/60)));
--        json_obj.put('hr3',to_char(round(((nvl(v_qty3,0)-round(nvl(v_qty3,0)))*nvl(v_qtyavgwk,0))/60)));
--        json_obj.put('min1',to_char(mod((v_qty1-round(v_qty1))*v_qtyavgwk,60)));
--        json_obj.put('min2',to_char(mod((v_qty2-round(v_qty2))*v_qtyavgwk,60)));
--        json_obj.put('min3',to_char(mod((v_qty3-round(v_qty3))*v_qtyavgwk,60)));

        json_obj.put('qtytime',to_char(v_qtytime));
        json_obj.put('flgdlemx',get_tlistval_name('LVLIMIT',v_flgdlemx,global_v_lang)); -- a??a??a?#a??a??a?sa??a?'a??a??a?'a??a??a??a?#a?Ya?? (Y-a??a??a?-a??a?#a??a??a??, N-a??a??a?-a??a??)
        json_obj.put('coderror','200');
    end;
		json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRAL58X;

/
