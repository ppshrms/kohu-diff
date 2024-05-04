--------------------------------------------------------
--  DDL for Package Body HRTR55E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR55E" AS

-- update 02/08/2022 redmine8171

  procedure initial_value(json_str_input in clob) is
        json_obj                json_object_t;
    begin
        json_obj                := json_object_t(json_str_input);
        global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
        p_codapp                := 'HRTR55E';

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        p_dteyear               := hcm_util.get_string_t(json_obj,'p_dteyear');
        p_codcompy              := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_codcours              := hcm_util.get_string_t(json_obj,'p_codcours');
        p_codcate               := hcm_util.get_string_t(json_obj,'p_codcate');
        p_codempid              := hcm_util.get_string_t(json_obj,'p_codempid');
        p_codinst               := hcm_util.get_string_t(json_obj,'p_codinst');
        p_numclseq              := hcm_util.get_string_t(json_obj,'p_numclseq');

        p_signature             := upper(hcm_util.get_string_t(json_obj,'p_signature'));
        p_refdoc                := hcm_util.get_string_t(json_obj,'p_refdoc');
        p_attendee_filename     := hcm_util.get_string_t(json_obj,'p_attendee_filename');
  end initial_value;

    function get_dtetrain_str(check_dte_subjd in out date, v_dtetrain in date) return varchar2 is
        check_dte_subjd2    varchar2(50 char);
        add_month           number := 0;
    begin
        add_month   := hcm_appsettings.get_additional_year*12;
        if check_dte_subjd != v_dtetrain or check_dte_subjd is null then
            check_dte_subjd     := v_dtetrain;
            check_dte_subjd2    := to_char(add_months(check_dte_subjd,add_month),'dd/mm/yyyy');
        else
            check_dte_subjd2    := null;
        end if;
        return check_dte_subjd2;
    end get_dtetrain_str;

/*    procedure gen_report_lecturer(p_dteyear number,p_codcours varchar2,p_codcompy varchar2,p_numclseq number,p_codinst varchar2,json_str_output out clob) is
        add_month           number:=0;
        max_numseq          number;
        p_numseq            number;
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

        cursor r_tyrtrsch is
            select codinst,codcours,numclseq,dtetrst,dtetren,codhotel
              from tyrtrsch
             where dteyear = p_dteyear
               and codcours =p_codcours
               and codcompy =p_codcompy
               and numclseq = p_numclseq;

        cursor r_ttrsched is
            select dtetrain,timstrt,timend,dessched
              from ttrsched
             where dteyear = p_dteyear
               and codcours =p_codcours
               and codcompy =p_codcompy
               and numclseq = p_numclseq;

        cursor r_ttrsubjd is
            select dtetrain,timstrt,timend,codsubj,qtytrmin
              from ttrsubjd
             where dteyear = p_dteyear
               and codcours =p_codcours
               and codcompy =p_codcompy
               and numclseq = p_numclseq
               and codinst = p_codinst
          order by dtetrain,timstrt;

        cursor r_tpotentp is
            select a.codempid,a.codcomp,a.codpos,b.codedlv,b.dteempdb,b.dteempmt,b.dteefpos
              from tpotentp a, temploy1 b
             where a.dteyear = p_dteyear
               and a.codcours =p_codcours
               and a.codcompy =p_codcompy
               and a.numclseq = p_numclseq
               and a.codempid = b.codempid
               and a.codpos =  b.codpos
          order by codcomp,codpos,codempid;
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = p_codapp;

        for i in r_tyrtrsch loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt where codempid = global_v_codempid
                   and codapp = p_codapp;
                if max_numseq is null then
                    max_numseq :=0 ;
                end if;
            end;
            p_numseq := max_numseq+1;
            if global_v_lang ='102' then
                add_month := 543*12;
            end if;
            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                    ,item4,item5,item6,item7)
            values (global_v_codempid,p_codapp,p_numseq,'head',get_tinstitu_name(i.codinst,global_v_lang),get_tcourse_name(i.codcours,global_v_lang)
                    ,i.numclseq,to_char(add_months(i.dtetrst,add_month),'dd/mm/yyyy')
                    ,to_char(add_months(i.dtetren,add_month),'dd/mm/yyyy'),get_thotelif_name(i.codhotel,global_v_lang));
        end loop;
        check_dte_sched     := null;
        check_dte_sched2    := null;
        for i2 in r_ttrsched loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt
                 where codempid = global_v_codempid
                   and codapp = p_codapp;
                if max_numseq is null then
                    max_numseq :=0;
                end if;
            end;
            p_numseq            := max_numseq+1;
            check_dte_sched2    := get_dtetrain_str(check_dte_subjd,i2.dtetrain);
            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5)
            values (global_v_codempid,p_codapp,p_numseq,'table1',check_dte_sched2
                    ,(substr(i2.timstrt,1,2)||':'||substr(i2.timstrt,3))
                    ,(substr(i2.timend,1,2)||':'||substr(i2.timend,3)),i2.dessched);
        end loop;

        for i4 in r_tpotentp loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt where codempid = global_v_codempid
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
                ,item4,item5,item6,item7,item8,item9)
            values (global_v_codempid,p_codapp,p_numseq,'table3',i4.codempid
                ,get_temploy_name(i4.codempid,global_v_lang)
                ,get_tcenter_name(i4.codcomp,global_v_lang),get_tpostn_name(i4.codpos,global_v_lang)
                ,get_tlistval_name('TCODEDUC',i4.codedlv,global_v_lang)
                ,(v_age_year||'('||v_age_month||')')
                ,(v_work_year||'('||v_work_month||')')
                ,(v_pos_year||'('||v_pos_month||')'));
        end loop;

        -- insert temp teble 2
        check_dte_subjd     := null;
        check_dte_subjd2    := null;
        for i3 in r_ttrsubjd loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt where codempid = global_v_codempid
                   and codapp = p_codapp;
                if max_numseq is null then
                    max_numseq :=0 ;
                end if;
            end;
            p_numseq            := max_numseq+1;
            check_dte_subjd2    := get_dtetrain_str(check_dte_subjd,i3.dtetrain);
            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
            values (global_v_codempid,p_codapp,p_numseq,'table2',check_dte_subjd2
                ,(substr(i3.timstrt,1,2)||':'||substr(i3.timstrt,3)),(substr(i3.timend,1,2)||':'||substr(i3.timend,3))
                ,i3.codsubj,get_tcourse_name(i3.codsubj,global_v_lang),hcm_util.convert_minute_to_hour(i3.qtytrmin));
        end loop;
    end gen_report_lecturer;*/

    procedure gen_report_trainer(p_dteyear number,p_codcours varchar2,p_codcompy varchar2,p_numclseq number,p_codinst varchar2,json_str_output out clob) is
        json_obj            json_object_t;
        max_numseq          number;
        p_numseq            number;
        rec_tyrtrsch        tyrtrsch%rowtype;
        rec_ttrsched        ttrsched%rowtype;
        rec_ttrsubjd        ttrsubjd%rowtype;
        check_dte           date;
        check_dte2          varchar2(50 char);
        check_dte_sub       date;
        check_dte_sub2      varchar2(50 char);
        add_month           number:=0;
        cursor r_tyrtrsch_tr is
            select codinst,codcours,numclseq,dtetrst,dtetren,codhotel
              from tyrtrsch
             where dteyear = p_dteyear
               and codcours =p_codcours
               and codcompy =p_codcompy
               and numclseq = p_numclseq;

        cursor r_ttrsched_tr is
            select dtetrain,timstrt,timend,dessched
              from ttrsched
             where dteyear = p_dteyear
               and codcours =p_codcours
               and codcompy =p_codcompy
               and numclseq = p_numclseq
          order by dtetrain,timstrt;

        cursor r_ttrsubjd_tr is
            select a.dtetrain,a.timstrt,a.timend,a.codsubj,a.qtytrmin,a.codinst, b.stainst
              from ttrsubjd a, tinstruc b
             where a.dteyear = p_dteyear
               and a.codcours =p_codcours
               and a.codcompy =p_codcompy
               and a.numclseq = p_numclseq
               and a.codinst = b.codinst
          order by dtetrain,timstrt;
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = p_codapp;

        for i in r_tyrtrsch_tr loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt
                 where codempid = global_v_codempid
                   and codapp = p_codapp;
                if max_numseq is null then
                    max_numseq :=0 ;
                end if;
            end;
            add_month   := hcm_appsettings.get_additional_year*12;
            p_numseq := max_numseq+1;
            insert into ttemprpt (codempid,codapp,numseq,
                                  item1,item2,item3,item4,item5,item6)
            values (global_v_codempid,p_codapp,p_numseq,'head_tr',i.codcours || ' - '||get_tcourse_name(i.codcours,global_v_lang)
                    ,i.numclseq,to_char(add_months(i.dtetrst,add_month),'dd/mm/yyyy')
                    ,to_char(add_months(i.dtetren,add_month),'dd/mm/yyyy'),get_thotelif_name(i.codhotel,global_v_lang));
        end loop;

        check_dte_sub  := null;
        check_dte_sub2 := null;

        for i3 in r_ttrsubjd_tr loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt
                 where codempid = global_v_codempid
                   and codapp = p_codapp;
                if max_numseq is null then
                    max_numseq :=0 ;
                end if;
            end;
            p_numseq        := max_numseq+1;
            check_dte_sub2  := get_dtetrain_str(check_dte_sub,i3.dtetrain);
            insert into ttemprpt (codempid,codapp,numseq,
                                  item1,item2,item3,item4,item5,item6,item7,item8,item9,item10)
            values (global_v_codempid,p_codapp,p_numseq,'table1_tr',check_dte_sub2
                ,(substr(i3.timstrt,1,2)||':'||substr(i3.timstrt,3))
                ,(substr(i3.timend,1,2)||':'||substr(i3.timend,3)),i3.codsubj
                ,get_tsubject_name(i3.codsubj,global_v_lang),hcm_util.convert_minute_to_hour(i3.qtytrmin),
                i3.codinst,get_tinstruc_name(i3.codinst, global_v_lang),get_tlistval_name('TSTAINST',i3.stainst,global_v_lang));
        end loop;

        check_dte   := null;
        check_dte2  := null;

        for i2 in r_ttrsched_tr loop
            begin
                select max(numseq) into max_numseq
                  from ttemprpt
                 where codempid = global_v_codempid
                   and codapp = p_codapp;
                if max_numseq is null then
                    max_numseq :=0 ;
                end if;
            end;
            p_numseq        := max_numseq+1;
            check_dte2      := get_dtetrain_str(check_dte,i2.dtetrain);
            insert into ttemprpt (codempid,codapp,numseq,
                                  item1,item2,item3,item4,item5)
            values (global_v_codempid,p_codapp,p_numseq,'table2_tr',check_dte2
                ,(substr(i2.timstrt,1,2)||':'||substr(i2.timstrt,3))
                ,(substr(i2.timend,1,2)||':'||substr(i2.timend,3)),i2.dessched);
        end loop;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    end gen_report_trainer;

    procedure gen_mail_lecturer(p_dteyear number,p_codcompy varchar2,p_codcours varchar2,p_codcate varchar2,p_numclseq number,p_codinst varchar2,json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        cod_sign        varchar2(50 char);
        v_check_emp     varchar2(50 char);
        cursor c1 is
            SELECT A.codinst,B.email,get_tinstruc_name(p_codinst,global_v_lang) as lecturer_name
              FROM TTRSUBJD A ,TINSTRUC  B
             WHERE A.CODINST = B.CODINST
               AND A.DTEYEAR = p_dteyear
               AND A.CODCOMPY =  p_codcompy
               AND A.CODCOURS =  p_codcours
               AND A.NUMCLSEQ =  p_numclseq
          GROUP BY A.CODINST,B.EMAIL
          ORDER BY A.CODINST;
    begin
        if(cod_sign is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            json_str_output := get_response_message(400,param_msg_error,global_v_lang);
            return;
        end if;
        begin
            select distinct 'X' into v_check_emp
              from temploy1
             where codempid = cod_sign;
        EXCEPTION when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            json_str_output := get_response_message(400,param_msg_error,global_v_lang);
            return;
        end;
        obj_rows := json_object_t();
        for i in c1 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('codinst',i.codinst);
            obj_data.put('email',i.email);
            obj_data.put('lecturer_name',i.lecturer_name);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_mail_lecturer;

    procedure gen_mail_trainer(p_dteyear number,p_codcompy varchar2,p_codcours varchar2,p_codcate varchar2,p_numclseq number,json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            SELECT A.CODEMPID,A.CODCOMP,A.CODPOS,B.EMAIL
              FROM TPOTENTP A,TEMPLOY1 B
             WHERE  A.CODEMPID = B.CODEMPID
               AND A.DTEYEAR = p_dteyear
               AND A.CODCOMPY = p_codcompy
               AND A.CODCOURS = p_codcours
               AND A.NUMCLSEQ = p_numclseq
               and  a.STACOURS  not in ('E','W')
          ORDER BY A.CODEMPID;
    begin
        obj_rows        := json_object_t();
        for i in c1 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('codempid',i.codempid);
            obj_data.put('email',i.email);
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codpos',i.codpos);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_mail_trainer;

    procedure gen_detail(json_str_output out clob) as
        obj_rows            json_object_t;
        obj_data            json_object_t;
        obj_data1           json_object_t;
        obj_children2       json_object_t;
        obj_children_rows2  json_object_t;
        obj_children3       json_object_t;
        obj_children_rows3  json_object_t;
        v_row               number := 0;
        v_rowt2             number := 0;
        v_rowt3             number := 0;
        obj_result          json_object_t;
        v_check             varchar2(1 char);
        v_dte               ttrsubjd.dtetrain%type;
        v_dte3              ttrsched.dtetrain%type;
        v_remark            tyrtrpln.remark%type;
        cursor c1 is
            select codtparg,codhotel,codinsts,staemptr,dtetrst,dtetren,qtyemp,qtytrmin,typtrain,descobjt,
                   dteregst,dteregen,codresp,desctrain,flgcerti,dteprest,dtepreen,codexampr,dtepostst,dteposten,codexampo,remark
              from tyrtrsch
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq;

        cursor c8 is
            select a.dteyear,a.codcompy,a.codcours, a.numclseq, a.codinst
              from ttrsubjd a, tyrtrsch b
             where a.dteyear  = b.dteyear
		       and a.codcompy = b.codcompy
		       and a.codcours = b.codcours
		       and a.numclseq = b.numclseq
               and b.dteyear = p_dteyear
               and b.codcompy = p_codcompy
               and b.codcours = p_codcours
               and b.numclseq = p_numclseq
          group by a.dteyear,a.codcompy,a.codcours,a.numclseq,a.codinst
          order by a.numclseq,a.codinst;

        cursor c2 is
            select dtetrain
              from ttrsubjd
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq
          Group by dtetrain
          Order by dtetrain;

        cursor c6 is
            select timstrt,timend,codsubj,codinst,qtytrmin
              from ttrsubjd
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq
               and dtetrain = v_dte
          Order by dtetrain,timstrt;

        cursor c3 is
            select dtetrain
              from ttrsched
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq
          Group by dtetrain
          Order by dtetrain;

        cursor c7 is
            select timstrt,timend,dessched
              from ttrsched
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq
               and dtetrain = v_dte3
          Order by dtetrain,timstrt;

        cursor c4_tab4 is
            select a.dteyear,a.codcompy,a.numclseq,a.codcours,a.codempid,b.codcomp,b.codpos,b.email,a.stacours
              from tpotentp a,temploy1 b
             where a.codempid = b.codempid
               and b.staemp <> '9'
               and a.codcompy = p_codcompy
               and a.dteyear = p_dteyear
               and a.codcours = p_codcours
               and numclseq = p_numclseq
          order by codcomp,codpos,codempid;

        cursor c4_tab4_waitlist is
            select a.dteyearn,a.codcompy,a.numclsn,a.codcours,a.codempid,b.codcomp,b.codpos,b.email,a.stacours
              from tpotentp a,temploy1 b
             where a.codempid = b.codempid
               and b.staemp <> '9'
               and a.codcompy = p_codcompy
               and a.dteyearn = p_dteyear
               and a.codcours = p_codcours
               and a.numclsn = p_numclseq
               and a.flgwait = 'Y'
          order by codcomp,codpos,codempid;

        cursor c5_tab4_ttpotent is
            select a.dteyear,a.codcompy,a.codcours,a.codempid,b.codcomp,b.codpos,b.email,a.stacours
              from ttpotent a,temploy1 b
             where a.codempid = b.codempid
               and b.staemp <> '9'
               and a.codcompy = p_codcompy
               and a.dteyear = p_dteyear
               and a.codcours = p_codcours
               and a.flgclass = 'N'
          order by codcomp,codpos,codempid;
    begin
        v_check         := 'N';
        obj_result      := json_object_t();
        obj_rows        := json_object_t();
        v_row           := 0;
        obj_result.put('coderror',200);

        begin
            select remark into v_remark
              from tyrtrpln
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours;
        exception when no_data_found then
            v_remark := '';
        end;

        obj_data1   := json_object_t();
        for i in c1 loop
            v_row       := v_row+1;
            obj_data1.put('codexampo',i.codexampo);
            obj_data1.put('codexampr',i.codexampr);
            obj_data1.put('codhotel',i.codhotel);
            obj_data1.put('codinsts',i.codinsts);
            obj_data1.put('codresp',i.codresp);
            obj_data1.put('codtparg',i.codtparg);
            obj_data1.put('desc_codtparg',get_tlistval_name('CODTPARG',i.codtparg,global_v_lang));
            obj_data1.put('descobjt',i.descobjt);
            if i.desctrain is not null then
                obj_data1.put('desctrain',i.desctrain);
                obj_data1.put('desctrainOld',i.desctrain);
            else
                if nvl(i.staemptr,'1') = '1' then
                    obj_data1.put('desctrain',get_label_name('HRTR55EP2',global_v_lang,340));
                    obj_data1.put('desctrainOld',get_label_name('HRTR55EP2',global_v_lang,340));
                else
                    obj_data1.put('desctrain',v_remark);
                    obj_data1.put('desctrainOld',v_remark);
                end if;
            end if;
            obj_data1.put('dteposten',to_char(i.dteposten, 'dd/mm/yyyy'));
            obj_data1.put('dtepostst',to_char(i.dtepostst, 'dd/mm/yyyy'));
            obj_data1.put('dtepreen',to_char(i.dtepreen, 'dd/mm/yyyy'));
            obj_data1.put('dteprest',to_char(i.dteprest, 'dd/mm/yyyy'));
            obj_data1.put('dteregen',to_char(i.dteregen, 'dd/mm/yyyy'));
            obj_data1.put('dteregst',to_char(i.dteregst, 'dd/mm/yyyy'));
            obj_data1.put('dtetren',to_char(i.dtetren, 'dd/mm/yyyy'));
            obj_data1.put('dtetrst',to_char(i.dtetrst, 'dd/mm/yyyy'));
            obj_data1.put('flgcerti',nvl(i.flgcerti,'Y'));
            obj_data1.put('qtyemp',i.qtyemp);
            obj_data1.put('qtytrmin',hcm_util.convert_minute_to_hour(i.qtytrmin));
            obj_data1.put('remark',i.remark);
            obj_data1.put('staemptr',nvl(i.staemptr,'1'));
            obj_data1.put('typtrain',nvl(i.typtrain,'11'));
        end loop;
        obj_result.put('tab1',obj_data1);

        obj_rows    := json_object_t();
        v_row       := 0;
        for r8 in c8 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('dteyear',r8.dteyear);
            obj_data.put('codcompy',r8.codcompy);
            obj_data.put('codcours',r8.codcours);
            obj_data.put('numclseq',r8.numclseq);
            obj_data.put('codinst',r8.codinst);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_result.put('instructor',obj_rows);

        obj_rows    := json_object_t();
        v_row       := 0;
        for i2 in c2 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('dtetrain',to_char(i2.dtetrain, 'dd/mm/yyyy'));
            v_dte       := i2.dtetrain;

            obj_children_rows2  := json_object_t();
            v_rowt2             := 0;
            for i6 in c6 loop
                v_rowt2         := v_rowt2+1;
                obj_children2   := json_object_t();
                obj_children2.put('timstrt',substr(i6.timstrt,1,2)||':'||substr(i6.timstrt,3));
                obj_children2.put('timend',substr(i6.timend,1,2)||':'||substr(i6.timend,3));
                obj_children2.put('codsubj',i6.codsubj);
                obj_children2.put('codinst',i6.codinst);
                obj_children2.put('qtytrmin',hcm_util.convert_minute_to_hour(i6.qtytrmin));
                obj_children_rows2.put(to_char(v_rowt2-1),obj_children2);
            end loop;
            obj_data.put('children',obj_children_rows2);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_result.put('tab2',obj_rows);

        obj_rows    := json_object_t();
        v_row       := 0;
        for i3 in c3 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('dtetrain',to_char(i3.dtetrain, 'dd/mm/yyyy'));
            v_dte3      := i3.dtetrain;
            obj_children_rows3 := json_object_t();
            v_rowt3     := 0;
            for i7 in c7 loop
                v_rowt3         := v_rowt3+1;
                obj_children3   := json_object_t();
                obj_children3.put('timstrt',substr(i7.timstrt,1,2)||':'||substr(i7.timstrt,3));
                obj_children3.put('timend',i7.timend);
                obj_children3.put('dessched',i7.dessched);
                obj_children_rows3.put(to_char(v_rowt3-1),obj_children3);
            end loop;
            obj_data.put('children',obj_children_rows3);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_result.put('tab3',obj_rows);

        obj_rows    := json_object_t();
        v_row       := 0;
        for i4 in c4_tab4 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('flgAdd', false);
            obj_data.put('flagwait', '');
            obj_data.put('dteyear',i4.dteyear);
            obj_data.put('codcompy',i4.codcompy);
            obj_data.put('numclseq',i4.numclseq);
            obj_data.put('codcours',i4.codcours);
            obj_data.put('codempid',i4.codempid);
            obj_data.put('image',get_emp_img(i4.codempid));
            obj_data.put('empname',get_temploy_name(i4.codempid,global_v_lang));
            obj_data.put('codcomp',i4.codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(i4.codcomp,global_v_lang));
            obj_data.put('codpos',i4.codpos);
            obj_data.put('desc_codpos',get_tpostn_name(i4.codpos,global_v_lang));
            obj_data.put('email',i4.email);
            obj_data.put('stacours',i4.stacours);
            obj_data.put('desc_stacours',get_tlistval_name('STACOURS',i4.stacours,global_v_lang));
            obj_data.put('tpotentp','tpotentp');
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if v_row = 0 then
            for i4 in c4_tab4_waitlist loop
                v_row       := v_row+1;
                obj_data    := json_object_t();
                obj_data.put('flgAdd', true);
                obj_data.put('flagwait', 'Y');
                obj_data.put('dteyear',i4.dteyearn);
                obj_data.put('codcompy',i4.codcompy);
                obj_data.put('numclseq',i4.numclsn);
                obj_data.put('codcours',i4.codcours);
            	obj_data.put('codempid',i4.codempid);
                obj_data.put('image',get_emp_img(i4.codempid));
	            obj_data.put('empname',get_temploy_name(i4.codempid,global_v_lang));
	            obj_data.put('codcomp',i4.codcomp);
	            obj_data.put('desc_codcomp',get_tcenter_name(i4.codcomp,global_v_lang));
	            obj_data.put('codpos',i4.codpos);
	            obj_data.put('desc_codpos',get_tpostn_name(i4.codpos,global_v_lang));
	            obj_data.put('email',i4.email);
	            obj_data.put('stacours',i4.stacours);
	            obj_data.put('desc_stacours',get_tlistval_name('STACOURS',i4.stacours,global_v_lang)||' (Waiting list)');
	            obj_data.put('tpotentp','tpotentp');
	            obj_rows.put(to_char(v_row-1),obj_data);
        	end loop;

            for i5 in c5_tab4_ttpotent loop
                v_row       := v_row+1;
                obj_data    := json_object_t();
                obj_data.put('flagwait', '');
                obj_data.put('flgAdd', true);
                obj_data.put('dteyear',i5.dteyear);
                obj_data.put('codcompy',i5.codcompy);
                obj_data.put('codcours',i5.codcours);
                obj_data.put('image',get_emp_img(i5.codempid));
                obj_data.put('codempid',i5.codempid);
                obj_data.put('empname',get_temploy_name(i5.codempid,global_v_lang));
                obj_data.put('codcomp',i5.codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(i5.codcomp,global_v_lang));
                obj_data.put('codpos',i5.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(i5.codpos,global_v_lang));
                obj_data.put('email',i5.email);
                obj_data.put('stacours',i5.stacours);
                obj_data.put('desc_stacours',get_tlistval_name('STACOURS',i5.stacours,global_v_lang));
                obj_data.put('tpotent','tpotent');
                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        end if;

        obj_result.put('tab4',obj_rows);
        dbms_lob.createtemporary(json_str_output, true);
        obj_result.to_clob(json_str_output);
    end gen_detail;

    procedure gen_waiting(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_dte       varchar2(500 char);
        v_mail      varchar2(1000 char);
        cursor c1 is
            select a.dteyear,a.codcompy,a.codempid,a.numclseq,a.codcours,
                   a.codcomp,a.codpos,a.flgatend,dteappr,codappr,dteyearn,numclsn,stacours
              from tpotentp a
             where a.codcompy  = p_codcompy
               and a.flgwait  = 'Y'
               and a.numclseq = 0
               and a.codcours = p_codcours
               and nvl(a.dteyearn,'0000')||nvl(a.numclsn,'0') <> p_dteyear||p_numclseq
          order by codcomp,codpos,codempid;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            begin
                select email into v_mail
                  from temploy1
                 where codempid = i.codempid;
            exception when no_data_found then
                v_mail := '';
            end;
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('flagwait', 'Y');
            obj_data.put('dteyear',i.dteyear);
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('numclseq',i.numclseq);
            obj_data.put('codcours',i.codcours);
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('email',v_mail);
            obj_data.put('codpos',i.codpos);
            obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('flgatend',get_tlistval_name('FLGATEND',i.flgatend,global_v_lang));
            obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            obj_data.put('codappr',get_temploy_name(i.codappr,global_v_lang));
            v_dte       := hcm_util.get_year_buddhist_era(i.dteyearn)||'/'||i.numclsn;
            obj_data.put('dteyearn',v_dte);
            obj_data.put('stacours',get_tlistval_name('STACOURS',i.stacours,global_v_lang));

            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_waiting;

    procedure gen_index(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_check_ess     number := 0;
        v_ess           varchar2(1 char);
        cursor c1 is
            select codcours,numclseq,dtetrst,dtetren,qtyemp,staemptr
              from tyrtrsch
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = nvl(p_codcours,codcours)
               and codcate = nvl(p_codcate,codcate)
          order by codcours,numclseq;
    begin
        select count(*) into v_check_ess
          from tusrproc
         where coduser = global_v_coduser
           and codproc like '%ES%';
        if v_check_ess != 0 then
            v_ess := 'Y';
        else
            v_ess := 'N';
        end if;

        obj_rows := json_object_t();
        for i in c1 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('codcours',i.codcours);
            obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
            obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
            obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
            obj_data.put('ess_check',v_ess);
            obj_data.put('numclseq',i.numclseq);
            obj_data.put('qtyemp',i.qtyemp);
            obj_data.put('staemptr',get_tlistval_name('STAEMPTR',i.staemptr,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure check_index as
        v_temp      varchar2(1 char);
        v_temp2     varchar2(1 char);
        v_temp3     varchar2(1 char);
    begin
        if p_codcompy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select distinct 'X' into v_temp
              from tcompny
             where codcompy = p_codcompy
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        begin
            select distinct 'X' into v_temp
              from tyrtrsch
             where codcompy = p_codcompy
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TYRTRSCH');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        if p_codcate is null and p_codcours is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codcate is not null then
            begin
                select distinct 'X' into v_temp3
                  from tcodcate
                 where codcodec = p_codcate
                   and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATE');
                return;
            end;
        end if;

        if p_codcours is not null then
            begin
                select distinct 'X' into v_temp2
                  from tcourse
                 where codcours = p_codcours
                   and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
                return;
            end;
        end if;
    end check_index;

    procedure save_data_tab1(param_json_save1 json_object_t) as
        json_obj            json_object_t;
        v_codtparg          tyrtrsch.codtparg%type;
        v_codhotel          tyrtrsch.codhotel%type;
        v_codinsts          tyrtrsch.codinsts%type;
        v_staemptr          tyrtrsch.staemptr%type;
        v_dtetrst           tyrtrsch.dtetrst%type;
        v_dtetren           tyrtrsch.dtetren%type;
        v_qtyemp            tyrtrsch.qtyemp%type;
        v_qtytrmin          tyrtrsch.qtytrmin%type;
        v_typtrain          tyrtrsch.typtrain%type;
        v_descobjt          tyrtrsch.descobjt%type;
        v_dteregst          tyrtrsch.dteregst%type;
        v_dteregen          tyrtrsch.dteregen%type;
        v_codresp           tyrtrsch.codresp%type;
        v_desctrain         tyrtrsch.desctrain%type;
        v_flgcerti          tyrtrsch.flgcerti%type;
        v_dteprest          tyrtrsch.dteprest%type;
        v_dtepreen          tyrtrsch.dtepreen%type;
        v_codexampr         tyrtrsch.codexampr%type;
        v_dtepostst         tyrtrsch.dtepostst%type;
        v_dteposten         tyrtrsch.dteposten%type;
        v_codexampo         tyrtrsch.codexampo%type;
        v_temp_codhotel     varchar2(1 char);
        v_empval            number :=0;
        v_temp_v_codinsts   varchar2(1 char);
        v_temp_v_codempid   varchar2(1 char);
        v_temp_v_codcodec   varchar2(1 char);
        v_temp_v_codcodec2  varchar2(1 char);
    begin
        v_codtparg  := hcm_util.get_string_t(param_json_save1,'codtparg');
        v_codhotel  := hcm_util.get_string_t(param_json_save1,'codhotel');
        v_codinsts  := hcm_util.get_string_t(param_json_save1,'codinsts');
        v_staemptr  := hcm_util.get_string_t(param_json_save1,'staemptr');
        v_dtetrst   := to_date(hcm_util.get_string_t(param_json_save1,'dtetrst'),'dd/mm/yyyy');
        v_dtetren   := to_date(hcm_util.get_string_t(param_json_save1,'dtetren'),'dd/mm/yyyy');
        v_qtyemp    := hcm_util.get_string_t(param_json_save1,'qtyemp');
        v_qtytrmin  := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_save1,'qtytrmin'));
        v_typtrain  := hcm_util.get_string_t(param_json_save1,'typtrain');
        v_descobjt  := hcm_util.get_string_t(param_json_save1,'descobjt');
        v_dteregst  := to_date(hcm_util.get_string_t(param_json_save1,'dteregst'),'dd/mm/yyyy');
        v_dteregen  := to_date(hcm_util.get_string_t(param_json_save1,'dteregen'),'dd/mm/yyyy');
        v_codresp   := hcm_util.get_string_t(param_json_save1,'codresp');
        v_desctrain := hcm_util.get_string_t(param_json_save1,'desctrain');
        v_flgcerti  := hcm_util.get_string_t(param_json_save1,'flgcerti');
        v_dteprest  := to_date(hcm_util.get_string_t(param_json_save1,'dteprest'),'dd/mm/yyyy');
        v_dtepreen  := to_date(hcm_util.get_string_t(param_json_save1,'dtepreen'),'dd/mm/yyyy');
        v_codexampr := hcm_util.get_string_t(param_json_save1,'codexampr');
        v_dtepostst := to_date(hcm_util.get_string_t(param_json_save1,'dtepostst'),'dd/mm/yyyy');
        v_dteposten := to_date(hcm_util.get_string_t(param_json_save1,'dteposten'),'dd/mm/yyyy');
        v_codexampo := hcm_util.get_string_t(param_json_save1,'codexampo');
        if ((v_staemptr is null) or (v_qtytrmin is null) or (v_codhotel is null) or (v_codinsts is null) or (v_dteregst is null) or (v_dteregen is null) or (v_dtetrst is null) or (v_dtetren is null) or (v_desctrain is null) or (v_flgcerti is null)) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if ((v_dtetren < v_dtetrst ) ) then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;
        if ((v_dteregen < v_dteregst ) ) then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;
        if ((v_dteregen >  v_dtetren) or (v_dteregst >  v_dtetren) ) then
            param_msg_error := get_error_msg_php('HR2025',global_v_lang);
            return;
        end if;
        if ( (v_dteprest is not null) and (v_dteprest > v_dtetrst) ) then
            param_msg_error := get_error_msg_php('HR2025',global_v_lang);
            return;
        end if;
        if ( (v_dtepreen is not null) and (v_dtepreen > v_dtetrst) ) then
            param_msg_error := get_error_msg_php('HR2025',global_v_lang);
            return;
        end if;
        if ( (v_dtepostst is not null) and (v_dtepostst < v_dtetrst) ) then
            param_msg_error := get_error_msg_php('HR2025',global_v_lang);
            return;
        end if;
        if ( (v_dteposten is not null) and (v_dteposten < v_dtetrst) ) then
            param_msg_error := get_error_msg_php('HR2025',global_v_lang);
            return;
        end if;
        if ( v_qtyemp > 50 ) then
            param_msg_error := get_error_msg_php('TR0042',global_v_lang);
            return;
        end if;

        begin
            select distinct 'X' into v_temp_codhotel
              from thotelif
             where codhotel = v_codhotel;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'THOTELIF');
            return;
        end;
        begin
            select distinct 'X' into v_temp_v_codinsts
              from tinstitu
             where codinsts = v_codinsts;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINSTITU');
            return;
        end;
        begin
            select distinct 'X' into v_temp_v_codempid
              from temploy1
             where codempid = v_codresp;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;

--        begin
--            select distinct 'X' into v_temp_v_codcodec
--              from tvtest
--             where codexam = v_codexampr;
--        exception when no_data_found then
--            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TVTEST');
--            return;
--        end;
--
--        begin
--            select distinct 'X' into v_temp_v_codcodec2
--              from tvtest
--             where codexam = v_codexampo;
--        exception when no_data_found then
--            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TVTEST');
--            return;
--        end;
        begin
            update tyrtrsch
               set codtparg  =  v_codtparg,
--<<02/08/2022 redmine8171
                    flgconf   = 'Y',
-->>02/08/2022 redmine8171
                   codhotel  =  v_codhotel,
                   codinsts  =  v_codinsts,
                   staemptr  =  v_staemptr,
                   dtetrst   =  v_dtetrst,
                   dtetren   =  v_dtetren,
                   qtyemp    =  v_qtyemp,
                   qtytrmin  =  v_qtytrmin,
                   typtrain  =  v_typtrain,
                   descobjt  =  v_descobjt,
                   dteregst  =  v_dteregst,
                   dteregen  =  v_dteregen,
                   codresp   =  v_codresp,
                   desctrain =  v_desctrain,
                   flgcerti  =  v_flgcerti,
                   dteprest  =  v_dteprest,
                   dtepreen  =  v_dtepreen,
                   codexampr =  v_codexampr,
                   dtepostst =  v_dtepostst,
                   dteposten =  v_dteposten,
                   codexampo =  v_codexampo,
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where dteyear   = p_dteyear
               and codcompy = p_codcompy
               and codcours =  p_codcours
               and numclseq =  p_numclseq;
        end;
    end save_data_tab1;

    procedure save_data_tab2(param_json_save1 json_object_t,param_json_save2 json_object_t) as
        json_obj                json_object_t;
        json_obj_detail         json_object_t;
        json_obj_children2      json_object_t;
        v_check                 varchar2(1 char);
        v_flgeditc_t2           varchar2(20 char);
        v_dtetrain              ttrsubjd.dtetrain%type;
        v_timstrt               varchar2(10 char);
        v_timend                varchar2(10 char);
        v_codsubj               ttrsubjd.codsubj%type;
        v_codinst               ttrsubjd.codinst%type;
        v_qtytrmin              ttrsubjd.qtytrmin%type;
        v_dtetrst               tyrtrsch.dtetrst%type;
        v_dtetren               tyrtrsch.dtetren%type;
        v_temp_v_tcoursub       varchar2(1 char);
        v_temp_v_tcoursub2      varchar2(1 char);
        v_temp                  varchar2(1 char);
        v_temp2                 varchar2(1 char);
        v_temp3                 varchar2(1 char);
    begin
        v_dtetrst       := to_date(hcm_util.get_string_t(param_json_save1,'dtetrst'),'dd/mm/yyyy');
        v_dtetren       := to_date(hcm_util.get_string_t(param_json_save1,'dtetren'),'dd/mm/yyyy');

        for i in 0..param_json_save2.get_size-1 loop
            json_obj        := hcm_util.get_json_t(param_json_save2,to_char(i));
            v_dtetrain      := to_date(hcm_util.get_string_t(json_obj,'dtetrain'),'dd/mm/yyyy');

            if v_dtetrain not between v_dtetrst and v_dtetren then
                param_msg_error := get_error_msg_php('HR2025',global_v_lang);
                return;
            end if;

            json_obj_detail := hcm_util.get_json_t(json_obj,'children');
            for x in 0..json_obj_detail.get_size-1 loop
                json_obj_children2      := hcm_util.get_json_t(json_obj_detail,to_char(x));
                v_flgeditc_t2           := hcm_util.get_string_t(json_obj_children2,'flg');
                v_timstrt               := REPLACE(hcm_util.get_string_t(json_obj_children2,'timstrt'),':','');
                v_timend                := REPLACE(hcm_util.get_string_t(json_obj_children2,'timend'),':','');
                v_codsubj               := hcm_util.get_string_t(json_obj_children2,'codsubj');
                v_codinst               := hcm_util.get_string_t(json_obj_children2,'codinst');
                v_qtytrmin              := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj_children2,'qtytrmin'));

                begin
                    if (v_flgeditc_t2 = 'add') then
                        if ((v_dtetrain is null) or (v_timstrt is null) or (v_timend is null) or (v_codsubj is null) or (v_codinst is null) or (v_qtytrmin is null) ) then
                            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                            return;
                        end if;
                        begin
                            select distinct 'X' into v_temp_v_tcoursub
                              from tcoursub
                             where codsubj = v_codsubj;
                        exception when no_data_found then
                            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcoursub');
                            return;
                        end;
                        begin
                            select distinct 'X' into v_temp_v_tcoursub2
                              from tcoursub
                             where codinst = v_codinst;
                        exception when no_data_found then
                            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcoursub');
                            return;
                        end;
                        begin
                            select distinct 'X' into v_temp
                              from ttrsubjd
                             where (timstrt between v_timstrt and v_timend
                                    or timend between v_timstrt and v_timend)
                               and dtetrain = v_dtetrain
                               and dteyear = p_dteyear
                               and codcompy = p_codcompy
                               and codcours = p_codcours
                               and numclseq = p_numclseq;
                        exception when no_data_found then
                            v_temp :=   null;
                        end;
                        begin
                            select distinct 'X' into v_temp2
                              from ttrsubjd
                             where v_timstrt between timstrt and timend
                               and dtetrain = v_dtetrain
                               and dteyear = p_dteyear
                               and codcompy = p_codcompy
                               and codcours = p_codcours
                               and numclseq = p_numclseq;
                        exception when no_data_found then
                            v_temp2 :=   null;
                        end;
                        if v_temp is not null then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                            return;
                        end if;
                        if v_temp2 is not null then
                            param_msg_error := get_error_msg_php('HR2020',global_v_lang,v_temp2);
                            return;
                        end if;
                        begin
                            insert into ttrsubjd (dteyear,codcompy,codcours,numclseq,dtetrain,timstrt,timend,codsubj,codinst,qtytrmin,dtecreate,codcreate,dteupd,coduser)
                            values (p_dteyear,p_codcompy,p_codcours,p_numclseq,v_dtetrain,v_timstrt,v_timend,v_codsubj,v_codinst,v_qtytrmin,sysdate,global_v_coduser,sysdate,global_v_coduser);
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'ttrsubjd');
                            rollback;
                            exit;
                        end;
                    elsif (v_flgeditc_t2 = 'edit') then
                        begin
                            select distinct 'X' into v_temp3
                              from ttrsubjd
                             where timend between v_timstrt and v_timend
                               and timstrt <> v_timstrt
                               and dtetrain = v_dtetrain
                               and dteyear = p_dteyear
                               and codcompy = p_codcompy
                               and codcours = p_codcours
                               and numclseq = p_numclseq;
                        exception when no_data_found then
                             v_temp3 :=   null;
                        end;
                        if v_temp3 is not null then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                            return;
                        end if;
                        begin
                            select distinct 'X' into v_temp_v_tcoursub
                              from tcoursub
                             where codsubj = v_codsubj;
                        exception when no_data_found then
                            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcoursub');
                            return;
                        end;
                        begin
                            select distinct 'X' into v_temp_v_tcoursub2
                              from tcoursub
                             where codinst = v_codinst;
                        exception when no_data_found then
                            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcoursub');
                            return;
                        end;
                        update ttrsubjd
                           set timend    =  v_timend,
                               codsubj   =  v_codsubj,
                               codinst   =  v_codinst,
                               qtytrmin  =  v_qtytrmin,
                               dteupd    =  sysdate,
                               coduser   =  global_v_coduser
                         where dteyear =   p_dteyear
                           and codcompy = p_codcompy
                           and codcours = p_codcours
                           and numclseq = p_numclseq
                           and trunc(dtetrain) = v_dtetrain
                           and timstrt =  v_timstrt;
                    elsif (v_flgeditc_t2 = 'delete') then
                        delete ttrsubjd
                         where dteyear  = p_dteyear
                           and codcompy = p_codcompy
                           and codcours =  p_codcours
                           and numclseq =  p_numclseq
                           and trunc(dtetrain) = v_dtetrain
                           and timstrt = v_timstrt;
                    end if;
                end;
            end loop;
        end loop;
    end save_data_tab2;

    procedure save_data_tab3(param_json_save1 json_object_t,param_json_save3 json_object_t) as
        json_obj                json_object_t;
        json_obj_detail         json_object_t;
        json_obj_children3      json_object_t;
        v_flgeditc_t3           varchar2(20 char);
        v_dtetrain              ttrsched.dtetrain%type;
        v_timstrt               varchar2(10 char);
        v_timend                varchar2(10 char);
        v_dessched              ttrsched.dessched%type;
        v_dtetrst               tyrtrsch.dtetrst%type;
        v_dtetren               tyrtrsch.dtetren%type;
        v_temp                  varchar2(1 char);
        v_temp2                 varchar2(1 char);
        v_temp3                 varchar2(1 char);
    begin
        v_dtetrst   := to_date(hcm_util.get_string_t(param_json_save1,'dtetrst'),'dd/mm/yyyy');
        v_dtetren   := to_date(hcm_util.get_string_t(param_json_save1,'dtetren'),'dd/mm/yyyy');

        for i in 0..param_json_save3.get_size-1 loop
            json_obj        := hcm_util.get_json_t(param_json_save3,to_char(i));
            v_dtetrain      := to_date(hcm_util.get_string_t(json_obj,'dtetrain'),'dd/mm/yyyy');

            if v_dtetrain not between v_dtetrst and v_dtetren then
                param_msg_error := get_error_msg_php('HR2025',global_v_lang);
                return;
            end if;

            json_obj_detail := hcm_util.get_json_t(json_obj,'children');
            for x in 0..json_obj_detail.get_size-1 loop
                json_obj_children3  := hcm_util.get_json_t(json_obj_detail,to_char(x));
                v_flgeditc_t3       := hcm_util.get_string_t(json_obj_children3,'flg');
                v_timstrt           := REPLACE(hcm_util.get_string_t(json_obj_children3,'timstrt'),':','');
                v_timend            := REPLACE(hcm_util.get_string_t(json_obj_children3,'timend'),':','');
                v_dessched          := hcm_util.get_string_t(json_obj_children3,'dessched');

                begin
                    if (v_flgeditc_t3 = 'add') then
                        if ((v_dtetrain is null) or (v_timstrt is null) or (v_timend is null) or (v_dessched is null)) then
                            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                            return;
                        end if;
                        begin
                            select distinct 'X' into v_temp
                              from ttrsched
                             where (timstrt between v_timstrt and v_timend
                                    or timend between v_timstrt and v_timend )
                               and dtetrain = v_dtetrain
                               and dteyear = p_dteyear
                               and codcompy = p_codcompy
                               and codcours = p_codcours
                               and numclseq = p_numclseq ;
                        exception when no_data_found then
                            v_temp := null;
                        end;

                        begin
                            select distinct 'X' into v_temp2
                              from ttrsched
                             where v_timstrt between timstrt and  timend
                               and dtetrain = v_dtetrain
                               and dteyear = p_dteyear
                               and codcompy = p_codcompy
                               and codcours = p_codcours
                               and numclseq = p_numclseq ;
                        exception when no_data_found then
                            v_temp2 := null;
                        end;
                        if v_temp is not null then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                            return;
                        end if;
                        if v_temp2 is not null then
                            param_msg_error := get_error_msg_php('HR2020',global_v_lang,v_temp2);
                            return;
                        end if;
                        begin
                            insert into ttrsched (dteyear,codcompy,codcours,numclseq,dtetrain,timstrt,timend,dessched,dtecreate,codcreate,dteupd,coduser)
                            values (p_dteyear,p_codcompy,p_codcours,p_numclseq,v_dtetrain,REPLACE(v_timstrt,':',''),REPLACE(v_timend,':',''),v_dessched,sysdate,global_v_coduser,sysdate,global_v_coduser);
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'ttrsched');
                            rollback;
                            exit;
                        end;
                    elsif (v_flgeditc_t3 = 'edit') then
                        begin
                            select distinct 'X' into v_temp3
                              from ttrsched
                             where timend between v_timstrt and v_timend
                               and timstrt <> v_timstrt
                               and trunc(dtetrain) = v_dtetrain
                               and dteyear = p_dteyear
                               and codcompy = p_codcompy
                               and codcours = p_codcours
                               and numclseq = p_numclseq ;
                        exception when no_data_found then
                             v_temp3 := null;
                        end;
                        if v_temp3 is not null then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                            return;
                        end if;
                        update ttrsched
                           set timend = v_timend,
                               dessched = v_dessched,
                               dteupd = sysdate,
                               coduser = global_v_coduser
                         where dteyear = p_dteyear
                           and codcompy = p_codcompy
                           and codcours = p_codcours
                           and numclseq = p_numclseq
                           and trunc(dtetrain) = v_dtetrain
                           and timstrt =  v_timstrt;
                    elsif (v_flgeditc_t3 = 'delete') then
                        delete ttrsched
                         where dteyear = p_dteyear
                           and codcompy = p_codcompy
                           and codcours = p_codcours
                           and numclseq = p_numclseq
                           and trunc(dtetrain) = v_dtetrain
                           and timstrt = v_timstrt;
                    end if;
                end;
            end loop;
        end loop;
    end save_data_tab3;

    procedure save_data_tab4(param_json_save4 json_object_t) as
        json_obj            json_object_t;
        json_obj_detail     json_object_t;
        v_check             varchar2(1 char);
        v_flgeditc_t4       varchar2(20 char);
        v_codempid          tpotentp.codempid%type;
        v_tab4_dteyear      tpotentp.dteyear%type;
        v_tab4_codcompy     tpotentp.codcompy%type;
        v_tab4_numclseq     tpotentp.numclseq%type;
        v_tab4_codcours     tpotentp.codcours%type;
        v_codcomp           tpotentp.codcomp%type;
        v_codpos            tpotentp.codpos%type;
        v_stacours          tpotentp.stacours%type;
        v_codtparg          tpotentp.codtparg%type;
        v_dtetrst           tpotentp.dtetrst%type;
        v_dtetren           tpotentp.dtetren%type;
        v_numlvl            tpotentp.numlvl%type;
        v_empval            number := 0;
        v_qtyemp            number := 0;

        v_costcent          tcenter.costcent%type;

        v_temp              varchar2(1 char);
        v_temp_check        varchar2(1 char);
        v_flgqlify          varchar2(1 char);
        v_flagwait          varchar2(1 char);
    begin
        for i in 0..param_json_save4.get_size-1 loop
            json_obj            := hcm_util.get_json_t(param_json_save4,to_char(i));

            v_codempid          := hcm_util.get_string_t(json_obj,'codempid');
            v_tab4_dteyear      := hcm_util.get_string_t(json_obj,'dteyear');
            v_tab4_codcompy     := hcm_util.get_string_t(json_obj,'codcompy');
            v_tab4_numclseq     := to_number(hcm_util.get_string_t(json_obj,'numclseq'));
            v_tab4_codcours     := hcm_util.get_string_t(json_obj,'codcours');

            v_flgeditc_t4       := hcm_util.get_string_t(json_obj,'flg');
            v_flagwait          := hcm_util.get_string_t(json_obj,'flagwait');
            v_codcomp           := hcm_util.get_string_t(json_obj,'codcomp');
            v_codpos            := hcm_util.get_string_t(json_obj,'codpos');
            v_stacours          := hcm_util.get_string_t(json_obj,'stacours');
            v_codtparg          := hcm_util.get_string_t(json_obj,'codtparg');
            v_dtetrst           := to_date(hcm_util.get_string_t(json_obj,'dtetrst'), 'dd/mm/yyyy');
            v_dtetren           := to_date(hcm_util.get_string_t(json_obj,'dtetren'), 'dd/mm/yyyy');

            begin
                select costcent into v_costcent
                  from tcenter
                 where codcomp like v_codcomp || '%'
                   and rownum = 1;
            exception when no_data_found then
                v_costcent := '';
            end;

            begin
                v_flgqlify := 'Y';
                select distinct 'X' into v_temp
                  from ttpotent
                 where dteyear = p_dteyear
                   and codcompy =  p_codcompy
                   and codcours = p_codcours
                   and codempid = v_codempid;
            exception when no_data_found then
                v_flgqlify := 'N';
            end;

            if nvl(v_flagwait,'%$#') = 'A' and v_flgeditc_t4 != 'delete' then  -- if v_flagwait = 'A' and v_flgeditc_t4 != 'delete' then  #6899 || User39 || 21/10/2021
                begin
                    select 'x' into v_temp_check
	                  from ttpotent
	                 where dteyear = p_dteyear
	                   and codcompy = p_codcompy
	                   and codcours = p_codcours
	                   and codempid = v_codempid;
	            exception when no_data_found then
	                rollback;
	                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttpotent');
	                return;
	            end;
            end if;

            begin
                select numlvl
                  into v_numlvl
                  from temploy1
                 where codempid = v_codempid;
            exception when no_data_found then
                v_numlvl := null;
            end;
            if v_flagwait = 'Y' and  v_flgeditc_t4 = 'add' then
                begin
                    insert into tpotentp (flgatend, flgwait, staappr, costcent, dteyear,codcompy,codcours,codempid,codcomp
                        ,codpos,stacours,numclseq,numclsn,flgqlify,numlvl,codtparg,dtetrst,dtetren,dtecreate,codcreate,dteupd
                        ,coduser)
                    values ('N', 'N', 'P', v_costcent, v_tab4_dteyear,v_tab4_codcompy,v_tab4_codcours,v_codempid,
                            v_codcomp,v_codpos
                        ,v_stacours,p_numclseq,p_numclseq,v_flgqlify,v_numlvl,v_codtparg,v_dtetrst,v_dtetren,sysdate
                        ,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tpotentp
                       set numclseq = p_numclseq,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where dteyear = v_tab4_dteyear
                       and codcours =  v_tab4_codcours
                       and codcompy = v_tab4_codcompy
                       and numclseq = v_tab4_numclseq
                       and codempid = v_codempid;
                end;
            elsif (v_flgeditc_t4 = 'add') then
                begin
                    select 'x' into v_temp_check
	                  from temploy1
	                 where staemp <> '9'
	                   and codempid = v_codempid;
	            exception when no_data_found then
	                rollback;
	                param_msg_error := get_error_msg_php('HR2101',global_v_lang);
	                return;
	            end;
                
                begin
                    insert into tpotentp (flgatend, flgwait, staappr, costcent, dteyear,codcompy,codcours,codempid,codcomp
                        ,codpos,stacours,numclseq,numclsn,flgqlify,numlvl,codtparg,dtetrst,dtetren,dtecreate,codcreate,dteupd
                        ,coduser)
                    values ('N', 'N', 'P', v_costcent, p_dteyear,p_codcompy,p_codcours,v_codempid,v_codcomp,v_codpos
                        ,v_stacours,p_numclseq,p_numclseq,v_flgqlify,v_numlvl,v_codtparg,v_dtetrst,v_dtetren,sysdate
                        ,global_v_coduser,sysdate,global_v_coduser);

                exception when dup_val_on_index then
                    update tpotentp
                       set flgatend = 'N',
                           flgwait = 'N',
                           staappr = 'P',
                           costcent = v_costcent,
                           numclsn = p_numclseq,
                           stacours = v_stacours,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where dteyear = p_dteyear
                       and codcours =  p_codcours
                       and codcompy = p_codcompy
                       and codempid = v_codempid
                       and numclseq = numclseq;
                end;
            elsif (v_flgeditc_t4 = 'edit') then
                begin
                    update tpotentp
                       set flgatend = 'N',
                           flgwait = 'N',
                           staappr = 'P',
                           numclseq = p_numclseq,
                           numclsn = p_numclseq,
                           stacours = v_stacours,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where dteyear = v_tab4_dteyear
                       and codcours = v_tab4_codcours
                       and codcompy = v_tab4_codcompy
                       and codempid = v_codempid
                       and numclseq = v_tab4_numclseq;
                exception when dup_val_on_index then
                    null;
                end;
            elsif (v_flgeditc_t4 = 'delete') then
                delete tpotentp
                 where dteyear   = v_tab4_dteyear
                    and codcompy = v_tab4_codcompy
                    and codcours = v_tab4_codcours
                    and codempid = v_codempid
                    and numclseq = v_tab4_numclseq;
            end if;
        end loop;

        if param_msg_error is null then
            commit;
--             begin
--              select qtyppc into v_empval
--              from tcourse
--              where codcours = v_codcours;
--                exception when no_data_found then
--                v_empval := 0;
--            end;

            begin
                select qtyppc
                  into v_empval
                  from tyrtrsch
                 where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codcours =  p_codcours
                   and numclseq = p_numclseq;
            exception when no_data_found then
                v_empval := 0;
            end;
            begin
                select count(codempid) into v_qtyemp
                  from tpotentp
                 where codcours = p_codcours
                   and codcompy = p_codcompy
                   and numclseq = p_numclseq
                   and dteyear = p_dteyear;
            exception when no_data_found then
                v_qtyemp := 0;
            end;
            --จำนวนผู้เข้าอบรมเกินจากที่กำหนดในรุ่น  เตือนแต่ให้บันทึกข้อมูลต่อได้
            if ( v_qtyemp > v_empval ) then
                param_msg_error := get_error_msg_php('TR0043',global_v_lang);
                v_flgcontinue   := true;
                return;
            end if;
        else
            rollback;
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end save_data_tab4;

   procedure save_index_detail(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        param_json_save1    json_object_t;
        param_json_save2    json_object_t;
        param_json_save3    json_object_t;
        param_json_save4    json_object_t;
        v_flgedit           varchar2(10 char);
        v_dteyear           tyrtrsch.dteyear%type;
        v_codcompy          tyrtrsch.codcompy%type;
        v_codcours          tyrtrsch.codcours%type;
        v_numclseq          tyrtrsch.numclseq%type;
        
        v_dtetrst           date;
        v_dtetren           date;
    begin
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);

        param_json_save1    := hcm_util.get_json_t(json_obj,'tab1');
        param_json_save2    := hcm_util.get_json_t(json_obj,'tab2');
        param_json_save3    := hcm_util.get_json_t(json_obj,'tab3');
        param_json_save4    := hcm_util.get_json_t(json_obj,'tab4');

        if param_msg_error is null then

            save_data_tab1(param_json_save1);

            if param_msg_error is null then
                save_data_tab2(param_json_save1,param_json_save2);
            end if;
            if param_msg_error is null then
                save_data_tab3(param_json_save1,param_json_save3);
            end if;

            if param_msg_error is null then
                save_data_tab4(param_json_save4);
            end if;
            
            if param_msg_error is null then
                v_dtetrst   := to_date(hcm_util.get_string_t(param_json_save1,'dtetrst'),'dd/mm/yyyy');
                v_dtetren   := to_date(hcm_util.get_string_t(param_json_save1,'dtetren'),'dd/mm/yyyy');
                begin
                    update tpotentp
                       set dtetrst = v_dtetrst,
                           dtetren = v_dtetren,
                           dteupd  = sysdate,
                           coduser = global_v_lang
                     where dteyear  = p_dteyear
                       and codcours = p_codcours
                       and codcompy = p_codcompy
                       and numclseq = p_numclseq;
                exception when no_data_found then
                    null;
                end;
            end if;
        end if;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message('200',param_msg_error,global_v_lang);
        elsif param_msg_error is not null and v_flgcontinue then
            commit;
            json_str_output := get_response_message('201',param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index_detail;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        json_obj json_object_t;
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

    procedure gen_emp_data(p_dteyear number,p_codcompy varchar2,p_codcours varchar2,p_codempid varchar2,json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_get       varchar2(2 char);
        v_codempid  temploy1.codempid%type;
        v_codcomp   temploy1.codcomp%type;
        v_codpos    temploy1.codpos%type;
        v_email     temploy1.email%type;
        v_chk_waiting varchar2(1);
    begin
        obj_rows := json_object_t();
        begin
            select codempid,codcomp,codpos,email into v_codempid,v_codcomp,v_codpos,v_email
              from temploy1
             where codempid = p_codempid;
            exception when no_data_found then
                v_codempid := null;
                v_codcomp  := null;
                v_codpos   := null;
                v_email    := null;
        end;
        if v_codempid is not null then
            v_chk_waiting   := 'N';
            begin
                select 'Y', stacours
                  into v_chk_waiting, v_get
                  from tpotentp a,temploy1 b
                 where a.codempid = b.codempid
                   and b.staemp <> '9'
                   and a.codcompy = p_codcompy
                   and a.dteyearn = p_dteyear
                   and a.codcours = p_codcours
                   and a.numclsn = p_numclseq
                   and a.flgwait = 'Y'
                   and a.codempid = v_codempid;
            exception when no_data_found then
                v_chk_waiting := 'N';
            end;
            
            if v_chk_waiting = 'N' then
                begin
                    select stacours into v_get
                    from ttpotent
                    where dteyear = p_dteyear
                    and codcompy = p_codcompy
                    and codcours = p_codcours
                    and codempid = p_codempid;
                exception when no_data_found then
                    v_get := 'O';
                end;
            end if;
        end if;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('image',get_emp_img(v_codempid));
        obj_data.put('codempid',v_codempid);
        obj_data.put('codcomp',v_codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
        obj_data.put('codpos',v_codpos);
        obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('email',v_email);
        obj_data.put('stacours',v_get);
        if v_chk_waiting = 'Y' then
            obj_data.put('desc_stacours',get_tlistval_name('STACOURS',v_get,global_v_lang)||' (Waiting list)');
        else
            obj_data.put('desc_stacours',get_tlistval_name('STACOURS',v_get,global_v_lang));
        end if;
        obj_rows.put(to_char(v_row-1),obj_data);
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_emp_data;

    procedure get_emp_data(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        params_emp_data     json_object_t;
    begin
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);
        params_emp_data     := hcm_util.get_json_t(json_obj,'params_emp_data');
        p_dteyear           := hcm_util.get_string_t(params_emp_data,'p_dteyear');
        p_codcompy          := upper(hcm_util.get_string_t(params_emp_data,'p_codcompy'));
        p_codcours          := hcm_util.get_string_t(params_emp_data,'p_codcours');
        p_codempid          := hcm_util.get_string_t(params_emp_data,'p_codempid');
        p_numclseq          := hcm_util.get_string_t(params_emp_data,'p_numclseq');
        if param_msg_error is null then
            gen_emp_data(p_dteyear,p_codcompy,p_codcours,p_codempid,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_emp_data;

    procedure get_waiting(json_str_input in clob, json_str_output out clob) as
        json_obj json_object_t;
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_waiting(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_waiting;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        json_obj json_object_t;
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

-- แจ้งผู้บันทึก/ผู้รับผิดชอบหลักสูตร  HRTR3FUCC
    procedure send_mail_attendee(v_codform TFWMAILH.codform%TYPE) as
        json_obj                json_object_t;
        v_rowid                 varchar2(20);
        v_error                 long;
        v_msg_to                clob;
        v_templete_to           clob;
        v_func_appr             varchar2(500 char);
        v_subject               varchar2(500 char);
        v_count                 number;
        v_excel_filename        varchar2(1000 char);
        v_filepath              varchar2(1000 char);
        v_column                varchar2(1000 char);
        v_labels                varchar2(1000 char);
        v_codpos                temploy1.codpos%type;
        v_file_attach           varchar2(4000);
        v_maillang              varchar2(10);
        v_codempid              tpotentp.codempid%type;

--        CURSOR c_tpotentp  IS
--            select a.codempid,a.codcomp,a.codpos,b.email
--              from tpotentp a,temploy1 b
--             where a.codempid = b.codempid
--               and a.dteyear = p_dteyear
--               and a.codcompy = p_codcompy
--               and a.codcours = p_codcours
--               and a.numclseq = p_numclseq
--               and a.stacours not in ('E','W')  -- E-ESS,W-walk in) ไม่ต้องส่ง Mail
--           ORDER BY A.codempid;
    begin
--        for i in 0..param_json.count-1 loop
            json_obj        := param_json;
--            json_obj        := hcm_util.get_json(param_json,to_char(i));
            v_codempid      := hcm_util.get_string_t(json_obj,'codempid');
            v_msg_to        := '';
            v_templete_to   := '';
            v_maillang      :=  chk_flowmail.get_emp_mail_lang(v_codempid);

            if p_refdoc is not null and (p_refdoc not like 'https://%' and p_refdoc not like 'http://%') then
                begin
                    select get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRTR55E')||'/'||p_refdoc
                      into v_file_attach
                      from dual;
                exception when no_data_found then
                    v_file_attach := null;
                end;
            else
                v_file_attach := p_refdoc;
            end if;
            begin
                select decode(v_maillang,101,descode,102,descodt,103,descod3,104,descod4,105,descod5) subject
                  into v_subject
                  from tfrmmail
                 where codform = v_codform;
            exception when no_data_found then
                v_subject := null;
            end;

            begin
                select rowid
                  into v_rowid
                  from tyrtrsch
                 where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codcours = p_codcours
                   and numclseq = p_numclseq;
            exception when no_data_found then
              v_rowid := null;
            end;

            chk_flowmail.get_message_result(v_codform, v_maillang, v_msg_to, v_templete_to);
            begin
                select decode(v_maillang,'101',messagee,
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

            v_msg_to := replace(v_msg_to,'[PARAM-01]',get_temploy_name(v_codempid,v_maillang));
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TYRTRSCH', v_rowid, v_subject, v_codform, '1', null, global_v_coduser, v_maillang, v_msg_to, p_chkparam => 'N',p_file => p_attendee_filename);
            begin
                select rowid
                  into v_rowid
                  from tpotentp
                 where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codcours = p_codcours
                   and numclseq = p_numclseq
                   and codempid = v_codempid;
            exception when no_data_found then
              v_rowid := null;
            end;

            chk_flowmail.replace_param('TPOTENTP',v_rowid,v_codform,'1',v_maillang,v_msg_to,'N');

            begin
                select codpos
                  into v_codpos
                  from temploy1
                 where codempid = p_signature;
            exception when no_data_found then
                v_codpos := '';
            end;
            v_msg_to        := replace(v_msg_to,'[param_sign]',get_temploy_name(p_signature,v_maillang));
            v_msg_to        := replace(v_msg_to,'[param_position]',get_tpostn_name(v_codpos,v_maillang));
            v_error         := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', v_maillang, v_file_attach,p_attendee_filename,null, null, null);
--        end loop;
    end send_mail_attendee;

/*    procedure send_mail_instructor(v_codform TFWMAILH.codform%TYPE, v_filename1 varchar2,v_codinst ttrsubjd.codinst%type) as
        v_rowid         varchar2(20);

        json_obj        json_object_t;
--        v_codform       TFWMAILH.codform%TYPE;

        v_error             varchar2(4000 char);
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_subject           varchar2(500 char);

        v_msg         	    clob;
        v_ttrsubjd_table    clob;

        v_email         varchar2(200);

        v_dteyear       tyrtrsch.dteyear%type;
        v_codcompy       tyrtrsch.codcompy%type;
        v_numclseq      tyrtrsch.numclseq%type;
        v_codcours      tyrtrsch.codcours %type;
        v_sign          temploy1.codempid%type;
        v_refdoc        varchar2(1000 char);
        v_stainst       tinstruc.stainst%type;
        v_namepos       tinstruc.namepos%type;
        v_desnoffi       tinstruc.desnoffi%type;
        v_codempid      tinstruc.codempid%type;

        v_codpos        temploy1.codpos%type;
        v_codcomp        temploy1.codcomp%type;

        cursor c1 is
            select timstrt,timend,codsubj,dtetrain
            from ttrsubjd a
            where a.dteyear  = p_dteyear
		    and a.codcompy = p_codcompy
		    and a.codcours = p_codcours
		    and a.numclseq = p_numclseq
            and a.codinst = v_codinst;

    begin

        v_subject  := get_label_name(p_codapp, global_v_lang, 10);

--        begin
--            select codform into v_codform
--            from tfwmailh
--            where codapp = v_codapp;
--        exception when no_data_found then
--            v_codform  := 'HRTR55ET1';
--        end;

--        v_codinst  := hcm_util.get_string(data_obj, 'codinst');
--        v_dteyear  := to_number(hcm_util.get_string(data_obj, 'dteyear'));
--        v_codcompy  := hcm_util.get_string(data_obj, 'codcompy');
--        v_codcours := hcm_util.get_string(data_obj, 'codcours');
--        v_numclseq  := to_number(hcm_util.get_string(data_obj, 'numclseq'));
--        v_sign       := hcm_util.get_string(data_obj, 'signature');
--        v_dtereq    := to_date(hcm_util.get_string(data_obj, 'dtereq'),'dd/mm/yyyy');
        chk_flowmail.get_message(p_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);

        begin
            select email,stainst,namepos,desnoffi,codempid,rowid into v_email,v_stainst,v_namepos,v_desnoffi,v_codempid,v_rowid
            from tinstruc
            where codinst = v_codinst;
        exception when no_data_found then
            v_rowid := '';
        end;

        if v_stainst = 'I' or v_stainst = '1' then

            begin
                select rowid into v_rowid
                from temploy1
                where codempid = v_codempid;
            exception when no_data_found then
                v_rowid := '';
            end;
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
        elsif v_stainst = 'E' or v_stainst = '2' then
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TINSTRUC', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
        end if;

        -- replace employee param
        begin
            select rowid into v_rowid
            from tyrtrsch
            where codcompy = p_codcompy
            and codcours = p_codcours
            and dteyear = p_dteyear
            and numclseq  = p_numclseq;
        exception when no_data_found then
            v_rowid := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TYRTRSCH', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        -- replace employee param email reciever param
        for i in c1 loop
            v_ttrsubjd_table :=  v_ttrsubjd_table||'<p>'||get_tcodec_name('TCODSUBJ',i.codsubj,global_v_lang)
                                                 ||' '||get_label_name('HRTR55EP4', global_v_lang, 20)||': '||to_char(i.dtetrain,'dd/mm/yyyy')
                                                 ||' '||get_label_name('HRTR55EP4', global_v_lang, 30)||': '||(substr(i.timstrt,1,2)||':'||substr(i.timstrt,3))||' - '||(substr(i.timend,1,2)||':'||substr(i.timend,3))
                                                 ||'</p>';
        end loop;
        v_msg_to := replace(v_msg_to,'[TTRSUBJD]]',v_ttrsubjd_table);

        -- replace sender
        begin
            select codpos into v_codpos
            from temploy1
            where codempid = p_signature;
        exception when no_data_found then
            v_codpos := '';
        end;
        v_msg_to := replace(v_msg_to,'[param_sign]',get_temploy_name(p_signature,global_v_lang));
        v_msg_to := replace(v_msg_to,'[param_position]',get_tpostn_name(v_codpos,global_v_lang));

--        param_msg_error := v_email||' mail '||v_msg_to||' <<END>> ';
--        return;
        if v_stainst = 'I' or v_stainst = '1' then
            v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_filename1,p_refdoc,null, null);
        else
            v_msg_to   := replace(v_msg_to ,'[PARA_DATE]'  ,to_char(sysdate,'dd/mm/yyyy'));
            v_msg_to   := replace(v_msg_to ,'[P_CODUSER]'  ,global_v_coduser);
            v_msg_to   := replace(v_msg_to ,'[P_LANG]'        ,global_v_lang);
            v_msg_to   := replace(v_msg_to ,'[PARAM1]'       ,get_temploy_name(global_v_coduser, global_v_lang));
            v_msg_to   := replace(v_msg_to ,'[PARAM2]'       ,v_subject);
            v_msg_to   := replace(v_msg_to ,'[P_EMAIL]'      ,v_email);
            v_error := send_mail(p_email    => v_email,
                                 p_msg     => v_msg_to,
                                 p_codappr  => null,
                                 p_codapp  => null,
                                 p_filename1 => v_filename1,
                                 p_filename2 => p_refdoc,
                                 p_filename3 => null,
                                 p_filename4 => null,
                                 p_filename5 => null,
                                 p_attach_mode => null);
        end if;
    end send_mail_instructor;*/

    procedure send_email(json_str_input in clob, json_str_output out clob) as
        json_obj                json_object_t;
        p_numclseq              tyrtrsch.numclseq%type;
        v_codform               TFWMAILH.codform%TYPE;
        v_letterfor             varchar2(20 char);
        p_signature             temploy1.codempid%type;
        v_filename1   	        varchar2(1000 char);
        v_codinst               ttrsubjd.codinst%type;

        v_temp                  varchar2(4 char);
        param_json_tab          json_object_t;
        param_json_tab_child    json_object_t;
        param_json_row          json_object_t;
        param_json_data         json_object_t;

        cursor c1 is
            select a.dteyear,a.codcompy,a.codcours, a.numclseq, a.codinst
              from ttrsubjd a, tyrtrsch b
             where a.dteyear  = b.dteyear
		       and a.codcompy = b.codcompy
		       and a.codcours = b.codcours
		       and a.numclseq = b.numclseq
               and b.dteyear = p_dteyear
               and b.codcompy = p_codcompy
               and b.codcours = p_codcours
               and b.numclseq = p_numclseq
          group by a.dteyear,a.codcompy,a.codcours,a.numclseq,a.codinst
          order by a.numclseq,a.codinst;
    begin
        param_msg_error         := '';
        initial_value(json_str_input);
        json_obj                := json_object_t(json_str_input);
        param_json              := hcm_util.get_json_t(json_obj,'param_json');

--        p_dteyear   := hcm_util.get_string(param_json_detail,'p_dteyear');
--        p_codcompy  := hcm_util.get_string(param_json_detail,'p_codcompy');
--        p_codcours  := hcm_util.get_string(param_json_detail,'p_codcours');
--        p_codcate   := hcm_util.get_string(param_json_detail,'p_codcate');
--        p_numclseq  := hcm_util.get_string(param_json_detail,'p_numclseq');
--        p_codinst   := hcm_util.get_string(param_json_detail,'p_codinst');

        p_codform               := hcm_util.get_string_t(json_obj,'p_codform');
        v_letterfor             := hcm_util.get_string_t(json_obj,'p_letterfor'); --'1' instructor '2' attendee
        p_signature             := hcm_util.get_string_t(json_obj,'p_signature');

        begin
            select 'x' into v_temp
              from TFRMMAIL
             where codform = p_codform
               and typfrm in ('HRTR55ET1','HRTR55ET2');
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TFRMMAIL');
        end;

        begin
            select 'x' into v_temp
              from TEMPLOY1
             where codempid = p_signature;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        end;

        if param_msg_error is null then
            if v_letterfor = '1' then -- instructor
                null;
                -- use tr56x sendmail
--                for r1 in c1 loop
--                    send_mail_instructor(p_codform, null,p_codinst);
--                end loop;
            elsif v_letterfor = '2' then -- attendee
                send_mail_attendee(p_codform);
            end if;
--            gen_report_lecturer(p_dteyear,p_codcours,p_codcompy,p_numclseq,p_codinst,json_str_output);
--            gen_report_trainer(p_dteyear,p_codcours,p_codcompy,p_numclseq,p_codinst,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
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

/*    procedure get_report_lecturer(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
    begin
        initial_value(json_str_input);
        gen_report_lecturer(p_dteyear,p_codcours,p_codcompy,p_numclseq,p_codinst,json_str_output);

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
    end get_report_lecturer;*/

    procedure get_report_trainer(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
    begin
        initial_value(json_str_input);
        gen_report_trainer(p_dteyear,p_codcours,p_codcompy,p_numclseq,p_codinst,json_str_output);

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
    end get_report_trainer;

    procedure gen_template(json_str_output out clob, json_str_input clob) as
        obj_data            json_object_t;
        v_row               number := 0;
        v_email             tinstruc.email%type;
        v_stainst           tinstruc.stainst%type;
        v_codform           TFWMAILH.codform%TYPE;
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr         varchar2(500 char);
    begin
        obj_data            := json_object_t(json_str_input);
        v_codform           := upper(hcm_util.get_string_t(obj_data,'codform'));
        obj_data            := json_object_t();
        chk_flowmail.get_message_result(v_codform,global_v_lang,v_msg_to,v_templete_to);
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

        obj_data := json_object_t();
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
END HRTR55E;

/
