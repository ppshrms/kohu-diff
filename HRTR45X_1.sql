--------------------------------------------------------
--  DDL for Package Body HRTR45X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR45X" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;

    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        p_codcompy         := upper(hcm_util.get_string(json_obj,'codcompy'));
        p_year             := hcm_util.get_string(json_obj,'year');
        p_codcours         := upper(hcm_util.get_string(json_obj,'codcours'));
        p_numclseq         := hcm_util.get_string(json_obj,'numgen');
        p_codapp           := 'HRTR45X';
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcompy is null or p_year is null or p_codcours is null or p_numclseq is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from tcompny
            where codcompy like p_codcompy
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPANY');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from tcourse
            where codcours like p_codcours
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
            return;
        end;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_result    json;
        obj_rows    json;
        obj_date_rows    json;
        obj_data    json;
        obj_head    json;
        obj_date    json;

        v_total_emp number := 0;
        v_total_emp_secur     number := 0;
        v_row       number := 0;
        v_row_secur     number := 0;
        v_row2       number := 0;
        v_email     varchar2(50 char);
        v_dtesubjd_desc varchar2(50 char);

        v_dtetrain                  date;
        v_dtetraen                  date;
        v_desc                    varchar2(100):= null;
        v_count                   number;

      cursor c1 is
         select a.dteyear,a.codcompy,a.numclseq,a.codcours,a.codempid,c.codcomp,c.codpos,a.dtetrst,a.dtetren,
                 b.dtetrain,b.timin,b.timin2,b.remark
              from tpotentp a,tpotentpd b,temploy1 c
             where a.dteyear  = b.dteyear    and a.codcompy = b.codcompy
               and a.codcours = b.codcours    and a.numclseq = b.numclseq
               and a.codempid = b.codempid    and a.codempid = c.codempid
               and a.staappr = 'Y'
               and a.dteyear  = p_year
               and a.codcompy  = p_codcompy
               and a.codcours  = p_codcours
               and a.numclseq  = p_numclseq
               and trunc(b.dtetrain)  = trunc(v_dtetrain)
       order by c.codcomp,c.codpos,c.codempid;

        cursor c2 is
          select dtetrain
          from ttrsubjd
          where dteyear    = p_year
          and codcompy   = p_codcompy
          and codcours     = p_codcours
          and numclseq    = p_numclseq
          group by dtetrain
          order by dtetrain;
        begin
        v_dtesubjd_desc := get_dtesubjd_desc(p_year, p_codcompy, p_codcours, p_numclseq);
-- get all date
          obj_date := json();
-- get table data for that date
          obj_rows := json();
          for j in c2 loop
                v_dtetrain  := j.dtetrain;
                v_row := 0;
                v_row_secur := 0;
                obj_date_rows := json();
                obj_head := json();
                for i in c1 loop
                   	v_row := v_row+1;
                	v_total_emp := v_total_emp+1;
                    if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                        v_row_secur := v_row_secur+1;
                        v_total_emp_secur := v_total_emp_secur+1;
                        obj_data := json();
	                    obj_data.put('dteyear',i.dteyear);
	                    obj_data.put('codcompy',i.codcompy);
	                    obj_data.put('numclseq',i.numclseq);
	                    obj_data.put('codcours',i.codcours);
                        obj_data.put('codempid',i.codempid);
                        obj_data.put('employee_name',get_temploy_name(i.codempid,global_v_lang));
                        obj_data.put('codcomp',i.codcomp);
                        obj_data.put('agency',get_tcenter_name(i.codcomp,global_v_lang));
                        obj_data.put('codpos',i.codpos);
                        obj_data.put('position',get_tpostn_name(i.codpos,global_v_lang));
                        obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
                        obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
                        obj_data.put('timin',substr(i.timin, 1, 2) || ':' || substr(i.timin, 3, 2));
                        obj_data.put('timin2', substr(i.timin2, 1, 2) || ':' || substr(i.timin2, 3, 2));
                        obj_data.put('remark',i.remark);
                        obj_data.put('image',get_emp_img(i.codempid));
                        obj_date_rows.put(to_char(v_row_secur-1),obj_data);
                    end if;
                end loop;
                obj_rows.put(to_char(j.dtetrain,'dd/mm/yyyy'),obj_date_rows);
-- end table
                    begin   -- check date
                    select count(*)  into v_count
                    from ttrsubjd a
                    where a.dtetrain  >  j.dtetrain
                      and a.dteyear    = p_year
                      and a.codcompy   = p_codcompy
                      and a.codcours     = p_codcours
                      and a.numclseq    = p_numclseq;
                    exception when no_data_found then
                       v_count   := 0;
                    end;
                    if v_count = 0 then
                        v_dtetraen  := j.dtetrain; -- final date
                    else
                        v_row2 := v_row2+1;
                        obj_date.put(to_char(v_row2-1),to_char(j.dtetrain,'dd/mm/yyyy')); -- put date
                    end if;

          end loop;
          v_row2 := v_row2+1;
          obj_date.put(to_char(v_row2-1),to_char(v_dtetraen,'dd/mm/yyyy')); -- put final date

        if v_total_emp > 0 and v_total_emp_secur = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        elsif v_total_emp = 0 then   -- table row
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPOTENTP');
            return;
        else
-- head data
            obj_result := json();
            obj_head.put('all_date',obj_date);
            obj_head.put('dtesubjd_desc',v_dtesubjd_desc);
            obj_head.put('counts',v_row);
            obj_head.put('codcours',p_codcours);
            obj_head.put('desc_codcours',p_codcours||' - '||get_tcourse_name(p_codcours,global_v_lang));
            obj_head.put('rows',obj_rows);
            obj_result.put('0',obj_head);
            dbms_lob.createtemporary(json_str_output, true);
            obj_result.to_clob(json_str_output);
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

    function get_dtetrain_str(check_dte_subjd in out date, v_dtetrain in date) return varchar2 is
        check_dte_subjd2 varchar2(50 char);
        add_month number := 0;
    begin
        if global_v_lang ='102' then
            add_month := 543*12;
        end if;
        if check_dte_subjd != v_dtetrain or check_dte_subjd is null then
            check_dte_subjd := v_dtetrain;
            check_dte_subjd2 := to_char(add_months(check_dte_subjd,add_month),'dd/mm/yyyy');
        else
            check_dte_subjd2 := null;
        end if;
        return check_dte_subjd2;
    end get_dtetrain_str;

    function get_dtesubjd_desc_45x (p_dteyear number, p_codcompy varchar2, p_codcours varchar2, p_numclseq number,add_month number) return varchar2 is

        v_dtestr                  date;
        v_dteend                date;
        v_desc                    varchar2(100):= null;
        v_count                   number;

        cursor c1 is
            select dtetrain
            from ttrsubjd
            where dteyear    = p_dteyear
            and codcompy   = p_codcompy
            and codcours     = p_codcours
            and numclseq    = p_numclseq
            group by dtetrain
            order by dtetrain;

    begin

        for i in c1 loop
            if  v_dtestr is null then
                v_dtestr  := i.dtetrain;
            end if;

            begin
            select count(*)  into v_count
            from ttrsubjd a
            where a.dtetrain  =  i.dtetrain + 1
              and a.dteyear    = p_dteyear
              and a.codcompy   = p_codcompy
              and a.codcours     = p_codcours
              and a.numclseq    = p_numclseq;
            exception when no_data_found then
               v_count   := 0;
            end;

            if v_count = 0 then
                  v_dteend  := i.dtetrain;
                   if v_dtestr <> v_dteend then
                             v_desc      := v_desc||','||to_char(add_months(v_dtestr,add_month),'dd/mm/yyyy')||' - '||to_char(add_months(v_dteend,add_month),'dd/mm/yyyy');
                             --Exe.  10/10/2019 - 11/10/2019,15/10/2019 - 16/10/2019
                   else --v_dtestrt = v_dteend
                             v_desc      := v_desc||','||to_char(add_months(v_dtestr,add_month),'dd/mm/yyyy');
                             --Exe.  10/10/2019 - 11/10/2019,15/10/2019
                   end if;
                   v_dtestr  := null;
            end if; -- if v_count = 0 then
        end loop;  -- for i in c1 loop

        return(substr(v_desc,2));
    end get_dtesubjd_desc_45x;

    procedure gen_report_data(json_str_output out clob) is
        json_obj json;

        add_month number:=0;
        v_row       number := 0;
        v_row2       number := 0;
        v_email     varchar2(50 char);
        v_dtesubjd_desc varchar2(50 char);

        v_year        varchar2(10 char);
        v_adjust_dte                 date;
        v_dtetrain                  date;
        v_dtetraen                  date;
        v_desc                    varchar2(100):= null;
        v_count                   number;
        v_numseq                    number;

        v_flgedit        varchar2(10 char);
        v_codform     tintvewd.codform%type;

        check_dte_sched date;
        check_dte_sched2 varchar2(50 char);

      cursor c1 is
         select a.codempid,c.codcomp,c.codpos,a.dtetrst,a.dtetren,
                 b.dtetrain,b.timin,b.timin2,b.remark
              from tpotentp a,tpotentpd b,temploy1 c
             where a.dteyear  = b.dteyear    and a.codcompy = b.codcompy
               and a.codcours = b.codcours    and a.numclseq = b.numclseq
               and a.codempid = b.codempid    and a.codempid = c.codempid
               and a.staappr = 'Y'
               and a.dteyear  = p_year
               and a.codcompy	= p_codcompy
               and a.codcours	= p_codcours
               and a.numclseq	= p_numclseq
               and trunc(b.dtetrain)  = trunc(v_dtetrain)
       order by c.codcomp,c.codpos,c.codempid;

        cursor c2 is
          select dtetrain
          from ttrsubjd
          where dteyear    = p_year
          and codcompy   = p_codcompy
          and codcours     = p_codcours
          and numclseq    = p_numclseq
          group by dtetrain
          order by dtetrain;

    begin
        v_numseq := 0;
        if global_v_lang ='102' then
            add_month := 543*12;
            v_year := to_char(p_year+543);
        else
            v_year := to_char(p_year);
        end if;

        v_dtesubjd_desc := get_dtesubjd_desc_45x(p_year, p_codcompy, p_codcours, p_numclseq,add_month);
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                            ,item4,item5,item6,item7,item8)
        values (global_v_codempid,p_codapp,v_numseq,'header',v_year,p_numclseq
                ,p_codcompy||' - '||GET_TCOMPNY_NAME(p_codcompy,global_v_lang),v_dtesubjd_desc,p_codcours||' - '||get_tcourse_name(p_codcours,global_v_lang),to_char(sysdate,'dd/mm/yyyy'),to_char(sysdate,'hh:mi:ss'));
        v_numseq := v_numseq+1;
        v_row := 0;
        for j in c2 loop
            v_row := v_row+1;
            v_dtetrain  := j.dtetrain;
            v_adjust_dte := add_months(v_dtetrain,add_month);
            insert into ttemprpt (codempid,codapp,numseq,item1,item2)
            values (global_v_codempid,p_codapp,v_numseq,'dtetrain',to_char(v_adjust_dte,'dd/mm/yyyy'));
            v_numseq := v_numseq+1;
            v_row2 := 0;
            for i in c1 loop
                if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
	                v_row2 := v_row2+1;
	                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9)
	                values (global_v_codempid,p_codapp,v_numseq,to_char(v_adjust_dte,'dd/mm/yyyy'),v_row2,i.codempid,get_temploy_name(i.codempid,global_v_lang),get_tcenter_name(i.codcomp,global_v_lang)  ,get_tpostn_name(i.codpos,global_v_lang),substr(i.timin, 1, 2) || ':' || substr(i.timin, 3, 2),substr(i.timin2, 1, 2) || ':' || substr(i.timin2, 3, 2),i.remark);
	                v_numseq := v_numseq+1;
                end if;
            end loop;
         end loop;

    end gen_report_data;

    procedure get_report(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');
        clear_ttemprpt;
        if param_msg_error is null then
            gen_report_data(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_report;

END HRTR45X;

/
