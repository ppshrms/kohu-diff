--------------------------------------------------------
--  DDL for Package Body HRTR56X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR56X" AS

    procedure initial_value(json_str_input in clob) is
        json_obj            json;
    begin
        json_obj            := json(json_str_input);
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        p_codcompy          := upper(hcm_util.get_string(json_obj,'codcompy'));
        p_year              := to_number(hcm_util.get_string(json_obj,'year'));
        p_codcours          := upper(hcm_util.get_string(json_obj,'codcours'));
        p_numclseq          := to_number(hcm_util.get_string(json_obj,'numgen'));
        p_codinst           := upper(hcm_util.get_string(json_obj,'codinst'));
        p_codapp            := 'HRTR56X';

        p_signature         := upper(hcm_util.get_string(json_obj,'signature'));
        p_refdoc            := hcm_util.get_string(json_obj,'refdoc');
        p_codform           := hcm_util.get_string(json_obj,'p_codform');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcompy is null or p_year is null or p_codcours is null  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X'
              into v_temp
              from tcompny
             where codcompy like p_codcompy
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompany');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
        begin
            select 'X'
              into v_temp
              from tcourse
             where codcours like p_codcours
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcourse');
            return;
        end;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;

        v_email     tinstruc.email%type;
        v_stainst   tinstruc.stainst%type;
        v_codempid  temploy1.codempid%type;
        cursor c1 is
            select a.dteyear,a.codcompy,a.codcours, a.numclseq, a.codinst, b.dtetrst, b.dtetren--,a.dtetrain,a.timstrt
              from ttrsubjd a, tyrtrsch b
             where a.dteyear  = b.dteyear
		       and a.codcompy = b.codcompy
		       and a.codcours = b.codcours
		       and a.numclseq = b.numclseq
               and b.dteyear = p_year
               and b.codcompy = p_codcompy
               and b.codcours = p_codcours
               and b.numclseq = nvl(p_numclseq, b.numclseq)
          group by a.dteyear,a.codcompy,a.codcours,a.numclseq,a.codinst,b.dtetrst,b.dtetren
          order by a.numclseq,a.codinst;

    begin
        obj_rows := json();
        for i in c1 loop
            v_row       := v_row+1;
            obj_data    := json();
            obj_data.put('dteyear',i.dteyear);
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('codcours',i.codcours);
            obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
            obj_data.put('numclseq',i.numclseq);
            obj_data.put('codinst',i.codinst);
            obj_data.put('desc_codlecter',get_tinstruc_name(i.codinst,global_v_lang));
            obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
            obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
            begin
                select stainst, codempid
                  into v_stainst, v_codempid
                  from tinstruc
                 where codinst = i.codinst;
            exception when no_data_found then
                v_stainst := '';
            end;
            if v_stainst = 'I' or v_stainst = '1' then
                begin
                    select email
                      into v_email
                      from temploy1
                     where codempid = v_codempid;
                exception when no_data_found then
                    v_email := '';
                end;
                if v_email is null then
                    begin
                        select email
                          into v_email
                          from tinstruc
                         where codinst = i.codinst;
                    exception when no_data_found then
                        v_email := '';
                    end;
                end if;
            elsif v_stainst = 'E' or v_stainst = '2' then
                begin
                    select email
                      into v_email
                      from tinstruc
                     where codinst = i.codinst;
                exception when no_data_found then
                    v_email := '';
                end;
            end if;
            obj_data.put('email',v_email);
            v_email := '';
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRSCH');
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

    procedure gen_template(json_str_output out clob, json_str_input clob) as
        obj_data            json;
        v_row               number := 0;

        v_email             tinstruc.email%type;
        v_stainst           tinstruc.stainst%type;

        v_codform           TFWMAILH.codform%TYPE;
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr         varchar2(500 char);
    begin

        obj_data            := json(json_str_input);
        v_codform           := upper(hcm_util.get_string(obj_data,'codform'));

        obj_data            := json();
        chk_flowmail.get_message_result(v_codform,global_v_lang,v_msg_to, v_templete_to);

        begin
            select decode(global_v_lang,'101',messagee,
                                 '102',messaget,
                                 '103',message3,
                                 '104',message4,
                                 '105',message5,
                                 '101',messagee) msg
              into v_templete_to
              from tfrmmail
             where codform = 'TEMPLATE' ;
        exception when others then
            v_templete_to := null ;
        end ;

        obj_data := json();
--        obj_data.put('message',replace(v_templete_to,'[P_MESSAGE]', replace(replace(v_msg_to,chr(10),'<br>'),' ','&nbsp;')));
        obj_data.put('message',v_msg_to);
        obj_data.put('coderror', '200');
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_template;

    procedure get_template(json_str_input in clob, json_str_output out clob) as
    begin
        if param_msg_error is null then
            gen_template(json_str_output, json_str_input);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_template;

    procedure clear_ttemprpt is
    begin
        begin
            delete ttemprpt
             where codempid = global_v_codempid
               and codapp = p_codapp;
        exception when others then
            null;
        end;
    end clear_ttemprpt;

    function get_dtetrain_str(check_dte_subjd in out date, v_dtetrain in date) return varchar2 is
        check_dte_subjd2    varchar2(50 char);
        add_month           number := 0;
    begin
        if check_dte_subjd != v_dtetrain or check_dte_subjd is null then
            check_dte_subjd     := v_dtetrain;
            check_dte_subjd2    := hcm_util.get_date_buddhist_era(check_dte_subjd);
        else
            check_dte_subjd2    := null;
        end if;
        return check_dte_subjd2;
    end get_dtetrain_str;

    procedure gen_report_data(v_numclseq_each ttrsubjd.numclseq%type) is
        max_numseq          number;
        p_numseq            number;
        p_qtyemp            tyrtrsch.qtyemp%type;
        rec_tyrtrsch        tyrtrsch%rowtype;
        rec_ttrsched        ttrsched%rowtype;
        rec_ttrsubjd        ttrsubjd%rowtype;
        check_dte_sched     date;
        check_dte_sched2    varchar2(50 char);
        check_dte_subjd     date;
        check_dte_subjd2    varchar2(50 char);
        v_age_year          number;
        v_age_month         number;
        v_age_day           number;
        v_work_year         number;
        v_work_month        number;
        v_work_day          number;
        v_pos_year          number;
        v_pos_month         number;
        v_pos_day           number;

        v_row               number := 0;

        cursor r_tyrtrsch is
            select codinst,codcours,numclseq,dtetrst,dtetren,codhotel,qtyemp
              from tyrtrsch
             where dteyear = p_year
               and codcours = p_codcours
               and codcompy = p_codcompy
               and numclseq = v_numclseq_each;

        cursor r_ttrsched is
            select dtetrain,timstrt,timend,dessched
              from ttrsched
             where dteyear = p_year
               and codcours = p_codcours
               and codcompy = p_codcompy
               and numclseq = v_numclseq_each
          order by dtetrain,timstrt;

        cursor r_ttrsubjd is
            select dtetrain,timstrt,timend,codsubj,codinst
              from ttrsubjd
             where dteyear = p_year
               and codcours = p_codcours
               and codcompy = p_codcompy
               and numclseq = v_numclseq_each
               and codinst = p_codinst
          order by dtetrain,timstrt;

        cursor r_tpotentp is
            select a.codempid,a.codcomp,a.codpos,b.codedlv,b.dteempdb,b.dteempmt,b.dteefpos
              from tpotentp a,temploy1 b
             where a.dteyear = p_year
               and a.codcours = p_codcours
               and a.codcompy = p_codcompy
               and a.numclseq = v_numclseq_each
               and a.codempid = b.codempid
          order by codempid;
    begin
        for i in r_tyrtrsch loop
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
            p_numseq := max_numseq+1;

               -- p_qtyemp            := i.qtyemp;
                begin
                select count(codempid)
                  into p_qtyemp
                  from tpotentp
                 where dteyear = p_year
                   and codcours = p_codcours
                   and codcompy = p_codcompy
                   and numclseq = v_numclseq_each;
                end;

            check_dte_sched     := null;
            check_dte_sched2    := null;
            v_row := 0;
            for i2 in r_ttrsched loop
                v_row := v_row+1;
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
                p_numseq            := max_numseq+1;
                check_dte_sched2    := get_dtetrain_str(check_dte_subjd,i2.dtetrain);
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item10,item11)
                values (global_v_codempid,p_codapp,p_numseq,'table1',check_dte_sched2
                        ,(substr(i2.timstrt,1,2)||':'||substr(i2.timstrt,3))||' - '||(substr(i2.timend,1,2)||':'||substr(i2.timend,3))
                        ,(substr(i2.timend,1,2)||':'||substr(i2.timend,3)),i2.dessched,v_numclseq_each,p_codinst);
            end loop;
            if v_row = 0 then
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
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item10,item11)
                values (global_v_codempid,p_codapp,max_numseq+1,'table1','',
                        '','','',v_numclseq_each,p_codinst);
            end if;
            check_dte_subjd     := null;
            check_dte_subjd2    := null;
            v_row               := 0;
            for i3 in r_ttrsubjd loop
                v_row := v_row+1;
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
                p_numseq            := max_numseq+1;
                check_dte_subjd2    := get_dtetrain_str(check_dte_subjd,i3.dtetrain);
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item10,item11)
                values (global_v_codempid,p_codapp,p_numseq,'table2',check_dte_subjd2
                    ,(substr(i3.timstrt,1,2)||':'||substr(i3.timstrt,3))||' - '||(substr(i3.timend,1,2)||':'||substr(i3.timend,3))
                    ,(substr(i3.timend,1,2)||':'||substr(i3.timend,3))
                    ,i3.codsubj,get_tsubject_name(i3.codsubj,global_v_lang),p_qtyemp,v_numclseq_each,i3.codinst);
            end loop;
            if v_row = 0 then
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item10,item11)
                values (global_v_codempid,p_codapp,max_numseq+1,'table2', ''
                    ,'','','','','',v_numclseq_each,p_codinst);
            end if;
            v_row := 0;
            for i4 in r_tpotentp loop
                v_row := v_row+1;
                begin
                    select max(numseq) into max_numseq
                      from ttemprpt
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;

                p_numseq := max_numseq+1;
                get_service_year(i4.dteempdb,sysdate,'Y',v_age_year,v_age_month,v_age_day);
                get_service_year(i4.dteempmt,sysdate,'Y',v_work_year,v_work_month,v_work_day);
                get_service_year(i4.dteefpos,sysdate,'Y',v_pos_year,v_pos_month,v_pos_day);

                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                    ,item4,item5,item6,item7,item8,item9,item10,item11,item12)
                values (global_v_codempid,p_codapp,p_numseq,'table3',i4.codempid
                    ,get_temploy_name(i4.codempid,global_v_lang)
                    ,get_tcenter_name(i4.codcomp,global_v_lang),get_tpostn_name(i4.codpos,global_v_lang)
                    ,get_tcodec_name('TCODEDUC',i4.codedlv,global_v_lang)
                    ,(v_age_year||'('||v_age_month||')')
                    ,(v_work_year||'('||v_work_month||')')
                    ,(v_pos_year||'('||v_pos_month||')'),v_numclseq_each,v_row,p_codinst);
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
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                    ,item4,item5,item6,item7,item8,item9,item10,item12)
                values (global_v_codempid,p_codapp,max_numseq+1,'table3',''
                    ,'','','','','','','',v_numclseq_each,p_codinst);
            end if;
        end loop;
    end gen_report_data;

    procedure get_report(json_str_input in clob, json_str_output out clob) as
        json_obj            json;
        each_obj            json;
        v_check             varchar2(50 char);
        p_numseq            number;
        max_numseq          number;
        v_numclseq_each     ttrsubjd.numclseq%type;

        v_codinst           tyrtrsch.codinst%type;
        v_codcours          tyrtrsch.codcours%type;
        v_numclseq          tyrtrsch.numclseq%type;
        v_dtetrst           tyrtrsch.dtetrst%type;
        v_dtetren           tyrtrsch.dtetren%type;
        v_codhotel          tyrtrsch.codhotel%type;
        v_qtyemp            tyrtrsch.qtyemp%type;
    begin
        param_msg_error := null;
        initial_value(json_str_input);
        json_obj            := json(json_str_input);
        param_json          := hcm_util.get_json(json_obj,'param_json');
        clear_ttemprpt;

        if param_msg_error is null then
            for i in 0..param_json.count-1 loop
                each_obj        := hcm_util.get_json(param_json,to_char(i));
                p_codinst       := upper(hcm_util.get_string(each_obj,'codinst'));
                v_numclseq_each := upper(hcm_util.get_string(each_obj,'numclseq'));
            -- for putting header for each codinst
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
                p_numseq := max_numseq+1;

                -- put header for each codinst
                begin
                    select codinst,codcours,numclseq,dtetrst,dtetren,codhotel,qtyemp
                      into v_codinst ,v_codcours ,v_numclseq ,v_dtetrst ,v_dtetren,v_codhotel ,v_qtyemp
                      from tyrtrsch
                     where dteyear = p_year
                       and codcours = p_codcours
                       and codcompy = p_codcompy
                       and numclseq = v_numclseq_each;
                end;
                begin
                    select 'x' into v_check
                      from ttemprpt
                     where codempid = global_v_codempid
                       and item4 = v_numclseq_each
                       and codapp = p_codapp
                       and item1 =  'head'
                       and item11 = p_codinst;
                exception when no_data_found then
                    insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                            ,item4,item5,item6,item7,item10,item11)
                    values (global_v_codempid,p_codapp,p_numseq,'head',get_tinstruc_name(p_codinst,global_v_lang)
                            ,p_codcours||' - '||get_tcourse_name(p_codcours,global_v_lang)
                            ,v_numclseq_each,hcm_util.get_date_buddhist_era(v_dtetrst)
                            ,hcm_util.get_date_buddhist_era(v_dtetren),get_thotelif_name(v_codhotel,global_v_lang)
                            ,v_numclseq_each,p_codinst);
                end;
                -- put header for each codinst
                gen_report_data(v_numclseq_each);
            end loop;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_report;

    procedure send_mail_a(data_obj json) as
        v_rowid             varchar(200);
        v_rowid2            varchar(200);
        v_rowid3            varchar(200);

        json_obj            json;
        v_codform           TFWMAILH.codform%TYPE;
        v_codapp            TFWMAILH.codapp%TYPE;

        v_error             varchar2(4000 char);
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr         varchar2(500 char);
        v_subject           varchar2(500 char);

        v_msg         	    clob;
        v_ttrsubjd_table    clob;

        v_email             varchar(200);
        v_codintview        treqest1.codintview%type;

        v_dteyear           tyrtrsch.dteyear%type;
        v_codcompy          tyrtrsch.codcompy%type;
        v_numclseq          tyrtrsch.numclseq%type;
        v_codcours          tyrtrsch.codcours %type;
        v_codinst           tinstruc.codinst%type;
        v_refdoc            varchar2(1000 char);
        v_stainst           tinstruc.stainst%type;
        v_namepos           tinstruc.namepos%type;
        v_desnoffi          tinstruc.desnoffi%type;
        v_codempid          tinstruc.codempid%type;

        v_filename1   	    varchar2(1000 char);

        v_codpos            temploy1.codpos%type;
        v_codcomp           temploy1.codcomp%type;
        v_tyrtrsch          tyrtrsch%rowtype;
        v_file_attach       varchar2(4000);

        cursor c1 is
            select timstrt,timend,codsubj,dtetrain
              from ttrsubjd a
             where a.dteyear  = v_dteyear
		       and a.codcompy = v_codcompy
		       and a.codcours = v_codcours
		       and a.numclseq = v_numclseq
               and a.codinst = v_codinst;
    begin

        begin
            select decode(global_v_lang,101,descode,102,descodt,103,descod3,104,descod4,105,descod5) subject
              into v_subject
              from tfrmmail
             where codform = p_codform;
        exception when no_data_found then
            v_subject := null;
        end;
        v_codapp        := 'HRTR56X';
        v_codinst       := hcm_util.get_string(data_obj, 'codinst');
        v_dteyear       := to_number(hcm_util.get_string(data_obj, 'dteyear'));
        v_codcompy      := hcm_util.get_string(data_obj, 'codcompy');
        v_codcours      := hcm_util.get_string(data_obj, 'codcours');
        v_numclseq      := to_number(hcm_util.get_string(data_obj, 'numclseq'));
        v_filename1     := hcm_util.get_string(data_obj,'filename');

        if p_refdoc is not null and (p_refdoc not like 'https://%' and p_refdoc not like 'http://%') then
            begin

                select get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRTR56X')||'/'||p_refdoc
                  into v_file_attach
                  from dual;
            exception when no_data_found then
                v_file_attach := null;
            end;
        else 
            v_file_attach := p_refdoc;
        end if;
        chk_flowmail.get_message_result(p_codform,global_v_lang,v_msg_to, v_templete_to);
        begin
            select decode(global_v_lang,'101',messagee,
                                 '102',messaget,
                                 '103',message3,
                                 '104',message4,
                                 '105',message5,
                                 '101',messagee) msg
              into v_templete_to
              from tfrmmail
             where codform = 'TEMPLATE' ;
        exception when others then
            v_templete_to := null ;
        end ;
        begin
            select lower(email),stainst,namepos,desnoffi,codempid,rowid
              into v_email,v_stainst,v_namepos,v_desnoffi,v_codempid,v_rowid
              from tinstruc
             where codinst = v_codinst;
        end;

        if v_stainst = 'I' or v_stainst = '1' then
            begin
                select /*rowid,*/lower(email),get_tpostn_name(codpos,global_v_lang),get_tcenter_name(hcm_util.get_codcomp_level(codcomp,1),global_v_lang)
                  into /*v_rowid,*/v_email,v_namepos,v_desnoffi
                  from temploy1
                 where codempid = v_codempid;
            exception when no_data_found then
                v_email := '';
            end;
            v_msg_to := replace(v_msg_to,'[param_1]',get_temploy_name(v_codempid,global_v_lang));
            v_msg_to := replace(v_msg_to,'[param_2]',v_namepos);
            v_msg_to := replace(v_msg_to,'[param_3]',v_desnoffi);
        elsif v_stainst = 'E' or v_stainst = '2' then
            v_msg_to := replace(v_msg_to,'[param_1]',get_tinstruc_name(v_codinst, global_v_lang));
            v_msg_to := replace(v_msg_to,'[param_2]',v_namepos);
            v_msg_to := replace(v_msg_to,'[param_3]',v_desnoffi);
        end if;

        -- replace employee param
        begin
            select rowid
              into v_rowid3
              from tyrtrsch
             where codcompy = v_codcompy
               and codcours = v_codcours
               and dteyear = v_dteyear
               and numclseq  = v_numclseq;
        exception when no_data_found then
            v_rowid3     := '';
        end;
        begin
            select *
              into v_tyrtrsch
              from tyrtrsch
             where codcompy = v_codcompy
               and codcours = v_codcours
               and dteyear = v_dteyear
               and numclseq  = v_numclseq;
        exception when no_data_found then
            v_tyrtrsch  := null;
        end;

        v_msg_to := replace(v_msg_to,'[param_4]',get_tcenter_name(v_codcompy,global_v_lang));
        v_msg_to := replace(v_msg_to,'[param_5]',get_tcourse_name(v_codcours,global_v_lang));
        v_msg_to := replace(v_msg_to,'[param_6]',v_tyrtrsch.descobjt);
        v_msg_to := replace(v_msg_to,'[param_10]',get_thotelif_name(v_tyrtrsch.codhotel,global_v_lang));

        chk_flowmail.replace_text_frmmail(v_templete_to, 'TINSTRUC', v_rowid, v_subject, v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N',p_file => v_filename1);
--        chk_flowmail.replace_text_frmmail(v_templete_to, 'TTRSUBJD', v_rowid2, v_subject, v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N',p_file => v_filename1);
--        chk_flowmail.replace_text_frmmail(v_templete_to, 'TYRTRSCH', v_rowid3, v_subject, v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N',p_file => v_filename1);

        -- replace employee param email reciever param
        for i in c1 loop
            v_ttrsubjd_table :=  v_ttrsubjd_table||'<p><strong>'||get_tsubject_name(i.codsubj,global_v_lang)||'</strong>'
                                                 ||' '||get_label_name('HRTR56XP3', global_v_lang, 250)||': <strong>'||hcm_util.get_date_buddhist_era(i.dtetrain)||'</strong>'
                                                 ||' '||get_label_name('HRTR56XP3', global_v_lang, 80)||': <strong>'||(substr(i.timstrt,1,2)||':'||substr(i.timstrt,3))||' - '||(substr(i.timend,1,2)||':'||substr(i.timend,3))||'</strong>'
                                                 ||'</p>';
        end loop;
        v_msg_to := replace(v_msg_to,'[TTRSUBJD]',v_ttrsubjd_table);

        -- replace sender
        begin
            select codpos
              into v_codpos
              from temploy1
             where codempid = p_signature;
        exception when no_data_found then
            v_codpos := '';
        end;
        v_msg_to        := replace(v_msg_to,'[param_sign]',get_temploy_name(p_signature,global_v_lang));
        v_msg_to        := replace(v_msg_to,'[param_position]',get_tpostn_name(v_codpos,global_v_lang));

        if v_stainst = 'I' or v_stainst = '1' then
            v_error     := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_file_attach,v_filename1,null, null, null);
        else
            v_error     := chk_flowmail.send_mail_to_emp (null, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_file_attach,v_filename1,null, null, v_email);
        end if;
    end send_mail_a;

  procedure send_email(json_str_input in clob, json_str_output out clob) AS
        json_obj        json;
        data_obj        json;
    begin
        initial_value(json_str_input);
        param_msg_error     := '';
        json_obj            := json(json_str_input);
        param_json          := hcm_util.get_json(json_obj,'param_json');
        for i in 0..param_json.count-1 loop
            data_obj        := hcm_util.get_json(param_json, to_char(i));
            send_mail_a(data_obj);
        end loop;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end send_email;
END HRTR56X;

/
