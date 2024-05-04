--------------------------------------------------------
--  DDL for Package Body HRCO26E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO26E" as

    -- Update 28/10/2019 14:45

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp         := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
        p_codpos          := upper(hcm_util.get_string_t(json_obj,'p_codpos'));
        p_codskill        := upper(hcm_util.get_string_t(json_obj,'p_codskill'));
        p_codtency        := upper(hcm_util.get_string_t(json_obj,'p_codtency'));
        p_jobgroup        := upper(hcm_util.get_string_t(json_obj,'p_jobgroup'));
        p_codkpi          := upper(hcm_util.get_string_t(json_obj,'p_codkpi'));
    end initial_value;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select * from tjobpos
            where codcomp like p_codcomp||'%'
            order by codpos,codcomp;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('codpos',i.codpos);
            obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('fmt_codcomp',replace(get_format_codcomp(i.codcomp),'-000',''));
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codjob',i.codjob);
            obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_index;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcomp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
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
    end get_index;

    procedure insert_tlogjobpos_delete as
        v_codjobOld     tjobpos.codjob%type;
        v_jobgradeOld   tjobpos.jobgrade%type;
        v_jobgroupOld   tjobpos.jobgroup%type;
        v_joblvlstOld   tjobpos.joblvlst%type;
        v_joblvlenOld   tjobpos.joblvlen%type;
        rec_tjobpos     tjobpos%rowtype;
    begin
        begin
            select *
              into rec_tjobpos
              from tjobpos
             where codpos = p_codpos
               and codcomp = p_codcomp;
        exception when no_data_found then
            rec_tjobpos := null;
        end;
        v_codjobOld     := rec_tjobpos.codjob;
        v_jobgradeOld   := rec_tjobpos.jobgrade;
        v_jobgroupOld   := rec_tjobpos.jobgroup;
        v_joblvlstOld   := rec_tjobpos.joblvlst;
        v_joblvlenOld   := rec_tjobpos.joblvlen;

        insert into  tlogjobpos (codpos,codcomp,dtechg,joblvlsto,joblvleno,codjobo
                    ,jobgradeo,jobgroupo,dtecreate,codcreate,dteupd,coduser)
             values (p_codpos,p_codcomp,sysdate,v_joblvlstOld,v_joblvlenOld,v_codjobOld
                    ,v_jobgradeOld,v_jobgroupOld,sysdate,global_v_coduser,sysdate,global_v_coduser);
    end insert_tlogjobpos_delete;

    procedure delete_tjobpos(json_str_output out clob) as
        json_obj json_object_t;
    begin
        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            p_codpos    := upper(hcm_util.get_string_t(json_obj,'codpos'));
            p_codcomp   := upper(hcm_util.get_string_t(json_obj,'codcomp'));
            insert_tlogjobpos_delete;
            -- Competency
            delete tjobposskil
             where codpos  = p_codpos
               and codcomp = p_codcomp;
            -- KPI
            delete tjobkpi
             where codpos  = p_codpos
               and codcomp = p_codcomp;

            delete tjobkpip
             where codpos  = p_codpos
               and codcomp = p_codcomp;

            delete tjobkpig
             where codpos  = p_codpos
               and codcomp = p_codcomp;
            -- JOB
            delete tjobpos
             where codpos  = p_codpos
               and codcomp = p_codcomp;
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
    end delete_tjobpos;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        delete_tjobpos(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

    procedure check_get_detail as
        v_temp  varchar2(1 char);
        v_count number;
    begin
        if (p_codcomp is null) or (p_codpos is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from tpostn
            where codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp = p_codcomp
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
        if p_codskill is not null then
            begin
                select 'X' into v_temp from tcodskil where codcodec = p_codskill;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodskil');
                return;
            end;
            begin
                select count(*)
                  into v_count
                  from tjobposskil
                 where codpos = p_codpos
                   and codcomp = p_codcomp
                   and codskill = p_codskill
                   and codtency <> p_codtency;
            exception when no_data_found then
                v_count := 0;
            end;
        end if;
        if v_count > 0 then
            param_msg_error := get_error_msg_php('CO0010',global_v_lang);
            return;
        end if;
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_get_detail;

    function gen_kpi return json_object_t as
        obj_rows            json_object_t;
        obj_data            json_object_t;
        obj_data_child      json_object_t;
        obj_tjobkpip        json_object_t;
        obj_tjobkpig        json_object_t;
        v_row               number := 0;
        v_row_child         number := 0;
        v_kodkpi            tjobkpi.codkpi%type;

        cursor c1 is
            select *
              from tjobkpi
             where codpos = p_codpos
               and codcomp = p_codcomp
          order by codkpi;

        cursor c2 is
            select *
              from tjobkpip
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codkpi = v_kodkpi
          order by codkpi,planlvl;

        cursor c3 is
            select *
              from tjobkpig
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codkpi = v_kodkpi
          order by qtyscor desc;
    begin
        obj_rows := json_object_t();
        obj_tjobkpip        := json_object_t();
        obj_tjobkpig        := json_object_t();
        for r1 in c1 loop
            v_kodkpi    := r1.codkpi;
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror',200);
            obj_data.put('codkpi',r1.codkpi);
            obj_data.put('kpiitem',r1.kpiitem);
            obj_data.put('target',r1.target);
            obj_data.put('kpivalue',r1.kpivalue);

            v_row_child         := 0;
            obj_tjobkpip        := json_object_t();
            for r2 in c2 loop
                v_row_child     := v_row_child + 1;
                obj_data_child  := json_object_t();
                obj_data_child.put('coderror',200);
                obj_data_child.put('planlvl',r2.planlvl);
                obj_data_child.put('plandesc',r2.plandesc);
                obj_tjobkpip.put(to_char(v_row_child-1),obj_data_child);
            end loop;
            obj_data.put('tjobkpip',obj_tjobkpip);

            v_row_child         := 0;
            obj_tjobkpig        := json_object_t();
            for r3 in c3 loop
                v_row_child     := v_row_child + 1;
                obj_data_child  := json_object_t();
                obj_data_child.put('coderror',200);
                if r3.qtyscor = 5 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: blue;"></i>');
                elsif r3.qtyscor = 4 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: green;"></i>');
                elsif r3.qtyscor = 3 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: yellow;"></i>');
                elsif r3.qtyscor = 2 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: orange;"></i>');
                elsif r3.qtyscor = 1 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: red;"></i>');
                end if;
                obj_data_child.put('qtyscor',r3.qtyscor);
                obj_data_child.put('descgrd',r3.descgrd);
                obj_data_child.put('flgkpi',r3.flgkpi);
                obj_tjobkpig.put(to_char(v_row_child-1),obj_data_child);
            end loop;
            obj_data.put('tjobkpig',obj_tjobkpig);

            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_rows;
    end gen_kpi;

--    gen-codtency from jobgroup
    procedure gen_codtency (p_jobgroup varchar2,json_str_output out clob) as
    obj_rows json_object_t;
    obj_data json_object_t;
    v_row number := 0;
    cursor cten is
        select codtency
        from tjobgroup
        where jobgroup  = p_jobgroup
        group by codtency
        order by  codtency;
    begin
        obj_rows := json_object_t();
        for rten in cten loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codtency',rten.codtency);
            obj_data.put('desc_codtency',get_tcomptnc_name(rten.codtency,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
        exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_codtency;

    function gen_competency return json_object_t as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        obj_rows_child    json_object_t;
        obj_data_child    json_object_t;
        obj_table   json_object_t;
        v_row number := 0;
        v_row_child number := 0;
        v_codtency  tjobscore.codtency%type;
        v_codskill  tjobscore.codskill%type;
        cursor c2 is
            select a.codtency, a.codskill,a.grade,a.fscore,a.score
            from tjobposskil a
            where a.codpos  = p_codpos
            and a.codcomp = p_codcomp
            order by  a.codtency, a.codskill;

        cursor c3 is
            select codpos, codcomp, codtency, codskill, grade, score
              from tjobscore
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codtency =  v_codtency
               and codskill =  v_codskill
          order by grade;
    begin
        obj_rows := json_object_t();
        for r2 in c2 loop
            v_row := v_row + 1;
            obj_data    := json_object_t();

            obj_rows_child := json_object_t();
            v_codtency  := r2.codtency;
            v_codskill  := r2.codskill;
            v_row_child := 0;
            for r3 in c3 loop
                v_row_child         := v_row_child + 1;
                obj_data_child      := json_object_t();
                obj_data_child.put('fscore',r2.fscore);
                obj_data_child.put('grade',to_char(r3.grade));
                obj_data_child.put('score',r3.score);
                obj_rows_child.put(to_char(v_row_child-1),obj_data_child);
            end loop;

            obj_data.put('codtency',r2.codtency);
            obj_data.put('desc_codtency',get_tcomptnc_name(r2.codtency,global_v_lang));
            obj_data.put('codskill',r2.codskill);
            obj_data.put('desc_codskill',get_tcodec_name ('TCODSKIL',r2.codskill,global_v_lang));
            obj_data.put('grade',to_char(r2.grade));
            obj_data.put('fscore',r2.fscore);
            obj_data.put('score',r2.score);
            obj_data.put('table',obj_rows_child);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_rows;
    end gen_competency;

--  get-codtency from jobgroup

    procedure gen_popup_codtency (json_str_output out clob) as
    obj_data json_object_t;
    obj_rows_child    json_object_t;
    obj_data_child    json_object_t;
    v_row_child number := 0;
    v_row number := 0;
    v_tjobposskil       tjobposskil%rowtype;

    cursor c2 is
        select codpos, codcomp, codtency, codskill, grade, score
          from tjobscore
         where codpos = p_codpos
           and codcomp = p_codcomp
           and codtency =  p_codtency
           and codskill =  p_codskill
      order by grade;
    begin
        obj_data    := json_object_t();
        begin
            select *
              into v_tjobposskil
              from tjobposskil a
             where a.codpos  = p_codpos
               and a.codcomp = p_codcomp
               and a.codtency = p_codtency
               and a.codskill = p_codskill
            order by  a.codtency, a.codskill;
        exception when no_data_found then
            v_tjobposskil := null;
        end;

        obj_data    := json_object_t();
        obj_data.put('coderror',200);
        obj_rows_child := json_object_t();
        v_row_child := 0;
        for r2 in c2 loop
            v_row_child         := v_row_child + 1;
            obj_data_child      := json_object_t();
            obj_data_child.put('fscore',v_tjobposskil.fscore);
            obj_data_child.put('grade',to_char(r2.grade));
            obj_data_child.put('score',r2.score);
            obj_rows_child.put(to_char(v_row_child-1),obj_data_child);
        end loop;

        obj_data.put('codtency',p_codtency);
        obj_data.put('desc_codtency',get_tcomptnc_name(p_codtency,global_v_lang));
        obj_data.put('codskill',p_codskill);
        obj_data.put('desc_codskill',get_tcodec_name ('TCODSKIL',p_codskill,global_v_lang));
        obj_data.put('grade',to_char(v_tjobposskil.grade));
        obj_data.put('fscore',v_tjobposskil.fscore);
        obj_data.put('score',v_tjobposskil.score);
        obj_data.put('table',obj_rows_child);
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_popup_codtency;

    procedure get_popup_codtency(json_str_input in clob, json_str_output out clob) as
        json_obj json_object_t;
        v_row       number := 0;
    begin
        initial_value(json_str_input);
        json_obj     := json_object_t(json_str_input);
        if param_msg_error is null then
            gen_popup_codtency(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_popup_codtency;

    function gen_competency_jobgroup return json_object_t as
        obj_rows            json_object_t;
        obj_rows_child      json_object_t;
        obj_data            json_object_t;
        obj_table           json_object_t;
        v_row               number := 0;
        v_codtency          tjobscore.codtency%type;
        v_codskill          tjobscore.codskill%type;
        v_jobgroupo         tjobpos.jobgroup%type;
        cursor c1 is
            select a.codtency, a.codskill
            from tjobgroup a
            where jobgroup = p_jobgroup
            order by  a.codtency, a.codskill;
        cursor c2 is
            select a.codtency, a.codskill
            from tjobgroup a
            where jobgroup = p_jobgroup
            order by  a.codtency, a.codskill;
    begin

        begin
            select jobgroup
              into v_jobgroupo
              from tjobpos
             where codpos = p_codpos
               and codcomp = p_codcomp;
        exception when no_data_found then
            v_jobgroupo := null;
        end;

        if v_jobgroupo = p_jobgroup and v_jobgroupo is not null then
            obj_rows := gen_competency;
        else
            obj_rows := json_object_t();
            for r2 in c2 loop
                v_row := v_row + 1;
                obj_data    := json_object_t();

                obj_rows_child := json_object_t();

                obj_data.put('codtency',r2.codtency);
                obj_data.put('desc_codtency',get_tcomptnc_name(r2.codtency,global_v_lang));
                obj_data.put('codskill',r2.codskill);
                obj_data.put('desc_codskill',get_tcodec_name ('TCODSKIL',r2.codskill,global_v_lang));
                obj_data.put('grade','');
                obj_data.put('fscore','');
                obj_data.put('score','');
                obj_data.put('table',obj_rows_child);
                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        end if;
        return obj_rows;
    end gen_competency_jobgroup;

    procedure get_competency(json_str_input in clob, json_str_output out clob) as
        obj_result  json_object_t;
        v_row       number := 0;
    begin
        initial_value(json_str_input);
--        check_get_detail;
        if param_msg_error is null then
            obj_result := json_object_t();
            obj_result := gen_competency_jobgroup;
            json_str_output := obj_result.to_clob;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_competency;

    procedure gen_detail(json_str_output out clob) as
        obj_result json_object_t;
        obj_tab1 json_object_t;
        obj_tab2 json_object_t;
        obj_tab3 json_object_t;
        obj_data json_object_t;
        v_row number := 0;
        rec_tjobpos tjobpos%rowtype;

    begin
        obj_result := json_object_t();
        obj_result.put('coderror','200');
        begin
            select * into rec_tjobpos
            from tjobpos
            where codpos = p_codpos
            and codcomp = p_codcomp;
        exception when no_data_found then
            rec_tjobpos := null;
        end;
        obj_tab1 := json_object_t();
        obj_tab1.put('codpos',p_codpos);
        obj_tab1.put('codcomp',p_codcomp);
        obj_tab1.put('desc_codpos',get_tpostn_name(p_codpos,global_v_lang));
        obj_tab1.put('joblvlst',rec_tjobpos.joblvlst);
        obj_tab1.put('joblvlen',rec_tjobpos.joblvlen);
        obj_tab1.put('codjob',rec_tjobpos.codjob);
        obj_tab1.put('jobgrade',rec_tjobpos.jobgrade);
        obj_tab1.put('jobgroup',rec_tjobpos.jobgroup);
        obj_tab1.put('remarks',rec_tjobpos.remarks);
        obj_result.put('tjobpos',obj_tab1);

        obj_result.put('tjobkpi',gen_kpi);

        obj_result.put('tjobposskil',gen_competency);

        json_str_output := obj_result.to_clob;
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_get_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure check_tab_tjobpos as
        v_temp      varchar2(1 char);
        v_codjob    tjobpos.codjob%type;
        v_jobgrade  tjobpos.jobgrade%type;
        v_jobgroup  tjobpos.jobgroup%type;
        v_joblvlst  tjobpos.joblvlst%type;
        v_joblvlen  tjobpos.joblvlen%type;
    begin
        v_codjob    := upper(hcm_util.get_string_t(param_tjobpos,'codjob'));
        v_jobgrade  := upper(hcm_util.get_string_t(param_tjobpos,'jobgrade'));
        v_jobgroup  := upper(hcm_util.get_string_t(param_tjobpos,'jobgroup'));
        v_joblvlst  := to_number(hcm_util.get_string_t(param_tjobpos,'joblvlst'));
        v_joblvlen  := to_number(hcm_util.get_string_t(param_tjobpos,'joblvlen'));
        if (p_codcomp is null) or (p_codpos is null) or (v_codjob is null) or
           (v_jobgrade is null) or (v_jobgroup is null) or (v_joblvlst is null) or
           (v_joblvlen is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from tpostn
            where codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
        if v_joblvlst > v_joblvlen then
            param_msg_error := get_error_msg_php('HR2075',global_v_lang);
            return;
        end if;
        if v_codjob is not null then
            begin
                select 'X'
                  into v_temp
                  from tjobcode
                 where codjob = v_codjob;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tjobcode');
                return;
            end;
        end if;
        if v_jobgrade is not null then
            begin
                select 'X'
                  into v_temp
                  from tcodjobg
                 where codcodec = v_jobgrade;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodjobg');
                return;
            end;
        end if;
        if v_jobgroup is not null then
            begin
                select 'X'
                  into v_temp
                  from tcodjobgrp
                 where jobgroup = v_jobgroup;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodjobgrp');
                return;
            end;
        end if;
    end check_tab_tjobpos;

    procedure insert_tlogjobpos(v_flgedit varchar2) as
        v_codjob        tjobpos.codjob%type;
        v_jobgrade      tjobpos.jobgrade%type;
        v_jobgroup      tjobpos.jobgroup%type;
        v_joblvlst      tjobpos.joblvlst%type;
        v_joblvlen      tjobpos.joblvlen%type;
        v_codjobOld     tjobpos.codjob%type;
        v_jobgradeOld   tjobpos.jobgrade%type;
        v_jobgroupOld   tjobpos.jobgroup%type;
        v_joblvlstOld   tjobpos.joblvlst%type;
        v_joblvlenOld   tjobpos.joblvlen%type;
        rec_tjobpos     tjobpos%rowtype;
    begin
        v_codjob        := upper(hcm_util.get_string_t(param_tjobpos,'codjob'));
        v_jobgrade      := upper(hcm_util.get_string_t(param_tjobpos,'jobgrade'));
        v_jobgroup      := upper(hcm_util.get_string_t(param_tjobpos,'jobgroup'));
        v_joblvlst      := to_number(hcm_util.get_string_t(param_tjobpos,'joblvlst'));
        v_joblvlen      := to_number(hcm_util.get_string_t(param_tjobpos,'joblvlen'));
        begin
            select *
              into rec_tjobpos
              from tjobpos
             where codpos = p_codpos
               and codcomp = p_codcomp;
        exception when no_data_found then
            rec_tjobpos := null;
        end;
        v_codjobOld     := rec_tjobpos.codjob;
        v_jobgradeOld   := rec_tjobpos.jobgrade;
        v_jobgroupOld   := rec_tjobpos.jobgroup;
        v_joblvlstOld   := rec_tjobpos.joblvlst;
        v_joblvlenOld   := rec_tjobpos.joblvlen;
        if v_flgedit = 'Add' then
            begin
                insert into tlogjobpos (codpos,codcomp,dtechg,joblvlstn,joblvlenn,codjobn
                            ,jobgraden,jobgroupn,dtecreate,codcreate,dteupd,coduser)
                     values (p_codpos,p_codcomp,sysdate,v_joblvlst,v_joblvlen,v_codjob
                            ,v_jobgrade,v_jobgroup,sysdate,global_v_coduser,sysdate
                            ,global_v_coduser);
            exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            end ;
        elsif v_flgedit = 'Edit' then
            if v_codjob = v_codjobOld then
                v_codjob        := null;
                v_codjobOld     := null;
            end if;
            if v_jobgrade = v_jobgradeOld then
                v_jobgrade      := null;
                v_jobgradeOld   := null;
            end if;
            if v_jobgroup = v_jobgroupOld then
                v_jobgroup      := null;
                v_jobgroupOld   := null;
            end if;
            if v_joblvlst = v_joblvlstOld then
                v_joblvlst      := null;
                v_joblvlstOld   := null;
            end if;
            if v_joblvlen = v_joblvlenOld then
                v_joblvlen      := null;
                v_joblvlenOld   := null;
            end if;
            begin
                insert into  tlogjobpos (codpos,codcomp,dtechg,joblvlsto,joblvleno,codjobo
                            ,jobgradeo,jobgroupo,joblvlstn,joblvlenn,codjobn,jobgraden
                            ,jobgroupn,dtecreate,codcreate,dteupd,coduser)
                     values (p_codpos,p_codcomp,sysdate,v_joblvlstOld,v_joblvlenOld,v_codjobOld
                            ,v_jobgradeOld,v_jobgroupOld,v_joblvlst,v_joblvlen,v_codjob,v_jobgrade
                            ,v_jobgroup,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            end ;
        end if;
    end insert_tlogjobpos;

    procedure save_tjobpos as
        v_codjob        tjobpos.codjob%type;
        v_jobgrade      tjobpos.jobgrade%type;
        v_jobgroup      tjobpos.jobgroup%type;
        v_joblvlst      tjobpos.joblvlst%type;
        v_joblvlen      tjobpos.joblvlen%type;
        v_remarks       tjobpos.remarks%type;
        obj_codkpi      json_object_t;
        obj_codtency    json_object_t;
        v_codkpi        tjobkpi.codkpi%type;
        v_codtency      tjobposskil.codtency%type;
        v_codskill      tjobposskil.codskill%type;
        json_obj        json_object_t;
        v_count         number;
    begin
        v_codjob        := upper(hcm_util.get_string_t(param_tjobpos,'codjob'));
        v_jobgrade      := upper(hcm_util.get_string_t(param_tjobpos,'jobgrade'));
        v_jobgroup      := upper(hcm_util.get_string_t(param_tjobpos,'jobgroup'));
        v_joblvlst      := to_number(hcm_util.get_string_t(param_tjobpos,'joblvlst'));
        v_joblvlen      := to_number(hcm_util.get_string_t(param_tjobpos,'joblvlen'));
        v_remarks       := hcm_util.get_string_t(param_tjobpos,'remarks');
        begin
            select count(*)
              into v_count
              from tjobpos
             where codpos   = p_codpos
               and codcomp  = p_codcomp;
        exception when others then
            v_count :=0;
        end ;

        if v_count = 0 then
            insert_tlogjobpos('Add');
            insert into tjobpos (codpos,codcomp,codjob,joblvlst,joblvlen,jobgrade
                        ,jobgroup,remarks,codcreate,coduser,dtecreate,dteupd)
                 values (p_codpos,p_codcomp,v_codjob,v_joblvlst,v_joblvlen
                        ,v_jobgrade,v_jobgroup,v_remarks,global_v_coduser
                        ,global_v_coduser,sysdate,sysdate);
        else
            insert_tlogjobpos('Edit');
            update tjobpos
               set codjob   = v_codjob,
                   joblvlst = v_joblvlst,
                   joblvlen = v_joblvlen,
                   jobgrade = v_jobgrade,
                   jobgroup = v_jobgroup,
                   remarks  = v_remarks,
                   coduser  = global_v_coduser,
                   dteupd   = sysdate
             where codpos   = p_codpos
               and codcomp  = p_codcomp;
        end if;

        -- Delete KPI
--        for i_kpi in 0..obj_codkpi.get_size-1 loop
--            v_codkpi    := upper(hcm_util.get_string_t(obj_codkpi,to_char(i_kpi)));
--            delete tjobkpi
--             where codpos  = p_codpos
--               and codcomp = p_codcomp
--               and codkpi  = v_codkpi;
--
--            delete tjobkpip
--             where codpos  = p_codpos
--               and codcomp = p_codcomp
--               and codkpi  = v_codkpi;
--
--            delete tjobkpig
--             where codpos  = p_codpos
--               and codcomp = p_codcomp
--               and codkpi  = v_codkpi;
--        end loop;
        -- Delete Competency
--        for i_codtency in 0..obj_codtency.get_size-1 loop
--            json_obj    := hcm_util.get_json_t(obj_codtency,to_char(i_codtency));
--            v_codtency  := upper(hcm_util.get_string_t(json_obj,'codtency'));
--            v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
--            delete tjobposskil
--             where codpos  = p_codpos
--               and codcomp = p_codcomp
--               and codskill = v_codskill
--               and codtency = v_codtency;
--
--            delete tjobscore
--             where codpos  = p_codpos
--               and codcomp = p_codcomp
--               and codskill = v_codskill
--               and codtency = v_codtency;
--
--        end loop;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end save_tjobpos;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        v_flgedit   varchar2(10 char);
        xx clob;
    begin
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);
        param_tjobpos       := hcm_util.get_json_t(json_obj,'tjobpos');
        p_codcomp           := upper(hcm_util.get_string_t(param_tjobpos,'codcomp'));
        p_codpos            := upper(hcm_util.get_string_t(param_tjobpos,'codpos'));
        param_json1         := hcm_util.get_json_t(json_obj,'param_json1');
        param_json2         := hcm_util.get_json_t(json_obj,'param_json2');
        check_tab_tjobpos;
        if param_msg_error is null then
            save_tjobpos;
        end if;
        if param_msg_error is null then
            save_kpi;
        end if;
        if param_msg_error is null then
            save_competency;
        end if;

        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message(400,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure gen_kpi_detail(p_codkpi varchar2, json_str_output out clob) as
        obj_result json_object_t;
        obj_tab1 json_object_t;
        obj_tab2 json_object_t;
        obj_rows json_object_t;
        obj_data json_object_t;
        v_row number := 0;
        rec_tjobkpi tjobkpi%rowtype;
        cursor c1 is
            select planlvl,plandesc from tjobkpip
            where codpos = p_codpos
            and codcomp = p_codcomp
            and codkpi = p_codkpi
            order by planlvl;
        cursor c2 is
            select * from tjobkpig
            where codpos = p_codpos
            and codcomp = p_codcomp
            and codkpi = p_codkpi
            order by qtyscor desc;
    begin
        obj_result := json_object_t();
        begin
            select * into rec_tjobkpi
            from tjobkpi
            where codpos = p_codpos
            and codcomp = p_codcomp
            and codkpi = p_codkpi;
            obj_result.put('flgedit','Edit');
        exception when no_data_found then
            obj_result.put('flgedit','Add');
            rec_tjobkpi := null;
        end;
        obj_result.put('kpiitem',rec_tjobkpi.kpiitem);
        obj_result.put('target',rec_tjobkpi.target);
        obj_result.put('kpivalue',rec_tjobkpi.kpivalue);

        obj_rows := json_object_t();
        for r1 in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('planlvl',r1.planlvl);
            obj_data.put('plandesc',r1.plandesc);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_tab1 := json_object_t();
        obj_tab1.put('rows',obj_rows);
        obj_result.put('tab1',obj_tab1);

        obj_rows := json_object_t();
        v_row := 0;
        for r2 in c2 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('qtyscor',r2.qtyscor);
            obj_data.put('flgkpi',r2.flgkpi);
            obj_data.put('descgrd',r2.descgrd);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_tab2 := json_object_t();
        obj_tab2.put('rows',obj_rows);
        obj_result.put('tab2',obj_tab2);

        obj_data := json_object_t();
        obj_data.put('rows',obj_result);
        json_str_output := obj_data.to_clob;
    end gen_kpi_detail;

    procedure check_save_kpi as
        v_kpiitem   tjobkpi.kpiitem%type;
        v_target    tjobkpi.target%type;
        obj_tab1    json_object_t;
        obj_tab2    json_object_t;
        obj_data    json_object_t;
        v_plandesc  tjobkpip.plandesc%type;
        v_descgrd   tjobkpig.descgrd%type;
        v_flgkpi    tjobkpig.flgkpi%type;
    begin
        v_kpiitem   := hcm_util.get_string_t(param_json,'kpiitem');
        v_target    := hcm_util.get_string_t(param_json,'target');
        obj_tab1    := hcm_util.get_json_t(param_json,'tab1');
        obj_tab2    := hcm_util.get_json_t(param_json,'tab2');
        if (v_kpiitem is null) or (v_target is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        for i_t1 in 0..obj_tab1.get_size-1 loop
            obj_data    := hcm_util.get_json_t(obj_tab1,to_char(i_t1));
            v_plandesc  := hcm_util.get_string_t(obj_data,'plandesc');
            if v_plandesc is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
        end loop;
        for i_t2 in 0..obj_tab2.get_size-1 loop
            obj_data    := hcm_util.get_json_t(obj_tab2,to_char(i_t2));
            v_descgrd   := hcm_util.get_string_t(obj_data,'descgrd');
            v_flgkpi    := hcm_util.get_string_t(obj_data,'flgkpi');
            if (v_descgrd is null) or (v_flgkpi is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
        end loop;
    end check_save_kpi;

    procedure save_data_kpi(v_codkpi varchar2,v_flgedit varchar2,json_str_output out clob) as
        v_kpiitem   tjobkpi.kpiitem%type;
        v_target    tjobkpi.target%type;
        v_kpivalue  tjobkpi.kpivalue%type;
        obj_tab1    json_object_t;
        obj_tab2    json_object_t;
        obj_data    json_object_t;
        v_planlvl   tjobkpip.planlvl%type;
        v_plandesc  tjobkpip.plandesc%type;
        v_qtyscor   tjobkpig.qtyscor%type;
        v_descgrd   tjobkpig.descgrd%type;
        v_flgkpi    tjobkpig.flgkpi%type;
        v_flgedit_item  varchar2(10 char);
        v_temp      varchar2(1 char);
    begin
        v_kpiitem   := hcm_util.get_string_t(param_json,'kpiitem');
        v_target    := hcm_util.get_string_t(param_json,'target');
        v_kpivalue  := to_number(hcm_util.get_string_t(param_json,'kpivalue'));
        obj_tab1    := hcm_util.get_json_t(param_json,'tab1');
        obj_tab2    := hcm_util.get_json_t(param_json,'tab2');
        if v_flgedit = 'Add' or v_flgedit = 'Edit' then
            begin
                insert into tjobkpi (codpos,codcomp,codkpi,kpiitem,target,kpivalue
                                    ,dtecreate,codcreate,dteupd,coduser)
                     values (p_codpos,p_codcomp,v_codkpi,v_kpiitem,v_target,v_kpivalue
                            ,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tjobkpi
                   set kpiitem = v_kpiitem,
                       target  = v_target,
                       kpivalue = v_kpivalue,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codpos = p_codpos
                   and codcomp = p_codcomp
                   and codkpi = v_codkpi;
            end;
        end if;
        for i_t1 in 0..obj_tab1.get_size-1 loop
            obj_data        := hcm_util.get_json_t(obj_tab1,to_char(i_t1));
            v_planlvl       := to_number(hcm_util.get_string_t(obj_data,'planlvl'));
            v_plandesc      := hcm_util.get_string_t(obj_data,'plandesc');
            v_flgedit_item  := hcm_util.get_string_t(obj_data,'flgedit');
            if v_flgedit_item = 'Add' then
                begin
                    insert into tjobkpip (codpos,codcomp,codkpi,planlvl,plandesc
                                         ,dtecreate,codcreate,dteupd,coduser)
                         values (p_codpos,p_codcomp,v_codkpi,v_planlvl,v_plandesc
                                ,sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tjobkpip');
                    exit;
                end;
            elsif v_flgedit_item = 'Edit' then
                update tjobkpip
                       set plandesc = v_plandesc
                     where codpos = p_codpos
                       and codcomp = p_codcomp
                       and codkpi = v_codkpi
                       and planlvl = v_planlvl;
            elsif v_flgedit_item = 'Delete' then
                delete from tjobkpip
                      where codpos = p_codpos
                        and codcomp = p_codcomp
                        and codkpi = v_codkpi
                        and planlvl = v_planlvl;
            end if;
        end loop;
        for i_t2 in 0..obj_tab2.get_size-1 loop
            obj_data    := hcm_util.get_json_t(obj_tab2,to_char(i_t2));
            v_qtyscor   := to_number(hcm_util.get_string_t(obj_data,'qtyscor'));
            v_descgrd   := hcm_util.get_string_t(obj_data,'descgrd');
            v_flgkpi    := upper(hcm_util.get_string_t(obj_data,'flgkpi'));
            v_flgedit_item  := hcm_util.get_string_t(obj_data,'flgedit');
            begin
                select 'X'
                  into v_temp
                  from tjobkpig
                 where codpos = p_codpos
                   and codcomp = p_codcomp
                   and codkpi = v_codkpi
                   and qtyscor = v_qtyscor;
                -- update
                update tjobkpig
                   set descgrd = v_descgrd,
                       flgkpi = v_flgkpi
                 where codpos = p_codpos
                   and codcomp = p_codcomp
                   and codkpi = v_codkpi
                   and qtyscor = v_qtyscor;
            exception when no_data_found then
                insert into tjobkpig (codpos,codcomp,codkpi,qtyscor,flgkpi
                                     ,descgrd,dtecreate,codcreate,dteupd,coduser)
                              values (p_codpos,p_codcomp,v_codkpi,v_qtyscor
                                     ,v_flgkpi,v_descgrd,sysdate,global_v_coduser
                                     ,sysdate,global_v_coduser);
            end;
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
    end save_data_kpi;

    procedure save_kpi as
        v_flgAdd        boolean;
        v_flgDelete     boolean;
        v_flgEdit       boolean;
        json_obj        json_object_t;
        obj_codkpi      json_object_t;
        v_codkpi        tjobkpi.codkpi%type;
        v_kpiitem       tjobkpi.kpiitem%type;
        v_kpivalue      tjobkpi.kpivalue%type;
        v_target        tjobkpi.target%type;
        obj_tab1        json_object_t;
        obj_tab2        json_object_t;
        obj_data        json_object_t;
        v_planlvl       tjobkpip.planlvl%type;
        v_plandesc      tjobkpip.plandesc%type;
        v_qtyscor       tjobkpig.qtyscor%type;
        v_descgrd       tjobkpig.descgrd%type;
        v_flgkpi        tjobkpig.flgkpi%type;

        v_flgAdd_child        boolean;
        v_flgDelete_child     boolean;
        v_flgEdit_child       boolean;
    begin
        obj_codkpi  := hcm_util.get_json_t(param_json1,'rows');

--        check_save_kpi;

        for i_kpi in 0..obj_codkpi.get_size-1 loop
            json_obj        := hcm_util.get_json_t(obj_codkpi,to_char(i_kpi));
            v_codkpi        := upper(hcm_util.get_string_t(json_obj,'codkpi'));
            v_flgAdd        := hcm_util.get_boolean_t(json_obj,'flgAdd');
            v_flgDelete     := hcm_util.get_boolean_t(json_obj,'flgDelete');
            v_flgEdit       := hcm_util.get_boolean_t(json_obj,'flgEdit');
            v_kpiitem       := hcm_util.get_string_t(json_obj,'kpiitem');
            v_kpivalue      := hcm_util.get_string_t(json_obj,'kpivalue');
            v_target        := hcm_util.get_string_t(json_obj,'target');
            obj_tab1        := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'tjobkpip'),'rows');
            obj_tab2        := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'tjobkpig'),'rows');

            if v_flgDelete then
                delete tjobkpi
                 where codpos  = p_codpos
                   and codcomp = p_codcomp
                   and codkpi  = v_codkpi;

                delete tjobkpip
                 where codpos  = p_codpos
                   and codcomp = p_codcomp
                   and codkpi  = v_codkpi;

                delete tjobkpig
                 where codpos  = p_codpos
                   and codcomp = p_codcomp
                   and codkpi  = v_codkpi;
            else
                begin
                    insert into tjobkpi (codpos,codcomp,codkpi,kpiitem,target,kpivalue
                                        ,dtecreate,codcreate,dteupd,coduser)
                         values (p_codpos,p_codcomp,v_codkpi,v_kpiitem,v_target,v_kpivalue
                                ,sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tjobkpi
                       set kpiitem = v_kpiitem,
                           target  = v_target,
                           kpivalue = v_kpivalue,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codpos = p_codpos
                       and codcomp = p_codcomp
                       and codkpi = v_codkpi;
                end;

                for i_t1 in 0..obj_tab1.get_size-1 loop
                    obj_data            := hcm_util.get_json_t(obj_tab1,to_char(i_t1));
                    v_plandesc          := hcm_util.get_string_t(obj_data,'plandesc');
                    v_planlvl           := hcm_util.get_string_t(obj_data,'planlvl');
                    v_flgAdd_child      := hcm_util.get_boolean_t(obj_data,'flgAdd');
                    v_flgDelete_child   := hcm_util.get_boolean_t(obj_data,'flgDelete');
                    v_flgEdit_child     := hcm_util.get_boolean_t(obj_data,'flgEdit');
                    if v_flgDelete_child then
                        delete from tjobkpip
                              where codpos = p_codpos
                                and codcomp = p_codcomp
                                and codkpi = v_codkpi
                                and planlvl = v_planlvl;
                    elsif v_flgAdd_child then
                        begin
                            select max(planlvl)
                              into v_planlvl
                              from tjobkpip
                             where codpos = p_codpos
                               and codcomp = p_codcomp
                               and codkpi = v_codkpi;
                        exception when no_data_found then
                            v_planlvl := 0;
                        end;
                        v_planlvl := nvl(v_planlvl,0) + 1;
                        begin
                            insert into tjobkpip (codpos,codcomp,codkpi,planlvl,plandesc
                                                 ,dtecreate,codcreate,dteupd,coduser)
                                 values (p_codpos,p_codcomp,v_codkpi,v_planlvl,v_plandesc
                                        ,sysdate,global_v_coduser,sysdate,global_v_coduser);
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tjobkpip');
                            exit;
                        end;
                    elsif v_flgEdit_child then
                        update tjobkpip
                               set plandesc = v_plandesc,
                                   dteupd = sysdate,
                                   coduser = global_v_coduser
                             where codpos = p_codpos
                               and codcomp = p_codcomp
                               and codkpi = v_codkpi
                               and planlvl = v_planlvl;
                    end if;
                end loop;

                update tjobkpip
                   set planlvl = ROWNUM
                 where codpos = p_codpos
                   and codcomp = p_codcomp
                   and codkpi = v_codkpi;

                for i_t2 in 0..obj_tab2.get_size-1 loop
                    obj_data    := hcm_util.get_json_t(obj_tab2,to_char(i_t2));
                    v_qtyscor   := to_number(hcm_util.get_string_t(obj_data,'qtyscor'));
                    v_descgrd   := hcm_util.get_string_t(obj_data,'descgrd');
                    v_flgkpi    := upper(hcm_util.get_string_t(obj_data,'flgkpi'));

                    begin
                        insert into tjobkpig (codpos,codcomp,codkpi,qtyscor,flgkpi
                                             ,descgrd,dtecreate,codcreate,dteupd,coduser)
                                      values (p_codpos,p_codcomp,v_codkpi,v_qtyscor
                                             ,v_flgkpi,v_descgrd,sysdate,global_v_coduser
                                             ,sysdate,global_v_coduser);
                    exception when dup_val_on_index then
                        update tjobkpig
                           set descgrd = v_descgrd,
                               flgkpi = v_flgkpi,
                               dteupd = sysdate,
                               coduser = global_v_coduser
                         where codpos = p_codpos
                           and codcomp = p_codcomp
                           and codkpi = v_codkpi
                           and qtyscor = v_qtyscor;
                    end;
                end loop;
            end if;
        end loop;

--        if param_msg_error is null then
--            save_data_kpi(v_codkpi,v_flgedit,json_str_output);
--        else
--            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end save_kpi;


    procedure save_competency as
        v_flgAdd        boolean;
        v_flgDelete     boolean;
        v_flgEdit       boolean;
        json_obj        json_object_t;
        obj_codtency    json_object_t;

        v_codtency      tjobposskil.codtency%type;
        v_codskill      tjobposskil.codskill%type;
        v_grade         tjobposskil.grade%type;
        v_score         tjobposskil.score%type;
        v_fscore        tjobposskil.fscore%type;
        obj_tab1        json_object_t;
        obj_data        json_object_t;

        v_flgAdd_child          boolean;
        v_flgDelete_child       boolean;
        v_flgEdit_child         boolean;
        v_count_child           number;
    begin
        obj_codtency  := hcm_util.get_json_t(param_json2,'rows');

--        check_save_kpi;

        for i_codtency in 0..obj_codtency.get_size-1 loop
            v_count_child   := 0;
            json_obj        := hcm_util.get_json_t(obj_codtency,to_char(i_codtency));
            v_codtency      := upper(hcm_util.get_string_t(json_obj,'codtency'));
            v_codskill      := upper(hcm_util.get_string_t(json_obj,'codskill'));
            v_grade         := hcm_util.get_string_t(json_obj,'grade');
            v_score         := hcm_util.get_string_t(json_obj,'score');
            v_fscore        := hcm_util.get_string_t(json_obj,'fscore');

            v_flgAdd        := hcm_util.get_boolean_t(json_obj,'flgAdd');
            v_flgDelete     := hcm_util.get_boolean_t(json_obj,'flgDelete');
            v_flgEdit       := hcm_util.get_boolean_t(json_obj,'flgEdit');
            obj_tab1        := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'table'),'rows');

            delete tjobposskil
             where codpos  = p_codpos
               and codcomp = p_codcomp
               and codskill = v_codskill
               and codtency = v_codtency;

            delete tjobscore
             where codpos  = p_codpos
               and codcomp = p_codcomp
               and codskill = v_codskill
               and codtency = v_codtency;




            if not v_flgDelete then
                if v_grade is null or v_score is null or v_fscore is null then
                    param_msg_error := get_error_msg_php('CO0042',global_v_lang);
                    exit;
                end if;
                begin
                    insert into tjobposskil (codpos,codcomp,codtency,codskill,grade
                                ,score,fscore,dtecreate,codcreate,dteupd,coduser)
                         values (p_codpos,p_codcomp,v_codtency,v_codskill,v_grade
                                ,v_score,v_fscore,sysdate,global_v_coduser,sysdate
                                ,global_v_coduser);
                exception when dup_val_on_index then
                    update tjobposskil
                       set grade = v_grade,
                           score = v_score,
                           fscore = v_fscore,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codpos = p_codpos
                       and codcomp = p_codcomp
                       and codtency = v_codtency
                       and codskill = v_codskill;
                end;

                for i_t1 in 0..obj_tab1.get_size-1 loop
                    v_flgDelete_child := false;
                    obj_data            := hcm_util.get_json_t(obj_tab1,to_char(i_t1));
                    v_grade             := hcm_util.get_string_t(obj_data,'grade');
                    v_score             := hcm_util.get_string_t(obj_data,'score');
                    v_flgAdd_child      := hcm_util.get_boolean_t(obj_data,'flgAdd');

                    v_flgEdit_child     := hcm_util.get_boolean_t(obj_data,'flgEdit');

                    if hcm_util.get_string_t(obj_data,'flgDelete') is not null and hcm_util.get_json_t(obj_data,'flgDelete').get_size > 0 then
                        v_flgDelete_child   := hcm_util.get_boolean_t(obj_data,'flgDelete');
                    end if;


                    if v_flgDelete then
                        v_flgDelete_child := true;
                    end if;

                    if not v_flgDelete_child then
                        v_count_child := v_count_child + 1;
                        begin
                            insert into tjobscore (codpos, codcomp, codtency, codskill,
                                                   grade, score, dtecreate, codcreate, dteupd, coduser)
                                 values (p_codpos,p_codcomp,v_codtency,v_codskill,
                                         v_grade ,v_score,sysdate,global_v_coduser,sysdate ,global_v_coduser);
                        exception when dup_val_on_index then
                            update tjobscore
                               set grade = v_grade,
                                   score = v_score,
                                   dteupd = sysdate,
                                   coduser = global_v_coduser
                             where codpos = p_codpos
                               and codcomp = p_codcomp
                               and codtency = v_codtency
                               and grade = v_grade
                               and codskill = v_codskill;
                        end;
                    end if;
                end loop;

                if v_count_child = 0 then
                    param_msg_error := get_error_msg_php('CO0043',global_v_lang);
                end if;
            end if;
        end loop;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end save_competency;



    procedure check_tab_codskil(v_codtency varchar2) as
        json_obj    json_object_t;
        v_grade     tjobposskil.grade%type;
        v_score     tjobposskil.score%type;
        v_codskill  tjobposskil.codskill%type;
        v_fscore    tjobposskil.fscore%type;
        v_flgedit   varchar2(10 char);
        v_temp      varchar2(1 char);
        v_count     number;
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj_main,'p_codskill'));
        v_fscore    := upper(hcm_util.get_string_t(json_obj_main,'p_fscore'));

        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_grade     := hcm_util.get_string_t(json_obj,'grade');
            v_score     := hcm_util.get_string_t(json_obj,'score');
            v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');

            if (v_grade is null) or (v_score is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
            if v_score > v_fscore then
                param_msg_error := get_error_msg_php('CO0007',global_v_lang);
                return;
            end if;
            begin
                select 'X' into v_temp from tcodskil where codcodec = v_codskill;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodskil');
                return;
            end;
            begin
                select count(*)
                  into v_count
                  from tjobposskil
                 where codpos = p_codpos
                   and codcomp = p_codcomp
                   and codskill = v_codskill
                   and codtency <> v_codtency;
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('CO0010',global_v_lang);
                return;
            end if;
        end loop;
    end check_tab_codskil;

    procedure save_data_competency(v_codtency varchar2, v_flgedit varchar2, json_str_output out clob) as
        json_obj    json_object_t;
        v_codskill  tjobposskil.codskill%type;
        v_grade     tjobposskil.grade%type;
        v_gradeOld  tjobposskil.grade%type;
        v_score     tjobposskil.score%type;
        v_fscore    tjobposskil.fscore%type;
        v_item_flgedit   varchar2(10 char);
    begin
        v_grade     := hcm_util.get_string_t(json_obj_main,'p_grade');
        v_score     := hcm_util.get_string_t(json_obj_main,'p_score');
        v_fscore    := hcm_util.get_string_t(json_obj_main,'p_fscore');
        begin
            insert into tjobposskil (codpos,codcomp,codtency,codskill,grade
                        ,score,fscore,dtecreate,codcreate,dteupd,coduser)
                 values (p_codpos,p_codcomp,p_codtency,p_codskill,v_grade
                        ,v_score,v_fscore,sysdate,global_v_coduser,sysdate
                        ,global_v_coduser);
        exception when dup_val_on_index then
            update tjobposskil
               set grade = v_grade,
                   score = v_score,
                   fscore = v_fscore,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codtency = p_codtency
               and codskill = p_codskill;
        end;

        for i in 0..param_json.get_size-1 loop
            json_obj            := hcm_util.get_json_t(param_json,to_char(i));
            v_grade             := hcm_util.get_string_t(json_obj,'grade');
            v_gradeOld          := hcm_util.get_string_t(json_obj,'gradeOld');
            v_score             := hcm_util.get_string_t(json_obj,'score');
            v_item_flgedit      := hcm_util.get_string_t(json_obj,'flgedit');
--            if v_flgedit = 'Add' then
--                v_item_flgedit := 'Add';
--            end if;
            if v_item_flgedit = 'Add' then
                begin
                    insert into tjobscore (codpos, codcomp, codtency, codskill,
                                           grade, score, dtecreate, codcreate, dteupd, coduser)
                         values (p_codpos,p_codcomp,p_codtency,p_codskill,
                                 v_grade ,v_score,sysdate,global_v_coduser,sysdate ,global_v_coduser);
                exception when dup_val_on_index then
                    update tjobscore
                       set grade = v_grade,
                           score = v_score,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codpos = p_codpos
                       and codcomp = p_codcomp
                       and codtency = p_codtency
                       and grade = v_grade
                       and codskill = p_codskill;
                end;
            elsif v_item_flgedit = 'Edit' then null;
                begin
                    update tjobscore
                       set grade = v_grade,
                           score = v_score,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codpos = p_codpos
                       and codcomp = p_codcomp
                       and codtency = p_codtency
                       and grade = v_gradeOld
                       and codskill = p_codskill;
                exception
                    when dup_val_on_index then
                        delete from tjobscore
                         where codpos = p_codpos
                           and codcomp = p_codcomp
                           and codtency = p_codtency
                           and codskill = p_codskill
                           and grade = v_grade;

                        insert into tjobscore (codpos, codcomp, codtency, codskill,
                                               grade, score, dtecreate, codcreate, dteupd, coduser)
                             values (p_codpos,p_codcomp,p_codtency,p_codskill,
                                     v_grade ,v_score,sysdate,global_v_coduser,sysdate ,global_v_coduser);
                    when NO_DATA_FOUND then
                        insert into tjobscore (codpos, codcomp, codtency, codskill,
                                               grade, score, dtecreate, codcreate, dteupd, coduser)
                             values (p_codpos,p_codcomp,p_codtency,p_codskill,
                                     v_grade ,v_score,sysdate,global_v_coduser,sysdate ,global_v_coduser);
                end;


            elsif v_item_flgedit = 'Delete' then
                delete from tjobscore
                 where codpos = p_codpos
                   and codcomp = p_codcomp
                   and codtency = p_codtency
                   and codskill = p_codskill
                   and grade = v_grade;
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
    end save_data_competency;

    procedure gen_popup_kpi (json_str_output out clob) as
    obj_data            json_object_t;
    obj_rows_child      json_object_t;
    obj_data_child      json_object_t;
    obj_tjobkpip        json_object_t;
    obj_tjobkpig        json_object_t;
    v_row_child         number := 0;
    v_row               number := 0;
    v_tjobkpi           tjobkpi%rowtype;

        cursor c1 is
            select *
              from tjobkpi
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codkpi = p_codkpi;

        cursor c2 is
            select *
              from tjobkpip
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codkpi = p_codkpi
          order by codkpi,planlvl;

        cursor c3 is
            select *
              from tjobkpig
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codkpi = p_codkpi
          order by qtyscor desc;
    begin
        begin
            select *
              into v_tjobkpi
              from tjobkpi
             where codpos = p_codpos
               and codcomp = p_codcomp
               and codkpi = p_codkpi;
        exception when no_data_found then
            v_tjobkpi := null;
        end;


        obj_tjobkpip        := json_object_t();
        obj_tjobkpig        := json_object_t();
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror',200);
        obj_data.put('codkpi',p_codkpi);
        obj_data.put('kpiitem',v_tjobkpi.kpiitem);
        obj_data.put('target',v_tjobkpi.target);
        obj_data.put('kpivalue',v_tjobkpi.kpivalue);

        v_row_child         := 0;
        obj_tjobkpip        := json_object_t();
        for r2 in c2 loop
            v_row_child     := v_row_child + 1;
            obj_data_child  := json_object_t();
            obj_data_child.put('coderror',200);
            obj_data_child.put('planlvl',r2.planlvl);
            obj_data_child.put('plandesc',r2.plandesc);
            obj_tjobkpip.put(to_char(v_row_child-1),obj_data_child);
        end loop;
        obj_data.put('tjobkpip',obj_tjobkpip);

        v_row_child         := 0;
        obj_tjobkpig        := json_object_t();
        for r3 in c3 loop
            v_row_child     := v_row_child + 1;
            obj_data_child  := json_object_t();
            obj_data_child.put('coderror',200);
            if r3.qtyscor = 5 then
                obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: blue;"></i>');
            elsif r3.qtyscor = 4 then
                obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: green;"></i>');
            elsif r3.qtyscor = 3 then
                obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: yellow;"></i>');
            elsif r3.qtyscor = 2 then
                obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: orange;"></i>');
            elsif r3.qtyscor = 1 then
                obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: red;"></i>');
            end if;
            obj_data_child.put('qtyscor',r3.qtyscor);
            obj_data_child.put('descgrd',r3.descgrd);
            obj_data_child.put('flgkpi',r3.flgkpi);
            obj_tjobkpig.put(to_char(v_row_child-1),obj_data_child);
        end loop;
        if v_row_child = 0 then
            for i in 1..5 loop
                v_row_child     := v_row_child + 1;
                obj_data_child  := json_object_t();
                obj_data_child.put('coderror',200);
                if i = 1 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: blue;"></i>');
                    obj_data_child.put('qtyscor',5);
                elsif i = 2 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: green;"></i>');
                    obj_data_child.put('qtyscor',4);
                elsif i = 3 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: yellow;"></i>');
                    obj_data_child.put('qtyscor',3);
                elsif i = 4 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: orange;"></i>');
                    obj_data_child.put('qtyscor',2);
                elsif i = 5 then
                    obj_data_child.put('icon','<i class="fa fa-circle" aria-hidden="true" style="color: red;"></i>');
                    obj_data_child.put('qtyscor',1);
                end if;
                obj_data_child.put('descgrd','');
                obj_data_child.put('flgkpi','P');
                obj_tjobkpig.put(to_char(v_row_child-1),obj_data_child);
            end loop;
        end if;
        obj_data.put('tjobkpig',obj_tjobkpig);
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_popup_kpi;

    procedure get_popup_kpi(json_str_input in clob, json_str_output out clob) as
        json_obj json_object_t;
        v_row       number := 0;
    begin
        initial_value(json_str_input);
        json_obj     := json_object_t(json_str_input);
        if param_msg_error is null then
            gen_popup_kpi(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_popup_kpi;

end HRCO26E;

/
