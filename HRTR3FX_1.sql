--------------------------------------------------------
--  DDL for Package Body HRTR3FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR3FX" is
-- last update: 15/02/2021 19:45
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
    p_codcompy           := upper(hcm_util.get_string(json_obj, 'p_codcompy'));
    p_signer_codempid   := upper(hcm_util.get_string(json_obj, 'p_signer_codempid'));
    p_year              := upper(hcm_util.get_string(json_obj, 'p_year'));
    p_from_month        := upper(hcm_util.get_string(json_obj, 'p_from_month'));
    p_to_month          := upper(hcm_util.get_string(json_obj, 'p_to_month'));
    p_codcours          := upper(hcm_util.get_string(json_obj, 'p_codcours'));
    p_numclseq          := upper(hcm_util.get_string(json_obj, 'p_numclseq'));

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
         and upper(codapp) like upper('HRTR3FX') || '%';
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
    v_numseq         number;
    v_rpt_codapp     varchar2(100 char) ;
    v_sum_incr       number ;
    v_sum_under      number ;
    v_check_secur      boolean;
    v_temp_cnt       number ;
    v_item1  varchar2(1000 char) ; v_item2  varchar2(1000 char) ; v_item3  varchar2(1000 char) ; v_item4  varchar2(1000 char) ; v_item5  varchar2(1000 char) ;
    v_item6  varchar2(1000 char) ; v_item7  varchar2(1000 char) ; v_item8  varchar2(1000 char) ;
    v_permis    boolean := false;
    flgpass     boolean := true;
    --------------------------------------------------
    cursor c_thistrnn is
          select  ( select decode(global_v_lang,'101',st1.namcourse ,
                                                '102',st1.namcourst ,
                                                '103',st1.namcours3 ,
                                                '104',st1.namcours4 ,
                                                '105',st1.namcours5 ,
                                                st1.namcourse)
                     from tcourse st1
                     where st1.codcours = a.codcours) as namcours ,
                   hcm_util.get_date_buddhist_era(a.dtetrst) || '-' || hcm_util.get_date_buddhist_era(a.dtetren) as dtetr , a.qtytrmin ,
                   RPAD(SUBSTR( to_char(a.qtytrmin), instr( to_char(a.qtytrmin) ,'.', -1) + 1), 2, '0') as mins ,
                   LPAD(SUBSTR( a.qtytrmin , 1, instr(a.qtytrmin,'.')-1 ), 2, '0') as hours ,
                    a.codinst ,
                   decode(global_v_lang,'101',a.naminse,
                              '102',a.naminst,
                              '103',a.namins3,
                              '104',a.namins4,
                              '105',a.namins5,
                              a.naminse) as namins,
                              c.codempid, c.codcomp,
                   b.numoffid, get_tlistval_name('CODTITLE',c.codtitle ,global_v_lang) as title  ,
                   decode(global_v_lang,'101',c.namfirste,
                              '102',c.namfirstt,
                              '103',c.namfirst3,
                              '104',c.namfirst4,
                              '105',c.namfirst5,
                              c.namfirste) as namfirst,
                   decode(global_v_lang,'101',c.namlaste,
                              '102',c.namlastt,
                              '103',c.namlast3,
                              '104',c.namlast4,
                              '105',c.namlast5,
                              c.namlaste) as namlast,
                   d.flgeval,
                   a.codcours,a.numclseq
            from   thistrnn a, temploy2 b, temploy1 c, ttrimph d
            where  a.codempid = b.codempid and a.codempid = c.codempid and a.codempid = d.codempid and
                   a.dteyear = d.dteyear and a.codcours = d.codcours and
                   a.numclseq = d.numclseq and
                   a.codcomp like p_codcompy || '%' and
                   a.dteyear = p_year and
                   a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
                   a.codcours = nvl(p_codcours,a.codcours) and
                   a.numclseq = nvl(p_numclseq,a.numclseq)
            order by b.numoffid ;

  begin
    --------------------------------------------------
    if p_codcours is not null then
      select count('x')
      into   v_temp_cnt
      from   tcourse t
      where  t.codcours = p_codcours ;
      if v_temp_cnt = 0 then
         param_msg_error := get_error_msg_php('HR2010', global_v_lang);
         return;
      end if ;
    end if;
    --------------------------------------------------
    select count('x')
    into   v_temp_cnt
    from   temploy1 t
    where  t.codempid = p_signer_codempid ;
    if v_temp_cnt = 0 then
       param_msg_error := get_error_msg_php('HR2010', global_v_lang);
       return;
    end if ;
    --------------------------------------------------
    v_check_secur  := secur_main.secur2(p_signer_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
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
    --------------------------------------------------
    select count('x')
    into   v_cnt
    from   thistrnn a, temploy2 b, temploy1 c, ttrimph d
    where  a.codempid = b.codempid and a.codempid = c.codempid and a.codempid = d.codempid and
           a.dteyear = d.dteyear and a.codcours = d.codcours and
           a.numclseq = d.numclseq and
           a.codcomp like p_codcompy || '%' and
           a.dteyear = p_year and
           a.dtemonth between to_number(p_from_month) and to_number(p_to_month) and
           a.codcours = nvl(p_codcours,a.codcours) and
           a.numclseq = nvl(p_numclseq,a.numclseq);
    -----------------------------------------------
    if v_cnt = 0 then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thistrnn');
       return;
    end if ;
    -----------------------------------------------
    v_numseq := 0 ;
    v_rpt_codapp := 'HRTR3FX_SUB1' ;
    v_sum_incr := 0 ;
    v_sum_under := 0 ;

    for r_temploy in c_thistrnn
    loop
      flgpass	:= secur_main.secur3(r_temploy.codcomp,r_temploy.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
           v_permis := true;
           v_numseq      := v_numseq + 1;
           if r_temploy.flgeval = 'I' then
             v_sum_incr := v_sum_incr + 1 ;
           end if ;
           if r_temploy.flgeval = 'U' then
             v_sum_under := v_sum_under + 1 ;
           end if ;
           -----------------------------------------------
           insert into ttemprpt ( codempid, codapp, numseq, item1, item2, item3, item4)
           values ( global_v_codempid, v_rpt_codapp, v_numseq,
                   r_temploy.numoffid, r_temploy.title || r_temploy.namfirst, r_temploy.namlast, r_temploy.flgeval);
           -----------------------------------------------
           v_item1 := r_temploy.namcours ;
           v_item2 := r_temploy.dtetr ;
           --v_item3 := r_temploy.qtytrmin ;
           ----v_item3 := r_temploy.hours || ':' || r_temploy.mins ;
           v_item3 := hcm_util.convert_minute_to_hour(r_temploy.qtytrmin * 60); 
           v_item4 := r_temploy.codinst ;
           v_item8 := r_temploy.namins ;
        end if;
    end loop ;
    -----------------------------------------------------
    if not v_permis then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
    if v_item8 is null then
      v_item4 := get_tinstruc_name(v_item4,global_v_lang) ;
    else
      v_item4 := v_item8 ;
    end if ;
    v_item5 := v_sum_incr ;
    v_item6 := v_sum_under ;
    v_item7 := get_temploy_name(p_signer_codempid,global_v_lang) ;
    -----------------------------------------------
    begin
      -----------------------------------------------------
      v_numseq := 1 ;
      v_rpt_codapp := 'HRTR3FX_MAIN' ;
      -----------------------------------------------------
      insert
      into ttemprpt ( codempid, codapp, numseq, item1,  item2,  item3,  item4,  item5,  item6,  item7 )
      values ( global_v_codempid, v_rpt_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7);
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
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------

end HRTR3FX;

/
