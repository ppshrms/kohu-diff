--------------------------------------------------------
--  DDL for Package Body HRES41X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES41X" AS

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
        p_codapp           := 'HRES41X';
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
        v_has_codcours BOOLEAN := false;
    begin
        if p_year is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_result          json_object_t;
        obj_rows            json_object_t;
        obj_rows2           json_object_t;
        obj_data            json_object_t;
        obj_head            json_object_t;
        obj_detail          json_object_t;
        v_row               number := 0;
        v_row2              number := 0;
        v_hour              number;
        v_min               number;
        obj_data2           json_object_t;
        v_flgrange_no       VARCHAR2(10);
        v_month_no          VARCHAR2(10);
        v_flgrange_value    VARCHAR2(2);
        type month_array    is VARRAY(12) OF VARCHAR2(10);
        v_month_array       month_array;
        v_month_value       varchar2(10);
        v_codcompy          tyrtrsch.codcompy%type;

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
         and a.codcompy   = v_codcompy
         and a.dtetrst+delta <= a.dtetren
         order by numclseq,dtetrst,codcours;
    begin
        begin
            select hcm_util.get_codcomp_level(codcomp,1)
              into v_codcompy
              from temploy1
             where codempid = global_v_codempid;        
        exception when others then
            v_codcompy := null;
        end;

        obj_rows := json_object_t();
        obj_head := json_object_t();

        obj_rows2 := json_object_t();
        v_row2 := 0;
        for i in c2 loop
            v_row2      := v_row2+1;
            obj_data2   := json_object_t();
            obj_data2.put('codcompy',v_codcompy);
            obj_data2.put('dteyear',p_year);
            obj_data2.put('dtedate',to_char(i.dtedate,'dd/mm/yyyy'));
            obj_data2.put('typtrain',i.typtrain);
            obj_data2.put('codcours',i.codcours);
            obj_data2.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
            obj_data2.put('numgen',i.numclseq);
            v_hour  := floor(i.qtytrmin/60);
            v_min   := mod((i.qtytrmin),60);
            obj_data2.put('amttrn',to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'));
            obj_data2.put('dtetrst',to_char(i.DTETRST,'dd/mm/yyyy'));
            obj_data2.put('dtetren',to_char(i.DTETREN,'dd/mm/yyyy'));
            obj_data2.put('dtesettrain',to_char(i.DTETRST,'dd/mm/yyyy')||' - '||to_char(i.DTETREN,'dd/mm/yyyy'));
            obj_data2.put('dtesetregis',to_char(i.DTEREGST,'dd/mm/yyyy')||' - '||to_char(i.DTEREGEN,'dd/mm/yyyy'));
            obj_rows2.put(to_char(v_row2-1),obj_data2);
        end loop;
        obj_detail := json_object_t();
        obj_detail.put('codempid',global_v_codempid);
        obj_detail.put('desc_codempid',get_temploy_name(global_v_codempid,global_v_lang));
        obj_detail.put('dteyear',p_year);
        obj_detail.put('codcompy',v_codcompy);
        obj_detail.put('codcours','');

        obj_head.put('coderror','200');
        obj_head.put('calendar',obj_rows2);
        obj_head.put('detail',obj_detail);
        json_str_output := obj_head.to_clob;           
        
        if v_row2 = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
            return;
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
        obj_result      json_object_t;
        v_hour          number;
        v_min           number;
        cursor c1 is
        select typtrain,codtparg,descobjt,qtyemp,staemptr,qtytrmin,
                   codhotel,codinsts,dteregst,dteregen,dtetrst,dtetren,
                   codresp,flgcerti,desctrain,dteprest,dtepreen,codexampr,
                   dtepostst, dteposten, codexampo,codcate
                  from tyrtrsch
             where dteyear  = p_year
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq;        
    begin
        obj_result := json_object_t();
        obj_result.put('coderror','200');
        
        for r1 in c1 loop
            obj_result.put('codempid', global_v_codempid);
            obj_result.put('desc_codempid', get_temploy_name(global_v_codempid,global_v_lang));
            obj_result.put('dteyear', p_year);
            obj_result.put('codcompy', p_codcompy || ' - ' || get_tcenter_name(p_codcompy,global_v_lang));
            obj_result.put('codcate', r1.codcate || ' - ' || get_tcodec_name('TCODCATE',r1.codcate, global_v_lang));
            obj_result.put('codcours', p_codcours || ' - ' || get_tcourse_name(p_codcours,global_v_lang));
            obj_result.put('numgen', p_numclseq);
            obj_result.put('typedev', get_tlistval_name('TYPTRAIN',r1.typtrain,global_v_lang));
            obj_result.put('typetrain', get_tlistval_name('TCODTPARG',r1.codtparg,global_v_lang));
            obj_result.put('objtrain', r1.descobjt);
            obj_result.put('qtytrain', r1.qtyemp);
            obj_result.put('fortrain', r1.staemptr);
            v_hour  := floor(r1.qtytrmin/60);
            v_min   := mod((r1.qtytrmin),60);
            obj_result.put('amttrn',to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'));
            obj_result.put('placetrain', r1.codhotel || ' - ' || get_thotelif_name(r1.codhotel,global_v_lang));
            obj_result.put('instrain', r1.codinsts || ' - ' || get_tinstitu_name(r1.codinsts,global_v_lang));
            obj_result.put('dtesetregis', to_char(r1.dteregst,'dd/mm/yyyy') || ' - ' || to_char(r1.dteregen,'dd/mm/yyyy'));
            obj_result.put('dtesettrain', to_char(r1.dtetrst,'dd/mm/yyyy') || ' - ' || to_char(r1.dtetren,'dd/mm/yyyy'));
            obj_result.put('codresp', r1.codresp || ' - ' || get_temploy_name(r1.codresp,global_v_lang));
            obj_result.put('qualtrain', r1.desctrain);
            obj_result.put('givecer', r1.flgcerti);
            obj_result.put('dtepretest', to_char(r1.dteprest,'dd/mm/yyyy'));
            obj_result.put('dtepreteen', to_char(r1.dtepreen,'dd/mm/yyyy'));
            obj_result.put('exampre', r1.codexampr || ' - ' || get_tcodec_name('TCODEXAM',r1.codexampr,global_v_lang));
            obj_result.put('dtepostest', to_char(r1.dtepostst,'dd/mm/yyyy'));
            obj_result.put('dteposteen', to_char(r1.dteposten,'dd/mm/yyyy'));
            obj_result.put('exampos', r1.codexampo || ' - ' || get_tcodec_name('TCODEXAM',r1.codexampo,global_v_lang));    
        end loop;  
		json_str_output := obj_result.to_clob();
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

    procedure gen_report_data is
        json_obj json;

        v_row                   number := 0;
        v_row2                  number := 0;
        v_hour                  number;
        v_min                   number;
        v_year                  varchar2(10 char);

        v_numseq                number;
        check_dte_sched         date;
        check_dte_sched2        varchar2(50 char);

        v_month                 varchar2(10 char):= 'NO';
        v_current_course        tyrtrsch.codcours%type;
        v_current_cate          tyrtrsch.codcate%type;
        v_is_old_course         boolean;
        v_is_old_cate           boolean;

        type month_array    is VARRAY(12) OF VARCHAR2(10);
        v_month_array           month_array;
        v_month_value_array     month_array;
        v_image                 varchar2(500 char);
        v_flg_img               varchar2(1 char);
        v_folder                varchar2(500 char);

        cursor c1 is
            select *
              from tyrtrsch
             where codcompy	= p_codcompy
               and dteyear  = p_year
               and codcours = p_codcours
               and numclseq  = p_numclseq
            order by codcate,codcours,numclseq;

    begin
        v_numseq := 1;
        for r1 in c1 loop
            v_hour := floor(r1.qtytrmin/60);
            v_min := mod((r1.qtytrmin),60);
            v_image := get_emp_img (global_v_codempid);
            if v_image = global_v_codempid then
                v_flg_img   := 'N';
                v_image     := '';
            else
                v_flg_img := 'Y';
                select folder 
                  into v_folder
                  from tfolderd 
                 where codapp = 'HRPMC2E1';
                 v_image := get_tsetup_value('PATHDOC')||v_folder ||'/'||v_image;
            end if;
            
            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,
                                  item4,item5,item6,item7,
                                  item8,item9,
                                  item10,item11,item12,
                                  item13,item14,item15,
                                  item16,item17,
                                  item18,
                                  item19,item20,
                                  item21,item22,item23,item24,item25,
                                  item26, item27,item28)
            values (global_v_codempid,p_codapp,v_numseq,'','','',
                    get_temploy_name(global_v_codempid,global_v_lang),global_v_codempid,hcm_util.get_year_buddhist_era(p_year),r1.codcate || ' - ' || get_tcodec_name('TCODCATE',r1.codcate, global_v_lang),
                    r1.codcours || ' - ' || get_tcourse_name(r1.codcours,global_v_lang),r1.numclseq,
                    get_tlistval_name('TYPTRAIN',r1.typtrain,global_v_lang), get_tlistval_name('TCODTPARG',r1.codtparg,global_v_lang),r1.descobjt,
                    r1.qtyemp|| ' ' || get_label_name('HRES41X1', global_v_lang, 120) ,get_tlistval_name('STAEMPTR',r1.staemptr,global_v_lang),to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00') ||' ' || get_label_name('HRES41X1', global_v_lang, 130),
                    r1.codhotel || ' - ' || get_thotelif_name(r1.codhotel,global_v_lang), r1.codinsts || ' - ' || get_tinstitu_name(r1.codinsts,global_v_lang),
                    hcm_util.get_date_buddhist_era(r1.dteregst) || ' - ' || hcm_util.get_date_buddhist_era(r1.dteregen),
                    hcm_util.get_date_buddhist_era(r1.dtetrst) || ' - ' || hcm_util.get_date_buddhist_era(r1.dtetren),
                    r1.codresp || ' - ' || get_temploy_name(r1.codresp,global_v_lang),
                    r1.desctrain, 
                    hcm_util.get_date_buddhist_era(r1.dteprest) || ' - ' || hcm_util.get_date_buddhist_era(r1.dtepreen),
                    r1.codexampr || ' - ' || get_tcodec_name('TCODEXAM',r1.codexampr,global_v_lang),
                    hcm_util.get_date_buddhist_era(r1.dtepostst) || ' - ' || hcm_util.get_date_buddhist_era(r1.dteposten),
                    r1.codexampo || ' - ' || get_tcodec_name('TCODEXAM',r1.codexampo,global_v_lang),
                    v_image,v_flg_img,decode(r1.flgcerti,'Y',get_label_name('HRES41X1', global_v_lang, 290),get_label_name('HRES41X1', global_v_lang, 300)));
--            values (global_v_codempid,p_codapp,v_numseq,'','','',get_temploy_name(global_v_codempid,global_v_lang),global_v_codempid,i.numclseq,to_char(v_hour,'FM00')||':'||to_char(v_min,'FM00'),hcm_util.get_date_buddhist_era(i.DTETRST),hcm_util.get_date_buddhist_era(i.DTETREN),hcm_util.get_date_buddhist_era(i.dteregst),hcm_util.get_date_buddhist_era(i.dteregen),v_month_array(1),v_month_array(2),v_month_array(3),v_month_array(4),v_month_array(5),v_month_array(6),v_month_array(7),v_month_array(8),v_month_array(9),v_month_array(10),v_month_array(11),v_month_array(12),i.remark,
--            v_month_value_array(1),v_month_value_array(2),v_month_value_array(3),v_month_value_array(4),v_month_value_array(5),v_month_value_array(6),v_month_value_array(7),v_month_value_array(8),v_month_value_array(9),v_month_value_array(10),v_month_value_array(11),v_month_value_array(12));
            v_numseq := v_numseq+1;
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

END HRES41X;

/
