--------------------------------------------------------
--  DDL for Package Body HRESS2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRESS2E" AS
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

    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'ddmmyyyy');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj, 'p_dtereq'), 'ddmmyyyy');
    p_dtereq2save       := to_date(hcm_util.get_string_t(json_obj, 'dtereq'), 'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj, 'numseq');
    p_staappr           := hcm_util.get_string_t(json_obj, 'staappr');

    tpfmemrq_codpfinf   := hcm_util.get_string_t(json_obj, 'codpfinf');
    tpfmemrq_codplano   := hcm_util.get_string_t(json_obj, 'codplano');
    tpfmemrq_nummember  := hcm_util.get_string_t(json_obj, 'nummember');
    tpfmemrq_dteeffec   := to_date(hcm_util.get_string_t(json_obj, 'dteeffec'), 'dd/mm/yyyy');
    tpfmemrq_dtechg     := to_date(hcm_util.get_string_t(json_obj, 'dtechg'), 'dd/mm/yyyy');
    tpfmemrq_flgemp     := hcm_util.get_string_t(json_obj, 'flgemp');
    tpfmemrq_dtereti    := to_date(hcm_util.get_string_t(json_obj, 'dtereti'), 'dd/mm/yyyy');
    tpfmemrq_remark     := hcm_util.get_string_t(json_obj, 'remark');
    tpfmemrq_ratereta   := hcm_util.get_string_t(json_obj, 'ratereta');
    tpfmemrq_codplann   := hcm_util.get_string_t(json_obj, 'codplann');
    tpfmemrq_staappr    := hcm_util.get_string_t(json_obj, 'staappr');
    tpfmemrq_codreti    := hcm_util.get_string_t(json_obj, 'codreti');
    tpfmemrq_dteplann   := to_date(hcm_util.get_string_t(json_obj, 'dteplann'), 'dd/mm/yyyy');
    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');--User37 #675 4.ES.MS Module 28/04/2021 

    tpfmemrq_dteplano   := tpfmemrq_dteeffec;
    tpfmemrq_dteinput   := sysdate;
    tpfmemrq_codinput   := global_v_codempid;

    json_tab2           := hcm_util.get_json_t(json_obj, 'tab2table');

    p_codpfinf          := hcm_util.get_string_t(json_obj, 'codpfinf');
    p_codplan           := hcm_util.get_string_t(json_obj, 'codplan');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'), 'ddmmyyyy');

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
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;

    cursor cl is
      select dtereq, seqno, staappr, remarkap, codappr, codempid, approvno
        from tpfmemrq
       where codempid = global_v_codempid
         and dtereq between p_dtestrt and p_dteend
       order by dtereq desc, seqno desc;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in cl loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtereq', to_char(r1.dtereq, 'dd/mm/yyyy'));
      obj_data.put('numseq', to_char(r1.seqno));
      obj_data.put('staappr', r1.staappr);
      obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', r1.staappr, global_v_lang));
      obj_data.put('remarkap', replace(r1.remarkap, chr(13) || chr(10), ' '));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', r1.codappr || ' ' || get_temploy_name(r1.codappr, global_v_lang));
      obj_data.put('codempap', chk_workflow.get_next_approve('HRESS2E', r1.codempid, to_char(r1.dtereq, 'dd/mm/yyyy'), r1.seqno, r1.approvno, global_v_lang));

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
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_data           json_object_t;
    v_codpfinf         tpfmemb.codpfinf%type;
    v_codplan          tpfmemb.codplan%type;
    v_codreti          tpfmemb.codreti%type;
    v_nummember        tpfmemb.nummember%type;
    v_dteeffec         tpfmemb.dteeffec%type;
    v_flgemp           tpfmemb.flgemp%type;
    v_dtereti          tpfmemb.dtereti%type;
    v_chkExist         varchar2(1 char);
    v_found            varchar2(1 char);
    cursor c1 is
      select seqno, remark, ratereta, dtechg, dtereq, codplann, dteeffec, flgemp, dtereti, staappr, dteplann
        from tpfmemrq
       where codempid = global_v_codempid
         and dtereq   = p_dtereq
         and seqno    = p_numseq;

  begin
    begin
      select 'Y' into v_chkExist
          from tpfmemrq
         where codempid = global_v_codempid
           and dtereq   = p_dtereq
           and seqno    = p_numseq;
    exception when others then
      v_chkExist := 'N';
    end;
    if v_chkExist = 'N' then
      begin
        select codpfinf, nummember, dteeffec, flgemp, dtereti, codplan, codreti
          into v_codpfinf, v_nummember, v_dteeffec, v_flgemp, v_dtereti, v_codplan, v_codreti
          from tpfmemb
         where codempid = global_v_codempid;
      exception when no_data_found then
        null;
      end;
    else
      begin
        select codpfinf, nummember, dteeffec, flgemp, dtereti, codplano, codreti
          into v_codpfinf, v_nummember, v_dteeffec, v_flgemp, v_dtereti, v_codplan, v_codreti
          from tpfmemrq
         where codempid = global_v_codempid
           and dtereq   = p_dtereq
           and seqno    = p_numseq;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtereq', to_char(sysdate, 'dd/mm/yyyy'));
    obj_data.put('codpfinf', v_codpfinf);
    obj_data.put('desc_pfinf', get_tcodec_name('tcodpfinf', v_codpfinf, global_v_lang));
    obj_data.put('codplano', v_codplan);
    obj_data.put('desc_plano', get_tcodec_name('tcodpfpln', v_codplan, global_v_lang));
    obj_data.put('nummember', v_nummember);
    obj_data.put('dteeffec', to_char(v_dteeffec, 'dd/mm/yyyy'));
    obj_data.put('dtechg', to_char(sysdate, 'dd/mm/yyyy'));
    obj_data.put('flgemp', v_flgemp);
    obj_data.put('dtereti', to_char(v_dtereti, 'dd/mm/yyyy'));
    obj_data.put('codreti', v_codreti);
    obj_data.put('dteplann', '');

    for r1 in c1 loop
      obj_data.put('numseq', to_char(r1.seqno));
      obj_data.put('remark', r1.remark);
      obj_data.put('ratereta', r1.ratereta);
      obj_data.put('codplann', r1.codplann);
      obj_data.put('dtereq', to_char(r1.dtereq, 'dd/mm/yyyy'));
      obj_data.put('dtechg', to_char(r1.dtechg, 'dd/mm/yyyy'));
      obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
      obj_data.put('flgemp', r1.flgemp);
      obj_data.put('dtereti', to_char(r1.dtereti, 'dd/mm/yyyy'));
      obj_data.put('dteplann', to_char(r1.dteplann, 'dd/mm/yyyy'));
      obj_data.put('staappr', r1.staappr);
    end loop;
    if p_numseq is null then
      obj_data.put('numseq', gen_numseq(p_dtereq));
    end if;

    json_str_output := obj_data.to_clob;
  end gen_detail;

  function gen_numseq(v_dtereq date) return number is
    v_numseq      tpfmemrq.seqno%type;
  begin
    begin
      select (nvl(max(seqno), 0) + 1) numseq
        into v_numseq
        from tpfmemrq
       where codempid = global_v_codempid
         and dtereq   = v_dtereq;
    exception when others then
      null;
    end;
    return v_numseq;
  end gen_numseq;

  procedure check_tpfmemrq2 is
    v_codplan           tpfpcinf.codplan%type;
  begin
    if tpfmemrq_codplann is not null then
      begin
        select distinct codplan
          into v_codplan
          from tpfpcinf
         where codpfinf = tpfmemrq_codpfinf
           and codplan = tpfmemrq_codplann
           and codcompy = hcm_util.get_codcomp_level(tpfmemrq_codcomp, 1)
           and dteeffec = (select max(dteeffec)
                             from tpfpcinf
                            where trunc(dteeffec) <= trunc(tpfmemrq_dteplann)
                              and codpfinf = tpfmemrq_codpfinf
                              and codcompy = hcm_util.get_codcomp_level(tpfmemrq_codcomp, 1)
                              and codplan = tpfmemrq_codplann);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpfpcinf');
        return;
      end;

      -- if tpfmemrq2_codpolicy is not null then
        -- if nvl(tpfmemrq2_qtycompst, 0) = 0 then
        --   param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        --   return;
        -- end if;

        -- if v_qtycompst <> 100 then
        --   param_msg_error := get_error_msg_php('PY0039', global_v_lang);
        --   return;
        -- end if;
      -- end if;g
    end if;
  end check_tpfmemrq2;

  procedure check_save is
    v_chkcod      tcodpfinf.codcodec%type;
  begin
    if p_numseq is null then
      p_numseq := gen_numseq(p_dtereq2save);
    end if;

    tpfmemrq_seqno            := p_numseq;
    tpfmemrq_dtereq           := p_dtereq2save;
    tpfmemrq_codempid         := global_v_codempid;
    tpfmemrq_codcomp          := hcm_util.get_temploy_field(global_v_codempid, 'codcomp');

    if tpfmemrq_flgemp = '1' then
      if tpfmemrq_ratereta is null and tpfmemrq_codplann is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      elsif tpfmemrq_dtechg is null and tpfmemrq_dteeffec is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;
      if tpfmemrq_dtechg < tpfmemrq_dteeffec and tpfmemrq_dteeffec is not null then
        param_msg_error := get_error_msg_php('PY0033', global_v_lang);
        return;
      end if;
      check_tpfmemrq2;
      if param_msg_error is not null then
        return;
      end if;
    elsif tpfmemrq_flgemp = '2' then
      if tpfmemrq_dtereti is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;
      if tpfmemrq_dtechg < tpfmemrq_dteeffec and tpfmemrq_dteeffec is not null then
        param_msg_error := get_error_msg_php('PY0033', global_v_lang);
        return;
      end if;
    end if;

    begin
      select codcodec into v_chkcod
        from tcodpfinf
       where codcodec = to_char(tpfmemrq_codpfinf);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodpfinf');
      return;
    end;
  end check_save;

  procedure save_tprofreq is
    obj_data      json_object_t;
    v_count       number := 0;
  begin
    tprofreq_codempid   :=  global_v_codempid;
    tprofreq_dtereq     :=  p_dtereq2save;
    tprofreq_seqno      :=  p_numseq;
    tprofreq_dteupd     :=  sysdate;
    tprofreq_coduser    :=  global_v_coduser;

    -- delete before insert
    begin
      delete from tprofreq
       where codempid = tprofreq_codempid
         and dtereq   = tprofreq_dtereq
         and seqno    = tprofreq_seqno;
    exception when others then
      null;
    end;

    tprofreq_numseq   := 0;
    for i in 0..json_tab2.get_size - 1 loop
      obj_data          := hcm_util.get_json_t(json_tab2, to_char(i));
      tprofreq_numseq   := nvl(tprofreq_numseq, 0) + 1;
      tprofreq_nampfic  := hcm_util.get_string_t(obj_data, 'nampfic');
      tprofreq_adrpfic  := hcm_util.get_string_t(obj_data, 'adrpfic');
      tprofreq_desrel   := hcm_util.get_string_t(obj_data, 'desrel');
      tprofreq_ratepf   := to_number(hcm_util.get_string_t(obj_data, 'ratepf'));
      v_count           := v_count + nvl(tprofreq_ratepf, 0);
      begin
        insert into tprofreq
                    (codempid, numseq, seqno, dtereq,
                     nampfic, ratepf, desrel, adrpfic,
                     codcreate, dtecreate)
               values
                    (tprofreq_codempid, tprofreq_numseq, tprofreq_seqno, tprofreq_dtereq,
                     tprofreq_nampfic, tprofreq_ratepf, tprofreq_desrel, tprofreq_adrpfic,
                     tprofreq_coduser, tprofreq_dteupd);
      exception when dup_val_on_index then
        update tprofreq
            set nampfic  = tprofreq_nampfic,
                ratepf   = tprofreq_ratepf,
                desrel   = tprofreq_desrel,
                adrpfic  = tprofreq_adrpfic,
                coduser  = tprofreq_coduser,
                dteupd   = tprofreq_dteupd
          where codempid = tprofreq_codempid
            and numseq   = tprofreq_numseq
            and seqno    = tprofreq_seqno
            and dtereq   = tprofreq_dtereq;
      end;
    end loop;

    if v_count > 100 then
      param_msg_error := get_error_msg_php('ES0029', global_v_lang, 'tprofreq');
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end save_tprofreq;

  procedure save_tpfmemrq2 is
    v_count number :=0;
    v_codcomp   temploy1.codcomp%type;--User37 #675 4.ES.MS Module 28/04/2021 
    cursor c1 is
      select dteeffec, codpfinf, codplan, codpolicy, dteupd, coduser , pctinvt
        from tpfpcinf
       where codpfinf = tpfmemrq_codpfinf
         and codplan  = tpfmemrq_codplann
         and codcompy = hcm_util.get_codcomp_level(v_codcomp,1) --User37 #675 4.ES.MS Module 28/04/2021 
         and dteeffec = (select max(dteeffec)
                           from tpfpcinf
                          where trunc(dteeffec) <= trunc(tpfmemrq2_dtereq)
                            and codcompy = hcm_util.get_codcomp_level(v_codcomp,1) --User37 #675 4.ES.MS Module 28/04/2021 
                            and codpfinf = tpfmemrq_codpfinf
                            and codplan = tpfmemrq_codplann);
  begin
    tpfmemrq2_codempid  := global_v_codempid;
    tpfmemrq2_dtereq    := p_dtereq2save;
    tpfmemrq2_seqno     := p_numseq;
    --<<User37 #675 4.ES.MS Module 28/04/2021 
    begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid_query;
    end;
    -->>User37 #675 4.ES.MS Module 28/04/2021 

    begin
      delete from tpfmemrq2
       where codempid = tpfmemrq2_codempid
         and seqno    = tpfmemrq2_seqno
         and dtereq   = tpfmemrq2_dtereq;
    exception when others then
      null;
    end;
    if tpfmemrq_dteplann is not null then
      tpfmemrq2_dteupd    := sysdate;
      tpfmemrq2_coduser   := global_v_coduser;

      for r1 in c1  loop
        tpfmemrq2_codplan   := tpfmemrq_codplann;
        tpfmemrq2_codpolicy := r1.codpolicy;
        tpfmemrq2_dteeffec  := r1.dteeffec;
         tpfmemrq2_qtycompst := r1.pctinvt;

        -- begin
        --   select codpolicy into tpfmemrq2_codpolicy
        --     from tpfrinf
        --    where codpolicy = tpfmemrq2_codpolicy
        --      and codpfinf  = tpfmemrq_codpfinf;
        -- exception when no_data_found then
        --   tpfmemrq2_codpolicy := null;
        -- end;

        begin
          select count(*) into v_count
            from tpfmemrq2
          where codempid  = tpfmemrq2_codempid
            and dtereq    = tpfmemrq2_dtereq
            and seqno     = tpfmemrq2_seqno
            and codpolicy = tpfmemrq2_codpolicy;
        exception when no_data_found then
          v_count := 0;
        end;

        if v_count > 0 then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tpfmemrq2');
          return;
        end if;

        begin
          insert
            into tpfmemrq2
                (codempid, dtereq, seqno, codplan,
                  codpolicy, dteeffec, dteupd, qtycompst,
                  coduser)
          values
                (tpfmemrq2_codempid, tpfmemrq2_dtereq, tpfmemrq2_seqno, tpfmemrq2_codplan,
                  tpfmemrq2_codpolicy, tpfmemrq2_dteeffec, tpfmemrq2_dteupd, tpfmemrq2_qtycompst,
                  tpfmemrq2_coduser);
        exception when dup_val_on_index then
          null;
        end;
      end loop;
    end if;
  end save_tpfmemrq2;

  procedure save_tpfmemrq is
    v_codplann          tpfmemrq.codplann%type;
  begin
    begin
      insert into tpfmemrq
       (seqno, dtereq, codempid, nummember,
        codpfinf, dtechg, remark, ratereta,
        codcomp, staappr, codappr, dteappr,
        approvno, dteplann, dteupd, coduser,
        routeno,codreti,
        --codempap, codcompap, codposap,
        flgsend, codinput, dtecancel, dteinput,
        dtesnd, dteapph, flgagency, codplano,
        dteplano, codplann, dteeffec, dtereti,
        flgemp, remarkap,codcreate)
      values
       (tpfmemrq_seqno, tpfmemrq_dtereq, tpfmemrq_codempid, tpfmemrq_nummember,
        tpfmemrq_codpfinf, tpfmemrq_dtechg, tpfmemrq_remark, tpfmemrq_ratereta,
        tpfmemrq_codcomp, tpfmemrq_staappr, tpfmemrq_codappr, tpfmemrq_dteappr,
        tpfmemrq_approvno, tpfmemrq_dteplann, tpfmemrq_dteupd, global_v_coduser,
        tpfmemrq_routeno, tpfmemrq_codreti,
        --tpfmemrq_codempap, tpfmemrq_codcompap, tpfmemrq_codposap,
        tpfmemrq_flgsend, tpfmemrq_codinput, tpfmemrq_dtecancel, tpfmemrq_dteinput,
        tpfmemrq_dtesnd, tpfmemrq_dteapph, tpfmemrq_flgagency, tpfmemrq_codplano,
        tpfmemrq_dteplano, tpfmemrq_codplann, tpfmemrq_dteeffec, tpfmemrq_dtereti,
        tpfmemrq_flgemp, tpfmemrq_remarkap,global_v_coduser);
    exception when dup_val_on_index then
      update tpfmemrq
        set nummember = tpfmemrq_nummember,
            codpfinf  = tpfmemrq_codpfinf,
            dtechg    = tpfmemrq_dtechg,
            remark    = tpfmemrq_remark,
            ratereta  = tpfmemrq_ratereta,
            codcomp   = tpfmemrq_codcomp,
            staappr   = tpfmemrq_staappr,
            codappr   = tpfmemrq_codappr,
            dteappr   = tpfmemrq_dteappr,
            approvno  = tpfmemrq_approvno,
            dteplann  = tpfmemrq_dteplann,
            dteupd    = tpfmemrq_dteupd,
            coduser   = global_v_coduser,
            routeno   = tpfmemrq_routeno,
            codreti   = tpfmemrq_codreti,

            flgsend   = tpfmemrq_flgsend,
            codinput  = tpfmemrq_codinput,
            dtecancel = tpfmemrq_dtecancel,
            dtesnd    = tpfmemrq_dtesnd,
            dteapph   = tpfmemrq_dteapph,
            flgagency = tpfmemrq_flgagency,
            codplano  = tpfmemrq_codplano,
            dteplano  = tpfmemrq_dteplano,
            codplann  = tpfmemrq_codplann,
            dteeffec  = tpfmemrq_dteeffec,
            dtereti   = tpfmemrq_dtereti,
            flgemp    = tpfmemrq_flgemp,
            remarkap  = tpfmemrq_remarkap
      where codempid  = tpfmemrq_codempid
        and seqno     = tpfmemrq_seqno
        and dtereq    = tpfmemrq_dtereq;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  END save_tpfmemrq;

  procedure insert_next_step is
    v_codapp          varchar2(10 char) := 'HRESS2E';
    v_approvno        number := 0;
    v_codempid_next   temploy1.codempid%type;
    v_codempap        temploy1.codempid%type;
    v_codcompap       tcenter.codcomp%type;
    v_codposap        varchar2(4 char);
    b_remark          varchar2(200 char) := substr(get_label_name('HRESZXEC1', global_v_lang, 99), 1, 200);
    v_routeno         varchar2(15 char);
    v_table           varchar2(50 char);
    v_error           varchar2(50 char);

  BEGIN
    tpfmemrq_codempid   := global_v_codempid;
    tpfmemrq_dtereq     := p_dtereq2save;
    v_approvno          := 0;
    v_codempap          := global_v_codempid;
    tpfmemrq_staappr    := 'P';
    chk_workflow.find_next_approve(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_approvno, v_codempap);
    commit;
    --<< user22 : 20/08/2016 : HRMS590307 ||
    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(v_codapp, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_approvno, v_table, v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error, global_v_lang, v_table);
      return;
    end if;
    -->> user22 : 20/08/2016 : HRMS590307 ||

   --Loop Check Next step
    loop
    -- v_codempid_next := chk_workflow.check_next_approve(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_approvno, v_codempap);
    v_codempid_next := chk_workflow.check_next_step(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_approvno, global_v_codempid);
      if v_codempid_next is not null then
        v_approvno          := v_approvno + 1;
        tpfmemrq_codappr    := v_codempid_next;
        tpfmemrq_staappr    := 'A';
        tpfmemrq_dteappr    := trunc(sysdate);
        tpfmemrq_remarkap   := b_remark;
        tpfmemrq_approvno   := v_approvno;

        begin
          insert into tapempch
                  (codempid, dtereq, numseq, typreq, approvno, codappr, dteappr,
                   staappr, remark, dteupd, coduser)
          values  (global_v_codempid, p_dtereq2save, p_numseq, v_codapp, v_approvno, v_codempid_next, trunc(sysdate),
                   'A', b_remark, trunc(sysdate), global_v_coduser);
        exception when dup_val_on_index then
          update tapempch
             set codappr   = v_codempid_next,
                 dteappr   = trunc(sysdate),
                 staappr   = 'A',
                 remark    = b_remark,
                 coduser   = global_v_coduser
           where codempid  = global_v_codempid
             and dtereq    = p_dtereq2save
             and numseq    = p_numseq
             and typreq    = v_codapp
             and approvno  = v_approvno;
        end;
        chk_workflow.find_next_approve(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_approvno, v_codempid_next);
      else
        exit;
      end if;
    end loop;
    tpfmemrq_approvno     := v_approvno;
    tpfmemrq_routeno      := v_routeno;
    tpfmemrq_codempap     := v_codempap;
    tpfmemrq_codcompap    := v_codcompap;
    tpfmemrq_codposap     := v_codposap;
  exception when others then

    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      insert_next_step;
      if param_msg_error is null then
        save_tpfmemrq;
        if param_msg_error is null then
          save_tprofreq;
          if param_msg_error is null then
            save_tpfmemrq2;
          end if;
        end if;
      end if;
    end if;
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
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;

  procedure cancel_request (json_str_input in clob, json_str_output out clob) AS
    v_staappr       tpfmemrq.staappr%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      if p_dtereq2save is not null then
        if p_staappr = 'P' then
          v_staappr := 'C';
          begin
            update tpfmemrq
               set staappr   = v_staappr,
                   dtecancel = sysdate,
                   coduser   = global_v_coduser
             where codempid  = global_v_codempid
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
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
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
    v_dteeffec      tpfmemb.dteeffec%type;
    v_codcomp       tpfmemb.codcomp%type;

    cursor c1 is
      select codplan
        from tpfpcinf
       where codpfinf = p_codpfinf
         and codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
         and dteeffec = (
          select max(dteeffec)
            from tpfpcinf
           where dteeffec <= trunc(p_dteeffec)
             and codpfinf = p_codpfinf
             and codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
        )
       group by codplan
       order by codplan;
  begin
    initial_value(json_str_input);
    begin
      select codpfinf, dteeffec, codcomp
        into p_codpfinf, v_dteeffec, v_codcomp
        from tpfmemb
       where codempid = global_v_codempid;
    exception when no_data_found then
      null;
    end;
    if p_dteeffec is null then
      p_dteeffec := v_dteeffec;
    end if;

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
      obj_data.put('codcodec', i.codplan);
      obj_data.put('descode', get_tcodec_name('tcodpfpln', i.codplan, '101'));
      obj_lang1.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descode', get_tcodec_name('tcodpfpln', i.codplan, '102'));
      obj_lang2.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descode', get_tcodec_name('tcodpfpln', i.codplan, '103'));
      obj_lang3.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descode', get_tcodec_name('tcodpfpln', i.codplan, '104'));
      obj_lang4.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('descode', get_tcodec_name('tcodpfpln', i.codplan, '105'));
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
    obj_data.put('response', dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400');
    return obj_data.to_clob;
  END;

  procedure get_tpfirinf (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tpfirinf(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tpfirinf;

  procedure gen_tpfirinf (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_codcompy         temploy1.codcomp%type;
    v_codpfinf         tpfmemb.codpfinf%type;
    cursor c1 is
      select ir.dteeffec, ir.codpfinf, ir.codplan, pc.codpolicy, pc.pctinvt
        from tpfirinf ir, tpfpcinf pc
       where ir.codempid  = global_v_codempid
         and pc.codcompy  = v_codcompy
         and ir.codpfinf  = v_codpfinf
         and ir.codpfinf  = pc.codpfinf
         and ir.codplan   = pc.codplan
         and pc.dteeffec  = (select max(dteeffec)
                               from tpfpcinf
                              where codcompy  = v_codcompy
                                and codpfinf  = pc.codpfinf
                                and codplan   = pc.codplan
                                and dteeffec  <= ir.dteeffec)
      order by ir.dteeffec,ir.codplan, pc.codpolicy;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    begin
      select get_codcompy(codcomp) into v_codcompy
        from temploy1
       where codempid = global_v_codempid;
    exception when others then
      null;
    end;
    begin
      select codpfinf
        into v_codpfinf
        from tpfmemb
       where codempid = global_v_codempid;
    exception when no_data_found then
      null;
    end;
    for r1 in c1 loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codpolicy', r1.codpolicy);
      obj_data.put('desc_policy', get_tcodec_name('TCODPFPLC', r1.codpolicy, global_v_lang));
      obj_data.put('qty', r1.pctinvt);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tpfirinf;

  procedure get_tpfpcinf (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tpfpcinf(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tpfpcinf;

  procedure gen_tpfpcinf (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_codcompy         temploy1.codcomp%type;
    v_codpfinf         tpfmemb.codpfinf%type;
    cursor c1 is
      select codpolicy, pctinvt
        from tpfpcinf
       where codcompy = v_codcompy
         and codpfinf = tpfmemrq_codpfinf
         and codplan = tpfmemrq_codplano
         and dteeffec = (select max(b.dteeffec)
                           from tpfpcinf b
                          where codcompy = v_codcompy
                            and codpfinf = tpfmemrq_codpfinf
                            and codplan = tpfmemrq_codplano
                            and b.dteeffec <= trunc(sysdate))
       order by codplan,codpolicy;

  begin
    obj_row                := json_object_t(); 
    v_rcnt                 := 0;
    begin
      select get_codcompy(codcomp) into v_codcompy
        from temploy1
       where codempid = global_v_codempid;
    exception when others then
      null;
    end;
    for r1 in c1 loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codpolicy', r1.codpolicy);
      obj_data.put('desc_policy', get_tcodec_name('TCODPFPLC', r1.codpolicy, global_v_lang));
      obj_data.put('qty', r1.pctinvt);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tpfpcinf;

  procedure get_tpficinf (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tpficinf(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tpficinf;

  procedure gen_tpficinf (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;

    cursor c1 is
      select numseq, nampfic, adrpfic, desrel, ratepf
        from tpficinf
       where codempid = global_v_codempid
       order by numseq;

    cursor c2 is
      select numseq, nampfic, adrpfic, desrel, ratepf
        from tprofreq
       where codempid = global_v_codempid
         and dtereq   = p_dtereq
         and seqno    = p_numseq;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    if p_numseq is null then
      for r1 in c1 loop
        v_rcnt               := v_rcnt + 1;
        obj_data             := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', r1.numseq);
        obj_data.put('nampfic', r1.nampfic);
        obj_data.put('adrpfic', r1.adrpfic);
        obj_data.put('desrel', r1.desrel);
        obj_data.put('ratepf', r1.ratepf);

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    else
      for r1 in c2 loop
        v_rcnt               := v_rcnt + 1;
        obj_data             := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', r1.numseq);
        obj_data.put('nampfic', r1.nampfic);
        obj_data.put('adrpfic', r1.adrpfic);
        obj_data.put('desrel', r1.desrel);
        obj_data.put('ratepf', r1.ratepf);

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end gen_tpficinf;
end HRESS2E;

/
