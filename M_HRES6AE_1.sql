--------------------------------------------------------
--  DDL for Package Body M_HRES6AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRES6AE" AS
/* Cust-Modify: KOHU-SM2301 */
-- last update: 07/12/2023 15:00

  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'ddmmyyyy');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj, 'p_dtereq'), 'ddmmyyyy');
    p_dtework           := to_date(hcm_util.get_string_t(json_obj, 'p_dtework'), 'ddmmyyyy');
    p_dtereq2save       := to_date(hcm_util.get_string_t(json_obj, 'dtereq'), 'dd/mm/yyyy');
    p_dtework2save      := to_date(hcm_util.get_string_t(json_obj, 'dtework'), 'dd/mm/yyyy');
    p_numseq            := hcm_util.get_number_t(json_obj, 'numseq');
    p_staappr           := hcm_util.get_string_t(json_obj, 'staappr');

    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
    if p_codcomp is null and p_codempid_query  is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;    
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;

    cursor C1 is
      select a.codempid, a.dtereq, a.dtework, a.numseq, a.codshift, a.dtein, a.timin, a.dteout, a.timout, a.codreqst, a.codcomp, a.numlvl, a.codshift2,
             a.dtein2, a.timin2, a.dteout2, a.timout2, a.remark, a.dteappr, a.codappr, a.remarkap, a.approvno, a.staappr, a.routeno
             , a.flgsend, a.codinput, a.dtecancel, a.dteinput, a.dtesnd, a.dteupd, a.coduser, a.dteapph, a.flgagency
        from ttimereq a, temploy1 b
       where a.codempid = b.codempid(+)
         and a.codempid = nvl(p_codempid_query, a.codempid)
         and a.codcomp like p_codcomp||'%'
       --and a.dtereq between nvl(p_dtestrt, a.dtereq) and nvl(p_dteend, a.dtereq)
        and a.dtework between nvl(p_dtestrt, a.dtework) and nvl(p_dteend, a.dtework)
         and (a.codempid = global_v_codempid or
             (a.codempid <> global_v_codempid
               and b.numlvl between global_v_zminlvl and global_v_zwrklvl
               and 0 <> (select count(ts.codcomp)
                     from tusrcom ts
                    where ts.coduser = global_v_coduser
                      and a.codcomp like ts.codcomp || '%'
                      and rownum    <= 1 )))
      order by a.codempid, a.dtereq desc, a.numseq desc, a.dtework desc;

  begin
    obj_row       := json_object_t();

    for i in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('desc_codempid', nvl(get_temploy_name(trim(i.codempid), global_v_lang), ''));
      obj_data.put('codempid_query', i.codempid);
      obj_data.put('desc_codempid_query', nvl(get_temploy_name(trim(i.codempid), global_v_lang), ''));
      obj_data.put('dtereq', nvl(to_char(i.dtereq, 'dd/mm/yyyy'), ''));
      obj_data.put('dtework', nvl(to_char(i.dtework, 'dd/mm/yyyy'), ''));
      obj_data.put('numseq', i.numseq);
      obj_data.put('codshift', i.codshift);
      obj_data.put('dtein', nvl(to_char(i.dtein, 'dd/mm/yyyy'), ''));
      obj_data.put('timin', to_char(to_date(i.timin, 'hh24mi'), 'hh24:mi') || ' - ' || to_char(to_date(i.timout, 'hh24mi'), 'hh24:mi'));
      obj_data.put('dteout', nvl(to_char(i.dteout, 'dd/mm/yyyy'), ''));
      obj_data.put('timout', to_char(to_date(i.timin, 'hh24mi'), 'hh24:mi') || ' - ' || to_char(to_date(i.timout, 'hh24mi'), 'hh24:mi'));
      obj_data.put('timinout', to_char(to_date(i.timin, 'hh24mi'), 'hh24:mi') || ' - ' || to_char(to_date(i.timout, 'hh24mi'), 'hh24:mi'));
      obj_data.put('codreqst', i.codreqst);
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('numlvl', i.numlvl);
      obj_data.put('codshift2', i.codshift2);
      obj_data.put('dtein2', nvl(to_char(i.dtein2, 'dd/mm/yyyy'), ''));
      obj_data.put('timin2', i.timin2);
      obj_data.put('dteout2', nvl(to_char(i.dteout2, 'dd/mm/yyyy'), ''));
      obj_data.put('timout2', i.timout2);
      obj_data.put('remark', i.remark);
      obj_data.put('dteappr', nvl(to_char(i.dteappr, 'dd/mm/yyyy'), ''));
      obj_data.put('codappr', i.codappr);
      obj_data.put('remarkap', i.remarkap);
      obj_data.put('approvno', i.approvno);
      obj_data.put('staappr', i.staappr);
      obj_data.put('desc_staappr', nvl(get_tlistval_name('ESSTAREQ', trim(i.staappr), global_v_lang), ''));
      obj_data.put('routeno', i.routeno);
      obj_data.put('flgsend', i.flgsend);
      obj_data.put('codinput', i.codinput);
      obj_data.put('dtecancel', nvl(to_char(i.dtecancel, 'dd/mm/yyyy'), ''));
      obj_data.put('dteinput', nvl(to_char(i.dteinput, 'dd/mm/yyyy'), ''));
      obj_data.put('dtesnd', nvl(to_char(i.dtesnd, 'dd/mm/yyyy'), ''));
      obj_data.put('dteupd', nvl(to_char(i.dteupd, 'dd/mm/yyyy'), ''));
      obj_data.put('coduser', i.coduser);
      obj_data.put('dteapph', nvl(to_char(i.dteapph, 'dd/mm/yyyy'), ''));
      obj_data.put('flgagency', i.flgagency);
      obj_data.put('desc_codcomp', nvl(get_tcenter_name(trim(i.codcomp), global_v_lang), ''));
      obj_data.put('desc_codappr', i.codappr || ' ' || nvl(get_temploy_name(trim(i.codappr), global_v_lang), ''));
      obj_data.put('desc_codempap', nvl(chk_workflow.get_next_approve('HRES6AE', i.codempid, to_char(i.dtereq, 'dd/mm/yyyy'), i.numseq, nvl(trim(i.approvno), '0'), global_v_lang), ''));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_row                   json_object_t;
    obj_data                  json_object_t;
    v_rcnt                    number := 0;
    v_numseq                  number;
    v_late                    number;
    v_early                   number;
    v_absent                  number;

    temp_ttimereq_dtework     tattence.dtework%type;
    temp_ttimereq_codshift    tattence.codshift%type;
    temp_ttimereq_typwork     tattence.typwork%type;
    temp_ttimereq_dtein       tattence.dtein%type;
    temp_ttimereq_dteout      tattence.dteout%type;
    temp_ttimereq_timin       tattence.timin%type;
    temp_ttimereq_timout      tattence.timout%type;
    temp_ttimereq_codreqst    tattence.codchng%type;
    temp_ttimereq_codcomp     tattence.codcomp%type;

    temp_ttimereq_codempid    ttimereq.codempid%type;
    temp_ttimereq_dtereq      ttimereq.dtereq%type;
    temp_ttimereq_numseq      ttimereq.numseq%type;
    temp_ttimereq_remark      ttimereq.remark%type;
    temp_ttimereq_numlvl      ttimereq.numlvl%type;
    temp_ttimereq_staappr     ttimereq.staappr%type;

    temp_ttimereq_qtylate     varchar2(100 char);
    temp_ttimereq_qtyearly    varchar2(100 char);
    temp_ttimereq_qtyabsent   varchar2(100 char);

    temp_ttimereq_dtestrtw    date;
    temp_ttimereq_timstrtw    varchar2(100 char);
    temp_ttimereq_dteendw     date;
    temp_ttimereq_timendw     varchar2(100 char);

    cursor c_tattence is
      select dtework, codshift, dtein, timin, dteout, timout, codcomp, codchng, typwork, dtestrtw, timstrtw, dteendw, timendw, codempid
        from tattence
       where codempid = p_codempid_query
         and dtework  = p_dtework
      order by dtework;

    cursor c_ttimereq is
      select codempid, dtereq, dtework, codshift, dtein, timin, dteout, timout, codcomp, numlvl, codreqst, remark, staappr, numseq
        from ttimereq
       where codempid = p_codempid_query
         and dtereq   = p_dtereq
         and numseq   = p_numseq
         and dtework  = p_dtework
      order by dtereq desc, numseq desc;
  begin
    -- get max numseq
    begin
      select max(nvl(numseq, 0)) into v_numseq
        from ttimereq
        where codempid = p_codempid_query
          and dtereq   = trunc(sysdate);
    end;
    v_numseq :=   nvl(v_numseq, 0) + 1;
    --
    obj_row := json_object_t();
    for r_tattence in c_tattence loop
      v_rcnt := v_rcnt + 1;
      temp_ttimereq_codempid     := r_tattence.codempid;
      temp_ttimereq_numseq       := v_numseq;
      temp_ttimereq_dtereq       := trunc(sysdate);
      temp_ttimereq_dtework      := r_tattence.dtework;
      temp_ttimereq_codshift     := r_tattence.codshift;
      temp_ttimereq_typwork      := r_tattence.typwork;
      temp_ttimereq_dtein        := r_tattence.dtein;
      temp_ttimereq_dteout       := r_tattence.dteout;
      temp_ttimereq_timin        := r_tattence.timin;
      temp_ttimereq_timout       := r_tattence.timout;
      temp_ttimereq_codreqst     := r_tattence.codchng;
      temp_ttimereq_codcomp      := r_tattence.codcomp;
      temp_ttimereq_dtestrtw     := r_tattence.dtestrtw;
      temp_ttimereq_timstrtw     := r_tattence.timstrtw;
      temp_ttimereq_dteendw      := r_tattence.dteendw;
      temp_ttimereq_timendw      := r_tattence.timendw;
      temp_ttimereq_remark       := null;
      temp_ttimereq_numlvl       := null;
      temp_ttimereq_staappr      := null;

      begin
        select numlvl into temp_ttimereq_numlvl
          from temploy1
          where codempid = p_codempid_query;
      exception when no_data_found then
        temp_ttimereq_numlvl  := null;
      end;

      begin
        select nvl(qtylate, 0), nvl(qtyearly, 0), nvl(qtyabsent, 0)
          into v_late, v_early, v_absent
          from tlateabs
          where codempid = p_codempid_query
            and dtework  = r_tattence.dtework;
      exception when no_data_found then
        v_late   := null;
        v_early  := null;
        v_absent := null;
      end;
      temp_ttimereq_qtylate    := null;
      temp_ttimereq_qtyearly   := null;
      temp_ttimereq_qtyabsent  := null;

      if nvl(v_late, 0) > 0 then
        temp_ttimereq_qtylate   := trunc(v_late / 60, 0)||':'||lpad(mod(v_late, 60), 2, '0');
      end if;
      if nvl(v_early, 0) > 0 then
        temp_ttimereq_qtyearly  := trunc(v_early / 60, 0)||':'||lpad(mod(v_early, 60), 2, '0');
      end if;
      if nvl(v_absent, 0) > 0 then
        temp_ttimereq_qtyabsent := trunc(v_absent / 60, 0)||':'||lpad(mod(v_absent, 60), 2, '0');
      end if;

      temp_ttimereq_codcomp       := r_tattence.codcomp;
      temp_ttimereq_dtein         := null;
      temp_ttimereq_dteout        := null;
      temp_ttimereq_timin         := null;
      temp_ttimereq_timout        := null;
      temp_ttimereq_codreqst      := null;
      temp_ttimereq_remark        := null;
      temp_ttimereq_codcomp       := null;
      temp_ttimereq_numlvl        := null;
      temp_ttimereq_dtereq        := null;
      temp_ttimereq_numseq        := null;
      temp_ttimereq_codempid      := null;
      temp_ttimereq_staappr       := null;
      for r_ttimereq in c_ttimereq loop
        temp_ttimereq_dtein         := r_ttimereq.dtein;
        temp_ttimereq_dteout        := r_ttimereq.dteout;
        temp_ttimereq_timin         := r_ttimereq.timin;
        temp_ttimereq_timout        := r_ttimereq.timout;
        temp_ttimereq_codreqst      := r_ttimereq.codreqst;
        temp_ttimereq_remark        := r_ttimereq.remark;
        temp_ttimereq_codcomp       := r_ttimereq.codcomp;
        temp_ttimereq_numlvl        := r_ttimereq.numlvl;
        temp_ttimereq_dtereq        := r_ttimereq.dtereq;
        temp_ttimereq_numseq        := r_ttimereq.numseq;
        temp_ttimereq_codempid      := r_ttimereq.codempid;
        temp_ttimereq_staappr       := r_ttimereq.staappr;
        exit;
      end loop;

      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid_query);
      obj_data.put('codempid_query', temp_ttimereq_codempid);
      obj_data.put('dtereq', to_char(temp_ttimereq_dtereq, 'dd/mm/yyyy'));
      obj_data.put('numseq', to_char(temp_ttimereq_numseq));
      obj_data.put('dtework', to_char(temp_ttimereq_dtework, 'dd/mm/yyyy'));
      obj_data.put('typwork', temp_ttimereq_typwork);
      obj_data.put('codshift', temp_ttimereq_codshift);
      obj_data.put('dtein', to_char(temp_ttimereq_dtein, 'dd/mm/yyyy'));
      obj_data.put('timin', to_char(to_date(temp_ttimereq_timin, 'hh24mi'), 'hh24:mi'));
      obj_data.put('dteout', to_char(temp_ttimereq_dteout, 'dd/mm/yyyy'));
      obj_data.put('timout', to_char(to_date(temp_ttimereq_timout, 'hh24mi'), 'hh24:mi'));
      obj_data.put('codreqst', temp_ttimereq_codreqst);
      obj_data.put('remark', temp_ttimereq_remark);
      obj_data.put('qtylate', temp_ttimereq_qtylate);
      obj_data.put('qtyearly', temp_ttimereq_qtyearly);
      obj_data.put('qtyabsent', temp_ttimereq_qtyabsent);
      obj_data.put('staappr', temp_ttimereq_staappr);
      obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', temp_ttimereq_staappr, global_v_lang));
      obj_data.put('dtestrtw', to_char(temp_ttimereq_dtestrtw, 'dd/mm/yyyy'));
      obj_data.put('timstrtw', to_char(to_date(temp_ttimereq_timstrtw, 'hh24mi'), 'hh24:mi'));
      obj_data.put('dteendw', to_char(temp_ttimereq_dteendw, 'dd/mm/yyyy'));
      obj_data.put('timendw', to_char(to_date(temp_ttimereq_timendw, 'hh24mi'), 'hh24:mi'));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_detail;

  procedure check_detail_search as
  begin
    if p_dtestrt > trunc(sysdate) or p_dteend > trunc(sysdate) then
      param_msg_error := get_error_msg_php('HR1508', global_v_lang);
      return;
    end if;

    if p_codempid_query is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

  end;

  procedure get_detail_search (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail_search;
    if param_msg_error is null then
      gen_detail_search(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_search;

  procedure gen_detail_search (json_str_output out clob) AS
    obj_row                   json_object_t;
    obj_data                  json_object_t;
    v_numseq                  number;
    v_rcnt                    number := 0;
    v_dtework                 date;
    v_late                    number;
    v_early                   number;
    v_absent                  number;

    temp_ttimereq_dtework     tattence.dtework%type;
    temp_ttimereq_codshift    tattence.codshift%type;
    temp_ttimereq_typwork     tattence.typwork%type;
    temp_ttimereq_dtein       tattence.dtein%type;
    temp_ttimereq_dteout      tattence.dteout%type;
    temp_ttimereq_timin       tattence.timin%type;
    temp_ttimereq_timout      tattence.timout%type;
    temp_ttimereq_codreqst    tattence.codchng%type;
    temp_ttimereq_codcomp     tattence.codcomp%type;

    temp_ttimereq_codempid    ttimereq.codempid%type;
    temp_ttimereq_dtereq      ttimereq.dtereq%type;
    temp_ttimereq_numseq      ttimereq.numseq%type;
    temp_ttimereq_remark      ttimereq.remark%type;
    temp_ttimereq_numlvl      ttimereq.numlvl%type;
    temp_ttimereq_staappr     ttimereq.staappr%type;

    temp_ttimereq_qtylate     varchar2(100 char);
    temp_ttimereq_qtyearly    varchar2(100 char);
    temp_ttimereq_qtyabsent   varchar2(100 char);
    temp_ttimereq_dtestrtw    date;
    temp_ttimereq_timstrtw    varchar2(100 char);
    temp_ttimereq_dteendw     date;
    temp_ttimereq_timendw     varchar2(100 char);

    v_codapp                  varchar2(30 char); --user36 KOHU-SM2301 06/12/2023
    v_msg_error               varchar2(4000 char) := ''; --user36 KOHU-SM2301 06/12/2023

    cursor c_tattence is
      select dtework, codshift, dtein, timin, dteout, timout, codcomp, codchng, typwork, dtestrtw, timstrtw, dteendw, timendw, codempid,
             get_payroll_active('HRES6AE', codempid, dtework, dtework) as flgpayroll
        from tattence
       where codempid = p_codempid_query
         and dtework  between p_dtestrt and p_dteend
         and dtework  <= trunc(sysdate)
      order by dtework;

    cursor c_ttimereq is
      select codempid, dtereq, dtework, codshift, dtein, timin, dteout, timout, codcomp, numlvl, codreqst, remark, staappr, numseq
        from ttimereq
       where codempid = p_codempid_query
         and dtework  = v_dtework
  --<< user22 : 27/08/2016 : HRMS590310 ||
         and staappr  = 'P'
         and dtereq   = trunc(sysdate)
         --and staappr in ('P', 'A')
  -->> user22 : 27/08/2016 : HRMS590310 ||
      order by dtereq desc, numseq desc;
  begin

    -- get max numseq
    begin
      select max(nvl(numseq, 0)) into v_numseq
        from ttimereq
        where codempid = p_codempid_query
          and dtereq   = trunc(sysdate);
    end;
    v_numseq :=   nvl(v_numseq, 0);

    obj_row := json_object_t();
    for r_tattence in c_tattence loop
      v_rcnt                     := v_rcnt + 1;
      v_numseq                   := v_numseq + 1;
      v_dtework                  := r_tattence.dtework;
      temp_ttimereq_codempid     := r_tattence.codempid;
      temp_ttimereq_numseq       := null;
      temp_ttimereq_dtereq       := trunc(sysdate);
      temp_ttimereq_dtework      := r_tattence.dtework;
      temp_ttimereq_codshift     := r_tattence.codshift;
      temp_ttimereq_typwork      := r_tattence.typwork;
      temp_ttimereq_dtein        := r_tattence.dtein;
      temp_ttimereq_dteout       := r_tattence.dteout;
      temp_ttimereq_timin        := r_tattence.timin;
      temp_ttimereq_timout       := r_tattence.timout;
      temp_ttimereq_codreqst     := r_tattence.codchng;
      temp_ttimereq_codcomp      := r_tattence.codcomp;
      temp_ttimereq_dtestrtw     := r_tattence.dtestrtw;
      temp_ttimereq_timstrtw     := r_tattence.timstrtw;
      temp_ttimereq_dteendw      := r_tattence.dteendw;
      temp_ttimereq_timendw      := r_tattence.timendw;
      temp_ttimereq_remark       := null;
      temp_ttimereq_numlvl       := null;
      temp_ttimereq_staappr      := null;

      begin
        select numlvl into temp_ttimereq_numlvl
          from temploy1
          where codempid = p_codempid_query;
      exception when no_data_found then
        temp_ttimereq_numlvl  := null;
      end;

      begin
        select nvl(qtylate, 0), nvl(qtyearly, 0), nvl(qtyabsent, 0)
          into v_late, v_early, v_absent
          from tlateabs
          where codempid = p_codempid_query
            and dtework  = r_tattence.dtework;
      exception when no_data_found then
        v_late   := null;
        v_early  := null;
        v_absent := null;
      end;
      temp_ttimereq_qtylate    := null;
      temp_ttimereq_qtyearly   := null;
      temp_ttimereq_qtyabsent  := null;

      if nvl(v_late, 0) > 0 then
        temp_ttimereq_qtylate   := trunc(v_late / 60, 0) || ':' || lpad(mod(v_late, 60), 2, '0');
      end if;
      if nvl(v_early, 0) > 0 then
        temp_ttimereq_qtyearly  := trunc(v_early / 60, 0) || ':' || lpad(mod(v_early, 60), 2, '0');
      end if;
      if nvl(v_absent, 0) > 0 then
        temp_ttimereq_qtyabsent := trunc(v_absent / 60, 0) || ':' || lpad(mod(v_absent, 60), 2, '0');
      end if;

      temp_ttimereq_codcomp      := r_tattence.codcomp;

      for r_ttimereq in c_ttimereq loop
        v_numseq := v_numseq - 1;
        temp_ttimereq_dtein         := r_ttimereq.dtein;
        temp_ttimereq_dteout        := r_ttimereq.dteout;
        temp_ttimereq_timin         := r_ttimereq.timin;
        temp_ttimereq_timout        := r_ttimereq.timout;
        temp_ttimereq_codreqst      := r_ttimereq.codreqst;
        temp_ttimereq_remark        := r_ttimereq.remark;
        temp_ttimereq_codcomp       := r_ttimereq.codcomp;
        temp_ttimereq_numlvl        := r_ttimereq.numlvl;

        temp_ttimereq_dtereq        := r_ttimereq.dtereq;
        temp_ttimereq_numseq        := r_ttimereq.numseq;
        temp_ttimereq_codempid      := r_ttimereq.codempid;
        temp_ttimereq_staappr       := r_ttimereq.staappr;
        exit;
      end loop;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid_query);
      obj_data.put('p_codempid_query', temp_ttimereq_codempid);
      obj_data.put('dtereq', to_char(temp_ttimereq_dtereq, 'dd/mm/yyyy'));
      obj_data.put('numseq', to_char(temp_ttimereq_numseq));
      obj_data.put('dtework', to_char(temp_ttimereq_dtework, 'dd/mm/yyyy'));
      obj_data.put('typwork', temp_ttimereq_typwork);
      obj_data.put('codshift', temp_ttimereq_codshift);
      obj_data.put('dtein', to_char(temp_ttimereq_dtein, 'dd/mm/yyyy'));
      obj_data.put('timin', to_char(to_date(temp_ttimereq_timin, 'hh24mi'), 'hh24:mi'));
      obj_data.put('dteout', to_char(temp_ttimereq_dteout, 'dd/mm/yyyy'));
      obj_data.put('timout', to_char(to_date(temp_ttimereq_timout, 'hh24mi'), 'hh24:mi'));
      obj_data.put('codreqst', temp_ttimereq_codreqst);
      obj_data.put('remark', temp_ttimereq_remark);
      obj_data.put('qtylate', temp_ttimereq_qtylate);
      obj_data.put('qtyearly', temp_ttimereq_qtyearly);
      obj_data.put('qtyabsent', temp_ttimereq_qtyabsent);
      obj_data.put('staappr', temp_ttimereq_staappr);
      obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', temp_ttimereq_staappr, global_v_lang));
      obj_data.put('dtestrtw', to_char(temp_ttimereq_dtestrtw, 'dd/mm/yyyy'));
      obj_data.put('timstrtw', to_char(to_date(temp_ttimereq_timstrtw, 'hh24mi'), 'hh24:mi'));
      obj_data.put('dteendw', to_char(temp_ttimereq_dteendw, 'dd/mm/yyyy'));
      obj_data.put('timendw', to_char(to_date(temp_ttimereq_timendw, 'hh24mi'), 'hh24:mi'));
      obj_data.put('flgpayroll', r_tattence.flgpayroll);
      --<<user36 KOHU-SM2301 06/12/2023
      begin 
        select codapp
        into   v_codapp
        from   tempflow
        where  codapp   = 'HRES6AE'
        and    codempid = temp_ttimereq_codempid;
      exception when no_data_found then  
        v_msg_error := replace(get_error_msg_php('ESZ004',global_v_lang),'@#$%400');      
      end;
      obj_data.put('error_msg', v_msg_error);
      -->>user36 KOHU-SM2301 06/12/2023

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_detail_search;

  procedure get_atten (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_atten(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_atten;

  procedure gen_atten (json_str_output out clob) AS
    obj_row                   json_object_t;
    obj_data                  json_object_t;
    v_numseq                  number;
    v_rcnt                    number := 0;
    v_dtework                 date;
    v_con                     varchar2(10 char);

    o_dtework                 varchar2(4000 char);
    o_typwork                 varchar2(4000 char);
    o_codshift                varchar2(4000 char);
    o_timsten                 varchar2(4000 char);
    o_dtein                   varchar2(4000 char);
    o_timin                   varchar2(4000 char);
    o_dteout                  varchar2(4000 char);
    o_timout                  varchar2(4000 char);
    o_atmfile                 varchar2(4000 char);

    cursor c_att is
      select codempid, dtework, typwork, codshift,
             timstrtw, timendw, dtein, timin, dteout, timout
      from tattence
      where codempid = p_codempid_query
        and dtework between p_dtestrt and p_dteend
      order by dtework;

    --user36 HRMS590229 29/02/2016
    cursor c_tatmfile is
      select codrecod, timtime, dtedate
        from tatmfile
       where codempid = p_codempid_query
         and dtetime between (v_dtework - 1) and (v_dtework + 1)
    order by dtetime;

  begin
    obj_row := json_object_t();
    -- insert data tattence
    for r_att in c_att loop
      v_rcnt        := v_rcnt + 1;
      v_dtework     := r_att.dtework;
      o_dtework     := to_char(r_att.dtework, 'dd/mm/yyyy');
      o_typwork     := r_att.typwork;
      o_codshift    := r_att.codshift;
      o_timsten     := to_char(to_date(r_att.timstrtw, 'hh24:mi'), 'hh24:mi') || ' - ' ||to_char(to_date(r_att.timendw, 'hh24:mi'), 'hh24:mi');
      o_dtein       := to_char(r_att.dtein, 'dd/mm/yyyy');
      o_timin       := to_char(to_date(r_att.timin, 'hh24:mi'), 'hh24:mi');
      o_dteout      := to_char(r_att.dteout, 'dd/mm/yyyy');
      o_timout      := to_char(to_date(r_att.timout, 'hh24:mi'), 'hh24:mi');
      o_atmfile     := '';
      --<<user36 HRMS590229 29/02/2016
      v_con := null;
      for c2 in c_tatmfile loop
        if c2.codrecod is not null then
          o_atmfile := substr(o_atmfile||v_con||c2.codrecod||'-'||to_char(c2.dtedate, 'dd/')|| substr(c2.timtime, 1, 2)||':'||substr(c2.timtime, 3, 2), 1, 600);
        else
          o_atmfile := substr(o_atmfile||v_con||to_char(c2.dtedate, 'dd/')|| substr(c2.timtime, 1, 2)||':'||substr(c2.timtime, 3, 2), 1, 600);
        end if;
        v_con := ', ';
      end loop;
      -->>user36 HRMS590229 29/02/2016

      --put json
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', o_dtework);
      obj_data.put('typwork', o_typwork);
      obj_data.put('codshift', o_codshift);
      obj_data.put('timsten', o_timsten);
      obj_data.put('dtein', o_dtein);
      obj_data.put('timin', o_timin);
      obj_data.put('dteout', o_dteout);
      obj_data.put('timout', o_timout);
      obj_data.put('atmfile', o_atmfile);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_atten;

  procedure check_save is
    v_count       number := 0;
    v_codapp      varchar2(30 char); --user36 KOHU-SM2301 06/12/2023
  begin
    --<<user36 KOHU-SM2301 06/12/2023
    begin 
      select codapp
      into   v_codapp
      from   tempflow
      where  codapp   = 'HRES6AE'
      and    codempid = ttimereq_codempid;
    exception when no_data_found then  
      param_msg_error := get_error_msg_php('ESZ004',global_v_lang);
      return;
    end;
    -->>user36 KOHU-SM2301 06/12/2023

    begin
      select count(*)
        into v_count
        from tattence
       where codempid = ttimereq_codempid
         and dtework  = ttimereq_dtework;
    exception when no_data_found then
      v_count := 0;
    end;
    if v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tattence');
      return;
    end if;

    if nvl(ttimereq_staappr, 'P') in ('C', 'P') then
      if ttimereq_dtein is not null or ttimereq_timin is not null then
        if ttimereq_dtein is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang);
          return;
        end if;
        if ttimereq_timin is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang);
          return;
        end if;
      end if;

      if ttimereq_dteout is not null or ttimereq_timout is not null then
        if ttimereq_dteout is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang);
          return;
        end if;
        if ttimereq_timout is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang);
          return;
        end if;
      end if;

      if to_date(to_char(ttimereq_dtein, 'dd/mm/yyyy') || ttimereq_timin, 'dd/mm/yyyyhh24mi') > to_date(to_char(ttimereq_dteout, 'dd/mm/yyyy') || ttimereq_timout, 'dd/mm/yyyyhh24mi') then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang);
        return;
      end if;

      if to_date(to_char(ttimereq_dteout, 'dd/mm/yyyy') || ttimereq_timout, 'dd/mm/yyyyhh24mi') - to_date(to_char(ttimereq_dtein, 'dd/mm/yyyy') || ttimereq_timin, 'dd/mm/yyyyhh24mi') > 1 then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang);
        return;
      end if;

      if ttimereq_dtein < ttimereq_dtework - 2 or ttimereq_dtein > ttimereq_dtework + 2 then
        param_msg_error := get_error_msg_php('ES0020', global_v_lang);
        return;
      end if;
      if ttimereq_dteout < ttimereq_dtework - 2 or ttimereq_dteout > ttimereq_dtework + 2 then
        param_msg_error := get_error_msg_php('ES0020', global_v_lang);
        return;
      end if;

      if ttimereq_codreqst is not null then
        begin
          select codcodec  into  ttimereq_codreqst
            from tcodtime
           where codcodec = ttimereq_codreqst;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtime');
          return;
        end;
      else
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;

      if ttimereq_remark is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;

      if  ttimereq_staappr is null then -- New Record
          ttimereq_dtereq     := trunc(sysdate);
          ttimereq_staappr    := 'P';
      end if;
    end if;
    if get_payroll_active('HRES6AE', ttimereq_codempid, ttimereq_dtework, ttimereq_dtework) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057', global_v_lang);
      return;
    end if;
    if ttimereq_numseq is null then
      begin
        select nvl(max(numseq), 0) + 1
          into ttimereq_numseq
          from ttimereq
         where codempid = ttimereq_codempid
           and dtereq   = ttimereq_dtereq;
      exception when others then
        null;
      end;
    end if;
  end check_save;

  procedure save_ttimereq is
    v_dteino1   tattence.dtein%type;
    v_timino1   tattence.timin%type;
    v_dteouto1  tattence.dteout%type;
    v_timouto1  tattence.timout%type;
  begin
    begin
      select dtein, timin, dteout, timout
        into v_dteino1, v_timino1, v_dteouto1, v_timouto1
        from tattence
        where codempid = ttimereq_codempid
          and dtework = ttimereq_dtework;
    exception when no_data_found then
      v_dteino1  := null;
      v_timino1  := null;
      v_dteouto1 := null;
      v_timouto1 := null;
    end;
    begin
      insert into ttimereq (codempid, dtereq,    dtework,
                            numseq,   codshift,  dtein,
                            timin,    dteout,    timout,
                            codreqst, codcomp,   numlvl,
                            remark,   approvno,  staappr,
                            routeno,  flgsend,   codinput,
                            dteinput, coduser,
                            dteappr,  codappr,   remarkap,
                            dteino1,  timino1,   dteouto1, timouto1)
             values        (ttimereq_codempid, ttimereq_dtereq,    ttimereq_dtework,
                            ttimereq_numseq,   ttimereq_codshift,  ttimereq_dtein,
                            ttimereq_timin,    ttimereq_dteout,    ttimereq_timout,
                            ttimereq_codreqst, ttimereq_codcomp,   ttimereq_numlvl,
                            ttimereq_remark,   ttimereq_approvno,  ttimereq_staappr,
                            ttimereq_routeno,  null,               p_codempid_query,
                            sysdate,           global_v_coduser,
                            ttimereq_dteappr,  ttimereq_codappr,   ttimereq_remarkap,

                            v_dteino1,         v_timino1,          v_dteouto1,        v_timouto1);
    exception when dup_val_on_index then
      update ttimereq
         set codshift  = ttimereq_codshift,
             dtein     = ttimereq_dtein,
             timin     = ttimereq_timin,
             dteout    = ttimereq_dteout,
             timout    = ttimereq_timout,
             codreqst  = ttimereq_codreqst,
             codcomp   = ttimereq_codcomp,
             numlvl    = ttimereq_numlvl,
             remark    = ttimereq_remark,
             routeno   = ttimereq_routeno,
             flgsend   = null,
             codinput  = p_codempid_query,
             coduser   = global_v_coduser,
             staappr   = ttimereq_staappr,
             dtecancel = sysdate,
             dteappr   = ttimereq_dteappr,
             codappr   = ttimereq_codappr,
             remarkap  = ttimereq_remarkap
       where codempid = ttimereq_codempid
         and dtework  = ttimereq_dtework
         and dtereq   = ttimereq_dtereq
         and numseq   = ttimereq_numseq;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure insert_next_step is
    v_codapp              varchar2(10 char) := 'HRES6AE';
    v_count               number := 0;
    v_approvno            number := 0;
    v_codempid_next       temploy1.codempid%type;
    v_codempap           temploy1.codempid%type;
    v_codcompap           tcenter.codcomp%type;
    v_codposap            varchar2(4 char);
    v_remark              varchar2(200 char) := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    v_routeno             varchar2(15 char);
    v_table               varchar2(50 char);
    v_error               varchar2(50 char);
    b_index_codempid      temploy1.codempid%type;
  begin
    b_index_codempid      := p_codempid_query;
    if nvl(ttimereq_staappr, 'P') in  ('P', 'C') then
      ttimereq_codempid  := nvl(ttimereq_codempid, b_index_codempid);
      if ttimereq_staappr = 'C' then
        ttimereq_dteinput  := sysdate;
      end if;

      v_approvno              :=  0 ;
      v_codempap              := ttimereq_codempid ;
      ttimereq_staappr        := 'P';
      ttimereq_dtecancel      := null;
      chk_workflow.find_next_approve(v_codapp, v_routeno, ttimereq_codempid, to_char(ttimereq_dtereq, 'dd/mm/yyyy'), ttimereq_numseq, v_approvno, ttimereq_codempid);
      --<< user22 : 20/08/2016 : STA4590307 ||
      /*user36 KOHU-SM2301 06/12/2023 cancel
      if v_routeno is null then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'twkflph');
        return;
      end if;
      --
      chk_workflow.find_approval(v_codapp, ttimereq_codempid, to_char(ttimereq_dtereq, 'dd/mm/yyyy'), ttimereq_numseq, v_approvno, v_table, v_error);
      if v_error is not null then
        param_msg_error := get_error_msg_php(v_error, global_v_lang, v_table);
        return;
      END IF;
      -->> user22 : 20/08/2016 : STA4590307 ||
      --Loop Check Next step
      loop
        v_codempid_next := chk_workflow.check_next_step2(v_codapp, v_routeno, b_index_codempid, to_char(ttimereq_dtereq, 'dd/mm/yyyy'), ttimereq_numseq, null, to_char(ttimereq_dtework, 'dd/mm/yyyy'), v_approvno, v_codempap);
        --v_codempid_next := chk_workflow.check_next_approve(v_codapp, v_routeno, b_index_codempid, to_char(ttimereq_dtereq, 'dd/mm/yyyy'), ttimereq_numseq, v_approvno, v_codempap);
        --Change to Chk_NextStep user13
        -- user22 : 18/07/2016 : STA4590287 ||v_codempid_next := chk_workflow.Chk_NextStep('HRES6AE', v_routeno, v_approvno, v_codempap, v_codcompap, v_codposap);
        if  v_codempid_next is not null then
          v_approvno          := v_approvno + 1 ;
          ttimereq_codappr    := v_codempid_next ;
          ttimereq_staappr    := 'A' ;
          ttimereq_dteappr    := trunc(sysdate);
          ttimereq_remarkap   := v_remark;
          ttimereq_approvno   := v_approvno ;
          begin
            insert into taptimrq(codempid, dtereq, numseq, dtework, approvno, codappr, dteappr, staappr,
                           remark, dteupd, coduser,
                           dteapph)
                  values  (ttimereq_codempid, ttimereq_dtereq, ttimereq_numseq, ttimereq_dtework,
                           v_approvno, v_codempid_next, trunc(sysdate),
                           'A', v_remark, trunc(sysdate), global_v_coduser,
                           sysdate);
          exception when dup_val_on_index then
            update taptimrq
               set staappr   = 'A',
                   codappr   = v_codempid_next,
                   dteappr   = trunc(sysdate),
                   coduser   = global_v_coduser,
                   remark    = v_remark,
                   dteapph   = sysdate


            where codempid        = ttimereq_codempid
              and trunc(dtereq)   = trunc(ttimereq_dtereq)
              and numseq          = ttimereq_numseq
              and trunc(dtework)  = trunc(ttimereq_dtework)
              and approvno        = v_approvno;
          end;
          chk_workflow.find_next_approve(v_codapp, v_routeno, b_index_codempid, to_char(ttimereq_dtereq, 'dd/mm/yyyy'), ttimereq_numseq, v_approvno, v_codempid_next);
        else
          exit ;
        end if;
      end loop ;
      */
      ttimereq_approvno     := v_approvno ;
      ttimereq_routeno      := v_routeno ;

    end if;
  end;

  procedure initial_save (json_obj in json_object_t) AS
  begin
    --block tleaverq
    ttimereq_codempid   := p_codempid_query;
    ttimereq_codempid   := hcm_util.get_string_t(json_obj, 'codempid');
    ttimereq_dtereq     := to_date(hcm_util.get_string_t(json_obj, 'dtereq'), 'dd/mm/yyyy');
    ttimereq_numseq     := hcm_util.get_string_t(json_obj, 'numseq');
    ttimereq_dtework    := to_date(hcm_util.get_string_t(json_obj, 'dtework'), 'dd/mm/yyyy');
    ttimereq_dtein      := to_date(hcm_util.get_string_t(json_obj, 'dtein'), 'dd/mm/yyyy');
    ttimereq_dteout     := to_date(hcm_util.get_string_t(json_obj, 'dteout'), 'dd/mm/yyyy');
    ttimereq_codreqst   := hcm_util.get_string_t(json_obj, 'codreqst');
    ttimereq_remark     := substr(hcm_util.get_string_t(json_obj, 'remark'), 1, 200);
    ttimereq_timin      := replace(hcm_util.get_string_t(json_obj, 'timin'), ':', '');
    ttimereq_timout     := replace(hcm_util.get_string_t(json_obj, 'timout'), ':', '');
    ttimereq_remarkap   := substr(hcm_util.get_string_t(json_obj, 'remarkap'), 1, 500);
    ttimereq_dteinput   := to_date(hcm_util.get_string_t(json_obj, 'dteinput'), 'dd/mm/yyyy');
    ttimereq_dtecancel  := to_date(hcm_util.get_string_t(json_obj, 'dtecancel'), 'dd/mm/yyyy');
    ttimereq_staappr    := hcm_util.get_string_t(json_obj, 'staappr');
    ttimereq_codappr    := hcm_util.get_string_t(json_obj, 'codappr');
    ttimereq_dteappr    := to_date(hcm_util.get_string_t(json_obj, 'dteappr'), 'dd/mm/yyyy');
    ttimereq_approvno   := hcm_util.get_string_t(json_obj, 'approvno');
    ttimereq_routeno    := hcm_util.get_string_t(json_obj, 'routeno');
    ttimereq_codshift   := hcm_util.get_string_t(json_obj, 'codshift');

    begin
      select codcomp,numlvl into ttimereq_codcomp, ttimereq_numlvl
        from temploy1
       where codempid = ttimereq_codempid;
    exception when no_data_found then
      ttimereq_codcomp := null;
      ttimereq_numlvl  := null;
    end;
  end initial_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    if json_params.get_size = 0 then
      param_msg_error := get_error_msg_php('HR2056', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    for i in 0..json_params.get_size - 1 loop
      obj_data      := hcm_util.get_json_t(json_params, to_char(i));
      initial_save(obj_data);
      check_save;
      if param_msg_error is null then
        insert_next_step;
      end if;
      if param_msg_error is null then
        save_ttimereq;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;

  procedure cancel_request (json_str_input in clob, json_str_output out clob) AS
    v_staappr       ttimereq.staappr%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      if p_dtereq2save is not null then
        if p_staappr = 'P' then
          v_staappr := 'C';
          begin
            update ttimereq
              set staappr   = v_staappr,
                  dtecancel = sysdate,
                  coduser   = global_v_coduser
            where codempid  = p_codempid_query
              and dtereq    = p_dtereq2save
              and numseq    = p_numseq
              and dtework   = p_dtework2save;
          end;
        elsif p_staappr = 'C' then
          param_msg_error := get_error_msg_php('HR1506', global_v_lang);
        else
          param_msg_error := get_error_msg_php('HR1490', global_v_lang);
        end if;
      end if;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2421', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end cancel_request;

  function get_codcodec(json_str_input in clob) return clob is
    v_rcnt          number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_lang1       json_object_t;
    obj_lang2       json_object_t;
    obj_lang3       json_object_t;
    obj_lang4       json_object_t;
    obj_lang5       json_object_t;

    cursor c1 is
      select codcodec,
             descode,
             descodt,
             descod3,
             descod4,
             descod5
        from tcodtime
       where nvl(flgact, '1') = '1'
       order by codcodec;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    obj_lang1       := json_object_t();
    obj_lang2       := json_object_t();
    obj_lang3       := json_object_t();
    obj_lang4       := json_object_t();
    obj_lang5       := json_object_t();
    for i in c1 loop
      v_rcnt   := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcodec', i.codcodec);
      obj_data.put('descod', i.descode);
      obj_lang1.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descod', i.descodt);
      obj_lang2.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descod', i.descod3);
      obj_lang3.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descod', i.descod4);
      obj_lang4.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descod', i.descod5);
      obj_lang5.put(to_char(v_rcnt-1), obj_data);
    end loop;
    obj_row.put('coderror', '200');
    obj_row.put('lang1', obj_lang1);
    obj_row.put('lang2', obj_lang2);
    obj_row.put('lang3', obj_lang3);
    obj_row.put('lang4', obj_lang4);
    obj_row.put('lang5', obj_lang5);

    return obj_row.to_clob;
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror', '400');
    obj_data.put('response', dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace);
    return obj_data.to_clob;
  END;
end M_HRES6AE;

/
