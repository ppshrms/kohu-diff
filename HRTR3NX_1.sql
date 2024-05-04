--------------------------------------------------------
--  DDL for Package Body HRTR3NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR3NX" is
-- last update: 28/12/2020 19:55
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
    p_contact_codempid  := upper(hcm_util.get_string(json_obj, 'p_contact_codempid'));
    p_signer_codempid   := upper(hcm_util.get_string(json_obj, 'p_signer_codempid'));
    p_year              := upper(hcm_util.get_string(json_obj, 'p_year'));
    p_from_month        := upper(hcm_util.get_string(json_obj, 'p_from_month'));
    p_to_month          := upper(hcm_util.get_string(json_obj, 'p_to_month'));
    p_posname           := upper(hcm_util.get_string(json_obj, 'p_posname'));
    p_typreport1        := upper(hcm_util.get_string(json_obj, 'p_typreport1'));
    p_typreport2        := upper(hcm_util.get_string(json_obj, 'p_typreport2'));
    p_typreport3        := upper(hcm_util.get_string(json_obj, 'p_typreport3'));

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
         and upper(codapp) like upper('HRTR3NX') || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure get_rpt_fp1 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       clear_ttemprpt;
       gen_rpt_fp1(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_rpt_fp1;

  procedure gen_rpt_fp1 (json_str_output out clob) is
    v_cnt1           number;
    v_cnt2           number;
    v_numseq         number;
    v_rpt_codapp     varchar2(100 char) ;
    v_numseq_sub     number;
    v_rpt_codapp_sub varchar2(100 char) ;
    v_check_secur      boolean;
    v_sum_amttrcost      number ;
    v_item1  varchar2(1000 char) ; v_item2  varchar2(1000 char) ; v_item3  varchar2(1000 char) ; v_item4  varchar2(1000 char) ; v_item5  varchar2(1000 char) ;
    v_item6  varchar2(1000 char) ; v_item7  varchar2(1000 char) ; v_item8  varchar2(1000 char) ; v_item9  varchar2(1000 char) ; v_item10 varchar2(1000 char) ;
    v_item11 varchar2(1000 char) ; v_item12 varchar2(1000 char) ; v_item13 varchar2(1000 char) ; v_item14 varchar2(1000 char) ; v_item15 varchar2(1000 char) ;
    v_item16 varchar2(1000 char) ; v_item17 varchar2(1000 char) ; v_item18 varchar2(1000 char) ; v_item19 varchar2(1000 char) ; v_item20 varchar2(1000 char) ;
    v_item21 varchar2(1000 char) ; v_item22 varchar2(1000 char) ; v_item23 varchar2(1000 char) ; v_item24 varchar2(1000 char) ; v_item25 varchar2(1000 char) ;
    v_item26 varchar2(1000 char) ; v_item27 varchar2(1000 char) ; v_item28 varchar2(1000 char) ; v_item29 varchar2(1000 char) ; v_item30 varchar2(1000 char) ;
    v_item31 varchar2(1000 char) ; v_item32 varchar2(1000 char) ; v_item33 varchar2(1000 char) ; v_item34 varchar2(1000 char) ; v_item35 varchar2(1000 char) ;
    v_item36 varchar2(1000 char) ; v_item37 varchar2(1000 char) ; v_item38 varchar2(1000 char) ;
    --------------------------------------------------
    cursor c_thisclss_1 is
--          select (select st1.namcourst from tcourse st1 where st1.codcours = a.codcours) as item1
          select get_tcourse_name(a.codcours,global_v_lang) as item1
          from   thisclss a
          where  a.codcompy like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                 a.typtrain = '11'
          order by a.codcours ;
    --------------------------------------------------
    cursor c_thisclss_2 is
          select get_tcourse_name(a.codcours,global_v_lang) as item1
          from   thisclss a
          where  a.codcompy like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                 a.typtrain = '12'
          order by a.codcours ;
    --------------------------------------------------
    cursor c_thistrnn_1 is
          select a.codcours , a.dteyear,hcm_util.get_codcomp_level(a.codcomp,1),
                 (select st1.namcourst from tcourse st1 where st1.codcours = a.codcours) as namcourst ,
                 a.numclseq as numclseq , --a.timestr || ' ' || a.timeend as item4 ,
                 (select hcm_util.get_date_buddhist_era(ts.dtetrst) || '-' || hcm_util.get_date_buddhist_era(ts.dtetren) from thisclss ts where ts.codcours = a.codcours and ts.numclseq = a.numclseq and ts.dteyear = a.dteyear and  ts.codcompy = hcm_util.get_codcomp_level(a.codcomp,1) ) as item4 ,
                 sum(decode(b.codsex,'M',1,0)) + sum(decode(b.codsex,'F',1,0)) as sum_all , sum(decode(b.codsex,'M',1,0)) as sum_male ,sum(decode(b.codsex,'F',1,0)) as sum_female ,
                 (select st2.namempt from temploy1 st2 where st2.codempid = p_signer_codempid) as item8 ,
                 (select get_tpostn_name(st2.codpos,'102') from temploy1 st2 where st2.codempid = p_signer_codempid) as item9
          from   thistrnn a, temploy1 b , temploy2 c
          where  a.codempid = b.codempid and a.codempid = c.codempid and
                 a.codcomp like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.codtparg = '1' and a.typtrain in ('11','12') and a.pcttr >= 80
          group by a.codcours , a.numclseq , dteyear,hcm_util.get_codcomp_level(a.codcomp,1)--, a.timestr ,  a.timeend
          order by a.codcours , a.numclseq ;
    --------------------------------------------------
    cursor c_thistrnn_2 (v_numclseq in varchar2,v_codcours in varchar2) is
          select (select st1.namcourst from tcourse st1 where st1.codcours = a.codcours) as item1 ,
                 a.numclseq as item2 ,
                 a.timestr || ' ' || a.timeend as item3 ,
                 c.numoffid as item4 ,
                 b.namempt as item5 ,
                 get_tpostn_name(b.codpos,'102') as item6 ,
                 a.remarks as item7
          from   thistrnn a, temploy1 b , temploy2 c
          where  a.codcours = v_codcours and a.numclseq = v_numclseq and
                 a.codempid = b.codempid and a.codempid = c.codempid and
                 a.codcomp like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.codtparg = '1' and a.typtrain in ('11','12') and a.pcttr >= 80
          order by a.codcours , a.numclseq , c.numoffid ;
    --------------------------------------------------
    cursor c_thisclss_3 is
          select a.codcours as codcours, count(a.numclseq) as cnt_numclseq
          from   thisclss a
          where  a.codcompy like p_codcomp|| '%' and
                 a.dteyear = p_year and
                 a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                 a.typtrain in('11','12')
                  group by a.codcours
          order by a.codcours ;
    --------------------------------------------------
    cursor c_thisclss_4 (v_codcours in varchar2) is
           select a.codcours, a.numclseq, a.dtetrst, a.timestr, a.dtetren, a.timeend,
                   get_thotelif_name(a.codhotel,'102') as destrloc,
                   a.amtcost, a.amttotexp, a.codresp, a.objective, a.flgcerti , a.qtytrmin ,
                   ( select st1.desctrain
                     from   tyrtrsch st1
                     where  st1.dteyear = a.dteyear and  st1.codcompy like a.codcompy || '%' and
                            st1.codcours = a.codcours and
                            st1.numclseq = a.numclseq and rownum = 1) as desctrain
            from   thisclss a
            where  a.codcours = v_codcours and
                   a.codcompy like p_codcomp|| '%' and
                   a.dteyear = p_year and
                   a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                   a.typtrain in('11','12')
            order by a.numclseq ;
    --------------------------------------------------
    cursor c_thisinst_1 (v_codcours in varchar2) is
            select get_temploy_name(c.codempid, '102') as temploy_name ,
                   get_tpostn_name(c.codpos,'102') as tpostn_name
            from   thisinst a , tinstruc b , temploy1 c
            where  b.stainst = 'I' and a.codinst = b.codinst and b.codempid = c.codempid  and
                   a.dteyear = p_year and a.codcompy like p_codcomp|| '%' and a.codcours = v_codcours  and
                   a.numclseq in (select a.numclseq
                                  from   thisclss a
                                  where  a.codcompy like p_codcomp|| '%' and
                                         a.dteyear = p_year and
                                         a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                                         a.typtrain in('11','12') )

            group by c.codempid , c.codpos
            order by c.codempid ;
    --------------------------------------------------
    cursor c_thisinst_2 (v_codcours in varchar2) is
            select a.codinst ,
                   b.namfirstt ,
                   b.namepos
            from   thisinst a , tinstruc b
            where  b.stainst = 'E' and a.codinst = b.codinst and
                   a.dteyear = p_year and a.codcompy like p_codcomp|| '%' and a.codcours = v_codcours and
                   a.numclseq in (select a.numclseq
                                  from   thisclss a
                                  where  a.codcompy like p_codcomp|| '%' and
                                         a.dteyear = p_year and
                                         a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                                         a.typtrain in('11','12') )
            group by a.codinst, b.namfirstt ,b.namepos
            order by a.codinst ;
    --------------------------------------------------
    cursor c_thisclss_5 (v_codcours in varchar2) is
            select distinct get_temploy_name(a.codresp, '102') as temploy_name ,
                   get_tpostn_name( (select st1.codpos from temploy1 st1 where st1.codempid = a.codresp ),'102') as tpostn_name
            from   thisclss a
            where  a.codcours = v_codcours and
                   a.codcompy like p_codcomp|| '%' and
                   a.dteyear = p_year and
                   a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                   a.typtrain in('11','12')
            order by get_temploy_name(a.codresp, '102')  ;
    --------------------------------------------------
    cursor c_tyrtrsubj_1(v_codcours in varchar2) is
            select t.codsubj ,
                   get_tsubject_name( t.codsubj , '102') as tsubject_name ,
                   t.qtytrmin
            from   tyrtrsubj t
            where  t.dteyear = p_year and
                   t.codcompy like p_codcomp|| '%' and
                   t.codcours = v_codcours and
                   t.numclseq in (select a.numclseq
                                  from   thisclss a
                                  where  a.codcompy like p_codcomp|| '%' and
                                         a.dteyear = p_year and
                                         a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                                         a.typtrain in('11','12') and
                                         rownum = 1 )
            group by t.codsubj , t.qtytrmin
            order by t.codsubj ;
    --------------------------------------------------
    cursor c_tcosttr_1(v_codcours in varchar2) is
            select t.codexpn ,
                   ( select st1.descodt from tcodexpnc st1 where st1.codcompy = t.codcompy  and st1.codexpn = t.codexpn) as desexptr ,
                   t.numclseq , t.amttrcost
            from   tcosttr t
            where  t.dteyear = p_year and
                   t.codcompy  like p_codcomp|| '%' and
                   t.codcours = v_codcours and
                   t.amttrcost > 0 ;
    --------------------------------------------------
    cursor c_tcosttr_2(v_codcours in varchar2) is
            select t.numclseq , sum(t.amttrcost) as amttrcost
            from   tcosttr t
            where  t.dteyear = p_year and
                   t.codcompy  like p_codcomp|| '%' and
                   t.codcours = v_codcours and
                   t.amttrcost > 0
            group by t.numclseq ;
    --------------------------------------------------
   cursor c_tcosttr_3(v_codcours in varchar2) is
            select st1.numclseq ,  round((st2.amttrcost / st1.sum_emp ),2) as amttrcost_peremp
            from
              ( select a.numclseq , sum(decode(b.codsex,'M',1,0)) + sum(decode(b.codsex,'F',1,0)) as sum_emp
                from   thistrnn a , temploy1 b
                where  a.codempid = b.codempid and a.codcours = v_codcours and
                       a.dteyear = p_year and a.codcomp like p_codcomp|| '%' and a.pcttr >= 80
                group by a.numclseq , b.codsex  ) st1 ,
              ( select t.numclseq , sum(t.amttrcost) as amttrcost
                from   tcosttr t
                where  t.dteyear = p_year and
                       t.codcompy  like p_codcomp|| '%' and
                       t.codcours = v_codcours and
                       t.amttrcost > 0
                group by t.numclseq ) st2
            where st1.numclseq = st2.numclseq
            order by  st1.numclseq ;
    --------------------------------------------------
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
    into   v_cnt1
    from   thisclss a
    where  a.codcompy like p_codcomp|| '%' and
           a.dteyear = p_year and
           a.dtemonth between  to_number(p_from_month) and to_number(p_to_month) and
           a.typtrain in('11','12');
    -----------------------------------------------
    select count('x')
    into   v_cnt2
    from   thistrnn t
    where  t.codcomp like p_codcomp || '%' and
           t.dteyear = p_year and
           t.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           t.codtparg = '1' and
           t.typtrain in ('11','12')
           and t.pcttr >= 80 ;
    -----------------------------------------------
    if p_typreport1 = 'Y' then
      if v_cnt1 = 0 then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thisclss');
         return;
      end if ;
    end if ;
    -----------------------------------------------
    if p_typreport2 = 'Y' then
      if v_cnt2 = 0 then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thistrnn');
         return;
      end if ;
    end if ;
    -----------------------------------------------
    if p_typreport3 = 'Y' then
      if v_cnt1 = 0 then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thisclss');
         return;
      end if ;
    end if ;
    -----------------------------------------------
    v_item1 := get_ref_year(global_v_lang,'0',p_year);
    v_item2 := get_nammthabb(p_from_month, global_v_lang);
    v_item3 := get_nammthabb(p_to_month, global_v_lang);
    v_item5 := to_char(sysdate,'dd/mm/yyyy') ;
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
                    and a.codtparg = '1'
                    and a.typtrain in ('11','12')
                    and b.codsex = 'M' ) as item26 ,
           ( select count(distinct(a.codempid))
             from   thistrnn a, temploy1 b
             where  a.codempid = b.codempid
                    and a.codcomp like p_codcomp|| '%'
                    and a.dteyear = p_year
                    and a.dtemonth between to_number(p_from_month) and to_number(p_to_month)
                    and a.codtparg = '1'
                    and a.typtrain in ('11','12')
                    and b.codsex = 'F' ) as item27
    into   v_item4 , v_item6 , v_item7 , v_item8 , v_item9 , v_item10 , v_item11 , v_item12 , v_item13 , v_item14 , v_item15 , v_item16 ,
           v_item17 ,v_item21 , v_item23 , v_item24 , v_item26 , v_item27
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
    select count(distinct(st2.codcours)) , count(distinct(st2.numclseq)) , nvl(sum(st2.amttotexp),0)
    into   v_item31 , v_item32 , v_item33
    from   thisclss st2
    where  st2.codcompy like p_codcomp|| '%' and
           st2.dteyear = p_year and
           st2.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           st2.typtrain = '11' ;
    -----------------------------------------------------------------
    select count(distinct(st2.codcours)) , count(distinct(st2.numclseq)) , nvl(sum(st2.amttotexp),0)
    into   v_item34 , v_item35 , v_item36
    from   thisclss st2
    where  st2.codcompy like p_codcomp|| '%' and
           st2.dteyear = p_year and
           st2.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           st2.typtrain = '12' ;
    -----------------------------------------------------------------
    v_item22 := to_char( to_number(nvl(v_item23,'0')) + TO_NUMBER(nvl(v_item24,'0')) ) ;
    v_item25 := to_char( to_number(nvl(v_item26,'0')) + TO_NUMBER(nvl(v_item27,'0')) ) ;
    v_item28 := to_char( to_number(nvl(v_item31,'0')) + TO_NUMBER(nvl(v_item34,'0')) ) ;
    v_item29 := to_char( to_number(nvl(v_item32,'0')) + TO_NUMBER(nvl(v_item35,'0')) ) ;
    v_item30 := to_char( to_number(nvl(v_item33,'0')) + TO_NUMBER(nvl(v_item36,'0')) ) ;
    v_item37 := get_temploy_name(p_signer_codempid,global_v_lang) ;
    v_item38 := p_posname ;
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
      v_rpt_codapp := 'HRTR3NX_FP1_MAIN' ;
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1,  item2,  item3,  item4,  item5,  item6,  item7,  item8,  item9,  item10,
             item11, item12, item13, item14, item15, item16, item17, item18, item19, item20,
             item21, item22, item23, item24, item25, item26, item27, item28, item29, item30,
             item31, item32, item33, item34, item35, item36 , item37 , item38
           )
       values
           (
             global_v_codempid, v_rpt_codapp, v_numseq,
             v_item1, v_item2, v_item3, v_item4, v_item5, v_item6,trim(nvl(v_item7,'----------')), v_item8, v_item9, v_item10,
             v_item11, v_item12, v_item13, v_item14, v_item15, v_item16, v_item17, v_item18, v_item19, v_item20,
             v_item21, v_item22, v_item23, v_item24, v_item25, v_item26, v_item27, v_item28, v_item29, v_item30,
             v_item31, v_item32, v_item33, v_item34, v_item35, v_item36, v_item37, v_item38
           );
           commit;
      -----------------------------------------------------
    exception when others then
      null;
    end;
    -------------------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR3NX_FP1_SUB1' ;
    --------------------------------------------------------
    for r_thisclss in c_thisclss_1
    loop
       v_numseq      := v_numseq + 1;
       insert into ttemprpt ( codempid, codapp, numseq,item1)
       values ( global_v_codempid, v_rpt_codapp, v_numseq, r_thisclss.item1);
    end loop ;
    ---------------------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR3NX_FP1_SUB2' ;
    ---------------------------------------------------------
    for r_thisclss in c_thisclss_2
    loop
       v_numseq      := v_numseq + 1;
       insert into ttemprpt ( codempid, codapp, numseq,item1)
       values ( global_v_codempid, v_rpt_codapp, v_numseq, r_thisclss.item1);
    end loop ;
    -----------------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR3NX_FP3_MAIN' ;
    -----------------------------------------------------
    for r_main in c_thistrnn_1
    loop
      v_numseq := v_numseq + 1 ;
      insert into ttemprpt ( codempid, codapp, numseq,
                             item1,  item2, item3, item4, item5, item6, item7, item8, item9)
      values ( global_v_codempid, v_rpt_codapp, v_numseq,
               r_main.codcours, r_main.namcourst, r_main.numclseq, r_main.item4, r_main.sum_all, r_main.sum_male, r_main.sum_female, r_main.item8, r_main.item9);
      v_numseq_sub := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP3_SUB_' || v_numseq ;
      for r_thistrnn in c_thistrnn_2(r_main.numclseq,r_main.codcours)
          loop
            v_numseq_sub := v_numseq_sub + 1;
            insert into ttemprpt ( codempid, codapp, numseq,
                                   item1,  item2,  item3,  item4,  item5,  item6,  item7)
            values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                     r_thistrnn.item1, r_thistrnn.item2, r_thistrnn.item3, r_thistrnn.item4, r_thistrnn.item5, r_thistrnn.item6, r_thistrnn.item7);
            commit;
          end loop;
    end loop ;
    -----------------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR3NX_FP2_MAIN' ;
    for r_main in c_thisclss_3
    loop
      v_numseq      := v_numseq + 1;
      v_numseq_sub := 0 ;
      for r_thisclss in c_thisclss_4(r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        -------------------------------------------
        v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB1_' ||  v_numseq ;
        insert into ttemprpt ( codempid, codapp, numseq,
                               item1, item2 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_thisclss.numclseq , r_thisclss.objective );
        -------------------------------------------
        v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB2_' ||  v_numseq ;
        insert into ttemprpt ( codempid, codapp, numseq,
                               item1, item2, item3, item4 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 floor(r_thisclss.qtytrmin) || ':' || lpad( round(mod(r_thisclss.qtytrmin,1) * 60), 2, '0')
                 , r_thisclss.numclseq, r_thisclss.timestr, r_thisclss.timeend );
        -------------------------------------------
        v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB3_' ||  v_numseq ;
        insert into ttemprpt ( codempid, codapp, numseq,
                               item1, item2 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_thisclss.numclseq , r_thisclss.destrloc );
        -------------------------------------------
        select sum(decode(b.codsex,'M',1,0)) + sum(decode(b.codsex,'F',1,0)) , sum(decode(b.codsex,'M',1,0)) , sum(decode(b.codsex,'F',1,0))
        into   v_item2 , v_item3 , v_item4
        from   thistrnn a , temploy1 b
        where  a.codempid = b.codempid and a.codcours = r_thisclss.codcours and a.numclseq = r_thisclss.numclseq and
               a.dteyear = p_year and a.codcomp like p_codcomp|| '%' and a.pcttr >= 80 ;
        -------------------------------------------
        v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB4_' ||  v_numseq ;
        insert into ttemprpt ( codempid, codapp, numseq,
                               item1, item2, item3, item4 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_thisclss.numclseq , v_item2 , v_item3 , v_item4 );
        -------------------------------------------
        v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB5_' ||  v_numseq ;
        insert into ttemprpt ( codempid, codapp, numseq,
                               item1, item2 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_thisclss.numclseq , r_thisclss.desctrain );
        -------------------------------------------
      end loop ;
      ----------------------------------------------
      v_numseq_sub := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB6_' ||  v_numseq ;
      for r_thisinst in c_thisinst_1 (r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        insert into ttemprpt ( codempid, codapp, numseq,
                             item1, item2 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_thisinst.temploy_name , r_thisinst.tpostn_name );
      end loop ;
      ----------------------------------------------
      v_numseq_sub := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB7_' ||  v_numseq ;
      for r_thisinst in c_thisinst_2 (r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        insert into ttemprpt ( codempid, codapp, numseq,
                             item1, item2 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_thisinst.namfirstt , r_thisinst.namepos );
      end loop ;
      -------------------------------------------
      v_numseq_sub := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB8_' ||  v_numseq ;
      for r_thisclss in c_thisclss_5 (r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        insert into ttemprpt ( codempid, codapp, numseq,
                             item1, item2 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_thisclss.temploy_name , r_thisclss.tpostn_name );
      end loop ;
      -------------------------------------------
      v_numseq_sub := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB9_' ||  v_numseq ;
      for r_tyrtrsubj in c_tyrtrsubj_1 (r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        insert into ttemprpt ( codempid, codapp, numseq,
                             item1, item2 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_tyrtrsubj.tsubject_name , floor(r_tyrtrsubj.qtytrmin) || ':' || lpad( round(mod(r_tyrtrsubj.qtytrmin,1) * 60), 2, '0')  );
      end loop ;
      -------------------------------------------
      v_numseq_sub := 0 ;
      v_sum_amttrcost := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB10_' ||  v_numseq ;
      for r_tcosttr in c_tcosttr_1 (r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        v_sum_amttrcost := v_sum_amttrcost + r_tcosttr.amttrcost ;
        insert into ttemprpt ( codempid, codapp, numseq,
                             item1, item2, item3 )
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_tcosttr.desexptr , r_tcosttr.numclseq , r_tcosttr.amttrcost );

      end loop ;
      -------------------------------------------
      v_numseq_sub := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB11_' ||  v_numseq ;
      for r_tcosttr in c_tcosttr_2 (r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        insert into ttemprpt ( codempid, codapp, numseq,
                             item1, item2)
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_tcosttr.numclseq , r_tcosttr.amttrcost  );
      end loop ;
      -------------------------------------------
      v_numseq_sub := 0 ;
      v_rpt_codapp_sub := 'HRTR3NX_FP2_SUB12_' ||  v_numseq ;
      for r_tcosttr in c_tcosttr_3 (r_main.codcours)
      loop
        v_numseq_sub := v_numseq_sub + 1 ;
        insert into ttemprpt ( codempid, codapp, numseq,
                             item1, item2)
        values ( global_v_codempid, v_rpt_codapp_sub, v_numseq_sub,
                 r_tcosttr.numclseq , r_tcosttr.amttrcost_peremp  );
      end loop ;
      -------------------------------------------
      -- HRTR3NX_FP2_MAIN
      insert into ttemprpt ( codempid, codapp, numseq,
                             item1,  item2, item3 )
      values ( global_v_codempid, v_rpt_codapp, v_numseq,
               get_tcourse_name(r_main.codcours,global_v_lang)/*r_main.codcours*/ , r_main.cnt_numclseq ,v_sum_amttrcost);
      -------------------------------------------
    end loop ;

  json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  commit;
exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_rpt_fp1;
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

end HRTR3NX;

/
