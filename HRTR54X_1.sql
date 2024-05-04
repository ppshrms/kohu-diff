--------------------------------------------------------
--  DDL for Package Body HRTR54X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR54X" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcompy         := upper(hcm_util.get_string(json_obj,'codcompy'));
        p_codcate          := upper(hcm_util.get_string(json_obj,'codcate'));
        p_year             := hcm_util.get_string(json_obj,'year');
        p_codcours         := upper(hcm_util.get_string(json_obj,'codcours'));
        p_numclseq         := hcm_util.get_string(json_obj,'numgen');
        p_month            := hcm_util.get_string(json_obj,'month');
        p_date             := hcm_util.get_string(json_obj,'date');
        p_mode             := upper(hcm_util.get_string(json_obj,'mode'));
        p_codapp           := 'HRTR54X';
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
        v_has_codcours BOOLEAN := false;
    begin
        if p_year is null or p_codcompy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from TCOMPNY
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

        if not p_codcours like '' or not p_codcours is null then
            begin
                select 'X' into v_temp
                from TCOURSE
                where codcours like p_codcours
                and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
                return;
            end;
            v_has_codcours := true;
        end if;

        if v_has_codcours = false and not p_codcate like '' or not p_codcate is null then
            begin
                select 'X' into v_temp
                from TCODCATE
                where CODCODEC like p_codcate
                and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATE');
                return;
            end;
        end if;
    end check_index;

    function get_month_value(v_current_month number,v_dtest date,v_dteen date) return varchar2 is
        v_month_value   varchar2(10);
        v_date_st       varchar2(10);
        v_date_en       varchar2(10);
        v_month_st      varchar2(10);
        v_month_en      varchar2(10);
    begin
        v_date_st   := lpad(extract(day from v_dtest),2,'0');
        v_date_en   := lpad(extract(day from v_dteen),2,'0');
        v_month_st  := lpad(extract(month from v_dtest),2,'0');
        v_month_en  := lpad(extract(month from v_dteen),2,'0');
        if to_number(v_month_st) < to_number(v_month_en) and v_current_month < to_number(v_month_en) then
            v_date_en := lpad(extract(day from last_day(v_dtest)),2,'0');
        end if;
        if v_current_month > to_number(v_month_st) then
            v_date_st := '01';
        end if;
        if trunc(v_dtest) = trunc(v_dteen) then
            v_month_value := v_date_st;
        else
            if v_date_st = v_date_en then
                v_month_value := v_date_st;
            else
            	v_month_value := v_date_st||'-'||v_date_en;
        	end if;
        end if;
        return v_month_value;
    end get_month_value;

    procedure gen_index(json_str_output out clob) as
        obj_result    json;
        obj_rows    json;
        obj_rows2    json;
        obj_data    json;
        obj_head    json;
        v_row         number := 0;
        v_row2         number := 0;
        v_hour      number;
        v_min       number;
        obj_data2    json;
        v_flgrange_no   VARCHAR2(10);
        v_month_no   VARCHAR2(10);
        v_flgrange_value VARCHAR2(2);
        type month_array is VARRAY(12) OF VARCHAR2(10);
        v_month_array     month_array;
        v_month_value   varchar2(10);

    cursor c1 is
        select codcate,codcours,numclseq,qtytrmin,dtetrst,dtetren,dteregst,dteregen,remark
		  from tyrtrsch a
		 where codcompy	= p_codcompy
		   and dteyear  = p_year
		   and codcate  = nvl(p_codcate,a.codcate)
           and codcours = nvl(p_codcours,a.codcours)
		order by codcate,codcours,numclseq;

    cursor c2 is
         select distinct a.codcours,a.qtytrmin,a.numclseq,a.dtetrst,a.dtetren,a.typtrain,a.DTEREGST,a.DTEREGEN,a.dtetrst+delta dtedate
         from tyrtrsch a,
              (
                 select level-1 as delta
                 from dual
                 connect by level-1 <= (
                   select max(dtetren - dtetrst) from tyrtrsch
                 )
              )
         where a.dteyear = p_year
         and a.codcompy   = p_codcompy
         and a.codcate    = nvl(p_codcate, a.codcate)
         and a.codcours    = nvl(p_codcours ,a.codcours)
         and a.dtetrst+delta <= a.dtetren
         order by dtedate,codcours,numclseq;
    begin

        obj_rows := json();
        obj_head := json();
        v_month_array := month_array('01', '02', '03', '04', '05','06', '07', '08', '09', '10','11','12');
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('codcate',i.codcate);
            obj_data.put('category',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
            obj_data.put('codcours',i.codcours);
            obj_data.put('course',get_tcourse_name(i.codcours,global_v_lang));
            obj_data.put('numclseq',i.numclseq);
            v_hour := floor(i.qtytrmin/60);
            v_min := mod((i.qtytrmin),60);
            obj_data.put('qtytrmin',to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'));
            obj_data.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
            obj_data.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
            obj_data.put('dteregst',to_char(i.dteregst,'dd/mm/yyyy'));
            obj_data.put('dteregen',to_char(i.dteregen,'dd/mm/yyyy'));
            FOR j in 1 .. v_month_array.count LOOP
                if to_number(v_month_array(j)) >= to_number(to_char(i.DTETRST,'mm')) and to_number(v_month_array(j)) <= to_number(to_char(i.DTETREN,'mm')) then
                    v_flgrange_value := 'Y';
                    v_month_value := get_month_value(to_number(v_month_array(j)),i.DTETRST,i.DTETREN);
                else
                    v_flgrange_value := 'N';
                    v_month_value := '';
                end if;
                v_flgrange_no := 'flgrange'||to_char(j);
                v_month_no := 'month'||to_char(j);
                obj_data.put(v_month_no,v_month_value);
                obj_data.put(v_flgrange_no,v_flgrange_value);
            END LOOP;
            obj_data.put('remarks',i.remark);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_rows2 := json();
        v_row2 := 0;
        for i in c2 loop
                v_row2 := v_row2+1;
                obj_data2 := json();
                obj_data2.put('codcompy',p_codcompy);
                obj_data2.put('dteyear',p_year);
                obj_data2.put('dtedate',to_char(i.dtedate,'dd/mm/yyyy'));
                obj_data2.put('typtrain',i.typtrain);
                obj_data2.put('codcours',i.codcours);
                obj_data2.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
                obj_data2.put('numgen',i.numclseq);
                v_hour := floor(i.qtytrmin/60);
                v_min := mod((i.qtytrmin),60);
                obj_data2.put('amttrn',to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'));
                obj_data2.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
                obj_data2.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_data2.put('dtesettrain',to_char(i.DTETRST,'dd/mm/yyyy')||' - '||to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_data2.put('dtesetregis',to_char(i.DTEREGST,'dd/mm/yyyy')||' - '||to_char(i.DTEREGEN,'dd/mm/yyyy'));
                obj_rows2.put(to_char(v_row2-1),obj_data2);
        end loop;
        if v_row2 = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
            return;
        else
            obj_head.put('calendar',obj_rows2);
        end if;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
            return;
        else
            obj_result := json();
            obj_head.put('rows',obj_rows);
            obj_result.put('0',obj_head);
            dbms_lob.createtemporary(json_str_output, true);
            obj_result.to_clob(json_str_output);
        end if;
    end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
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
    v_temp varchar2(1 char);
    begin
        if p_year is null or p_codcours is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
            from TTRSUBJD
            where codcompy like p_codcompy
            and dteyear = p_year
            and codcours = p_codcours
            and numclseq = p_numclseq
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('TR0046',global_v_lang);
            return;
        end;
    end check_detail;

    procedure gen_detail(json_str_output out clob) as
        obj_result    json;
    begin
        obj_result := json();
		obj_result.put('0',std_tyrtrsch(p_codcompy, p_year, p_numclseq, p_codcours,global_v_lang));
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

    procedure gen_detail_month(json_str_output out clob) as
        obj_result    json;
        obj_rows    json;
        obj_head    json;

        v_row         number := 0;
        v_hour        number;
        v_min         number;
        obj_data    json;

        cursor c1 is
         select codcours,qtytrmin,numclseq,dtetrst,dtetren
         from tyrtrsch
         where dteyear = p_year
         and codcompy   = p_codcompy
         and codcate    = nvl(p_codcate, codcate)
         and codcours    = nvl(p_codcours ,codcours)
         and p_month between to_number(to_char(dtetrst,'mm')) and to_number(to_char(dtetren,'mm'))
         order by numclseq,dtetrst,codcours;
    begin
        obj_head := json();
        obj_result := json();
        obj_rows := json();
        for i in c1 loop
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('codcours',i.codcours);
                obj_data.put('course',get_tcourse_name(i.codcours,global_v_lang));
                obj_data.put('numclseq',i.numclseq);
                v_hour := floor(i.qtytrmin/60);
                v_min := mod((i.qtytrmin),60);
                obj_data.put('qtytrmin',to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'));
                obj_data.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
                obj_data.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_data.put('dte_train',to_char(i.DTETRST,'dd/mm/yyyy')||' - '||to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
            return;
        else
            obj_head.put('rows',obj_rows);
        end if;

-- put data
		obj_result.put('0',obj_head);
		dbms_lob.createtemporary(json_str_output, true);
		obj_result.to_clob(json_str_output);
    end gen_detail_month;

    procedure gen_detail_date(json_str_output out clob) as
        obj_result    json;
        obj_rows    json;
        obj_head    json;

        v_row         number := 0;
        v_hour        number;
        v_min         number;
        obj_data    json;

        cursor c1 is
         select codcours,qtytrmin,numclseq,dtetrst,dtetren
         from tyrtrsch
         where dteyear = p_year
         and codcompy   = p_codcompy
         and codcate    = nvl(p_codcate, codcate)
         and codcours    = nvl(p_codcours ,codcours)
         and trunc(to_date(p_date, 'dd/mm/yyyy')) between trunc(dtetrst)   and trunc(dtetren)
         order by numclseq,dtetrst,codcours;
    begin
        obj_head := json();
        obj_result := json();
        obj_rows := json();
        for i in c1 loop
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('codcours',i.codcours);
                obj_data.put('course',get_tcourse_name(i.codcours,global_v_lang));
                obj_data.put('numclseq',i.numclseq);
                v_hour := floor(i.qtytrmin/60);
                v_min := mod((i.qtytrmin),60);
                obj_data.put('qtytrmin',to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'));
                obj_data.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
                obj_data.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_data.put('dte_train',to_char(i.DTETRST,'dd/mm/yyyy')||' - '||to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
            return;
        else
            obj_head.put('rows',obj_rows);
        end if;

-- put data
		obj_result.put('0',obj_head);
		dbms_lob.createtemporary(json_str_output, true);
		obj_result.to_clob(json_str_output);
    end gen_detail_date;

    procedure gen_detail_daterange(json_str_output out clob) as
        obj_result    json;
        obj_rows    json;
        obj_head    json;

        v_row         number := 0;
        v_hour        number;
        v_min         number;
        obj_data    json;

        cursor c1 is
         select codcours,qtytrmin,numclseq,dtetrst,dtetren
         from tyrtrsch
         where dteyear = p_year
         and codcompy   = p_codcompy
         and codcate    = nvl(p_codcate, codcate)
         and codcours    = nvl(p_codcours ,codcours)
         and to_date(p_date) between dtetrst   and dtetren
         order by numclseq,dtetrst,codcours;
    begin
        obj_head := json();
        obj_result := json();
        obj_rows := json();
        for i in c1 loop
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('codcours',i.codcours);
                obj_data.put('course',get_tcourse_name(i.codcours,global_v_lang));
                obj_data.put('numclseq',i.numclseq);
                v_hour := floor(i.qtytrmin/60);
                v_min := mod((i.qtytrmin),60);
                obj_data.put('qtytrmin',to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'));
                obj_data.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
                obj_data.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_data.put('dte_train',to_char(i.DTETRST,'dd/mm/yyyy')||' - '||to_char(i.DTETREN,'dd/mm/yyyy'));
                obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
            return;
        else
            obj_head.put('rows',obj_rows);
        end if;

-- put data
		obj_result.put('0',obj_head);
		dbms_lob.createtemporary(json_str_output, true);
		obj_result.to_clob(json_str_output);
    end gen_detail_daterange;

    procedure get_detail_calender(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            if p_mode = 'DATE' then
                gen_detail_date(json_str_output);
            else
                gen_detail_month(json_str_output);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail_calender;

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

    procedure gen_report_data is
        json_obj json;

        add_month number:=0;
        v_row       number := 0;
        v_row2       number := 0;
        v_hour      number;
        v_min       number;
        v_year        varchar2(10 char);

        v_numseq       number;
        check_dte_sched date;
        check_dte_sched2 varchar2(50 char);

        v_month          varchar2(10 char):= 'NO';
        v_current_course   tyrtrsch.codcours%type;
        v_current_cate   tyrtrsch.codcate%type;
        v_is_old_course  boolean;
        v_is_old_cate  boolean;

        type month_array is VARRAY(12) OF VARCHAR2(10);
        v_month_array     month_array;
        v_month_value_array     month_array;
--        v_month_value      varchar2(10);

        cursor c1 is
            select codcate,codcours,numclseq,qtytrmin,dtetrst,dtetren,dteregst,dteregen,remark
              from tyrtrsch
             where codcompy	= p_codcompy
               and dteyear  = p_year
               and codcate  = nvl(p_codcate,codcate)
               and codcours = nvl(p_codcours,codcours)
            order by codcate,codcours,numclseq;

    begin
        v_numseq := 0;
        if global_v_lang ='102' then
            add_month := 543*12;
            v_year := to_char(p_year+543);
        else
            v_year := to_char(p_year);
        end if;
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5)
        values (global_v_codempid,p_codapp,v_numseq,'header',v_year,p_codcate||' - '||get_tcodec_name('TCODCATE',p_codcate,global_v_lang),p_codcompy||' - '||GET_TCOMPNY_NAME(p_codcompy,global_v_lang),p_codcours||' - '||get_tcourse_name(p_codcours,global_v_lang));
        v_numseq := v_numseq+1;
        v_row := 0;
        for i in c1 loop
            v_row := v_row+1;
            v_is_old_course := false;
            v_is_old_cate := false;
            if v_current_course = i.codcours then
                v_is_old_course := true;
            else
                v_current_course := i.codcours;
            end if;
            if v_current_cate = i.codcate then
                v_is_old_cate := true;
            else
                v_current_cate := i.codcate;
            end if;

            v_month_array := month_array('01', '02', '03', '04', '05','06', '07', '08', '09', '10','11','12');
            v_month_value_array := month_array('', '', '', '', '','', '', '', '', '','','');
            FOR j in 1 .. v_month_array.count LOOP
                if to_number(v_month_array(j)) >= to_number(to_char(i.dtetrst,'mm')) and to_number(v_month_array(j)) <= to_number(to_char(i.dtetren,'mm')) then
                    v_month_value_array(j) := get_month_value(to_number(v_month_array(j)),i.dtetrst,i.dtetren);
                    v_month_array(j) := 'Y';
                else
                    v_month_array(j) := 'N';
                end if;
            END LOOP;

            v_hour := floor(i.qtytrmin/60);
            v_min := mod((i.qtytrmin),60);
            if v_is_old_course then
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18,item19,item20,item21,item22,item23,item24,
                item25,item26,item27,item28,item29,item30,item31,item32,item33,item34,item35,item36)
                values (global_v_codempid,p_codapp,v_numseq,'table','','','','',i.numclseq,to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'),to_char(add_months(i.DTETRST,add_month),'dd/mm/yyyy'),to_char(add_months(i.DTETREN,add_month),'dd/mm/yyyy'),to_char(add_months(i.dteregst,add_month),'dd/mm/yyyy'),to_char(add_months(i.dteregen,add_month),'dd/mm/yyyy'),v_month_array(1),v_month_array(2),v_month_array(3),v_month_array(4),v_month_array(5),v_month_array(6),v_month_array(7),v_month_array(8),v_month_array(9),v_month_array(10),v_month_array(11),v_month_array(12),i.remark,
                v_month_value_array(1),v_month_value_array(2),v_month_value_array(3),v_month_value_array(4),v_month_value_array(5),v_month_value_array(6),v_month_value_array(7),v_month_value_array(8),v_month_value_array(9),v_month_value_array(10),v_month_value_array(11),v_month_value_array(12));
                v_numseq := v_numseq+1;
            elsif v_is_old_cate then
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18,item19,item20,item21,item22,item23,item24,
                item25,item26,item27,item28,item29,item30,item31,item32,item33,item34,item35,item36)
                values (global_v_codempid,p_codapp,v_numseq,'table','','',i.codcours,get_tcourse_name(i.codcours,global_v_lang),i.numclseq,to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'),to_char(add_months(i.DTETRST,add_month),'dd/mm/yyyy'),to_char(add_months(i.DTETREN,add_month),'dd/mm/yyyy'),to_char(add_months(i.dteregst,add_month),'dd/mm/yyyy'),to_char(add_months(i.dteregen,add_month),'dd/mm/yyyy'),v_month_array(1),v_month_array(2),v_month_array(3),v_month_array(4),v_month_array(5),v_month_array(6),v_month_array(7),v_month_array(8),v_month_array(9),v_month_array(10),v_month_array(11),v_month_array(12),i.remark,
                v_month_value_array(1),v_month_value_array(2),v_month_value_array(3),v_month_value_array(4),v_month_value_array(5),v_month_value_array(6),v_month_value_array(7),v_month_value_array(8),v_month_value_array(9),v_month_value_array(10),v_month_value_array(11),v_month_value_array(12));
                v_numseq := v_numseq+1;
            else
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18,item19,item20,item21,item22,item23,item24,
                item25,item26,item27,item28,item29,item30,item31,item32,item33,item34,item35,item36)
                values (global_v_codempid,p_codapp,v_numseq,'table',i.codcate,get_tcodec_name('TCODCATE',i.codcate,global_v_lang),i.codcours,get_tcourse_name(i.codcours,global_v_lang),i.numclseq,to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'),to_char(add_months(i.DTETRST,add_month),'dd/mm/yyyy'),to_char(add_months(i.DTETREN,add_month),'dd/mm/yyyy'),to_char(add_months(i.dteregst,add_month),'dd/mm/yyyy'),to_char(add_months(i.dteregen,add_month),'dd/mm/yyyy'),v_month_array(1),v_month_array(2),v_month_array(3),v_month_array(4),v_month_array(5),v_month_array(6),v_month_array(7),v_month_array(8),v_month_array(9),v_month_array(10),v_month_array(11),v_month_array(12),i.remark,
                v_month_value_array(1),v_month_value_array(2),v_month_value_array(3),v_month_value_array(4),v_month_value_array(5),v_month_value_array(6),v_month_value_array(7),v_month_value_array(8),v_month_value_array(9),v_month_value_array(10),v_month_value_array(11),v_month_value_array(12));
                v_numseq := v_numseq+1;
            end if;
         end loop;
    end gen_report_data;

    procedure get_report(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);
        clear_ttemprpt;
        if param_msg_error is null then
            gen_report_data;
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

END HRTR54X;

/
