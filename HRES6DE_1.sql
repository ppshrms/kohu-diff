--------------------------------------------------------
--  DDL for Package Body HRES6DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES6DE" AS
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

    tworkreq_typwrko     :=  hcm_util.get_string_t(json_obj, 'typwrko');
    tworkreq_typwrkn     :=  hcm_util.get_string_t(json_obj, 'typwrkn');
    tworkreq_codshifto   :=  hcm_util.get_string_t(json_obj, 'codshifto');
    tworkreq_codshiftn   :=  hcm_util.get_string_t(json_obj, 'codshiftn');
    tworkreq_typwrkro    :=  hcm_util.get_string_t(json_obj, 'typwrkro');
    tworkreq_typwrkrn    :=  hcm_util.get_string_t(json_obj, 'typwrkrn');
    tworkreq_codshifro   :=  hcm_util.get_string_t(json_obj, 'codshifro');
    tworkreq_codshifrn   :=  hcm_util.get_string_t(json_obj, 'codshifrn');
    tworkreq_remark      :=  hcm_util.get_string_t(json_obj, 'remark');
    tworkreq_codcomp     :=  hcm_util.get_string_t(json_obj, 'codcomp');
    tworkreq_codappr     :=  hcm_util.get_string_t(json_obj, 'codappr');
    tworkreq_dteappr     :=  to_date(hcm_util.get_string_t(json_obj, 'dteappr'), 'dd/mm/yyyy');
    tworkreq_dteupd      :=  to_date(hcm_util.get_string_t(json_obj, 'dteupd'), 'dd/mm/yyyy');
    tworkreq_flgsend     :=  hcm_util.get_string_t(json_obj, 'flgsend');
    tworkreq_dtecancel   :=  to_date(hcm_util.get_string_t(json_obj, 'dtecancel'), 'dd/mm/yyyy');
    tworkreq_dteinput    :=  to_date(hcm_util.get_string_t(json_obj, 'dteinput'), 'dd/mm/yyyy');
    tworkreq_dtesnd      :=  to_date(hcm_util.get_string_t(json_obj, 'dtesnd'), 'dd/mm/yyyy');
    tworkreq_dteapph     :=  to_date(hcm_util.get_string_t(json_obj, 'dteapph'), 'dd/mm/yyyy');
    tworkreq_flgagency   :=  hcm_util.get_string_t(json_obj, 'flgagency');

    p_dteworkst         :=  to_date(hcm_util.get_string_t(json_obj, 'p_dteworkst'), 'dd/mm/yyyy');
    p_dteworken         :=  to_date(hcm_util.get_string_t(json_obj, 'p_dteworken'), 'dd/mm/yyyy');

    p_table             := hcm_util.get_json_t(json_obj, 'table');
    p_flgAfterSave      := hcm_util.get_string_t(json_obj, 'flgAfterSave');
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
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

    cursor cl is
      select a.codempid, a.dtereq, a.seqno, a.dtework, a.typwrko, a.typwrkn,
             a.codshifto, a.codshiftn, a.typwrkro, a.typwrkrn, a.codshifro, a.codshifrn,
             a.remark, a.codcomp, a.codappr, a.dteappr, a.remarkap, a.approvno, a.staappr,
             a.routeno, a.dteupd, a.coduser, a.flgsend,
             a.codinput, a.dtecancel, a.dteinput, a.dtesnd, a.dteapph, a.flgagency
        from tworkreq a, temploy1 b
       where a.codempid = b.codempid(+)
         and a.codempid = nvl(p_codempid_query,a.codempid)
         and a.codcomp  like p_codcomp||'%'
--         and dtereq between p_dtestrt and p_dteend
         and a.dtework between nvl(p_dtestrt, a.dtework) and nvl(p_dteend, a.dtework)
         and (a.codempid = global_v_codempid or
             (a.codempid <> global_v_codempid
               and b.numlvl between global_v_zminlvl and global_v_zwrklvl
               and 0 <> (select count(ts.codcomp)
                           from tusrcom ts
                          where ts.coduser = global_v_coduser
                            and a.codcomp like ts.codcomp || '%'
                            and rownum    <= 1 )))
       order by a.dtereq desc, a.seqno desc;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in cl loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', nvl(get_temploy_name(trim(r1.codempid), global_v_lang), ''));
      obj_data.put('dtereq', to_char(r1.dtereq, 'dd/mm/yyyy'));
      obj_data.put('numseq', to_char(r1.seqno));
      obj_data.put('dtework', to_char(r1.dtework, 'dd/mm/yyyy'));
      obj_data.put('staappr', r1.staappr);
      obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', r1.staappr, global_v_lang));
      obj_data.put('remarkap', replace(r1.remarkap, chr(13) || chr(10), ' '));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', r1.codappr || ' ' || get_temploy_name(r1.codappr, global_v_lang));
      obj_data.put('codempap', chk_workflow.get_next_approve(p_codapp, r1.codempid, to_char(r1.dtereq, 'dd/mm/yyyy'), r1.seqno, r1.approvno, global_v_lang));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure check_detail AS
  begin
    if p_dtework is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
--    elsif p_dtework < p_dtereq then
--      param_msg_error := get_error_msg_php('ES0021', global_v_lang);
--      return;
    end if;
    if get_payroll_active('HRES6DE', p_codempid_query, p_dtework, p_dtework) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057', global_v_lang);
      return;
    end if;
  end;

  procedure check_detail2 AS
  begin
    if p_dteworkst < (trunc(sysdate) - 15) then
      param_msg_error := get_error_msg_php('ES0080', global_v_lang);
      return;
    end if;
    if p_dteworken - p_dteworkst > 6 then
      param_msg_error := get_error_msg_php('ES0081', global_v_lang);
      return;
    end if;
  end;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_data            json_object_t;
    obj_main            json_object_t;
    obj_detail          json_object_t;
    obj_calendar        json_object_t;
    obj_tmp             json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    calendar_clob       clob;
    v_dtework           tworkreq.dtework%type;
    v_typwrko           tworkreq.typwrko%type;
    v_typwrkn           tworkreq.typwrkn%type;
    v_codshifto         tworkreq.codshifto%type;
    v_codshiftn         tworkreq.codshiftn%type;
    v_typwrkro          tworkreq.typwrkro%type;
    v_typwrkrn          tworkreq.typwrkrn%type;
    v_codshifro         tworkreq.codshifro%type;
    v_codshifrn         tworkreq.codshifrn%type;
    v_remark            tworkreq.remark%type;
    v_codcomp           tworkreq.codcomp%type;
    v_codappr           tworkreq.codappr%type;
    v_dteappr           tworkreq.dteappr%type;
    v_remarkap          tworkreq.remarkap%type;
    v_approvno          tworkreq.approvno%type;
    v_staappr           tworkreq.staappr%type;
    v_routeno           tworkreq.routeno%type;
    v_dteupd            tworkreq.dteupd%type;
    v_coduser           tworkreq.coduser%type;
    v_flgsend           tworkreq.flgsend%type;
    v_codinput          tworkreq.codinput%type;
    v_dtecancel         tworkreq.dtecancel%type;
    v_dteinput          tworkreq.dteinput%type;
    v_dtesnd            tworkreq.dtesnd%type;
    v_dteapph           tworkreq.dteapph%type;
    v_flgagency         tworkreq.flgagency%type;

    v_timstrtw          tshiftcd.timstrtw%type;
    v_timendw           tshiftcd.timendw%type;

  begin
    obj_main                := json_object_t();
    obj_detail              := json_object_t();
    obj_calendar            := json_object_t();
    obj_row                 := json_object_t();
    v_rcnt                  := 0;
    begin
        delete ttemprpt
         where codapp = 'HRES6DE'
           and codempid = global_v_codempid;
    exception when others then
        null;
    end;
    if p_numseq is null then
        begin
        SELECT NVL(MAX(seqno),0) + 1
          INTO p_numseq
          FROM tworkreq
         WHERE codempid = p_codempid_query
           AND dtereq = p_dtereq;
        exception when no_data_found then
            p_numseq := 1;
        end;
    end if;
    begin
      select dtework,   typwrko,
             typwrkn,   codshifto,  codshiftn,  typwrkro,   typwrkrn,
             codshifro, codshifrn,  remark,     codcomp,    codappr,
             dteappr,   remarkap,   approvno,   staappr,    routeno,
             dteupd,     coduser,
             flgsend,   codinput,   dtecancel,  dteinput,   dtesnd,
             dteapph,   flgagency
        into v_dtework,   v_typwrko,
             v_typwrkn,   v_codshifto, v_codshiftn, v_typwrkro, v_typwrkrn,
             v_codshifro, v_codshifrn, v_remark,    v_codcomp, v_codappr,
             v_dteappr,   v_remarkap,  v_approvno,  v_staappr, v_routeno,
             v_dteupd,  v_coduser,
             v_flgsend,   v_codinput,  v_dtecancel, v_dteinput, v_dtesnd,
             v_dteapph,   v_flgagency
        from tworkreq
       where codempid = p_codempid_query
         and dtereq   = p_dtereq
         and seqno    = p_numseq
         and dtework  = p_dtework;
    exception when no_data_found then
      v_dtework    := '';
      v_typwrko    := '';
      v_typwrkn    := '';
      v_codshifto  := '';
      v_codshiftn  := '';
      v_typwrkro   := '';
      v_typwrkrn   := '';
      v_codshifro  := '';
      v_codshifrn  := '';
      v_remark     := '';
      v_codcomp    := '';
      v_codappr    := '';
      v_dteappr    := '';
      v_remarkap   := '';
      v_approvno   := '';
      v_staappr    := '';
      v_routeno    := '';
      v_dteupd     := '';
      v_coduser    := '';
      v_flgsend    := '';
      v_codinput   := '';
      v_dtecancel  := '';
      v_dteinput   := '';
      v_dtesnd     := '';
      v_dteapph    := '';
      v_flgagency  := '';
    end;

    if v_dtework is null then
      --- tattence
      begin
        select typwork, codshift
          into v_typwrko, v_codshifto
          from tattence
         where codempid = p_codempid_query
           and dtework  = p_dtework;
      exception when no_data_found then
        v_typwrkro          := null;
        v_codshifro         := null;
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tattence');
        return;
      end;
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid_query);
    obj_data.put('dtereq', to_char(p_dtereq, 'dd/mm/yyyy'));
    obj_data.put('numseq', to_char(p_numseq));
    obj_data.put('dtework', to_char(p_dtework, 'dd/mm/yyyy'));
    obj_data.put('staappr', v_staappr);
    obj_data.put('typwrko', v_typwrko);
    obj_data.put('desc_typwrko', nvl(get_tlistval_name('TYPWRKFUL',v_typwrko,global_v_lang),''));
    obj_data.put('typwrkn', v_typwrkn);
    obj_data.put('codshifto', v_codshifto);
    obj_data.put('desc_codshifto',v_codshifto|| ' - ' ||nvl(get_tshiftcd_name(v_codshifto,global_v_lang),''));
    obj_data.put('codshiftn', v_codshiftn);
    obj_data.put('desc_codshiftn',v_codshiftn|| ' - ' ||nvl(get_tshiftcd_name(v_codshiftn,global_v_lang),''));
    obj_data.put('typwrkro', v_typwrkro);
    obj_data.put('typwrkrn', v_typwrkrn);
    obj_data.put('codshifro', v_codshifro);
    obj_data.put('codshifrn', v_codshifrn);
    obj_data.put('remark', v_remark);
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('codappr', v_codappr);
    obj_data.put('dteappr', to_char(v_dteappr, 'dd/mm/yyyy'));
    obj_data.put('remarkap', v_remarkap);
    obj_data.put('approvno', v_approvno);
    obj_data.put('routeno', v_routeno);
    obj_data.put('dteupd', to_char(v_dteupd, 'dd/mm/yyyy'));
    obj_data.put('coduser', v_coduser);
    obj_data.put('flgsend', v_flgsend);
    obj_data.put('codinput', v_codinput);
    obj_data.put('dtecancel', to_char(v_dtecancel, 'dd/mm/yyyy'));
    obj_data.put('dteinput', to_char(v_dteinput, 'dd/mm/yyyy'));
    obj_data.put('dtesnd', to_char(v_dtesnd, 'dd/mm/yyyy'));
    obj_data.put('dteapph', to_char(v_dteapph, 'dd/mm/yyyy'));
    obj_data.put('flgagency', v_flgagency);

    begin
        select timstrtw, timendw
          into v_timstrtw, v_timendw
          from tshiftcd
          where codshift = v_codshifto;
    exception when others then
        v_timstrtw  := null;
        v_timendw   := null;
    end;
    obj_data.put('timeo',to_char(to_date(v_timstrtw, 'hh24mi'), 'hh24:mi') || '-' || to_char(to_date(v_timendw, 'hh24mi'), 'hh24:mi'));

    begin
        select timstrtw, timendw
          into v_timstrtw, v_timendw
          from tshiftcd
          where codshift = v_codshiftn;
    exception when others then
        v_timstrtw  := null;
        v_timendw   := null;
    end;

    obj_data.put('timen',to_char(to_date(v_timstrtw, 'hh24mi'), 'hh24:mi') || '-' || to_char(to_date(v_timendw, 'hh24mi'), 'hh24:mi'));

    obj_row.put(to_char(0), obj_data);

    if p_dtework < trunc(sysdate) - 15 then
      obj_tmp := json_object_t(get_response_message(null, get_error_msg_php('HR1501', global_v_lang), global_v_lang));
      obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
    end if;

    obj_detail := obj_data;
    obj_detail.put('dteworkst', to_char(p_dtework,'dd/mm/yyyy'));
    obj_detail.put('dteworken', to_char(p_dtework,'dd/mm/yyyy'));

    obj_main.put('coderror', '200');
    obj_main.put('table', obj_row);
    obj_main.put('detail', obj_detail);

    gen_calendar(calendar_clob);
    obj_calendar := json_object_t(calendar_clob);
    obj_main.put('calendar', obj_calendar);
    json_str_output := obj_main.to_clob;
  end gen_detail;

  function gen_numseq(v_dtereq date) return number is
    v_numseq        tworkreq.seqno%type;
  begin
    begin
      select (nvl(max(seqno), 0) + 1) seqno
        into v_numseq
        from tworkreq
       where codempid = p_codempid_query
         and dtereq   = v_dtereq;
    exception when others then
      null;
    end;
    return v_numseq;
  end gen_numseq;

  procedure get_numseq (json_str_input in clob, json_str_output out clob) AS
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtereq', to_char(p_dtereq, 'dd/mm/yyyy'));
      obj_data.put('dtework', to_char(sysdate, 'dd/mm/yyyy'));
      obj_data.put('numseq', gen_numseq(p_dtereq));

      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_numseq;

  procedure check_save is
    v_numseq      tworkreq.seqno%type;
  begin
    if tworkreq_typwrkn is null and tworkreq_codshiftn is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    elsif tworkreq_typwrko = nvl(tworkreq_typwrkn,tworkreq_typwrko) and tworkreq_codshifto = nvl(tworkreq_codshiftn,tworkreq_codshifto) then
      param_msg_error := get_error_msg_php('HR8518', global_v_lang);
      return;
    end if;
    if p_numseq is null or p_numseq = 0 then
      p_numseq := gen_numseq(p_dtereq2save);
    end if;
    tworkreq_codcomp  := hcm_util.get_temploy_field(p_codempid_query, 'codcomp');
    tworkreq_codempid := p_codempid_query;
    tworkreq_dtereq   := p_dtereq2save;
    tworkreq_seqno    := p_numseq;
    tworkreq_dtework  := p_dtework2save;

    tworkreq_coduser  := global_v_coduser;
    tworkreq_codinput := global_v_codempid;
    tworkreq_dteinput := sysdate;
    
    if get_payroll_active('HRES6DE', p_codempid_query, tworkreq_dtework, tworkreq_dtework) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057', global_v_lang);
      return;
    end if;
  end check_save;

  procedure save_tworkreq AS
  begin
    begin
      insert into tworkreq
      (codempid,    dtereq,     seqno,      dtework,    typwrko,
       typwrkn,     codshifto,  codshiftn,  typwrkro,   typwrkrn,
       codshifro,   codshifrn,  remark,     codcomp,    codappr,
       dteappr,     remarkap,   approvno,   staappr,    routeno,
       dteupd,     coduser,
       flgsend,     codinput,   dtecancel,  dteinput,   dtesnd,
       dteapph,     flgagency)
      values
      (tworkreq_codempid,     tworkreq_dtereq,      tworkreq_seqno,       tworkreq_dtework,     tworkreq_typwrko,
       tworkreq_typwrkn,      tworkreq_codshifto,   tworkreq_codshiftn,   tworkreq_typwrkro,    tworkreq_typwrkrn,
       tworkreq_codshifro,    tworkreq_codshifrn,   tworkreq_remark,      tworkreq_codcomp,     tworkreq_codappr,
       tworkreq_dteappr,      tworkreq_remarkap,    tworkreq_approvno,    tworkreq_staappr,     tworkreq_routeno,
       tworkreq_dteupd,      tworkreq_coduser,
       tworkreq_flgsend,      tworkreq_codinput,    tworkreq_dtecancel,   tworkreq_dteinput,    tworkreq_dtesnd,
       tworkreq_dteapph,      tworkreq_flgagency);
    exception when dup_val_on_index then
      update tworkreq
         set dtework     =  tworkreq_dtework,
             typwrko     =  tworkreq_typwrko,
             typwrkn     =  tworkreq_typwrkn,
             codshifto   =  tworkreq_codshifto,
             codshiftn   =  tworkreq_codshiftn,
             typwrkro    =  tworkreq_typwrkro,
             typwrkrn    =  tworkreq_typwrkrn,
             codshifro   =  tworkreq_codshifro,
             codshifrn   =  tworkreq_codshifrn,
             remark      =  tworkreq_remark,
             codcomp     =  tworkreq_codcomp,
             codappr     =  tworkreq_codappr,
             dteappr     =  tworkreq_dteappr,
             remarkap    =  tworkreq_remarkap,
             approvno    =  tworkreq_approvno,
             staappr     =  tworkreq_staappr,
             routeno     =  tworkreq_routeno,
             dteupd      =  tworkreq_dteupd,
             coduser     =  tworkreq_coduser,
             flgsend     =  tworkreq_flgsend,
             codinput    =  tworkreq_codinput,
             dtecancel   =  tworkreq_dtecancel,
             dtesnd      =  tworkreq_dtesnd,
             dteapph     =  tworkreq_dteapph,
             flgagency   =  tworkreq_flgagency
       where seqno       = tworkreq_seqno
         and dtereq      = tworkreq_dtereq
         and codempid    = tworkreq_codempid;
    end;
--    begin
--        select nvl(max(numseq),0) + 1
--          into v_tmp_numseq
--          from ttemprpt
--         where codapp = 'HRES6DE'
--           and codempid = global_v_codempid;
--    exception when others then
--        null;
--    end;
--    v_tmp_numseq := v_tmp_numseq + 1;
    begin
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4)
        values (global_v_codempid,'HRES6DE',tworkreq_seqno,tworkreq_codempid,to_char(tworkreq_dtereq,'dd/mm/yyyy'),tworkreq_seqno, to_char(tworkreq_dtework,'dd/mm/yyyy'));
    exception when others then
        null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure insert_next_step IS
    parameter_v_approvno      number := 0;
    v_codempid_next           temploy1.codempid%type;
    v_codempap                temploy1.codempid%type;
    v_codcompap               temploy1.codcomp%type;
    v_codposap                temploy1.codpos%type;
    v_approv                  varchar2(20 char);
    v_desc                    varchar2(200 char) := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    v_routeno                 varchar2(15 char)  := null;
    v_table                   varchar2(50 char);
    v_error                   varchar2(50 char);

  begin
    parameter_v_approvno  := 0;
    v_codempap            := p_codempid_query;
    tworkreq_staappr      := 'P';
    chk_workflow.find_next_approve(p_codapp, v_routeno, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_codempap);

    --<< user22 : 20/08/2016 : HRMS590307 ||
    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(p_codapp, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_table, v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error, global_v_lang, v_table);
      return;
    end if;
    -->> user22 : 20/08/2016 : HRMS590307 ||

    --loop check next step
    loop
      --v_codempid_next := chk_workflow.check_next_approve(p_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_codempap);
      --Change to Chk_NextStep user13
      v_codempid_next := chk_workflow.Chk_NextStep(p_codapp, v_routeno, parameter_v_approvno, v_codempap, v_codcompap, v_codposap);
      if v_codempid_next is not null then
        parameter_v_approvno  := parameter_v_approvno + 1;
        tworkreq_codappr      := v_codempid_next;
        tworkreq_staappr      := 'A';
        tworkreq_dteappr      := trunc(sysdate);
        tworkreq_remarkap     := v_desc;
        tworkreq_approvno     := parameter_v_approvno;
        v_approv              := v_codempid_next;
        begin
          insert into tapwrkrq
                                (
                                  codempid, dtereq, seqno, dtework,
                                  approvno, codappr, dteappr,
                                  staappr, remarkap, coduser,
                                  dterec, dteapph
                                  )
                  values
                                (
                                  p_codempid_query, tworkreq_dtereq, tworkreq_seqno, tworkreq_dtework,
                                  parameter_v_approvno, v_codempid_next, trunc(sysdate),
                                  'A', v_desc, global_v_coduser,
                                  sysdate, sysdate
                                  );
        exception when dup_val_on_index then
          update tapwrkrq
              set codappr   = v_codempid_next,
                  dteappr   = trunc(sysdate),
                  staappr   = 'A',
                  remarkap  = v_desc ,
                  coduser   = global_v_coduser,
                  dterec    = sysdate,
                  dteapph   = sysdate

            where codempid  = p_codempid_query
              and dtereq    = tworkreq_dtereq
              and seqno     = tworkreq_seqno
              and approvno  = parameter_v_approvno;
        end;
        chk_workflow.find_next_approve(p_codapp , v_routeno, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_codempid_next);
      else
        exit;
      end if;
    end loop;

    tworkreq_approvno     := parameter_v_approvno;
    tworkreq_routeno      := v_routeno;
  end;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data        json_object_t;
    obj_row         json_object_t;
  begin
    initial_value(json_str_input);
    v_tmp_numseq    := 0;
--    begin
--        delete ttemprpt
--         where codapp = 'HRES6DE'
--           and codempid = global_v_codempid;
--    exception when others then
--        null;
--    end;
    for i in 0..p_table.get_size - 1 loop
        obj_row := hcm_util.get_json_t(p_table, to_char(i));
        p_numseq             := hcm_util.get_string_t(obj_row, 'numseq');
        p_dtereq2save        := to_date(hcm_util.get_string_t(obj_row, 'dtereq'), 'dd/mm/yyyy');
        p_dtework2save       := to_date(hcm_util.get_string_t(obj_row, 'dtework'), 'dd/mm/yyyy');
        tworkreq_typwrko     :=  hcm_util.get_string_t(obj_row, 'typwrko');
        tworkreq_typwrkn     :=  nvl(hcm_util.get_string_t(obj_row, 'typwrkn'),tworkreq_typwrko);
        tworkreq_codshifto   :=  hcm_util.get_string_t(obj_row, 'codshifto');
        tworkreq_codshiftn   :=  nvl(hcm_util.get_string_t(obj_row, 'codshiftn'),tworkreq_codshifto);
        tworkreq_typwrkro    :=  hcm_util.get_string_t(obj_row, 'typwrkro');
        tworkreq_typwrkrn    :=  hcm_util.get_string_t(obj_row, 'typwrkrn');
        tworkreq_codshifro   :=  hcm_util.get_string_t(obj_row, 'codshifro');
        tworkreq_codshifrn   :=  hcm_util.get_string_t(obj_row, 'codshifrn');
        tworkreq_remark      :=  hcm_util.get_string_t(obj_row, 'remark');
        tworkreq_codcomp     :=  hcm_util.get_string_t(obj_row, 'codcomp');
        tworkreq_codappr     :=  hcm_util.get_string_t(obj_row, 'codappr');
        tworkreq_dteappr     :=  to_date(hcm_util.get_string_t(obj_row, 'dteappr'), 'dd/mm/yyyy');
        tworkreq_dteupd      :=  to_date(hcm_util.get_string_t(obj_row, 'dteupd'), 'dd/mm/yyyy');
        tworkreq_flgsend     :=  hcm_util.get_string_t(obj_row, 'flgsend');
        tworkreq_dtecancel   :=  to_date(hcm_util.get_string_t(obj_row, 'dtecancel'), 'dd/mm/yyyy');
        tworkreq_dteinput    :=  to_date(hcm_util.get_string_t(obj_row, 'dteinput'), 'dd/mm/yyyy');
        tworkreq_dtesnd      :=  to_date(hcm_util.get_string_t(obj_row, 'dtesnd'), 'dd/mm/yyyy');
        tworkreq_dteapph     :=  to_date(hcm_util.get_string_t(obj_row, 'dteapph'), 'dd/mm/yyyy');
        tworkreq_flgagency   :=  hcm_util.get_string_t(obj_row, 'flgagency');
        check_save;
        if param_msg_error is null then
            insert_next_step;
        else
            exit;
        end if;
        if param_msg_error is null then
            save_tworkreq;
        else
            exit;
        end if;
    end loop ;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    obj_data        := json_object_t(get_response_message(null, param_msg_error, global_v_lang));
    obj_data.put('numseq', to_char(p_numseq));
    json_str_output := obj_data.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;

  procedure cancel_request (json_str_input in clob, json_str_output out clob) AS
    v_staappr       tworkreq.staappr%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      if p_dtereq2save is not null then
        if p_staappr = 'P' then
          v_staappr := 'C';
          begin
            update tworkreq
              set staappr   = v_staappr,
                  dtecancel = sysdate,
                  coduser   = global_v_coduser
            where codempid  = p_codempid_query
              and dtereq    = p_dtereq2save
              and seqno     = p_numseq;
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

  function get_codshift(json_str_input in clob) return clob is
    v_rcnt          number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_lang1       json_object_t;
    obj_lang2       json_object_t;
    obj_lang3       json_object_t;
    obj_lang4       json_object_t;
    obj_lang5       json_object_t;
    obj_descr       json_object_t;
    obj_descd       json_object_t;

    cursor c1 is
      select codshift,
             codshift ||' - '||desshifte desshifte,
             codshift ||' - '||desshiftt desshiftt,
             desshift3,
             desshift4,
             desshift5,
             timstrtw,
             timendw,
             qtydaywk
        from tshiftcd
       order by codshift;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    obj_lang1       := json_object_t();
    obj_lang2       := json_object_t();
    obj_lang3       := json_object_t();
    obj_lang4       := json_object_t();
    obj_lang5       := json_object_t();
    obj_descr       := json_object_t();
    for i in c1 loop
      v_rcnt    := v_rcnt + 1;
      obj_data  := json_object_t();
      obj_descd := json_object_t();
      obj_descd.put('coderror', '200');
      obj_descd.put('codshift', i.codshift);
      obj_descd.put('timstrtw', i.timstrtw);
      obj_descd.put('timendw', i.timendw);
      obj_descd.put('qtydaywk', to_char(i.qtydaywk));
      obj_descd.put('time', to_char(to_date(i.timstrtw, 'hh24mi'), 'hh24:mi') || ' - ' || to_char(to_date(i.timendw, 'hh24mi'), 'hh24:mi'));
      obj_descr.put(to_char(v_rcnt - 1), obj_descd);

      obj_data.put('coderror', '200');
      obj_data.put('codshift', i.codshift);
      obj_data.put('desshift', i.desshifte);
      obj_lang1.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desshift', i.desshiftt);
      obj_lang2.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desshift', i.desshift3);
      obj_lang3.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desshift', i.desshift4);
      obj_lang4.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desshift', i.desshift5);
      obj_lang5.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    obj_row.put('coderror', '200');
    obj_row.put('lang1', obj_lang1);
    obj_row.put('lang2', obj_lang2);
    obj_row.put('lang3', obj_lang3);
    obj_row.put('lang4', obj_lang4);
    obj_row.put('lang5', obj_lang5);
    obj_row.put('desc', obj_descr);

    return obj_row.to_clob;
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror', '400');
    obj_data.put('response', dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace);
    return obj_data.to_clob;
  END;

  procedure get_calendar(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;

    if param_msg_error is null then
      gen_calendar(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_calendar;

  procedure gen_calendar (json_str_output out clob) as
    obj_rows       json_object_t;
    obj_data       json_object_t;
    v_rcnt         number := 0;

    v_codcomp      tcenter.codcomp%type;
    v_codcalen     temploy1.codcalen%type;
    v_desholdy     tgholidy.desholdye%type;

    v_current_date date;
    v_dteyear      tgholidy.dteyear%type;

    v_codleave     tleavetr.codleave%type;
    v_typwork      tattence.typwork%type;
    v_codshift     tattence.codshift%type;
    v_qtylate      number;
    v_qtyearly     number;
    v_qtyabsent    number;

    v_codleave_all varchar2(4000 char);
    v_qtymin_all   number;
    v_comma        varchar2(4 char);

    first_date     date;
    end_date       date;

    v_traditional_hol     varchar2(1) := 'T';
    v_shutdown_hol        varchar2(1) := 'S';

    cursor c_tleavetr is
      select codleave, nvl(sum(qtymin), 0) qtymin
        from tleavetr
       where codempid = p_codempid_query
         and dtework  = v_current_date
    group by codleave
    order by codleave;
  begin
    first_date   := to_date('01/' || to_char(p_dtework, 'mm/yyyy'), 'dd/mm/yyyy');
    end_date     := last_day(first_date);
    v_dteyear    := to_char(p_dtework, 'yyyy');

    begin
      select get_tgholidy_codcomp(codcomp, codcalen, to_number(v_dteyear)), codcalen
        into v_codcomp, v_codcalen
        from temploy1
       where codempid = p_codempid_query;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end;

    obj_rows        := json_object_t();
    for i in 0 .. end_date - first_date loop
      v_current_date  := to_date(first_date + i);

      v_rcnt          := v_rcnt + 1;
      obj_data        := json_object_t();
      v_typwork       := '';
      v_codshift      := '';
      v_desholdy      := '';
      v_codleave_all  := '';
      v_qtymin_all    := 0;
      v_comma         := '';
      begin
        select typwork, codshift
          into v_typwork, v_codshift
          from tattence
         where codempid = p_codempid_query
           and dtework  = v_current_date;
        for r_tleavetr in c_tleavetr loop
          v_codleave_all := v_codleave_all || v_comma || r_tleavetr.codleave;
          v_qtymin_all   := v_qtymin_all + r_tleavetr.qtymin;
          v_comma        := ', ';
        end loop;
        if v_typwork = 'T' or v_typwork = 'S' then
          begin
            select decode(global_v_lang, '101', desholdye,
                                        '102', desholdyt,
                                        '103', desholdy3,
                                        '104', desholdy4,
                                        '105', desholdy5, '')
              into v_desholdy
              from tgholidy
             where codcomp  = v_codcomp
               and codcalen = v_codcalen
               and dteyear  = to_number(v_dteyear)
               and dtedate  = v_current_date
               and typwork  = v_typwork;
          exception when no_data_found then
            v_desholdy := get_tlistval_name('TYPWORK', v_typwork, global_v_lang);
          end;
        elsif v_typwork = 'W' then
          begin
            select nvl(sum(qtylate)  , 0),
                   nvl(sum(qtyearly) , 0),
                   nvl(sum(qtyabsent), 0)
              into v_qtylate,
                   v_qtyearly,
                   v_qtyabsent
              from tlateabs
             where codempid = p_codempid_query
               and dtework  = v_current_date;
          exception when no_data_found then
            v_qtylate   := 0;
            v_qtyearly  := 0;
            v_qtyabsent := 0;
          end;
          if v_qtylate <> 0 then
            v_codleave_all := v_codleave_all || v_comma || 'L';
            v_qtymin_all   := v_qtymin_all + v_qtylate;
            v_comma        := ', ';
          end if;
          if v_qtyearly <> 0 then
            v_codleave_all := v_codleave_all || v_comma || 'E';
            v_qtymin_all   := v_qtymin_all + v_qtyearly;
            v_comma        := ', ';
          end if;
          if v_qtyabsent <> 0 then
            v_codleave_all := v_codleave_all || v_comma || 'A';
            v_qtymin_all   := v_qtymin_all + v_qtyabsent;
          end if;
        end if;
      exception when no_data_found then
        null;
      end;
      if v_codleave_all is not null then
        obj_data.put('codleave' , v_codleave_all || ' (' || hcm_util.convert_minute_to_hour(v_qtymin_all) || ')');
      end if;
      obj_data.put('codshift', v_codshift);
      obj_data.put('typwork', v_typwork);
      obj_data.put('desholdy', v_desholdy);
      obj_data.put('dtedate', to_char(v_current_date, 'dd/mm/yyyy'));
      obj_data.put('coderror', '200');

      obj_rows.put(to_char(i), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure gen_calendar_period (json_str_output out clob) as
    obj_rows       json_object_t;
    obj_data       json_object_t;
    v_rcnt         number := 0;

    v_codcomp      tcenter.codcomp%type;
    v_codcalen     temploy1.codcalen%type;
    v_desholdy     tgholidy.desholdye%type;

    v_current_date date;
    v_dteyear      tgholidy.dteyear%type;

    v_codleave     tleavetr.codleave%type;
    v_typwork      tattence.typwork%type;
    v_codshift     tattence.codshift%type;
    v_qtylate      number;
    v_qtyearly     number;
    v_qtyabsent    number;

    v_codleave_all varchar2(4000 char);
    v_qtymin_all   number;
    v_comma        varchar2(4 char);

    first_date     date;
    end_date       date;

    v_traditional_hol     varchar2(1) := 'T';
    v_shutdown_hol        varchar2(1) := 'S';

    cursor c_tleavetr is
      select codleave, nvl(sum(qtymin), 0) qtymin
        from tleavetr
       where codempid = p_codempid_query
         and dtework  = v_current_date
    group by codleave
    order by codleave;
  begin
    first_date   := to_date('01/' || to_char(p_dteworkst, 'mm/yyyy'), 'dd/mm/yyyy');
    end_date     := last_day(p_dteworken);
    v_dteyear    := to_char(p_dteworkst, 'yyyy');

    begin
      select get_tgholidy_codcomp(codcomp, codcalen, to_number(v_dteyear)), codcalen
        into v_codcomp, v_codcalen
        from temploy1
       where codempid = p_codempid_query;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end;

    obj_rows        := json_object_t();
    for i in 0 .. end_date - first_date loop
      v_current_date  := to_date(first_date + i);

      v_rcnt          := v_rcnt + 1;
      obj_data        := json_object_t();
      v_typwork       := '';
      v_codshift      := '';
      v_desholdy      := '';
      v_codleave_all  := '';
      v_qtymin_all    := 0;
      v_comma         := '';
      begin
        select typwork, codshift
          into v_typwork, v_codshift
          from tattence
         where codempid = p_codempid_query
           and dtework  = v_current_date;
        for r_tleavetr in c_tleavetr loop
          v_codleave_all := v_codleave_all || v_comma || r_tleavetr.codleave;
          v_qtymin_all   := v_qtymin_all + r_tleavetr.qtymin;
          v_comma        := ', ';
        end loop;
        if v_typwork = 'T' or v_typwork = 'S' then
          begin
            select decode(global_v_lang, '101', desholdye,
                                        '102', desholdyt,
                                        '103', desholdy3,
                                        '104', desholdy4,
                                        '105', desholdy5, '')
              into v_desholdy
              from tgholidy
             where codcomp  = v_codcomp
               and codcalen = v_codcalen
               and dteyear  = to_number(v_dteyear)
               and dtedate  = v_current_date
               and typwork  = v_typwork;
          exception when no_data_found then
            v_desholdy := get_tlistval_name('TYPWORK', v_typwork, global_v_lang);
          end;
        elsif v_typwork = 'W' then
          begin
            select nvl(sum(qtylate)  , 0),
                   nvl(sum(qtyearly) , 0),
                   nvl(sum(qtyabsent), 0)
              into v_qtylate,
                   v_qtyearly,
                   v_qtyabsent
              from tlateabs
             where codempid = p_codempid_query
               and dtework  = v_current_date;
          exception when no_data_found then
            v_qtylate   := 0;
            v_qtyearly  := 0;
            v_qtyabsent := 0;
          end;
          if v_qtylate <> 0 then
            v_codleave_all := v_codleave_all || v_comma || 'L';
            v_qtymin_all   := v_qtymin_all + v_qtylate;
            v_comma        := ', ';
          end if;
          if v_qtyearly <> 0 then
            v_codleave_all := v_codleave_all || v_comma || 'E';
            v_qtymin_all   := v_qtymin_all + v_qtyearly;
            v_comma        := ', ';
          end if;
          if v_qtyabsent <> 0 then
            v_codleave_all := v_codleave_all || v_comma || 'A';
            v_qtymin_all   := v_qtymin_all + v_qtyabsent;
          end if;
        end if;
      exception when no_data_found then
        null;
      end;
      if v_codleave_all is not null then
        obj_data.put('codleave' , v_codleave_all || ' (' || hcm_util.convert_minute_to_hour(v_qtymin_all) || ')');
      end if;
      obj_data.put('codshift', v_codshift);
      obj_data.put('typwork', v_typwork);
      obj_data.put('desholdy', v_desholdy);
      obj_data.put('dtedate', to_char(v_current_date, 'dd/mm/yyyy'));
      obj_data.put('coderror', '200');

      obj_rows.put(to_char(i), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure get_create (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
--    check_detail;
    if param_msg_error is null then
      check_detail2;
    end if;

    if param_msg_error is null then
      gen_create(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_create;

  procedure gen_create (json_str_output out clob) AS
    obj_main            json_object_t;
    obj_calendar        json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    obj_data            json_object_t;
    obj_tmp             json_object_t;
    v_dtework           tworkreq.dtework%type;
    v_typwrko           tworkreq.typwrko%type;
    v_typwrkn           tworkreq.typwrkn%type;
    v_codshifto         tworkreq.codshifto%type;
    v_codshiftn         tworkreq.codshiftn%type;
    v_typwrkro          tworkreq.typwrkro%type;
    v_typwrkrn          tworkreq.typwrkrn%type;
    v_codshifro         tworkreq.codshifro%type;
    v_codshifrn         tworkreq.codshifrn%type;
    v_remark            tworkreq.remark%type;
    v_codcomp           tworkreq.codcomp%type;
    v_codappr           tworkreq.codappr%type;
    v_dteappr           tworkreq.dteappr%type;
    v_remarkap          tworkreq.remarkap%type;
    v_approvno          tworkreq.approvno%type;
    v_staappr           tworkreq.staappr%type;
    v_routeno           tworkreq.routeno%type;
    v_dteupd            tworkreq.dteupd%type;
    v_coduser           tworkreq.coduser%type;
    v_flgsend           tworkreq.flgsend%type;
    v_codinput          tworkreq.codinput%type;
    v_dtecancel         tworkreq.dtecancel%type;
    v_dteinput          tworkreq.dteinput%type;
    v_dtesnd            tworkreq.dtesnd%type;
    v_dteapph           tworkreq.dteapph%type;
    v_flgagency         tworkreq.flgagency%type;
    v_timstrtw          tshiftcd.timstrtw%type;
    v_timendw           tshiftcd.timendw%type;
    calendar_clob       clob;
    v_tworkreq          tworkreq%rowtype;

    cursor c1 is
        select *
          from tattence
         where codempid = p_codempid_query
           and dtework between p_dteworkst and p_dteworken
      order by dtework;

  begin

    obj_main                := json_object_t();
    obj_detail              := json_object_t();
    obj_calendar            := json_object_t();
    obj_row                 := json_object_t();
    v_rcnt                  := 0;
--
    begin
        SELECT NVL(MAX(seqno),0)
          INTO p_numseq
          FROM tworkreq
         WHERE codempid = p_codempid_query
           AND dtereq = trunc(sysdate);
    exception when no_data_found then
        p_numseq := 0;
    end;

    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', p_codempid_query);
    obj_detail.put('dtereq', to_char(sysdate, 'dd/mm/yyyy'));
    obj_detail.put('dteworkst', to_char(p_dteworkst,'dd/mm/yyyy'));
    obj_detail.put('dteworken', to_char(p_dteworken,'dd/mm/yyyy'));
    obj_detail.put('response', '');
    obj_detail.put('staappr', '');
    obj_detail.put('dtework', to_char(p_dteworkst, 'dd/mm/yyyy'));

    for r1 in c1 loop
        v_rcnt               := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', p_codempid_query);
        obj_data.put('dtereq', to_char(sysdate, 'dd/mm/yyyy'));
        obj_data.put('dtework', to_char(r1.dtework, 'dd/mm/yyyy'));
        obj_data.put('typwrko', r1.typwork);
        obj_data.put('desc_typwrko', nvl(get_tlistval_name('TYPWRKFUL',r1.typwork,global_v_lang),''));
        obj_data.put('codshifto', r1.codshift);
        obj_data.put('desc_codshifto', r1.codshift||' - '||nvl(get_tshiftcd_name(r1.codshift,global_v_lang),''));

        if p_flgAfterSave = 'Y' then
            begin
                select a.*
                  into v_tworkreq
                  from tworkreq a, ttemprpt b
                 where a.codempid = p_codempid_query
--                   and a.dtereq = trunc(sysdate)
                   and a.dtework = trunc(r1.dtework)
                   and a.codempid = b.item1
                   and a.dtereq = to_date(b.item2,'dd/mm/yyyy')
                   and a.seqno = b.item3
                   and b.codapp = 'HRES6DE'
                   and b.codempid = global_v_codempid;
                obj_data.put('numseq', to_char(v_tworkreq.seqno));
                obj_data.put('dtereq', to_char(v_tworkreq.dtereq, 'dd/mm/yyyy'));
                obj_data.put('typwrkn', v_tworkreq.typwrkn);
                obj_data.put('codshiftn', v_tworkreq.codshiftn);
                obj_data.put('desc_codshifto', r1.codshift||' - '||nvl(get_tshiftcd_name(r1.codshift,global_v_lang),''));
                obj_data.put('remark', v_tworkreq.remark);

                if p_dteworkst = p_dteworken then
                    obj_detail.put('staappr', v_tworkreq.staappr);
                    obj_detail.put('numseq', to_char(v_tworkreq.seqno));
                    obj_detail.put('dtereq', to_char(v_tworkreq.dtereq, 'dd/mm/yyyy'));
                else
                    obj_detail.put('staappr', 'P');
                end if;

                begin
                    select timstrtw, timendw
                      into v_timstrtw, v_timendw
                      from tshiftcd
                      where codshift = v_tworkreq.codshiftn;
                exception when others then
                    v_timstrtw  := null;
                    v_timendw   := null;
                end;
                obj_data.put('timen',to_char(to_date(v_timstrtw, 'hh24mi'), 'hh24:mi') || '-' || to_char(to_date(v_timendw, 'hh24mi'), 'hh24:mi'));
            exception when no_data_found then
                null;
            end;
        else
            begin
                delete ttemprpt
                 where codapp = 'HRES6DE'
                   and codempid = global_v_codempid;
            exception when others then
                null;
            end;

--            p_numseq             := p_numseq + 1;
--            obj_data.put('numseq', to_char(p_numseq));
            obj_data.put('typwrkn', '');
            obj_data.put('codshiftn', '');
            obj_data.put('remark', '');
        end if;

        begin
            select timstrtw, timendw
              into v_timstrtw, v_timendw
              from tshiftcd
              where codshift = r1.codshift;
        exception when others then
            v_timstrtw  := null;
            v_timendw   := null;
        end;

        obj_data.put('timeo',to_char(to_date(v_timstrtw, 'hh24mi'), 'hh24:mi') || '-' || to_char(to_date(v_timendw, 'hh24mi'), 'hh24:mi'));


        obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    obj_main.put('coderror', '200');
    obj_main.put('table', obj_row);
    obj_main.put('detail', obj_detail);

    gen_calendar_period (calendar_clob);
    obj_calendar := json_object_t(calendar_clob);
    obj_main.put('calendar', obj_calendar);
    json_str_output := obj_main.to_clob;
  end gen_create;
end HRES6DE;

/
