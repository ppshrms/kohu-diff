--------------------------------------------------------
--  DDL for Package Body M_HRES6ME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRES6ME" is
/* Cust-Modify: KOHU-SM2301 */
-- last update: 06/12/2023 11:30

  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj                := json_object_t(json_str);
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
    if substr(to_char(sysdate,'yyyy'),1,2) = '25' then
      global_v_zyear        := 543;
    else
      global_v_zyear        := 0;
    end if;
    --b_index
    b_index_codempid        := hcm_util.get_string_t(json_obj,'p_codempid_query');
    if b_index_codempid is null then
      b_index_codempid      := hcm_util.get_string_t(json_obj,'codempid_query');
    end if;
    b_index_seqno           := to_number(hcm_util.get_string_t(json_obj,'seqno'));
    b_index_dtereq          := to_date(trim(hcm_util.get_string_t(json_obj,'dtereq')),'dd/mm/yyyy');
    b_index_seqnor          := to_number(hcm_util.get_string_t(json_obj,'seqnor'));
    b_index_dtereqr         := to_date(trim(hcm_util.get_string_t(json_obj,'dtereqr')),'dd/mm/yyyy');
    b_index_codinput        := hcm_util.get_string_t(json_obj,'codinput');

    b_index_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtereq_st       := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    b_index_dtereq_en       := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');
    --block tleavecc
    tleavecc_codempid       := hcm_util.get_string_t(json_obj,'codempid_query');
    tleavecc_seqno          := to_number(hcm_util.get_string_t(json_obj,'seqno'));
    tleavecc_dtereq         := to_date(trim(hcm_util.get_string_t(json_obj,'dtereq')),'dd/mm/yyyy');
    tleavecc_codleave       := hcm_util.get_string_t(json_obj,'codleave');
    tleavecc_desc_codleave  := '';
    tleavecc_dtestrt        := to_date(trim(hcm_util.get_string_t(json_obj,'dtestrt')),'dd/mm/yyyy');
    tleavecc_dteend         := to_date(trim(hcm_util.get_string_t(json_obj,'dteend')),'dd/mm/yyyy');
    tleavecc_desreq         := hcm_util.get_string_t(json_obj,'desreq');
    tleavecc_seqnor         := to_number(hcm_util.get_string_t(json_obj,'seqnor'));
    tleavecc_dtereqr        := to_date(trim(hcm_util.get_string_t(json_obj,'dtereqr')),'dd/mm/yyyy');
    tleavecc_numlereq       := hcm_util.get_string_t(json_obj,'numlereq');
    tleavecc_codcomp        := hcm_util.get_string_t(json_obj,'codcomp');
    tleavecc_codappr        := hcm_util.get_string_t(json_obj,'codappr');
    tleavecc_staappr        := hcm_util.get_string_t(json_obj,'staappr');
    tleavecc_dteupd         := to_date(trim(hcm_util.get_string_t(json_obj,'dteupd')),'dd/mm/yyyy');
    tleavecc_coduser        := hcm_util.get_string_t(json_obj,'coduser');
    tleavecc_approvno       := to_number(hcm_util.get_string_t(json_obj,'approvno'));
    tleavecc_remarkap       := hcm_util.get_string_t(json_obj,'remarkap');
    tleavecc_dteappr        := to_date(trim(hcm_util.get_string_t(json_obj,'dteappr')),'dd/mm/yyyy');
    tleavecc_routeno        := hcm_util.get_string_t(json_obj,'routeno');
    tleavecc_codinput       := hcm_util.get_string_t(json_obj,'codinput');
    tleavecc_dteinput       := to_date(trim(hcm_util.get_string_t(json_obj,'dteinput')),'dd/mm/yyyy');
    tleavecc_dtecancel      := to_date(trim(hcm_util.get_string_t(json_obj,'dtecancel')),'dd/mm/yyyy');
    --tleavecc_codempap       := json_ext.get_string(json_obj,'codempap');
    --tleavecc_codcompap      := json_ext.get_string(json_obj,'codcompap');
    --tleavecc_codposap       := json_ext.get_string(json_obj,'codposap');
    --param
    param_msg_error         := '';
  end;

  procedure check_index2 is
    error_secur varchar2(4000 char);
    v_dtereq    tleavecc.dtereq%type;
  begin
    if b_index_dtereq is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtereq');
      return;
    end if;
    if b_index_seqno is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numseq');
      return;
    end if;
    begin
      select dtereq
        into v_dtereq
        from tleavecc
       where codempid = b_index_codempid
         and dtereqr = b_index_dtereq
         and seqnor = b_index_seqno
         and seqno = (select max(seqno)
                        from tleavecc
                       where dtereqr = b_index_dtereq
                         and seqnor = b_index_seqno
                         and codempid = b_index_codempid)
         and rownum = 1;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
    end;
--    if p_codcompy is not null then
--      error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
--      if error_secur is not null then
--        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--        return;
--      end if;
--    end if;
  end;

  procedure get_index (json_str_input in clob,json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_tleavecc_detail(p_codempid in varchar2,p_seqnor in varchar2,p_dtereqr in date) is
  begin
    begin

      select staappr,remarkap,codappr,dteappr,
             chk_workflow.get_next_approve('HRES6ME',codempid,to_char(dtereq,'dd/mm/yyyy'),seqno,nvl(trim(approvno),'0'),global_v_lang)
        into tleavecc_staappr,tleavecc_remarkap,tleavecc_codappr,tleavecc_dteappr,tleavecc_codempap
        from tleavecc
       where dtereqr  = p_dtereqr
         and seqnor   = p_seqnor
         and codempid = p_codempid
         and seqno    = (select max(seqno)
                           from tleavecc
                          where dtereqr  = p_dtereqr
                            and seqnor   = p_seqnor
                            and codempid = p_codempid)
         and rownum = 1;
    exception when no_data_found then
      tleavecc_staappr  := null;
      tleavecc_remarkap := null;
      tleavecc_codappr  := null;
      tleavecc_codempap := null;
    end;
  end;

  procedure gen_index(json_str_output out clob) as
    json_obj        json_object_t;
    v_cursor        number;
    v_dummy         integer;
    v_stmt          varchar2(5000 char);
    v_remarkapcc    varchar2(4000 char);
    v_staapprcc     varchar2(4000 char);
    v_staapprccname varchar2(4000 char);

    v_num           number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;

    cursor c1 is
      select codempid, dtereq, seqno, codleave, dtestrt, timstrt, dteend, timend, deslereq, numlereq, staappr, dteappr,
             codappr, codcomp, remarkap, approvno, routeno, flgsend, dteupd, coduser,
             filenam1, codinput, dtecancel, dteinput, dtesnd, dteapph, flgagency, flgleave, codshift, dteleave
        from tleaverq
       where codempid like nvl(b_index_codempid,codempid)
         and seqno like nvl(b_index_seqno,seqno)
         and codcomp like nvl(b_index_codcomp,'%')
       --  and dtereq between nvl(b_index_dtereq_st,dtereq) and nvl(b_index_dtereq_en,dtereq)
         and (
                dtestrt  between nvl(b_index_dtereq_st,dtestrt) and nvl(b_index_dtereq_en,dtestrt)
                    or
                dteend  between nvl(b_index_dtereq_st,dteend) and nvl(b_index_dtereq_en,dteend)
                    or  
                b_index_dtereq_st between     dtestrt  and dteend
                    or
                b_index_dtereq_en between     dtestrt  and dteend                
                )
         and staappr in ('A', 'Y')
    order by codempid, dtereq desc, seqno desc;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for i in c1 loop
      v_num := v_num + 1;
      --
      get_tleavecc_detail(i.codempid,i.seqno,i.dtereq);
      --
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt',v_num);
      obj_data.put('codempid_query',i.codempid);
      obj_data.put('desc_codempid_query',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
      obj_data.put('seqno',i.seqno);
      obj_data.put('codleave',i.codleave);
      obj_data.put('desc_codleave',get_tleavecd_name(i.codleave,global_v_lang));
      obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
      obj_data.put('timstrt',i.timstrt);
      obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
      obj_data.put('timend',i.timend);
      obj_data.put('deslereq',i.deslereq);
      obj_data.put('numlereq',i.numlereq);
      obj_data.put('staappr',i.staappr);
      obj_data.put('status',get_tlistval_name('ESSTAREQ',trim(i.staappr),global_v_lang));
      obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
      obj_data.put('codappr',i.codappr);
      obj_data.put('desc_codappr',get_temploy_name(i.codappr,global_v_lang));
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('remarkap',i.remarkap);
      obj_data.put('approvno',i.approvno);
      obj_data.put('routeno',i.routeno);
      obj_data.put('desc_codempap',chk_workflow.get_next_approve('HRES62E',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.seqno,nvl(trim(i.approvno),'0'),global_v_lang));
      obj_data.put('flgsend',i.flgsend);
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_data.put('filenam1',i.filenam1||'$##$'||get_tsetup_value('PATHDOC'));
      obj_data.put('codinput',i.codinput);
      obj_data.put('desc_codinput',get_temploy_name(i.codinput,global_v_lang));
      obj_data.put('dtecancel',to_char(i.dtecancel,'dd/mm/yyyy'));
      obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
      obj_data.put('dtesnd',to_char(i.dtesnd,'dd/mm/yyyy'));
      obj_data.put('dteapph',to_char(i.dteapph,'dd/mm/yyyy'));
      obj_data.put('flgagency',i.flgagency);
      obj_data.put('flgleave',i.flgleave);
      obj_data.put('codshift',i.codshift);
      obj_data.put('desc_codshift',get_tshiftcd_name(i.codshift,global_v_lang));
      obj_data.put('dteleave',to_char(i.dteleave,'dd/mm/yyyy'));
      obj_data.put('staapprcc',tleavecc_staappr);
      obj_data.put('statuscc',get_tlistval_name('ESSTAREQ',tleavecc_staappr,global_v_lang));
      obj_data.put('remarkapcc',tleavecc_remarkap);
      obj_data.put('dteapprcc',to_char(tleavecc_dteappr,'dd/mm/yyyy'));
      obj_data.put('codapprcc',tleavecc_codappr);
      obj_data.put('desc_codapprcc',tleavecc_codappr ||' '|| get_temploy_name(tleavecc_codappr,global_v_lang));
      obj_data.put('codempapcc',tleavecc_codempap);
      obj_data.put('desc_codempapcc',tleavecc_codempap);

      obj_row.put(to_char(v_num-1),obj_data);
    end loop; -- end for
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_detail (json_str_input in clob,json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    --    check_index2;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_numseq        number;
    v_codapp        varchar2(30 char); --user36 KOHU-SM2301 06/12/2023
    v_msg_error     varchar2(4000 char) := ''; --user36 KOHU-SM2301 06/12/2023

    cursor c1 is
      select a.codempid,a.dtereq,a.seqno,a.codleave,
             a.dtestrt,a.dteend,b.staappr,a.numlereq,
             a.timstrt,a.timend,a.flgleave,a.deslereq,
             b.desreq as desreqcc,b.dtereq as dtereqcc,b.seqno as seqnocc
        from tleaverq a
        left join tleavecc b
          on a.codempid   = b.codempid
         and a.codempid   = b.codempid
         and a.dtereq     = b.dtereqr
         and a.seqno      = b.seqnor
         and b.seqno      = (select max(seqno)
                               from tleavecc c
                              where c.dtereqr  = b_index_dtereq
                                and c.seqnor   = b_index_seqno
                                and c.codempid = b_index_codempid)
         where a.codempid = b_index_codempid
         and a.dtereq   = b_index_dtereq
         and a.seqno    = b_index_seqno;

  begin
    obj_data := json_object_t();
    for r1 in c1 loop
      v_numseq := r1.seqnocc;
      if v_numseq is null then
        begin
          select nvl(max(seqno),0) + 1
            into v_numseq
            from tleavecc
           where codempid = b_index_codempid
             and dtereq = trunc(sysdate);
        exception when no_data_found then
          v_numseq := 1;
        end;
      end if;
      obj_data.put('coderror','200');
      obj_data.put('desc_coderror',' ');
      obj_data.put('httpcode',' ');
      obj_data.put('flg',' ');
      obj_data.put('codempid',r1.codempid);
      obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('dtereq',to_char(r1.dtereqcc,'dd/mm/yyyy'));
      obj_data.put('seqno',to_char(v_numseq));
      obj_data.put('dtereqr',to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('seqnor',to_char(r1.seqno));
      obj_data.put('codleave',r1.codleave);
      obj_data.put('desc_codleave',get_tleavecd_name(r1.codleave,global_v_lang));
      obj_data.put('dtestrt',to_char(r1.dtestrt,'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy'));
      obj_data.put('desreq',r1.desreqcc);
      obj_data.put('staappr',r1.staappr);
      obj_data.put('status',get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
      obj_data.put('numlereq',r1.numlereq);
      obj_data.put('timstrt',r1.timstrt);
      obj_data.put('timend',r1.timend);
      obj_data.put('flgleave',r1.flgleave);
      obj_data.put('deslereq',r1.deslereq);
      --<<user36 KOHU-SM2301 06/12/2023
      if r1.seqnocc is null then
      begin 
        select codapp
        into   v_codapp
        from   tempflow
        where  codapp   = 'HRES6ME'
        and    codempid = r1.codempid;
      exception when no_data_found then  
        v_msg_error := replace(get_error_msg_php('ESZ004',global_v_lang),'@#$%400');      
      end;
      end if;
      obj_data.put('error_msg', v_msg_error);
      -->>user36 KOHU-SM2301 06/12/2023

--      obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
--      obj_data.put('codappr',r1.codappr);
--      obj_data.put('desc_codappr',get_temploy_name(r1.codappr,global_v_lang));
--      obj_data.put('codcomp',r1.codcomp);
--      obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
--      obj_data.put('remarkap',r1.remarkap);
--      obj_data.put('approvno',to_char(r1.approvno));
--      obj_data.put('routeno',r1.routeno);
--      obj_data.put('codempap',r1.codempap);
--      obj_data.put('desc_codempap',chk_workflow.get_next_approve('HRES6ME',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,nvl(trim(r1.approvno),'0'),global_v_lang));
--      obj_data.put('codcompap',r1.codcompap);
--      obj_data.put('desc_codcompap',get_tcenter_name(r1.codcompap,global_v_lang));
--      obj_data.put('codposap',r1.codposap);
--      obj_data.put('desc_codposap',get_tpostn_name(r1.codposap,global_v_lang));
--      obj_data.put('flgsend',r1.flgsend);
--      obj_data.put('flgcanc',r1.flgcanc);
--      obj_data.put('dteupd',to_char(r1.dteupd,'dd/mm/yyyy'));
--      obj_data.put('coduser',r1.coduser);
--      obj_data.put('numlereq',r1.numlereq);
--      obj_data.put('codinput',r1.codinput);
--      obj_data.put('desc_codinput',get_temploy_name(r1.codinput,global_v_lang));
--      obj_data.put('dtecancel',to_char(r1.dtecancel,'dd/mm/yyyy'));
--      obj_data.put('dteinput',to_char(r1.dteinput,'dd/mm/yyyy'));
--      obj_data.put('dtesnd',to_char(r1.dtesnd,'dd/mm/yyyy'));
--      obj_data.put('dteapph',to_char(r1.dteapph,'dd/mm/yyyy'));
--      obj_data.put('flgagency',r1.flgagency);
    end loop; -- end while
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_data.to_clob(json_str_output);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure cancel_tleavecc (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_data;
    if param_msg_error is null then
      insert_next_step;
      if param_msg_error is null then
        save_tleavecc;
        commit;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end cancel_tleavecc;

  procedure check_data is
    v_codleave    tleavecd.codleave%type;
    v_typleave    tleavecd.typleave%type;
    v_staleave    tleavecd.staleave%type;
    v_descond     tleavecd.syncond%type;
    v_tleaverq    varchar2(1) := 'N';
    v_tlereqd     varchar2(1) := 'N';
    v_tleavetr    varchar2(1) := 'N';
    v_dtereq      date;
    v_codcomp     tcenter.codcomp%type;
    v_codapp      varchar2(30 char); --user36 KOHU-SM2301 06/12/2023

   cursor c2 is
    select dtestrt ,dteend
    from  tleaverq
    where codempid = b_index_codempid
    and   v_dtereq between dtestrt and dteend
    and   codleave = tleavecc_codleave
    and   staappr in ('P','A','Y') ;


   cursor c3 is
    select dtework
    from tlereqd
    where codempid = b_index_codempid
    and  codleave = tleavecc_codleave
    and dtework between tleavecc_dtestrt and tleavecc_dteend
    order by dtework;

   cursor c4 is
    select dtework
    from tleavetr
    where codempid = b_index_codempid
    and  codleave = tleavecc_codleave
    and dtework between tleavecc_dtestrt and tleavecc_dteend
    order by dtework;

  begin
      tleavecc_codempid      := b_index_codempid;
      tleavecc_desc_codleave := get_tleavecd_name(tleavecc_codleave, global_v_lang);

      if b_index_dtereq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleavecc_codleave is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleavecc_dtestrt is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleavecc_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleavecc_dtestrt > tleavecc_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
      end if;

      begin
        select codleave,typleave,staleave,syncond
        into   v_codleave,v_typleave,v_staleave,v_descond
        from   tleavecd
        where  codleave = tleavecc_codleave;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tleavecd');
        return;
      end;

      v_dtereq := tleavecc_dtestrt ;
      for j in c2 loop
          v_tleaverq := 'Y';
          exit;
      end loop;
      if v_tleaverq = 'Y' then
          v_dtereq := tleavecc_dteend ;
          for j in c2 loop
              v_tleaverq := 'Y';
              exit;
          end loop;
      end if;

      if v_tleaverq = 'N' then
          -- Check tlereqd
          for k in c3 loop
            v_tlereqd := 'Y';
            exit;
          end loop;

          if v_tlereqd = 'N' then
              -- Check tleavetr
              for k in c3 loop
                  v_tleavetr := 'Y';
                exit;
              end loop;
          end if;
     end if;

     if v_tleaverq = 'N' then
       param_msg_error := get_error_msg_php('ES0047',global_v_lang);
       return;
     end if;

      begin
        select codcomp
        into  v_codcomp
        from  temploy1
        where codempid =  b_index_codempid;
      exception when no_data_found then
        v_codcomp := null;
      end;
      tleavecc_codcomp := v_codcomp;
      if b_index_seqno is null then
          b_index_seqno    := gen_numseq;
      end if;

    --<<user36 KOHU-SM2301 06/12/2023
    begin 
      select codapp
      into   v_codapp
      from   tempflow
      where  codapp   = 'HRES6ME'
      and    codempid = b_index_codempid;
    exception when no_data_found then  
      param_msg_error := get_error_msg_php('ESZ004',global_v_lang);
      return;
    end;
    -->>user36 KOHU-SM2301 06/12/2023

    ---<<< weerayut 09/01/2018 Lock request during payroll
    if get_payroll_active('HRES6ME',tleavecc_codempid,tleavecc_dtestrt,tleavecc_dteend) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057',global_v_lang);
      return;
    end if;
    --->>> weerayut 09/01/2018
  end check_data;

  procedure insert_next_step is
    v_codapp     varchar2(10) := 'HRES6ME';
    v_count      number := 0;
    v_approvno   number := 0;
    v_codempid_next  temploy1.codempid%type;
    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   varchar2(4);
    v_remark     varchar2(200) := substr(get_label_name('HCM_APPRFLW',global_v_lang,10),1,600);
    v_routeno    varchar2(15);
    v_table			 varchar2(50 char);
    v_error			 varchar2(50 char);

    v_typleave       tleavecd.typleave%type;

  begin
--<< user14:||20/04/2022
    begin
      select typleave
        into v_typleave
        from tleavecd
       where codleave = tleavecc_codleave;
    exception when no_data_found then	null;
    end;
 -->>user14:||20/04/2022

         v_approvno         :=  0 ;
         v_codempap         := b_index_codempid ;
         tleavecc_staappr  := 'P';
--         chk_workflow.find_next_approve(v_codapp  ,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,v_codempap);
         chk_workflow.find_next_approve(v_codapp  ,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,v_codempap,v_typleave);
        --<< user22 : 20/08/2016 : HRMS590307 ||
         /*user36 KOHU-SM2301 06/12/2023 cancel
          if v_routeno is null then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
            return;
          end if;
          --
          chk_workflow.find_approval(v_codapp,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,v_table,v_error);
          if v_error is not null then
            param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
            return;
          end if;
        -->> user22 : 20/08/2016 : HRMS590307 ||
         --Loop Check Next step
         loop
           v_codempid_next := chk_workflow.Chk_NextStep(v_codapp,v_routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
--           v_codempid_next := chk_workflow.Check_Next_Approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,v_codempap);

           if  v_codempid_next is not null then
               v_approvno           := v_approvno + 1 ;
               tleavecc_codappr    := v_codempid_next ;
               tleavecc_staappr    := 'A' ;
               tleavecc_dteappr    := trunc(sysdate);
               tleavecc_remarkap   := v_remark;
               tleavecc_approvno   := v_approvno ;
                begin
                    select  count(*) into v_count
                     from   taplvecc
                     where  codempid = b_index_codempid
                     and    dtereq   = tleavecc_dtereq
                     and    seqno    = tleavecc_seqno
                     and    approvno = v_approvno;--:parameter.v_approvno;
                exception when no_data_found then  v_count := 0;
                end;

                if v_count = 0 then
                  insert into taplvecc
                          (codempid,dtereq,seqno,approvno,codappr,dteappr,
                           staappr,remark,coduser)
                  values  (b_index_codempid,b_index_dtereq,b_index_seqno,v_approvno/*:parameter.v_approvno* /,
                           v_codempid_next,trunc(sysdate),
                           'A',v_remark,global_v_coduser);
                else
                  update taplvecc  set codappr   = v_codempid_next,
                                      dteappr   = trunc(sysdate),
                                      staappr   = 'A',
                                      remark    = v_remark ,
                                      coduser   = global_v_coduser

                  where codempid  = b_index_codempid
                  and    dtereq   = tleavecc_dtereq
                  and    seqno    = tleavecc_seqno
                  and   approvno  = v_approvno;--:parameter.v_approvno;
                end if;
              chk_workflow.find_next_approve(v_codapp  ,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,v_codempid_next);
           else
              exit ;
           end if;
         end loop ;
        */

        tleavecc_approvno     := v_approvno ;
        tleavecc_routeno      := v_routeno ;

        commit;
  end insert_next_step;

  procedure save_tleavecc is
  begin

    tleavecc_codempid := b_index_codempid;
    tleavecc_dtereq   := b_index_dtereq;
    tleavecc_seqno    := b_index_seqno;
    tleavecc_dtereqr  := b_index_dtereqr;
    tleavecc_seqnor   := b_index_seqnor;
    tleavecc_coduser  := global_v_coduser;
    tleavecc_codinput := b_index_codinput;
    tleavecc_dteinput := sysdate;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    begin
      insert into tleavecc
      (codempid,    seqno,        dtereq,       codleave,     dtestrt,
       dteend,      desreq,       seqnor,       dtereqr,      numlereq,
       codcomp,     codappr,      staappr,      dteupd,       coduser,
       approvno,    remarkap,     dteappr,      routeno,      codinput,
       dteinput,    dtecancel)
      values
      (tleavecc_codempid,     tleavecc_seqno,       tleavecc_dtereq,      tleavecc_codleave,    tleavecc_dtestrt,
       tleavecc_dteend,       tleavecc_desreq,      tleavecc_seqnor,      tleavecc_dtereqr,     tleavecc_numlereq,
       tleavecc_codcomp,      tleavecc_codappr,     tleavecc_staappr,     tleavecc_dteupd,      tleavecc_coduser,
       tleavecc_approvno,     tleavecc_remarkap,    tleavecc_dteappr,     tleavecc_routeno,     tleavecc_codinput,
       tleavecc_dteinput,     tleavecc_dtecancel);
    exception when dup_val_on_index then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        update tleavecc
        set   codleave  = tleavecc_codleave,
              dtestrt   = tleavecc_dtestrt,
              dteend    = tleavecc_dteend,
              desreq    = tleavecc_desreq,
              seqnor    = tleavecc_seqnor,
              dtereqr   = tleavecc_dtereqr,
              numlereq  = tleavecc_numlereq,
              codcomp   = tleavecc_codcomp,
              codappr   = tleavecc_codappr,
              staappr   = tleavecc_staappr,
              coduser   = tleavecc_coduser,
              approvno  = tleavecc_approvno,
              remarkap  = tleavecc_remarkap,
              dteappr   = tleavecc_dteappr,
              routeno   = tleavecc_routeno,
              codinput  = tleavecc_codinput,
              dtecancel = tleavecc_dtecancel
        where codempid  = tleavecc_codempid
          and seqno     = tleavecc_seqno
          and dtereq    = tleavecc_dtereq;
    end;

  end save_tleavecc;

  function gen_numseq RETURN number is
    v_num         number:=0;
  begin
            begin
                select nvl(max(seqno),0) + 1
                  into v_num
                  from tleavecc
                 where codempid = b_index_codempid
                   and dtereq = trunc(sysdate);
            end;
  return(v_num);
  end;

end;

/
