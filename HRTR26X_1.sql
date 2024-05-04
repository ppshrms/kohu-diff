--------------------------------------------------------
--  DDL for Package Body HRTR26X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR26X" as

--update 05/02/2021

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        p_codapp          := 'HRTR26X';
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    end initial_value;

    procedure gen_index(json_str_output out clob,p_dteyear_index VARCHAR2,p_codcomp VARCHAR2,p_codpos VARCHAR2,p_codempid VARCHAR2,p_status number) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_row_secur number := 0;

    cursor c1 is
        select codempid,codcomp,codpos,codappr,dteinput
        from tidpplan a
        where dteyear = p_dteyear_index
        and codcomp like p_codcomp||'%'
        and codpos = nvl(p_codpos,codpos)
        and codempid = nvl(p_codempid,codempid)
        and exists (select codempid
                    from tidpcptc b
                    where a.dteyear = b.dteyear
                    and a.codempid = b.codempid
                    and ((p_status = '1' and grade > grdemp)
                      or (p_status = '2')))
                    order by codempid;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            if secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
--            if false then
                v_row_secur := v_row_secur+1;
                obj_data := json_object_t();
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('des_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
                obj_data.put('des_codpos',get_tpostn_name(i.codpos,global_v_lang));
                obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
                obj_data.put('codappr',get_temploy_name(i.codappr,global_v_lang));
                obj_rows.put(to_char(v_row_secur-1),obj_data);
            end if;
        end loop;
        if  v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tidpplan');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        if ( v_row > 0 ) and ( v_row_secur = 0 ) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure gen_detail(json_str_output out clob,p_dteyear_index VARCHAR2,p_codcomp VARCHAR2,p_codpos VARCHAR2,p_codempid VARCHAR2,p_status number) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        obj_tidpcptc   json_object_t;
        obj_tidpplans   json_object_t;
        obj_tidpcptcd   json_object_t;
        obj_tab1    json_object_t;
        obj_tab2    json_object_t;
        obj_tab3    json_object_t;
        v_row       number := 0;
        v_row_c1       number := 0;
        v_row_secur number :=0;
        v_row_secur_c1 number :=0;
        v_gap    number := 0;
        obj_result json_object_t;

    cursor c1 is
        select *
        from tidpplan a
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        and exists (select codempid
                      from tidpcptc b
                     where a.dteyear    = b.dteyear
                       and a.codempid   = b.codempid
                    )
                    order by codempid;

    -- competency ที่ต้องพัฒนา
    cursor c2 is
        select codtency,codskill,grade,grdemp
        from tidpcptc
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        order by codtency,codskill;
    -- หลักสูตรที่ต้องเข้าอบรม
    cursor c3 is
        select codcours,codcate,dtestr,dteend,dtetrst,dtetren
        from tidpplans
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        order by codcours;
    -- รายละเอียดการพัฒนา
    cursor c4 is
        select coddevp,desdevp,targetdev,remark,pctsucc,desresults
        from tidpcptcd
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        order by coddevp;

    begin

        obj_result := json_object_t();
        v_row := 0;
        for i in c1 loop
            v_row_c1 := v_row_c1+1;
            if secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                v_row_secur_c1 := v_row_secur_c1+1;
                obj_result.put('image',get_emp_img(i.codempid));
                obj_result.put('codempid',i.codempid);
                obj_result.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
                obj_result.put('des_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
                obj_result.put('codcomp',i.codcomp);
                obj_result.put('des_codpos',get_tpostn_name(i.codpos,global_v_lang));
                obj_result.put('codpos',i.codpos);
                obj_result.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
                obj_result.put('codappr',i.codappr);
                obj_result.put('dteyear',i.dteyear);
                obj_result.put('stadevp',i.stadevp);
                obj_result.put('commtemp',i.commtemp);
                obj_result.put('commtemph',i.commtemph);
                obj_result.put('commtfoll',i.commtfoll);
                obj_result.put('dteconf',to_char(i.dteconf,'dd/mm/yyyy'));
                obj_result.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            end if;
        end loop;

        obj_rows := json_object_t();
        v_row := 0;
        for i2 in c2 loop
            v_row := v_row + 1;
            obj_tidpcptc := json_object_t();
            obj_tidpcptc.put('codtency',i2.codtency);
            obj_tidpcptc.put('desc_codtency',get_tcomptnc_name(i2.codtency,global_v_lang));
            obj_tidpcptc.put('codskill',i2.codskill);
            obj_tidpcptc.put('desc_codskill',get_tcodec_name('TCODSKIL',i2.codskill,global_v_lang));
            obj_tidpcptc.put('grade',i2.grade);
            obj_tidpcptc.put('grdemp',i2.grdemp);
            v_gap := (i2.grdemp - i2.grade);
            obj_tidpcptc.put('gap',v_gap);
            obj_rows.put(to_char(v_row-1),obj_tidpcptc);
        end loop;
        obj_result.put('tab1',obj_rows);

        obj_rows := json_object_t();
        v_row := 0;
        for i3 in c3 loop
            v_row := v_row + 1;
            obj_tidpplans := json_object_t();
            obj_tidpplans.put('codcours',i3.codcours);
            obj_tidpplans.put('desc_codcours',get_tcourse_name(i3.codcours,global_v_lang));
            obj_tidpplans.put('codcate',i3.codcate);
            obj_tidpplans.put('dtestr',to_char(i3.dtestr,'dd/mm/yyyy'));
            obj_tidpplans.put('dteend',to_char(i3.dteend,'dd/mm/yyyy'));
            obj_tidpplans.put('dtetrst',to_char(i3.dtetrst,'dd/mm/yyyy'));
            obj_tidpplans.put('dtetren',to_char(i3.dtetren,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_tidpplans);
        end loop;
        obj_result.put('tab2',obj_rows);

        obj_rows := json_object_t();
        v_row := 0;
        for i4 in c4 loop
            v_row := v_row + 1;
            obj_tidpcptcd := json_object_t();
            obj_tidpcptcd.put('coddevp',i4.coddevp);
            obj_tidpcptcd.put('desdevp',i4.desdevp);
            obj_tidpcptcd.put('coddevp_desc',get_tcodec_name('TCODDEVT', i4.coddevp, global_v_lang));
            obj_tidpcptcd.put('targetdev',i4.targetdev);
            obj_tidpcptcd.put('pctsucc',i4.pctsucc);
            obj_tidpcptcd.put('desresults',i4.desresults);
            obj_tidpcptcd.put('remark',i4.remark);
            obj_rows.put(to_char(v_row-1),obj_tidpcptcd);
        end loop;
            obj_result.put('tab3',obj_rows);

        dbms_lob.createtemporary(json_str_output, true);
        if  v_row_c1 = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tidpplan');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        if ( v_row_c1 > 0 ) and ( v_row_secur_c1 = 0 ) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        obj_rows := json_object_t();
        obj_rows.put('0',obj_result);
        obj_rows.to_clob(json_str_output);
    end gen_detail;

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
    end clear_ttemprpt;

    procedure gen_report(json_str_output out clob,p_dteyear_index VARCHAR2,p_codcomp VARCHAR2,p_codpos VARCHAR2,p_codempid VARCHAR2,p_status number) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        p_numseq    number;
        add_month   number:=0;
        max_numseq  number;
        obj_tidpcptc   json_object_t;
        obj_tidpplans   json_object_t;
        obj_tidpcptcd   json_object_t;
        obj_tab1    json_object_t;
        obj_tab2    json_object_t;
        obj_tab3    json_object_t;
        v_row       number := 0;
        v_row_secur number :=0;
        v_gap    number := 0;
        obj_result json_object_t;
        p_dteyear number := 0;
        v_stadevp_name varchar2(3000 char);
        add_data_month number := 0;
        emp_path varchar2(3000 char);
    cursor c1 is
        select *
        from tidpplan a
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        and exists (select codempid
                    from tidpcptc b
                    where a.dteyear = b.dteyear
                    and a.codempid = b.codempid
                    and (p_status = '1' and grade > grdemp)
                    or (p_status = '2'))
                    order by codempid;

    -- competency ที่ต้องพัฒนา
    cursor c2 is
        select codtency,codskill,grade,grdemp
        from tidpcptc
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        order by codtency,codskill;
    -- หลักสูตรที่ต้องเข้าอบรม
    cursor c3 is
        select codcours,codcate,dtestr,dteend,dtetrst,dtetren
        from tidpplans
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        order by codcours;
    -- รายละเอียดการพัฒนา
    cursor c4 is
        select coddevp,desdevp,targetdev,remark,pctsucc,desresults
        from tidpcptcd
        where dteyear = p_dteyear_index
        and codempid = p_codempid
        order by coddevp;

    begin
        for i in c1 loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt where codempid = global_v_codempid
                   and codapp = p_codapp;
                if max_numseq is null then
                    max_numseq :=0 ;
                end if;
            end;
            begin
                select folder into emp_path
                  from tfolderd where codapp = 'HRPMC2E1';
                if emp_path is null then
                    emp_path :='' ;
                end if;
            end;
            if global_v_lang ='102' then
                add_data_month := 543*12;
            end if;
            p_numseq := max_numseq+1;
            if global_v_lang ='102' then
                p_dteyear := i.dteyear+543;
            end if;
            if(i.stadevp = 'P') then
                v_stadevp_name := get_label_name('HRTR26XP2',global_v_lang,'350');
            else
                v_stadevp_name := get_label_name('HRTR26XP2',global_v_lang,'360');
            end if;

            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                    ,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18)
            values (global_v_codempid,p_codapp,p_numseq,'head',(emp_path||'/'||get_emp_img(i.codempid)),i.codempid,get_temploy_name(i.codempid,global_v_lang)
            ,get_tcenter_name(i.codcomp,global_v_lang),i.codcomp,get_tpostn_name(i.codpos,global_v_lang),i.codpos,to_char(add_months(i.dteinput,add_data_month),'dd/mm/yyyy')
            ,i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang),p_dteyear,v_stadevp_name,i.commtemp,i.commtemph,i.commtfoll,to_char(add_months(i.dteconf,add_data_month),'dd/mm/yyyy')
            ,to_char(add_months(i.dteappr,add_data_month),'dd/mm/yyyy'),to_char(add_months(i.dteconfh,add_data_month),'dd/mm/yyyy'));
        end loop;
            v_row := 0;
            for i2 in c2 loop
                v_row := v_row+1;
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;
                p_numseq := max_numseq+1;
                v_gap := (i2.grdemp - i2.grade);
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
                values (global_v_codempid,p_codapp,p_numseq,'table1',i2.codtency,get_tcomptnc_name(i2.codtency,global_v_lang),i2.codskill
                ,get_tcodec_name('TCODSKIL',i2.codskill,global_v_lang),i2.grade,i2.grdemp,v_gap);
            end loop;
            if v_row = 0 then
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;
                p_numseq := max_numseq+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
                values (global_v_codempid,p_codapp,p_numseq,'table1',' ',' ',' '
                ,' ',' ',' ',' ');
            end if;

            v_row := 0;
            for i3 in c3 loop
                v_row := v_row+1;
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;
                p_numseq := max_numseq+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
                values (global_v_codempid,p_codapp,p_numseq,'table2',i3.codcours,get_tcourse_name(i3.codcours,global_v_lang),i3.codcate
                ,to_char(add_months(i3.dtestr,add_data_month),'dd/mm/yyyy'),to_char(add_months(i3.dteend,add_data_month),'dd/mm/yyyy')
                ,to_char(add_months(i3.dtetrst,add_data_month),'dd/mm/yyyy'),to_char(add_months(i3.dtetren,add_data_month),'dd/mm/yyyy'));
            end loop;
            if v_row = 0 then
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;
                p_numseq := max_numseq+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
                values (global_v_codempid,p_codapp,p_numseq,'table2',' ',' ',' '
                ,' ',' '
                ,' ',' ');
            end if;

            v_row := 0;
            for i4 in c4 loop
                v_row := v_row+1;
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;
                p_numseq := max_numseq+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
                values (global_v_codempid,p_codapp,p_numseq,'table3',i4.coddevp,i4.desdevp,get_tcodec_name('TCODDEVT', i4.coddevp, global_v_lang)
                ,i4.targetdev,i4.pctsucc,i4.desresults,i4.remark);
            end loop;
            if v_row = 0 then
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;
                p_numseq := max_numseq+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
                values (global_v_codempid,p_codapp,p_numseq,'table3',' ',' ',' '
                ,' ',' ',' ',' ');
            end if;

        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    end gen_report;

    procedure check_index(p_codcomp varchar2,p_codpos varchar2,p_codempid varchar2) as
        v_temp varchar2(1 char);
    begin
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

        if p_codempid is not null then
            begin
                select 'X' into v_temp
                from temploy1
                where codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
                return;
            end;
        end if;

        begin
            select 'X' into v_temp
            from tpostn
            where codpos like p_codpos||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;
    end check_index;

    procedure check_detail(p_codcomp varchar2,p_codpos varchar2,p_codempid varchar2) as
        v_temp varchar2(1 char);
        v_temp2 varchar2(1 char);
        v_temp3 varchar2(1 char);
    begin
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
        if p_codempid is not null then
        begin
            select 'X' into v_temp3
            from temploy1
            where codempid = p_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;
        end if;
        begin
            select 'X' into v_temp2
            from tpostn
            where codpos like p_codpos||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_detail;


    procedure get_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        p_dteyear_index  tidpplan.dteyear%type;
        p_codcomp  tidpplan.codcomp%type;
        p_codpos   tidpplan.codpos%type;
        p_codempid tidpplan.codempid%type;
        p_status  number;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
           for i in 0..param_json.get_size-1 loop
                    p_dteyear_index   := hcm_util.get_string_t(param_json,'p_dteyear_index');
                    p_codcomp   := hcm_util.get_string_t(param_json,'p_codcomp');
                    p_codpos    := hcm_util.get_string_t(param_json,'p_codpos');
                    p_codempid  := hcm_util.get_string_t(param_json,'p_codempid');
                    p_status    := hcm_util.get_string_t(param_json,'p_status');
            end loop;
        check_index(p_codcomp,p_codpos,p_codempid);
        if param_msg_error is null then
            if (p_codempid is not null) then
                gen_detail(json_str_output,p_dteyear_index,p_codcomp,p_codpos,p_codempid,p_status);
            else
                gen_index(json_str_output,p_dteyear_index,p_codcomp,p_codpos,p_codempid,p_status);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        p_dteyear_index  tidpplan.dteyear%type;
        p_codcomp  tidpplan.codcomp%type;
        p_codpos   tidpplan.codpos%type;
        p_codempid tidpplan.codempid%type;
        p_status  number;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
           for i in 0..param_json.get_size-1 loop
                    p_dteyear_index   := hcm_util.get_string_t(param_json,'p_dteyear_index');
                    p_codcomp   := hcm_util.get_string_t(param_json,'p_codcomp');
                    p_codpos    := hcm_util.get_string_t(param_json,'p_codpos');
                    p_codempid  := hcm_util.get_string_t(param_json,'p_codempid');
                    p_status    := hcm_util.get_string_t(param_json,'p_status');
            end loop;
        check_detail(p_codcomp,p_codpos,p_codempid);
        if param_msg_error is null then

                gen_detail(json_str_output,p_dteyear_index,p_codcomp,p_codpos,p_codempid,p_status);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure get_report(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        p_dteyear_index  tidpplan.dteyear%type;
        p_codcomp  tidpplan.codcomp%type;
        p_codpos   tidpplan.codpos%type;
        p_codempid tidpplan.codempid%type;
        p_status  number;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
           for i in 0..param_json.get_size-1 loop
                    p_dteyear_index   := hcm_util.get_string_t(param_json,'p_dteyear_index');
                    p_codcomp   := hcm_util.get_string_t(param_json,'p_codcomp');
                    p_codpos    := hcm_util.get_string_t(param_json,'p_codpos');
                    p_codempid  := hcm_util.get_string_t(param_json,'p_codempid');
                    p_status    := hcm_util.get_string_t(param_json,'p_status');
            end loop;
            clear_ttemprpt;
        if param_msg_error is null then
                gen_report(json_str_output,p_dteyear_index,p_codcomp,p_codpos,p_codempid,p_status);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_report;

END HRTR26X;

/
