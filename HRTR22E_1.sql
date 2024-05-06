--------------------------------------------------------
--  DDL for Package Body HRTR22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR22E" AS

    PROCEDURE initial_value ( json_str_input IN CLOB) IS
        json_obj            json_object_t;
    BEGIN
        json_obj            := json_object_t(json_str_input);
        global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');

        hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
        p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'codcomp'));
        p_index_codcomp     := upper(hcm_util.get_string_t(json_obj, 'index_codcomp'));
        p_year              := to_number(hcm_util.get_string_t(json_obj, 'year'));
        p_problem_numseq    := to_number(hcm_util.get_string_t(json_obj, 'numseq'));
        p_codcours          := upper(hcm_util.get_string_t(json_obj, 'codcours'));
        p_codcate           := upper(hcm_util.get_string_t(json_obj, 'codcate'));
    END initial_value;

    PROCEDURE check_codcomp AS
        v_temp VARCHAR2(1 CHAR);
    BEGIN
        IF p_codcomp IS NULL  THEN
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
            return;
        END IF;
        param_msg_error :=  HCM_SECUR.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
    END check_codcomp;

    PROCEDURE check_year AS
    BEGIN
        IF p_year IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
            return;
        END IF;
    END check_year;

    function get_problem return clob is
      obj_rows  json_object_t;
      obj_data  json_object_t;
      v_row3    number := 0;

      cursor c3problem is
        select codcomp, numseq, desprob, descoures
          from ttrneedp
         where codcomp like p_codcomp||'%'
           and dteyear = p_year
      order by numseq;
    begin
      obj_rows := json_object_t();
      for i in c3problem loop
        v_row3      := v_row3 + 1;
        obj_data    := json_object_t();
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('codcomp_desc', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('numseq', i.numseq);
        obj_data.put('desprob', i.desprob);
        obj_data.put('descoures', i.descoures);
        obj_rows.put(to_char(v_row3 - 1), obj_data);
      end loop;
      return obj_rows.to_clob;
    end;

    PROCEDURE gen_index(json_str_output OUT CLOB, v_in_ttrneed BOOLEAN, v_less_than_current_year BOOLEAN,v_trpln_count NUMBER ) AS
        obj_rows            json_object_t;
        obj_rows2           json_object_t;
        obj_head            json_object_t;
        obj_result          json_object_t;
        obj_data            json_object_t;
        obj_data2           json_object_t;
        obj_data3           json_object_t;
        obj_emp             json_object_t;
        obj_child           json_object_t;
        obj_child_data      json_object_t;
        obj_syncond         json_object_t;
        obj_cours           json_object_t;

        v_row               NUMBER := 0;
        v_row2              NUMBER := 0;
        v_row3              NUMBER := 0;
        v_rowemp            NUMBER := 0;
        v_row_child         NUMBER := 0;

        v_codcours          tyrtrpln.codcours%TYPE;
        v_intruct_name      VARCHAR2(300);
        v_codcomp           tjobposskil.codcomp%TYPE;
        v_codpos            tjobposskil.codpos%TYPE;
        v_codskill          tjobposskil.codskill%TYPE;
        v_codcate           ttrneedg.codcate%TYPE;
        v_grade             tjobposskil.grade%TYPE;
        v_survey_codpos     temploy1.codpos%TYPE;

        v_qtyemp            NUMBER := 0;

        v_dteefpos          temploy1.dteefpos%type;
        v_numlvl            temploy1.numlvl%type;
        v_work_month        NUMBER;
        t_year		        number  				:= 0;
        t_month   	        number  				:= 0;
        t_day 		        number  				:= 0;
        v_problem_clob    clob;

        --User37 #2099 18/05/2021
        v_codcompdup        tjobposskil.codcomp%TYPE;
        v_codposdup         tjobposskil.codpos%TYPE;
        --User37 #2099 18/05/2021

        CURSOR c0header IS
            SELECT codsurvey, dtesurvey
              FROM ttrneed
             WHERE codcomp = p_codcomp
               AND dteyear = p_year;

        CURSOR c1general IS
            SELECT distinct codcate
              FROM ttrneedg
             WHERE codcomp = p_codcomp
               AND dteyear = p_year
          ORDER BY codcate;  --, TTRNEEDC c, TTRNEEDPD pd

        CURSOR c1child IS
            SELECT codcours,typcon,syncond,statement,typtrain,flgprior,remark,qtyemp
              FROM ttrneedg
             WHERE codcomp = p_codcomp
               AND dteyear = p_year
               AND codcate = v_codcate
          ORDER BY codcours;

        cursor c1emp is
            select codempid,codpos
              from ttrneedgd  a
             where codcomp = p_codcomp
               and dteyear = p_year
               and codcours = v_codcours
          order by codempid;

        CURSOR c2competency IS
            SELECT codcompc,codpos,grade,codskill,codtency,flgprior,qtyemp
              FROM ttrneedc
             WHERE codcompc = p_codcomp
               AND dteyear = p_year
          ORDER BY codcompc, codpos, codskill;

        CURSOR c2emp IS
            SELECT codempid, grade, grdemp, codcompc, codpos
              FROM ttrneedcd c
             WHERE c.dteyear = p_year
               AND codcompc = v_codcomp
               AND c.codskill = v_codskill
               AND c.codpos = v_codpos
               AND c.grade = v_grade
          ORDER BY codcompc, codpos, codempid;

        CURSOR c2tcomptcr IS
            SELECT codcours, grade, flgprior
              FROM ttrneedcc a
             WHERE a.dteyear = p_year
               AND codcompc = v_codcomp
               AND a.codskill = v_codskill
               AND a.codpos = v_codpos
          ORDER BY codcours;

        CURSOR c3problem IS
            SELECT codcomp, numseq, desprob, descoures
              FROM ttrneedp
             WHERE codcomp like p_codcomp||'%'
               AND dteyear = p_year
          ORDER BY numseq;
    BEGIN
        obj_result  := json_object_t();
        obj_head    := json_object_t();
        obj_rows    := json_object_t();

        -- existed data info v_in_ttrneed boolean,v_less_than_current_year boolean, v_trpln_count
        obj_data    := json_object_t();
        obj_data.put('existed_in_ttrneed', v_in_ttrneed);
        obj_data.put('year_is_less_than_current_year', v_less_than_current_year);
        obj_data.put('tyrtrpln_count', v_trpln_count);
        obj_head.put('existed_data_info', obj_data);
        FOR i IN c0header LOOP
            v_row := v_row + 1;
            obj_head.put('codsurvey', i.codsurvey);
            obj_head.put('dtesurvey', to_char(i.dtesurvey, 'dd/mm/yyyy'));

            begin
                select codpos
                  into v_survey_codpos
                  from temploy1
                 where codempid = i.codsurvey;
            exception when no_data_found THEN
                param_msg_error  := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            end;
            obj_head.put('survey_codpos', v_survey_codpos);
        END LOOP;

        v_row := 0;
        FOR j IN c1general LOOP
            v_row       := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('codcate', j.codcate);
            obj_data.put('category', get_tcodec_name('TCODCATE', j.codcate, global_v_lang));
            v_codcate   := j.codcate;
            obj_child   := json_object_t();
            v_row_child := 0;
            for i in c1child loop
                v_codcours      := i.codcours;
                v_row_child     := v_row_child+1;
                obj_child_data  := json_object_t();
                obj_syncond     := json_object_t();

                obj_child_data.put('codcours', i.codcours);
                obj_child_data.put('course', get_tcourse_name(i.codcours, global_v_lang));
                obj_child_data.put('conspc', i.TYPCON);
                obj_syncond.put('code', trim(nvl(i.SYNCOND,' ')));
                obj_syncond.put('description',trim(nvl(get_logical_name('HRTR22E',i.syncond,global_v_lang),' ')));
                obj_syncond.put('statement', trim(nvl(i.statement,' ')));
                obj_child_data.put('syncond', obj_syncond);
                if i.typtrain = '1' then
                    obj_child_data.put('conretrn1', 'Y');
                    obj_child_data.put('contrnno', '');
                    obj_child_data.put('conretrn2', '');
                elsif i.typtrain = '2' then
                    obj_child_data.put('conretrn2', 'Y');
                    obj_child_data.put('conretrn1', '');
                    obj_child_data.put('contrnno', '');
                elsif i.typtrain = '3' then
                    obj_child_data.put('contrnno', 'Y');
                    obj_child_data.put('conretrn1', '');
                    obj_child_data.put('conretrn2', '');
                else
                    obj_child_data.put('contrnno', 'N');
                    obj_child_data.put('conretrn1', 'N');
                    obj_child_data.put('conretrn2', 'N');
                end if;
                obj_child_data.put('flgprior', i.flgprior);
                obj_child_data.put('remark', i.remark);
                v_rowemp    := 0;
                obj_emp     := json_object_t();
                for k in c1emp loop
                    BEGIN
                        select dteefpos,numlvl
                          into v_dteefpos,v_numlvl
                          from temploy1
                         where codempid = k.codempid;
                    END;
                    if secur_main.secur3(p_codcomp,k.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                        v_rowemp    := v_rowemp+1;
	                    obj_data2   := json_object_t();
	                    obj_data2.put('flag', 'Edit');
	                    obj_data2.put('numseq', v_rowemp);
	                    obj_data2.put('image', get_emp_img(k.codempid));
	                    obj_data2.put('codempid', k.codempid);
	                    obj_data2.put('empname', get_temploy_name(k.codempid, global_v_lang));
	                    obj_data2.put('codpos', k.codpos);
	                    obj_data2.put('position', get_tpostn_name(k.codpos, global_v_lang));
	                    v_work_month := TRUNC(( months_between(sysdate, v_dteefpos) ),0);
	                    GET_SERVICE_YEAR(v_dteefpos,sysdate,'Y',t_year,t_month,t_day);
	                    obj_data2.put('work_month', t_year||'('||t_month||')');
	                    obj_emp.put(to_char(v_rowemp - 1), obj_data2);
                    end if;
                end loop;
                obj_child_data.put('employee', obj_emp);
                obj_child_data.put('qtyemp', v_rowemp);
                obj_child_data.put('count', v_rowemp);
                obj_child.put(to_char(v_row_child - 1), obj_child_data);
            end loop;
            obj_data.put('children', obj_child);
            obj_rows.put(to_char(v_row - 1), obj_data);
        END LOOP;

        obj_head.put('general', obj_rows);
        obj_rows2 := json_object_t();
        --<<User37 #2099 18/05/2021
        v_codposdup  := '!@#$';
        v_codcompdup := '!@#$';
        -->>User37 #2099 18/05/2021
        FOR i IN c2competency LOOP
            v_row2      := v_row2 + 1;
            obj_data    := json_object_t();
            v_codcomp   := i.codcompc;
            v_codpos    := i.codpos;
            v_grade     := i.grade;
            v_codskill  := i.codskill;
            obj_data.put('codcomp', i.codcompc);
            obj_data.put('codcomp_desc', get_tcenter_name(i.codcompc, global_v_lang));
            obj_data.put('codpos', i.codpos);
            obj_data.put('codpos_desc', get_tpostn_name(i.codpos, global_v_lang));
            obj_data.put('codskill', i.codskill);
            obj_data.put('codskill_desc', get_tcodec_name('TCODSKIL', i.codskill, global_v_lang));
            obj_data.put('codtency', i.codtency);
            obj_data.put('codtency_desc', get_tcodec_name('TCODSKIL', i.codskill, global_v_lang));
            obj_data.put('codtency_type', get_tcomptnc_name(i.codtency, global_v_lang));
            obj_data.put('grade', i.grade);
            obj_data.put('flgprior', i.flgprior);
            --<<User37 #2099 18/05/2021
            if v_codcompdup <> i.codcompc then
                obj_data.put('codcomp_desc', get_tcenter_name(i.codcompc, global_v_lang));
                v_codcompdup := i.codcompc;
                v_codposdup := '!@#$';
            else
                obj_data.put('codcomp_desc', '');
            end if;
            if v_codposdup <> i.codpos then
                obj_data.put('codpos_desc', get_tpostn_name(i.codpos, global_v_lang));
                v_codposdup := i.codpos;
            else
                obj_data.put('codpos_desc', '');
            end if;
            -->>User37 #2099 18/05/2021

        -- get employee
            obj_emp     := json_object_t();
            v_rowemp    := 0;
            FOR j IN c2emp LOOP
                BEGIN
                    SELECT numlvl
                      INTO v_numlvl
                      FROM temploy1
                     WHERE codempid = j.codempid;
                END;
                if  secur_main.secur3(p_codcomp,j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
	                v_rowemp    := v_rowemp + 1;
	                obj_data2   := json_object_t();
	                obj_data2.put('image', get_emp_img(j.codempid));
	                obj_data2.put('numseq', v_rowemp);
	                obj_data2.put('codempid', j.codempid);
	                obj_data2.put('employee_name', get_temploy_name(j.codempid, global_v_lang));
	                obj_data2.put('codcomp', j.codcompc);
	                obj_data2.put('agency', get_tcenter_name(j.codcompc, global_v_lang));
	                obj_data2.put('codpos', j.codpos);
	                obj_data2.put('position', get_tpostn_name(j.codpos, global_v_lang));
	                obj_data2.put('grade', j.grdemp);
	                obj_emp.put(to_char(v_rowemp - 1), obj_data2);
                end if;
            END LOOP;

            obj_data.put('employee', obj_emp);
            obj_data.put('qtyemp', v_rowemp);
            obj_data.put('qtyemp_actual', v_rowemp); -- end get employee
        -- get course
            obj_emp     := json_object_t();
            v_rowemp    := 0;
            FOR k IN c2tcomptcr LOOP
                v_rowemp    := v_rowemp + 1;
                obj_data2   := json_object_t();
                obj_data2.put('numseq', v_rowemp);
                obj_data2.put('codcours', k.codcours);
                obj_data2.put('codcours_desc', get_tcourse_name(k.codcours, global_v_lang));
                obj_data2.put('grade', k.grade);
                obj_data2.put('flgprior', k.flgprior);
                obj_emp.put(to_char(v_rowemp - 1), obj_data2);
            END LOOP;

            obj_data.put('course', obj_emp);
            obj_data.put('qtycourse', v_rowemp);  --  end get course
            obj_rows2.put(to_char(v_row2 - 1), obj_data);
        END LOOP;

        obj_head.put('competency', obj_rows2);

        v_problem_clob := get_problem;
        obj_rows := json_object_t(v_problem_clob);

        obj_head.put('problem', obj_rows);

        IF v_less_than_current_year = true THEN
            obj_head.put('message', replace(get_error_msg_php('HR1501', global_v_lang),'@#$%400',null));
        ELSIF v_trpln_count > 0 THEN
            obj_head.put('message', replace(get_error_msg_php('TR0041', global_v_lang),'@#$%400',null));
        END IF;

        obj_result.put('0', obj_head);
        dbms_lob.createtemporary(json_str_output, true);
        obj_result.to_clob(json_str_output);
    END gen_index;

    PROCEDURE gen_index_default (json_str_output OUT CLOB, v_in_ttrneed BOOLEAN, v_less_than_current_year BOOLEAN, v_trpln_count NUMBER) AS
        obj_rows         json_object_t;
        obj_rows2        json_object_t;
        obj_rows3        json_object_t;
        obj_head         json_object_t;
        obj_result       json_object_t;
        obj_data         json_object_t;
        obj_data2        json_object_t;
        obj_data3        json_object_t;
        obj_emp          json_object_t;
        obj_cours        json_object_t;
        v_row            NUMBER := 0;
        v_row2           NUMBER := 0;
        v_row3           NUMBER := 0;
        v_codcours       tyrtrpln.codcours%TYPE;
        v_intruct_name   VARCHAR2(300);
        v_qtyemp         NUMBER := 0;
        v_codcomp        tjobposskil.codcomp%TYPE;
        v_codpos         tjobposskil.codpos%TYPE;
        v_grade          tjobposskil.grade%TYPE;
        v_codskill       tjobposskil.codskill%TYPE;
        v_min_grdemp     tjobposskil.grade%TYPE := 0;
        v_codposdup      tjobposskil.codpos%TYPE;--User37 #2099 18/05/2021

--<< user22 : 15/08/2022 : ST11 ||
        cursor c2competency is
          select  a.codcomp, a.codpos, a.codtency, a.codskill, a.grade
            from tjobposskil a, temploy1 b
           where a.codcomp  = b.codcomp
             and a.codpos   = b.codpos
             and a.codcomp  like p_codcomp||'%'
             and b.staemp   in ('1','3')
             and(not exists (select c.codempid
                               from tcmptncy c
                              where c.codempid   = b.codempid
                                and c.codtency   = a.codskill)
              or exists     (select c.codempid
                               from tcmptncy c
                              where c.codempid   = b.codempid
                                and c.codtency   = a.codskill 
                                and c.grade     < a.grade))
        group by a.codcomp, a.codpos, a.codtency, a.codskill, a.grade
        order by a.codcomp, a.codpos, a.codtency, a.codskill;

        cursor c2emp is
          select codempid,codcomp,codpos,codtency,grade
            from (
                  select c.codempid, c.codcomp, c.codpos, d.codtency, d.grade
                    from temploy1 c, tcmptncy d
                   where c.codempid   = d.codempid
                     and c.staemp    in ('1','3')
                     and c.codcomp    = v_codcomp
                     and c.codpos     = v_codpos
                     and d.codtency   = v_codskill
                     and d.grade      < v_grade
            union
                  select c.codempid, c.codcomp, c.codpos, v_codskill, 0
                    from temploy1 c
                   where c.staemp    in ('1','3')
                     and c.codcomp    = v_codcomp
                     and c.codpos     = v_codpos
                     and not exists (select d.codempid
                                       from tcmptncy d
                                      where d.codempid   = c.codempid
                                        and d.codtency   = v_codskill))
          order by codempid;

        /*CURSOR c2competency IS
            SELECT a.codpos, a.codcomp, a.codtency, a.codskill, a.grade
              FROM tjobposskil a
             WHERE codcomp like p_codcomp||'%'--get_compful(p_codcomp)
               AND EXISTS ( SELECT d.codempid
                              FROM temploy1   c, tcmptncy   d
                             WHERE c.staemp NOT IN ( '0', '9' )
                               AND c.codempid = d.codempid
                               AND c.codcomp = a.codcomp
                               AND c.codpos = a.codpos
                               AND d.grade < a.grade)
                          ORDER BY codcomp, codpos, codtency, codskill;

        CURSOR c2emp IS
            SELECT c.codempid, c.codcomp, c.codpos, d.codtency, d.grade
              FROM temploy1 c, tcmptncy   d
             WHERE c.staemp NOT IN ( '0', '9' )
               AND c.codempid = d.codempid
               AND c.codcomp = v_codcomp
               AND c.codpos = v_codpos
               AND d.codtency = v_codskill
               AND d.grade < v_grade;*/
-->> user22 : 15/08/2022 : ST11 ||

        CURSOR c2tcomptcr IS
            SELECT codcours, grade
              FROM tcomptcr
             WHERE codskill = v_codskill
               AND grade >= v_min_grdemp
          ORDER BY codcours;
    BEGIN
        obj_result  := json_object_t();
        obj_head    := json_object_t();
        obj_rows    := json_object_t();

        -- existed data info v_in_ttrneed boolean,v_less_than_current_year boolean, v_trpln_count
        obj_data    := json_object_t();
        obj_data.put('existed_in_ttrneed', v_in_ttrneed);
        obj_data.put('year_less_than_current_year', v_less_than_current_year);
        obj_data.put('tyrtrpln_count', v_trpln_count);
        obj_head.put('existed_data_info', obj_data);

        -- header
        obj_head.put('dtesurvey', to_char(trunc(sysdate), 'dd/mm/yyyy'));
        if v_trpln_count > 0 then
            obj_head.put('message', replace(get_error_msg_php('TR0041', global_v_lang),'@#$%400',null));
        else
            obj_head.put('message', '');
        end if;
        obj_head.put('general', obj_rows);
        obj_rows2 := json_object_t();
        v_codposdup  := '!@#$'; --User37 #2099 18/05/2021
        FOR i IN c2competency LOOP
            v_row2          := v_row2 + 1;
            v_codpos        := i.codpos;
            v_grade         := i.grade;
            v_codskill      := i.codskill;
            obj_data        := json_object_t();
            v_codcomp       := i.codcomp;
            obj_data.put('flag', 'Add');
            obj_data.put('codcomp', p_codcomp);
            obj_data.put('codcomp_desc', get_tcenter_name(p_codcomp, global_v_lang));
            obj_data.put('codpos', i.codpos);
            obj_data.put('codpos_desc', get_tpostn_name(i.codpos, global_v_lang));
            obj_data.put('codskill', i.codskill);
            obj_data.put('codskill_desc', get_tcodec_name('TCODSKIL', i.codskill, global_v_lang));
            obj_data.put('codtency', i.codtency);
            obj_data.put('codtency_desc', get_tcodec_name('TCODSKIL', i.codtency, global_v_lang));
            obj_data.put('codtency_type', get_tcomptnc_name(i.codtency, global_v_lang));
            obj_data.put('grade', i.grade);
            obj_data.put('flgprior', '2');
            --<<User37 #2099 18/05/2021
            if v_row2 = 1 then
                obj_data.put('codcomp_desc', get_tcenter_name(p_codcomp, global_v_lang));
            else
                obj_data.put('codcomp_desc', '');
            end if;
            if v_codposdup <> i.codpos then
                obj_data.put('codpos_desc', get_tpostn_name(i.codpos, global_v_lang));
                v_codposdup := i.codpos;
            else
                obj_data.put('codpos_desc', '');
            end if;
            -->>User37 #2099 18/05/2021
            BEGIN
                SELECT COUNT(DISTINCT d.codempid)
                  INTO v_qtyemp
                  FROM temploy1 c, tcmptncy   d
                 WHERE c.staemp NOT IN ( '0', '9' )
                   AND c.codempid = d.codempid
                   AND c.codcomp = i.codcomp
                   AND c.codpos = i.codpos
                   AND d.codtency = v_codskill
                   AND d.grade < i.grade;
            END;

            begin
                delete ttrneedcd
                 where dteyear  = p_year
                   and codcompc = v_codcomp
                   and codskill = v_codskill;
            end;

            obj_emp := json_object_t();
            v_row3 := 0;
            v_min_grdemp  := 0;
            FOR j IN c2emp LOOP
                if secur_main.secur3(p_codcomp,j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
	                v_row3 := v_row3 + 1;
	                obj_data2 := json_object_t();
	                obj_data2.put('image', get_emp_img(j.codempid));
	                obj_data2.put('numseq', v_row3);
	                obj_data2.put('codempid', j.codempid);
	                obj_data2.put('employee_name', get_temploy_name(j.codempid, global_v_lang));
	                obj_data2.put('codcomp', j.codcomp);
	                obj_data2.put('agency', get_tcenter_name(j.codcomp, global_v_lang));
	                obj_data2.put('codpos', j.codpos);
	                obj_data2.put('position', get_tpostn_name(j.codpos, global_v_lang));
	                obj_data2.put('grade', j.grade);
                  v_min_grdemp  := least(v_min_grdemp, nvl(j.grade,0));
	                obj_emp.put(to_char(v_row3 - 1), obj_data2);
                end if;
            END LOOP;
            obj_data.put('employee', obj_emp);
            obj_data.put('qtyemp', v_row3);
            obj_data.put('qtyemp_actual', v_row3);

            obj_cours := json_object_t();
            v_row3 := 0;
            FOR k IN c2tcomptcr LOOP
                v_row3 := v_row3 + 1;
                obj_data2 := json_object_t();
                obj_data2.put('numseq', v_row3);
                obj_data2.put('codcours', k.codcours);
                obj_data2.put('codcours_desc', get_tcourse_name(k.codcours, global_v_lang));
                obj_data2.put('grade', k.grade);
                obj_data2.put('flgprior', '2');
                obj_cours.put(to_char(v_row3 - 1), obj_data2);
            END LOOP;

            obj_data.put('course', obj_cours);
            obj_data.put('qtycourse', v_row3);
            obj_rows2.put(to_char(v_row2 - 1), obj_data);
        END LOOP;

        obj_head.put('competency', obj_rows2);
        obj_rows3 := json_object_t();
        obj_head.put('problem', obj_rows3);

        obj_result.put('0', obj_head);
        dbms_lob.createtemporary(json_str_output, true);
        obj_result.to_clob(json_str_output);
    END gen_index_default;

    PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        v_trpln_count              NUMBER := 0;
        v_in_ttrneed               BOOLEAN := false;
        v_less_than_current_year   BOOLEAN := false;
        v_temp                     VARCHAR2(1 CHAR);
        v_codcompy                 tcenter.codcomp%type;
    BEGIN
        initial_value(json_str_input);
        check_codcomp;
        check_year;

        IF p_year < to_number(to_char(sysdate, 'YYYY')) THEN
            v_less_than_current_year := true;
        END IF;

        v_in_ttrneed := true;
        BEGIN
            SELECT 'X'
              INTO v_temp
              FROM ttrneed
             WHERE dteyear = p_year
               AND codcomp = p_codcomp;
        EXCEPTION WHEN no_data_found THEN
            v_in_ttrneed := false;
        END;

        IF v_in_ttrneed = false AND v_less_than_current_year = true THEN
            param_msg_error := replace(get_error_msg_php('HR1501', global_v_lang),'@#$%400',null);
        END IF;

        v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
        BEGIN
            SELECT COUNT(*)
              INTO v_trpln_count
              FROM tyrtrpln
             WHERE dteyear = p_year
               AND codcompy = v_codcompy;
        END;
        IF param_msg_error IS NULL AND v_in_ttrneed = true THEN
            gen_index(json_str_output, v_in_ttrneed, v_less_than_current_year, v_trpln_count);
        ELSIF param_msg_error IS NULL AND v_in_ttrneed = false THEN
            gen_index_default(json_str_output, v_in_ttrneed, v_less_than_current_year, v_trpln_count);
        END IF;
        IF param_msg_error IS NOT NULL THEN
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_index;

    PROCEDURE gen_problem_detail ( json_str_output OUT CLOB, v_in_ttrneedp BOOLEAN ) AS
        obj_rows     json_object_t;
        obj_rows2    json_object_t;
        obj_result   json_object_t;
        obj_data2    json_object_t;
        v_row        NUMBER := 0;
        v_row2       NUMBER := 0;

        CURSOR c1 IS
            SELECT codcomp, numseq, desprob, descoures, desresult
              FROM ttrneedp
             WHERE codcomp = p_codcomp
               AND dteyear = p_year
               AND numseq = p_problem_numseq;

        CURSOR c2 IS
            SELECT a.numseq, a.codempid, b.codcomp, b.codpos
              FROM ttrneedpd a, temploy1 b
             WHERE a.codcomp = p_codcomp
               AND a.dteyear = p_year
               AND a.numseq = p_problem_numseq
               AND a.codempid = b.codempid
          ORDER BY a.codcomp, a.codpos, a.codempid;

    BEGIN
        obj_result  := json_object_t();
        obj_rows    := json_object_t();
        IF v_in_ttrneedp = true THEN
            obj_rows.put('existed_in_ttrneedp', v_in_ttrneedp);
            obj_rows.put('flag', 'Edit');
            FOR i IN c1 LOOP
                v_row := v_row + 1;
                obj_rows.put('codcomp', i.codcomp);
                obj_rows.put('agency', get_tcenter_name(i.codcomp, global_v_lang));
                obj_rows.put('numseq', p_problem_numseq);
                obj_rows.put('desprob', i.desprob);
                obj_rows.put('descoures', i.descoures);
                obj_rows.put('desresult', i.desresult);
                -- gen employee
                obj_rows2   := json_object_t();
                v_row2      := 0;
                FOR j IN c2 LOOP
                    if secur_main.secur3(p_codcomp,j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    v_row2      := v_row2 + 1;
                    obj_data2   := json_object_t();
                    obj_data2.put('numseq', v_row2);
                    obj_data2.put('codempid', j.codempid);
                    obj_data2.put('employee_name', get_temploy_name(j.codempid, global_v_lang));
                    obj_data2.put('codcomp', j.codcomp);
                    obj_data2.put('agency', get_tcenter_name(j.codcomp, global_v_lang));
                    obj_data2.put('codpos', j.codpos);
                    obj_data2.put('position', get_tpostn_name(j.codpos, global_v_lang));
                    obj_rows2.put(to_char(v_row2 - 1), obj_data2);
                    end if;
                END LOOP;

                obj_rows.put('employee', obj_rows2);
            END LOOP;
        ELSE --  case v_in_ttrneedp = false
            obj_rows := json_object_t();
            obj_rows.put('existed_in_ttrneedp', v_in_ttrneedp);
            obj_rows.put('flag', 'Add');
            obj_rows.put('codcomp', p_codcomp);
            obj_rows.put('agency', '');
            obj_rows.put('numseq', p_problem_numseq);
            obj_rows.put('desprob', '');
            obj_rows.put('descoures', '');
            obj_rows.put('desresult', '');
            obj_rows2 := json_object_t();
            obj_rows.put('employee', obj_rows2);
        END IF;
        obj_result.put('rows', obj_rows);
        dbms_lob.createtemporary(json_str_output, true);
        obj_result.to_clob(json_str_output);
    END gen_problem_detail;

    PROCEDURE get_problem_detail ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        v_in_ttrneedp   BOOLEAN;
        v_temp          VARCHAR2(1);
    BEGIN
        initial_value(json_str_input);
        check_codcomp;

    --  check if already exist in ttrneedp
        v_in_ttrneedp := true;
        BEGIN
            SELECT 'X' INTO v_temp
              FROM ttrneedp
             WHERE dteyear = p_year
               AND codcomp = p_codcomp
               AND numseq = p_problem_numseq
               AND ROWNUM = 1;
        EXCEPTION WHEN no_data_found THEN
            v_in_ttrneedp := false;
        END;

        IF param_msg_error IS NULL THEN
            gen_problem_detail(json_str_output, v_in_ttrneedp);
        END IF;
        IF param_msg_error IS NOT NULL THEN
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_problem_detail;

    PROCEDURE check_problem_employee ( data_obj json_object_t ) AS
        v_codempid             ttrneedpd.codempid%TYPE;
        v_codcomp              ttrneedpd.codcomp%TYPE;
        v_codpos               ttrneedpd.codpos%TYPE;
        v_employee_codcomp     temploy1.codcomp%TYPE;
        v_employee_numlvl      temploy1.numlvl%TYPE;
        v_item_flgedit         VARCHAR2(10 CHAR);
        v_codempid_duplicate   BOOLEAN;
        detail_obj             json_object_t;
        v_temp                 VARCHAR2(40 CHAR);
        v_row                  NUMBER := 0;
    BEGIN
        FOR i IN 0..data_obj.get_size - 1 LOOP
            v_row           := v_row + 1;
            detail_obj      := hcm_util.get_json_t(data_obj, to_char(i));
            v_item_flgedit  := hcm_util.get_string_t(detail_obj, 'flag');
            IF v_item_flgedit = 'Add' OR v_item_flgedit = 'Edit' THEN  -- if flag add edit
                v_codempid  := upper(hcm_util.get_string_t(detail_obj, 'codempid'));
                v_codcomp   := upper(hcm_util.get_string_t(detail_obj, 'codcomp'));
                v_codpos    := upper(hcm_util.get_string_t(detail_obj, 'codpos'));
                IF v_codempid IS NULL THEN
                    param_msg_error := get_error_msg_php('HR2045', global_v_lang);
                    return;
                END IF;

                BEGIN
                    SELECT codcomp, numlvl
                      INTO v_employee_codcomp, v_employee_numlvl
                      FROM temploy1
                     WHERE codempid = v_codempid
                       AND ROWNUM = 1;
                EXCEPTION WHEN no_data_found THEN
                    param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TEMPLOY1');
                    return;
                END;

                IF v_employee_codcomp LIKE p_index_codcomp|| '%' THEN
                    NULL;
                ELSE
                    param_msg_error := get_error_msg_php('HR2104', global_v_lang);
                    return;
                END IF;

                if secur_main.secur7(p_index_codcomp,global_v_coduser) = false then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    return;
                end if;

                IF v_item_flgedit = 'Add' THEN -- check duplicate
                    v_codempid_duplicate := true;
                    BEGIN
                        SELECT 'x' INTO v_temp
                          FROM ttrneedpd
                         WHERE codempid = v_codempid
                           and DTEYEAR = p_year
                           and CODCOMP = p_codcomp
                           and numseq = p_problem_numseq
                           AND ROWNUM = 1;
                    EXCEPTION WHEN no_data_found THEN
                        v_codempid_duplicate := false;
                    END;

                    IF v_codempid_duplicate = true THEN
                        param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TTRNEEDPD');
                        return;
                    END IF;
                END IF; -- end check duplicate
            END IF; -- end if flag add edit
        END LOOP;
    END check_problem_employee;

    PROCEDURE check_param_problemdetail(param_json json_object_t ) AS
        v_desprob       ttrneedp.desprob%TYPE;
        v_descoures     ttrneedp.descoures%TYPE;
        v_desresult     ttrneedp.desresult%TYPE;
        v_numseq        ttrneedp.numseq%TYPE;
    BEGIN
        v_desprob       := hcm_util.get_string_t(param_json, 'desprob');
        v_descoures     := hcm_util.get_string_t(param_json, 'descoures');
        v_desresult     := hcm_util.get_string_t(param_json, 'desresult');
        v_numseq        := to_number(hcm_util.get_string_t(param_json, 'numseq'));

        IF v_desprob IS NULL OR v_descoures IS NULL OR v_desresult IS NULL OR v_numseq IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
            return;
        END IF;

        IF p_codcomp LIKE p_index_codcomp||'%' THEN
            NULL;
        ELSE
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
            return;
        END IF;
    END check_param_problemdetail;

    PROCEDURE insert_problem_employee ( detail_obj json_object_t, json_str_output OUT CLOB ) AS
        v_codempid   ttrneedpd.codempid%TYPE;
        v_codcomp    ttrneedpd.codcomp%TYPE;
        v_codpos     ttrneedpd.codpos%TYPE;
    BEGIN
        v_codempid  := upper(hcm_util.get_string_t(detail_obj, 'codempid'));
        v_codcomp   := upper(hcm_util.get_string_t(detail_obj, 'codcomp'));
        v_codpos    := upper(hcm_util.get_string_t(detail_obj, 'codpos'));
        INSERT INTO ttrneedpd ( codempid, codcomp, codpos, numseq, dteyear, dtecreate, codcreate, dteupd, coduser )
        VALUES ( v_codempid, p_codcomp, v_codpos, p_problem_numseq, p_year, sysdate, global_v_coduser, sysdate, global_v_coduser );
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END insert_problem_employee;

    PROCEDURE delete_problem_employee ( detail_obj json_object_t, json_str_output OUT CLOB ) AS
        v_codempid   ttrneedpd.codempid%TYPE;
        v_codcomp    ttrneedpd.codcomp%TYPE;
        v_codpos     ttrneedpd.codpos%TYPE;
    BEGIN
        v_codempid  := upper(hcm_util.get_string_t(detail_obj, 'codempid'));
        v_codcomp   := upper(hcm_util.get_string_t(detail_obj, 'codcomp'));
        v_codpos    := upper(hcm_util.get_string_t(detail_obj, 'codpos'));
        DELETE ttrneedpd
         WHERE codempid = v_codempid
           AND dteyear = p_year
           AND codcomp = p_codcomp
           AND numseq = p_problem_numseq;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END delete_problem_employee;

    PROCEDURE edit_problem_employee ( data_obj json_object_t, json_str_output OUT CLOB ) AS
        v_item_flgedit   VARCHAR2(10 CHAR);
        detail_obj       json_object_t;
    BEGIN
        FOR i IN 0..data_obj.get_size - 1 LOOP
            IF param_msg_error IS NULL THEN
                detail_obj := hcm_util.get_json_t(data_obj, to_char(i));
                v_item_flgedit := hcm_util.get_string_t(detail_obj, 'flag');
                IF v_item_flgedit = 'Add' THEN
                    insert_problem_employee(detail_obj, json_str_output);
                ELSIF v_item_flgedit = 'Delete' THEN
                    delete_problem_employee(detail_obj, json_str_output);
                END IF;
            END IF;
        END LOOP;
    END edit_problem_employee;

    PROCEDURE update_problem ( param_json json_object_t, json_str_output OUT CLOB ) AS
        data_obj      json_object_t;
        v_desprob     ttrneedp.desprob%TYPE;
        v_descoures   ttrneedp.descoures%TYPE;
        v_desresult   ttrneedp.desresult%TYPE;
        v_numseq      ttrneedp.numseq%TYPE;
    BEGIN
        data_obj        := hcm_util.get_json_t(param_json, 'param_json');
        v_desprob       := hcm_util.get_string_t(param_json, 'desprob');
        v_descoures     := hcm_util.get_string_t(param_json, 'descoures');
        v_desresult     := hcm_util.get_string_t(param_json, 'desresult');
        v_numseq        := to_number(hcm_util.get_string_t(param_json, 'numseq'));

        UPDATE ttrneedp
           SET desprob = v_desprob,
               descoures = v_descoures,
               desresult = v_desresult,
               dteupd = sysdate,
               coduser = global_v_coduser
         WHERE dteyear = p_year
           AND codcomp = p_codcomp
           AND numseq = v_numseq;

        data_obj := hcm_util.get_json_t(param_json, 'param_json');
        edit_problem_employee(data_obj, json_str_output);
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END update_problem;

    PROCEDURE insert_problem ( param_json json_object_t, json_str_output OUT CLOB ) AS
        data_obj      json_object_t;
        v_desprob     ttrneedp.desprob%TYPE;
        v_descoures   ttrneedp.descoures%TYPE;
        v_desresult   ttrneedp.desresult%TYPE;
        v_numseq      ttrneedp.numseq%TYPE;
    BEGIN
        data_obj    := hcm_util.get_json_t(param_json, 'param_json');
        v_desprob   := hcm_util.get_string_t(param_json, 'desprob');
        v_descoures := hcm_util.get_string_t(param_json, 'descoures');
        v_desresult := hcm_util.get_string_t(param_json, 'desresult');
        v_numseq    := to_number(hcm_util.get_string_t(param_json, 'numseq'));

        INSERT INTO ttrneedp ( desprob, descoures, desresult, numseq, codcomp, dteyear, dtecreate, codcreate, dteupd, coduser )
        VALUES ( v_desprob, v_descoures, v_desresult, v_numseq, p_codcomp, p_year, sysdate, global_v_coduser, sysdate, global_v_coduser);

        data_obj := hcm_util.get_json_t(param_json, 'param_json');
        edit_problem_employee(data_obj, json_str_output);
    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END insert_problem;

    PROCEDURE save_problem_detail ( json_str_input IN CLOB, json_str_output OUT CLOB) AS
        json_obj         json_object_t;
        v_item_flgedit   VARCHAR2(10 CHAR);
    BEGIN
        initial_value(json_str_input);
        check_codcomp;
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj, 'param_json');
        check_param_problemdetail(json_obj);
        check_problem_employee(param_json);
        v_item_flgedit := hcm_util.get_string_t(json_obj, 'flag');
        IF param_msg_error IS NULL THEN
            IF v_item_flgedit = 'Add' THEN
                insert_problem(json_obj, json_str_output);
            ELSIF v_item_flgedit = 'Edit' THEN
                update_problem(json_obj, json_str_output);
            END IF;
        END IF;

        IF param_msg_error IS NOT NULL THEN
            ROLLBACK;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        ELSE
            COMMIT;
            param_msg_error := get_error_msg_php('HR2401', global_v_lang);
            json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END save_problem_detail;

    PROCEDURE get_inst ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        json_obj        json_object_t;
        v_codempid      temploy1.codempid%TYPE;
        v_codpos        temploy1.codpos%TYPE;
        v_codcomp       temploy1.codcomp%TYPE;
        v_dteefpos      temploy1.dteefpos%TYPE;
        t_year		    number  := 0;
        t_month   	    number  := 0;
        t_day 		    number  := 0;
        obj_data        json_object_t;
        obj_head        json_object_t;
    BEGIN
        json_obj        := json_object_t(json_str_input);
        obj_data        := json_object_t;
        obj_head        := json_object_t;
        initial_value(json_str_input);
        v_codempid      := upper(hcm_util.get_string_t(json_obj, 'codempid'));
        BEGIN
            SELECT codpos, codcomp,dteefpos
              INTO v_codpos, v_codcomp, v_dteefpos
              FROM temploy1
             WHERE codempid = v_codempid;
        END;

        obj_data.put('codempid', v_codempid);
        obj_data.put('codcomp', v_codcomp);
        obj_data.put('codcomp_desc', get_tcenter_name(v_codcomp, global_v_lang));
        obj_data.put('codpos', v_codpos);
        obj_data.put('codpos_desc', get_tpostn_name(v_codpos, global_v_lang));
        GET_SERVICE_YEAR(v_dteefpos,sysdate,'Y',t_year,t_month,t_day);
        obj_data.put('work_month', t_year||'('||t_month||')');
        obj_head.put('0', obj_data);
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
        IF param_msg_error IS NOT NULL THEN
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_inst;

    PROCEDURE gen_processed_emp(data_obj json_object_t, json_str_output   OUT CLOB ) AS
        v_statement_1       tcourse.syncond%TYPE;
        v_base_statement    tcourse.syncond%TYPE;
        v_codcours          tcourse.codcours%TYPE;
        v_codcate           tcourse.codcate%TYPE;
        v_typcon            ttrneedg.typcon%TYPE;
        v_conspc            ttrneedg.typcon%TYPE;
        v_inst_statement    ttrneedg.statement%TYPE;
        v_typtrain          ttrneedg.typtrain%TYPE;
        v_flgprior          ttrneedg.FLGPRIOR%TYPE;
        v_contrnno          ttrneedg.typtrain%TYPE;
        v_conretrn1         ttrneedg.typtrain%TYPE;
        v_conretrn2         ttrneedg.typtrain%TYPE;
        detail_obj          json_object_t;
        detail_obj_children json_object_t;
        detail_obj_child    json_object_t;
        obj_rows            json_object_t;
        obj_cate            json_object_t;
        obj_cate_child      json_object_t;
        obj_cours           json_object_t;
        obj_emp             json_object_t;
        obj_data            json_object_t;
        obj_syncon          json_object_t;

        v_row               NUMBER := 0;
        v_row2              NUMBER := 0;
        v_temp              VARCHAR2(1);
        v_descod            temploy1%rowtype;
        v_flg_delete        VARCHAR2(10);
        v_work_month        NUMBER;
        v_duplicate         BOOLEAN;

        t_year		        number  := 0;
        t_month   	        number  := 0;
        t_day 		        number  := 0;

        TYPE empcurtyp IS REF CURSOR;
        c1                 SYS_REFCURSOR;
        v_emp_cursor       empcurtyp;
        ttpotent_record    temploy1%rowtype;
    BEGIN
        obj_rows := json_object_t();
        FOR j IN 0..data_obj.get_size - 1 LOOP -- loop all
            detail_obj          := hcm_util.get_json_t(data_obj, to_char(j)); -- each codcate
            v_codcate           := hcm_util.get_string_t(detail_obj, 'codcate');
            obj_cate            := json_object_t();
            obj_cate.put('codcate', v_codcate);
            detail_obj_children := hcm_util.get_json_t(detail_obj,'children');
            obj_cate_child      := json_object_t();
            v_row               := 0;
            FOR i IN 0..detail_obj_children.get_size - 1 LOOP  -- each codcours
                obj_cours           := json_object_t();
                detail_obj_child    := hcm_util.get_json_t(detail_obj_children, to_char(i)); -- each codcourse
                v_flg_delete        := hcm_util.get_string_t(detail_obj_child, 'flg');
                if v_flg_delete <> 'delete' then
	                v_codcours      := hcm_util.get_string_t(detail_obj_child, 'codcours');
	                v_flgprior      := hcm_util.get_string_t(detail_obj_child, 'flgprior');
	                v_conspc        := hcm_util.get_string_t(detail_obj_child, 'conspc'); -- กลุ่มเป้าหมายกำหนดขึ้นใหม่ (Y-กำหนด,N-ไม่ได้กำหนด)
	                v_contrnno      := hcm_util.get_string_t(detail_obj_child, 'contrnno'); -- คนที่ยังไม่เคยเข้าอบรม (Y-กำหนด,N-ไม่ได้กำหนด)
	                v_conretrn1     := hcm_util.get_string_t(detail_obj_child, 'conretrn1'); -- อบรมซ้ำ(ทั้งหมด) (Y-กำหนด,N-ไม่ได้กำหนด)
	                v_conretrn2     := hcm_util.get_string_t(detail_obj_child, 'conretrn2'); --	อบรมซ้ำ(เฉพาะคนที่ไม่ผ่าน) (Y/N)
	                obj_syncon      := hcm_util.get_json_t(detail_obj_child, 'syncond');
	                v_statement_1   := hcm_util.get_string_t(obj_syncon, 'code');
	                if  v_conspc = 'Y' or v_conspc = '1'  then
	                    v_typcon    := '1';
	                elsif v_conspc = 'N' or v_conspc = '2' then
	                    v_typcon    := '2';
	                end if;
	            -- validate data
	                IF v_conretrn1 = 'Y' AND v_conretrn2 = 'Y' THEN
	                    param_msg_error := get_error_msg_php('HR2020', global_v_lang);
	                    return;
	                END IF;

	                IF v_codcate IS NULL OR v_codcours IS NULL OR v_typcon IS NULL THEN
	                    param_msg_error := get_error_msg_php('HR2045', global_v_lang);
	                    return;
	                END IF;

	                BEGIN
	                    SELECT 'X' INTO v_temp
                          FROM tcourse
	                     WHERE codcours = v_codcours
	                       AND ROWNUM = 1;
                    EXCEPTION WHEN no_data_found THEN
                        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCOURSE');
                        return;
	                END;

	                BEGIN
	                    SELECT 'X' INTO v_temp
                          FROM tcodcate
	                     WHERE codcodec = v_codcate
	                       AND ROWNUM = 1;
                    EXCEPTION WHEN no_data_found THEN
                        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODCATE');
                        return;
	                END;

	                BEGIN -- remove old data
	                    DELETE FROM ttrneedg
	                     WHERE dteyear = p_year
	                       AND codcomp = p_codcomp
	                       AND codcours = v_codcours;
	                END;

	                BEGIN -- remove old data
	                    DELETE FROM ttrneedgd
	                     WHERE dteyear = p_year
	                       AND codcomp = p_codcomp
	                       AND codcours = v_codcours;
	                END;

	                if v_conretrn1 = 'Y' then -- ซ้ำทั้งหมด
	                    v_typtrain := '1';
	                elsif v_conretrn2 = 'Y' then -- ซ้ำไม่ผ่าน
	                    v_typtrain := '2';
	                elsif v_contrnno = 'Y' then -- ยังไม่เข้าอบรม
	                    v_typtrain := '3';
	                else
	                    v_typtrain := '4';
	                end if;

	             -- statement 1 เงื่อนไขใหม่ หรือ ดึงเงื่อนไขเก่า
                -- if กลุ่มเป้าหมายกำหนดขึ้นใหม่
                    IF v_conspc = 'Y' or v_conspc = '1' THEN
	                    obj_syncon          := hcm_util.get_json_t(detail_obj_child,'syncond');
	                    v_statement_1       := hcm_util.get_string_t(obj_syncon, 'code');
	                    v_inst_statement    := hcm_util.get_string_t(obj_syncon, 'statement');
                -- if ตามหลักสูตร
                    ELSIF v_conspc = 'N' or v_conspc = '2' THEN
	                    BEGIN
	                        SELECT syncond,STATEMENT
                              INTO v_statement_1,v_inst_statement
	                          FROM tcourse
	                         WHERE codcours = v_codcours;
	                    EXCEPTION WHEN no_data_found THEN
	                        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCOURSE');
                            return;
	                    END;
                -- Not Y Not N
                    ELSE
	                    param_msg_error := get_error_msg_php('HR2045', global_v_lang);
                        return;
                    END IF;
                -- end if กลุ่มเป้าหมายกำหนดขึ้นใหม
	                BEGIN -- insert new data
	                    INSERT INTO ttrneedg (codcomp,codcours,codcate,dteyear,typcon,typtrain,syncond,statement,flgprior,codcreate,coduser)
	                    VALUES (p_codcomp,v_codcours,v_codcate,p_year,v_typcon,v_typtrain,v_statement_1,v_inst_statement,v_flgprior,global_v_coduser,global_v_coduser);
	                END;
                    -- check and remove 'V_HRTR.FLGTALEN
                    if instr(v_statement_1, 'V_HRTR.FLGTALEN = ''Y''') <> 0 then
                        if instr(v_statement_1, 'or V_HRTR.FLGTALEN = ''Y''') <> 0 then
                            v_statement_1   := substr(v_statement_1,1,instr(v_statement_1,'V_HRTR.FLGTALEN')-5)||' or exists (select ttalente.codempid from ttalente where ttalente.codcomp like '''|| p_codcomp|| '%'''|| ' and ttalente.codempid =  V_HRTR.CODEMPID ) '||substr(v_statement_1,instr(v_statement_1,'V_HRTR.FLGTALEN = ''Y''')+21);
                        elsif instr(v_statement_1, 'and V_HRTR.FLGTALEN = ''Y''') <> 0 then
                            v_statement_1   := substr(v_statement_1,1,instr(v_statement_1,'V_HRTR.FLGTALEN')-5)||' and exists (select ttalente.codempid from ttalente where ttalente.codcomp like '''|| p_codcomp|| '%'''|| ' and ttalente.codempid =  V_HRTR.CODEMPID ) '||substr(v_statement_1,instr(v_statement_1,'V_HRTR.FLGTALEN = ''Y''')+21);
                        else
                            v_statement_1   := 'exists (select ttalente.codempid from ttalente where ttalente.codcomp like '''|| p_codcomp|| '%'''|| ' and ttalente.codempid =  V_HRTR.CODEMPID ) '||substr(v_statement_1,instr(v_statement_1,'V_HRTR.FLGTALEN = ''Y''')+21);
                        end if;
                    elsif  instr(v_statement_1, 'V_HRTR.FLGTALEN = ''N''') <> 0 then
                        if instr(v_statement_1, 'or V_HRTR.FLGTALEN = ''N''') <> 0 or instr(v_statement_1, 'and V_HRTR.FLGTALEN = ''N''') <> 0 then
                            v_statement_1   := substr(v_statement_1,1,instr(v_statement_1,'V_HRTR.FLGTALEN')-5)||substr(v_statement_1,instr(v_statement_1,'V_HRTR.FLGTALEN = ''N''')+21);
                        else
                            v_statement_1   := '1 = 1'||substr(v_statement_1,instr(v_statement_1,'V_HRTR.FLGTALEN = ''N''')+21);
                        end if;
                    end if;

	             -- end  add the course to ttrneedg

	             -- concat statement 1
	                v_base_statement        := 'select * from temploy1 e1 where codcomp like '''|| p_codcomp|| '%'''|| ' and staemp not in (''9'',''0'') and exists (SELECT V_HRTR.CODEMPID FROM V_HRTR,temploy1 WHERE '|| v_statement_1|| ' and V_HRTR.codempid =  e1.codempid and V_HRTR.codempid = temploy1.codempid)';
	             -- statement 2
	                IF v_conretrn1 = 'Y' THEN
	                    v_base_statement    := v_base_statement|| ' and exists (select distinct e.codempid from THISTRNN e where codcomp like '''|| p_codcomp|| '%'''|| ' and e.codempid =  e1.codempid and codcours = '''|| v_codcours|| ''' ) ';
	                ELSIF v_conretrn2 = 'Y' THEN
	                    v_base_statement    := v_base_statement|| ' and exists (select distinct e.codempid from THISTRNN e where codcours = '''|| v_codcours|| ''' and e.codempid =  e1.codempid and FLGTREVL = ''F'' and  codcomp like '''|| p_codcomp|| '%'')';
	                ELSIF v_contrnno = 'Y' THEN
	                    v_base_statement    := v_base_statement|| ' and not exists (select distinct e.codempid from THISTRNN e where codcours = '''|| v_codcours|| ''' and e.codempid =  e1.codempid )';
	                END IF;
	                v_base_statement        := v_base_statement|| ' order by e1.codempid ';
	            -- get employee
                commit;
	                obj_emp := json_object_t();
	                v_row2 := 0;
	                BEGIN
                    OPEN c1 FOR v_base_statement;
	                    LOOP
	                        FETCH c1 INTO ttpotent_record;
	                        EXIT WHEN ( c1%notfound );

                            if secur_main.secur3(p_codcomp,ttpotent_record.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
		                        v_row2      := v_row2 + 1;
		                        obj_data    := json_object_t();
		                        obj_data.put('flag', 'Add');
		                        obj_data.put('numseq', v_row2);
		                        obj_data.put('image', get_emp_img(ttpotent_record.codempid));
		                        obj_data.put('codempid', ttpotent_record.codempid);
		                        obj_data.put('empname', get_temploy_name(ttpotent_record.codempid, global_v_lang));
		                        obj_data.put('codpos', ttpotent_record.codpos);
		                        obj_data.put('position', get_tpostn_name(ttpotent_record.codpos, global_v_lang));
		                        v_work_month := TRUNC(( months_between(sysdate, ttpotent_record.dteefpos) ),0);
		                        GET_SERVICE_YEAR(ttpotent_record.dteefpos,sysdate,'Y',t_year,t_month,t_day);
		                        obj_data.put('work_month', t_year||'('||t_month||')');
		                        obj_emp.put(to_char(v_row2 - 1), obj_data);
		                        begin
		                            merge into ttrneedgd st
		                            using (select ttpotent_record.codempid codempid,to_number(p_year) dteyear,
                                                  /*ttpotent_record.codcomp*/p_codcomp codcomp,v_codcours codcours,ttpotent_record.codpos codpos,
                                                  TRUNC(( months_between(sysdate, ttpotent_record.dteefpos) ),0) agepos,
                                                  global_v_coduser codcreate, global_v_coduser coduser from dual) v
		                            on (    st.dteyear  = v.dteyear
		                                and st.codcomp = v.codcomp
		                                and st.codcours  = v.codcours
		                                and st.codempid = v.codempid)
		                            when matched then update set st.codpos = v.codpos,
		                                                         st.agepos = v.agepos,
		                                                         st.coduser = global_v_coduser
		                            when not matched then insert (codempid,dteyear,codcomp,codcours,codpos,agepos,codcreate,coduser)
		                            VALUES (v.codempid,v.dteyear,v.codcomp,v.codcours,v.codpos,v.agepos,v.codcreate,v.coduser);
		                        end;
	                        end if;
	                    END LOOP;
	                EXCEPTION WHEN OTHERS THEN
	                    ROLLBACK;
	                    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
	                END;

	                IF obj_emp.get_size() = 0 or v_row2 = 0 THEN
	                    obj_emp := json_object_t();
	                END IF;
	                obj_cours.put('codcours', v_codcours);
	                obj_cours.put('count', v_row2);
	                obj_cours.put('employee', obj_emp);
                    obj_cate_child.put(to_char(v_row), obj_cours);
                    v_row := v_row + 1;
                end if;
            end loop;
            obj_cate.put('children', obj_cate_child);
            obj_rows.put(to_char(j), obj_cate);
        END LOOP; -- end loop all course
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message(400, param_msg_error, global_v_lang);
    END gen_processed_emp;

    PROCEDURE process_general ( json_str_input IN  CLOB, json_str_output OUT CLOB ) AS
        json_obj         json_object_t;
        data_obj         json_object_t;
    BEGIN
        initial_value(json_str_input);
        check_codcomp;
        json_obj := json_object_t(json_str_input);
        data_obj := hcm_util.get_json_t(json_obj, 'param_json');
        if param_msg_error IS NULL THEN
            gen_processed_emp(data_obj, json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        IF param_msg_error IS NOT NULL THEN
            ROLLBACK;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        ELSE
            COMMIT;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message(400, param_msg_error, global_v_lang);
    END process_general;

    PROCEDURE gen_general_emp(data_obj json_object_t, json_str_output OUT CLOB ) AS
        obj_rows            json_object_t;
        obj_data            json_object_t;

        v_row               NUMBER := 0;
        v_work_month        NUMBER;
        v_dteefpos          temploy1.dteefpos%type;
        v_numlvl            temploy1.numlvl%type;

        t_year		        number  				:= 0;
        t_month   	        number  				:= 0;
        t_day 		        number  				:= 0;

        cursor c1 is
            select codempid,codpos
              from ttrneedgd  a
             where codcomp = p_codcomp
               and dteyear = p_year
               and codcours = p_codcours
          order by codempid;
    BEGIN
        obj_rows := json_object_t();
        for i in c1 loop
            BEGIN
                SELECT dteefpos,numlvl
                  INTO v_dteefpos,v_numlvl
                  FROM temploy1
                 WHERE codempid = i.codempid;
            END;
            if secur_main.secur3(p_codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                v_row := v_row+1;
	            obj_data := json_object_t();
	            obj_data.put('flag', 'Edit');
	            obj_data.put('numseq', v_row);
	            obj_data.put('image', get_emp_img(i.codempid));
	            obj_data.put('codempid', i.codempid);
	            obj_data.put('empname', get_temploy_name(i.codempid, global_v_lang));
	            obj_data.put('codpos', i.codpos);
	            obj_data.put('position', get_tpostn_name(i.codpos, global_v_lang));
	            v_work_month := TRUNC(( months_between(sysdate, v_dteefpos) ),0);
	            GET_SERVICE_YEAR(v_dteefpos,sysdate,'Y',t_year,t_month,t_day);
	            obj_data.put('work_month', t_year||'('||t_month||')');
	            obj_rows.put(to_char(v_row - 1), obj_data);
            end if;
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    END gen_general_emp;

    procedure get_general_emp(json_str_input in clob, json_str_output out clob) as
        json_obj         json_object_t;
        data_obj         json_object_t;
    BEGIN
        initial_value(json_str_input);
        check_codcomp;
        json_obj        := json_object_t(json_str_input);
        data_obj        := hcm_util.get_json_t(json_obj, 'param_json');
        if param_msg_error is null then
            gen_general_emp( json_obj,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_general_emp;

    PROCEDURE gen_competency_emp ( json_str_output OUT CLOB ) AS
        obj_rows        json_object_t;
        obj_rows2       json_object_t;
        obj_head        json_object_t;
        obj_result      json_object_t;
        obj_data        json_object_t;
        obj_data2       json_object_t;
        v_row           NUMBER := 0;
        v_row2          NUMBER := 0;
        v_numlvl        temploy1.numlvl%type;

        CURSOR c1 IS
            SELECT numseq, desprob, descoures, desresult
              FROM ttrneedp
             WHERE codcomp = p_codcomp
               AND dteyear = p_year
               AND numseq = p_problem_numseq;

        CURSOR c2 IS
            SELECT numseq, codempid, codcomp, codpos
              FROM ttrneedpd
             WHERE codcomp = p_codcomp
               AND dteyear = p_year
               AND numseq = p_problem_numseq
          ORDER BY codcomp, codpos, codempid;
    BEGIN
        obj_result  := json_object_t();
        obj_head    := json_object_t();
        obj_rows    := json_object_t();
        obj_data    := json_object_t();
        obj_rows    := json_object_t();
        FOR i IN c1 LOOP
            v_row       := v_row + 1;
            obj_data    := json_object_t();
            obj_rows.put('numseq', p_problem_numseq);
            obj_rows.put('desprob', i.desprob);
            obj_rows.put('descoures', i.descoures);
            obj_rows.put('desresult', i.desresult);
                -- gen employee
            obj_rows2   := json_object_t();
            v_row2      := 0;
            FOR j IN c2 LOOP
                BEGIN
                    SELECT numlvl
                      INTO v_numlvl
                      FROM temploy1
                     WHERE codempid = j.codempid;
                END;
                if secur_main.secur3(p_codcomp,j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
	                v_row2      := v_row2 + 1;
	                obj_data2   := json_object_t();
	                obj_data2.put('numseq', v_row2);
	                obj_data2.put('codempid', j.codempid);
	                obj_data2.put('employee_name', get_temploy_name(j.codempid, global_v_lang));
--	                obj_data2.put('codcomp', j.codcomp);
	                obj_data2.put('codcomp', p_codcomp);
	                obj_data2.put('agency', get_tcenter_name(j.codcomp, global_v_lang));
	                obj_data2.put('codpos', j.codpos);
	                obj_data2.put('position', get_tpostn_name(j.codpos, global_v_lang));
	                obj_rows2.put(to_char(v_row2 - 1), obj_data2);
                end if;
            END LOOP;
            obj_rows.put('employee', obj_rows2);
        END LOOP;

        obj_head.put('rows', obj_rows);
        obj_result.put('0', obj_head);
        json_str_output := obj_result.to_clob;
    END gen_competency_emp;

    PROCEDURE get_competency_emp ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        v_in_ttrneed BOOLEAN;
    BEGIN
        initial_value(json_str_input);
        check_codcomp;
        check_year;
        IF param_msg_error IS NULL THEN
            gen_competency_emp(json_str_output);
        END IF;
        IF param_msg_error IS NOT NULL THEN
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_competency_emp;

    PROCEDURE check_general_employee ( data_obj json_object_t ) AS
        v_temp                 VARCHAR2(40 CHAR);
        v_item_flgedit         VARCHAR2(40 CHAR);
        v_codempid_duplicate   BOOLEAN;
        v_employee_codcomp     temploy1.codcomp%TYPE;
        v_employee_numlvl      temploy1.numlvl%TYPE;
        v_codempid             ttrneedgd.codempid%TYPE;
        v_codpos               ttrneedgd.codpos%TYPE;
    BEGIN
        v_codempid      := upper(hcm_util.get_string_t(data_obj, 'codempid'));
        v_codpos        := upper(hcm_util.get_string_t(data_obj, 'codpos'));
        v_item_flgedit  := hcm_util.get_string_t(data_obj, 'flag');

        IF v_codempid IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
            return;
        END IF;

        BEGIN
            SELECT codcomp, numlvl
              INTO v_employee_codcomp, v_employee_numlvl
              FROM temploy1
             WHERE codempid = v_codempid;
        EXCEPTION WHEN no_data_found THEN
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TEMPLOY1');
            return;
        END;

        if secur_main.secur3(p_index_codcomp,v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
        end if;

        IF v_employee_codcomp LIKE p_index_codcomp||'%' THEN
            NULL;
        ELSE
            param_msg_error := get_error_msg_php('HR2104', global_v_lang);
            return;
        END IF;

        if secur_main.secur7(p_index_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        -- check duplicate
        v_codempid_duplicate := true;
        BEGIN
            SELECT 'x' INTO v_temp
              FROM ttrneedgd
             WHERE codempid = v_codempid
           	   and codcomp = p_index_codcomp
               and dteyear = p_year
               and codcours = p_codcours
               and rownum = 1;
        EXCEPTION WHEN no_data_found THEN
            v_codempid_duplicate := false;
        END;

        IF v_codempid_duplicate = true THEN
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TTRNEEDGD');
            return;
        END IF;
    END check_general_employee;

    PROCEDURE delete_general_employee ( data_obj json_object_t ) AS
        v_codempid ttrneedgd.codempid%TYPE;
    BEGIN
        v_codempid := upper(hcm_util.get_string_t(data_obj, 'codempid'));

        DELETE ttrneedgd
         WHERE dteyear = p_year
           AND codcomp = p_index_codcomp
           AND codcours = p_codcours
           AND codempid = v_codempid;

    END delete_general_employee;

    PROCEDURE insert_general_employee ( data_obj json_object_t ) AS
        v_codpos        ttrneedgd.codpos%TYPE;
        v_codempid      ttrneedgd.codempid%TYPE;
        v_dteefpos      temploy1.dteefpos%TYPE;
        v_codcomp       temploy1.codcomp%TYPE;
    BEGIN
        v_codpos        := upper(hcm_util.get_string_t(data_obj, 'codpos'));
        v_codempid      := upper(hcm_util.get_string_t(data_obj, 'codempid'));

        BEGIN
            SELECT dteefpos,codcomp
              INTO v_dteefpos, v_codcomp
              FROM temploy1
             WHERE codempid = v_codempid;
        END;

        begin
            INSERT INTO ttrneedgd ( dteyear, codcomp, codcours, codempid, codpos, agepos, dtecreate, codcreate, dteupd, coduser )
            VALUES ( p_year, p_index_codcomp, p_codcours, v_codempid, v_codpos, TRUNC(( months_between(sysdate, v_dteefpos) ),0), sysdate, global_v_coduser, sysdate, global_v_coduser);
        end;
    END insert_general_employee;

    PROCEDURE save_general_employee ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        json_obj         json_object_t;
        data_obj         json_object_t;
        v_item_flgedit   VARCHAR2(10 CHAR);
    BEGIN
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj, 'param_json');
        FOR i IN 0..param_json.get_size - 1 LOOP
            data_obj        := hcm_util.get_json_t(param_json, to_char(i));
            v_item_flgedit  := hcm_util.get_string_t(data_obj, 'flag');
            IF v_item_flgedit = 'Add' THEN
            check_general_employee(data_obj);
            IF param_msg_error IS NULL THEN
                insert_general_employee(data_obj);
            END IF;
            ELSIF v_item_flgedit = 'Delete' THEN
                delete_general_employee(data_obj);
            END IF;
        END LOOP;

        IF param_msg_error IS NOT NULL THEN
            ROLLBACK;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        ELSE
            COMMIT;
            param_msg_error := get_error_msg_php('HR2401', global_v_lang);
            json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END save_general_employee;

    PROCEDURE save_index_competency ( param_json json_object_t ) AS
        data_obj           json_object_t;
        data_course        json_object_t;
        data_employee      json_object_t;
        detail_course      json_object_t;
        detail_employee    json_object_t;
        v_flag             VARCHAR2(10 CHAR);
        v_codcomp          ttrneedc.codcompc%TYPE;
        v_codpos           ttrneedc.codpos%TYPE;
        v_codskill         ttrneedc.codskill%TYPE;
        v_codtency         ttrneedc.codtency%TYPE;
        v_grade            ttrneedc.grade%TYPE;
        v_flgprior         ttrneedc.flgprior%TYPE;
        v_qtyemp           ttrneedc.qtyemp%TYPE;

        v_codcours         ttrneedcc.codcours%TYPE;
        v_cours_grade      ttrneedcc.grade%TYPE;
        v_cc_flgprior      ttrneedcc.flgprior%TYPE;

        v_codempid         ttrneedcd.codempid%type;
        v_grade_emp        ttrneedcd.grdemp%type;
    BEGIN
        FOR i IN 0..param_json.get_size - 1 LOOP -- loop competency
            data_obj    := hcm_util.get_json_t(param_json, to_char(i));
            v_codcomp   := upper(hcm_util.get_string_t(data_obj, 'codcomp'));
            v_codpos    := upper(hcm_util.get_string_t(data_obj, 'codpos'));
            v_codskill  := upper(hcm_util.get_string_t(data_obj, 'codskill'));
            v_codtency  := upper(hcm_util.get_string_t(data_obj, 'codtency'));
            v_grade     := to_number(hcm_util.get_string_t(data_obj, 'grade'));
            v_qtyemp    := to_number(hcm_util.get_string_t(data_obj, 'qtyemp'));
            v_flgprior  := upper(hcm_util.get_string_t(data_obj, 'flgprior'));

            v_flag      := hcm_util.get_string_t(data_obj, 'flag');
            if v_flag = 'Edit' then
                if v_flgprior is NULL then
                    param_msg_error := get_error_msg_php('HR2045', global_v_lang);
                end if;

                update ttrneedc
                   set flgprior = v_flgprior
                 where dteyear = p_year
                   and codcompc = v_codcomp
                   and codpos = v_codpos
                   and codskill = v_codskill
                   and grade = v_grade
                   and qtyemp = v_qtyemp
                   and coduser = global_v_coduser;

                data_course := hcm_util.get_json_t(data_obj, 'course' );
                FOR i IN 0..data_course.get_size - 1 LOOP
                    detail_course       := hcm_util.get_json_t(data_course, to_char(i));
                    v_codcours          := upper(hcm_util.get_string_t(detail_course, 'codcours'));
                    v_cours_grade       := to_number(hcm_util.get_string_t(detail_course, 'grade'));
                    v_cc_flgprior       := hcm_util.get_string_t(detail_course, 'flgprior');

                    if v_cc_flgprior is NULL then
                        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
                    end if;

                    update ttrneedcc
                       set flgprior = v_cc_flgprior
                     where dteyear = p_year
                       and codcompc = v_codcomp
                       and codpos = v_codpos
                       and codskill = v_codskill
                       and codcours = v_codcours
                       and grade = v_cours_grade
                       and coduser = global_v_coduser;
                END LOOP;
            end if;
            if v_flag = 'Add' then
                if v_flgprior is NULL then
                    param_msg_error := get_error_msg_php('HR2045', global_v_lang);
                end if;
                begin
                    insert into ttrneedc (dteyear,codcompc,codpos,codskill,grade,codtency,flgprior,qtyemp,codcreate,coduser)
                    values (p_year, v_codcomp, v_codpos, v_codskill, v_grade, v_codtency, v_flgprior ,v_qtyemp,global_v_coduser,global_v_coduser);
                end;

                data_course         := hcm_util.get_json_t(data_obj, 'course' );
                FOR i IN 0..data_course.get_size - 1 LOOP
                    detail_course   := hcm_util.get_json_t(data_course, to_char(i));
                    v_codcours      := upper(hcm_util.get_string_t(detail_course, 'codcours'));
                    v_cc_flgprior   := hcm_util.get_string_t(detail_course, 'flgprior');
                    v_cours_grade   := to_number(hcm_util.get_string_t(detail_course, 'grade'));

                    if v_cc_flgprior is NULL then
                        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
                    end if;

                    begin
                        insert into ttrneedcc (dteyear,codcompc,codpos,codskill,codcours,flgprior,grade,codcreate,coduser)
                        values (p_year,v_codcomp,v_codpos,v_codskill,v_codcours,v_cc_flgprior,v_cours_grade,global_v_coduser,global_v_coduser);
                    end;
                END LOOP;
                data_employee         := hcm_util.get_json_t(data_obj, 'employee' );
                FOR i IN 0..data_employee.get_size - 1 LOOP
                    detail_employee := hcm_util.get_json_t(data_employee, to_char(i));
                    v_codempid      := hcm_util.get_string_t(detail_employee, 'codempid');
                    v_grade_emp     := to_number(hcm_util.get_string_t(detail_employee, 'grade'));
                    begin
                        insert into ttrneedcd (dteyear,codcompc,codpos,codskill,codempid,grade,grdemp,codcreate,coduser)
                        values (p_year,v_codcomp,v_codpos,v_codskill,v_codempid,v_grade,v_grade_emp,global_v_coduser,global_v_coduser);
                    end;
                END LOOP;
            end if;
            if v_flag = 'Delete' then
                begin
                    DELETE ttrneedc
                     WHERE dteyear = p_year
                       AND codcompc = v_codcomp
                       AND codpos = v_codpos
                       AND codskill = v_codskill;
                end;
                begin
                    DELETE ttrneedcc
                     WHERE dteyear = p_year
                       AND codcompc = v_codcomp
                       AND codpos = v_codpos
                       AND codskill = v_codskill;
                end;
                begin
                   DELETE ttrneedcd
                    WHERE dteyear = p_year
                      AND codcompc = v_codcomp
                      AND codpos = v_codpos
                      AND codskill = v_codskill;
                end;
            end if;
        END LOOP; -- end competency
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END save_index_competency;

    PROCEDURE delete_index_general ( data_obj json_object_t ) AS
        v_codcours      ttrneedg.codcours%TYPE;
        v_codcate       ttrneedg.codcate%TYPE;
    BEGIN
        v_codcours      := upper(hcm_util.get_string_t(data_obj, 'codcours'));
        v_codcate       := upper(hcm_util.get_string_t(data_obj, 'codcate'));
        DELETE ttrneedgd
         WHERE dteyear = p_year
           AND codcomp = p_index_codcomp
           AND codcours = v_codcours;

        DELETE ttrneedg
         WHERE dteyear = p_year
           AND codcomp = p_index_codcomp
           AND codcours = v_codcours
           AND codcate = p_codcate;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_index_general;

    PROCEDURE insert_index_general ( data_obj json_object_t ) AS
        v_codcours     ttrneedg.codcours%TYPE;
        v_codcate      ttrneedg.codcate%TYPE;
        v_conspc       ttrneedg.typcon%TYPE;
        v_typcon       ttrneedg.typcon%TYPE;
        v_syncond      ttrneedg.syncond%TYPE;
        v_statement    ttrneedg.statement%TYPE;
        v_typtrain     ttrneedg.typtrain%TYPE;
        v_contrnno     ttrneedg.typtrain%TYPE;
        v_conretrn1    ttrneedg.typtrain%TYPE;
        v_conretrn2    ttrneedg.typtrain%TYPE;
        v_flgprior     ttrneedg.flgprior%TYPE;
        v_remark       ttrneedg.remark%TYPE;
        v_qtyemp       ttrneedg.qtyemp%TYPE;

        syncond_obj    json_object_t;
    BEGIN
        v_codcours      := upper(hcm_util.get_string_t(data_obj, 'codcours'));
        v_codcate       := upper(hcm_util.get_string_t(data_obj, 'codcate'));
        v_conspc        := upper(hcm_util.get_string_t(data_obj, 'conspc'));
        syncond_obj     := hcm_util.get_json_t(data_obj, 'syncond');
        v_syncond       := hcm_util.get_string_t(syncond_obj, 'code');
        v_statement     := hcm_util.get_string_t(syncond_obj, 'statement');
        v_contrnno      := upper(hcm_util.get_string_t(data_obj, 'contrnno'));
        v_conretrn1     := upper(hcm_util.get_string_t(data_obj, 'conretrn1'));
        v_conretrn2     := upper(hcm_util.get_string_t(data_obj, 'conretrn2'));
        v_flgprior      := upper(hcm_util.get_string_t(data_obj, 'flgprior'));
        v_remark        := hcm_util.get_string_t(data_obj, 'remark');
        v_qtyemp        := to_number(hcm_util.get_string_t(data_obj, 'qtyemp'));

        if v_conspc = 'Y' or v_conspc = '1'  then
            v_typcon    := '1';
        elsif  v_conspc = 'N' or v_conspc = '2' then
            v_typcon    := '2';
        end if;

        if v_conretrn1 = 'Y' then
            v_typtrain  := '1';
        elsif v_conretrn2 = 'Y' then
            v_typtrain  := '2';
        elsif v_contrnno = 'Y' then
            v_typtrain  := '3';
        else
            v_typtrain  := '4';
        end if;

        BEGIN -- remove old data
            DELETE FROM ttrneedg
             WHERE dteyear = p_year
               AND codcomp = p_codcomp
               AND codcours = v_codcours;
        END;

        BEGIN -- insert new data
            INSERT INTO ttrneedg ( codcomp, codcours, codcate, dteyear, typcon, syncond, statement,typtrain, remark,
                flgprior, qtyemp, dtecreate, codcreate, dteupd, coduser )
            VALUES ( p_index_codcomp, v_codcours, p_codcate, p_year, v_typcon, v_syncond, v_statement, v_typtrain,
                v_remark, v_flgprior, v_qtyemp, sysdate, global_v_coduser, sysdate, global_v_coduser );
        exception when DUP_VAL_ON_INDEX  then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TTRNEEDG');
        END;
    END insert_index_general;

    PROCEDURE update_index_general ( data_obj  json_object_t ) AS
        v_codcours      ttrneedg.codcours%TYPE;
        v_codcate       ttrneedg.codcate%TYPE;
        v_conspc        ttrneedg.typcon%TYPE;
        v_typcon        ttrneedg.typcon%TYPE;
        v_syncond       ttrneedg.syncond%TYPE;
        v_statement     ttrneedg.statement%TYPE;
        v_typtrain      ttrneedg.typtrain%TYPE;
        v_contrnno      ttrneedg.typtrain%TYPE;
        v_conretrn1     ttrneedg.typtrain%TYPE;
        v_conretrn2     ttrneedg.typtrain%TYPE;
        v_flgprior      ttrneedg.flgprior%TYPE;
        v_remark        ttrneedg.remark%TYPE;
        v_qtyemp        ttrneedg.qtyemp%TYPE;

        syncond_obj     json_object_t;
    BEGIN
        v_codcours      := upper(hcm_util.get_string_t(data_obj, 'codcours'));
        v_codcate       := upper(hcm_util.get_string_t(data_obj, 'codcate'));
        v_conspc        := upper(hcm_util.get_string_t(data_obj, 'conspc'));
        syncond_obj     := hcm_util.get_json_t(data_obj, 'syncond');
        v_syncond       := hcm_util.get_string_t(syncond_obj, 'code');
        v_statement     := hcm_util.get_string_t(syncond_obj, 'statement');
        v_contrnno      := upper(hcm_util.get_string_t(data_obj, 'contrnno'));
        if v_contrnno = '' then
            v_contrnno  := 'N';
        end if;
        v_conretrn1     := upper(hcm_util.get_string_t(data_obj, 'conretrn1'));
        if v_conretrn1 = '' then
            v_conretrn1 := 'N';
        end if;
        v_conretrn2     := upper(hcm_util.get_string_t(data_obj, 'conretrn2'));
        v_flgprior      := upper(hcm_util.get_string_t(data_obj, 'flgprior'));
        v_remark        := hcm_util.get_string_t(data_obj, 'remark');
        v_qtyemp        := to_number(hcm_util.get_string_t(data_obj, 'qtyemp'));

        if v_conspc = 'Y'  or v_conspc = '1'  then
            v_typcon    := '1';
        elsif   v_conspc = 'N' or v_conspc = '2' then
            v_typcon    := '2';
        end if;

        if v_conretrn1 = 'Y' then
            v_typtrain  := '1';
        elsif v_conretrn2 = 'Y' then
            v_typtrain  := '2';
        elsif v_contrnno = 'Y' then
            v_typtrain  := '3';
        else
            v_typtrain  := '4';
        end if;

        UPDATE ttrneedg
           SET typcon = v_typcon,
               syncond = v_syncond,
               statement = v_statement,
               typtrain = v_typtrain,
               flgprior = v_flgprior,
               remark = v_remark,
               qtyemp = v_qtyemp,
               dteupd  =  sysdate,
               coduser =  global_v_coduser
         WHERE dteyear = p_year
           AND codcomp = p_index_codcomp
           AND codcours = v_codcours
           AND codcate = p_codcate;

    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END update_index_general;

    PROCEDURE save_index_general ( param_json json_object_t ) AS
        data_obj           json_object_t;
        data_obj_children  json_object_t;
        data_obj_child     json_object_t;
        v_item_flgedit     VARCHAR2(10 CHAR);
    BEGIN
        FOR i IN 0..param_json.get_size - 1 LOOP
            data_obj            := hcm_util.get_json_t(param_json, to_char(i));
            p_codcate           := hcm_util.get_string_t(data_obj, 'codcate');
            data_obj_children   := hcm_util.get_json_t(data_obj, 'children');
            FOR j IN 0..data_obj_children.get_size - 1 LOOP
                data_obj_child  := hcm_util.get_json_t(data_obj_children, to_char(j));
                v_item_flgedit  := hcm_util.get_string_t(data_obj_child, 'flag');
                IF v_item_flgedit = 'Delete' THEN
                    delete_index_general(data_obj_child);
                ELSIF v_item_flgedit = 'Add' THEN
                    insert_index_general(data_obj_child);
                ELSIF v_item_flgedit = 'Edit' THEN
                    update_index_general(data_obj_child);
                END IF;
            END LOOP;
        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END save_index_general;

    PROCEDURE delete_index_problem ( data_obj json_object_t ) AS
        v_numseq    ttrneedp.numseq%TYPE;
        v_codcomp   tcenter.codcomp%type;
    BEGIN
        v_numseq    := upper(hcm_util.get_string_t(data_obj, 'numseq'));
        v_codcomp   := upper(hcm_util.get_string_t(data_obj, 'codcomp'));

        DELETE ttrneedpd
         WHERE dteyear = p_year
           AND numseq = v_numseq
           AND dteyear = p_year
           AND CODCOMP = v_codcomp;

        DELETE ttrneedp
         WHERE dteyear = p_year
           AND codcomp = v_codcomp
           AND numseq = v_numseq;
    END delete_index_problem;

    PROCEDURE save_index_problem ( param_json json_object_t ) AS
        data_obj           json_object_t;
        v_item_flgedit     VARCHAR2(10 CHAR);

    BEGIN
        FOR i IN 0..param_json.get_size - 1 LOOP
            data_obj        := hcm_util.get_json_t(param_json, to_char(i));
            v_item_flgedit  := hcm_util.get_string_t(data_obj, 'flag');
            IF v_item_flgedit = 'Delete' THEN
                delete_index_problem(data_obj);
            END IF;
        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END save_index_problem;
    --
    procedure delete_ttrneed is
      v_cnt_g   number := 0;
      v_cnt_c   number := 0;
      v_cnt_p   number := 0;
    begin
      begin
        select 1
          into v_cnt_g
          from ttrneedg
         where dteyear = p_year
           and codcomp = p_codcomp
           and rownum = 1;
      exception when no_data_found then
        v_cnt_g := 0;
      end;
      begin
        select 1
          into v_cnt_c
          from ttrneedc
         where dteyear = p_year
           and codcompc = p_codcomp
           and rownum = 1;
      exception when no_data_found then
        v_cnt_c := 0;
      end;
      begin
        select 1
          into v_cnt_p
          from ttrneedp
         where dteyear = p_year
           and codcomp like p_codcomp||'%'
           and rownum = 1;
      exception when no_data_found then
        v_cnt_p := 0;
      end;
      if v_cnt_g = 0 and v_cnt_c = 0 and v_cnt_p = 0 then
        delete from ttrneed where dteyear = p_year and codcomp = p_codcomp;
      end if;
    end;
    --
    PROCEDURE save_index( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        json_obj            json_object_t;
        data_obj            json_object_t;
        v_item_flgedit      VARCHAR2(10 CHAR);
        v_codsurvey         VARCHAR2(10 CHAR);
        v_dtesurvey         DATE;
        v_employee_numlvl   temploy1.numlvl%TYPE;
    BEGIN
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);
        p_index_codcomp     := upper(hcm_util.get_string_t(json_obj, 'codcomp'));
        param_json          := hcm_util.get_json_t(json_obj, 'param_json');
        v_codsurvey         := upper(hcm_util.get_string_t(param_json, 'codsurv'));
        v_dtesurvey         := to_date(hcm_util.get_string_t(param_json, 'dtesurv'), 'dd/mm/yyyy');
    -- validate
        IF v_codsurvey IS NULL OR v_dtesurvey IS NULL THEN
            param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        END IF;
        begin
            select numlvl
              into v_employee_numlvl
              from TEMPLOY1
             where codempid = v_codsurvey;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        end;

        if secur_main.secur7(p_index_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;

        if secur_main.secur3(p_index_codcomp,v_codsurvey,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false  then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
    -- end validate

        IF param_msg_error IS NULL THEN
            data_obj := json_object_t();
            data_obj := hcm_util.get_json_t(param_json, 'general');
            save_index_general(data_obj);
        END IF;

        IF param_msg_error IS NULL THEN
            data_obj := json_object_t();
            data_obj := hcm_util.get_json_t(param_json, 'competency');
            save_index_competency(data_obj);
        END IF;

        IF param_msg_error IS NULL THEN
            data_obj := json_object_t();
            data_obj := hcm_util.get_json_t(param_json, 'problem');
            save_index_problem(data_obj);
        END IF;

        IF param_msg_error IS NULL THEN
          begin
              INSERT INTO ttrneed ( dteyear, codcomp, codsurvey, dtesurvey, dtecreate, codcreate, dteupd, coduser )
              VALUES (p_year, p_codcomp, v_codsurvey, v_dtesurvey, sysdate, global_v_coduser, sysdate, global_v_coduser );
          exception when dup_val_on_index then
            update ttrneed
               set codsurvey    = v_codsurvey,
                   dtesurvey    = v_dtesurvey,
                   dteupd       = sysdate,
                   coduser      = global_v_coduser
             where dteyear      = p_year
               and codcomp      = p_codcomp;
          end;
          delete_ttrneed;
        END IF;

        IF param_msg_error IS NOT NULL THEN
            ROLLBACK;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        ELSE
            COMMIT;
            param_msg_error := get_error_msg_php('HR2401', global_v_lang);
            json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END save_index;
    procedure get_problem_list(json_str_input in clob, json_str_output out clob) is
    begin
        initial_value(json_str_input);
        check_codcomp;
        check_year;

        if param_msg_error is not null then
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
            return;
        end if;
        gen_problem_list(json_str_output);
    end get_problem_list;
    procedure gen_problem_list(json_str_output out clob) is
        v_problem_clob    clob;
        obj_rows          json_object_t;
    begin
        v_problem_clob := get_problem;
        obj_rows := json_object_t(v_problem_clob);
        json_str_output := obj_rows.to_clob;
    end gen_problem_list;
END HRTR22E;

/
