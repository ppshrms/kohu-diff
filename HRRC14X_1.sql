--------------------------------------------------------
--  DDL for Package Body HRRC14X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC14X" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        p_codapp          := 'HRRC14X';

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
    begin
--  index parameter
        p_codcomp         := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_dtereqst        := to_date(hcm_util.get_string_t(data_obj,'p_dtereqst'),'dd/mm/yyyy');
        p_dtereqen        := to_date(hcm_util.get_string_t(data_obj,'p_dtereqen'),'dd/mm/yyyy');
        p_codemprc        := hcm_util.get_string_t(data_obj,'p_codemprc');
        p_stareq          := hcm_util.get_string_t(data_obj,'p_stareq');

--  drilldown parameter
        p_numreqst        := hcm_util.get_string_t(data_obj,'p_numreqst');
        p_codpos          := hcm_util.get_string_t(data_obj,'p_codpos');

  end initial_params;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--check null parameters
    if p_dtereqst is null or p_dtereqen is null or p_codcomp is null and p_codemprc is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp
    if p_codcomp is not null then
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end;
    end if;

    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check date
    if p_dtereqst > p_dtereqen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

--  check recruiter
    if p_codemprc is not null then
        begin
            select 'X' into v_temp
            from temploy1
            where codempid = p_codemprc;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;

--      check secur2
        if secur_main.secur2(p_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;

  end check_index;

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
        obj_data.put('desc_codjobpost',get_tcodec_name('TCODJOBPOST',i.codjobpost,global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_rows;

  end gen_jobposting;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;

    cursor c1 is
        select b.dtereqm, a.numreqst, a.dtereq, a.codemprc, a.codcomp, b.codpos, b.qtyreq, b.qtyact
        from treqest1 a, treqest2 b
        where a.numreqst = b.numreqst
          and a.codcomp like nvl(p_codcomp||'%',a.codcomp)
          and a.dtereq between p_dtereqst and p_dtereqen
          and a.codemprc = nvl(p_codemprc,a.codemprc)
          and a.stareq = nvl(p_stareq,a.stareq)
        order by b.dtereqm, a.numreqst;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_count := v_count + 1;
        if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_count_secur := v_count_secur + 1;
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('dtereq',to_char(i.dtereqm,'dd/mm/yyyy'));
            obj_data.put('numreqststd',i.numreqst);
            obj_data.put('dtecre',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('codempid',i.codemprc);
            obj_data.put('desc_codempid',get_temploy_name(i.codemprc,global_v_lang));
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codpos',i.codpos);
            obj_data.put('position',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('amtreq',i.qtyreq);
            obj_data.put('aldamt',i.qtyact);
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST1');
    end if;

    if param_msg_error is null then
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  end gen_index;

  procedure gen_drilldown_tab1(json_str_output out clob) as
     obj_data        json_object_t;
     v_treqest1      treqest1%rowtype;
  begin
    begin
        select * into v_treqest1
        from treqest1
        where numreqst = p_numreqst;
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
        where numreqst = p_numreqst
          and codpos = nvl(p_codpos, codpos);

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        obj_data := json_object_t();
        v_row := v_row + 1;
        obj_data.put('position', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('desc_codjob', get_tjobcode_name(i.codjob, global_v_lang));
        obj_data.put('desc_codempmt', get_tcodec_name('TCODEMPL', i.codempmt, global_v_lang));
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

    procedure clear_ttemprpt is
        begin
            begin
                delete
                from  ttemprpt
                where codempid = global_v_codempid
                and   codapp   = p_codapp;
            exception when others then
        null;
        end;
    end clear_ttemprpt; -- clear temp

    procedure gen_report(json_str_output out clob) is
        numappl_obj         json_object_t;
        p_numseq            number;
        max_numseq          number;
        v_tab_count         number := 0;
        v_numreqst          treqest1.numreqst%type;
        v_codpos            treqest2.codpos%type;
        v_desc_codemprq     treqest1.codemprq%type;
        v_dtereq            treqest1.dtereq%type;
        v_desc_codempap     treqest1.codempap%type;
        v_dteaprov          treqest1.dteaprov%type;
        v_desc_codemprc     treqest1.codemprc%type;
        v_desc_codintview   treqest1.codintview%type;
        v_desc_codappchse   treqest1.codappchse%type;
        v_desc_stareq       treqest1.stareq%type;
        v_dterec            treqest1.dterec%type;
        v_filename          treqest1.filename%type;
        v_desnote           treqest1.desnote%type;
        v_treqest1          treqest1%rowtype;
        v_treqest2          treqest2%rowtype;
        v_flgjob_statement    tjobcode.statement%type;
        v_count_exists      number;

        cursor c1 is
            select *
              from treqest1
             where numreqst = v_numreqst;

        cursor c2 is
            select *
              from treqest2
             where numreqst = v_numreqst
               and codpos = v_codpos;

        cursor c3 is
            select *
              from tjobpost
             where numreqst = v_numreqst
               and codpos = v_codpos ;

    begin
        for i in 0..p_index_rows.get_size-1 loop
            numappl_obj     := hcm_util.get_json_t(p_index_rows,to_char(i));
            v_numreqst      := hcm_util.get_string_t(numappl_obj,'numreqststd');
            v_codpos        := hcm_util.get_string_t(numappl_obj,'codpos');

            select count(*)
              into v_count_exists
              from ttemprpt 
             where codempid = global_v_codempid
               and codapp = p_codapp
               and item1 = 'tab1'
               and item2 = v_numreqst;

--            if (v_count_exists = 0) then

            for i1 in c1 loop
                begin
                    select max(numseq) 
                      into max_numseq
                      from ttemprpt 
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;

                p_numseq := max_numseq + 1;

                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,
                                      item4,item5,item6,item7,item8,item9,item10,
                                      item11,item12,item13,item14,item15,item16)
                values (global_v_codempid,p_codapp,p_numseq,'tab1',i1.numreqst,
                        i1.codcomp || ' - ' || get_tcenter_name(i1.codcomp, global_v_lang),
                        i1.codemprq || ' - ' || get_temploy_name(i1.codemprq, global_v_lang),
                        hcm_util.get_date_buddhist_era(i1.dtereq),
                        i1.codempap || ' - ' || get_temploy_name(i1.codempap, global_v_lang),
                        hcm_util.get_date_buddhist_era(i1.dteaprov),
                        i1.codemprc || ' - ' || get_temploy_name(i1.codemprc, global_v_lang),
                        i1.codintview || ' - ' || get_temploy_name(i1.codintview, global_v_lang),
                        i1.codappchse || ' - ' || get_temploy_name(i1.codappchse, global_v_lang),
                        get_tlistval_name('TSTAREQ',i1.stareq, global_v_lang),hcm_util.get_date_buddhist_era(i1.dterec),
                        i1.filename,i1.desnote,v_codpos,nvl(i1.numreqstcopy,'-'));
            end loop;

            for i2 in c2 loop
--                v_codpos := i2.codpos;
                begin
                    select max(numseq) 
                      into max_numseq
                      from ttemprpt 
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;

                begin
                    select statement 
                      into v_flgjob_statement
                      from tjobcode
                     where codjob = i2.codjob;
                exception when no_data_found then
                    v_flgjob_statement := '';
                end;

                p_numseq := max_numseq+1;
                insert into ttemprpt (codempid,codapp,numseq,
                                      item1,item2,item3,item4,item5,
                                      item6,item7,item8,item9,item10,
                                      item11,item12,item13,item14,item15,
                                      item16,item17,item18,item19,item20,
                                      item21,item22,item23,item24,item25)
                values (global_v_codempid,p_codapp,p_numseq,
                       'tab2',v_numreqst,get_tpostn_name(i2.codpos, global_v_lang),
                       i2.codjob || ' - ' || get_tjobcode_name(i2.codjob, global_v_lang),
                       i2.codempmt || ' - ' || get_tcodec_name('TCODEMPL', i2.codempmt, global_v_lang),
                       i2.codbrlc || ' - ' || get_tcodec_name('TCODLOCA', i2.codbrlc, global_v_lang),
                       to_char(i2.amtincom,'fm999,999,999,999,990.00'),
                       get_tlistval_name('FLGRECUT', i2.flgrecut, global_v_lang),
                       hcm_util.get_date_buddhist_era(i2.dtereqm),
                       hcm_util.get_date_buddhist_era(i2.dteopen),
                       hcm_util.get_date_buddhist_era(i2.dteclose),
                       get_tlistval_name('TCODREARQ', i2.codrearq ,global_v_lang),
                       i2.codempr || ' - ' || get_temploy_name(i2.codempr, global_v_lang),i2.flgjob,
                       get_logical_desc(v_flgjob_statement),i2.flgcond,
                       get_logical_desc(i2.statement),i2.desnote,
                       i2.qtyreq,i2.qtyact,i2.codpos,v_codpos,
                       trunc(sysdate) - trunc(i2.DTEREQM) + 1,
                       i2.codpos, i2.qtyreq - i2.qtyact);

                -- get_logical_desc(i2.statement)
                v_codpos := i2.codpos;

                v_tab_count := 0;
                for i3 in c3 loop
                    begin
                        select max(numseq) 
                          into max_numseq
                          from ttemprpt 
                         where codempid = global_v_codempid
                           and codapp = p_codapp;
                        if max_numseq is null then
                            max_numseq :=0 ;
                        end if;
                    end;
                    p_numseq    := max_numseq+1;
                    v_tab_count := v_tab_count + 1;
                    insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5)
                    values (global_v_codempid,p_codapp,p_numseq,'tab3',v_numreqst,v_codpos,
                            hcm_util.get_date_buddhist_era(i3.dtepost),get_tcodec_name('TCODJOBPOST',i3.codjobpost,global_v_lang));
                end loop;
                if v_tab_count = 0 then
                    begin
                        select max(numseq) 
                          into max_numseq
                          from ttemprpt where codempid = global_v_codempid
                           and codapp = p_codapp;
                        if max_numseq is null then
                            max_numseq :=0 ;
                        end if;
                    end;
                    p_numseq := max_numseq+1;
                    insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5)
                    values (global_v_codempid,p_codapp,p_numseq,'tab3',v_numreqst,v_codpos,' ', ' ');
                end if;
             end loop; -- end c2 treqest2 loop
--             end if;
        end loop; -- end json obj loop

        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    end gen_report;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
 BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
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

 procedure get_report(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        numappl_obj    json_object_t;
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        json_obj            := json_object_t(json_str_input);
        p_index_rows        := hcm_util.get_json_t(json_obj,'p_index_rows');
        clear_ttemprpt;
--        for i in 0..p_index_rows.get_size-1 loop
        if param_msg_error is null then
            gen_report(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
--        end loop;

  end get_report;

END HRRC14X;

/
