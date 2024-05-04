--------------------------------------------------------
--  DDL for Package Body HRTR3MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR3MX" is
-- last update: 03/07/2020 14:30
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
         and upper(codapp) like upper('HRTR3MX') || '%';
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
    v_cnt            number;
    v_numseq         number;
    v_rpt_codapp     varchar2(100 char);
    v_check_secur      boolean;
    v_item1  varchar2(1000 char); v_item2  varchar2(1000 char); v_item3  varchar2(1000 char); v_item4  varchar2(1000 char); v_item5  varchar2(1000 char);
    v_item6  varchar2(1000 char); v_item7  varchar2(1000 char); v_item8  varchar2(1000 char); v_item9  varchar2(1000 char); v_item10 varchar2(1000 char);
    v_item11 varchar2(1000 char); v_item12 varchar2(1000 char); v_item13 varchar2(1000 char); v_item14 varchar2(1000 char); v_item15 varchar2(1000 char);
    v_item16 varchar2(1000 char); v_item17 varchar2(1000 char); v_item18 varchar2(1000 char); v_item19 varchar2(1000 char);

    cursor c_temploy1 is
      select  t2.numoffid as item1 , get_tlistval_name('CODTITLE',t1.codtitle,global_v_lang) as item2 , t1.namfirstt as item3 , t1.namlastt as item4
             ,t1.codempid 
      from    temploy1 t1 , temploy2 t2
      where   t1.codempid = t2.codempid and
              t1.codcomp like p_codcompy || '%' and
              t1.dteempmt <= sysdate and
              t1.staemp in ('1','3')
      order by t2.numoffid;

  begin
    v_check_secur  := secur_main.secur2(p_signer_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
    if not v_check_secur then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;
    --------------------------------------------------
    v_check_secur  := secur_main.secur7(p_codcompy, global_v_coduser);
    if not v_check_secur then
       param_msg_error := get_error_msg_php('HR3007', global_v_lang);
       return;
    end if;
    -----------------------------------------------------
    begin 
      select count('x')
      into   v_cnt
      from    temploy1 t1 , temploy2 t2
      where   t1.codempid = t2.codempid and
              t1.codcomp like p_codcompy || '%' and
              t1.dteempmt <= sysdate and
              t1.staemp in ('1','3');
    end; 
    ----------------------------------------------- 
    if v_cnt = 0 then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
       return;
    end if;
    -----------------------------------------------
    v_numseq := 0;
    v_rpt_codapp := 'HRTR3MX_SUB1';
    for r_temploy in c_temploy1 loop
      v_check_secur  := secur_main.secur2(r_temploy.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal); ----
      if v_check_secur then 
        v_numseq      := v_numseq + 1;
        insert into ttemprpt ( codempid, codapp, numseq, item1, item2, item3, item4)
        values ( global_v_codempid, v_rpt_codapp, v_numseq, r_temploy.item1, r_temploy.item2, r_temploy.item3, r_temploy.item4);
      end if; 
    end loop; 
    if v_numseq = 0 then 
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
    -----------------------------------------------------
    begin 
      select nvl(t1.numacdsd,t1.numacsoc) ,
             decode(global_v_lang,'101',t1.namcome,
                                  '102',t1.namcomt,
                                  '103',t1.namcom3,
                                  '104',t1.namcom4,
                                  '105',t1.namcom5,t1.namcome) as namcom ,
             decode(global_v_lang,'101',t1.addrnoe || ' ' || t1.buildinge ,
                                  '102',t1.addrnot || ' ' || t1.buildingt ,
                                  '103',t1.addrno3 || ' ' || t1.building3 ,
                                  '104',t1.addrno4 || ' ' || t1.building4 ,
                                  '105',t1.addrno5 || ' ' || t1.building5 , t1.addrnoe || ' ' || t1.buildinge) as addrno_building ,
             decode(global_v_lang,'101',t1.mooe,
                                  '102',t1.moot,
                                  '103',t1.moo3,
                                  '104',t1.moo4,
                                  '105',t1.moo5, t1.mooe) as moo ,
             decode(global_v_lang,'101',t1.soie,
                                  '102',t1.soit,
                                  '103',t1.soi3,
                                  '104',t1.soi4,
                                  '105',t1.soi5, t1.soie) as soi ,
             decode(global_v_lang,'101',t1.roade,
                                  '102',t1.roadt,
                                  '103',t1.road3,
                                  '104',t1.road4,
                                  '105',t1.road5, t1.roade) as road ,
             get_tsubdist_name(t1.codsubdist, global_v_lang) ,
             get_tcoddist_name(t1.coddist, global_v_lang) ,
             get_tcodec_name('TCODPROV', t1.codprovr , global_v_lang ) ,
             t1.zipcode , t1.numtele , t1.numfax ,
             (select get_tpostn_name(t.codpos,global_v_lang) from temploy1 t where t.codempid = p_signer_codempid ) as codpos
      into   v_item1 , v_item2 , v_item3 , v_item4 , v_item5 , v_item6 ,
             v_item7 , v_item8 , v_item9 , v_item10 , v_item11 , v_item12, v_item16
      from   tcompny t1
      where  t1.codcompy = p_codcompy;
    exception when no_data_found then null; 
    end; 
    v_item13 := TO_CHAR(SYSDATE, 'dd', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') || ' ' ||
                trim(TO_CHAR(SYSDATE, 'MONTH', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')) || ' ' ||
                TO_CHAR(SYSDATE, 'yyyy', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI');
    v_item14 := v_numseq;
    v_item15 := get_temploy_name(p_signer_codempid,global_v_lang);
    v_item17 := TO_CHAR(SYSDATE, 'dd', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI');
    v_item18 := trim(TO_CHAR(SYSDATE, 'MONTH', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI'));
    v_item19 := TO_CHAR(SYSDATE, 'yyyy', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI');
    -----------------------------------------------
    begin
      -----------------------------------------------------
      v_numseq := 1;
      v_rpt_codapp := 'HRTR3MX_MAIN';
      -----------------------------------------------------
      insert
      into ttemprpt
           (
             codempid, codapp, numseq,
             item1,  item2,  item3,  item4,  item5,  item6,  item7,  item8,  item9,  item10,
             item11, item12, item13, item14, item15, item16, item17 , item18 , item19
           )
      values
           (
             global_v_codempid, v_rpt_codapp, v_numseq,
             v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10,
             v_item11, v_item12, v_item13, v_item14, v_item15, v_item16, v_item17 , v_item18 , v_item19
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
  end gen_rpt;
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------

end HRTR3MX;

/
