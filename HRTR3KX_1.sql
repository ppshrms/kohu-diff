--------------------------------------------------------
--  DDL for Package Body HRTR3KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR3KX" is
-- last update: 20/07/2020 10:00
 procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string(json_obj, 'p_lrunning');

    -- report params
    p_codcompy          := upper(hcm_util.get_string(json_obj, 'p_codcompy'));
    p_signer_codempid   := upper(hcm_util.get_string(json_obj, 'p_signer_codempid'));
    p_year              := upper(hcm_util.get_string(json_obj, 'p_year'));
    p_from_month        := upper(hcm_util.get_string(json_obj, 'p_from_month'));
    p_to_month          := upper(hcm_util.get_string(json_obj, 'p_to_month'));
    p_ratio             := hcm_util.get_string(json_obj, 'p_ratio');
    p_minimum_wage      := hcm_util.get_string(json_obj, 'p_minimum_wage');
    -- save index
    json_params         := hcm_util.get_json(json_obj, 'params');
    -- tprocapp
    p_codproc           := upper(hcm_util.get_string(json_obj, 'p_codproc'));
    -- report
    json_coduser        := hcm_util.get_json(json_obj, 'json_coduser');
    p_codapp            := upper(hcm_util.get_string(json_obj, 'p_codapp'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;
  --------------------------------------------------
  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp) like upper('HRTR3KX') || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;
  --------------------------------------------------
  procedure get_rpt (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       clear_ttemprpt;
       gen_rpt(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_rpt;

  procedure gen_rpt (json_str_output out clob) is
    v_numseq         number;
    v_rpt_codapp     varchar2(100 char) ;

    type arr_num is table of number index by binary_integer;
      a_num   arr_num;
    v_flag_over100   boolean ;
    v_sum_all        number ;
    v_sum_cal_all    number ;
    v_num_month_cal  number ;
    v_check_secur    boolean ;

    v_item1  varchar2(1000 char) ; v_item2  varchar2(1000 char) ; v_item3  varchar2(1000 char) ; v_item4  varchar2(1000 char) ; v_item5  varchar2(1000 char) ;
    v_item6  varchar2(1000 char) ; v_item7  varchar2(1000 char) ; v_item8  varchar2(1000 char) ; v_item9  varchar2(1000 char) ; v_item10 varchar2(1000 char) ;
    v_item11 varchar2(1000 char) ; v_item12 varchar2(1000 char) ; v_item13 varchar2(1000 char) ; v_item14 varchar2(1000 char) ; v_item15 varchar2(1000 char) ;
    v_item16 varchar2(1000 char) ; v_item17 varchar2(1000 char) ; v_item18 varchar2(1000 char) ; v_item19 varchar2(1000 char) ; v_item20 varchar2(1000 char) ;
    v_item21 varchar2(1000 char) ; v_item22 varchar2(1000 char) ; v_item23 varchar2(1000 char) ; v_item24 varchar2(1000 char) ; v_item25 varchar2(1000 char) ;
    v_item26 varchar2(1000 char) ; v_item27 varchar2(1000 char) ; v_item28 varchar2(1000 char) ; v_item29 varchar2(1000 char) ; v_item30 varchar2(1000 char) ;
    v_item31 varchar2(1000 char) ; v_item32 varchar2(1000 char) ; v_item33 varchar2(1000 char) ; v_item34 varchar2(1000 char) ; v_item35 varchar2(1000 char) ;
    v_item36 varchar2(1000 char) ; v_item37 varchar2(1000 char) ; v_item38 varchar2(1000 char) ; v_item39 varchar2(1000 char) ; v_item40 varchar2(1000 char) ;
    v_item41 varchar2(1000 char) ; v_item42 varchar2(1000 char) ; v_item43 varchar2(1000 char) ; v_item44 varchar2(1000 char) ; v_item45 varchar2(1000 char) ;
    v_item46 varchar2(1000 char) ; v_item47 varchar2(1000 char) ; v_item48 varchar2(1000 char) ; v_item49 varchar2(1000 char) ; v_item50 varchar2(1000 char) ;
    -----------------------------------------------------
    cursor c_ttaxcur is
            select t.dtemthpay , count(distinct(t.codempid)) qtyman
            from   ttaxcur t
            where  t.dteyrepay = p_year and
                   t.codcomp like p_codcompy || '%' and
                   t.dtemthpay between to_number(p_from_month) and to_number(p_to_month)
            group by t.dtemthpay
            order by t.dtemthpay ;
    -----------------------------------------------------
  begin
    -----------------------------------------------------
    v_check_secur  := secur_main.secur2(p_signer_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
    if not v_check_secur then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if ;
    --------------------------------------------------
    v_check_secur  := secur_main.secur7(p_codcompy, global_v_coduser);
    if not v_check_secur then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if ;
    -----------------------------------------------------
    for i in 1..12 loop
      a_num(i) := 0;
    end loop;
    -----------------------------------------------------
    for r_ttaxcur in c_ttaxcur
    loop
      a_num(r_ttaxcur.dtemthpay) := r_ttaxcur.qtyman ;
    end loop ;
    -----------------------------------------------------
    v_flag_over100 := false ;
    v_sum_all := 0 ;
    v_sum_cal_all := 0 ;
    v_num_month_cal := 0 ;
    for i in 1..12 loop
      v_sum_all := v_sum_all + a_num(i) ;
      if a_num(i) >= 100 then
        v_flag_over100 := true ;
      end if ;
      if v_flag_over100 = true then
        v_sum_cal_all := v_sum_cal_all + a_num(i) ;
        v_num_month_cal := v_num_month_cal + 1 ;
      end if ;
    end loop ;
    -----------------------------------------------------
    if v_flag_over100 = false then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxcur');
       return;
    end if ;
    -----------------------------------------------------
    v_item1 := p_year + 543 ;
    -----------------------------------------------------
    select nvl(t.numacdsd , t.numacsoc) ,
           decode ( global_v_lang ,'101',t.namcome,'102',t.namcomt,'103',t.namcom3,'104',t.namcom4,'105',t.namcom5,t.namcome) as namcom ,
           decode ( global_v_lang ,'101',t.addrnoe || ' ' || t.buildinge,'102',t.addrnot || ' ' || t.buildingt,'103',t.addrno3 || ' ' || t.building3,
                   '104',t.addrno4 || ' ' || t.building4,'105',t.addrno5 || ' ' || t.building5,t.addrnoe || ' ' || t.buildinge) as addrno_building ,
           --decode ( global_v_lang ,'101',t.mooe,'102',t.moot,'103',t.moo3,'104',t.moo4,'105',t.moo5,t.mooe) as moo ,
           decode ( global_v_lang ,'101',t.soie,'102',t.soit,'103',t.soi3,'104',t.soi4,'105',t.soi5,t.soie) as soi ,
           decode ( global_v_lang ,'101',t.roade,'102',t.roadt,'103',t.road3,'104',t.road4,'105',t.road5,t.roade) as road ,
           get_tcodec_name('TCODPROV', t.codprovr , global_v_lang ) as item12 , get_tcoddist_name(t.coddist, global_v_lang)  ,
           get_tsubdist_name(t.codsubdist, global_v_lang), t.zipcode, t.numtele ,t.numfax ,t.email ,
           get_tpostn_name( (select st1.codpos from temploy1 st1 where st1.codempid = p_signer_codempid ),'102')
    into   v_item2 ,v_item3 ,v_item4 ,v_item5 ,v_item6 ,v_item7 ,v_item8 ,v_item9 ,v_item10 ,v_item11 ,v_item12 ,v_item13 ,v_item36
    from   tcompny t
    where  t.codcompy = p_codcompy ;
    -----------------------------------------------------
    v_item14 := v_sum_cal_all ;
    v_item15 := v_num_month_cal ;
    v_item16 := floor (v_sum_cal_all / v_num_month_cal) ;
    v_item17 := floor (p_ratio * v_item16 /100 );
    -----------------------------------------------------
    select count(distinct(t.codcours))
    into   v_item19
    from   thistrnn t
    where  t.codcomp like  p_codcompy || '%' and
           t.dteyear = p_year and
           t.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           t.numcert is not null ;
    -----------------------------------------------------
    select count(distinct(t.codcours))
    into   v_item22
    from   thistrnn t
    where  t.codcomp like  p_codcompy || '%' and
           t.dteyear = p_year and
           t.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           t.typtrain = '11' ;
    IF ( v_item22 > 0) THEN
       v_item21 := 'Y' ;
    ELSE
       v_item21 :=  'N' ;
    END IF ;
    -----------------------------------------------------
    select count(distinct(t.codcours))
    into   v_item24
    from   thistrnn t
    where  t.codcomp like  p_codcompy || '%' and
           t.dteyear = p_year and
           t.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           t.typtrain = '12' ;
    IF ( v_item24 > 0) THEN
       v_item23 := 'Y' ;
    ELSE
       v_item23 := 'N' ;
    END IF  ;
    -----------------------------------------------------
    v_item20 := v_item22 + v_item24 ;
    v_item18 := v_item20 ;
    -----------------------------------------------------
    IF ( v_item18 >= v_item17) THEN
       v_item25 := 'Y' ;
    ELSE
       v_item25 := 'N' ;
    END IF ;
    IF (( v_item18 < v_item17) and (v_item18>0)) THEN
       v_item27 := v_item17 - v_item18 ;
       v_item26 := 'Y' ;
    ELSE
       v_item27 := '';
       v_item26 := 'N' ;
    END IF ;

    IF ( v_item18 = 0) THEN
       v_item29 := v_item17 ;
       v_item28 := 'Y' ;
    ELSE
       v_item29 := '' ;
       v_item28 := 'N' ;
    END IF ;
--    v_item29 := v_item17 ;
    IF ( v_item15 = 0) THEN
       v_item30 := 'Y' ;
    ELSE
       v_item30 := 'N' ;
    END IF ;
    IF ( v_item16 < 100) THEN
       v_item31 := 'Y' ;
    ELSE
       v_item31 := 'N' ;
    END IF ;
    -----------------------------------------------------
    IF ((v_item26 = 'Y') or (v_item28 = 'Y')) THEN
       v_item32 := 'Y' ;
    ELSE
       v_item32 := 'N' ;
    END IF ;
    IF ( v_item32 = 'Y') THEN
       v_item33 := 'N' ;
    ELSE
       v_item33 := 'Y' ;
    END IF ;
    -----------------------------------------------------
    v_item34 := '' ;
    IF v_item32 = 'Y' THEN
      IF v_item26 = 'Y' THEN
        v_item34 := p_ratio * v_item27 * 30 * v_num_month_cal / 100 ;
      ELSE
        v_item34 := p_ratio * v_item29 * 30 * v_num_month_cal / 100 ;
      END IF ;
    END IF ;

    v_item35 := get_temploy_name(p_signer_codempid,global_v_lang) ;
    --v_item36 := get_tpostn_name( (select st1.codpos from temploy1 st1 where st1.codempid = p_signer_codempid ),'102') ;

    v_item37 := a_num(1) ; v_item38 := a_num(2) ; v_item39 := a_num(3) ; v_item40 := a_num(4) ;
    v_item41 := a_num(5) ; v_item42 := a_num(6) ; v_item43 := a_num(7) ; v_item44 := a_num(8) ;
    v_item45 := a_num(9) ; v_item46 := a_num(10) ; v_item47 := a_num(11) ; v_item48 := a_num(12) ;
    v_item49 := p_ratio ;
    v_item50 := get_amt_nameth(v_item34) ;

    begin
      -----------------------------------------------------
      v_numseq := 1 ;
      v_rpt_codapp := 'HRTR3KX_MAIN' ;
      -----------------------------------------------------
      insert
      into ttemprpt
           (
             codempid, codapp, numseq,
             item1,  item2,  item3,  item4,  item5,  item6,  item7,  item8,  item9,  item10,
             item11, item12, item13, item14, item15, item16, item17 , item18 , item19, item20,
             item21, item22, item23, item24, item25, item26, item27 , item28 , item29, item30,
             item31, item32, item33, item34, item35, item36, item37 , item38 , item39, item40,
             item41, item42, item43, item44, item45, item46, item47 , item48 , item49, item50
           )
      values
           (
             global_v_codempid, v_rpt_codapp, v_numseq,
             v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item9, v_item8, v_item7, v_item10,
             v_item11, v_item12, v_item13, v_item14, v_item15, v_item16, v_item17 , v_item18 , v_item19, v_item20,
             v_item21, v_item22, v_item23, v_item24, v_item25, v_item26, v_item27 , v_item28 , v_item29, v_item30,
             v_item31, v_item32, v_item33, v_item34, v_item35, v_item36, v_item37 , v_item38 , v_item39, v_item40,
             v_item41, v_item42, v_item43, v_item44, v_item45, v_item46, v_item47 , v_item48 , v_item49, v_item50
           );
      commit;
      -----------------------------------------------------
    exception when others then
      null;
    end;

    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    commit;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_rpt ;
  ----------------------------------------------------------------------------------
  procedure get_position (json_str_input in clob, json_str_output out clob) is
    obj_data    json;
    v_position  temploy1.codpos%type;
  begin
    initial_value (json_str_input);
    v_position := '' ;
    if param_msg_error is null then
        select codpos
        into   v_position
        from temploy1
        where codempid = p_signer_codempid ;
    end if;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('position', v_position);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_position;
----------------------------------------------------------------------------------

end HRTR3KX;

/
