--------------------------------------------------------
--  DDL for Package Body HRRC11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC11E" AS
  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj            := json_object_t(json_str_input);
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
        p_dtereqst          := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
        p_dtereqen          := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
        p_codemprc          := hcm_util.get_string_t(json_obj,'p_codemprc');
        p_stareq            := hcm_util.get_string_t(json_obj,'p_stareq');

        p_numreqst          := hcm_util.get_string_t(json_obj,'p_numreqst');
        p_numreqstCopy      := hcm_util.get_string_t(json_obj,'p_numreqstQuery');

        p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
        p_codjob            := hcm_util.get_string_t(json_obj,'p_codjob');
        p_flgrecut          := hcm_util.get_string_t(json_obj,'p_flgrecut');
        p_status            := hcm_util.get_string_t(json_obj,'p_status');

        param_json          := hcm_util.get_json_t(json_obj,'param_json');
        v_chken             := hcm_secur.get_v_chken;
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_temp   varchar(1 char);
  begin
    if p_dtereqst is null or p_dtereqen is null or (p_codcomp is null and p_codemprc is null) then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_codcomp is not null then
        begin
            select 'X'
              into v_temp
              from tcenter
             where codcomp like p_codcomp || '%'
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end;
        if secur_main.secur7(p_codcomp, global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;

    if p_dtereqst > p_dtereqen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

    if p_codemprc is not null then
        begin
            select 'X'
              into v_temp
              from temploy1
             where codempid = p_codemprc;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;

        if secur_main.secur2(p_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;

    cursor c1 is
        select a.dtereq, a.numreqst, a.codcomp, a.codemprc, a.stareq
          from treqest1 a
         where a.codcomp like p_codcomp||'%'
           and a.dtereq between p_dtereqst and p_dtereqen
           and a.codemprc = nvl(p_codemprc,a.codemprc)
           and a.stareq = nvl(p_stareq,a.stareq)
      order by a.dtereq, a.numreqst;
  begin
    obj_row := json_object_t();
    for i in c1 loop
        if secur_main.secur7(i.codcomp,global_v_coduser) then
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror',200);
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('numreqst',i.numreqst);
            obj_data.put('codcomp',get_compful(i.codcomp));
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codemprc',i.codemprc);
            obj_data.put('desc_codemprc',get_temploy_name(i.codemprc,global_v_lang));
            obj_data.put('stareq',i.stareq);
            obj_data.put('desc_stareq',get_tlistval_name('TSTAREQ',i.stareq,global_v_lang));
            obj_row.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

  procedure gen_detail(json_str_output out clob) as
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    obj_main    json_object_t;
    obj_detail  json_object_t;
    obj_tab1    json_object_t;
    v_treqest1  treqest1%rowtype;
    v_flgAdd    boolean := false;
    v_flgEdit   boolean := false;

    cursor c1 is
        select *
          from treqest2
         where numreqst = nvl(p_numreqstCopy,p_numreqst)
      order by codpos;
  begin
    obj_main    := json_object_t();
    obj_detail  := json_object_t();
    obj_tab1    := json_object_t();
    obj_row     := json_object_t();

    obj_detail.put('coderror',200);
    obj_detail.put('numreqst', p_numreqst);
    obj_detail.put('numreqstc', p_numreqstCopy);

    begin
        select *
          into v_treqest1
          from treqest1
         where numreqst = nvl(p_numreqstCopy,p_numreqst);
        v_flgEdit   := true;
    exception when others then
        v_treqest1 := null;
        v_flgAdd   := true;
        v_treqest1.stareq       := 'N';
        v_treqest1.dtereq       := trunc(sysdate);
        v_treqest1.dteaprov     := trunc(sysdate);
        v_treqest1.dterec       := trunc(sysdate);
    end;

    obj_tab1.put('coderror',200);
    obj_tab1.put('numreqst', p_numreqst);
    obj_tab1.put('numreqstc', p_numreqstCopy);
    obj_tab1.put('codcomp',v_treqest1.codcomp);
    obj_tab1.put('codemprq',v_treqest1.codemprq);
    obj_tab1.put('dtereq',to_char(v_treqest1.dtereq,'dd/mm/yyyy'));
    obj_tab1.put('codempap',v_treqest1.codempap);
    obj_tab1.put('dteaprov',to_char(v_treqest1.dteaprov,'dd/mm/yyyy'));
    obj_tab1.put('codemprc',v_treqest1.codemprc);
    obj_tab1.put('codintview',v_treqest1.codintview);
    obj_tab1.put('codappchse',v_treqest1.codappchse);
    obj_tab1.put('desnote',v_treqest1.desnote);
    obj_tab1.put('stareq',v_treqest1.stareq);
    obj_tab1.put('dterec',to_char(v_treqest1.dterec,'dd/mm/yyyy'));
    if p_numreqstCopy is null then
        obj_tab1.put('filename',v_treqest1.filename);
    end if;
    if v_treqest1.stareq <> 'N' then
        obj_tab1.put('flgStareq',false);
    else
        obj_tab1.put('flgStareq',true);
    end if;

    for r1 in c1 loop
        v_row       := v_row + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror',200);
        obj_data.put('codpos',r1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('codjob',r1.codjob);
        obj_data.put('desc_codjob',get_tjobcode_name(r1.codjob,global_v_lang));
        obj_data.put('codrearq',r1.codrearq);
        obj_data.put('desc_codrearq',get_tlistval_name('TCODREARQ',r1.codrearq,global_v_lang));
        if p_numreqstCopy is null then
            obj_data.put('flgCopy','N');
        else
            obj_data.put('flgCopy','Y');
        end if;
        obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    obj_main.put('coderror',200);
--    obj_main.put('detail', obj_detail);
    if p_numreqstCopy is null then
        obj_main.put('isCopy','N');
    else
        obj_main.put('isCopy','Y');
        v_flgAdd    := true;
        v_flgEdit   := false;
    end if;
    obj_main.put('isAdd',v_flgAdd);
    obj_main.put('isEdit',v_flgEdit);
    obj_main.put('tab1', obj_tab1);
    obj_main.put('tab2', obj_row);

    json_str_output := obj_main.to_clob;
  end gen_detail;

  procedure get_detail(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail;

  procedure gen_detailtab2_sub(json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_row               number := 0;
    obj_detail          json_object_t;
    obj_main            json_object_t;
    v_treqest2          treqest2%rowtype;
    v_statement         tjobcode.statement%type;
    obj_syncond         json_object_t;
    v_qtybalance        number;
    v_codjob            tjobpos.codjob%type;

    cursor c1 is
        select dtepost,codjobpost
          from tjobpost
         where numreqst = nvl(p_numreqstCopy,p_numreqst)
           and codpos = p_codpos
      order by dtepost;
  begin
    obj_main    := json_object_t();
    obj_detail  := json_object_t();
    obj_row     := json_object_t();

    begin
        select *
          into v_treqest2
          from treqest2
         where numreqst = nvl(p_numreqstCopy,p_numreqst)
           and codpos = p_codpos ;
    exception when others then
        v_treqest2 := null;
    end;
    if v_treqest2.codjob is null then
      begin
        select codjob into v_codjob
          from tjobpos
         where codcomp = get_compful(p_codcomp)
           and codpos = p_codpos;
      exception when others then
        v_codjob := null;
      end;
    end if;
    obj_detail.put('coderror',200);
    obj_detail.put('codpos',p_codpos);
    obj_detail.put('codjob',nvl(v_treqest2.codjob,v_codjob));
    obj_detail.put('codempmt',v_treqest2.codempmt);
    obj_detail.put('codbrlc',v_treqest2.codbrlc);
    obj_detail.put('amtincom',v_treqest2.amtincom);
    obj_detail.put('flgrecut',v_treqest2.flgrecut);
    obj_detail.put('desnote',v_treqest2.desnote);
    obj_detail.put('welfare',v_treqest2.welfare); -- softberry || 16/02/2023 || #8852
    obj_detail.put('dteopen',to_char(v_treqest2.dteopen,'dd/mm/yyyy'));
    obj_detail.put('dteclose',to_char(v_treqest2.dteclose,'dd/mm/yyyy'));
    obj_detail.put('dtereqm',to_char(v_treqest2.dtereqm,'dd/mm/yyyy'));

    begin
        select statement into v_statement
          from tjobcode
         where codjob = v_treqest2.codjob;
    exception when no_data_found then
        v_statement := '';
    end;

    obj_detail.put('codrearq',v_treqest2.codrearq);
    obj_detail.put('codempr',v_treqest2.codempr);
    obj_detail.put('flgjob',v_treqest2.flgjob);
    if v_treqest2.flgjob = 'Y' then
        obj_detail.put('statement',get_logical_desc(v_statement));
    end if;
    obj_syncond := json_object_t();
    obj_syncond.put('code',trim(nvl(v_treqest2.syncond,' ')));
    obj_syncond.put('description',trim(nvl(get_logical_desc(v_treqest2.statement),' ')));
    obj_syncond.put('statement',nvl(v_treqest2.statement,'[]'));
    obj_detail.put('flgcond',v_treqest2.flgcond);
    obj_detail.put('syncond',obj_syncond);
    obj_detail.put('qtyreq',v_treqest2.qtyreq);
    obj_detail.put('qtyappl',qtyappl(p_numreqst, p_codpos, v_treqest2.flgrecut));
    if p_numreqstCopy is null then
        obj_detail.put('qtyact',nvl(v_treqest2.qtyact,0));
        v_qtybalance    := v_treqest2.qtyreq - nvl(v_treqest2.qtyact,0);
        obj_detail.put('qtybalance',v_qtybalance);
    else
        obj_detail.put('qtyact',0);
        v_qtybalance    := v_treqest2.qtyreq - 0;
        obj_detail.put('qtybalance',v_qtybalance);
    end if;
    if trunc(sysdate) > trunc(v_treqest2.dtereqm) and v_qtybalance > 0 then
        obj_detail.put('overdue',trunc(sysdate) - trunc(v_treqest2.dtereqm));
    else
        obj_detail.put('overdue','');
    end if;


    for r1 in c1 loop
        v_row       := v_row + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror',200);
        obj_data.put('dtepost',to_char(r1.dtepost,'dd/mm/yyyy'));
        obj_data.put('codjobpost',get_tcodec_name('TCODJOBPOST',r1.codjobpost,global_v_lang));
        obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    obj_main.put('coderror',200);
    obj_main.put('detail',obj_detail);
    obj_main.put('table',obj_row);

    json_str_output := obj_main.to_clob;
  end gen_detailtab2_sub;

  procedure get_detailtab2_sub(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detailtab2_sub(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detailtab2_sub;

  procedure save_index(json_str_input in clob,json_str_output out clob) as
    json_obj        json_object_t;
    data_obj        json_object_t;
    v_numreqst      treqest1.numreqst%type;
    v_flg           varchar(20 char);
  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
        data_obj    := hcm_util.get_json_t(param_json,to_char(i));
        v_flg       := hcm_util.get_string_t(data_obj,'flg');
        v_numreqst  := hcm_util.get_string_t(data_obj,'numreqst');
        if v_flg = 'delete' then
            delete from treqest1 where numreqst = v_numreqst;
            delete from treqest2 where numreqst = v_numreqst;
        end if;
    end loop;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure gen_copy_list(json_str_output out clob) as
    obj_data            json_object_t;
    obj_rows            json_object_t;
    v_row               number := 0;

    cursor c1 is
        select numreqst, codcomp
          from treqest1
         where numreqst <> p_numreqst
      order by numreqst;
  begin
    obj_rows := json_object_t();
    for r1 in c1 loop
        if secur_main.secur7(r1.codcomp, global_v_coduser) then
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('numreqst',r1.numreqst);
            obj_data.put('codcomp',r1.codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp, global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_copy_list;

  procedure get_copy_list(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_copy_list(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_copy_list;

  procedure gen_codjob_syncond(json_str_output out clob) as
    obj_data            json_object_t;
    v_statement         tjobcode.statement%type;
  begin
    obj_data := json_object_t();

    begin
        select statement into v_statement
          from tjobcode
         where codjob = p_codjob;
    exception when no_data_found then
        v_statement := '';
    end;
    obj_data.put('coderror',200);
    obj_data.put('statement',get_logical_desc(v_statement));
    json_str_output := obj_data.to_clob;
  end gen_codjob_syncond;

  procedure get_codjob_syncond(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_codjob_syncond(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_codjob_syncond;

  function qtyappl(p_numreqst varchar2, p_codpos varchar2, p_flgrecut varchar2) return number is
    v_qtyappl           number := 0;
    v_temp              number := 0;
  begin
    if p_flgrecut = 'I' OR p_flgrecut = 'O' then
        begin
            select count(codempid)
              into v_temp
              from tappeinf
             where numreqst = p_numreqst
               and codpos = p_codpos;
        exception when others then
            v_temp := 0;
        end;
        v_qtyappl   := v_qtyappl + nvl(v_temp,0);
    end if;

    if p_flgrecut = 'E' OR p_flgrecut = 'O' then
        begin
            select count(numappl)
              into v_temp
              from tapplinf
             where (numreql = p_numreqst or numreqc = p_numreqst)
               and (codposl = p_codpos or codposc = p_codpos);
        exception when others then
            v_temp := 0;
        end;
        v_qtyappl   := v_qtyappl + nvl(v_temp,0);
    end if;

    return v_qtyappl;
  END;

  procedure gen_qtyappl(json_str_output out clob) as
    obj_data            json_object_t;
    v_qtyappl           number;
  begin
    obj_data := json_object_t();

    v_qtyappl   := qtyappl(p_numreqst, p_codpos, p_flgrecut);

    obj_data.put('coderror',200);
    obj_data.put('qtyappl',v_qtyappl);
    json_str_output := obj_data.to_clob;
  end gen_qtyappl;

  procedure get_qtyappl(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_qtyappl(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_qtyappl;

  procedure gen_drilldown_qtyappl(json_str_output out clob) as
    obj_data            json_object_t;
    obj_main            json_object_t;
    v_qtyappl           number;
    v_temp              number;
    obj_rows            json_object_t;
    v_row               number := 0;
    v_statappl          tapplinf.statappl%type;
    v_expression        clob;
    v_statement         clob;
    v_dtefoll           date;

    cursor c1 is
        select status, count(codempid) qtyappl, max(dtefoll) maxdtefoll
          from tappeinf
         where numreqst = p_numreqst
           and codpos = p_codpos
      group by status
      order by status;

    cursor c2 is
        select statappl
          from tapplinf
         where (numreql = p_numreqst or numreqc = p_numreqst)
           and (codposl = p_codpos or codposc = p_codpos)
           and statappl in ('21','22','31','51','52','56','62','42')
      group by statappl
      order by statappl;
  begin
    obj_rows := json_object_t();
    obj_main := json_object_t();
    if p_flgrecut = 'I' or  p_flgrecut = 'O' then
        for r1 in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror',200);
            obj_data.put('numreqst',p_numreqst);
            obj_data.put('codpos',p_codpos);
            obj_data.put('status',r1.status);
            obj_data.put('desc_status',get_tlistval_name('STAEMPAPL',r1.status,global_v_lang));
            obj_data.put('qtyappl',r1.qtyappl);
            obj_data.put('dtefoll',to_char(r1.maxdtefoll,'dd/mm/yyyy'));
            obj_data.put('flgrecut','I');
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
    end if;
    if p_flgrecut = 'E' or  p_flgrecut = 'O' then
        for r2 in c2 loop
            v_statappl      := r2.statappl;
            v_qtyappl       := 0;
            if v_statappl = '21' then
                v_expression := ' and ( statappl = '''||v_statappl||''' or statappl >= ''31'')';
            elsif v_statappl in ('22','52','62','42') then
                v_expression := ' and ( statappl = '''||v_statappl||''' )';
            elsif v_statappl = ('31') then
                v_expression := ' and ( statappl = '''||v_statappl||''' or statappl >= ''40'' or statappl in (''53'',''54'',''55''))';
            elsif v_statappl = ('51') then
                v_expression := ' and ( statappl = '''||v_statappl||''' or statappl = ''61'')';
            end if;

            v_statement := 'select count(codempid), max(dtefoll) '||
                           '  from tapplinf '||
                           ' where (numreql = '||''''||p_numreqst||''''||' or numreqc = '||''''||p_numreqst||''''||') '||
                           '   and (codposl = '||''''||p_codpos||''''||' or codposc = '||''''||p_codpos||''''||') '||
                           v_expression;

            execute immediate v_statement into v_qtyappl, v_dtefoll;

            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror',200);
            obj_data.put('numreqst',p_numreqst);
            obj_data.put('codpos',p_codpos);
            obj_data.put('status',v_statappl);
            obj_data.put('desc_status',get_tlistval_name('STATAPPL',v_statappl,global_v_lang));
            obj_data.put('qtyappl',v_qtyappl);
            obj_data.put('dtereq',to_char(v_dtefoll,'dd/mm/yyyy'));
            obj_data.put('flgrecut','E');
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
    end if;
    obj_main.put('coderror','200');
    obj_main.put('qtyappl',qtyappl(p_numreqst, p_codpos, p_flgrecut));
    obj_main.put('flgrecut',p_flgrecut);
    obj_main.put('table',obj_rows);
    json_str_output := obj_main.to_clob;
  end gen_drilldown_qtyappl;

  procedure get_drilldown_qtyappl(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_drilldown_qtyappl(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_drilldown_qtyappl;

  procedure gen_drilldown_qtyappl_popup(json_str_output out clob) as
    obj_data            json_object_t;
    obj_main            json_object_t;
    v_qtyappl           number;
    v_temp              number;
    obj_rows            json_object_t;
    v_row               number := 0;
    v_statappl          tapplinf.statappl%type;
    v_expression        clob;
    v_statement         clob;
    v_dtefoll           date;
    c2_ex_tapplinf      SYS_REFCURSOR;
    v_tapplinf          tapplinf%rowtype;

    cursor c1 is
        select codempid, status, dtefoll
          from tappeinf
         where numreqst = p_numreqst
           and codpos = p_codpos
           and status = nvl(p_status,status)
      order by codempid;

    cursor c2 is
        select statappl
          from tapplinf
         where (numreql = p_numreqst or numreqc = p_numreqst)
           and (codposl = p_codpos or codposc = p_codpos)
           and statappl in ('21','22','31','51','52','56','62','42')
      group by statappl
      order by statappl;
  begin
    obj_rows := json_object_t();
    obj_main := json_object_t();
    if p_flgrecut = 'I' or  p_flgrecut = 'O' then
        for r1 in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror',200);
            obj_data.put('numappl','');
            obj_data.put('codempid',r1.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('status',get_tlistval_name('STAEMPAPL',r1.status,global_v_lang));
            obj_data.put('dtereq',to_char(r1.dtefoll,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
    end if;
    if p_flgrecut = 'E' or  p_flgrecut = 'O' then
        v_statappl  := p_status;
        if v_statappl = '21' then
            v_expression := ' and ( statappl = '''||v_statappl||''' or statappl >= ''31'')';
        elsif v_statappl in ('22','52','62','42') then
            v_expression := ' and ( statappl = '''||v_statappl||''' )';
        elsif v_statappl = ('31') then
            v_expression := ' and ( statappl = '''||v_statappl||''' or statappl >= ''40'' or statappl in (''53'',''54'',''55''))';
        elsif v_statappl = ('51') then
            v_expression := ' and ( statappl = '''||v_statappl||''' or statappl = ''61'')';
        elsif v_statappl is null then
            null;
--            v_expression := ' and statappl in (''21'',''22'',''31'',''51'',''52'',''56'',''62'',''42'')';
        end if;

        v_statement := 'select * '||
                       '  from tapplinf '||
                       ' where (numreql = '||''''||p_numreqst||''''||' or numreqc = '||''''||p_numreqst||''''||') '||
                       '   and (codposl = '||''''||p_codpos||''''||' or codposc = '||''''||p_codpos||''''||') '||
                       v_expression;

--        execute immediate v_statement into v_qtyappl, v_dtefoll;
        open c2_ex_tapplinf for v_statement;
        loop
            FETCH c2_ex_tapplinf INTO v_tapplinf;
            EXIT WHEN c2_ex_tapplinf%NOTFOUND;
            v_row       := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('numappl',v_tapplinf.numappl);
            obj_data.put('codempid',v_tapplinf.codempid);
            obj_data.put('desc_codempid',get_temploy_name(v_tapplinf.codempid,global_v_lang));
            obj_data.put('status',get_tlistval_name('STATAPPL',v_tapplinf.statappl,global_v_lang));
            obj_data.put('dtereq',to_char(v_tapplinf.dtefoll,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

--        v_row := v_row + 1;
--        obj_data := json_object_t();
--        obj_data.put('coderror',200);
--        obj_data.put('numreqst',p_numreqst);
--        obj_data.put('codpos',p_codpos);
--        obj_data.put('status',v_statappl);
--        obj_data.put('desc_status',get_tlistval_name('STATAPPL',v_statappl,global_v_lang));
--        obj_data.put('qtyappl',v_qtyappl);
--        obj_data.put('dtereq',to_char(v_dtefoll,'dd/mm/yyyy'));
--        obj_data.put('flgrecut','E');
--        obj_rows.put(to_char(v_row-1),obj_data);
    end if;
    obj_main.put('coderror','200');
    obj_main.put('codpos',p_codpos);
    obj_main.put('desc_codpos',get_tpostn_name(p_codpos,global_v_lang));
    obj_main.put('table',obj_rows);
    json_str_output := obj_main.to_clob;
  end gen_drilldown_qtyappl_popup;

  procedure get_drilldown_qtyappl_popup(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_drilldown_qtyappl_popup(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_drilldown_qtyappl_popup;

  procedure gen_drilldown_qtyact(json_str_output out clob) as
    obj_data            json_object_t;
    v_qtyappl           number;
    v_temp              number;
    obj_rows            json_object_t;
    v_row               number := 0;
    v_statappl          tapplinf.statappl%type;
    v_expression        clob;
    v_statement         clob;
    v_dtefoll           date;

    cursor c1 is
        select numappl,decode(global_v_lang,'101',namempe,
                                            '102',namempt,
                                            '103',namemp3,
                                            '104',namemp4,
                                            '105',namemp5) namemp,
               stddec(amtsal,codempid,v_chken) amtsal, dteempmt
          from tapplinf
         where (numreql = p_numreqst or numreqc = p_numreqst)
           and (codposl = p_codpos or codposc = p_codpos)
           and statappl in ('51','61')
      order by numappl;
  begin
    obj_rows := json_object_t();
    for r1 in c1 loop
        v_row       := v_row + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror',200);
        obj_data.put('numseq',v_row);
        obj_data.put('numappl',r1.numappl);
        obj_data.put('desc_codempid',r1.namemp);
        obj_data.put('amtincom',to_char(r1.amtsal,'fm999,999,999,990.00'));
        obj_data.put('dtework',to_char(r1.dteempmt,'dd/mm/yyyy'));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_drilldown_qtyact;

  procedure get_drilldown_qtyact(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_drilldown_qtyact(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_drilldown_qtyact;

  procedure save_detail(json_str_input in clob,json_str_output out clob) as
    json_obj        json_object_t;
    data_obj        json_object_t;
    v_numreqst      treqest1.numreqst%type;
    v_flg           varchar(20 char);
    v_flgCopy       varchar2(1);
    v_flgDelete     boolean;
    v_codpos        treqest2.codpos%type;
    obj_syncond     json_object_t;
  begin
    initial_value(json_str_input);
    json_obj                := json_object_t(json_str_input);
    p_tab1                  := hcm_util.get_json_t(json_obj,'tab1');
    p_tab2                  := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'tab2'),'rows');
    p_tab2_sub              := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'detailTab2Sub'),'detail');
    isAdd                   := hcm_util.get_boolean_t(json_obj,'isAdd');
    isEdit                  := hcm_util.get_boolean_t(json_obj,'isEdit');
    isCopy                  := hcm_util.get_string_t(json_obj,'isCopy');

    p_numreqst              := hcm_util.get_string_t(p_tab1,'numreqst');
    p_numreqstCopy          := hcm_util.get_string_t(p_tab1,'numreqstc');
    v_treqest1.codcomp      := hcm_util.get_string_t(p_tab1,'codcomp');
    v_treqest1.codemprq     := hcm_util.get_string_t(p_tab1,'codemprq');
    v_treqest1.dtereq       := to_date(hcm_util.get_string_t(p_tab1,'dtereq'),'dd/mm/yyyy');
    v_treqest1.codempap     := hcm_util.get_string_t(p_tab1,'codempap');
    v_treqest1.dteaprov     := to_date(hcm_util.get_string_t(p_tab1,'dteaprov'),'dd/mm/yyyy');
    v_treqest1.codemprc     := hcm_util.get_string_t(p_tab1,'codemprc');
    v_treqest1.codintview   := hcm_util.get_string_t(p_tab1,'codintview');
    v_treqest1.codappchse   := hcm_util.get_string_t(p_tab1,'codappchse');
    v_treqest1.desnote      := hcm_util.get_string_t(p_tab1,'desnote');
    v_treqest1.stareq       := hcm_util.get_string_t(p_tab1,'stareq');
    v_treqest1.dterec       := to_date(hcm_util.get_string_t(p_tab1,'dterec'),'dd/mm/yyyy');
    v_treqest1.filename     := hcm_util.get_string_t(p_tab1,'filename');

    if isCopy = 'Y' then
        delete from treqest1 where numreqst = p_numreqst;
        delete from treqest2 where numreqst = p_numreqst;
    end if;

    begin
        insert into treqest1(numreqst,codcomp,codemprq,dtereq,
                             codempap,dteaprov,codemprc,codintview,codappchse,
                             desnote,stareq,dterec,filename,
                             dtecreate,codcreate,dteupd,coduser,
                             numreqstcopy)
        values(p_numreqst,v_treqest1.codcomp,v_treqest1.codemprq,v_treqest1.dtereq,
               v_treqest1.codempap,v_treqest1.dteaprov,v_treqest1.codemprc,v_treqest1.codintview,v_treqest1.codappchse,
               v_treqest1.desnote,v_treqest1.stareq,v_treqest1.dterec,v_treqest1.filename,
               sysdate,global_v_coduser,sysdate,global_v_coduser,
               p_numreqstCopy);
    exception when dup_val_on_index then
        update treqest1
           set codcomp = v_treqest1.codcomp,
               codemprq = v_treqest1.codemprq,
               dtereq = v_treqest1.dtereq,
               codempap = v_treqest1.codempap,
               dteaprov = v_treqest1.dteaprov,
               codemprc = v_treqest1.codemprc,
               codintview = v_treqest1.codintview,
               codappchse = v_treqest1.codappchse,
               desnote = v_treqest1.desnote,
               stareq = v_treqest1.stareq,
               dterec = v_treqest1.dterec,
               filename = v_treqest1.filename,
               coduser = global_v_coduser,
               dteupd = sysdate,
               numreqstcopy = p_numreqstCopy
         where numreqst = p_numreqst;
    end;

    for i in 0..p_tab2.get_size-1 loop
        data_obj    := hcm_util.get_json_t(p_tab2,to_char(i));
        v_flgCopy   := hcm_util.get_string_t(data_obj,'flgCopy');
        v_flgDelete := hcm_util.get_boolean_t(data_obj,'flgDelete');
        v_codpos    := hcm_util.get_string_t(data_obj,'codpos');

        if v_flgDelete then
            delete treqest2
             where numreqst = p_numreqst
               and codpos = v_codpos;
        elsif v_flgCopy = 'Y' then
            begin
                select *
                  into v_treqest2
                  from treqest2
                 where numreqst = p_numreqstCopy
                   and codpos = v_codpos;
            exception when others then
                v_treqest2  := null;
            end;

            begin
                insert into treqest2(numreqst,codpos,codcomp,codjob,
                                     codempmt,codbrlc,amtincom,flgrecut,
                                     dtereqm,dteopen,codrearq,codempr,
                                     flgjob,flgcond,syncond,statement,
                                     desnote,qtyreq,qtyact,amtsalavg,
                                     dtepost,dteclose,dtechoose,
                                     dteintview,dteappchse,codemprc,welfare,
                                     dtecreate,codcreate,dteupd,coduser)
                values(p_numreqst,v_codpos,v_treqest1.codcomp,v_treqest2.codjob,
                       v_treqest2.codempmt,v_treqest2.codbrlc,v_treqest2.amtincom,v_treqest2.flgrecut,
                       v_treqest2.dtereqm,v_treqest2.dteopen,v_treqest2.codrearq,v_treqest2.codempr,
                       v_treqest2.flgjob,v_treqest2.flgcond,v_treqest2.syncond,v_treqest2.statement,
                       v_treqest2.desnote,v_treqest2.qtyreq,0,null,
                       null,v_treqest2.dteclose,null,
                       null,null,v_treqest1.codemprc,v_treqest2.welfare, -- softberry || 7/03/2023 || #9058 || null,null, null,v_treqest2.welfare, -- softberry || 16/02/2023 || #8852 || null,null,null,null,
                       sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when others then
                null;
            end;
        end if;
    end loop;

    if p_tab2_sub.get_size > 0 then
        v_treqest2.codpos       := hcm_util.get_string_t(p_tab2_sub,'codpos');
        if v_treqest2.codpos is not null then
            v_treqest2.codcomp      := v_treqest1.codcomp;
            v_treqest2.codjob       := hcm_util.get_string_t(p_tab2_sub,'codjob');
            v_treqest2.codempmt     := hcm_util.get_string_t(p_tab2_sub,'codempmt');
            v_treqest2.codbrlc      := hcm_util.get_string_t(p_tab2_sub,'codbrlc');
            v_treqest2.amtincom     := hcm_util.get_string_t(p_tab2_sub,'amtincom');
            v_treqest2.flgrecut     := hcm_util.get_string_t(p_tab2_sub,'flgrecut');
            v_treqest2.dtereqm      := to_date(hcm_util.get_string_t(p_tab2_sub,'dtereqm'),'dd/mm/yyyy');
            v_treqest2.dteopen      := to_date(hcm_util.get_string_t(p_tab2_sub,'dteopen'),'dd/mm/yyyy');
            v_treqest2.codrearq     := hcm_util.get_string_t(p_tab2_sub,'codrearq');
            v_treqest2.codempr      := hcm_util.get_string_t(p_tab2_sub,'codempr');
            v_treqest2.flgjob       := hcm_util.get_string_t(p_tab2_sub,'flgjob');
            if v_treqest2.flgjob = 'Y' then
                v_treqest2.flgcond      := 'N';
            else
                v_treqest2.flgcond      := 'Y';
            end if;
            obj_syncond             := hcm_util.get_json_t(p_tab2_sub,'syncond');
            v_treqest2.syncond      := hcm_util.get_string_t(obj_syncond,'code');
            v_treqest2.statement    := hcm_util.get_string_t(obj_syncond,'statement');
            v_treqest2.desnote      := hcm_util.get_string_t(p_tab2_sub,'desnote');
            v_treqest2.welfare      := hcm_util.get_string_t(p_tab2_sub,'welfare'); -- softberry || 16/02/2023 || #8852
            v_treqest2.qtyreq       := hcm_util.get_string_t(p_tab2_sub,'qtyreq');
            v_treqest2.dteclose     := to_date(hcm_util.get_string_t(p_tab2_sub,'dteclose'),'dd/mm/yyyy');

            begin
                insert into treqest2(numreqst,codpos,codcomp,codjob,
                                     codempmt,codbrlc,amtincom,flgrecut,
                                     dtereqm,dteopen,codrearq,codempr,
                                     flgjob,flgcond,syncond,statement,
                                     desnote,qtyreq,qtyact,amtsalavg,
                                     dtepost,dteclose,dtechoose,
                                     dteintview,dteappchse,codemprc,welfare,
                                     dtecreate,codcreate,dteupd,coduser)
                values(p_numreqst,v_treqest2.codpos,v_treqest1.codcomp,v_treqest2.codjob,
                       v_treqest2.codempmt,v_treqest2.codbrlc,v_treqest2.amtincom,v_treqest2.flgrecut,
                       v_treqest2.dtereqm,v_treqest2.dteopen,v_treqest2.codrearq,v_treqest2.codempr,
                       v_treqest2.flgjob,v_treqest2.flgcond,v_treqest2.syncond,v_treqest2.statement,
                       v_treqest2.desnote,v_treqest2.qtyreq,0,null,
                       null,v_treqest2.dteclose,null,
                       null,null,v_treqest1.codemprc,v_treqest2.welfare, -- softberry || 7/03/2023 || #9058 || null,null, null,v_treqest2.welfare,  -- softberry || 16/02/2023 || #8852 || null,null,null,null,
                       sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update treqest2
                   set codcomp = v_treqest2.codcomp,
                       codjob = v_treqest2.codjob,
                       codempmt = v_treqest2.codempmt,
                       codbrlc = v_treqest2.codbrlc,
                       amtincom = v_treqest2.amtincom,
                       flgrecut = v_treqest2.flgrecut,
                       dtereqm = v_treqest2.dtereqm,
                       dteopen = v_treqest2.dteopen,
                       codrearq = v_treqest2.codrearq,
                       codempr = v_treqest2.codempr,
                       flgjob = v_treqest2.flgjob,
                       flgcond = v_treqest2.flgcond,
                       syncond = v_treqest2.syncond,
                       statement = v_treqest2.statement,
                       codemprc = v_treqest1.codemprc,
                       desnote = v_treqest2.desnote,
                       welfare = v_treqest2.welfare, -- softberry || 16/02/2023 || #8852
                       qtyreq = v_treqest2.qtyreq,
                       dteclose = v_treqest2.dteclose,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where numreqst = p_numreqst
                   and codpos = v_treqest2.codpos;
            end;
        end if;
    end if;

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
  end save_detail;
END HRRC11E;

/
