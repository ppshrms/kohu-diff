--------------------------------------------------------
--  DDL for Package Body HRRC1JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC1JE" AS
  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin
--  get index parameter
        p_codcomp           := upper(hcm_util.get_string_t(data_obj,'p_codcomp'));
        p_numreqst          := hcm_util.get_string_t(data_obj,'p_numreqst');
        p_codpos            := hcm_util.get_string_t(data_obj,'p_codpos');
--  save index parameter
        p_query_codempid    := hcm_util.get_string_t(data_obj,'p_query_codempid');
        p_codappchse        := hcm_util.get_string_t(data_obj,'p_codappchse');
        p_codtran           := hcm_util.get_string_t(data_obj,'p_codtran');
        p_dteeffec          := to_date(hcm_util.get_string_t(data_obj,'p_dteeffec'), 'dd/mm/yyyy');
        p_staappr           := hcm_util.get_string_t(data_obj,'p_staappr');
        p_codconfrm         := hcm_util.get_string_t(data_obj,'p_codconfrm');
        p_dteconfrm         := to_date(hcm_util.get_string_t(data_obj,'p_dteconfrm'), 'dd/mm/yyyy');
        p_codtran           := hcm_util.get_string_t(data_obj,'p_codtran');
        p_qtyduepr          := to_number(hcm_util.get_string_t(data_obj,'p_qtyduepr'));
        p_desnote           := hcm_util.get_string_t(data_obj,'p_desnote');
        p_dtereq            := to_date(hcm_util.get_string_t(data_obj,'p_dtereq'), 'dd/mm/yyyy');
        p_codcompe          := hcm_util.get_string_t(data_obj,'p_codcompe');
        p_mailto            := hcm_util.get_string_t(data_obj,'p_mailto');
        p_flgduepr          := hcm_util.get_string_t(data_obj,'p_flgduepr');
--  parameter from drilldown tab2
        p_codjob            := hcm_util.get_string_t(data_obj,'p_codjob');
        p_codempmt          := hcm_util.get_string_t(data_obj,'p_codempmt');
        p_codbrlc           := hcm_util.get_string_t(data_obj,'p_codbrlc');

  end initial_params;

  function check_index return boolean as
    v_temp      varchar(1 char);
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return false;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp , global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

--  check position
    begin
        select 'X' into v_temp
        from tpostn
        where codpos = p_codpos;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
        return false;
    end;

--  check data in treqest2
    begin
        select 'X' into v_temp
        from treqest2
        where codcomp like p_codcomp||'%'
          and codpos = p_codpos
          and numreqst =  nvl(p_numreqst,numreqst)
          and rownum = 1
          and flgrecut in ('I','E')
          and nvl(qtyact,0) < nvl(qtyreq,0) ; --ST11 #8023 || 04/07/2022
          --and qtyact < qtyreq; --ST11 #8023 || 04/07/2022
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2-2');
        return false;
    end;

    return true;

  end;

  function check_params return boolean as
    v_temp     varchar(1 char);
  begin
    begin
        select 'X' into v_temp
        from treqest1
          where numreqst =  nvl(p_numreqst,numreqst)
          and rownum = 1
          and codappchse = p_codconfrm;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('RC0039', global_v_lang);
        return false;
    end;

    begin
        select 'X' into v_temp
        from tcodmove
        where codcodec = p_codtran;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODMOVE');
        return false;
    end;

    if p_dteeffec < trunc(sysdate) then
        param_msg_error := get_error_msg_php('HR8519', global_v_lang);
        return false;
    end if;

    if p_flgduepr = 'Y' and nvl(p_qtyduepr,0) = 0 then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang);
        return false;
    end if;

    if p_flgduepr = 'N' and nvl(p_qtyduepr,0) > 0 then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang);
        return false;
    end if;

--    begin
--        select 'X' into v_temp
--          from treqest2
--          where numreqst =  nvl(p_numreqst,numreqst)
--           and rownum = 1
--           and codpos = p_codpos
--           and qtyact < qtyreq;
--    exception when no_data_found then
--        param_msg_error := get_error_msg_php('RC0038', global_v_lang);
--        return false;
--    end;

    return true;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    obj_data_rows   json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_year          number;
    v_month         number;
    v_day           number;
    v_count_trequest2   number := 0;
    cursor c1 is
        select a.codempid, a.codcompe, a.codpose, b.dteempmt, a.dtestrt,a.numreqst, a.dtereq
        from tappeinf a, temploy1 b
        where a.codempid = b.codempid
          and a.numreqst = nvl(p_numreqst, a.numreqst)
          and a.codcomp  like p_codcomp||'%'
          and a.codpos   = p_codpos
          and a.status   = 'A'
          and a.codasapl = 'P'
        order by a.codempid;

    cursor c2 is
        select numreqst,qtyreq,qtyact
          from treqest2
         where codcomp like p_codcomp||'%'
           and codpos = p_codpos
           and numreqst = nvl(p_numreqst,numreqst)
           and flgrecut in ('I','E')
      order by numreqst desc;

  begin

--  loop for get qty_req, qty_act of header
    for i in c2 loop
        v_count_trequest2 := v_count_trequest2+1;
        obj_data := json_object_t();
        obj_data.put('qtyreq', i.qtyreq);
        obj_data.put('qtyallow', i.qtyact);
        exit;
    end loop;

    if v_count_trequest2 = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST2');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    obj_rows := json_object_t();
    for i in c1 loop
        v_count := v_count + 1;
        if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
            v_count_secur := v_count_secur + 1;
            v_row := v_row + 1;
            obj_data_rows := json_object_t();
            obj_data_rows.put('image', get_emp_img(i.codempid));
            obj_data_rows.put('codempid', i.codempid);
            obj_data_rows.put('dtereq', to_char(i.dtereq, 'dd/mm/yyyy'));

            obj_data_rows.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
            obj_data_rows.put('desc_codcomp', get_tcenter_name(i.codcompe, global_v_lang));
            obj_data_rows.put('desc_codpos', get_tpostn_name(i.codpose, global_v_lang));

            get_service_year(i.dteempmt, sysdate, 'Y', v_year, v_month, v_day);

            obj_data_rows.put('worktim', v_year||'('||v_month||')');
            obj_data_rows.put('dtestrt', to_char(i.dtestrt, 'dd/mm/yyyy'));
            obj_data_rows.put('numreqststd',i.numreqst);
            obj_rows.put(to_char(v_row-1),obj_data_rows);
        end if;
    end loop;

    obj_data.put('table', obj_rows);
    obj_data.put('coderror', 200);


    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPEINF');
    end if;

    if param_msg_error is null then
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end gen_index;

  function gen_jobposting(v_numreqst varchar2, v_codpos varchar2) return json_object_t as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;

    cursor c1 is
        select dtepost, codjobpost
        from tjobpost
        where numreqst = v_numreqst
          and codpos = v_codpos;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('dtepost',to_char(i.dtepost, 'dd/mm/yyyy'));
        obj_data.put('desc_codjobpost',i.codjobpost);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_rows;

  end gen_jobposting;

  procedure gen_drilldown_tab1(json_str_output out clob) as
     obj_data        json_object_t;
     v_treqest1      treqest1%rowtype;
  begin
    begin
        select *
        into v_treqest1
        from treqest1
        where numreqst = nvl(p_numreqst,numreqst);
    exception when no_data_found then
        v_treqest1 := null;
    end;

    obj_data := json_object_t();
    obj_data.put('desc_codcomp',get_tcenter_name(v_treqest1.codcomp, global_v_lang));
    obj_data.put('desc_codemprq',get_temploy_name(v_treqest1.codemprq, global_v_lang));
    obj_data.put('dtereq',to_char(v_treqest1.dtereq, 'dd/mm/yyyy'));
    obj_data.put('desc_codempap',get_temploy_name(v_treqest1.codempap, global_v_lang));
    obj_data.put('dteaprov',to_char(v_treqest1.dteaprov, 'dd/mm/yyyy'));
    obj_data.put('desc_codemprc',get_temploy_name(v_treqest1.codemprc, global_v_lang));
    obj_data.put('desc_codintview',get_temploy_name(v_treqest1.codintview, global_v_lang));
    obj_data.put('desc_codappchse',get_temploy_name(v_treqest1.codappchse, global_v_lang));
    obj_data.put('desc_stareq',get_tlistval_name('TSTAREQ',v_treqest1.stareq, global_v_lang));
    obj_data.put('dterec',to_char(v_treqest1.dterec, 'dd/mm/yyyy'));
    obj_data.put('filename', v_treqest1.filename);
    obj_data.put('desnote', v_treqest1.desnote);
    obj_data.put('coderror', '200');

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_drilldown_tab1;

  procedure gen_drilldown_tab2(json_str_output out clob) as
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_row               number := 0;
    v_flgjob_syncond    tjobcode.syncond%type;

    cursor c1 is
        select codpos, codempmt, codbrlc, amtincom, flgrecut, codjob,
               dtereqm, dteopen, dteclose, codrearq, codempr, flgjob,
               flgcond, syncond, desnote, qtyreq, qtyact
        from treqest2
        where numreqst = nvl(p_numreqst,numreqst)
          and codpos = nvl(p_codpos, codpos);

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        obj_data := json_object_t();
        v_row := v_row + 1;
        obj_data.put('position', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('codjob', i.codjob);
        obj_data.put('desc_codjob', get_tjobcode_name(i.codjob, global_v_lang));
        obj_data.put('codempmt', i.codempmt);
        obj_data.put('desc_codempmt', get_tcodec_name('TCODEMPL', i.codempmt, global_v_lang));
        obj_data.put('codbrlc', i.codbrlc);
        obj_data.put('desc_codbrlc', get_tcenter_name(i.codbrlc, global_v_lang));
        obj_data.put('amtincom', i.amtincom);
        obj_data.put('desc_flgrecut', get_tlistval_name('FLGRECUT', i.flgrecut, global_v_lang));
        obj_data.put('dtereqm', to_char(i.dtereqm, 'dd/mm/yyyy'));
        obj_data.put('dteopen', to_char(i.dteopen , 'dd/mm/yyyy'));
        obj_data.put('dteclose', to_char(i.dteclose , 'dd/mm/yyyy'));
        obj_data.put('desc_codrearq',get_tlistval_name('TCODREARQ', i.codrearq ,global_v_lang));
        obj_data.put('desc_codempr', get_temploy_name(i.codempr, global_v_lang));
        obj_data.put('flgjob', i.flgjob);

        begin
            select syncond into v_flgjob_syncond
            from tjobcode
            where codjob = i.codjob;
        exception when no_data_found then
            v_flgjob_syncond := '';
        end;

        obj_data.put('flgjob_syncond', v_flgjob_syncond);
        obj_data.put('flgcond', i.flgcond);
        obj_data.put('flgcond_syncond', i.syncond);
        obj_data.put('desnote', i.desnote);
        obj_data.put('qtyreq', i.qtyreq);
        obj_data.put('qtyact', i.qtyact);
        obj_data.put('job_posting_table', gen_jobposting(p_numreqst, i.codpos));
        obj_rows.put(to_char(v_row-1),obj_data);

    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_drilldown_tab2;

  procedure update_tappeinf as
    v_staappr tappeinf.staappr%type;
  begin

    if p_staappr = 'A' then
        v_staappr := 'Y';
    elsif  p_staappr = 'N' then
        v_staappr := 'N';
    end if;

        update tappeinf
        set staappr = v_staappr,
            status = v_staappr,
            codconfrm = p_codconfrm,
            dteconfrm = p_dteconfrm,
            codtran = p_codtran,
            dteeffec = p_dteeffec,
            flgduepr = p_flgduepr,
            qtyduepr = p_qtyduepr,
            desnote = p_desnote,
            dtefoll = sysdate,
            coduser = global_v_coduser
        where codempid = p_query_codempid
          and trunc(dtereq) = trunc(p_dtereq)
          and numreqst = nvl(p_numreqst,numreqst)
        --  and codcomp = p_codcomp
          and codpos = p_codpos;
  end update_tappeinf;

  procedure update_treqest1 as
    v_qtyact    treqest2.qtyact%type;
    v_qtyreq    treqest2.qtyreq%type;
    v_stareq    treqest1.stareq%type;
  begin
    begin
      select nvl(sum(qtyact),0),nvl(sum(qtyreq),0)
        into v_qtyact,v_qtyreq
        from treqest2
       where numreqst = p_numreqst;
    end;

    if v_qtyreq > v_qtyact and v_qtyact >= 1 then
      v_stareq := 'F';
    elsif v_qtyreq <= v_qtyact then
      v_stareq := 'C';
    end if;

    if v_stareq in ('F','C') then
      update treqest1
         set dterec  = sysdate,
             stareq  = v_stareq,
             coduser = global_v_coduser
      where numreqst = p_numreqst;
    end if;
  end update_treqest1;

  procedure update_treqest2(v_salary number) as
  begin

    if p_staappr = 'A' then
        update treqest2
           set dteappchse = sysdate,
               qtyact = nvl(qtyact,0)+1,
               amtsalavg = (nvl(qtyact,0) * nvl(amtsalavg,0) + nvl(v_salary,0))/ (nvl(qtyact,0) + 1),
               coduser = global_v_coduser
         where numreqst = p_numreqst
           and codpos = p_codpos;
    else
        update treqest2
           set dteappchse = sysdate,
               coduser = global_v_coduser
         where numreqst = p_numreqst
           and codpos = p_codpos;
    end if;

  end update_treqest2;

  procedure insert_ttmovemt(v_codcomp varchar2, v_codpos varchar2, v_codpose varchar2) as
    v_max         number;
    v_dteduepr    ttmovemt.dteduepr%type;
    v_amtincom1   temploy3.amtincom1%type;
    v_amtincom2   temploy3.amtincom2%type;
    v_amtincom3   temploy3.amtincom3%type;
    v_amtincom4   temploy3.amtincom4%type;
    v_amtincom5   temploy3.amtincom5%type;
    v_amtincom6   temploy3.amtincom6%type;
    v_amtincom7   temploy3.amtincom7%type;
    v_amtincom8   temploy3.amtincom8%type;
    v_amtincom9   temploy3.amtincom9%type;
    v_amtincom10  temploy3.amtincom10%type;

    v_amtincadj1  ttmovemt.amtincadj1%type;
    v_amtincadj2  ttmovemt.amtincadj1%type;
    v_amtincadj3  ttmovemt.amtincadj1%type;
    v_amtincadj4  ttmovemt.amtincadj1%type;
    v_amtincadj5  ttmovemt.amtincadj1%type;
    v_amtincadj6  ttmovemt.amtincadj1%type;
    v_amtincadj7  ttmovemt.amtincadj1%type;
    v_amtincadj8  ttmovemt.amtincadj1%type;
    v_amtincadj9  ttmovemt.amtincadj1%type;
    v_amtincadj10 ttmovemt.amtincadj1%type;

    v_amtothr     ttmovemt.amtothr%type;

    v_codjob      varchar2(1000 char);
    v_numlvl      varchar2(1000 char);
    v_codbrlc     varchar2(1000 char);
    v_codcalen    varchar2(1000 char);
    v_flgatten    varchar2(1000 char);
    v_dteeffpos   varchar2(1000 char);
    v_codjobt     varchar2(1000 char);
    v_numlvlt     varchar2(1000 char);
    v_codbrlct    varchar2(1000 char);
    v_codcalet    varchar2(1000 char);
    v_flgattet    varchar2(1000 char);
    v_codsex      varchar2(1000 char);
    v_codempmtt   varchar2(1000 char);
    v_codempmt    varchar2(1000 char);
    v_typpayrolt  varchar2(1000 char);
    v_typpayroll  varchar2(1000 char);
    v_typempt     varchar2(1000 char);
    v_typemp      varchar2(1000 char);
    v_codcurr     varchar2(1000 char);
    v_jobgrade    varchar2(1000 char);
    v_jobgradet   varchar2(1000 char);
    v_codgrpgl    varchar2(1000 char);
    v_codgrpglt   varchar2(1000 char);
    v_dteefpos    varchar2(1000 char);
    v_dteeflvl    varchar2(1000 char);
    v_dteefstep   varchar2(1000 char);
  begin
    select max(numseq) + 1 into v_max
    from ttmovemt
    where codempid = p_query_codempid
      and dteeffec = p_dteeffec;

    if v_max is null then
        v_max := 1;
    end if;

    if p_flgduepr = 'Y' then
        v_dteduepr := p_dteeffec + p_qtyduepr;
    else
        v_dteduepr := p_dteeffec;
    end if;

    begin
        select codjob,numlvl,codbrlc,codcalen,flgatten,dteefpos,codjob,numlvl,codbrlc,codcalen,flgatten,
               codsex,codempmt,codempmt,typpayroll,typpayroll,typemp,typemp,null,jobgrade,jobgrade,
               codgrpgl,codgrpgl,dteefpos,dteeflvl,dteefstep
          into v_codjob,v_numlvl,v_codbrlc,v_codcalen,v_flgatten,v_dteeffpos,v_codjobt,v_numlvlt,v_codbrlct,v_codcalet,v_flgattet,
               v_codsex,v_codempmtt,v_codempmt,v_typpayrolt,v_typpayroll,v_typempt,v_typemp,v_codcurr,v_jobgrade,v_jobgradet,
               v_codgrpgl,v_codgrpglt,v_dteefpos,v_dteeflvl,v_dteefstep
          from temploy1
         where codempid = p_query_codempid;
    exception when no_data_found then
        v_codjob        := '';
        v_numlvl        := '';
        v_codbrlc       := '';
        v_codcalen      := '';
        v_flgatten      := '';
        v_dteeffpos     := '';
        v_codjobt       := '';
        v_numlvlt       := '';
        v_codbrlct      := '';
        v_codcalet      := '';
        v_flgattet      := '';
        v_codsex        := '';
        v_codempmtt     := '';
        v_codempmt      := '';
        v_typpayrolt    := '';
        v_typpayroll    := '';
        v_typempt       := '';
        v_typemp        := '';
        v_codcurr       := '';
        v_jobgrade      := '';
        v_jobgradet     := '';
        v_codgrpgl      := '';
        v_codgrpglt     := '';
        v_dteefpos      := '';
        v_dteeflvl      := '';
        v_dteefstep     := '';
    end;


    v_amtincom1  := 0;
    v_amtincom2  := 0;
    v_amtincom3  := 0;
    v_amtincom4  := 0;
    v_amtincom5  := 0;
    v_amtincom6  := 0;
    v_amtincom7  := 0;
    v_amtincom8  := 0;
    v_amtincom9  := 0;
    v_amtincom10 := 0;

    v_amtothr    := 0;

    v_amtincadj1  := 0;
    v_amtincadj2  := 0;
    v_amtincadj3  := 0;
    v_amtincadj4  := 0;
    v_amtincadj5  := 0;
    v_amtincadj6  := 0;
    v_amtincadj7  := 0;
    v_amtincadj8  := 0;
    v_amtincadj9  := 0;
    v_amtincadj10 := 0;

    v_amtincom1  := stdenc(v_amtincom1,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom2  := stdenc(v_amtincom2,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom3  := stdenc(v_amtincom3,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom4  := stdenc(v_amtincom4,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom5  := stdenc(v_amtincom5,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom6  := stdenc(v_amtincom6,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom7  := stdenc(v_amtincom7,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom8  := stdenc(v_amtincom8,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom9  := stdenc(v_amtincom9,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom10 := stdenc(v_amtincom10,p_query_codempid,hcm_secur.get_v_chken);

    v_amtothr    := stdenc(v_amtothr,p_query_codempid,hcm_secur.get_v_chken);

    v_amtincadj1  := stdenc(v_amtincadj1,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj2  := stdenc(v_amtincadj2,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj3  := stdenc(v_amtincadj3,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj4  := stdenc(v_amtincadj4,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj5  := stdenc(v_amtincadj5,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj6  := stdenc(v_amtincadj6,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj7  := stdenc(v_amtincadj7,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj8  := stdenc(v_amtincadj8,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj9  := stdenc(v_amtincadj9,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincadj10 := stdenc(v_amtincadj10,p_query_codempid,hcm_secur.get_v_chken);


    insert into ttmovemt
        (
            codempid, dteeffec, numseq, codtrn, stapost2, codcomp, codcompt, codpos,
            codposnow, codappr, dteappr, remarkap, codreq, flgduepr, dteduepr,
            flggroup, flgadjin, amtincom1, amtincom2, amtincom3,
            amtincom4, amtincom5, amtincom6, amtincom7, amtincom8, amtincom9,
            amtincom10, amtothr, amtincadj1, amtincadj2, amtincadj3, amtincadj4,
            amtincadj5, amtincadj6, amtincadj7, amtincadj8, amtincadj9, amtincadj10,
            flgrp, staupd, codcreate, coduser,
            codjob,numlvl,codbrlc,codcalen,flgatten,dteeffpos,codjobt,numlvlt,codbrlct,codcalet,flgattet,
            codsex,codempmtt,codempmt,typpayrolt,typpayroll,typempt,typemp,codcurr,jobgrade,jobgradet,
            codgrpgl,codgrpglt,dteefpos,dteeflvl,dteefstep
        )
    values
        (
            p_query_codempid, p_dteeffec, v_max, p_codtran, '0', v_codcomp, p_codcomp, v_codpos,
            v_codpose, p_codconfrm, p_dteconfrm, p_desnote, p_codconfrm, p_flgduepr, v_dteduepr,
            'N', 'N', v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
            v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, v_amtothr,
            v_amtincadj1, v_amtincadj2, v_amtincadj3, v_amtincadj4, v_amtincadj5, v_amtincadj6,
            v_amtincadj7, v_amtincadj8, v_amtincadj9, v_amtincadj10,'N', 'C', global_v_coduser,
            global_v_coduser,
            v_codjob,v_numlvl,v_codbrlc,v_codcalen,v_flgatten,v_dteeffpos,v_codjobt,v_numlvlt,v_codbrlct,v_codcalet,v_flgattet,
            v_codsex,v_codempmtt,v_codempmt,v_typpayrolt,v_typpayroll,v_typempt,v_typemp,v_codcurr,v_jobgrade,v_jobgradet,
            v_codgrpgl,v_codgrpglt,v_dteefpos,v_dteeflvl,v_dteefstep
        );

  end insert_ttmovemt;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

    PROCEDURE get_mail_to ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        json_obj     json;
        v_codempid   temploy1.codempid%TYPE;
        obj_data     json;

        v_codposh       temphead.codposh%type;
        v_codcomph      temphead.codcomph%type;

        v_codempidh      temphead.codempidh%type;
        v_codemprq      treqest1.codemprq%type;

        v_mail_to    varchar2(1000 char);

        cursor  c1 is
            select codempidh,codposh,codcomph,rowid
            from TEMPHEAD
            where codpos = p_codpos
            and codcomp = p_codcomp;

        cursor  c2 is
            select codempid
            from TEMPLOY1
            where codpos = v_codposh
            and codcomp = v_codcomph;

    BEGIN
        json_obj := json(json_str_input);
        obj_data := json;
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        v_codempid := upper(hcm_util.get_string(json_obj, 'p_codempid'));

        v_mail_to := get_temploy_name(v_codempid, global_v_lang);

        for i in c1 loop

            if i.codempidh is not null then
                v_codempidh := i.codempidh;
                v_mail_to := v_mail_to||', '||get_temploy_name(v_codempidh, global_v_lang);
            elsif i.codposh is not null  and i.codcomph is not null  then
                v_codposh := i.codposh;
                v_codcomph := i.codcomph;
                for j in c2 loop
                    v_mail_to := v_mail_to||', '||get_temploy_name(j.codempid, global_v_lang);
                end loop;
            end if;
        end loop;

        BEGIN
            select codemprq into v_codemprq
            from treqest1
            where numreqst = nvl(p_numreqst,numreqst)
              and   rownum = 1;
        exception when no_data_found then
            v_codemprq := '';
        END;

        obj_data.put('mailto', v_mail_to||', '||get_temploy_name(v_codemprq, global_v_lang));
        obj_data.put('coderror', 200);

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
        IF param_msg_error IS NOT NULL THEN
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_mail_to;

 procedure get_drilldown_tab1(json_str_input in clob, json_str_output out clob) AS
 BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_drilldown_tab1(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_drilldown_tab1;

 procedure get_drilldown_tab2(json_str_input in clob, json_str_output out clob) AS
 BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_drilldown_tab2(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_drilldown_tab2;

    procedure send_mail_a(data_obj json_object_t) as
        v_rowid         varchar(20);

        json_obj        json_object_t;
        v_codform       TFWMAILH.codform%TYPE;
        v_codapp        TFWMAILH.codapp%TYPE;

        v_error             varchar2(4000 char);
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_subject           varchar2(500 char);

        v_msg           clob;

        v_email         varchar(200);
        v_codintview    treqest1.codintview%type;

        v_numreqst      tappeinf.numreqst%type;
        v_codcomp       tappeinf.codcomp%type;
        v_codpos        tappeinf.codpos%type;
        v_codempid      tappeinf.codempid%type;
        v_dtereq        tappeinf.dtereq%type;

        v_codposh       temphead.codposh%type;
        v_codcomph      temphead.codcomph%type;
        v_codempidh      temphead.codempidh%type;

        cursor  c1 is
            select codempidh,codposh,codcomph,rowid
            from TEMPHEAD
            where codpos = v_codpos
            and codcomp = v_codcomp;

        cursor  c2 is
            select codempid,email,rowid
            from TEMPLOY1
            where codpos = v_codposh
            and codcomp = v_codcomph;

    begin
        v_numreqst  := hcm_util.get_string_t(data_obj, 'p_numreqst');
        v_codcomp   := hcm_util.get_string_t(data_obj, 'p_codcomp');
        v_codpos    := hcm_util.get_string_t(data_obj, 'p_codpos');
        v_codempid  := hcm_util.get_string_t(data_obj, 'p_query_codempid');
        v_dtereq    := to_date(hcm_util.get_string_t(data_obj, 'p_dtereq'),'dd/mm/yyyy');
        for i in c1 loop

            if i.codempidh is not null then
                v_codempidh := i.codempidh;

                v_subject  := get_label_name('HRRC1JE2', global_v_lang, 130);
                v_codapp   := 'HRRC1JE';
                begin
                    select codform into v_codform
                    from tfwmailh
                    where codapp = v_codapp;
                exception when no_data_found then
                    v_codform  := 'HRRC1JE';
                end;
                chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);

                -- replace data
                begin
                    select rowid into v_rowid
                    from tappeinf
                    where numreqst = v_numreqst
                    and codcomp = v_codcomp
                    and codpos  = v_codpos
                    and codempid = v_codempid
                    and dtereq = v_dtereq;
                exception when no_data_found then
                    v_rowid := '';
                end;
                chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPEINF', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

                begin
                    select rowid into v_rowid
                    from temploy1
                    where codempid = i.codempidh;
                exception when no_data_found then
                    v_rowid := '';
                end;
                chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

                -- replace email reciever param
                  v_error := chk_flowmail.send_mail_to_emp (i.codempidh, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);

            elsif i.codposh is not null  and i.codcomph is not null  then
                v_codposh := i.codposh;
                v_codcomph := i.codcomph;
                for j in c2 loop
                    v_subject  := get_label_name('HRRC1JE2', global_v_lang, 130);
                    v_codapp   := 'HRRC1JE';
                    begin
                        select codform into v_codform
                        from tfwmailh
                        where codapp = v_codapp;
                    exception when no_data_found then
                        v_codform  := 'HRRC1JE';
                    end;
                    v_numreqst  := hcm_util.get_string_t(data_obj, 'p_numreqst');
                    v_codcomp   := hcm_util.get_string_t(data_obj, 'p_codcomp');
                    v_codpos    := hcm_util.get_string_t(data_obj, 'p_codpos');
                    v_codempid  := hcm_util.get_string_t(data_obj, 'p_query_codempid');
                    v_dtereq    := to_date(hcm_util.get_string_t(data_obj, 'p_dtereq'),'dd/mm/yyyy');
                    chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);

                    -- replace data
                    begin
                        select rowid into v_rowid
                        from tappeinf
                        where numreqst = v_numreqst
                        and codcomp = v_codcomp
                        and codpos  = v_codpos
                        and codempid = v_codempid
                        and dtereq = v_dtereq;
                    exception when no_data_found then
                        v_rowid := '';
                    end;
                    chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPEINF', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

                    -- replace sender
                    begin
                        select rowid into v_rowid
                        from temploy1
                        where codempid = global_v_codempid;
                    exception when no_data_found then
                        v_rowid := '';
                    end;

                    chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
                    chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', j.rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
                    v_error := chk_flowmail.send_mail_to_emp (j.codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);
                end loop;
            end if;
        end loop;
    end send_mail_a;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
    v_qtypos       number := 0;
    v_codcomp      tappeinf.codcomp%type;
    v_codpos       tappeinf.codpos%type;
    v_amtmth       number;
    v_numlvl       temploy1.numlvl%type;
    v_typpayroll   temploy1.typpayroll%type;
    v_codcalen     temploy1.codcalen%type;
    v_jobgrade     temploy1.jobgrade%type;
    v_codgrpgl     temploy1.codgrpgl%type;
    v_amthour      number;
    v_amtday       number;
    v_typemp       temploy1.typemp%type;
    v_dteeffec     tappeinf.dteeffec%type;
    v_codpose      tappeinf.codpose%type;

    v_get_movemt_codpos     treqest2.codpos%type;
    v_get_movemt_codcomp    treqest2.codcomp%type;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop

        data_obj  := hcm_util.get_json_t(param_json, to_char(i));
        initial_params(data_obj);
        if check_params then
            v_dteeffec := sysdate;
            v_get_movemt_codpos     :=  p_codpos;
            v_get_movemt_codcomp    :=  p_codcomp;
            std_al.get_movemt(p_query_codempid, v_dteeffec, 'C', 'U', v_get_movemt_codcomp, v_get_movemt_codpos,
                              v_numlvl, p_codjob, p_codempmt, v_typemp, v_typpayroll, p_codbrlc,
                              v_codcalen, v_jobgrade, v_codgrpgl, v_amthour,
                              v_amtday, v_amtmth);
            update_tappeinf;
            update_treqest2(v_amtmth);
            update_treqest1;

            begin
               select codcomp, codpos,codpose
                 into v_codcomp, v_codpos, v_codpose
                 from tappeinf
                where numreqst = nvl(p_numreqst,numreqst)
                  and rownum = 1
                  and trunc(dtereq) = p_dtereq
                  and codempid = p_query_codempid
                  and codcomp = p_codcomp
                  and codpos = p_codpos;
            exception when no_data_found then
                v_codcomp := '';
                v_codpos := '';
            end;

            if p_staappr = 'A' then
                insert_ttmovemt(v_codcomp, v_codpos, v_codpose);
            end if;
            if param_msg_error is null then
                send_mail_a(data_obj);
            end if;
        else
            exit;
        end if;
    end loop;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END save_index;

END HRRC1JE;

/
