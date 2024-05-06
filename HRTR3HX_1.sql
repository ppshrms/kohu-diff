--------------------------------------------------------
--  DDL for Package Body HRTR3HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR3HX" is
-- last update: 28/12/2020 19:56
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
    p_posname           := upper(hcm_util.get_string(json_obj, 'p_posname'));

    -- save index
    json_params         := hcm_util.get_json(json_obj, 'params');
    -- tprocapp
    p_codproc           := upper(hcm_util.get_string(json_obj, 'p_codproc'));
    -- report
    json_coduser        := hcm_util.get_json(json_obj, 'json_coduser');
    p_codapp            := upper(hcm_util.get_string(json_obj, 'p_codapp'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp) like upper('HRTR3HX') || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;


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
    v_cnt            number;
    v_numseq_main         number;
    v_numseq         number;
    v_rpt_codapp     varchar2(100 char) ;
    v_numseq_sub     number;
    v_rpt_codapp_sub varchar2(100 char) ;
    v_temp_amttrcost number ;
    v_check_secur      boolean;
    v_item1  varchar2(1000 char) ; v_item2  varchar2(1000 char) ; v_item3  varchar2(1000 char) ; v_item4  varchar2(1000 char) ; v_item5  varchar2(1000 char) ;
    v_item6  varchar2(1000 char) ; v_item7  varchar2(1000 char) ; v_item8  varchar2(1000 char) ; v_item9  varchar2(1000 char) ; v_item10 varchar2(1000 char) ;
    v_item11 varchar2(1000 char) ; v_item12 varchar2(1000 char) ; v_item13 varchar2(1000 char) ; v_item14 varchar2(1000 char) ; v_item15 varchar2(1000 char) ;
    v_item16 varchar2(1000 char) ; v_item17 varchar2(1000 char) ; v_item18 varchar2(1000 char) ; v_item19 varchar2(1000 char) ; v_item20 varchar2(1000 char) ;
    v_item21 varchar2(1000 char) ; v_item22 varchar2(1000 char) ; v_item23 varchar2(1000 char) ; v_item24 varchar2(1000 char) ; v_item25 varchar2(1000 char) ;
    v_item26 varchar2(1000 char) ; v_item27 varchar2(1000 char) ; v_item28 varchar2(1000 char) ; v_item29 varchar2(1000 char) ; v_item30 varchar2(1000 char) ;
    v_item31 varchar2(1000 char) ; v_item32 varchar2(1000 char) ; v_item33 varchar2(1000 char) ; v_item34 varchar2(1000 char) ; v_item35 varchar2(1000 char) ;
    v_item36 varchar2(1000 char) ; v_item37 varchar2(1000 char) ; v_item38 varchar2(1000 char) ;
    ----------------------------------------------
    cursor c_thisclss1 is
          select (select st1.namcourst from tcourse st1 where st1.codcours = a.codcours) as item1
          from   thistrnn a
          where  a.codcomp like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                 a.CODTPARG = '2' and
                 a.typtrain = '11'
          order by a.codcours  ;
    ----------------------------------------------
    cursor c_thisclss2 is
          select (select st1.namcourst from tcourse st1 where st1.codcours = a.codcours) as item1
          from   thistrnn a
          where  a.codcomp like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                 a.CODTPARG = '2' and
                 a.typtrain = '12'
          order by a.codcours ;
    ----------------------------------------------
    cursor c_thistrnn1 is
          select a.codcours ,
                 ( select decode(global_v_lang,'101', st1.namcourse ,
                                              '102', st1.namcourst,
                                              '103', st1.namcours3,
                                              '104', st1.namcours4,
                                              '105', st1.namcours5,
                                              st1.namcourse)
                   from   tcourse st1 where st1.codcours = a.codcours) as namcours ,
                 --to_char(a.dtetrst,'dd/mm/yyyy') || '-' || to_char(a.dtetren,'dd/mm/yyyy') as dtetr ,
                 hcm_util.get_date_buddhist_era(a.dtetrst) || '-' || hcm_util.get_date_buddhist_era(a.dtetren) as dtetr ,
                 a.qtytrmin as qtytrmin ,
                 get_tinstitu_name(a.codinsts ,global_v_lang) as tinstitu ,
                 a.numclseq  ,
                 a.dteyear  ,
                 sum(decode(b.codsex,'M',1,0)) as sum_male ,
                 sum(decode(b.codsex,'F',1,0)) as sum_female ,
                 sum(decode(b.codsex,'M',1,'F',1,0)) as num_all,
                 a.dtetrst , a.dtetren
          from   thistrnn a, temploy1 b
          where  a.codempid = b.codempid and
                 a.codcomp like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                 a.codtparg = '2' and a.typtrain in ('11','12')
          group by a.codcours , a.numclseq ,a.dtetrst , a.dtetren ,a.qtytrmin ,a.codinsts,a.dteyear
          order by a.codcours , a.numclseq ;
    ----------------------------------------------
    cursor c_thistrnn2 (v_dteyear in varchar2,v_codcours in varchar2, v_numclseq in varchar2,v_qtytrmin in varchar2, v_dtetrst date, v_dtetren date ) is
          select c.numoffid , get_temploy_name(c.codempid,global_v_lang) as codempid_name ,  get_tpostn_name(a.codpos,global_v_lang) as codpos_name
          from   thistrnn a, temploy1 b, temploy2 c
          where  a.codempid = b.codempid and b.codempid = c.codempid and
                 a.codcomp like p_codcomp|| '%' and
                 a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                 a.codtparg = '2' and
                 a.typtrain in ('11','12') and
                 a.dteyear = v_dteyear and
                 a.codcours = v_codcours and
                 a.numclseq = v_numclseq and
                 a.qtytrmin = v_qtytrmin
                 and a.dtetrst = v_dtetrst
                 and a.dtetren = v_dtetren
          order by c.numoffid ;

  begin
    --------------------------------------------------
    v_check_secur  := secur_main.secur2(p_contact_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
    if not v_check_secur then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if ;
    --------------------------------------------------
    v_check_secur  := secur_main.secur2(p_signer_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
    if not v_check_secur then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if ;
    --------------------------------------------------
    v_check_secur  := secur_main.secur7(p_codcomp, global_v_coduser);
    if not v_check_secur then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if ;
    --------------------------------------------------
    select count('x')
    into   v_cnt
    from   thistrnn t
    where  t.codcomp like p_codcomp || '%' and
           t.dteyear = p_year and
           t.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           t.codtparg = '2' and
           t.typtrain in ('11','12') ;
    -----------------------------------------------
    if v_cnt = 0 then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thistrnn');
       return;
    end if ;
    -----------------------------------------------

    -----------------------------------------------
    v_item1 := get_ref_year(global_v_lang,'0',p_year);
    v_item2 := get_nammthabb(p_from_month, global_v_lang);
    v_item3 := get_nammthabb(p_to_month, global_v_lang);
    v_item5 := hcm_util.get_date_buddhist_era(sysdate);--to_char(sysdate,'dd/mm/yyyy') ;
    select decode(global_v_lang,'101', t.namcome,
                                '102', t.namcomt,
                                '103', t.namcom3,
                                '104', t.namcom4,
                                '105', t.namcom5,
                                t.namcome) as item4 ,
           decode(global_v_lang,'101', t.namcome,
                                '102', t.namcomt,
                                '103', t.namcom3,
                                '104', t.namcom4,
                                '105', t.namcom5,
                                t.namcome) as item6 ,
           t.numacsoc as item7 ,
           decode(global_v_lang,'101', t.addrnoe,
                                '102', t.addrnot,
                                '103', t.addrno3,
                                '104', t.addrno4,
                                '105', t.addrno5,
                                t.addrnoe) as item8 ,
           decode(global_v_lang,'101', t.mooe,
                                '102', t.moot,
                                '103', t.moo3,
                                '104', t.moo4,
                                '105', t.moo5,
                                t.mooe) as item9 ,
           decode(global_v_lang,'101', t.soie,
                                '102', t.soit,
                                '103', t.soi3,
                                '104', t.soi4,
                                '105', t.soi5,
                                t.soie) as item10 ,
           decode(global_v_lang,'101', t.roade,
                                '102', t.roadt,
                                '103', t.road3,
                                '104', t.road4,
                                '105', t.road5,
                                t.roade) as item11 ,
           get_tcodec_name('TCODPROV', t.codprovr , global_v_lang ) as item12 ,
           get_tcoddist_name(t.coddist, global_v_lang) as item13 ,
           get_tsubdist_name(t.codsubdist, global_v_lang) as item14 ,
           t.zipcode as item15 ,
           t.numtele as item16 ,
           t.numfax as item17 ,
           t.typbusiness as item21,
           ( select count('x') from temploy1 st1 where st1.codcomp like p_codcomp || '%' and st1.staemp in ('1','3') and st1.codsex = 'M' ) as item23 ,
           ( select count('x') from temploy1 st1 where st1.codcomp like p_codcomp || '%' and st1.staemp in ('1','3') and st1.codsex = 'F' ) as item24 ,
           ( select count(distinct(a.codempid))
             from   thistrnn a, temploy1 b
             where  a.codempid = b.codempid
                    and a.codcomp like p_codcomp || '%'
                    and a.dteyear = p_year
                    and a.dtemonth between to_number(p_from_month) and to_number(p_to_month)
                    and a.codtparg = '2'
                    and a.typtrain in ('11','12')
                    and b.codsex = 'M' ) as item26 ,
           ( select count(distinct(a.codempid))
             from   thistrnn a, temploy1 b
             where  a.codempid = b.codempid
                    and a.codcomp like p_codcomp|| '%'
                    and a.dteyear = p_year
                    and a.dtemonth between to_number(p_from_month) and to_number(p_to_month)
                    and a.codtparg = '2'
                    and a.typtrain in ('11','12')
                    and b.codsex = 'F' ) as item27,
             get_tpostn_name( (select st1.codpos from temploy1 st1 where st1.codempid = p_signer_codempid ),'102') as item38
    into   v_item4 , v_item6 , v_item7 , v_item8 , v_item9 , v_item10 , v_item11 , v_item12 , v_item13 , v_item14 , v_item15 , v_item16 ,
           v_item17 ,v_item21 , v_item23 , v_item24 , v_item26 , v_item27  , v_item38
    from   tcompny t
    where  t.codcompy = p_codcomp ;
    -----------------------------------------------------------------
    select decode(global_v_lang,'101', st1.namempe,
                                '102', st1.namempt,
                                '103', st1.namemp3,
                                '104', st1.namemp4,
                                '105', st1.namemp5,
                                st1.namempe) as item18 ,
           st1.numtelof as item19
    into   v_item18 , v_item19
    from   temploy1 st1
    where  st1.codempid = p_contact_codempid ;
    -----------------------------------------------------------------
    select count(distinct(st2.codcours)) , count((st2.numclseq)) , nvl(sum(st2.amtcost),0)
    into   v_item31 , v_item32 , v_item33
    from   thistrnn st2
    where  st2.codcomp like p_codcomp|| '%' and
           st2.dteyear = p_year and
           st2.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           st2.CODTPARG = '2' and
           st2.typtrain = '11' ;
    -----------------------------------------------------------------
    select count(distinct(st2.codcours)) , count((st2.numclseq)) , nvl(sum(st2.amtcost),0)
    into   v_item34 , v_item35 , v_item36
    from   thistrnn st2
    where  st2.codcomp like p_codcomp|| '%' and
           st2.dteyear = p_year and
           st2.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           st2.CODTPARG = '2' and
           st2.typtrain = '12' ;
    -----------------------------------------------------------------
    v_item22 := to_char( to_number(nvl(v_item23,'0')) + TO_NUMBER(nvl(v_item24,'0')) ) ;
    v_item25 := to_char( to_number(nvl(v_item26,'0')) + TO_NUMBER(nvl(v_item27,'0')) ) ;
    v_item28 := to_char( to_number(nvl(v_item31,'0')) + TO_NUMBER(nvl(v_item34,'0')) ) ;
    v_item29 := to_char( to_number(nvl(v_item32,'0')) + TO_NUMBER(nvl(v_item35,'0')) ) ;
    v_item30 := to_char( to_number(nvl(v_item33,'0')) + TO_NUMBER(nvl(v_item36,'0')) ) ;
    v_item37 := get_temploy_name(p_signer_codempid,global_v_lang) ;
    -----------------------------------------------------------------
    if v_item31 = 0 then
        v_item31 := '-' ;
    else
        v_item31 := v_item31 ;
    end if;

    if v_item32 = 0 then
        v_item32 := '-' ;
    else
        v_item32 := v_item32 ;
    end if;

    if v_item34 = 0 then
        v_item34 := '-' ;
    else
        v_item34 := v_item34 ;
    end if;

    if v_item35 = 0 then
        v_item35 := '-' ;
    else
        v_item35 := v_item35 ;
    end if;

    -----------------------------------------------------------------
    if v_item30 = 0 then
        v_item30 := '-' ;
    else
        v_item30 := TRIM(TO_CHAR(v_item30,'999,999,999,999.99')) ;
    end if;

    if v_item33 = 0 then
        v_item33 := '-' ;
    else
        v_item33 := TRIM(TO_CHAR(v_item33,'999,999,999,999.99')) ;
    end if;

    if v_item36 = 0 then
        v_item36 := '-' ;
    else
        v_item36 := TRIM(TO_CHAR(v_item36,'999,999,999,999.99')) ;
    end if;
    -----------------------------------------------------------------
    begin
      v_numseq := 1 ;
      v_rpt_codapp := 'HRTR3HX_FP1_MAIN' ;
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1,  item2,  item3,  item4,  item5,  item6,  item7,  item8,  item9,  item10,
             item11, item12, item13, item14, item15, item16, item17, item18, item19, item20,
             item21, item22, item23, item24, item25, item26, item27, item28, item29, item30,
             item31, item32, item33, item34, item35, item36, item37, item38
           )
      values
           (
             global_v_codempid, v_rpt_codapp, v_numseq,
             v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10,
             v_item11, v_item14, v_item13, v_item12, v_item15, v_item16, v_item17, v_item18, v_item19, v_item20,
             v_item21, v_item22, v_item23, v_item24, v_item25, v_item26, v_item27, v_item28, v_item29, v_item30,
             v_item31, v_item32, v_item33, v_item34, v_item35, v_item36, v_item37, v_item38
           );
           commit;
      -----------------------------------------------------
    exception when others then
      null;
    end;
    -----------------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR3HX_FP1_SUB1' ;
    for r_thisclss in c_thisclss1
    loop
       v_numseq      := v_numseq + 1;
       insert into ttemprpt ( codempid, codapp, numseq,item1)
       values ( global_v_codempid, v_rpt_codapp, v_numseq, r_thisclss.item1);
    end loop ;
    -----------------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR3HX_FP1_SUB2' ;
    for r_thisclss in c_thisclss2
    loop
       v_numseq      := v_numseq + 1;
       insert into ttemprpt ( codempid, codapp, numseq,item1)
       values ( global_v_codempid, v_rpt_codapp, v_numseq, r_thisclss.item1);
    end loop ;
    -----------------------------------------------------
    v_numseq := 1 ;
    v_rpt_codapp := 'HRTR3HX_FP2_FOOTER' ;
    v_item1 := get_temploy_name(p_signer_codempid,global_v_lang) ;
    v_item2 := p_posname ;
    insert into ttemprpt ( codempid, codapp, numseq, item1, item2 )
    values ( global_v_codempid, v_rpt_codapp, v_numseq, v_item1, v_item2 );
    commit;
    -----------------------------------------------------

    v_numseq_main := 0 ;
    v_rpt_codapp := 'HRTR3HX_FP2_MAIN' ;
    for r_main in c_thistrnn1
    loop
      v_numseq_main := v_numseq_main + 1 ;
      -------------------------------------
      select sum(st1.amttrcost)
      into   v_temp_amttrcost
      from   thiscost st1
      where  st1.dteyear = r_main.dteyear and
             st1.codcours = r_main.codcours and
             st1.numclseq = r_main.numclseq ;
      -------------------------------------
      insert into ttemprpt ( codempid, codapp, numseq,
                             item1,  item2, item3, item4, item5, item6, item7, item8, item9, item10)
      values ( global_v_codempid, v_rpt_codapp, v_numseq_main,
                     r_main.namcours, r_main.dtetr, hcm_util.convert_minute_to_hour(r_main.qtytrmin*60), r_main.tinstitu, r_main.numclseq, r_main.sum_male, r_main.sum_female, r_main.num_all, round((v_temp_amttrcost / r_main.num_all) , 2) ,v_temp_amttrcost); -- softberry || 26/04/2023 || #9358 || r_main.namcours, r_main.dtetr, r_main.qtytrmin, r_main.tinstitu, r_main.numclseq, r_main.sum_male, r_main.sum_female, r_main.num_all, round((v_temp_amttrcost / r_main.num_all) , 2) ,v_temp_amttrcost);
      -------------------------------------
      v_numseq_sub := 0 ;
      v_numseq := 0 ;
      v_rpt_codapp_sub := 'HRTR3HX_FP2_SUB_' || v_numseq_main ;
      for r_thistrnn in c_thistrnn2 (r_main.dteyear,r_main.codcours,r_main.numclseq,r_main.qtytrmin,r_main.dtetrst , r_main.dtetren)
          loop
            v_numseq_sub := v_numseq_sub + 1;
            v_numseq := v_numseq + 1 ;

            insert into ttemprpt ( codempid, codapp, numseq,
                                   item1,  item2,  item3)
            values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                    case
                        when length( r_thistrnn.numoffid) = 13 then
                            substr( r_thistrnn.numoffid, 1, 1) || '-' || 
                            substr( r_thistrnn.numoffid, 2, 4) || '-' || 
                            substr( r_thistrnn.numoffid, 6,5) || '-' || 
                            substr( r_thistrnn.numoffid, 11,2) || '-' || 
                            substr( r_thistrnn.numoffid, 13)
                        else    r_thistrnn.numoffid
                    end, r_thistrnn.codempid_name, r_thistrnn.codpos_name);
          end loop;
    end loop ;
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
    obj_data.put('position', get_tpostn_name(v_position, global_v_lang));
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_position;
----------------------------------------------------------------------------------

end HRTR3HX;

/
