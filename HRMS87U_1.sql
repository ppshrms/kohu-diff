--------------------------------------------------------
--  DDL for Package Body HRMS87U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS87U" is
-- last update: 27/09/2022 10:44

  procedure initial_value(json_str in clob) AS
    json_obj        json_object_t := json_object_t(json_str);
  begin
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_dtest             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtest')),'dd/mm/yyyy');
    p_dteen             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteen')),'dd/mm/yyyy');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_appseq            := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
    p_dteeffex          := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteeffex')),'dd/mm/yyyy');

    v_codappr           := pdk.check_codempid(global_v_coduser);
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;
  --
  procedure gen_index(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_nextappr    varchar2(1000 char);
    v_dtest       date;
    v_dteen       date;
    v_appno       varchar2(100 char);
    v_chk         varchar2(100 char) := ' ';
    v_date        VARCHAR2(10 char);
    v_dtereq      VARCHAR2(10 char);
    v_dteeffec    VARCHAR2(10 char);
    v_staappr     VARCHAR2(50 char);
    v_codproc     VARCHAR2(50 char);
    v_row         NUMBER := 0;

    v_numexemp    VARCHAR2(4000 CHAR);
    v_codempid    VARCHAR2(4000 CHAR);
    v_numseq      NUMBER;
    v_flgblist    varchar2(100 char);
    v_flgssm      varchar2(100 char);

    CURSOR c1 IS
       select codempid,dtereq,numseq,dteeffec,codexemp,desnote,
              staappr,codappr,dteappr,remarkap,a.approvno appno,codcomp,
              b.approvno qtyapp
         from tresreq a,twkflowh b
        where staappr in ('P','A')
        AND   ('Y' = chk_workflow.check_privilege('HRES86E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
            -- Replace Approve
                or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from   twkflowde c
                                                          where  c.routeno  = a.routeno
                                                          and    c.codempid = v_codappr)
                     and ((sysdate - nvl(dteapph,dteinput))*1440) >= (select  hrtotal  from twkflpf where codapp ='HRES86E')))
          and a.routeno = b.routeno
--          and a.codcomp like p_codcomp||'%'
          and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
     ORDER BY a.codempid,a.dtereq,a.numseq,a.dteeffec;

     CURSOR c2 IS
      select codempid,codappr,approvno,codcomp,dteappr,remarkap,
             get_temploy_name(codempid,global_v_lang) ename,staappr,
             get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
             get_tcenter_name(codcomp,global_v_lang) namcomp,dtereq,numseq,dteeffec,
             codexemp
        from tresreq
--       where codcomp like p_codcomp||'%'
       where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and (codempid ,dtereq,numseq) in
                      (select codempid, dtereq ,numseq
                       from  tapresrq
                       where staappr = decode(p_staappr,'Y','A',p_staappr)
                       and   codappr = v_codappr
                       and   dteappr between nvl(p_dtest,dteappr) and nvl(p_dteen,dteappr) )
       order by  codempid,dtereq,numseq;

      cursor c_tapresrq is
        SELECT numexemp, flgblist, flgssm
          FROM tapresrq
         WHERE codempid = v_codempid
           AND dtereq   = to_date(v_dtereq,'dd/mm/yyyy')
           AND numseq   = v_numseq
           AND approvno < v_appno
         ORDER BY codempid,approvno;

  begin
    -- get data
    if p_staappr = 'P' then
      obj_row  := json_object_t();
      FOR r1 IN c1 LOOP
        if secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
            v_appno   := nvl(r1.appno,0) + 1;
            v_row     := v_row+1;
            IF nvl(r1.appno,0)+1 = r1.qtyapp THEN
               v_chk := 'E' ;
            ELSE
               v_chk := v_appno ;
            end if;
            v_dtereq    := to_char(r1.dtereq,'dd/mm/yyyy');
            v_dteeffec  := to_char(r1.dteeffec, 'dd/mm/yyyy');
            v_staappr   := get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang);

            v_codempid := r1.codempid;
            v_numseq := r1.numseq;
            v_numexemp := null;
            v_flgblist := null;
            v_flgssm   := null;
            FOR r_tapresrq IN c_tapresrq loop
              v_numexemp := r_tapresrq.numexemp;
              v_flgblist := r_tapresrq.flgblist;
              v_flgssm   := r_tapresrq.flgssm;
            end loop;

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', '');
            obj_data.put('flg', '');
            obj_data.put('total','');
            obj_data.put('rcnt', '');
            obj_data.put('approvno', v_appno);
            obj_data.put('chk_appr', v_chk);
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('numseq', to_char(r1.numseq));
            obj_data.put('codcomp',r1.codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('dtereq', v_dtereq);
            obj_data.put('dteeffec', v_dteeffec);
            obj_data.put('codexemp', r1.codexemp);
            obj_data.put('desc_codexemp', get_tcodec_name('TCODEXEM',r1.codexemp,global_v_lang));
            obj_data.put('status', v_staappr);
            obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
            obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('remark', r1.remarkap);
            obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
            obj_data.put('staappr', r1.staappr);
            obj_data.put('numexemp', v_numexemp);
            obj_data.put('flgblist', v_flgblist);
            obj_data.put('flgssm', v_flgssm);
            obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
    else
      obj_row  := json_object_t();
      for r1 in c2 loop
        if secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
            v_dtereq    := to_char(r1.dtereq,'dd/mm/yyyy');
            v_dteeffec  := to_char(r1.dteeffec, 'dd/mm/yyyy');
            v_staappr   := get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang);
            v_row       := v_row+1;
            --
            v_nextappr := null;
            if r1.staappr = 'A' then
              v_nextappr := chk_workflow.get_next_approve('HRES86E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
            end if;
            --
            v_chk := 'E' ;
            v_codempid := r1.codempid;
            v_numseq := r1.numseq;
            v_numexemp := null;
            v_flgblist := null;
            v_flgssm   := null;
            FOR r_tapresrq IN c_tapresrq loop
              v_numexemp := r_tapresrq.numexemp;
              v_flgblist := r_tapresrq.flgblist;
              v_flgssm   := r_tapresrq.flgssm;
            end loop;
            --
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', '');
            obj_data.put('flg', '');
            obj_data.put('total', '');
            obj_data.put('rcnt', '');
            obj_data.put('approvno', v_appno);
            obj_data.put('chk_appr', v_chk);
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('numseq', to_char(r1.numseq));
            obj_data.put('codcomp',r1.codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('dtereq', v_dtereq);
            obj_data.put('dteeffec', v_dteeffec);
            obj_data.put('codexemp', r1.codexemp);
            obj_data.put('desc_codexemp', get_tcodec_name('TCODEXEM',r1.codexemp,global_v_lang));
            obj_data.put('status', v_staappr);
            obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
            obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('remark', r1.remarkap);
            obj_data.put('desc_codempap', v_nextappr);
            obj_data.put('staappr', r1.staappr);
            obj_data.put('numexemp', v_numexemp);
            obj_data.put('flgblist', v_flgblist);
            obj_data.put('flgssm', v_flgssm);
            obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_tab1(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_tresreq     tresreq%rowtype;
  begin
    begin
      select *
        into v_tresreq
        from tresreq
       where codempid = p_codempid
         and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq   = p_numseq;
    exception when no_data_found then
      null;
    end;
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codempid',nvl(v_tresreq.codempid,''));
    obj_row.put('desc_codempid', nvl(get_temploy_name(v_tresreq.codempid,global_v_lang),' '));
    obj_row.put('dtereq',nvl(to_char(v_tresreq.dtereq,'dd/mm/yyyy'),' '));
    obj_row.put('dteeffec',nvl(to_char(v_tresreq.dteeffec,'dd/mm/yyyy'),' '));
    obj_row.put('codexemp',nvl(v_tresreq.codexemp,' '));
    obj_row.put('desc_codexemp',nvl(get_tcodec_name('TCODEXEM',v_tresreq.codexemp,global_v_lang),' '));
    obj_row.put('desnote',nvl(v_tresreq.desnote,' '));

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_tab2(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_tresreq    tresreq%rowtype ;
    v_tresintw   tresintw%rowtype;
    v_codpos     tpostn.codpos%type;
    v_run        number;
    v_intdate    varchar2(50 char);
  begin
    begin
      select codpos
        into v_codpos
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then null;
    end;

    begin
      select *
        into v_tresreq
        from tresreq
       where codempid = p_codempid
         and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq   = to_number(p_numseq);
    exception when no_data_found then
        null;
    end;
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codempid',nvl(v_tresreq.codempid,''));
    obj_row.put('desc_codempid', nvl(get_temploy_name(v_tresreq.codempid,global_v_lang),' '));
    obj_row.put('codpos',nvl(v_codpos,' '));
    obj_row.put('desc_codpos',nvl(get_tpostn_name(v_codpos,global_v_lang),' '));
    obj_row.put('intwno',nvl(v_tresreq.intwno,' ') );

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_table_tab2(json_str_output out clob) as
    obj_row       json_object_t;
    obj_row2      json_object_t;
    obj_row3      json_object_t;
    obj_data      json_object_t;
    obj_data2     json_object_t;
    obj_data3     json_object_t;
    v_row         number;
    v_row2        number;
    v_row3        number;
    v_namcate     TEXINTWS.namcatet%type;
    v_intwno      varchar2(100 char);
    v_numcate_c1  number;
    v_numcate_c2  number;
    v_numseq      number;
    v_asci_chr    number;
    cursor c1 is
      select distinct a.numcate,b.intwno
        from tresintw a, tresreq b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and a.numseq   = p_numseq
         and a.codempid = p_codempid;
--      and b.staappr  = 'Y';
    cursor c2 is
    select a.dtereq,a.numseq,a.numqes,a.details,a.response ans,a.typeques,a.numcate,b.intwno
      from tresintw a, tresreq b
     where a.codempid = b.codempid
       and a.dtereq   = b.dtereq
       and a.numseq   = b.numseq
       and a.codempid = p_codempid
       and a.numseq   = p_numseq
       and a.numcate = v_numcate_c1;
--      and b.staappr  = 'Y';
     cursor c3 is
      select NUMANS,decode(global_v_lang, '101', detailse,
                                     '102', detailst,
                                     '103', details3,
                                     '104', details4,
                                     '105', details5,
                                     detailse) description
            from texintwc
           where intwno  = v_intwno
             and numcate = v_numcate_c2
             and numseq  = v_numseq;
  begin
    obj_row := json_object_t();
    v_row := 0;
    for r1 in c1 loop
        begin
          select decode(global_v_lang, '101', namcatee,
                                       '102', namcatet,
                                       '103', namcate3,
                                       '104', namcate4,
                                       '105', namcate5,
                                       namcatee)
            into v_namcate
            from TEXINTWS
           where INTWNO = r1.intwno
             and NUMCATE = r1.numcate;
        end;
        v_numcate_c1 := r1.numcate;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');

        obj_data.put('numcate', v_namcate);
        obj_data.put('numcateno', r1.numcate);
        v_row2 := 0;
        obj_row2 := json_object_t();
        for r2 in c2 loop
          obj_data2 := json_object_t();
          obj_data2.put('details', r2.details);
          obj_data2.put('numqes', r2.numqes);
          obj_data2.put('response', r2.ans);
          obj_data2.put('typeques', r2.typeques);

          v_intwno      := r1.intwno;
          v_numcate_c2  := r2.numcate;
          v_numseq      := r2.numqes;
          v_row3 := 0;
          obj_row3 := json_object_t();
          v_asci_chr := 65;
          for r3 in c3 loop
            obj_data3 := json_object_t();
            obj_data3.put('numseq', r3.numans);
            obj_data3.put('choice', CHR(v_asci_chr));
            obj_data3.put('desc_choice', r3.description);
            obj_row3.put(to_char(v_row3), obj_data3);
            v_row3 := v_row3 + 1;
            v_asci_chr := v_asci_chr + 1;
          end loop;
          obj_data2.put('choices',obj_row3);
          obj_row2.put(to_char(v_row2), obj_data2);
          v_row2 := v_row2 + 1;
        end loop;
        obj_data.put('numitem', obj_row2);
        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_table_tab2(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_submit(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    json_obj          json_object_t;
    v_intdate         varchar2(50 char);
    v_intdate2        varchar2(50 char);
    v_intdate3        varchar2(50 char);
    v_dtereq          date;
    v_codempid        temploy1.codempid%type;
    v_codappid        temploy1.codempid%type;
    v_name            varchar2(100 char);
    v_appseq          number;
    v_numseq          varchar2(100 char);
    v_status          varchar2(100 char);
    v_remark          varchar2(500 char);
    v_dteappr         varchar2(20 char);
    v_numexemp        tapresrq.numexemp%type;
    v_flgblist        tapresrq.flgblist%type := 'N';
    v_flgssm          tapresrq.flgssm%type;
    v_tresreq         tresreq%rowtype;
    v_remarkap        varchar2(2000);
    CURSOR c2 IS
      SELECT codappr , get_temploy_name(codappr,global_v_lang) app_name,
             to_char(dtereq,'dd/mm/yyyy') dtereq,approvno,
             to_char(dteappr ,'dd/mm/yyyy') dteappr,staappr,remark,
             numexemp ,flgblist ,flgssm
       FROM  tapresrq
       WHERE codempid = p_codempid
         AND dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
         AND numseq   = p_numseq
         AND approvno < p_appseq
       ORDER BY codempid,approvno;

  begin
    v_codappid            := pdk.check_codempid(global_v_coduser);
    v_name                := get_temploy_name(v_codappid,global_v_lang);
    v_intdate             := to_char(sysdate,'dd/mm/yyyy');

    begin
    v_intdate := to_char(sysdate,'DD/MM/YYYY');
    end;

    if p_appseq > 1 then
      for r1 in c2 loop
         v_remarkap := replace(r1.remark,chr(10),' ');
         v_numexemp := r1.numexemp;
         v_flgblist := r1.flgblist;
         v_flgssm   := r1.flgssm;
         v_remark   := replace(r1.remark,CHR(13),' ');
      end loop;
    else
      BEGIN
        SELECT *
          INTO v_tresreq
          FROM tresreq
         WHERE codempid = p_codempid
           AND dtereq   = p_dtereq
           AND numseq   = p_numseq ;
        EXCEPTION when others then null;
      END ;
    end if;

--    obj_row := json_object_t();
--    obj_row.put('coderror', '200');
--    obj_row.put('codempid',nvl(p_codempid,''));
--    obj_row.put('desc_codempid', nvl(get_temploy_name(p_codempid,global_v_lang),' '));
--    obj_row.put('approvno',nvl(p_appseq,' '));
--    obj_row.put('codappr',nvl(v_codappid,' '));
--    obj_row.put('desc_codappr',nvl(v_name,' '));
--    obj_row.put('numexemp',nvl(v_numexemp,' ') );
--    obj_row.put('flgblist', nvl(to_char(v_flgblist),' '));
--    obj_row.put('flgssm', nvl(to_char(v_flgssm),' '));
--    obj_row.put('staappr',nvl(p_staappr,''));
--    obj_row.put('status', nvl(get_tlistval_name('ESSTAREQ',p_staappr,global_v_lang),' '));
--    obj_row.put('remark',nvl(v_remark,' '));

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codempid',nvl(p_codempid,''));
    obj_row.put('desc_codempid', nvl(get_temploy_name(p_codempid,global_v_lang),' '));
    obj_row.put('approvno',nvl(p_appseq,' '));
    obj_row.put('codappr',nvl(v_codappid,' '));
    obj_row.put('desc_codappr',nvl(v_name,' '));
    obj_row.put('numexemp',nvl(v_numexemp,' ') );
    obj_row.put('flgblist', nvl(to_char(v_flgblist),' '));
    obj_row.put('flgssm', nvl(to_char(v_flgssm),' '));
    obj_row.put('staappr',nvl(p_staappr,''));
    obj_row.put('status', nvl(get_tlistval_name('ESSTAREQ',p_staappr,global_v_lang),' '));
    obj_row.put('remark',nvl(v_remark,' '));
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_detail_submit(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_submit(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_empinfo(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_codpos      temploy1.codpos%type;
    v_codcomp     temploy1.codcomp%type;
    v_dteempmt    temploy1.dteempmt%type;
    v_dteeffex    temploy1.dteeffex%type;
  begin
    begin
      select codpos,codcomp,dteempmt,dteeffex
        into v_codpos,v_codcomp,v_dteempmt,v_dteeffex
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then null;
    end;
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codempid',nvl(p_codempid,''));
    obj_row.put('desc_codempid', nvl(get_temploy_name(p_codempid,global_v_lang),' '));
    obj_row.put('desc_codcomp',nvl(get_tcenter_name(v_codcomp,global_v_lang),''));
    obj_row.put('desc_codpos',nvl(get_tpostn_name(v_codpos,global_v_lang),' '));
    obj_row.put('dteempmt',nvl(to_char(v_dteempmt,'dd/mm/yyyy'),' '));
    obj_row.put('dteresig',nvl(to_char(v_dteeffex,'dd/mm/yyyy'),' '));

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_empinfo(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_empinfo(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab1(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number := 0;
    cursor c1 is
       select 'HRES71E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tmedreq a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES71E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES71E')))
          union all
          --- HRES74E
          select 'HRES74E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tobfreq a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES74E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES74E')))
          union all
          --- HRES77E
          select 'HRES77E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tloanreq a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES77E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES77E')))
          union all
          --- HRES32E
          select 'HRES32E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tempch a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES32E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES32E')))
          --- HRES36E
          union all
          select 'HRES36E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from trefreq a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES36E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES36E')))
          --- HRES62E
          union all
          select 'HRES62E' codapp,a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
          from tleaverq a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES62E',codempid,dtereq,a.SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES62E')))
          --- 'HRES6AE'
          union all
          select 'HRES6AE' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from ttimereq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES6AE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6AE')))
          --- 'HRES34E'
          union all
          select 'HRES34E' codapp,  a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tmovereq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES34E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES34E')))
          ---- HRES6DE
          union all
          select 'HRES6DE' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
          from tworkreq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES6DE',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6DE')))
          ---- 'HRES6IE'
          union all
          select 'HRES6IE' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
          from tworkreq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES6IE',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6IE')))
          --- 'HRES6KE'
          union all
          select 'HRES6KE' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
          from tworkreq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES6KE',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6KE')))
          --- 'HRES81E'
          union all
          select 'HRES81E' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
          from tworkreq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES81E',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES81E')))
          union all
          --- 'HRES86E'
          select 'HRES86E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tresreq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES86E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES86E')))
          union all
          --- 'HRES88E'
          select 'HRES88E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tjobreq a,twkflowh b
           where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES88E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES88E')))
          union all
          --- 'HRESS2E'
          select 'HRESS2E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tjobreq a,twkflowh b
           where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRESS2E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRESS2E')))
          union all
          -- HRES3BE
          select 'HRES3BE' codapp, a.codempid, a.dtecompl dtereq,null numseq, a.stacompl staappr, null remark
          from tcompln a,twkflowh b
          where a.routeno = b.routeno
          and a.stacompl in ('N','D')
          and 'Y' = chk_workflow.check_privilege('HRES3BE',a.codempid,a.dtecompl,a.numcomp,1,p_codempid)
          union all
          -- HRESS4E
          select 'HRESS4E' codapp,  a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from tircreq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRESS4E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRESS4E')))
          union all
          --- HRES6ME
          select 'HRES6ME' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
          from tleavecc a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES6ME',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6ME')))
          union all
          --- HRES95E
          select 'HRES95E' codapp,a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from treplacerq a,twkflowh b
          where  a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES6ME',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6ME')))
          --- 'HRES91E'
          union all
          select 'HRES91E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          from ttrncerq a,twkflowh b
          where a.routeno = b.routeno
          and staappr in ('P','A')
          and ('Y' = chk_workflow.check_privilege('HRES91E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
          or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
          from twkflowde c
          where c.routeno  = a.routeno
          and c.codempid = p_codempid)
          and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES91E')));

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codapp',r1.codapp);
      obj_data.put('desc_codapp',nvl(get_tappprof_name(r1.codapp,1,global_v_lang),''));
      obj_data.put('image',get_emp_img(r1.codempid));
      obj_data.put('codempid',r1.codempid);
      obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('numseq',r1.numseq);
      obj_data.put('staappr',r1.staappr);
      obj_data.put('desc_staappr',GET_TLISTVAL_NAME('STAAPPR',r1.staappr,global_v_lang));
      obj_data.put('remark',r1.remark);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab1(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab2(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number := 0;
    cursor c1 is
        select dtelonst,numcont,get_ttyploan_name(codlon,global_v_lang) codlon,
        amtlon,nvl(amtnpfin,0)+nvl(amtintovr,0) balance,numlon,
        qtyperiod,qtyperip
        from tloaninf
        where amtnpfin <> 0
        and staappr = 'Y'
        and STALON <> 'C'
        and codempid = p_codempid;
  begin

    obj_row  := json_object_t();
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtelonst', to_char(r1.dtelonst, 'dd/mm/yyyy'));
      obj_data.put('numcont', r1.numcont);
      obj_data.put('codlon', r1.codlon);
      obj_data.put('amtlon',r1.amtlon);
      obj_data.put('balance',r1.balance);
      obj_data.put('numlon',r1.numlon);
      obj_data.put('qtyperiod',r1.qtyperiod);
      obj_data.put('qtyperip',r1.qtyperip);

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab2(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab3(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number := 0;
    cursor c1 is
      select qtyrepaym,amtrepaym,decode(dtestrpm, null, null,substr(dtestrpm,7,5)||'/'||substr(dtestrpm,5,2)||'/'||substr(dtestrpm,1,4)) dtestrpm,
             amtoutstd,amtoutstd - amttotpay balance,qtypaid,decode(dtelstpay, null, null,substr(dtelstpay,7,5)||'/'||substr(dtelstpay,5,2)||'/'||substr(dtelstpay,1,4) ) dtelstpay
        from trepay
       where codempid = p_codempid
         and dteappr = ( select max(dteappr)
                           from trepay
                          where codempid = p_codempid
                            and dteappr <= sysdate );
  begin
    obj_row  := json_object_t();
    obj_row.put('coderror', '200');
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_row.put('qtyrepaym',nvl(r1.qtyrepaym,0));
      obj_row.put('qtypaid',nvl(r1.qtypaid,0));
      obj_row.put('dtestrpm',nvl(r1.dtestrpm,0));
      obj_row.put('dtelstpay',nvl(r1.dtelstpay,0));
      obj_row.put('amtrepaym',nvl(r1.amtrepaym,0));
      obj_row.put('amtoutstd',nvl(r1.balance,0));
      obj_row.put('balance',nvl(r1.amtoutstd,0));
      obj_data.put('balance',nvl(r1.balance,0));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab3(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab4(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number := 0;
    cursor c1 is
--      select get_tfundinf_name(codsco,global_v_lang) typdesc,
--             desccomm desccom,descript1,qtymth,dtestartf,dteendf
--        from tfunddet
--       where dteendf <=  nvl(p_dteeffex-1,trunc(sysdate))
--         and codempid = p_codempid
--      union all
      select get_tcourse_name(t1.codcours,global_v_lang) typdesc,
             t2.descommt desccom,null descript1,null qtymth,null dtestartf,null dteendf
        from thistrnn t1,tcourse t2
       where t1.codcours = t2.codcours
--         and flgcommt = 'Y'
         and codempid = p_codempid;
  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('typdesc', r1.typdesc);
      obj_data.put('desccom', r1.desccom);
      obj_data.put('descript1', r1.descript1);
      obj_data.put('qtymth',TO_CHAR(r1.qtymth, '99.99'));
      obj_data.put('dtestartf',to_char( r1.dtestartf,'dd/mm/yyyy'));
      obj_data.put('dteendf',to_char(r1.dteendf,'dd/mm/yyyy'));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab4(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab4(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab5(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number := 0;

    cursor c1 is
      select t1.codasset,get_taseinf_name(t1.codasset,global_v_lang) assetname,t1.dtercass, t1.remark
        from tassets t1,tasetinf t2
       where t1.codasset = t2.codasset
         and t1.codempid = p_codempid
    order by t1.codasset,t1.dtercass;
  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codasset', r1.codasset);
      obj_data.put('assetname', r1.assetname);
      obj_data.put('dtercass', to_char(r1.dtercass, 'dd/mm/yyyy'));
      obj_data.put('remark',r1.remark);

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab5(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab5(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab6(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row			    number := 0;
		v_qtyavqwk		number;
		v_codleavev		varchar2(500 char);
		v_typleavev		varchar2(500 char);

		v_qtyvacatv		number;
		v_qtydaylev		number;
		v_balancev		number;
		v_flgdlemxv		varchar2(500 char);
		v_qtyreqv		  varchar2(500 char);

		o_qtyvacatv_d		number;
		o_qtyvacatv_h		number;
		o_qtyvacatv_m		number;
		o_qtyvacatv_dhm		varchar2(500 char);
		o_qtydaylev_d		number;
		o_qtydaylev_h		number;
		o_qtydaylev_m		number;
		o_qtydaylev_dhm		varchar2(500 char);

		o_balancev_d		number;
		o_balancev_h		number;
		o_balancev_m		number;
		o_balancev_dhm		varchar2(500 char);
		o_qtyreqv_d		number;
		o_qtyreqv_h		number;
		o_qtyreqv_m		number;
		o_qtyreqv_dhm		varchar2(500 char);

		v_codcomp		varchar2(500 char);
		v_yrecyclev		varchar2(500 char);
		v_dtecycstv		date;
		v_dtecycenv		date;
		v_dtecycstv_new		varchar2(500 char);
		v_dtecycenv_new		varchar2(500 char);

		v_codleavec		varchar2(500 char);
		v_typleavec		varchar2(500 char);
		v_qtyvacatc		number;
		v_qtydaylec		number;
		v_balancec		number;
		v_yrecyclec		varchar2(500 char);
		v_dtecycstc		date;
		v_dtecycenc		date;

		v_flgdlemxc		varchar2(500 char);
		v_qtyreqc		varchar2(500 char);
		o_qtyvacatc_d		number;
		o_qtyvacatc_h		number;
		o_qtyvacatc_m		number;
		o_qtyvacatc_dhm		varchar2(500 char);

		o_qtydaylec_d		number;
		o_qtydaylec_h		number;
		o_qtydaylec_m		number;
		o_qtydaylec_dhm		varchar2(500 char);
		o_balancec_d		number;
		o_balancec_h		number;
		o_balancec_m		number;
		o_balancec_dhm		varchar2(500 char);

		o_qtyreqc_d		number;
		o_qtyreqc_h		number;
		o_qtyreqc_m		number;
		o_qtyreqc_dhm		varchar2(500 char);
		v_dtecycstc_new		varchar2(500 char);
		v_dtecycenc_new		varchar2(500 char);

		v_count_ttemprpt	varchar2(500 char);
  begin
    begin
			select codleave,typleave
			into v_codleavev,v_typleavev
			from TLEAVECD
			where STALEAVE = 'V';
		exception when no_data_found then
			v_codleavev := null;
		end;
		begin
			select qtyvacat,qtydayle,nvl(QTYVACAT,0)-nvl(QTYDAYLE,0)
			into v_qtyvacatv,v_qtydaylev,v_balancev
			from TLEAVSUM
			where CODLEAVE = v_codleavev
			and dteyear = to_number(to_char(sysdate,'yyyy'))
			and codempid = p_codempid;
		exception when no_data_found then
			null;
		end;

		std_al.cycle_leave(hcm_util.get_codcomp_level(p_codcomp,'1'),p_codempid,'V',sysdate,v_yrecyclev,v_dtecycstv,v_dtecycenv);
		begin
			select FLGDLEMX
			into v_flgdlemxv
			from TLEAVETY
			where TYPLEAVE = v_typleavev;
		exception when no_data_found then
			null;
		end;


		if v_flgdlemxv = 'Y' then
			v_qtyreqv := 0;
		else
			v_dtecycstv_new := to_char(v_dtecycstv, 'yyyymmdd');
			v_dtecycstv_new := to_char(v_dtecycstv, 'yyyymmdd');
			begin
				select nvl(sum(qtyday),0)
				into v_qtyreqv
				from tlereqd
				where codempid = p_codempid
				and dtework between TO_DATE(v_dtecycstv_new, 'yyyymmdd' ) and TO_DATE(v_dtecycstv_new, 'yyyymmdd' )
				and codleave = v_codleavev
				and dayeupd is null;
			exception when no_data_found then
				null;
			end;
		end if;


		---------- OT ----------

		begin
			select codleave,typleave
			into v_codleavec,v_typleavec
			from tleavecd
			where staleave ='V';
		exception when no_data_found then
			v_codleavec := null;
		end;
		begin
			select qtydleot,qtydayle,nvl(qtyvacat,0)-nvl(qtydayle,0)
			into v_qtyvacatc,v_qtydaylec,v_balancec
			from tleavsum
			where codleave = v_codleavec
			and dteyear = to_number(to_char(sysdate,'yyyy'))
			and codempid = p_codempid;
		exception when no_data_found then
			null;
		end;

		std_al.cycle_leave(hcm_util.get_codcomp_level(p_codcomp,1),p_codempid,'C',sysdate,v_yrecyclec,v_dtecycstc,v_dtecycenc);
		begin
			select FLGDLEMX
			into v_flgdlemxc
			from TLEAVETY
			where TYPLEAVE = v_typleavec;
		exception when no_data_found then
			null;
		end;

		if v_flgdlemxv = 'Y' then
			v_qtyreqc := 0;
		else
			v_dtecycstc_new := to_char(v_dtecycstc, 'yyyymmdd');
			v_dtecycstc_new := to_char(v_dtecycstc, 'yyyymmdd');
			begin
				select nvl(sum(qtyday),0)
				into v_qtyreqc
				from tlereqd
				where codempid = p_codempid
				and dtework between TO_DATE(v_dtecycstc_new, 'yyyymmdd' ) and TO_DATE(v_dtecycstc_new, 'yyyymmdd' )
				and codleave = v_codleavev
				and dayeupd is null;
			exception when no_data_found then
				v_qtyreqc := 0;
			end;
		end if;
        v_qtyavqwk := HCM_UTIL.get_qtyavgwk('',p_codempid);
		--- vacation
		hcm_util.cal_dhm_hm (v_qtyvacatv, 0,0, v_qtyavqwk,'1' ,o_qtyvacatv_d,o_qtyvacatv_h,o_qtyvacatv_m,o_qtyvacatv_dhm) ;
		hcm_util.cal_dhm_hm (v_qtydaylev, 0,0, v_qtyavqwk,'1' ,o_qtydaylev_d,o_qtydaylev_h,o_qtydaylev_m,o_qtydaylev_dhm) ;
		hcm_util.cal_dhm_hm (v_balancev, 0,0, v_qtyavqwk ,'1' ,o_balancev_d,o_balancev_h,o_balancev_m,o_balancev_dhm) ;
		hcm_util.cal_dhm_hm (v_qtyreqv, 0,0, v_qtyavqwk ,'1' ,o_qtyreqv_d,o_qtyreqv_h,o_qtyreqv_m,o_qtyreqv_dhm) ;

		--- OT
		hcm_util.cal_dhm_hm (v_qtyvacatc, 0,0, v_qtyavqwk,'1' ,o_qtyvacatc_d,o_qtyvacatc_h,o_qtyvacatc_m,o_qtyvacatc_dhm) ;
		hcm_util.cal_dhm_hm (v_qtydaylec, 0,0, v_qtyavqwk,'1' ,o_qtydaylec_d,o_qtydaylec_h,o_qtydaylec_m,o_qtydaylec_dhm) ;
		hcm_util.cal_dhm_hm (v_balancec, 0,0, v_qtyavqwk ,'1' ,o_balancec_d,o_balancec_h,o_balancec_m,o_balancec_dhm) ;
		hcm_util.cal_dhm_hm (v_qtyreqc, 0,0, v_qtyavqwk ,'1' ,o_qtyreqc_d,o_qtyreqc_h,o_qtyreqc_m,o_qtyreqc_dhm) ;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('o_qtyvacat_day_vacation', o_qtyvacatv_d);
    obj_row.put('o_qtyvacat_hr_vacation', o_qtyvacatv_h);
    obj_row.put('o_qtyvacat_min_vacation', o_qtyvacatv_m);
    obj_row.put('o_qtyvacat_dhm_vacation',o_qtyvacatv_dhm);

    obj_row.put('o_qtydayle_day_vacation', o_qtydaylev_d);
    obj_row.put('o_qtydayle_hr_vacation', o_qtydaylev_h);
    obj_row.put('o_qtydayle_min_vacation', o_qtydaylev_m);
    obj_row.put('o_qtydayle_dhm_vacation',o_qtydaylev_dhm);

    obj_row.put('o_balance_day_vacation', o_balancev_d);
    obj_row.put('o_balance_hr_vacation', o_balancev_h);
    obj_row.put('o_balance_min_vacation', o_balancev_m);
    obj_row.put('o_balance_dhm_vacation',o_balancev_dhm);

    obj_row.put('o_qtyreqv_day_vacation', o_qtyreqv_d);
    obj_row.put('o_qtyreqv_hr_vacation', o_qtyreqv_h);
    obj_row.put('o_qtyreqv_min_vacation', o_qtyreqv_m);
    obj_row.put('o_qtyreqv_dhm_vacation',o_qtyreqv_dhm);

    --- OT
    obj_row.put('o_qtyvacat_day_ot', o_qtyvacatc_d);
    obj_row.put('o_qtyvacat_hr_ot', o_qtyvacatc_h);
    obj_row.put('o_qtyvacat_min_ot', o_qtyvacatc_m);
    obj_row.put('o_qtyvacat_dhm_ot',o_qtyvacatc_dhm);

    obj_row.put('o_qtydayle_day_ot', o_qtydaylec_d);
    obj_row.put('o_qtydayle_hr_ot', o_qtydaylec_h);
    obj_row.put('o_qtydayle_min_ot', o_qtydaylec_m);
    obj_row.put('o_qtydayle_dhm_ot',o_qtydaylec_dhm);

    obj_row.put('o_balance_day_ot', o_balancec_d);
    obj_row.put('o_balance_hr_ot', o_balancec_h);
    obj_row.put('o_balance_min_ot', o_balancec_m);
    obj_row.put('o_balance_dhm_ot',o_balancec_dhm);

    obj_row.put('o_qtyreqc_day_ot', o_qtyreqc_d);
    obj_row.put('o_qtyreqc_hr_ot', o_qtyreqc_h);
    obj_row.put('o_qtyreqc_min_ot', o_qtyreqc_m);
    obj_row.put('o_qtyreqc_dhm_ot',o_qtyreqc_dhm);


    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab6(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab6(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab7(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number := 0;
    v_formula       varchar2(500 char);

    cursor c1 is
        select codpay,get_tinexinf_name(codpay,global_v_lang) codpayname,periodpay,
               amtfix,dtestrt,dteend,dtecancl,stddec(amtfix,p_codempid,v_chken) amount
          from tempinc
         where nvl(dtecancl,dteend) <= sysdate
           and codempid = p_codempid;
  begin

    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      v_row := v_row + 1;
      obj_data.put('coderror', '200');
      begin
          select formula into v_formula from tformula
          where codpay = r1.codpay
          and dteeffec = (
              select max(dteeffec)
              from tformula
              where codpay = r1.codpay
              and dteeffec <= sysdate
          );
          exception when no_data_found then
              v_formula	:= null;
      end;

      obj_data.put('codpay', r1.codpay);
      obj_data.put('codpayname', r1.codpayname);
      obj_data.put('periodpay', r1.periodpay);
      obj_data.put('formula',v_formula);
      obj_data.put('formulaname',get_formula_name(v_formula,global_v_lang));
      obj_data.put('amount', r1.amount);
      obj_data.put('dtestrt',to_char(r1.dtestrt, 'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(r1.dteend, 'dd/mm/yyyy'));
      obj_data.put('dtecancl',to_char(r1.dtecancl,'dd/mm/yyyy'));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab7(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab7(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab8(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_row           number  := 0;
    v_amtpay_number number;

    cursor c1 is
        select codpay,get_tinexinf_name(codpay,global_v_lang) codpayname,amtpay,codsys,numperiod||'/'||get_tlistval_name('NAMMTHFUL',dtemthpay,'102')||'/'||(dteyrepay) period
        from tothinc
        where exists (
            select *
            from tsincexp
      where tothinc.codempid	= tsincexp.codempid
      and tothinc.dteyrepay = tsincexp.dteyrepay
      and tothinc.dtemthpay = tsincexp.dtemthpay
      and tothinc.numperiod = tsincexp.numperiod
      and tothinc.codpay = tsincexp.codpay
        )
        and codempid = p_codempid
			and dteyrepay = v_dteyrepay
			and dtemthpay = v_dtemthpay
			and numperiod = v_numperiod;
  begin
    begin
      select dteyrepay, dtemthpay, numperiod
        into v_dteyrepay,v_dtemthpay,v_numperiod
        from ttaxcur
       where codempid = p_codempid
         and dteyrepay||dtemthpay||numperiod =(
                                                select max(dteyrepay||dtemthpay||numperiod)
                                                from ttaxcur
                                                where codempid = p_codempid
                                                );
      exception when no_data_found then
           v_dteyrepay := null;
           v_dtemthpay := null;
           v_numperiod := null;
    end;
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      v_row := v_row + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codpay', r1.codpay);
      obj_data.put('codpayname', r1.codpayname);
      obj_data.put('period', r1.period);
      obj_data.put('amtpay',v_amtpay_number);
      obj_data.put('codsys',r1.codsys);

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab8(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab8(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup_tab9(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number;

    cursor c1 is
      select typcolla,get_tcodec_name('TCODCOLA',typcolla,global_v_lang) codename,descoll,
             numdocum,amtcolla,dtecolla,dtestrt,amtdedcol
      from tcolltrl
      where codempid = p_codempid
      and staded not in ('N','C')
      order by dtecolla;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      v_row := v_row + 1;
      obj_data.put('coderror', '200');
      obj_data.put('typcolla', r1.typcolla);
      obj_data.put('codename', r1.codename);
      obj_data.put('descoll', r1.descoll);
      obj_data.put('numdocum',r1.numdocum);
      obj_data.put('amtcolla',r1.amtcolla);
      obj_data.put('dtecolla',to_char(r1.dtecolla, 'dd/mm/yyyy'));
      obj_data.put('dtestrt',to_char(r1.dtestrt,'dd/mm/yyyy'));
      obj_data.put('amtdedcol',r1.amtdedcol);

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_popup_tab9(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup_tab9(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure approve(p_coduser          in varchar2,
                  p_lang             in varchar2,
                  p_total            in varchar2,
                  p_status           in varchar2,
                  p_appseq           in number,
                  p_chk              in varchar2,
                  p_codempid         in varchar2,
                  p_numseq           in number,
                  p_dtereq           in varchar2,
                  p_dteappr          in varchar2,
                  p_dteeffec         in varchar2,
                  p_numexemp         in varchar2,
                  p_flgblist         in varchar2,
                  p_flgssm           in varchar2,
                  p_remark           in varchar2,
                  param_flgwarn      in out varchar2) is

    p_amtwidrw      number;
    p_dtepay        date;
    p_numvcher      varchar2(5000 char);

    p_staappr       varchar2(400 char);

    --  Request
    rq_approvno     number ;
    v_counter       NUMBER := 0;
    v_temp          varchar2(200 char);
    v_select        VARCHAR2(500 char);
    v_staappr       VARCHAR2(1 char);
    v_autonum       VARCHAR2(15 char);
    v_numvcher      tobfinf.numvcher%TYPE;
    v_pay           VARCHAR2(1 char);
    v_py            VARCHAR2(1 char);
    v_limit         varchar2(1 char):= 'A';
    v_numtsmit      NUMBER;
    v_year          varchar2(15 char);
    v_approv        temploy1.codempid%type;
    v_desc          varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 ||
    v_tobfreq       tobfreq%ROWTYPE;
    v_dtestrt       DATE ;
    v_dteend        DATE;
    v_qty_min       NUMBER;
    v_qty_day       NUMBER;
    v_dtesmit       date;
    v_appseq        number;
    v_amtwidrw      NUMBER;
    v_appnochk      varchar2(10 char);
    v_run           NUMBER;

    v_dtereq        VARCHAR2(200 char);
    v_codcomp       temploy1.codcomp%type;
    v_typemp        temploy1.typemp%type;
    v_codempmt      temploy1.codempmt%type;
    v_numlvl        temploy1.numlvl%type;
    v_codpos        temploy1.codpos%type;
    v_staemp        temploy1.staemp%type;
    v_qtywkday      temploy1.dteempmt%type;
    v_dteeffex      temploy1.dteeffex%type;
    v_amtincom1     temploy3.amtincom1%type;
    v_jobgrade      varchar2(4);
    v_stamarry      varchar2(4);
    v_codsex        varchar2(4);

    v_codempid      temploy1.codempid%type;
    v_codappid      temploy1.codempid%type;
    v_name          varchar2(100 char);
    v_remark        varchar2(6000 char):= replace(replace(p_remark,'^$','&'),'^@','#');
    v_status        varchar2(100 char);

    v_appno         owa_util.ident_arr;
    v_stappr        owa_util.ident_arr;
    v_id            owa_util.ident_arr;
    v_date          owa_util.ident_arr;

    v_zyear         number ;
    v_app_pass      varchar2(1 char) := 'N';
    --check_cft---
    v_obfsum        NUMBER(10,2);
    v_obfinf        NUMBER(10,2);
    v_amtt          NUMBER;
    v_amt           number;
    v_qty           NUMBER;
    acc_amt         number(10,2);
    acc_qty         NUMBER(10,2);

    --  Request
    rq_chk        varchar2(3 char);
    rq_seqno      NUMBER ;
    rq_temp       VARCHAR2(200 char);
    rq_dteeffec   DATE;
    rq_dtereq     DATE;
    rq_codempid   temploy1.codempid%type;

    --  Approve
    ap_approvno   NUMBER := NULL;

    --  Values
    v_count       NUMBER :=0;
    v_date        VARCHAR2(100 char);
    v_approvno    NUMBER := NULL;
    v_codeappr    temploy1.codempid%type;
    v_codempid    temploy1.codempid%type;

    p_error       VARCHAR2(10 char);
    p_codappr     temploy1.codempid%type := pdk.Check_Codempid(p_coduser);
    p_date        DATE;
    v_flag        VARCHAR2(1 char) := 'Y';
    v_tresreq     tresreq%ROWTYPE;
    v_temploy1    temploy1%ROWTYPE;
    v_temploy3    temploy3%ROWTYPE;
    v_amtincoma   VARCHAR2(20 char);
    v_totwkday    NUMBER;

    v_msg_to      VARCHAR2(7000 char) ;
    v_msg_cc      VARCHAR2(7000 char) ;
    v_msg_not     VARCHAR2(7000 char) ;
    msg_error     VARCHAR2(10 char) ;
    v_codempap    temploy1.codempid%type;
    v_codcompap   tcenter.codcomp%type;
    v_codposap    tpostn.codpos%type;
    v_dtereq      varchar2(200 char);
    v_numseq      number := 0;
    rq_numseq     number ;
    v_max_approv number;
    v_row_id     varchar2(200 char);

  begin
    begin
      v_staappr   := p_status;
      v_remark    := p_remark;
      v_remark    := replace(v_remark,'.',chr(13));
      v_remark    := replace(replace(v_remark,'^$','&'),'^@','#');
      rq_codempid := p_codempid;
      rq_dtereq   := p_dtereq;
      rq_numseq   := p_numseq;
      rq_dteeffec := p_dteeffec;
      ap_approvno := p_appseq;
    end ;

    -----check_index-----
    --Step 1 => Check Data
    begin
     select *
       into v_tresreq
       from tresreq
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = rq_numseq;
     exception when no_data_found then
        v_tresreq := null;
    end;
    begin
      select approvno into v_max_approv
      from   twkflowh
      where  routeno = v_tresreq.routeno ;
    exception when no_data_found then
      v_max_approv := 0 ;
    end ;

    -- Step 2 => Insert Table Request Detail
    begin
      select count(*)
        into v_count
        from tapresrq
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq
         and approvno = ap_approvno;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then
      insert into tapresrq(codempid,dtereq,numseq,approvno,
                          codappr,dteappr,staappr,
                          remark,coduser,dteupd ,
                          flgblist ,numexemp ,flgssm,
                          dterec, dteapph,
                          codcreate --04/10/2021
                          )
                  values (rq_codempid,rq_dtereq,rq_numseq,ap_approvno,
                          p_codappr,p_dteappr,v_staappr,
                          v_remark,p_coduser,trunc(sysdate),
                          p_flgblist ,p_numexemp ,p_flgssm,
                          nvl(v_tresreq.dtesnd,sysdate),sysdate,
                          p_coduser --04/10/2021
                          );
    else
      update tapresrq
         set staappr   = v_staappr,--rq_chk,
             codappr   = p_codappr,
             dteappr   = p_dteappr,
             coduser   = p_coduser,
             remark    = v_remark,
             dteupd    = trunc(sysdate),
             flgblist  = p_flgblist ,
             numexemp  = p_numexemp ,
             flgssm    = p_flgssm,
             dterec    =  nvl(v_tresreq.dtesnd,sysdate),
             dteapph   = sysdate
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq
         and approvno = ap_approvno ;
    end if;

    -- Step 3 => Check Next Step
    v_codeappr  := p_codappr ;
    v_approvno  := p_appseq ;

    chk_workflow.find_next_approve('HRES86E',v_tresreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

    if  p_status = 'A' and rq_chk <> 'E' then
      loop
        v_approv := chk_workflow.check_next_step('HRES86E',v_tresreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
        if v_approv is not null then
          v_remark   := v_desc; -- user22 : 04/07/2016 : STA4590287 ||
          v_approvno := v_approvno + 1 ;
          v_codeappr := v_approv ;
          begin
            select count(*)
              into v_count
              from tapresrq
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and approvno = v_approvno;
            exception when no_data_found then
                 v_count := 0;
          end;
          if v_count = 0 then
            insert into tapresrq(codempid,dtereq,numseq,approvno,
                                 codappr,dteappr,staappr,
                                 remark,coduser,dteupd ,
                                 flgblist ,numexemp ,flgssm,
                                 dterec, dteapph,
                                 codcreate --04/10/2021
                                 )
                         values (rq_codempid,rq_dtereq,rq_numseq,ap_approvno,
                                 p_codappr,p_dteappr,p_staappr,
                                 v_remark,p_coduser,trunc(sysdate),
                                 p_flgblist ,p_numexemp ,p_flgssm,
                                 sysdate,sysdate,
                                 p_coduser --04/10/2021
                                 );
          else
            update tapresrq
               set staappr   = 'A',
                   codappr   = p_codappr,
                   dteappr   = p_dteappr,
                   coduser   = p_coduser,
                   remark    = v_remark,
                   dterec   =  sysdate,
                   dteapph  =  sysdate
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and approvno = ap_approvno ;
          end if;
          chk_workflow.find_next_approve('HRES86E',v_tresreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA4590287 || v_approv := chk_workflow.Check_Next_Approve('HRES86E',v_tresreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
        else
          exit ;
        end if;
      end loop ;
      update tresreq
         set approvno  = v_approvno ,
             codappr   = v_codeappr,
             dteappr   = p_dteappr,
             staappr   = 'A',
             remarkap  = v_remark,
             coduser   = p_coduser,
             dteupd    = trunc(sysdate),
             dteapph   = sysdate
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq;
    end if;

    -- Step 4 => Update Table Request and Insert Transaction
    if v_max_approv = v_approvno then
      rq_chk := 'E' ;
    end if;
    v_staappr := p_status ;
    if rq_chk = 'E' and p_status = 'A' then
      v_staappr := 'Y';
      begin
        select *
          into v_temploy1
          from temploy1
         where codempid = rq_codempid;
      exception when no_data_found then
        v_temploy1 := null;
      end;

      begin
        select *
          into v_temploy3
          from temploy3
         where codempid = rq_codempid;
      exception when no_data_found then
        v_temploy3 := null;
      end;

      begin
        select *
          into v_tresreq
          from tresreq
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq;
      exception when no_data_found then
        v_tresreq := null;
      end;

      begin
        select count(*)
          into v_count
          from ttexempt
         where codempid = rq_codempid
           and dteeffec = rq_dteeffec;
        exception when no_data_found then
             v_count := 0;
      end;

      if v_count = 0 then
        v_amtincom1  := stddec(v_temploy3.amtincom1,rq_codempid,v_chken);
        v_amtincoma  := stddec(v_temploy3.amtincom2,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom3,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom4,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom5,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom6,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom7,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom8,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom9,rq_codempid,v_chken)
                      + stddec(v_temploy3.amtincom10,rq_codempid,v_chken);

        v_amtincom1   := stdenc(round(v_amtincom1,2),rq_codempid,v_chken);
        v_amtincoma   := stdenc(round(v_amtincoma,2),rq_codempid,v_chken);
        v_totwkday    := (rq_dteeffec - v_temploy1.dteempmt) + nvl(v_temploy1.qtywkday,0);

        insert into ttexempt(codempid,dteeffec,codcomp,codjob,codpos,
                            codempmt,numlvl,codexemp,numexemp,typdoc,
                            numannou,desnote,amtsalt,amtotht,codsex,
                            codedlv,totwkday,flgblist,staupd,flgrp,
                            flgssm,codappr,dteappr,remarkap,
                           coduser,dteupd,codreq,
                           codcreate --04/10/2021
                           )
                    values
                          (rq_codempid,rq_dteeffec,v_temploy1.codcomp,v_temploy1.codjob,v_temploy1.codpos,
                           v_temploy1.codempmt,v_temploy1.numlvl,v_tresreq.codexemp,null,null,
                           null,v_tresreq.desnote,v_amtincom1,v_amtincoma,v_temploy1.codsex,
                           v_temploy1.codedlv,v_totwkday,p_flgblist,'P','N',
                           p_flgssm,p_codappr,p_dteappr,v_remark,
                           p_coduser,trunc(sysdate),v_codeappr,
                           p_coduser --04/10/2021
                           );
      else
        update ttexempt
           set codappr   = p_codappr,
               dteappr   = p_dteappr,
               coduser   = p_coduser,
               remarkap  = v_remark,
               dteupd    = trunc(sysdate)
         where  codempid  = rq_codempid
           and  dteeffec  = rq_dteeffec;
      end if;
    end if;

    update tresreq
       set staappr   = v_staappr,
           codappr   = v_codeappr,
           approvno  = v_approvno,
           dteappr   = p_dteappr,
           coduser   = p_coduser,
           dteupd    = trunc(sysdate),
           remarkap  = v_remark,
           dteapph   = sysdate
     where codempid = rq_codempid
       and dtereq   = rq_dtereq
       and numseq   = rq_numseq;
    commit;

    -- Step 5 => Send Mail
    begin
      select rowid
        into v_row_id
        from tresreq
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq;
    exception when no_data_found then
        v_tresreq := null;
    end;

    begin 
      chk_workflow.sendmail_to_approve( p_codapp        => 'HRES86E',
                                        p_codtable_req  => 'tresreq',
                                        p_rowid_req     => v_row_id,
                                        p_codtable_appr => 'tapresrq',
                                        p_codempid      => rq_codempid,
                                        p_dtereq        => rq_dtereq,
                                        p_seqno         => rq_numseq,
                                        p_staappr       => v_staappr,
                                        p_approvno      => v_approvno,
                                        p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                        p_subject_mail_numseq  => '80',
                                        p_lang          => global_v_lang,
                                        p_coduser       => global_v_coduser);
    exception when others then
      param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
    end;

  EXCEPTION WHEN others THEN
    ROLLBACK ;
     param_sqlerrm := sqlerrm;
  end;  -- Procedure Approve
  --
  procedure process_approve(json_str_input in clob, json_str_output out clob) is
    json_obj              json_object_t;
    json_obj2             json_object_t;

    v_coduser             varchar2(100 char);
    v_remark_appr         varchar2(4000 char);
    v_remark_not_appr     varchar2(4000 char);

    v_rowcount      number:= 0;
    v_staappr       varchar2(400);
    v_appseq        number;
    v_chk           varchar2(10);
    v_numseq        number;
    v_codempid      varchar2(400);
    v_dtereq        varchar2(400);
    v_dteappr       varchar2(400);
    v_dteeffec      varchar2(400);
    v_numexemp      varchar2(400);
    v_flgblist      varchar2(400);
    v_flgssm        varchar2(400);
    v_remark        varchar2(4000);
    errm_str        varchar2(4000);
    resp_obj        json_object_t :=  json_object_t();
    resp_str        varchar2(4000 char);
    param_flgwarn   varchar2(200);

  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');
    v_rowcount := json_obj.get_size;

--    for i in 0..json_obj.count-1 loop
--      json_obj2   := json(json_obj.get(to_char(i)));
      v_staappr   := hcm_util.get_string_t(json_obj, 'p_staappr');
      v_appseq    := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
      v_chk       := hcm_util.get_string_t(json_obj, 'p_chk_appr');
      v_numseq    := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
      v_codempid  := hcm_util.get_string_t(json_obj, 'p_codempid');

      v_dtereq    := to_date(hcm_util.get_string_t(json_obj, 'p_dtereq'),'dd/mm/yyyy');
      v_dteappr   := to_date(hcm_util.get_string_t(json_obj, 'p_dteappr'),'dd/mm/yyyy');
      v_dteeffec  := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'),'dd/mm/yyyy');
      v_numexemp  := hcm_util.get_string_t(json_obj, 'p_numexemp');
      v_flgblist  := hcm_util.get_string_t(json_obj, 'p_flgblist');
      v_flgssm    := hcm_util.get_string_t(json_obj, 'p_flgssm');
      param_flgwarn  := hcm_util.get_string_t(json_obj, 'p_flgwarn');

      v_staappr := nvl(v_staappr, 'A');
      if v_staappr = 'A' then
         v_remark := p_remark_appr;
      elsif v_staappr = 'N' then
         v_remark := p_remark_not_appr;
      end if;
      approve(global_v_coduser,global_v_lang,to_char(v_rowcount),v_staappr,v_appseq,v_chk,v_codempid,
              v_numseq,v_dtereq,v_dteappr,v_dteeffec,v_numexemp,v_flgblist,v_flgssm,v_remark,param_flgwarn);

    if param_msg_error is not null then
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      if param_msg_error_mail is not null then
        json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_approve;
  --
  procedure datatest(json_str in clob) as
    json_obj    json_object_t  := json_object_t(json_str);

    v_flgcreate varchar2(4000 char);
    v_coduser   varchar2(4000 char);
    v_codcomp   varchar2(4000 char);
    v_codempid  varchar2(4000 char);
    v_numseq    number;
    v_dtereq    date;
    v_routeno   varchar2(4000 char);
  begin
    v_flgcreate := hcm_util.get_string_t(json_obj,'p_flgcreate');
    v_coduser   := hcm_util.get_string_t(json_obj,'p_coduser');
    v_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    v_codempid  := hcm_util.get_string_t(json_obj,'p_codempid');
    v_numseq    := to_number(hcm_util.get_string_t(json_obj,'p_dataseed'));
    v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy hh24.mi.ss');
    v_routeno   := hcm_util.get_string_t(json_obj,'p_routeno');

    if v_flgcreate = 'Y' or v_flgcreate = 'N' then
      delete tresreq
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and numseq   = v_numseq;

      delete tapresrq
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and numseq   = v_numseq;

      delete ttexempt
       where codempid = v_codempid
         and dteeffec = v_dtereq;
    end if;

    if v_flgcreate = 'Y' then
      insert into tresreq
        (codempid,dtereq,numseq,dteeffec,
        codexemp,desnote,intwno,staappr,
        codappr,dteappr,remarkap,approvno,
        routeno,
        codcomp,flgsend,dtecancel,dteinput,
        dtesnd,dteupd,coduser,dteapph,
        flgagency,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,v_dtereq,
        '0001','test-remark','A001','P',
        null,null,null,0,
        v_routeno,
        v_codcomp,null,null,sysdate,
        null,sysdate,v_coduser,null,
        null,
        global_v_coduser --04/10/2021
        );

      insert into tresintw
        (codempid,dtereq,numseq,numqes,
        details,response,dteupd,coduser,
        typeques,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,1,
        'test','1',sysdate,v_coduser,
        '2',
        global_v_coduser --04/10/2021
        );
      insert into tresintw
        (codempid,dtereq,numseq,numqes,
        details,response,dteupd,coduser,
        typeques,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,2,
        'test','2',sysdate,v_coduser,
        '2',
        global_v_coduser --04/10/2021
        );
      insert into tresintw
        (codempid,dtereq,numseq,numqes,
        details,response,dteupd,coduser,
        typeques,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,3,
        'test','3',sysdate,v_coduser,
        '2',
        global_v_coduser --04/10/2021
        );
      insert into tresintw
        (codempid,dtereq,numseq,numqes,
        details,response,dteupd,coduser,
        typeques,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,4,
        'test','test-ans4',sysdate,v_coduser,
        '1',
        global_v_coduser --04/10/2021
        );
      insert into tresintw
        (codempid,dtereq,numseq,numqes,
        details,response,dteupd,coduser,
        typeques,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,5,
        'test','1',sysdate,v_coduser,
        '2',
        global_v_coduser --04/10/2021
        );

      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,1,
        1,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,1,
        '','','','',
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,1,
        3,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,1,
        4,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,2,
        1,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,2,
        2,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,2,
        3,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,3,
        1,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,3,
        2,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,3,
        3,null,'test',null,
        null,null,sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,5,
        1,'a','test','a',
        'a','a',sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,5,
        2,'b','test','b',
        'b','b',sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,5,
        3,'c','test','c',
        'c','c',sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
      insert into tresintwc
        (codempid,dtereq,numseq,numqes,
        numans,detailse,detailst,details3,
        details4,details5,dteupd,coduser,
        codcreate --04/10/2021
        )
      values
        (v_codempid,v_dtereq,v_numseq,5,
        4,'d','test','d',
        'd','d',sysdate,v_coduser,
        global_v_coduser --04/10/2021
        );
    end if;

    commit;
  end;
  function get_formula_name(v_formula in varchar2,v_lang in varchar2) return varchar2 is
     cursor c1 is
               select codpay
                     from tinexinf
             order by codpay;
             v_formulaname clob;
  begin
            v_formulaname := v_formula ;
            for i in c1 loop
                v_formulaname     := replace(v_formulaname,'&'||i.codpay,get_tinexinf_name(i.codpay,v_lang));
            end loop;
            return v_formulaname;
  end get_formula_name;
end;

/
