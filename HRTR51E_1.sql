--------------------------------------------------------
--  DDL for Package Body HRTR51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR51E" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codcompy      := upper(hcm_util.get_string(json_obj,'codcompy'));
        p_year          := to_number(hcm_util.get_string(json_obj,'year'));
        p_codcate       := upper(hcm_util.get_string(json_obj, 'codcate'));
        p_codcours       := upper(hcm_util.get_string(json_obj, 'codcours'));
        p_numclseq      := hcm_util.get_string(json_obj,'numclseq');

    end initial_value;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        obj_data2    json;
        v_row       number := 0;
        v_row2       number := 0;
        v_codcours  TYRTRPLN.codcours%type;
        v_intruct_name VARCHAR2(300);
        v_cnt_sch   number := 0;
        v_cnt_emp   number := 0;

        cursor c1 is  -- course
            select codcate,codcours, qtynumcl,qtyptbdg,plancond
            from TYRTRPLN a
            where codcompy = p_codcompy
            and dteyear = p_year
            and codcate  = nvl(p_codcate,codcate)
            and staappr = 'Y'
            order by codcate,codcours;

        cursor c2 is -- instructor
            select a.CODINST
            from TYRTRSCH a
            where codcompy = p_codcompy
            and dteyear = p_year
            and codcate  = nvl(p_codcate,codcate)
            and codcours = v_codcours
            group by CODINST;

    begin
        obj_rows := json();
        for i in c1 loop
                v_codcours := i.codcours;
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('codcate',i.codcate);
                obj_data.put('category',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
                obj_data.put('codcours',i.codcours);
                obj_data.put('course',get_tcourse_name(i.codcours,global_v_lang));
                begin
                    select count(numclseq),sum(nvl(qtyemp,0))
                      into v_cnt_sch, v_cnt_emp
                      from tyrtrsch
                     where dteyear = p_year
                       and codcompy = p_codcompy
                       and codcours = i.codcours;
                    exception when no_data_found then
                       v_cnt_sch := 0;
                       v_cnt_emp := 0;
                end;

             --obj_data.put('qtynumcl',i.qtynumcl);
             --obj_data.put('qtyptbdg',i.qtyptbdg);
                obj_data.put('qtynumcl',v_cnt_sch);
                obj_data.put('qtyptbdg',v_cnt_emp);
                obj_data.put('plancond',i.plancond);
                obj_data.put('plancond_desc',get_tlistval_name('STACOURS', i.plancond,global_v_lang));
                v_row2 := 0; -- get all intructor name
                v_intruct_name := '';
                for j in c2 loop
                    v_row2 := v_row2+1;
                    if v_row2 = 1 then
                        v_intruct_name := get_tinstruc_name(j.codinst, global_v_lang);
                    else
                        v_intruct_name := v_intruct_name||', '||get_tinstruc_name(j.codinst, global_v_lang);
                    end if;
                end loop;
                obj_data.put('instrucname',v_intruct_name); -- end get all intructor name
                obj_data.put('qtyintruct',v_row2);
                obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRPLN');
            return;
        else
            dbms_lob.createtemporary(json_str_output, true);
            obj_rows.to_clob(json_str_output);
        end if;
    end gen_index;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcompy is null or p_year is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from tcompny
            where codcompy like p_codcompy
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        if not p_codcate like '' or not p_codcate is null then
            begin
                select 'X' into v_temp
                from tcodcate
                where codcodec like p_codcate
                and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATE');
                return;
            end;
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
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure get_inst(json_str_input in clob, json_str_output out clob) as
        json_obj json;
        p_codinst  tyrtrsch.codinst%type;
        obj_data    json;
        obj_head    json;

        v_stainst tinstruc.STAINST%type;
    begin
        json_obj          := json(json_str_input);
        obj_data        := json;
        obj_head        := json;
        initial_value(json_str_input);
        p_codinst      := upper(hcm_util.get_string(json_obj,'codinst'));
        obj_data.put('codinst',p_codinst);
        obj_data.put('codinst_desc',get_tinstruc_name(p_codinst,global_v_lang));
        begin
            select stainst into v_stainst
            from tinstruc
            where codinst = p_codinst
            and rownum = 1;
        exception when no_data_found then
            v_stainst := '';
        end;
        obj_data.put('stainst',v_stainst);
        obj_data.put('stainst_desc',get_tlistval_name('STAINST',v_stainst,global_v_lang));
        obj_head.put('0',obj_data);
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_inst;

    procedure check_detail as
        v_temp varchar2(1 char);
        v_has_codemp BOOLEAN := false;
    begin
        if p_year is null or p_codcours is null or p_codcompy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

    end check_detail;

    procedure gen_detail(json_str_output out clob) as
        obj_head    json;
    begin
        obj_head := json();
        obj_head.put('rows',std_tyrtrpln(p_codcompy, p_year, p_codcours,global_v_lang));
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tyrtrsch');
            return;
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure gen_edit_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;

        cursor c1 is  -- course
            select a.numclseq,a.dtetrst, a.dtetren,a.codhotel,a.codinsts,a.codinst,a.qtyemp,b.amtpbdg,c.QTYTRDAY
            from tyrtrsch a,TYRTRPLN b, tcourse c
            where a.dteyear = b.dteyear
            and a.codcompy = b.codcompy
            and a.codcours = b.codcours
            and a.codcours = c.codcours
            and a.dteyear = p_year
            and a.codcompy = p_codcompy
            and a.codcours = p_codcours
            order by a.numclseq;

    begin
        obj_rows := json();
        for i in c1 loop
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('numclseq',i.numclseq);
                obj_data.put('qtytrday',i.QTYTRDAY);
                obj_data.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
                obj_data.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_data.put('codhotel',i.codhotel);
                obj_data.put('codhotel_desc',get_thotelif_name(i.codhotel,global_v_lang));
                obj_data.put('codinsts',i.codinsts);
                obj_data.put('codinsts_desc',get_tinstitu_name(i.codinsts,global_v_lang));
                obj_data.put('codinst',i.codinst);
                obj_data.put('codinst_desc',get_tinstruc_name(i.codinst,global_v_lang));
                obj_data.put('qtyemp',i.qtyemp);
                obj_data.put('budget',i.amtpbdg * i.qtyemp);
                obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_edit_index;

    procedure check_edit_index as
        v_temp varchar2(1 char);
        v_max_numclseq number := 0;
        v_numclseq number := 0;

    begin
        if p_codcompy is null or p_year is null or p_codcours is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
            from tcompny
            where codcompy like p_codcompy
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        if not p_codcate like '' or not p_codcate is null then
            begin
                select 'X' into v_temp
                from tcodcate
                where codcodec like p_codcate
                and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATE');
                return;
            end;
        end if;

         begin
            select count(*)+1
              into v_max_numclseq
              from tyrtrsch
             where dteyear  = p_year
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq  <> p_numclseq;
        end;

         begin
            select nvl(qtynumcl,0)
              into v_numclseq
              from tyrtrpln
             where dteyear  = p_year
               and codcompy = p_codcompy
               and codcours = p_codcours
               and rownum = 1;
            exception when no_data_found then
                v_numclseq := 0;
        end;

        if nvl(v_max_numclseq,0) <> 1 then
            if v_max_numclseq > v_numclseq then
                  param_msg_error := get_error_msg_php('TR0049',global_v_lang);
                return;
            end if;
        end if;
--        
--        if nvl(v_max_numclseq,0) <> 1 then
--            if p_numclseq > v_numclseq then
--                  param_msg_error := get_error_msg_php('TR0049',global_v_lang);
--                return;
--            end if;
--        end if;

    end check_edit_index;

    procedure get_edit_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_edit_index;
        if param_msg_error is null then
            gen_edit_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_edit_index;

    procedure gen_edit_detail(json_str_output out clob) as
        obj_result      json;
        obj_rows        json;
        obj_rows2       json;
        obj_head        json;
        v_row           number := 0;
        v_row2          number := 0;

        obj_data        json;
		obj_data2       json;

        v_qtytrhur          tcourse.qtytrhur%type;
        v_qtytrday          tcourse.qtytrday%type;
        v_hour              number(5,0);
        v_min               number(5,0);
        v_amtpbdg           tyrtrpln.amtpbdg%type;
        v_qtyptbdg          tyrtrpln.qtyptbdg%type;
        v_stainst           tinstruc.stainst%type;
        v_hr                varchar(10 char);
        v2_qtypc            number;

        cursor c1trdetail is
            select codtparg,codhotel,codinsts,codinst,stainst,staemptr,dtetrst,dtetren,timestr,timeend,qtytrday,qtytrmin,qtyemp,remark
            from tyrtrsch a
            where a.dteyear = p_year
            and a.codcompy = p_codcompy
            and a.codcours = p_codcours
            and a.numclseq = p_numclseq;

        cursor c2subjdetail is
            select a.codsubj, a.codinst, qtytrmin
            from tyrtrsubj a   
            where a.dteyear = p_year
            and a.codcompy = p_codcompy
            and a.codcours = p_codcours
            and a.numclseq = p_numclseq
            order by codsubj;

    begin
        obj_head := json();
        obj_result := json();

-- trdetail
        obj_rows := json(); --  training detail
        for i in c1trdetail loop
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('codtparg',i.codtparg);
                obj_data.put('codtparg_desc',get_tlistval_name('CODTPARG', i.CODTPARG,global_v_lang));
                obj_data.put('codhotel',i.codhotel);
                obj_data.put('codhotel_desc',get_thotelif_name(i.codhotel,global_v_lang));
                obj_data.put('codinsts',i.codinsts);
                obj_data.put('codinsts_desc',get_tinstitu_name(i.codinsts,global_v_lang));
                obj_data.put('codinst',i.codinst);
                obj_data.put('codinst_desc',get_tinstruc_name(i.codinst,global_v_lang));
                obj_data.put('stainst',i.stainst);
                obj_data.put('stainst_desc',get_tlistval_name('STAINST',i.stainst,global_v_lang));
                obj_data.put('staemptr',i.staemptr);  -- end training detail
                obj_data.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));  --  training detail time table
                obj_data.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_data.put('timestr',substr(i.timestr, 1, 2) || ':' || substr(i.timestr, 3, 2));
                obj_data.put('timeend',substr(i.timeend, 1, 2) || ':' || substr(i.timeend, 3, 2));

                begin  -- default course duration
                    select qtytrday,qtytrhur into v_qtytrday,v_qtytrhur
                    from tcourse
                    where codcours = p_codcours;
                    exception when no_data_found then
                        v_qtytrday := 0;
                        v_qtytrhur := 0;
                end;

                v_hr := replace(v_qtytrhur, '.', ':');
                if instr(v_hr, ':') = 0 then
                    obj_data.put('qtytrmin',rpad(v_hr||':',length(v_hr||':')+2,'0'));
                else
                    if length(substr(v_hr, instr(v_hr, ':') + 1)) = 2 then
                        obj_data.put('qtytrmin',v_hr);
                    else
                        obj_data.put('qtytrmin',rpad(v_hr,length(v_hr)+1,'0'));
                    end if;
                end if;
                
                obj_data.put('qtytrday',nvl(v_qtytrday,0));                     --> Peerasak || #8964 || 22032023
                obj_data.put('qtyemp',i.qtyemp);        

--<< #7520 || 24/02/2022 || user39                
                if i.qtyemp is null or i.qtyemp = 0 then
                       begin
                           select qtyppc into v2_qtypc 
                           from tcourse where codcours = p_codcours;
                       exception when no_data_found then
                           v2_qtypc := '';
                       end;
                   obj_data.put('qtyemp',v2_qtypc);
                end if;
-->> #7520 || 24/02/2022 || user39

                begin
                     select amtpbdg,qtyptbdg  into v_amtpbdg,v_qtyptbdg
                       from tyrtrpln
                      where dteyear = p_year
                        and codcompy  = p_codcompy
                        and codcours  = p_codcours;
                exception when no_data_found then
                    v_amtpbdg := 0;
                    v_qtyptbdg := 0;
                end;

                obj_data.put('amtpdbg',v_amtpbdg);
                obj_data.put('maxqtyemp',v_qtyptbdg);
                obj_data.put('budget',v_amtpbdg * i.qtyemp);
                obj_data.put('remark', i.remark);
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
            return;
        else
            obj_head.put('training_detail',obj_data);
        end if; --  end training detail time table

-- subject detail
        obj_rows2 := json(); --  subject detail
        for i in c2subjdetail loop
                v_row2 := v_row2+1;
                obj_data2 := json();
                obj_data2.put('codsubj',i.codsubj);
                obj_data2.put('codinst',i.codinst);
                begin
                       select stainst into v_stainst
                         from tinstruc
                        where codinst = i.codinst
                          and rownum = 1;
                end;
                v_hr := replace(i.qtytrmin, '.', ':');
                if instr(v_hr, ':') = 0 then
                    obj_data2.put('qtytrmin',rpad(v_hr||':',length(v_hr||':')+2,'0'));
                else
                    if length(substr(v_hr, instr(v_hr, ':') + 1)) = 2 then
                        obj_data2.put('qtytrmin',v_hr);
                    else
                        obj_data2.put('qtytrmin',rpad(v_hr,length(v_hr)+1,'0'));
                    end if;
                end if;
                obj_data2.put('stainst',v_stainst);
                obj_data2.put('stainst_desc',get_tlistval_name('STAINST',v_stainst,global_v_lang));
                obj_rows2.put(to_char(v_row2-1),obj_data2);
        end loop;
            obj_head.put('subject_detail',obj_rows2);
		obj_head.put('flag','Edit');
		obj_result.put('0',obj_head);
		dbms_lob.createtemporary(json_str_output, true);
		obj_result.to_clob(json_str_output);
    end gen_edit_detail;

    procedure gen_new_edit_detail(json_str_output out clob) as
        obj_result    json;
        obj_rows      json;
        obj_rows2     json;
        obj_head      json;
        v_row         number := 0;
        v_row2        number := 0;

        obj_data      json;
		obj_data2     json;

        v_qtytrhur    tcourse.qtytrhur%type;
        v_qtytrday    tcourse.qtytrday%type;
        v_hour        number(5,0);
        v_min         number(5,0);
        v_stainst     tinstruc.stainst%type;

        v_amtpbdg     tyrtrpln.amtpbdg%type;
        v_qtyptbdg    tyrtrpln.qtyptbdg%type;
        v_hr          varchar(10 char);
        v2_qtypc      number;

        cursor c1 is
             select a.codsubj, a.codinst, qtytrhr
               from tcoursub a
              where a.codcours = p_codcours
            order by codsubj;

    begin
        obj_head := json();
        obj_result := json();

--  training detail
        obj_data := json();
        begin  -- default course duration
            select qtytrday,qtytrhur into v_qtytrday,v_qtytrhur
            from tcourse
            where codcours = p_codcours;
            exception when no_data_found then
                v_qtytrday := 0;
                v_qtytrhur := 0;
        end;

        v_hr := replace(v_qtytrhur, '.', ':');
        if instr(v_hr, ':') = 0 then
            obj_data.put('qtytrmin',rpad(v_hr||':',length(v_hr||':')+2,'0'));
        else
            if length(substr(v_hr, instr(v_hr, ':') + 1)) = 2 then
                obj_data.put('qtytrmin',v_hr);
            else
                obj_data.put('qtytrmin',rpad(v_hr,length(v_hr)+1,'0'));
            end if;
        end if;

        obj_data.put('qtytrday', nvl(v_qtytrday, 0));                                    --> Peerasak || #8964 || 22032023

        begin  -- default course duration
            select amtpbdg,qtyptbdg into v_amtpbdg,v_qtyptbdg
            from tyrtrpln
            where codcours = p_codcours
            and codcompy = p_codcompy
            and dteyear = p_year
            and rownum = 1;
            exception when no_data_found then
                v_qtyptbdg := 0;
        end;
        obj_data.put('amtpdbg',v_amtpbdg);
        obj_data.put('maxqtyemp',v_qtyptbdg);
        obj_data.put('budget', 0);

        --<< #7520 || 24/02/2022 || user39                
           begin
               select qtyppc into v2_qtypc 
               from tcourse where codcours = p_codcours;
               obj_data.put('qtyemp',v2_qtypc);                  
           exception when no_data_found then
               null;
           end;
        -->> #7520 || 24/02/2022 || user39

        obj_data.put('codtparg','1');
        obj_head.put('training_detail',obj_data);
        --  end training detail

-- subject detail
        obj_rows2 := json(); -- default subject
        for i in c1 loop
                v_row2 := v_row2+1;
                obj_data2 := json();
                obj_data2.put('codsubj',i.codsubj);
                obj_data2.put('codinst',i.codinst);
                begin
                    select stainst into v_stainst
                        from tinstruc
                        where codinst = i.codinst
                        and rownum = 1;
                exception when no_data_found then
                    v_stainst := '';
                end;
                obj_data2.put('stainst',v_stainst);
                obj_data2.put('stainst_desc',get_tlistval_name('STAINST',v_stainst,global_v_lang));
--<<15/08/2022 --redmine 8201
--                obj_data2.put('qtytrmin',hcm_util.convert_minute_to_hour(i.qtytrhr));
                 obj_data2.put('qtytrmin',hcm_util.convert_hour_to_minute(i.qtytrhr));
--<<15/08/2022 --redmine 8201
                obj_rows2.put(to_char(v_row2-1),obj_data2);
        end loop;
        if v_row2 = 0 then
              obj_head.put('subject_detail',obj_rows2);
        else
            obj_head.put('subject_detail',obj_rows2);
        end if;        -- end subject detail
		obj_head.put('flag','Add');
        obj_result.put('0',obj_head);
		dbms_lob.createtemporary(json_str_output, true);
		obj_result.to_clob(json_str_output);
    end gen_new_edit_detail;

    procedure get_edit_detail(json_str_input in clob, json_str_output out clob) as
        v_temp                      varchar2(1 char);
        v_flag          varchar2(4 char) := 'Edit';
    begin
        initial_value(json_str_input);
        check_edit_index;
-- see if p_numclseq already exist
            begin
                select 'X' into v_temp
                from tyrtrsch a
                where a.dteyear = p_year
                and a.codcompy = p_codcompy
                and a.codcours = p_codcours
                and a.numclseq = p_numclseq
                and rownum = 1;
            exception when no_data_found then
                v_flag := 'Add';
            end;

        if param_msg_error is null and v_flag = 'Edit' then
            gen_edit_detail(json_str_output);
        elsif param_msg_error is null and v_flag = 'Add' then
            gen_new_edit_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_edit_detail;

    procedure check_param(data_obj json) as
        v_temp       varchar2(40 char);

    begin
        if p_codcompy is null or p_year is null  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from tcompny
            where codcompy like p_codcompy
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
    end check_param;

    procedure delete_gen(data_obj json,json_str_output out clob) as
        v_numclseq     tyrtrsch.NUMCLSEQ%type;
    begin
        v_numclseq   := upper(hcm_util.get_string(data_obj,'numgen'));
        delete tyrtrsch   -- delete class gen
         where dteyear  = p_year
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = v_numclseq;

        delete TYRTRSUBJ  -- delete that class gen subject
         where codcompy  = p_codcompy
           and dteyear  = p_year
           and codcours  = p_codcours
           and numclseq  = v_numclseq;

        if param_msg_error is null then
            commit;
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end delete_gen;


    procedure update_tyrtrpln_qty(json_str_output out clob) as
        v_numclseq_count   number := 0;
        v_qtyemp_sum       number := 0;
    begin
        begin
            select count(numclseq) into v_numclseq_count
            from tyrtrsch
            where dteyear = p_year
            and   codcompy = p_codcompy
            and   codcours = p_codcours;
        exception when no_data_found then
            v_numclseq_count := 0;
        end;
        begin
            select sum(qtyemp) into v_qtyemp_sum
            from tyrtrsch
            where dteyear = p_year
            and   codcompy = p_codcompy
            and   codcours = p_codcours;
        exception when no_data_found then
            v_qtyemp_sum := 0;
        end;
        update tyrtrpln
           set qtynumcl = v_numclseq_count,
               qtyptbdg  = v_qtyemp_sum,
                 dteupd  =  sysdate,
                 coduser =  global_v_coduser
        where dteyear = p_year
         and      codcompy = p_codcompy
         and      codcours = p_codcours;
        if param_msg_error is null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end update_tyrtrpln_qty;

    procedure save_edit_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
        data_obj    json;
        v_item_flgedit varchar2(10 char);
    begin
        initial_value(json_str_input);
        check_index;
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');

        for i in 0..param_json.count-1 loop
            data_obj := hcm_util.get_json(param_json,to_char(i));
            check_param(data_obj);
            if param_msg_error is null then
                v_item_flgedit := hcm_util.get_string(data_obj,'flag');
                if v_item_flgedit = 'Delete' then
                    delete_gen(data_obj, json_str_output);
                end if;
            end if;
        end loop;

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_edit_index;

    procedure insert_subject(detail_obj json, json_str_output out clob) as
        v_codsubj     TYRTRSUBJ.codsubj%type;
        v_codinst   TYRTRSUBJ.codinst%type;
        v_qtytrmin   TYRTRSUBJ.qtytrmin%type;
        v_qtytrmin_2   varchar2(2000 char);
        v_qtytrmin_3   TYRTRSUBJ.qtytrmin%type;
        v_temp      varchar2(2);

    begin
        v_codsubj   := upper(hcm_util.get_string(detail_obj,'codsubj'));
        v_codinst   := upper(hcm_util.get_string(detail_obj,'codinst'));
        v_qtytrmin  := hcm_util.convert_hour_to_minute(hcm_util.get_string(detail_obj,'qtytrmin'));
        v_qtytrmin_2 := hcm_util.convert_minute_to_hour(v_qtytrmin);
        v_qtytrmin_3 := replace(upper(v_qtytrmin_2),':','.');

        param_msg_error := get_error_msg_php('HR2005',global_v_lang);
        begin
            select 'X'  into v_temp
            from TYRTRSUBJ
         where codcompy  = p_codcompy
           and dteyear  = p_year
           and codcours  = p_codcours
           and numclseq  = p_numclseq
           and codsubj  = v_codsubj
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := null;
        end;
        if param_msg_error is null then
            insert into  TYRTRSUBJ ( codsubj, codinst, qtytrmin, dteyear, codcompy, codcours, numclseq,dtecreate,codcreate,dteupd,coduser)
                 values (v_codsubj,v_codinst,v_qtytrmin_3,p_year, p_codcompy, p_codcours, p_numclseq,sysdate,global_v_coduser,sysdate,global_v_coduser);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end insert_subject;

    procedure update_subject(detail_obj json, json_str_output out clob) as
        v_codsubj     TYRTRSUBJ.codsubj%type;
        v_codsubj_old     TYRTRSUBJ.codsubj%type;
        v_codinst   TYRTRSUBJ.codinst%type;
        v_qtytrmin   TYRTRSUBJ.QTYTRMIN%type;
        v_qtytrmin_2   varchar2(2000 char);
        v_qtytrmin_3   TYRTRSUBJ.qtytrmin%type;
        v_temp      varchar2(2);

    begin
        v_codsubj   := upper(hcm_util.get_string(detail_obj,'codsubj'));
        v_codsubj_old   := upper(hcm_util.get_string(detail_obj,'codsubjOld'));
        v_codinst   := upper(hcm_util.get_string(detail_obj,'codinst'));
        v_qtytrmin  := hcm_util.convert_hour_to_minute(hcm_util.get_string(detail_obj,'qtytrmin'));
        v_qtytrmin_2 := hcm_util.convert_minute_to_hour(v_qtytrmin);
        v_qtytrmin_3 := replace(upper(v_qtytrmin_2),':','.');

        param_msg_error := get_error_msg_php('HR2005',global_v_lang);
        begin
            select 'X'  into v_temp
            from TYRTRSUBJ
         where codcompy  = p_codcompy
           and dteyear  = p_year
           and codcours  = p_codcours
           and numclseq  = p_numclseq
           and codsubj  = v_codsubj
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := null;
        end;
        if v_codsubj like v_codsubj_old then
            param_msg_error := null;
        end if;
        if param_msg_error is null then
            update TYRTRSUBJ
               set codinst = v_codinst,
                   qtytrmin = v_qtytrmin_3,
                     dteupd  =  sysdate,
                     coduser =  global_v_coduser
             where codcompy  = p_codcompy
               and dteyear  = p_year
               and codcours  = p_codcours
               and numclseq  = p_numclseq
               and codsubj  = v_codsubj_old;
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end update_subject;

    procedure delete_subject(detail_obj json, json_str_output out clob) as
        v_codsubj     TYRTRSUBJ.codsubj%type;
        v_codinst   TYRTRSUBJ.codinst%type;
        v_qtytrmin   TYRTRSUBJ.QTYTRMIN%type;

    begin
        v_codsubj   := upper(hcm_util.get_string(detail_obj,'codsubj'));
        v_codinst   := upper(hcm_util.get_string(detail_obj,'codinst'));
        v_qtytrmin  := hcm_util.convert_hour_to_minute(hcm_util.get_string(detail_obj,'qtytrmin'));

        delete TYRTRSUBJ
         where codcompy  = p_codcompy
           and dteyear  = p_year
           and codcours  = p_codcours
           and numclseq  = p_numclseq
           and codsubj  = v_codsubj;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end delete_subject;

    procedure edit_subject_detail(data_obj json, json_str_output out clob) as
        v_item_flgedit varchar2(10 char);
        detail_obj    json;
    begin
        for i in 0..data_obj.count-1 loop
            if param_msg_error is null then
                detail_obj := hcm_util.get_json(data_obj,to_char(i));
                v_item_flgedit := hcm_util.get_string(detail_obj,'flag');
                if v_item_flgedit = 'Add' then
                    insert_subject(detail_obj, json_str_output);
                elsif v_item_flgedit = 'Edit' then
                    update_subject(detail_obj, json_str_output);
                elsif v_item_flgedit = 'Delete' then
                    delete_subject(detail_obj, json_str_output);
                end if;
            end if;
        end loop;

    end edit_subject_detail;

    procedure update_tyrtrsch(param_json json, json_str_output out clob) as

        data_obj    json;

        v_codtparg       tyrtrsch.codtparg%type;
        v_codhotel       tyrtrsch.codhotel%type;
        v_codinsts       tyrtrsch.codinsts%type;
        v_codinst        tyrtrsch.codinst%type;
        v_stainst        tyrtrsch.stainst%type;
        v_staemptr       tyrtrsch.staemptr%type;
        v_dtetrst        tyrtrsch.dtetrst%type;
        v_dtetren        tyrtrsch.dtetren%type;
        v_timestr        tyrtrsch.timestr%type;
        v_timeend        tyrtrsch.timeend%type;
        v_qtytrday       tyrtrsch.qtytrday%type;
        v_qtytrmin       tyrtrsch.qtytrmin%type;
        v_qtyemp         tyrtrsch.qtyemp%type;
        v_remark         tyrtrsch.remark%type;
        v2_qtypc         number;

    begin

        data_obj  := hcm_util.get_json(param_json,'training_detail');

        v_codtparg := upper(hcm_util.get_string(data_obj,'codtparg'));
        v_codhotel := upper(hcm_util.get_string(data_obj,'codhotel'));
        v_codinsts := upper(hcm_util.get_string(data_obj,'codinsts'));
        v_codinst  := upper(hcm_util.get_string(data_obj,'codinst'));
        v_stainst  := upper(hcm_util.get_string(data_obj,'stainst'));
        v_staemptr := upper(hcm_util.get_string(data_obj,'staemptr'));
        v_dtetrst  := to_date(upper(hcm_util.get_string(data_obj,'dtetrst')),'dd/mm/yyyy');
        v_dtetren  := to_date(upper(hcm_util.get_string(data_obj,'dtetren')),'dd/mm/yyyy');
        v_timestr  := replace(upper(hcm_util.get_string(data_obj,'timestr')),':','');
        v_timeend  := replace(upper(hcm_util.get_string(data_obj,'timeend')),':','');
        v_qtytrday := to_number(hcm_util.get_string(data_obj,'qtytrday'));
        v_qtytrmin := hcm_util.convert_hour_to_minute(hcm_util.get_string(data_obj,'qtytrmin'));
        v_qtyemp   := to_number(hcm_util.get_string(data_obj,'qtyemp'));
        v_remark   := hcm_util.get_string(data_obj,'remark');

        --<< #7520 || 24/02/2022 || user39                
        if v_qtyemp is null or v_qtyemp = 0 then
               begin
                   select qtyppc into v2_qtypc 
                   from tcourse where codcours = p_codcours;
                   v_qtyemp := v_qtyemp;
               exception when no_data_found then
                   null;
               end;
        end if;
        -->> #7520 || 24/02/2022 || user39

        update tyrtrsch
           set
                 codtparg  =  v_codtparg,
                 codhotel =  v_codhotel,
                 codinsts =  v_codinsts,
                 codinst =  v_codinst,
                 stainst =  v_stainst,
                 staemptr =  v_staemptr,
                 dtetrst =  v_dtetrst,
                 dtetren =  v_dtetren,
                 timestr =  v_timestr,
                 timeend =  v_timeend,
                 qtytrday =  v_qtytrday,
                 qtytrmin =  v_qtytrmin,
                 qtyemp =  v_qtyemp,
                 remark =  v_remark,
                 dteupd  =  sysdate,
                 coduser =  global_v_coduser
        where    dteyear = p_year
         and      codcompy = p_codcompy
         and      codcours = p_codcours
         and      numclseq = p_numclseq;         -- end update training_detail

        data_obj  := hcm_util.get_json(param_json,'subject_detail');
        edit_subject_detail(data_obj, json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end update_tyrtrsch;

    procedure insert_tyrtrsch(param_json json,json_str_output out clob) as

        data_obj    json;

        v_codtparg              tyrtrsch.codtparg%type;
        v_codhotel              tyrtrsch.codhotel%type;
        v_codinsts              tyrtrsch.codinsts%type;
        v_codinst               tyrtrsch.codinst%type;
        v_stainst               tyrtrsch.stainst%type;
        v_staemptr              tyrtrsch.staemptr%type;
        v_dtetrst               tyrtrsch.dtetrst%type;
        v_dtetren               tyrtrsch.dtetren%type;
        v_timestr               tyrtrsch.timestr%type;
        v_timeend               tyrtrsch.timeend%type;
        v_qtytrday              tyrtrsch.qtytrday%type;
        v_qtytrmin              tyrtrsch.qtytrmin%type;
        v_qtyemp                tyrtrsch.qtyemp%type;
        v_remark                tyrtrsch.remark%type;
        v2_qtypc                number;

    begin

        data_obj    := hcm_util.get_json(param_json,'training_detail');

        v_codtparg  := upper(hcm_util.get_string(data_obj,'codtparg'));
        v_codhotel  := upper(hcm_util.get_string(data_obj,'codhotel'));
        v_codinsts  := upper(hcm_util.get_string(data_obj,'codinsts'));
        v_codinst   := upper(hcm_util.get_string(data_obj,'codinst'));
        v_stainst   := upper(hcm_util.get_string(data_obj,'stainst'));
        v_staemptr  := upper(hcm_util.get_string(data_obj,'staemptr'));
        v_dtetrst   := to_date(upper(hcm_util.get_string(data_obj,'dtetrst')),'dd/mm/yyyy');
        v_dtetren   := to_date(upper(hcm_util.get_string(data_obj,'dtetren')),'dd/mm/yyyy');
        v_timestr   := replace(upper(hcm_util.get_string(data_obj,'timestr')),':','');
        v_timeend   := replace(upper(hcm_util.get_string(data_obj,'timeend')),':','');
        v_qtytrday  := to_number(hcm_util.get_string(data_obj,'qtytrday'));
        v_qtytrmin  := hcm_util.convert_hour_to_minute(hcm_util.get_string(data_obj,'qtytrmin'));
        v_qtyemp    := to_number(hcm_util.get_string(data_obj,'qtyemp'));
        v_remark    := hcm_util.get_string(data_obj,'remark');

        --<< #7520 || 24/02/2022 || user39                
        if v_qtyemp is null or v_qtyemp = 0 then
               begin
                   select qtyppc into v2_qtypc 
                   from tcourse where codcours = p_codcours;
                   v_qtyemp := v_qtyemp;
               exception when no_data_found then
                   null;
               end;
        end if;
        -->> #7520 || 24/02/2022 || user39

        insert into tyrtrsch
                  ( codtparg, codhotel, codinsts, codinst, stainst, staemptr, dtetrst
                 , dtetren,timestr, timeend, qtytrday, qtytrmin, qtyemp, remark,
                 dteyear, codcompy, codcours, numclseq ,codcate,dtecreate,codcreate,dteupd,coduser)
         values ( v_codtparg, v_codhotel,v_codinsts,v_codinst, v_stainst,v_staemptr,v_dtetrst
         ,v_dtetren,v_timestr,v_timeend,v_qtytrday,v_qtytrmin,v_qtyemp,v_remark,
                   p_year, p_codcompy, p_codcours, p_numclseq ,p_codcate,sysdate,global_v_coduser,sysdate,global_v_coduser);
        data_obj  := hcm_util.get_json(param_json,'subject_detail');
        edit_subject_detail(data_obj, json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end insert_tyrtrsch;

    procedure check_subject_detail(data_obj json, v_tr_codinst varchar2) as
        v_codsubj        TYRTRSUBJ.codsubj%type;
        v_codinst        TYRTRSUBJ.codinst%type;
        v_qtytrmin       TYRTRSUBJ.QTYTRMIN%type;
        v_item_flgedit   varchar2(10 char);
        detail_obj       json;
        v_temp           varchar2(40 char);
        v_row            number := 0; -- check must exist atleast 1 subject
        v_check_codinst  boolean := false;  -- check course's instructor must exist in subject's insructor
        v_count          number := 0;
    begin
        for i in 0..data_obj.count-1 loop
            v_row := v_row+1; -- check must exist atleast 1 subject
            detail_obj := hcm_util.get_json(data_obj,to_char(i));
            v_item_flgedit := hcm_util.get_string(detail_obj,'flag');
            if v_item_flgedit = 'Add' or v_item_flgedit = 'Edit' then
                v_codsubj   := upper(hcm_util.get_string(detail_obj,'codsubj'));
                v_codinst   := upper(hcm_util.get_string(detail_obj,'codinst'));
                p_codinst_sub := v_codinst;
                v_qtytrmin  := hcm_util.convert_hour_to_minute(hcm_util.get_string(detail_obj,'qtytrmin'));
                if v_codsubj is null or v_codinst is null or v_qtytrmin is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;

                begin
                    select codinst  into v_temp
                    from tinstruc
                    where codinst = v_codinst
                    and rownum = 1;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINSTRUC');
                    return;
                end;

                begin
                    select 'x' into v_temp
                    from tsubject
                    where codcodec = v_codsubj
                    and rownum = 1;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TSUBJECT');
                    return;
                end;

                begin
                    select 'x'  into v_temp
                    from tcoursub
                    where codsubj = v_codsubj
                    and codcours = p_codcours;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSUB');
                    return;
                end;
                --
                if p_codinst_tr = p_codinst_sub then
                    v_count := v_count+1;
               end if;

            end if;
        end loop;

        if v_count = 0 then
                param_msg_error := get_error_msg_php('TR0052',global_v_lang);
               -- return;
        end if;

    end check_subject_detail;

    procedure check_param_editdetail(param_json json) as
        v_temp       varchar2(40 char);
        data_obj    json;

        v_codtparg      tyrtrsch.codtparg%type;
        v_codhotel      tyrtrsch.codhotel%type;
        v_codinst       tyrtrsch.codinst%type;
        v_codinsts      tinstitu.codinsts%type;
        v_dtetrst       tyrtrsch.dtetrst%type;
        v_dtetren       tyrtrsch.dtetren%type;
        v_timestr       tyrtrsch.timestr%type;
        v_timeend       tyrtrsch.timeend%type;
        v_qtyemp        tyrtrsch.qtyemp%type;
        v_codempid      temploy1.codempid%type;
    begin
        data_obj  := hcm_util.get_json(param_json,'training_detail');
        v_codtparg := upper(hcm_util.get_string(data_obj,'codtparg'));
        v_codhotel := upper(hcm_util.get_string(data_obj,'codhotel'));
        v_codinst := upper(hcm_util.get_string(data_obj,'codinst'));
        p_codinst_tr := v_codinst;
        v_codinsts := upper(hcm_util.get_string(data_obj,'codinsts'));
        v_dtetrst := to_date(upper(hcm_util.get_string(data_obj,'dtetrst')),'dd/mm/yyyy');
        v_dtetren := to_date(upper(hcm_util.get_string(data_obj,'dtetren')),'dd/mm/yyyy');
        v_timestr := replace(upper(hcm_util.get_string(data_obj,'timestr')),':','');
        v_timeend := replace(upper(hcm_util.get_string(data_obj,'timeend')),':','');
        v_qtyemp := to_number(hcm_util.get_string(data_obj,'qtyemp'));

        if v_codtparg is null or v_codhotel is null or v_codinst is null or v_dtetrst is null or v_dtetren is null or v_timestr is null or v_timeend is null or v_qtyemp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'x'  into v_temp
            from thotelif
            where codhotel = v_codhotel;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'THOTELIF');
            return;
        end;

        begin
            select stainst,codempid
            into v_temp,v_codempid
            from tinstruc
            where codinst = v_codinst;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINSTRUC');
            return;
        end;

        begin
            select 'X' into v_temp
            from tinstitu
            where codinsts = v_codinsts;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINSTITU');
            return;
        end;

        if v_temp = 'I' then
            begin
                select 'x'  into v_temp
                from temploy1
                where codempid = v_codempid
                and staemp in ('1','3');
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                return;
            end;
        end if;

        data_obj  := hcm_util.get_json(param_json,'subject_detail');
        check_subject_detail(data_obj, v_codinst);
    end check_param_editdetail;

    procedure save_edit_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
        data_obj    json;
        v_item_flgedit varchar2(10 char);
    begin
        initial_value(json_str_input);
        check_index;
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');
        v_item_flgedit := hcm_util.get_string(json_obj,'flag');
        check_param_editdetail(param_json);
        if param_msg_error is null then
            if v_item_flgedit = 'Add' then
                insert_tyrtrsch(param_json, json_str_output);
            elsif v_item_flgedit = 'Edit' then
                update_tyrtrsch(param_json, json_str_output);
            end if;
        end if;
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
    end save_edit_detail;

END HRTR51E;

/
