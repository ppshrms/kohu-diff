--------------------------------------------------------
--  DDL for Package Body HRTR25E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR25E" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp         := upper(hcm_util.get_string(json_obj,'codcomp'));
        p_codappr         := upper(hcm_util.get_string(json_obj,'codappr'));
        p_year            := hcm_util.get_string(json_obj,'year');
        p_codempid        := upper(hcm_util.get_string(json_obj,'codempid'));
        p_codpos          := upper(hcm_util.get_string(json_obj,'codpos'));

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
        v_has_codemp boolean := false;
    begin
        if p_year is null or p_codappr is null  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
              from temploy1
             where codempid like p_codappr
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;
        if secur_main.secur2(p_codappr,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        if not p_codempid like '' or not p_codempid is null then
            begin
                select 'X' into v_temp
                  from temploy1
                 where codempid like p_codempid
                   and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
            v_has_codemp := true;
        end if;

        if not p_codcomp like '' or not p_codcomp is null then
            begin
                select 'X' into v_temp
                from tcenter
                where codcomp like p_codcomp||'%'
                and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;
            if secur_main.secur7(p_codcomp,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;

        if not p_codpos like '' or not p_codpos is null then
            begin
                select 'X' into v_temp
                from tpostn
                where codpos like p_codpos
                and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
                return;
            end;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;

        cursor c1 is
            select a.codempid, a.codcomp, a.codpos, a.dteinput, a.dteyear
              from tidpplan a
             where a.dteyear = p_year
               and a.codappr = p_codappr
               and a.codcomp like nvl(p_codcomp, a.codcomp)||'%'
               and a.codpos = nvl(p_codpos, a.codpos)
               and a.codempid = nvl(p_codempid, a.codempid)
             order by codcomp,codpos,codempid;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('employee_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('agency',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codpos',i.codpos);
            obj_data.put('position',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('position',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TIDPPLAN');
            return;
        else
            dbms_lob.createtemporary(json_str_output, true);
            obj_rows.to_clob(json_str_output);
        end if;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure check_detail as
        v_temp          varchar2(1 char);
        v_has_codemp    boolean := false;
    begin
        if p_year is null or p_codempid is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

    end check_detail;

    procedure gen_detail(json_str_output out clob) as
        obj_result      json;
        obj_rows        json;
        obj_rows2       json;
        obj_rows3       json;
        obj_head        json;
        v_row           number := 0;
        obj_data        json;
		obj_data2       json;
		obj_data3       json;
        v_stadevp       tidpplan.stadevp%type;
        v_cmmt          tidpplan.commtfoll%type;

        cursor c1compe is
            select a.codtency, a.codskill, a.grade, a.grdemp
              from tidpcptc a
             where a.dteyear = p_year
               and a.codempid = p_codempid
          order by a.codtency,a.codskill;

        cursor c1cours is
            select a.codcours, a.codcate, a.dtestr, a.dteend, a.dtetrst, a.dtetren
              from tidpplans a
             where a.dteyear = p_year
               and a.codempid = p_codempid
          order by a.codcours;

        cursor c1improv is
            select a.coddevp, a.desdevp, a.targetdev, a.desresults, a.remark
              from tidpcptcd a
             where a.dteyear = p_year
               and a.codempid = p_codempid
          order by a.coddevp;
    begin
        obj_head := json();
        obj_result := json();

-- competency
        obj_rows := json();
        for i in c1compe loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('codtency',i.codtency);
            obj_data.put('codtency_type', get_tcomptnc_name(i.codtency, global_v_lang));
            obj_data.put('codskill',i.codskill);
            obj_data.put('codskill_desc', get_tcodec_name('TCODSKIL', i.codskill, global_v_lang));
            obj_data.put('grade',i.grade);
            obj_data.put('grdemp',nvl(i.grdemp,0));
            obj_data.put('GAP',i.grdemp-i.grade);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_head.put('competency',obj_rows);

-- course require
        v_row := 0;
        obj_rows2 := json();
        for i in c1cours loop
            v_row := v_row+1;
            obj_data2 := json();
            obj_data2.put('codcours',i.codcours);
            obj_data2.put('desc_codcurs',get_tcourse_name(i.codcours,global_v_lang));
            obj_data2.put('codcate',i.codcate);
            obj_data2.put('target_dtestar',to_char(i.DTESTR,'dd/mm/yyyy'));
            obj_data2.put('target_dteend',to_char(i.DTEEND,'dd/mm/yyyy'));
            obj_data2.put('actual_dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
            obj_data2.put('actual_dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
            obj_rows2.put(to_char(v_row-1),obj_data2);
        end loop;
        obj_head.put('course',obj_rows2);


-- improvement
        v_row := 0;
        obj_rows3 := json();
        for i in c1improv loop
            v_row := v_row+1;
            obj_data3 := json();
            obj_data3.put('order',v_row);
            obj_data3.put('coddevp',i.coddevp);
            obj_data3.put('desdevp_desc', get_tcodec_name('TCODDEVT', i.coddevp, global_v_lang));
            obj_data3.put('desdevp',i.desdevp);
            obj_data3.put('targetdev',i.targetdev);
            obj_data3.put('desresults',i.desresults);
            obj_data3.put('remark',i.remark);
            obj_rows3.put(to_char(v_row-1),obj_data3);
        end loop;
        obj_head.put('improvement',obj_rows3);

-- overall
        obj_rows3 := json();
        begin
            select stadevp, commtfoll into v_stadevp, v_cmmt
              from tidpplan
             where dteyear = p_year
               and codempid = p_codempid;
        exception when no_data_found then
            v_stadevp := '';
            v_cmmt := '';
        end;
        obj_data3 := json();
        obj_data3.put('stadevp',v_stadevp);
        obj_data3.put('comment',v_cmmt);
        obj_head.put('overall',obj_data3);
-- put data
		obj_result.put('0',obj_head);
		dbms_lob.createtemporary(json_str_output, true);
		obj_result.to_clob(json_str_output);
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure update_competency(data_obj json) as
        v_grdemp     tidpcptc.grdemp%type;
        v_codtency   tidpcptc.codtency%type;
        v_codskill   tidpcptc.codskill%type;
    begin
        v_grdemp    := hcm_util.get_string(data_obj,'grdemp');
        v_codtency  := hcm_util.get_string(data_obj,'codtency');
        v_codskill  := hcm_util.get_string(data_obj,'codskill');

        update tidpcptc
           set grdemp = v_grdemp,
               dteupd  =  sysdate,
               coduser =  global_v_coduser
         where dteyear = p_year
           and codempid = p_codempid
           and codtency = v_codtency
           and codskill = v_codskill;

        update tcmptncy
           set grade = v_grdemp,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid
           and codtency = v_codskill;
    end update_competency;

    procedure update_improvement(data_obj json) as
        v_desresults     tidpcptcd.desresults%type;
        v_remark         tidpcptcd.remark%type;
        v_coddevp        tidpcptcd.coddevp%type;
    begin
        v_desresults    := hcm_util.get_string(data_obj,'desresults');
        v_remark        := hcm_util.get_string(data_obj,'remark');
        v_coddevp       := hcm_util.get_string(data_obj,'coddevp');

        update tidpcptcd
           set desresults = v_desresults,
               remark = v_remark,
               dteupd = sysdate,
               coduser = global_v_coduser
         where dteyear = p_year
           and codempid = p_codempid
           and coddevp = v_coddevp;
    end update_improvement;

    procedure update_overall(data_obj json) as
        v_stadevp   tidpplan.stadevp%type;
        v_cmmt      tidpplan.commtfoll%type;
    begin
        v_stadevp   := hcm_util.get_string(data_obj,'stadevp');
        v_cmmt      := hcm_util.get_string(data_obj,'comment');

        update tidpplan
            set stadevp = v_stadevp,
                commtfoll = v_cmmt,
                dteinput = sysdate,
                dteupd = sysdate,
                coduser = global_v_coduser
          where dteyear = p_year
            and codempid = p_codempid;
    end update_overall;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
        data_obj    json;
        each_entry  json;
    begin
        initial_value(json_str_input);

-- initial param
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');

-- update
        data_obj := hcm_util.get_json(param_json,'competency');
        for i in 0..data_obj.count-1 loop
            each_entry := hcm_util.get_json(data_obj,to_char(i));
            update_competency(each_entry);
        end loop;

        data_obj := hcm_util.get_json(param_json,'improvement');
        for i in 0..data_obj.count-1 loop
            each_entry := hcm_util.get_json(data_obj,to_char(i));
            update_improvement(each_entry);
        end loop;

        data_obj := hcm_util.get_json(param_json,'overall');
        update_overall(data_obj);

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;
END HRTR25E;

/
