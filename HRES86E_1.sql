--------------------------------------------------------
--  DDL for Package Body HRES86E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES86E" AS
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

    p_codempid           := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'ddmmyyyy');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj, 'p_dtereq'), 'ddmmyyyy');
    p_dtereq2save       := to_date(hcm_util.get_string_t(json_obj, 'dtereq'), 'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj, 'numseq');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'dteeffec'), 'dd/mm/yyyy');
    p_codexemp          := hcm_util.get_string_t(json_obj, 'codexemp');
    p_desnote           := hcm_util.get_string_t(json_obj, 'desnote');
    p_staappr           := hcm_util.get_string_t(json_obj, 'staappr');
    p_intwno            := hcm_util.get_string_t(json_obj, 'intwno');
    p_codpos            := hcm_util.get_string_t(json_obj, 'codpos');
    json_intw           := hcm_util.get_json_t(json_obj, 'intw');
    if p_codempid is null then
      p_codempid := global_v_codempid;
    end if;    
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

    cursor c1 is
      select dtereq, numseq, dteeffec, codexemp, staappr, remarkap, codappr, codempid, approvno
        from tresreq
       where codempid = p_codempid
         and dtereq between p_dtestrt and p_dteend
       order by dtereq desc, numseq desc;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in c1 loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtereq', to_char(r1.dtereq, 'dd/mm/yyyy'));
      obj_data.put('numseq', to_char(r1.numseq));
      obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
      obj_data.put('codexemp', r1.codexemp);
      obj_data.put('desc_codexemp', get_tcodec_name('TCODEXEM', r1.codexemp, global_v_lang));
      obj_data.put('staappr', r1.staappr);
      obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', r1.staappr, global_v_lang));
      obj_data.put('remarkap', replace(r1.remarkap, chr(13) || chr(10), ' '));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', r1.codappr || ' ' || get_temploy_name(r1.codappr, global_v_lang));
      obj_data.put('codempap', chk_workflow.get_next_approve('HRES86E', r1.codempid, to_char(r1.dtereq, 'dd/mm/yyyy'), r1.numseq, r1.approvno, global_v_lang));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure check_detail AS
  begin
    if p_codpos is null then
      p_codpos := hcm_util.get_temploy_field(p_codempid, 'codpos');
    end if;
  end;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);   
    check_detail;     
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
    obj_data           json_object_t;
    v_dtereq           tresreq.dtereq%type;
    v_numseq           tresreq.numseq%type;
    v_dteeffec         tresreq.dteeffec%type;
    v_codexemp         tresreq.codexemp%type;
    v_staappr          tresreq.staappr%type;
    v_desnote          tresreq.desnote%type;
    v_codempid         tresreq.codempid%type;
    v_intwno           tresreq.intwno%type;
    v_response         varchar2(4000 char);
    v_codcomp          temploy1.codcomp%type;
    v_flg              varchar2(1); --<<user25 Date:06/10/2021 4.ES.MS Module #7082
    cursor c1_texintwh is
      select intwno
        from texintwh
       where p_codpos between codposst and codposen
       order by intwno;
  begin
    v_codempid := p_codempid;

    if p_numseq is null then
      begin
        select dtereq, numseq
          into v_dtereq, v_numseq
          from tresreq
         where codempid = p_codempid
           and staappr in ('P', 'A')
           and rownum = 1;
      exception when no_data_found then
        null;
      end;
    end if;
    if v_dtereq is not null then
      obj_data        := json_object_t(get_response_message(null, get_error_msg_php('ES0027', global_v_lang), global_v_lang));
      v_response      := hcm_util.get_string_t(obj_data, 'response');
      p_dtereq        := v_dtereq;
      p_numseq        := v_numseq;
    elsif p_numseq is null then
      v_flg := 'N';--<<user25 Date:06/10/2021 4.ES.MS Module #7082
      begin
        select nvl(max(numseq), 0) numseq
          into v_numseq
          from tresreq
         where codempid = p_codempid
           and dtereq   = p_dtereq;
        p_numseq := v_numseq + 1;
      exception when others then
        null;
      end;
    end if;
    begin
      select dteeffec,
             codexemp,
             staappr,
             desnote,
             intwno,
             'Y'--<<user25 Date:06/10/2021 4.ES.MS Module #7082
        into v_dteeffec,
             v_codexemp,
             v_staappr,
             v_desnote,
             v_intwno,
             v_flg--<<user25 Date:06/10/2021 4.ES.MS Module #7082
      from tresreq
      where codempid = p_codempid
        and dtereq   = p_dtereq
        and numseq   = p_numseq;
    exception when no_data_found then
      null;
    end;
    if v_intwno is null then
      for r1 in c1_texintwh loop
        v_intwno := r1.intwno;
        exit;
      end loop;
    end if;
    begin
      select codcomp
        into v_codcomp
        from temploy1
       where codempid   = p_codempid;
    exception when no_data_found then
      null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('response', v_response);
    obj_data.put('dtereq', to_char(p_dtereq, 'dd/mm/yyyy'));
    obj_data.put('numseq', p_numseq);
    obj_data.put('dteeffec', to_char(nvl(v_dteeffec, trunc(sysdate)), 'dd/mm/yyyy'));
    obj_data.put('codexemp', v_codexemp);
    obj_data.put('desc_codexemp', get_tcodec_name('TCODEXEM', v_codexemp, global_v_lang));
    obj_data.put('staappr', v_staappr);
    obj_data.put('desnote', v_desnote);
    obj_data.put('codempid', v_codempid);
    obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
    obj_data.put('intwno', v_intwno);
    obj_data.put('codpos', p_codpos);
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('desc_codpos', p_codpos || ' - ' || get_tpostn_name(p_codpos, global_v_lang));
    obj_data.put('flg',v_flg);--<<user25 Date:06/10/2021 4.ES.MS Module #7082
    json_str_output := obj_data.to_clob;
  end gen_detail;

  function get_resintw (v_numcate texintwd.numcate%type, v_numseq texintwd.numseq%type) return varchar2 is
    v_response          tresintw.response%type;
  begin
    begin
      select response
        into v_response
        from tresintw
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq
         and numcate  = v_numcate
         and numqes   = v_numseq;
    exception when no_data_found then
      null;
    end;
    return v_response;
  end;

  function get_exintws (v_intwno texintws.intwno%type, v_numcate texintws.numcate%type) return varchar2 is
    v_namcate           texintws.namcatee%type;
  begin
    begin
      select decode(global_v_lang, '101', namcatee,
                                   '102', namcatet,
                                   '103', namcate3,
                                   '104', namcate4,
                                   '105', namcate5,
                                   namcatee)
        into v_namcate
        from texintws
       where intwno  = v_intwno
         and numcate = v_numcate;
    exception when no_data_found then
      null;
    end;
    return v_namcate;
  end;

  procedure get_texintw (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_texintw(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_texintw;

  procedure gen_texintw (json_str_output out clob) AS
    obj_rowd            json_object_t;
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_datad           json_object_t;
    obj_rowc            json_object_t;
    obj_datac           json_object_t;
    v_rcnt              number := 0;
    v_rcntd             number := 0;
    v_rcntc             number := 0;
    v_numcate           texintwd.numcate%type;
    v_numseq            texintwd.numseq%type;
    v_numans            texintwc.numans%type;
    v_dtereq            tresreq.dtereq%type;

    cursor c1_texintwh is
      select intwno
        from texintwh
       where p_codpos between codposst and codposen
       order by intwno;

    cursor c1 is
      select numcate
        from texintwd
       where intwno = p_intwno
       group by numcate
       order by numcate;

    cursor c2 is
      select t1.numcate, t1.numseq,
             decode(global_v_lang, '101', t1.detailse,
                                   '102', t1.detailst,
                                   '103', t1.details3,
                                   '104', t1.details4,
                                   '105', t1.details5) details,
             t1.detailse, t1.detailst, t1.details3, t1.details4, t1.details5, t2.typeques
        from texintwd t1, texintws t2
       where t1.intwno     = p_intwno
         and t1.numcate = v_numcate
         and t1.intwno  = t2.intwno
         and t1.numcate = t2.numcate
       order by numcate, numseq;

    cursor c3 is
      select numans, decode(global_v_lang, '101', detailse,
                                                            '102', detailst,
                                                            '103', details3,
                                                            '104', details4,
                                                            '105', details5) details,
             detailse, detailst, details3, details4, details5
        from texintwc
       where intwno  = p_intwno
         and numcate = v_numcate
         and numseq  = v_numseq
       order by numans;

  begin
    obj_row                 := json_object_t();
    v_rcnt                  := 0;
    if p_numseq is null then
      begin
        select dtereq, numseq
          into v_dtereq, v_numseq
          from tresreq
         where codempid = p_codempid
           and staappr in ('P', 'A')
           and rownum = 1;
      exception when no_data_found then
        null;
      end;
    end if;
    if v_dtereq is not null then
      p_dtereq        := v_dtereq;
      p_numseq        := v_numseq;
    end if;
    if p_intwno is null then
      for r1 in c1_texintwh loop
        p_intwno := r1.intwno;
        exit;
      end loop;
    end if;
    for r1 in c1 loop
      v_numcate               := r1.numcate;
      obj_rowd                := json_object_t();
      v_rcnt                  := v_rcnt + 1;
      v_rcntd                 := 0;
      for r2 in c2 loop
        v_rcntd                 := v_rcntd + 1;
        obj_datad               := json_object_t();
        v_numseq                := r2.numseq;
        obj_datad.put('coderror', '200');
        obj_datad.put('numcate', to_char(r2.numcate));
        obj_datad.put('numseq', to_char(r2.numseq));
        obj_datad.put('details', r2.details);
        obj_datad.put('detailse', r2.detailse);
        obj_datad.put('detailst', r2.detailst);
        obj_datad.put('details3', r2.details3);
        obj_datad.put('details4', r2.details4);
        obj_datad.put('details5', r2.details5);
        obj_datad.put('typeques', to_char(r2.typeques));
        obj_datad.put('result', get_resintw(v_numcate, v_numseq));

        obj_rowc              := json_object_t();
        v_rcntc               := 0;
        for r3 in c3 loop
          obj_datac             := json_object_t();
          v_rcntc               := v_rcntc + 1;
          obj_datac.put('coderror', '200');
          obj_datac.put('numans', to_char(r3.numans));
          obj_datac.put('details', r3.details);
          obj_datac.put('detailse', r3.detailse);
          obj_datac.put('detailst', r3.detailst);
          obj_datac.put('details3', r3.details3);
          obj_datac.put('details4', r3.details4);
          obj_datac.put('details5', r3.details5);

          obj_rowc.put(to_char(v_rcntc - 1), obj_datac);
        end loop;
        obj_datad.put('children', obj_rowc);

        obj_rowd.put(to_char(v_rcntd - 1), obj_datad);
      end loop;
      obj_data                := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('namcate', to_char(v_numcate) || '. ' || get_exintws(p_intwno, v_numcate));
      obj_data.put('texintw', obj_rowd);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_texintw;

  procedure check_save is
    v_numseq      tresreq.numseq%type;
    v_flg         varchar2(1); --<<user25 Date:06/10/2021 4.ES.MS Module #7082
  begin

  --  --<<user25 Date:06/10/2021 4.ES.MS Module #7082
       begin
         select 'Y'
          into v_flg
          from tresreq
         where codempid = p_codempid
           and dtereq   = p_dtereq2save;
      exception when no_data_found  then
        v_flg := 'N';
      end;


      if v_flg = 'N' then 
            if trunc(p_dteeffec) < trunc(sysdate) then
              param_msg_error := get_error_msg_php('HR8519', global_v_lang);
              return;
            end if;
     end if;


--    if trunc(p_dteeffec) < trunc(sysdate) then
--      param_msg_error := get_error_msg_php('HR8519', global_v_lang);
--      return;
--    end if;
      -->>user25 Date:06/10/2021 4.ES.MS Module #7082

    if p_intwno is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TEXINTWH');
      return;
    end if;
    if p_numseq is null then
      begin
        select nvl(max(numseq), 0) numseq
          into v_numseq
          from tresreq
         where codempid = p_codempid
           and dtereq   = p_dtereq2save;
        p_numseq := v_numseq + 1;
      exception when others then
        null;
      end;
    end if;
    begin
      select numseq
        into v_numseq
        from tresreq
        where codempid = p_codempid
          and staappr  in ('P', 'A')
          and (dtereq   <> p_dtereq2save
              or numseq   <> p_numseq)
          and rownum = 1;
      param_msg_error := get_error_msg_php('ES0027', global_v_lang);
      return;
    exception when no_data_found then
      null;
    end;
  end check_save;

  procedure save_tresreq AS
    v_codcomp     temploy1.codcomp%type;
  begin
    v_codcomp := hcm_util.get_temploy_field(p_codempid, 'codcomp');
    begin
      insert into tresreq (codempid, numseq, dtereq, dteeffec,
                          codappr, staappr, codcomp, remarkap,
                          dteappr, flgagency, codexemp,
                          routeno,
                          flgsend, dtecancel, dteinput, dtesnd,
                          dteupd, coduser, dteapph,
                          desnote, approvno, intwno,
                          codcreate
                          )
                  values (p_codempid, p_numseq, p_dtereq2save, p_dteeffec,
                          p_codappr, p_staappr, v_codcomp, p_remarkap,
                          p_dteappr, null, p_codexemp,
                          p_routeno,
                          'N', p_dtecancel, sysdate, null,
                          trunc(sysdate), global_v_coduser, sysdate,
                          p_desnote, p_approvno, p_intwno,
                          global_v_coduser
                          );
      exception when dup_val_on_index then
        update tresreq
           set codappr       = p_codappr,
               staappr       = p_staappr,
               codcomp       = v_codcomp,
               remarkap      = p_remarkap,
               dteeffec      = p_dteeffec,
               codexemp      = p_codexemp,
               dteappr       = p_dteappr,
               flgagency     = null,
               routeno       = p_routeno,
               flgsend       = null,
               dtecancel     = p_dtecancel,
               dteinput      = sysdate,
               dtesnd        = null,
               dteupd        = trunc(sysdate),
               coduser       = global_v_coduser,
               dteapph       = sysdate,
               desnote       = p_desnote,
               approvno      = p_approvno,
               intwno        = p_intwno
         where codempid = p_codempid
           and dtereq   = p_dtereq2save
           and numseq   = p_numseq;

        update tautomail
           set flgsend = 'N',
               coduser = global_v_coduser
         where codapp = 'HRES86E'
           and codempid = p_codempid
           and dtereq = p_dtereq2save
           and numseq = p_numseq
           and typchg = '0'
           and dtework = to_date('01/01/0001','dd/mm/yyyy');   
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end;

  procedure save_tresintw AS
    obj_tresintwh         json_object_t;
    obj_tresintwd         json_object_t;
    obj_tresintwc         json_object_t;
    obj_tresintwl         json_object_t;
    v_numcate             texintwd.numcate%type;
    v_numseq              texintwd.numseq%type;
    v_numans              tresintw.numqes%type;
    v_details             tresintw.details%type;
    v_detailse            texintwd.detailse%type;
    v_detailst            texintwd.detailst%type;
    v_details3            texintwd.details3%type;
    v_details4            texintwd.details4%type;
    v_details5            texintwd.details5%type;
    v_typeques            tresintw.typeques%type;
    v_response            tresintw.response%type;
  begin
    begin
      delete from tresintwc
       where codempid = p_codempid
         and dtereq   = p_dtereq2save
         and numseq   = p_numseq;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
    for i in 0..json_intw.get_size - 1 loop
      if param_msg_error is not null then
        return;
      end if;
      obj_tresintwh           := hcm_util.get_json_t(json_intw, to_char(i));
      obj_tresintwh           := hcm_util.get_json_t(obj_tresintwh, 'children');
      for j in 0..obj_tresintwh.get_size - 1 loop
        obj_tresintwd           := hcm_util.get_json_t(obj_tresintwh, to_char(j));
        v_numcate               := hcm_util.get_number_t(obj_tresintwd, 'numcate');
        v_numseq                := hcm_util.get_number_t(obj_tresintwd, 'numseq');
        v_details               := hcm_util.get_string_t(obj_tresintwd, 'details');
        v_response              := hcm_util.get_string_t(obj_tresintwd, 'result');
        v_typeques              := hcm_util.get_number_t(obj_tresintwd, 'typeques');
        obj_tresintwc           := hcm_util.get_json_t(obj_tresintwd, 'children');
        if param_msg_error is not null then
          return;
        end if;
        begin
          insert into tresintw (codempid, dtereq, numseq, numcate, numqes, details, response, typeques, codcreate, coduser)
          values (p_codempid, p_dtereq2save, p_numseq, v_numcate, v_numseq, v_details, v_response, v_typeques, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tresintw
            set details  = v_details,
                response = v_response,
                typeques = v_typeques,
                coduser  = global_v_coduser
          where codempid = p_codempid
            and dtereq   = p_dtereq2save
            and numseq   = p_numseq
            and numcate  = v_numcate
            and numqes   = v_numseq;
        end;
        if v_typeques = '2' then
          for k in 0..obj_tresintwc.get_size - 1 loop
            obj_tresintwl           := hcm_util.get_json_t(obj_tresintwc, to_char(k));
            v_numans                := hcm_util.get_number_t(obj_tresintwl, 'numans');
            v_detailse              := hcm_util.get_string_t(obj_tresintwl, 'detailse');
            v_detailst              := hcm_util.get_string_t(obj_tresintwl, 'detailst');
            v_details3              := hcm_util.get_string_t(obj_tresintwl, 'details3');
            v_details4              := hcm_util.get_string_t(obj_tresintwl, 'details4');
            v_details5              := hcm_util.get_string_t(obj_tresintwl, 'details5');
            if param_msg_error is not null then
              return;
            end if;
            begin
              insert into tresintwc (codempid, dtereq, numseq, numcate, numqes, numans,
                                    detailse, detailst, details3, details4, details5, codcreate, coduser)
              values (p_codempid, p_dtereq2save, p_numseq, v_numcate, v_numseq, v_numans,
                      v_detailse, v_detailst, v_details3, v_details4, v_details5, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              update tresintwc
                set detailse = v_detailse,
                    detailst = v_detailst,
                    details3 = v_details3,
                    details4 = v_details4,
                    details5 = v_details5,
                    coduser  = global_v_coduser
              where codempid = p_codempid
                and dtereq   = p_dtereq2save
                and numseq   = p_numseq
                and numcate  = v_numcate
                and numqes   = v_numseq
                and numans   = v_numans;
            end;
          end loop;
        end if;
      end loop;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end;

  procedure insert_next_step IS
    v_codapp              varchar2(10 char) := 'HRES86E';
    v_codempid_next       temploy1.codempid%type;
    v_approv              temploy1.codempid%type;
    parameter_v_approvno  tresreq.approvno%type;
    v_routeno             tresreq.routeno%type;
    v_desc                tresreq.remarkap%type := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    v_table               varchar2(50 char);
    v_error               varchar2(50 char);

  begin
    parameter_v_approvno  :=  0;
    --
    p_dtecancel           := null;
    p_staappr             := 'P';

    chk_workflow.find_next_approve(v_codapp, v_routeno, p_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, p_codempid);

    -- <<
    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(v_codapp, p_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_table, v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error, global_v_lang, v_table);
      return;
    end if;
    -- >>

    loop

      v_codempid_next := chk_workflow.check_next_step2(v_codapp, v_routeno, p_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_codapp, null, parameter_v_approvno, p_codempid);

      if v_codempid_next is not null then
         parameter_v_approvno := parameter_v_approvno + 1;
         p_codappr         := v_codempid_next;
         p_staappr         := 'A';
         p_dteappr         := trunc(sysdate);
         p_remarkap        := v_desc;
         p_approvno        := parameter_v_approvno;
         v_approv          := v_codempid_next;

        begin
          insert into tapresrq (codempid, dtereq, numseq,
                                approvno, codappr, dteappr,
                                staappr, remark, coduser,codcreate,
                                dterec, dteapph)
                values         (p_codempid, p_dtereq2save, p_numseq,
                                parameter_v_approvno, v_codempid_next, trunc(sysdate),
                                'A', v_desc, global_v_coduser, global_v_coduser,
                                sysdate, sysdate);
        exception when dup_val_on_index then
          update tapresrq
             set codappr   = v_codempid_next,
                 dteappr   = trunc(sysdate),
                 staappr   = 'A',
                 remark    = v_desc,
                 coduser   = global_v_coduser,
                 dterec    = sysdate,
                 dteapph   = sysdate
           where codempid  = p_codempid
             and dtereq    = p_dtereq2save
             and numseq    = p_numseq
             and approvno  = parameter_v_approvno;
        end;

        chk_workflow.find_next_approve(v_codapp, v_routeno, p_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_codempid_next);
      else
        exit;
      end if;
    end loop;
    p_approvno     := parameter_v_approvno;
    p_routeno      := v_routeno;
  end;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      insert_next_step;
    end if;
    if param_msg_error is null then
      save_tresreq;
    end if;
    if param_msg_error is null then
      save_tresintw;
    end if;
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
    v_staappr       tresreq.staappr%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      if p_dtereq2save is not null then
        if p_staappr = 'P' then
          v_staappr := 'C';
          begin
            update tresreq
               set staappr   = v_staappr,
                   dtecancel = sysdate,
                   coduser   = global_v_coduser
             where codempid  = p_codempid
               and dtereq    = p_dtereq2save
               and numseq    = p_numseq;
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

  function get_codexem(json_str_input in clob) return clob is
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
        from tcodexem
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
      obj_data.put('codexem', i.codcodec);
      obj_data.put('desexem', i.descode);
      obj_lang1.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desexem', i.descodt);
      obj_lang2.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desexem', i.descod3);
      obj_lang3.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desexem', i.descod4);
      obj_lang4.put(to_char(v_rcnt - 1), obj_data);
      obj_data.put('desexem', i.descod5);
      obj_lang5.put(to_char(v_rcnt - 1), obj_data);
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
    obj_data.put('desc_coderror', dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    return obj_data.to_clob;
  END;

  procedure initial_popup (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
  end initial_popup;

  -- Code POPUP_LINK1 Start
  procedure get_popup_link1(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_unit        varchar2(10 char);

    cursor c1 is
      select codasset, dtercass
        from tassets
       where codempid = p_codempid;

  begin
    initial_popup(json_str_input);
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_rcnt   := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codasset', r1.codasset);
      obj_data.put('desc_codasset', get_tasetinf_name(r1.codasset, global_v_lang));
      obj_data.put('dtercass', to_char(r1.dtercass, 'dd/mm/yyyy'));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_popup_link1;
  -- Code POPUP_LINK1 End

  -- Code POPUP_LINK2 Start
  procedure get_popup_link2(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_total       number := 0;
    v_rcnt        number := 0;

    cursor c1 is
      select dtelonst, numcont, amtlon, amtnpfin, dtelpay, dteaccls, codlon, numlon
        from tloaninf
       where codempid = p_codempid
         and nvl(amtnpfin, 0) > 0
         and staappr  = 'Y';

  begin
    initial_popup(json_str_input);
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt   := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteprom', to_char(r1.dtelonst, 'dd/mm/yyyy'));
      obj_data.put('prom_no', r1.numcont);
      obj_data.put('amt_loan', to_char(r1.amtlon));
      obj_data.put('loan', to_char(r1.amtnpfin));
      obj_data.put('dteaccls', to_char(r1.dteaccls, 'dd/mm/yyyy'));
      obj_data.put('codlon',  get_ttyploan_name(r1.codlon, global_v_lang));
      obj_data.put('numlon', r1.numlon);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_popup_link2;
  -- Code POPUP_LINK2

  -- Code POPUP_LINK3 Start
  procedure get_popup_link3(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;

    cursor c1 is
      select a.amttotpay, a.amtoutstd, a.amtrepaym,
             a.qtyrepaym, a.dtestrpm, a.dtelstpay
        from trepay a
       where a.codempid  = p_codempid
         and a.amtoutstd > 0
         and a.dteappr   = (
             select max(dteappr)
               from trepay c
              where c.codempid = a.codempid
            );

  begin
    initial_popup(json_str_input);
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('amtrepaym', to_char(r1.amtrepaym, 'fm999,999,990.00'));
      obj_row.put('qtyrepaym', r1.qtyrepaym);
      obj_row.put('dtestrpm', substr(r1.dtestrpm, 7) || '/' || substr(r1.dtestrpm, 5, 2) || '/' || to_char(to_number(substr(r1.dtestrpm, 1, 4))));
      obj_row.put('sum_atm',  to_char(r1.amttotpay + r1.amtoutstd, 'fm999,999,990.00'));
      obj_row.put('amttotpay', to_char(r1.amttotpay, 'fm999,999,990.00'));
      obj_row.put('amtoutstd', to_char(r1.amtoutstd, 'fm999,999,990.00'));
      obj_row.put('date_end', ' ');
      if r1.dtelstpay is not null then
        obj_row.put('date_end', substr(r1.dtelstpay, 7, 1) || '/' || substr(r1.dtelstpay, 5, 2) || '/' || to_char(to_number(substr(r1.dtestrpm, 1, 4))));
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_popup_link3;
  -- Code POPUP_LINK3

  -- Code POPUP_LINK4 Start.
  procedure get_popup_link4(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_codsco      varchar2(4000 char);

--    cursor c1 is
--      select codempid, codsco, desccomm, dtecomm, dtestartf
--        from tfunddet
--       where codempid = p_codempid
--         and codsco   >= ' '
--         and dtecomm  >= sysdate
--       order by codsco;

    cursor c2 is
     select distinct codcours, descommt, dtecntr, dtetrst
       from  thistrnn
      where  codempid = p_codempid
        and  dtecntr  >= sysdate
      order by codcours;

  begin
    initial_popup(json_str_input);
    obj_row  := json_object_t();
--    for r1 in c1 loop
--      v_rcnt   := v_rcnt + 1;
--      obj_data := json_object_t();
--      obj_data.put('coderror', '200');
--      begin
--        select codsco
--               || ' - ' ||
--               decode(global_v_lang, '101', namscoe,
--                                     '102', namscot,
--                                     '103', namsco3,
--                                     '104', namsco4,
--                                     '105', namsco5,
--                                     namscoe)
--          into v_codsco
--          from tfundinf
--         where codsco = r1.codsco
--           and rownum <= 1;
--      exception when no_data_found  then
--        v_codsco := null;
--      end;
--      obj_data.put('codsco', v_codsco);
--      obj_data.put('desccomm', to_char(r1.desccomm));
--      obj_data.put('dtestartf', to_char(r1.dtestartf, 'dd/mm/yyyy'));
--      obj_data.put('dtecomm', to_char(r1.dtecomm, 'dd/mm/yyyy'));
--
--      obj_row.put(to_char(v_rcnt - 1), obj_data);
--    end loop;

    for l in c2 loop
      v_rcnt   := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codsco', l.codcours || ' ' || get_tcourse_name(l.codcours, global_v_lang));
      obj_data.put('desccomm', replace(l.descommt, chr(10), ' '));
      obj_data.put('dtestartf', to_char(l.dtetrst, 'dd/mm/yyyy'));
      obj_data.put('dtecomm', to_char(l.dtecntr, 'dd/mm/yyyy'));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_popup_link4;
  -- Code POPUP_LINK4 End.
end HRES86E;

/
