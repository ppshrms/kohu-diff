--------------------------------------------------------
--  DDL for Package Body HRTR7IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR7IX" is
-- last update: 17/07/2020 18:00
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
    p_codcomp           := upper(hcm_util.get_string(json_obj, 'p_codcomp'));
    p_codcompy          := upper(hcm_util.get_string(json_obj, 'p_codcompy'));
    p_contact_codempid  := upper(hcm_util.get_string(json_obj, 'p_contact_codempid'));
    p_signer_codempid   := upper(hcm_util.get_string(json_obj, 'p_signer_codempid'));
    p_year              := upper(hcm_util.get_string(json_obj, 'p_year'));
    p_from_month        := upper(hcm_util.get_string(json_obj, 'p_from_month'));
    p_to_month          := upper(hcm_util.get_string(json_obj, 'p_to_month'));
    p_ratio_mantrain    := upper(hcm_util.get_string(json_obj, 'p_ratio_mantrain'));

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
         and upper(codapp) like upper('HRTR7IX') || '%';
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
    v_cnt              number;
    v_numseq           number;
    v_rpt_codapp       varchar2(100 char) ;
    v_sum_train_qtyman number ;
    v_calmonth         number ;
    v_sum_qtyman       number ;

    v_item1  varchar2(1000 char) ; v_item2  varchar2(1000 char) ; v_item3  varchar2(1000 char) ; v_item4  varchar2(1000 char) ; v_item5  varchar2(1000 char) ;
    v_item6  varchar2(1000 char) ; v_item7  varchar2(1000 char) ; v_item8  varchar2(1000 char) ; v_item9  varchar2(1000 char) ; v_item10 varchar2(1000 char) ;    v_item11 varchar2(1000 char) ;
    --------------------------------------------------
    cursor c_thistrnn_1 is
          select  t1.numcert as item1 ,
                  hcm_util.get_date_buddhist_era(t1.dtecert) as item2 ,
                  t1.descomptr  as item3 ,
                  decode(t1.typtrain , '10' , count(distinct(t1.codempid)),0)  as item4 ,
                  decode(t1.typtrain , '11' , count(distinct(t1.codempid)),0)  as item5 ,
                  decode(t1.typtrain , '12' , count(distinct(t1.codempid)),0)  as item6
          from    thistrnn t1
          where   t1.codcomp like p_codcompy || '%' and
                  t1.dteyear = p_year and
                  t1.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                  t1.typtrain is not null and
                  t1.numcert is not null and
                  t1.pcttr >= 80
          group by t1.numcert , t1.dtecert , t1.descomptr , t1.typtrain
          order by  t1.numcert ;
    --------------------------------------------------
    cursor c_thistrnn_2 is
          select  c.numoffid as item1, get_tlistval_name('CODTITLE',b.codtitle,global_v_lang) as item2 , b.namfirstt as item3,
                  b.namlastt as item4 , get_tcourse_name(a.codcours, '102') as item5,
                  floor(a.qtytrmin) || ':' || lpad( round(mod(a.qtytrmin,1) * 60), 2, '0') as item6 ,
                  a.numcert as item7 ,
                  hcm_util.get_date_buddhist_era(a.dtecert) as item8 ,
                  a.typtrain as item9
          from    thistrnn a , temploy1 b , temploy2 c
          where   a.codempid = b.codempid and
                  a.codempid = c.codempid and
                  a.codcomp like p_codcompy || '%' and
                  a.dteyear = p_year and
                  a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                  a.typtrain is not null and
                  a.numcert is not null and
                  a.pcttr >= 80
          order by a.numcert , a.dtecert , c.numoffid  ;
    --------------------------------------------------
    cursor c_ttaxcur is
          select  t1.dtemthpay , count(distinct(t1.codempid)) as qtyman
          from    ttaxcur t1
          where   t1.dteyrepay = p_year and
                  t1.codcomp like p_codcompy || '%' and
                  t1.dtemthpay between to_number(p_from_month) and to_number(p_to_month)
          group by t1.dtemthpay
          order by t1.dtemthpay ;
    --------------------------------------------------

    begin

    -----------------------------------------------------
    select count('x')
    into   v_cnt
    from   thistrnn t
    where  t.codcomp like p_codcompy || '%' and
           t.dteyear = p_year and
           t.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           t.typtrain is not null and
           t.numcert is not null and
           t.pcttr >= 80;
    -----------------------------------------------
    if v_cnt = 0 then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thistrnn');
       return;

    end if ;
    -----------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR7IX_ST2_1_SUB1' ;
    for r_thistrnn in c_thistrnn_1
    loop
       v_numseq      := v_numseq + 1;
       insert into ttemprpt ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6)
       values ( global_v_codempid, v_rpt_codapp, v_numseq, r_thistrnn.item1, r_thistrnn.item2, r_thistrnn.item3, r_thistrnn.item4, r_thistrnn.item5, r_thistrnn.item6);
    end loop ;
    -----------------------------------------------------
    select nvl(t1.numacdsd,t1.numacsoc) ,
           decode(global_v_lang,'101',t1.namcome,
                                '102',t1.namcomt,
                                '103',t1.namcom3,
                                '104',t1.namcom4,
                                '105',t1.namcom5,t1.namcome) as namcom ,
            get_tpostn_name(t2.codpos,global_v_lang) as  v_item5
    into   v_item1 , v_item2 , v_item5
    from   tcompny t1, temploy1 t2
    where  t1.codcompy = p_codcompy and t2.codempid = p_signer_codempid ;
    v_item4 := get_temploy_name(p_signer_codempid,global_v_lang) ;
    v_item6 := TO_CHAR(SYSDATE, 'dd', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') ;
    v_item7:= trim(TO_CHAR(SYSDATE, 'MONTH', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')) ;
    v_item8 := get_ref_year(global_v_lang,'0',hcm_util.get_year()) ;--hcm_util.get_year_buddhist_era(SYSDATE) ;
    v_item9 := get_ref_year(global_v_lang,'0',p_year) ;
    -----------------------------------------------
    begin
      -----------------------------------------------------
      v_numseq := 1 ;
      v_rpt_codapp := 'HRTR7IX_ST2_1_MAIN' ;
      -----------------------------------------------------
      insert
      into ttemprpt ( codempid, codapp, numseq,
                      item1,  item2,  item3,  item4,  item5,  item6,  item7,  item8, item9 )
      values ( global_v_codempid, v_rpt_codapp, v_numseq,
               v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9 );
      commit;
      -----------------------------------------------------
    exception when others then
      null;
    end;
    -----------------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR7IX_ST2_2_SUB1' ;
    -----------------------------------------------------
    for r_thistrnn in c_thistrnn_2
    loop
       v_numseq      := v_numseq + 1;
       insert into ttemprpt ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9)
       values ( global_v_codempid, v_rpt_codapp, v_numseq, r_thistrnn.item1, r_thistrnn.item2, r_thistrnn.item3, r_thistrnn.item4, r_thistrnn.item5, r_thistrnn.item6,
                r_thistrnn.item7, r_thistrnn.item8, r_thistrnn.item9);
    end loop ;
    v_sum_train_qtyman := v_numseq ;
    -----------------------------------------------------
    select nvl(t1.numacdsd,t1.numacsoc) ,
           decode(global_v_lang,'101',t1.namcome,
                                '102',t1.namcomt,
                                '103',t1.namcom3,
                                '104',t1.namcom4,
                                '105',t1.namcom5,t1.namcome) as namcom ,
           get_tpostn_name( (select st1.codpos from temploy1 st1 where st1.codempid = p_signer_codempid ),'102') as v_item7
    into   v_item1 , v_item2 , v_item7
    from   tcompny t1
    where  t1.codcompy = p_codcompy ;
     -----------------------------------------------------
    v_calmonth := 0 ;
    v_sum_qtyman := 0 ;
    -----------------------------------------------------
    for r_ttaxcur in c_ttaxcur
    loop
      if r_ttaxcur.qtyman > 100 then
        v_sum_qtyman := v_sum_qtyman + r_ttaxcur.qtyman ;
        v_calmonth := v_calmonth + 1;
      end if ;
    end loop ;
    -----------------------------------------------------
    v_item3 := 0 ;
    if v_calmonth != 0 then
       v_item3 := TRUNC(v_sum_qtyman / v_calmonth) ;
    end if ;
    v_item4 := TRUNC(v_item3 * p_ratio_mantrain / 100) ;
    v_item5 := v_sum_train_qtyman ;
    v_item6 := get_temploy_name(p_signer_codempid,global_v_lang) ;
    --v_item7 := get_tpostn_name(p_signer_codempid,global_v_lang) ;
    v_item8 := TO_CHAR(SYSDATE, 'dd', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') ;
    v_item9:= trim(TO_CHAR(SYSDATE, 'MONTH', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')) ;
    v_item10 := get_ref_year(global_v_lang,'0',hcm_util.get_year()) ;--hcm_util.get_year_buddhist_era(SYSDATE) ;
    v_item11 := get_ref_year(global_v_lang,'0',p_year) ;
    -----------------------------------------------
    begin
      -----------------------------------------------------
      v_numseq := 1 ;
      v_rpt_codapp := 'HRTR7IX_ST2_2_MAIN' ;
      -----------------------------------------------------
      insert into ttemprpt ( codempid, codapp, numseq,
                             item1,  item2,  item3,  item4,  item5,  item6,  item7,  item8,  item9,  item10, item11 )
      values ( global_v_codempid, v_rpt_codapp, v_numseq,
               v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item11 );
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

end HRTR7IX;


/
