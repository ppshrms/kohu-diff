--------------------------------------------------------
--  DDL for Package Body HRTR34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR34E" AS

--update 05/11/2563

  procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj                := json_object_t(json_str_input);
        global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        p_dteyear               := hcm_util.get_string_t(json_obj,'p_dteyear');
        p_codcompy              := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_codcours              := upper(hcm_util.get_string_t(json_obj,'p_codcours'));

        p_codcomp               := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
        p_codpos                := upper(hcm_util.get_string_t(json_obj,'p_codpos'));

        p_dteyreap               := hcm_util.get_string_t(json_obj,'p_dteyreap');
        p_numtime               := hcm_util.get_string_t(json_obj,'p_numtime');
        p_flgprior              := hcm_util.get_string_t(json_obj,'p_flgprior');
        p_numseq                := hcm_util.get_string_t(json_obj,'p_numseq');

        p_dtestrt               := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
        p_dteend                := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

        p_flgempnew             := hcm_util.get_string_t(json_obj,'p_flgempnew');
        p_flgempmove            := hcm_util.get_string_t(json_obj,'p_flgempmove');
        p_dteempmtst            := to_date(hcm_util.get_string_t(json_obj,'p_dteempmtst'),'dd/mm/yyyy');
        p_dteempmtend           := to_date(hcm_util.get_string_t(json_obj,'p_dteempmtend'),'dd/mm/yyyy');
        p_dteeffecst            := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecst'),'dd/mm/yyyy');
        p_dteeffecend           := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecend'),'dd/mm/yyyy');

        p_flgClearTmp           := hcm_util.get_string_t(json_obj,'p_flgClearTmp');
        p_codskill              := hcm_util.get_string_t(json_obj,'p_codskill');
        p_grade                 := hcm_util.get_string_t(json_obj,'p_grade');
  end initial_value;

    procedure check_index as
        v_temp                  varchar2(1 char);
        v_temp_check            number;
    begin
        if p_dteyear is null or p_codcompy is null  then
            param_msg_error     := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
              from tcenter
             where codcomp like p_codcompy||'%'
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;

        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_main        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_tcourse       tcourse.codcours%type;
        v_temp          number := 0;
        v_temp_check    number := 0;

    cursor c1 is
        select codcate,codcours,plancond,codtparg,qtyptpln,amtclbdg,staappr
          from tyrtrpln
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and (coduser not like 'TEMP-%' or coduser = 'TEMP-'||global_v_codempid )
      order by codcate,codcours;

    begin
        obj_main := json_object_t();
        obj_rows := json_object_t();
        obj_main.put('coderror',200);

        if p_flgClearTmp = 'Y' then
            begin
                delete tyrtrpln
                 where coduser = 'TEMP-'||global_v_codempid;
                delete ttpotent
                 where coduser = 'TEMP-'||global_v_codempid;
                commit;
            exception when others then
                null;
            end;
        end if;

        begin
            select count(*) into v_temp_check
              from tyrtrpln
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and staappr in ('A','Y','N');
        end;
        if v_temp_check > 0 then
            obj_main.put('msgerror',replace(get_error_msg_php('HR1490',global_v_lang),'@#$%400',null));
        end if;

        for i in c1 loop
            begin
                select coddevp
                  into v_tcourse
                  from tcourse
                 where codcours = i.codcours;
            exception when no_data_found then
                v_tcourse := '';
            end;

            v_row       := v_row+1;
            obj_data    := json_object_t();

            obj_data.put('dteyear',p_dteyear);
            obj_data.put('codcompy',p_codcompy);
            obj_data.put('amtclbdg',i.amtclbdg);
            obj_data.put('codcate',i.codcate);
            obj_data.put('codcours',i.codcours);
            obj_data.put('coddevp',v_tcourse);
            obj_data.put('codtparg',i.codtparg);
            obj_data.put('des_plancond',get_tlistval_name('STACOURS',i.plancond,global_v_lang));
            obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
            obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
            obj_data.put('desc_coddevp',get_tlistval_name('METTRAIN',v_tcourse,global_v_lang));
            obj_data.put('desc_codtparg',get_tlistval_name('CODTPARG',i.codtparg,global_v_lang));
            obj_data.put('desc_staappr',get_tlistval_name('STAAPPR',i.staappr,global_v_lang));
            obj_data.put('plancond',i.plancond);
            obj_data.put('qtyptpln',i.qtyptpln);
            obj_data.put('staappr',i.staappr);
            obj_data.put('status',get_tlistval_name('STAAPPR',i.staappr,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_main.put('table',obj_rows);
        json_str_output := obj_main.to_clob;
    end gen_index;

    procedure gen_detail(json_str_output out clob) as
        obj_main            json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        obj_rows            json_object_t;
        obj_data            json_object_t;
        obj_result          json_object_t;
        obj_ttpotent        json_object_t;
        v_row               number := 0;
        v_temp              varchar2(20 char);
        v_row_secur         number := 0;
        v_qtyppc            tcourse.qtyppc%type;
        v_amtbudg           tcourse.amtbudg%type;
        v_temp_check        number :=0;
        v_tyrtrpln          tyrtrpln%rowtype;
        obj_syncond         json_object_t;
        v2_qtyppc           number;
        v2_amtbudg          number;
        v2_default          varchar2(20 char);

        cursor c1 is
            select *
              from ttpotent
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and (coduser not like 'TEMP-%' or coduser = 'TEMP-'||global_v_codempid )
          order by codempid;

    begin
        obj_main        := json_object_t();
        obj_tab1        := json_object_t();
        obj_tab2        := json_object_t();
        obj_syncond     := json_object_t();
        begin
            select count(*) into v_temp_check
              from tyrtrpln
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and staappr in ('A','Y','N');
        end;

        select qtyppc, amtbudg
          into v_qtyppc, v_amtbudg
          from tcourse
         where codcours = p_codcours;

        obj_tab1.put('dteyear',p_dteyear);
        obj_tab1.put('codcompy',p_codcompy);
        obj_tab1.put('codcours',p_codcours);
        obj_tab1.put('qtyptbdg',v_qtyppc);
        obj_tab1.put('amtpbdg',v_amtbudg);

        v2_default := 'N';  -- #7220 || USER39 || 07/12/2021
        begin
            select *
              into v_tyrtrpln
              from tyrtrpln
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours;
            obj_tab1.put('flgedit','Edit');
            obj_tab1.put('plancond',v_tyrtrpln.plancond);
            obj_tab1.put('des_plancond',get_tlistval_name('STACOURS',v_tyrtrpln.plancond,global_v_lang));
            v2_default := 'N'; -- #7220 || USER39 || 07/12/2021
        exception when no_data_found then
            v_tyrtrpln := null;
            obj_tab1.put('flgedit','Add');
            obj_tab1.put('plancond','O');
            obj_tab1.put('des_plancond',get_tlistval_name('STACOURS','O',global_v_lang));
            --<< #7220 || USER39 || 07/12/2021
            begin
                select qtyppc,amtbudg
                into v2_qtyppc ,v2_amtbudg
                from tcourse
                where codcours = p_codcours;
                v2_default := 'Y';
            exception when no_data_found then
                v2_default := 'N';
            end;
            -->> #7220 || USER39 || 07/12/2021
        end;

        obj_rows        := json_object_t();
        obj_data        := json_object_t();
        obj_result      := json_object_t();

--<< #7220 || USER39 || 07/12/2021
        if v2_default = 'Y' then
            obj_tab1.put('amtclbdg',v2_amtbudg * v2_qtyppc);
            obj_tab1.put('amtpbdg',v2_amtbudg);
            obj_tab1.put('amttot',v2_amtbudg * v2_qtyppc);
            obj_tab1.put('qtyptbdg',v2_qtyppc);  -- จำนวนผู้เข้าอบรม
        else
            obj_tab1.put('amtclbdg',v_tyrtrpln.amtclbdg);
            obj_tab1.put('amtpbdg',v_tyrtrpln.amtpbdg);
            obj_tab1.put('amttot',v_tyrtrpln.amttot);
            obj_tab1.put('qtyptbdg',v_tyrtrpln.qtyptbdg);  -- จำนวนผู้เข้าอบรม
        end if;
-->> #7220 || USER39 || 07/12/2021

        obj_tab1.put('codhotel',v_tyrtrpln.codhotel);
        obj_tab1.put('codinsts',v_tyrtrpln.codinsts);
        obj_tab1.put('codrespn',v_tyrtrpln.codrespn);
        obj_tab1.put('codtparg',v_tyrtrpln.codtparg);
        if (v_temp_check > 0) then
            if v2_default not in ('A','Y','N') then
             obj_tab1.put('message', replace(get_error_msg_php('HR1490', global_v_lang),'@#$%400',null));
            else 
             obj_tab1.put('message','');
            end if;
        else
            obj_tab1.put('message','');
        end if;
        obj_tab1.put('qtynumcl',v_tyrtrpln.qtynumcl);  -- จำนวนรุ่นที่จัดอบรม
        obj_tab1.put('qtyptpln',v_tyrtrpln.qtyptpln);
        obj_tab1.put('remark',v_tyrtrpln.remark);
        obj_tab1.put('staappr',v_tyrtrpln.staappr);
        obj_syncond.put('code',nvl(v_tyrtrpln.syncond,''));
        obj_syncond.put('description',get_logical_desc(v_tyrtrpln.statement));
        obj_syncond.put('statement',nvl(v_tyrtrpln.statement,'[]'));
        obj_tab1.put('syncond',obj_syncond);
        obj_tab1.put('typcon',v_tyrtrpln.typcon);
        obj_tab1.put('typtrain',v_tyrtrpln.typtrain);
        v_row       := 0;
        for r1 in c1 loop
            v_row           := v_row + 1;
            obj_ttpotent    := json_object_t();
            obj_ttpotent.put('codcomp',r1.codcomp);
            obj_ttpotent.put('codempid',r1.codempid);
            obj_ttpotent.put('codpos',r1.codpos);
            obj_ttpotent.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
            obj_ttpotent.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
            obj_ttpotent.put('desc_stacours',get_tlistval_name('STACOURS',r1.stacours,global_v_lang));
            obj_ttpotent.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            obj_ttpotent.put('image',get_emp_img(r1.codempid));
            obj_ttpotent.put('remark',r1.remark);
            obj_ttpotent.put('stacours',r1.stacours);
            obj_tab2.put(to_char(v_row-1),obj_ttpotent);
        end loop;
        obj_main.put('coderror',200);
        obj_main.put('tab1',obj_tab1);
        obj_main.put('tab2',obj_tab2);
        json_str_output := obj_main.to_clob;
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
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

    procedure gen_prev_year(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select to_char(dtetrst,'dd/mm/yyyy') as dtetrst,
                   to_char(dtetren,'dd/mm/yyyy') as dtetren,
                   dteyear,codtparg,codhotel,
                   codinsts,amtcost,amttotexp,numclseq
              from thisclss
             where codcompy = p_codcompy
               and codcours = p_codcours
               and dteyear = (select max(dteyear)
                                from thisclss
                               where codcompy = p_codcompy
                                 and codcours = p_codcours
                                 and dteyear < p_dteyear)
          order by numclseq;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('numclseq',i.numclseq);
            obj_data.put('dtetrain',i.dtetrst||' - '||i.dtetren);
            obj_data.put('desc_codtparg',get_tlistval_name('CODTPARG',i.codtparg,global_v_lang));
            obj_data.put('desc_codhotel',get_thotelif_name(i.codhotel,global_v_lang));
            obj_data.put('desc_codinsts',get_tinstitu_name(i.codinsts,global_v_lang));
            obj_data.put('amtcost',i.amtcost);
            obj_data.put('amttotexp',i.amttotexp);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        if obj_rows.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRPLN');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_prev_year;

    procedure gen_mail(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_flgpass   boolean;
        v_check     varchar2(500 char);
        v_staappr2  varchar2(500 char);
        v_approvno  number := 0;

        cursor c1 is
              select codrespn
                from tyrtrpln
               where dteyear = p_dteyear
                 and codcompy = p_codcompy
            group by codrespn
            order by codrespn;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_flgpass := chk_flowmail.check_approve('HRTR34E', i.codrespn, v_approvno, global_v_codempid, null, null, v_check);
            if v_check = 'Y' then
                v_staappr2 := 'C';
            else
                v_staappr2 := 'A';
            end if;
        end loop;
        if obj_rows.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRPLN');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_mail;

    procedure check_tapptrnf as
    begin
        if ((p_dteto = null) or (p_dtefrom = null) or (p_numtime = null)) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if (p_dteto > p_dtefrom) then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        end if;
    end check_tapptrnf;

   procedure gen_process(json_str_output out clob,
                         p_syncond varchar2,
                         p_typcon varchar2,
                         p_typtrain varchar2,
                         p_remark varchar2) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        obj_res         json_object_t;
        obj_main        json_object_t;
        v_row           number := 0;
        v_row_secur     number := 0;

        v_statement     clob;
        v_syncond       clob;
        v_statement1    clob;
        v_statement2    clob;

        TYPE EmpCurTyp  IS REF CURSOR;
        c1 SYS_REFCURSOR;
        v_temploy1      temploy1%rowtype;
    begin
        obj_main        := json_object_t();
        if (p_typcon  = '1') then
            v_syncond := p_syncond;
        end if;
        if (p_typcon = '2') then
            begin
                select nvl(syncond,'V_HRTR.codcomp like '''||p_codcompy||'%''')
                  into v_syncond
                  from tcourse
                 where codcours = p_codcours;
            exception when no_data_found then
                v_syncond := 'V_HRTR.codcomp like '''||p_codcompy||'%''';
            end;
        end if;
        v_statement := 'select DISTINCT * from temploy1 where codcomp like '''||p_codcompy||'%'' and staemp not in (''9'',''0'')'||' AND EXISTS (SELECT CODEMPID FROM V_HRTR WHERE ('||v_syncond||') AND codempid =  temploy1.codempid)';

        if (p_typtrain = '1') then
            v_statement := v_statement||' and EXISTS (SELECT DISTINCT e.codempid FROM THISTRNN e WHERE e.codcours = '''||p_codcours||''' AND e.codempid =  temploy1.codempid)';
        elsif (p_typtrain = '2') then
            v_statement := v_statement||' and EXISTS (select distinct e.codempid from THISTRNN e where e.codcours = '''||p_codcours||''' and e.codempid =  temploy1.codempid and FLGTREVL = ''F'')';
        elsif (p_typtrain = '3') then
            v_statement := v_statement||' and NOT EXISTS (SELECT DISTINCT E.CODEMPID FROM THISTRNN E WHERE E.CODCOURS = '''||p_codcours||''' AND E.CODEMPID =  temploy1.CODEMPID)';
        else
            v_statement := v_statement;
        end if;
        v_statement := v_statement || ' order by codempid';
        insert into a(a) values (v_statement); commit;
--<< #7218 || USER39 || 23/11/2021
        v_statement := replace(v_statement,'V_HRTR.AGE ','V_HRTR.AGE_EMP '); -- Adisak redmine#9234 31/03/2023 10:43: add space char in replace searching for ignore AGE_XXX
        v_statement := replace(v_statement,'V_HRTR.YR','V_HRTR.AGE_WORK');
        v_statement := replace(v_statement,'V_HRTR.SV_LVL','V_HRTR.AGE_LVL');
        v_statement := replace(v_statement,'V_HRTR.SV_POS','V_HRTR.AGE_POS');
-->> #7218 || USER39 || 23/11/2021

        v_statement := replace(v_statement,'V_HRTR1.CODCOMP','V_HRTR.CODCOMP'); -- #7219 || USER39 || 25/11/2021
        begin
            obj_rows := json_object_t();
            OPEN c1 FOR v_statement; -- Opening c1 for the select statement
            v_row := 0;
            LOOP
                FETCH c1 INTO v_temploy1;
                EXIT WHEN (c1%NOTFOUND);
                v_row := v_row+1;
                if secur_main.secur3(v_temploy1.codcomp,v_temploy1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    v_row_secur := v_row_secur+1;
                    obj_data    := json_object_t();
                    obj_data.put('codcomp',v_temploy1.codcomp);
                    obj_data.put('codempid',v_temploy1.codempid);
                    obj_data.put('codpos',v_temploy1.codpos);
                    obj_data.put('desc_codcomp',get_tcenter_name(v_temploy1.codcomp,global_v_lang));
                    obj_data.put('desc_codpos',get_tpostn_name(v_temploy1.codpos,global_v_lang));
                    obj_data.put('desc_stacours',get_tlistval_name('STACOURS','O',global_v_lang));
                    obj_data.put('desc_codempid',get_temploy_name(v_temploy1.codempid,global_v_lang));
                    obj_data.put('image',get_emp_img(v_temploy1.codempid));
                    obj_data.put('remark',p_remark);
                    obj_data.put('stacours','O');
                    obj_rows.put(to_char(v_row-1),obj_data);
               end if;
            END LOOP;
            close c1;
        end;
        if  v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        if ( v_row > 0 ) and ( v_row_secur = 0 ) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        obj_main.put('coderror', '200');
        obj_main.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_main.put('rows', obj_rows);
        json_str_output := obj_main.to_clob;
    end gen_process;

    procedure get_prev_year(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_prev_year(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_prev_year;

    procedure send_mail_a as
        json_obj            json_object_t;
        v_codform           TFWMAILH.codform%TYPE;
        v_codapp            ttemprpt.codapp%TYPE;
        v_codrespn          tyrtrpln.codrespn%TYPE;

        v_error             long;
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr         varchar2(500 char);
        v_subject           varchar2(500 char);

        v_count             number;
        v_excel_filename    varchar2(1000 char);
        v_filepath          varchar2(1000 char);
        v_column            varchar2(1000 char);
        v_labels            varchar2(1000 char);
        v_approvno2         tyrtrpln.approvno%type;
        v_staappr         tyrtrpln.staappr%type;

        cursor c_codrespn is
            select codrespn, approvno
              from tyrtrpln
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and rownum = 1;

        cursor c_excel is --export Excel
            select codcours,codtparg,qtynumcl,qtyptbdg,amtpbdg,amtclbdg,amttot
              from tyrtrpln
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codrespn = v_codrespn
               and nvl(approvno,0) = nvl(v_approvno2,0)
          order by codcours;

    begin
        v_subject   := get_label_name('HRTR3FU', global_v_lang, 10);
        v_codapp    := 'HRTR34E';

        begin
            select codform
              into v_codform
              from tfwmailh
             where codapp = v_codapp;
        exception when no_data_found then
        	v_codform := 'HRTR3FUTO';
        end;

        for i in c_codrespn loop
            v_msg_to        := '';
            v_templete_to   := '';
            v_approvno2     := i.approvno;
            begin
                delete ttemprpt
                 where codempid = global_v_codempid
                   and codapp = v_codapp;
            exception when others then
                null;
            end;

            begin
                delete from ttempprm
                 where codempid = global_v_codempid
                   and codapp   = v_codapp;
            exception when others then
                null;
            end;

            begin
                insert into ttempprm (codempid, codapp, namrep,pdate,ppage,
                                      label1, label2, label3, label4, label5, label6, label7)
                     values (global_v_codempid, v_codapp,'namrep',to_char(sysdate,'dd/mm/yyyy'),'page1',
                             get_label_name('HRTR3FUP1', global_v_lang, 30), get_label_name('HRTR3FUP1', global_v_lang, 40), get_label_name('HRTR3FUP1', global_v_lang, 90),
                             get_label_name('HRTR3FUP2', global_v_lang, 40), get_label_name('HRTR3FUP2', global_v_lang, 60), get_label_name('HRTR3FUP2', global_v_lang, 80),
                             get_label_name('HRTR3FUP2', global_v_lang, 110));
            exception when dup_val_on_index then
                param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'ttempprm');
            end;

            v_count     := 0;
            v_codrespn  := i.codrespn;

            for j in c_excel loop
                v_count := v_count+1;
                begin
                    insert into ttemprpt (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7)
                         values (global_v_codempid, v_codapp, v_count, j.codcours, get_tcourse_name(j.codcours,global_v_lang), get_tlistval_name('CODTPARG', j.codtparg,global_v_lang),
                                 to_char(j.qtynumcl,'fm9,999,999,990'),
                                 to_char(j.qtyptbdg,'fm9,999,999,990'),
                                 to_char(j.amtclbdg,'fm9,999,999,990.00'),
                                 to_char(j.amttot,'fm9,999,999,990.00'));
                    exception when dup_val_on_index then
                        param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'ttemprpt');
                end;
            end loop;

            v_excel_filename      := v_codrespn || '_excelmail';
            v_filepath            := get_tsetup_value('PATHEXCEL') || v_excel_filename;
            v_column              := 'item1, item2, item3, item4, item5, item6, item7';
            v_labels              := 'label1, label2, label3, label4, label5, label6, label7';
            excel_mail(v_column, v_labels, null, global_v_codempid, v_codapp, v_excel_filename);
            begin 
                select staappr
                into v_staappr
                from tyrtrpln
                where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codrespn = v_codrespn
                   and nvl(approvno,0) = nvl(v_approvno2,0)
                order by codcours;
            exception when no_data_found then
                v_staappr := 'U';
            end;
            if v_staappr = 'Y' then
                v_staappr := 'U';
            else
                v_staappr := 'E';
            end if;
            v_error := chk_flowmail.send_mail_for_approve('HRTR34E', v_codrespn, global_v_codempid, global_v_coduser, v_excel_filename, 'HRTR3FU', 10, v_staappr, 'P', nvl(i.approvno,0) + 1, null, null,null,null, '1', 'Oracle');
        end loop;
    end send_mail_a;

    procedure send_mail(json_str_input in clob, json_str_output out clob) as
        v_rowid     varchar(20);
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            begin
                select rowid into v_rowid
                  from temploy1
                 where codempid = global_v_codempid;
            exception when no_data_found then
              v_rowid := null;
            end;
            send_mail_a;
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
    end send_mail;

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

    procedure get_process(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        param_detail        json_object_t;
        p_remark            ttpotent.remark%type;
        p_typcon            tyrtrpln.typcon%type;
        p_typtrain          tyrtrpln.typtrain%type;
        obj_syncond         json_object_t;
        p_syncond           tcourse.syncond%type;
    begin
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);
        param_detail        := hcm_util.get_json_t(json_obj,'detail');
        p_typcon            := hcm_util.get_string_t(param_detail,'typcon');
        obj_syncond         := hcm_util.get_json_t(param_detail,'syncond');
        p_syncond           := hcm_util.get_string_t(obj_syncond,'code');
        p_typtrain          := hcm_util.get_string_t(param_detail,'typtrain');
        p_remark            := hcm_util.get_string_t(param_detail,'remark');

        if param_msg_error is null then
            gen_process(json_str_output,p_syncond,p_typcon,p_typtrain,p_remark);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        IF param_msg_error IS NOT NULL THEN
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        END IF;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_process;

   procedure delete_tyrtrpln(json_str_output out clob,v_dteyear number,v_codcompy varchar2,v_codcours varchar2) as
        json_obj    json_object_t;
   begin
        delete tyrtrpln
         where dteyear = v_dteyear
           and codcompy = v_codcompy
           and codcours = v_codcours;

        delete ttpotent
         where dteyear = v_dteyear
           and codcompy = v_codcompy
           and codcours = v_codcours;
   exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
   end delete_tyrtrpln;

   procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        param_json          json_object_t;
        v_dteyear           tyrtrpln.dteyear%type;
        v_codcompy          tyrtrpln.codcompy%type;
        v_codcours          tyrtrpln.codcours%type;
        v_flag              varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            json_obj        := hcm_util.get_json_t(param_json,to_char(i));
            v_dteyear       := hcm_util.get_string_t(json_obj,'dteyear');
            v_codcompy      := hcm_util.get_string_t(json_obj,'codcompy');
            v_codcours      := hcm_util.get_string_t(json_obj,'codcours');
            v_flag          := hcm_util.get_string_t(json_obj,'flg');
            if v_flag ='delete' then
                delete_tyrtrpln(json_str_output,v_dteyear,v_codcompy,v_codcours);
            end if;
        end loop;
        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;


    procedure gen_planidp(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_qtyemp        number := 0;

        v_codcate       tidpplans.codcate%type;
        v_codcours      tidpplans.codcours%type;
        v_codcomp       tidpplan.codcomp%type;
        v_codpos        tidpplan.codpos%type;

        cursor c1 is
            select b.codcate,b.codcours,a.codcomp,a.codpos
              from tidpplan a,tidpplans b
             where a.dteyear = b.dteyear
               and a.codempid = b.codempid
               and a.dteyear = p_dteyear
               and a.codcomp like p_codcompy||'%'
               and ((b.dtestr between p_dtestrt and p_dteend)
                   or (b.dteend between p_dtestrt and p_dteend)
                   or (p_dtestrt between b.dtestr and b.dteend)
                   or (p_dteend between b.dtestr and b.dteend))
          group by b.codcate,b.codcours,a.codcomp,a.codpos
          order by b.codcate,b.codcours,a.codcomp,a.codpos;

        cursor c2 is
            select a.codempid
              from tidpplan a,tidpplans b
             where a.dteyear = b.dteyear
               and a.codempid = b.codempid
               and a.dteyear = p_dteyear
               and a.codcomp = v_codcomp
               and a.codpos = v_codpos
               and b.codcours = v_codcours
               and ((b.dtestr between p_dtestrt and p_dteend)
                   or (b.dteend between p_dtestrt and p_dteend)
                   or (p_dtestrt between b.dtestr and b.dteend)
                   or (p_dteend between b.dtestr and b.dteend))
          order by a.codempid;
    begin
        obj_rows := json_object_t();
        for r1 in c1 loop
            v_codcours      := r1.codcours;
            v_codcomp       := r1.codcomp;
            v_codpos        := r1.codpos;
            v_qtyemp := 0;
            for r2 in c2 loop
                if secur_main.secur3(r1.codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    v_qtyemp       := v_qtyemp + 1;
                end if;
            end loop;

            if v_qtyemp > 0 then
                v_row       := v_row+1;
                obj_data    := json_object_t();
                obj_data.put('dteyear',p_dteyear);
                obj_data.put('codcate',r1.codcate);
                obj_data.put('codcomp',r1.codcomp);
                obj_data.put('codcours',r1.codcours);
                obj_data.put('codpos',r1.codpos);
                obj_data.put('plancond','1');
                obj_data.put('des_plancond',get_tlistval_name('STACOURS','1',global_v_lang));
                obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',r1.codcate,global_v_lang));
                obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('desc_stacours',get_tlistval_name('STACOURS','1',global_v_lang));
                obj_data.put('qtyemp',v_qtyemp);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if obj_rows.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TIDPPLAN');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_planidp;

    procedure get_planidp(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_planidp(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planidp;

    procedure gen_planidp_detail(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_qtyemp        number := 0;

        v_codcate       tidpplans.codcate%type;
        v_codcours      tidpplans.codcours%type;
        v_codcomp       tidpplan.codcomp%type;
        v_codpos        tidpplan.codpos%type;

        cursor c2 is
            select a.codempid, a.commtemp
              from tidpplan a,tidpplans b
             where a.dteyear = b.dteyear
               and a.codempid = b.codempid
               and a.dteyear = p_dteyear
               and a.codcomp = p_codcomp
               and a.codpos = p_codpos
               and b.codcours = p_codcours
               and ((b.dtestr between p_dtestrt and p_dteend)
                   or (b.dteend between p_dtestrt and p_dteend)
                   or (p_dtestrt between b.dtestr and b.dteend)
                   or (p_dteend between b.dtestr and b.dteend))
          order by a.codempid;
    begin
        obj_rows := json_object_t();

        for r2 in c2 loop
            if secur_main.secur3(p_codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('image',get_emp_img(r2.codempid));
                obj_data.put('codempid',r2.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r2.codempid,global_v_lang));
                obj_data.put('codcomp',p_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(p_codcomp,global_v_lang));
                obj_data.put('codpos',p_codpos);
                obj_data.put('desc_codpos',get_tpostn_name(p_codpos,global_v_lang));
                obj_data.put('stacours',get_tlistval_name('STACOURS',1,global_v_lang));
                obj_data.put('remark',r2.commtemp);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if obj_rows.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TIDPPLAN');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_planidp_detail;

    procedure get_planidp_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_planidp_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planidp_detail;

    procedure gen_planevaluation(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_qtyemp        number := 0;

        v_codcate       tidpplans.codcate%type;
        v_codcours      tidpplans.codcours%type;
        v_codcomp       tidpplan.codcomp%type;
        v_codpos        tidpplan.codpos%type;

        cursor c1 is
            select c.codcate,b.codcours,a.codcomp,a.codpos
              from temploy1 a,tapptrnf b,tcourse c
             where a.codempid = b.codempid
               and b.codcours = c.codcours
               and b.dteyreap = p_dteyreap
               and b.numtime = p_numtime
               and a.codcomp like p_codcompy||'%'
          group by c.codcate,b.codcours,a.codcomp,a.codpos
          order by c.codcate,b.codcours,a.codcomp,a.codpos;

        cursor c2 is
            select a.codempid
              from temploy1 a,tapptrnf b
             where a.codempid = b.codempid
               and b.dteyreap =  p_dteyreap
               and b.numtime = p_numtime
               and a.codcomp =  v_codcomp
               and a.codpos   = v_codpos
               and b.codcours   = v_codcours
          order by a.codempid;
    begin
        obj_rows := json_object_t();
        for r1 in c1 loop
            v_codcours      := r1.codcours;
            v_codcomp       := r1.codcomp;
            v_codpos        := r1.codpos;
            v_qtyemp := 0;
            for r2 in c2 loop
                if secur_main.secur3(r1.codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    v_qtyemp       := v_qtyemp + 1;
                end if;
            end loop;

            if v_qtyemp > 0 then
                v_row       := v_row+1;
                obj_data    := json_object_t();
                obj_data.put('dteyear',p_dteyear);
                obj_data.put('codcate',r1.codcate);
                obj_data.put('codcomp',r1.codcomp);
                obj_data.put('codcours',r1.codcours);
                obj_data.put('codpos',r1.codpos);
                obj_data.put('plancond','2');
                obj_data.put('des_plancond',get_tlistval_name('STACOURS','2',global_v_lang));
                obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',r1.codcate,global_v_lang));
                obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('desc_stacours',get_tlistval_name('STACOURS','2',global_v_lang));
                obj_data.put('qtyemp',v_qtyemp);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if obj_rows.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPTRNF');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_planevaluation;

    procedure get_planevaluation(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_planevaluation(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planevaluation;

    procedure gen_planevaluation_detail(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_qtyemp        number := 0;

        v_codcate       tidpplans.codcate%type;
        v_codcours      tidpplans.codcours%type;
        v_codcomp       tidpplan.codcomp%type;
        v_codpos        tidpplan.codpos%type;

        cursor c2 is
            select a.codempid
              from temploy1 a,tapptrnf b
             where a.codempid = b.codempid
               and b.dteyreap =  p_dteyreap
               and b.numtime = p_numtime
               and a.codcomp =  p_codcomp
               and a.codpos   = p_codpos
               and b.codcours   = p_codcours
          order by a.codempid;
    begin
        obj_rows := json_object_t();

        for r2 in c2 loop
            if secur_main.secur3(p_codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('image',get_emp_img(r2.codempid));
                obj_data.put('codempid',r2.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r2.codempid,global_v_lang));
                obj_data.put('codcomp',p_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(p_codcomp,global_v_lang));
                obj_data.put('codpos',p_codpos);
                obj_data.put('desc_codpos',get_tpostn_name(p_codpos,global_v_lang));
                obj_data.put('stacours',get_tlistval_name('STACOURS',2,global_v_lang));
                obj_data.put('remark','');
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if obj_rows.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TIDPPLAN');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_planevaluation_detail;

    procedure get_planevaluation_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_planevaluation_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planevaluation_detail;

    procedure gen_planBasic(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_qtyemp        number := 0;

        v_codcate       tidpplans.codcate%type;
        v_codcours      tidpplans.codcours%type;
        v_codcomp       tidpplan.codcomp%type;
        v_codpos        tidpplan.codpos%type;
        v_typemp        varchar2(1);
        v_qtyposst      tbasictp.qtyposst%type;
        v_rpt_numseq    number := 0;
        v_count_emp     number := 0;

        cursor c1 is
            select codcomp,codpos, 'N' as typemp
              from temploy1
             where codcomp like p_codcompy||'%'
               and staemp <> '9'
               and dteempmt between p_dteempmtst and p_dteempmtend
               and p_flgempnew = 'Y'
          group by codcomp,codpos
             union
            select codcomp,codpos, 'M' as typemp
              from ttmovemt
             where codcomp like p_codcompy||'%'
               and codcomp <> codcompt
               and codpos <> codposnow
               and staupd = 'C'
               and stapost2 = 0
               and dteeffec between p_dteeffecst and p_dteeffecend
               and p_flgempmove = 'Y'
          group by codcomp,codpos
          order by codcomp,codpos;

        cursor c2 is
            select codcomp, codpos,codcate, codcours, qtyposst, typemp
              from tbasictp
             where v_codcomp like codcomp||'%'
               and codpos = v_codpos
               and typemp = v_typemp
          order by codcate,codcours;

        cursor c3 is
            select codempid
              from temploy1
             where codcomp = v_codcomp
               and codpos = v_codpos
               and staemp <> '9'
               and dteempmt  between  p_dteempmtst and p_dteempmtend
               and months_between(sysdate,dteefpos)  >= v_qtyposst;

        cursor c4 is
            select b.codempid
              from ttmovemt b
             where b.codcomp = v_codcomp
               and b.codpos = v_codpos
               and b.codcomp <> codcompt
               and b.codpos <> codposnow
               and b.staupd = 'C'
               and stapost2 = 0
               and b.dteeffec  between  p_dteeffecst and p_dteeffecend
               and months_between(sysdate,b.dteeffec) >= v_qtyposst;

        cursor c5 is
            select codcate, codcours, codcomp, codpos, count(codempid) qtyemp
              from ( select distinct item1 codcate, item2 codcours, item3 codcomp, item4 codpos, item5 codempid
                       from ttemprpt
                      where codempid = global_v_codempid
                        and codapp = 'HRTR34EX1') basic
          group by codcate, codcours, codcomp, codpos
          order by codcate, codcours, codcomp, codpos;
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRTR34EX1';

        obj_rows := json_object_t();
        for r1 in c1 loop
            v_typemp        := r1.typemp;
            v_codcomp       := r1.codcomp;
            v_codpos        := r1.codpos;

            for r2 in c2 loop
                v_qtyemp        := 0;
                v_codcours      := r2.codcours;
                v_qtyposst      := r2.qtyposst;
                if v_typemp = 'N' then
                    for r3 in c3 loop
                        if secur_main.secur3(r1.codcomp,r3.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            v_rpt_numseq := v_rpt_numseq +1 ;
                            insert into ttemprpt(CODEMPID,CODAPP,NUMSEQ,item1,item2,item3,item4,item5)
                            values (global_v_codempid, 'HRTR34EX1',v_rpt_numseq,
                                    r2.codcate,r2.codcours,r1.codcomp,r1.codpos,r3.codempid );
                        end if;
                    end loop;
                end if;
                if v_typemp = 'M' then
                    for r4 in c4 loop
                        if secur_main.secur3(r1.codcomp,r4.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            v_rpt_numseq := v_rpt_numseq +1;
                            insert into ttemprpt(CODEMPID,CODAPP,NUMSEQ,item1,item2,item3,item4,item5)
                            values (global_v_codempid, 'HRTR34EX1',v_rpt_numseq,
                                    r2.codcate,r2.codcours,r1.codcomp,r1.codpos,r4.codempid );
                        end if;
                    end loop;
                end if;
            end loop;
        end loop;

        for r5 in c5 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('dteyear',p_dteyear);
            obj_data.put('codcate',r5.codcate);
            obj_data.put('codcomp',r5.codcomp);
            obj_data.put('codcours',r5.codcours);
            obj_data.put('codpos',r5.codpos);
            obj_data.put('plancond','3');
            obj_data.put('des_plancond',get_tlistval_name('STACOURS','3',global_v_lang));
            obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',r5.codcate,global_v_lang));
            obj_data.put('desc_codcomp',get_tcenter_name(r5.codcomp,global_v_lang));
            obj_data.put('desc_codcours',get_tcourse_name(r5.codcours,global_v_lang));
            obj_data.put('desc_codpos',get_tpostn_name(r5.codpos,global_v_lang));
            obj_data.put('desc_stacours',get_tlistval_name('STACOURS','3',global_v_lang));
            obj_data.put('qtyemp',r5.qtyemp);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        if obj_rows.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TBASICTP');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_planBasic;

    procedure get_planBasic(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_planBasic(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planBasic;

    procedure gen_planBasic_detail(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_qtyemp        number := 0;

        v_codcate       tidpplans.codcate%type;
        v_codcours      tidpplans.codcours%type;
        v_codcomp       tidpplan.codcomp%type;
        v_codpos        tidpplan.codpos%type;
        v_typemp        varchar2(1);
        v_qtyposst      tbasictp.qtyposst%type;
        v_rpt_numseq    number := 0;
        v_count_emp     number := 0;

        cursor c1 is
            select codcomp,codpos, 'N' as typemp
              from temploy1
             where codcomp like p_codcompy||'%'
               and staemp <> '9'
               and dteempmt between p_dteempmtst and p_dteempmtend
               and p_flgempnew = 'Y'
               and codcomp = p_codcomp
               and codpos = p_codpos
          group by codcomp,codpos
             union
            select codcomp,codpos, 'M' as typemp
              from ttmovemt
             where codcomp like p_codcompy||'%'
               and codcomp <> codcompt
               and codpos <> codposnow
               and staupd = 'C'
               and stapost2 = 0
               and dteeffec between p_dteeffecst and p_dteeffecend
               and p_flgempmove = 'Y'
               and codcomp = p_codcomp
               and codpos = p_codpos
          group by codcomp,codpos
          order by codcomp,codpos;

        cursor c2 is
            select codcomp, codpos,codcate, codcours, qtyposst, typemp
              from tbasictp
             where v_codcomp like codcomp||'%'
               and codpos = v_codpos
               and typemp = v_typemp
               and codcours = p_codcours
          order by codcate,codcours;

        cursor c3 is
            select codempid
              from temploy1
             where codcomp = v_codcomp
               and codpos = v_codpos
               and staemp <> '9'
               and dteempmt  between  p_dteempmtst and p_dteempmtend
               and months_between(sysdate,dteefpos)  >= v_qtyposst;

        cursor c4 is
            select b.codempid
              from ttmovemt b
             where b.codcomp = v_codcomp
               and b.codpos = v_codpos
               and b.codcomp <> codcompt
               and b.codpos <> codposnow
               and b.staupd = 'C'
               and stapost2 = 0
               and b.dteeffec  between  p_dteeffecst and p_dteeffecend
               and months_between(sysdate,b.dteeffec) >= v_qtyposst;

        cursor c5 is
            select distinct item1 codcate, item2 codcours, item3 codcomp, item4 codpos, item5 codempid
              from ttemprpt
             where codempid = global_v_codempid
               and codapp = 'HRTR34EX1'
          order by codempid;
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRTR34EX1';
        commit;
        obj_rows := json_object_t();
        for r1 in c1 loop
            v_typemp        := r1.typemp;
            v_codcomp       := r1.codcomp;
            v_codpos        := r1.codpos;

            for r2 in c2 loop
                v_qtyemp        := 0;
                v_codcours      := r2.codcours;
                v_qtyposst      := r2.qtyposst;
                if v_typemp = 'N' then
                    for r3 in c3 loop
                        if secur_main.secur3(r1.codcomp,r3.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            v_rpt_numseq := v_rpt_numseq +1 ;
                            insert into ttemprpt(CODEMPID,CODAPP,NUMSEQ,item1,item2,item3,item4,item5)
                            values (global_v_codempid, 'HRTR34EX1',v_rpt_numseq,
                                    r2.codcate,r2.codcours,r1.codcomp,r1.codpos,r3.codempid );
                        end if;
                    end loop;
                end if;
                if v_typemp = 'M' then
                    for r4 in c4 loop
                        if secur_main.secur3(r1.codcomp,r4.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            v_rpt_numseq := v_rpt_numseq +1;
                            insert into ttemprpt(CODEMPID,CODAPP,NUMSEQ,item1,item2,item3,item4,item5)
                            values (global_v_codempid, 'HRTR34EX1',v_rpt_numseq,
                                    r2.codcate,r2.codcours,r1.codcomp,r1.codpos,r4.codempid );
                        end if;
                    end loop;
                end if;
            end loop;
        end loop;

        for r5 in c5 loop
            v_row       := v_row+1;
            obj_data    := json_object_t();
            obj_data.put('image',get_emp_img(r5.codempid));
            obj_data.put('codempid',r5.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r5.codempid,global_v_lang));
            obj_data.put('codcomp',r5.codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(r5.codcomp,global_v_lang));
            obj_data.put('codpos',r5.codpos);
            obj_data.put('desc_codpos',get_tpostn_name(r5.codpos,global_v_lang));
            obj_data.put('stacours',get_tlistval_name('STACOURS',3,global_v_lang));
            obj_data.put('remark','');
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        if obj_rows.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TBASICTP');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_planBasic_detail;

    procedure get_planBasic_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_planBasic_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planBasic_detail;

    procedure gen_plansurvey(json_str_output out clob) as
        obj_main        json_object_t;
        obj_general     json_object_t;
        obj_competency  json_object_t;
        obj_training    json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_qtyemp        number := 0;

        v_codcate       ttrneedg.codcate%type;
        v_codcours      ttrneedg.codcours%type;
        v_codcomp       ttrneedg.codcomp%type;
        v_codpos        ttrneedgd.codpos%type;
        v_codskill      ttrneedcc.codskill%type;
        v_grade         ttrneedcc.grade%type;
        v_codtency      tjobposskil.codtency%type;
        v_numseq        ttrneedp.numseq%type;

        cursor c1 is
            select a.codcate,a.codcours,b.codcomp,b.codpos
              from ttrneedg a, ttrneedgd b
             where a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.codcours = b.codcours
               and a.dteyear = p_dteyear
               and a.codcomp like p_codcompy||'%'
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A' ))
          group by a.codcate,a.codcours,b.codcomp,b.codpos
          order by a.codcate,a.codcours,b.codcomp,b.codpos;

        cursor c2 is
            select codempid
              from ttrneedg a, ttrneedgd b
             where a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.codcours = b.codcours
               and a.dteyear = p_dteyear
               and a.codcomp = v_codcomp
               and codpos = v_codpos
               and a.codcours = v_codcours
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A' ))
          order by codempid;

        cursor c3 is
            select a.codskill, a.codcours, c.codcompc, c.codpos, a.grade
              from ttrneedcc a ,ttrneedcd c
             where a.dteyear = c.dteyear
               and a.codpos = c.codpos
               and a.codskill = c.codskill
               and a.grade = c.grade
               and a.codcompc = c.codcompc
               and a.dteyear = p_dteyear
               and a.codcompc like p_codcompy ||'%'
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A'))
          group by a.codskill, a.codcours, c.codcompc, c.codpos, a.grade
          order by codskill, codcours, codcompc, codpos, grade;

        cursor c4 is
            select c.codempid
              from ttrneedcc a ,ttrneedcd c
             where a.dteyear = c.dteyear
               and a.codpos = c.codpos
               and a.codskill = c.codskill
               and a.grade = c.grade
               and a.codcompc = c.codcompc
               and a.dteyear = p_dteyear
               and a.codcompc = v_codcomp
               and c.codpos = v_codpos
               and a.codcours = v_codcours
               and a.codskill = v_codskill
               and a.grade = v_grade
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A'))
          order by codempid;

        cursor c5 is
            select codcate,codcomp,numseq,descoures,codcours
              from ttrneedp
             where dteyear = p_dteyear
               and codcomp like p_codcompy||'%'
          order by codcomp,numseq;

        cursor c6 is
            select b.codempid
              from ttrneedp a, ttrneedpd b
             where b.codempid = b.codempid
               and a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.numseq = b.numseq
               and a.dteyear = p_dteyear
               and a.codcomp = v_codcomp
               and a.numseq = v_numseq
               and nvl(a.codcours,'xxxx') = nvl(v_codcours,'xxxx')
          order by codempid;
    begin
        obj_main            := json_object_t();
        obj_general         := json_object_t();
        obj_competency      := json_object_t();
        obj_training        := json_object_t();
        for r1 in c1 loop
            v_codcomp       := r1.codcomp;
            v_codpos        := r1.codpos;
            v_codcours      := r1.codcours;
            v_qtyemp        := 0;

            for r2 in c2 loop
                if secur_main.secur3(r1.codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    v_qtyemp := v_qtyemp +1;
                end if;
            end loop;

            if v_qtyemp > 0 then
                v_row       := v_row+1;
                obj_data    := json_object_t();
                obj_data.put('dteyear',p_dteyear);
                obj_data.put('codcate',r1.codcate);
                obj_data.put('codcomp',r1.codcomp);
                obj_data.put('codcours',r1.codcours);
                obj_data.put('codpos',r1.codpos);
                obj_data.put('plancond','4');
                obj_data.put('des_plancond',get_tlistval_name('STACOURS','4',global_v_lang));
                obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',r1.codcate,global_v_lang));
                obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('desc_stacours',get_tlistval_name('STACOURS','4',global_v_lang));
                obj_data.put('qtyemp',v_qtyemp);
                obj_general.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

        if obj_general.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRNEEDG');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        v_row   := 0;
        for r3 in c3 loop
            v_codcomp       := r3.codcompc;
            v_codpos        := r3.codpos;
            v_codcours      := r3.codcours;
            v_codskill      := r3.codskill;
            v_grade         := r3.grade;
            v_qtyemp        := 0;

            begin
                select distinct codcate  into v_codcate
                  from tcourse
                 where codcours  =  v_codcours;
            exception when no_data_found then
                v_codcate := null;
            end;

            begin
                select codtency into v_codtency
                  from tjobposskil
                 where codpos = v_codpos
                   and codcomp = v_codcomp
                   and codskill = v_codskill;
            exception when no_data_found then
                v_codtency := null;
            end;

            for r4 in c4 loop
                if secur_main.secur3(r3.codcompc,r4.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    v_qtyemp := v_qtyemp +1;
                end if;
            end loop;

            if v_qtyemp > 0 then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('codskill',v_codskill);
                obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',v_codskill,global_v_lang));
                obj_data.put('codtency',v_codtency);
                obj_data.put('desc_codtency',get_tcomptnc_name(v_codtency,global_v_lang));
                obj_data.put('codcours',v_codcours);
                obj_data.put('desc_codcours',get_tcourse_name(v_codcours,global_v_lang));
                obj_data.put('codcomp',v_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
                obj_data.put('codpos',v_codpos);
                obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
                obj_data.put('grade',v_grade);
                obj_data.put('qtyemp',v_qtyemp);
                obj_data.put('codcate',v_codcate);
                obj_data.put('plancond','4');
                obj_data.put('dteyear',p_dteyear);
                obj_competency.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

        if obj_competency.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRNEEDCC');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        v_row   := 0;
        for r5 in c5 loop
            v_codcomp       := r5.codcomp;
            v_numseq        := r5.numseq;
            v_codcours      := r5.codcours;
            v_qtyemp        := 0;

            for r6 in c6 loop
                if secur_main.secur3(r5.codcomp,r6.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    v_qtyemp := v_qtyemp +1;
                end if;
            end loop;

            if v_qtyemp > 0 then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('codcomp',v_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
                obj_data.put('numseq',v_numseq);
                obj_data.put('descoures',r5.descoures);
                obj_data.put('codcours',v_codcours);
                obj_data.put('desc_codcours',get_tcourse_name(v_codcours,global_v_lang));
                obj_data.put('qtyemp',v_qtyemp);
                obj_data.put('dteyear',p_dteyear);
                obj_training.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

        if obj_training.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRNEEDP');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        obj_main.put('coderror',200);
        obj_main.put('general',obj_general);
        obj_main.put('competency',obj_competency);
        obj_main.put('training',obj_training);

        json_str_output := obj_main.to_clob;
    end gen_plansurvey;

    procedure get_plansurvey(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_plansurvey(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_plansurvey;

    procedure gen_plansurvey_general(json_str_output out clob) as
        obj_general     json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;

        cursor c1 is
            select codempid,a.remark
              from ttrneedg a, ttrneedgd b
             where a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.codcours = b.codcours
               and a.dteyear = p_dteyear
               and a.codcomp = p_codcomp
               and codpos = p_codpos
               and a.codcours = p_codcours
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A' ))
          order by codempid;
    begin
        obj_general         := json_object_t();

        for r1 in c1 loop
            if secur_main.secur3(p_codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('codcomp',p_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(p_codcomp,global_v_lang));
                obj_data.put('codpos',p_codpos);
                obj_data.put('desc_codpos',get_tpostn_name(p_codpos,global_v_lang));
                obj_data.put('stacours',get_tlistval_name('STACOURS',4,global_v_lang));
                obj_data.put('remark',r1.remark);
                obj_general.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

        if obj_general.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRNEEDG');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        json_str_output := obj_general.to_clob;
    end gen_plansurvey_general;

    procedure get_plansurvey_general(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_plansurvey_general(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_plansurvey_general;

    procedure gen_plansurvey_competency(json_str_output out clob) as
        obj_competency     json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;

        cursor c1 is
            select c.codempid
              from ttrneedcc a ,ttrneedcd c
             where a.dteyear = c.dteyear
               and a.codpos = c.codpos
               and a.codskill = c.codskill
               and a.grade = c.grade
               and a.codcompc = c.codcompc
               and a.dteyear = p_dteyear
               and a.codcompc = p_codcomp
               and c.codpos = p_codpos
               and a.codcours = p_codcours
               and a.codskill = p_codskill
               and a.grade = p_grade
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A'))
          order by codempid;
    begin
        obj_competency         := json_object_t();

        for r1 in c1 loop
            if secur_main.secur3(p_codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('codcomp',p_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(p_codcomp,global_v_lang));
                obj_data.put('codpos',p_codpos);
                obj_data.put('desc_codpos',get_tpostn_name(p_codpos,global_v_lang));
                obj_data.put('stacours',get_tlistval_name('STACOURS',4,global_v_lang));
                obj_data.put('remark','');
                obj_competency.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

        if obj_competency.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRNEEDG');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        json_str_output := obj_competency.to_clob;
    end gen_plansurvey_competency;

    procedure get_plansurvey_competency(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_plansurvey_competency(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_plansurvey_competency;

    procedure gen_plansurvey_training(json_str_output out clob) as
        obj_training     json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;

        cursor c1 is
            select b.codempid,b.codpos
              from ttrneedp a, ttrneedpd b
             where b.codempid = b.codempid
               and a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.numseq = b.numseq
               and a.dteyear = p_dteyear
               and a.codcomp = p_codcomp
               and a.numseq = p_numseq
               and nvl(a.codcours,'xxxx') = nvl(p_codcours,'xxxx')
          order by codempid;
    begin
        obj_training         := json_object_t();

        for r1 in c1 loop
            if secur_main.secur3(p_codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('codcomp',p_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(p_codcomp,global_v_lang));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('stacours',get_tlistval_name('STACOURS',4,global_v_lang));
                obj_data.put('remark','');
                obj_training.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

        if obj_training.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRNEEDG');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_training.to_clob;
    end gen_plansurvey_training;

    procedure get_plansurvey_training(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_plansurvey_training(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_plansurvey_training;

   procedure get_planSurvey_summarycourse(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_table           json_object_t;
        obj_row             json_object_t;
        obj_result          json_object_t;
        v_codcate           tcourse.codcate%type;
        obj_training        json_object_t;
        obj_data            json_object_t;
        obj_training_main   json_object_t;

        v_row           number := 0;
        v_qtyemp        number := 0;
        v_codcours      ttrneedg.codcours%type;
        v_numseq        ttrneedp.numseq%type;
        v_codcomp       ttrneedg.codcomp%type;
        v_count_total   number := 0;

        cursor c1 is
            select codcate,codcours,codcomp,numseq
              from ttrneedp
             where dteyear = p_dteyear
               and codcomp like p_codcompy||'%'
               and codcours is not null
          order by codcate,numseq,codcours;

        cursor c2 is
            select b.codempid
              from ttrneedp a, ttrneedpd b
             where b.codempid = b.codempid
               and a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.numseq = b.numseq
               and a.dteyear = p_dteyear
               and a.codcomp = v_codcomp
               and a.numseq = v_numseq
               and a.codcours = v_codcours
          order by codempid;

        cursor c5 is
            select codcate,codcomp,numseq,descoures,codcours
              from ttrneedp
             where dteyear = p_dteyear
               and codcomp like p_codcompy||'%'
          order by codcomp,numseq;

        cursor c6 is
            select b.codempid
              from ttrneedp a, ttrneedpd b
             where b.codempid = b.codempid
               and a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.numseq = b.numseq
               and a.dteyear = p_dteyear
               and a.codcomp = v_codcomp
               and a.numseq = v_numseq
               and nvl(a.codcours,'xxxx') = nvl(v_codcours,'xxxx')
          order by codempid;
    begin
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);
        obj_table           := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'table'),'rows');
        obj_training        := json_object_t();
        obj_training_main   := json_object_t();

        for i in 0..obj_table.get_size-1 loop
            obj_row                 := hcm_util.get_json_t(obj_table,to_char(i));
            p_codcomp               := hcm_util.get_string_t(obj_row,'codcomp');
            p_numseq                := hcm_util.get_string_t(obj_row,'numseq');
            p_codcours              := hcm_util.get_string_t(obj_row,'codcours');

            begin
                select codcate  into v_codcate
                  from tcourse
                 where codcours  =  p_codcours;
            exception when no_data_found then
                v_codcate := null;
            end;

            update ttrneedp
               set codcours = p_codcours,
                   codcate = v_codcate
             where dteyear = p_dteyear
               and codcomp = p_codcomp
               and numseq = p_numseq;
        end loop;

        obj_result      := json_object_t();
        if param_msg_error is null then
            commit;
            for r1 in c1 loop
                v_codcomp       := r1.codcomp;
                v_numseq        := r1.numseq;
                v_codcours      := r1.codcours;
                v_qtyemp        := 0;

                for r2 in c2 loop
                    if secur_main.secur3(r1.codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                        v_qtyemp := v_qtyemp +1;
                        v_count_total := v_count_total + 1;
                    end if;
                end loop;
                if v_qtyemp > 0 then
                    v_row       := v_row+1;
                    obj_data    := json_object_t();
                    obj_data.put('numseq',r1.numseq);
                    obj_data.put('codcate',r1.codcate);
                    obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',r1.codcate,global_v_lang));
                    obj_data.put('codcours',r1.codcours);
                    obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
                    obj_data.put('codcomp',r1.codcomp);
                    obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
                    obj_data.put('qtyemp',v_qtyemp);
                    obj_data.put('plancond',4);
                    obj_training.put(to_char(v_row-1),obj_data);
                end if;
            end loop;

            v_row   := 0;
            for r5 in c5 loop
                v_codcomp       := r5.codcomp;
                v_numseq        := r5.numseq;
                v_codcours      := r5.codcours;
                v_qtyemp        := 0;

                for r6 in c6 loop
                    if secur_main.secur3(r5.codcomp,r6.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                        v_qtyemp := v_qtyemp +1;
                    end if;
                end loop;

                if v_qtyemp > 0 then
                    v_row       := v_row+1;
                    obj_data    := json_object_t();

                    obj_data.put('codcomp',v_codcomp);
                    obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
                    obj_data.put('numseq',v_numseq);
                    obj_data.put('descoures',r5.descoures);
                    obj_data.put('codcours',v_codcours);
                    obj_data.put('codcoursOld',v_codcours);
                    obj_data.put('qtyemp',v_qtyemp);
                    obj_training_main.put(to_char(v_row-1),obj_data);
                end if;
            end loop;

            obj_result.put('coderror',200);
            obj_result.put('response',replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201'));
            obj_result.put('qtyemp',v_count_total);
            obj_result.put('table',obj_training);
            obj_result.put('tabelTraining',obj_training_main);
            json_str_output := obj_result.to_clob;
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planSurvey_summarycourse;

    procedure gen_planSurvey_summarycourse_detail(json_str_output out clob) as
        obj_training     json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;

        cursor c1 is
            select b.codempid,b.codpos
              from ttrneedp a, ttrneedpd b
             where b.codempid = b.codempid
               and a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.numseq = b.numseq
               and a.dteyear = p_dteyear
               and a.codcomp = p_codcomp
               and a.numseq = p_numseq
               and a.codcours = p_codcours
          order by codempid;
    begin
        obj_training         := json_object_t();

        for r1 in c1 loop
            if secur_main.secur3(p_codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                v_row       := v_row+1;
                obj_data    := json_object_t();

                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('codcomp',p_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(p_codcomp,global_v_lang));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('stacours',get_tlistval_name('STACOURS',4,global_v_lang));
                obj_data.put('remark','');
                obj_training.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

        if obj_training.get_size = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRNEEDG');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := obj_training.to_clob;
    end gen_planSurvey_summarycourse_detail;

    procedure get_planSurvey_summarycourse_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_planSurvey_summarycourse_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_planSurvey_summarycourse_detail;

   procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_detail          json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        obj_table           json_object_t;
        obj_syncond         json_object_t;
        json_emp            json_object_t;
        v_flgedit           varchar2(10 char);
        v_plancond          tyrtrpln.plancond%type;
        v_syncond           tyrtrpln.syncond%type;
        v_statement         tyrtrpln.statement%type;
        v_typcon            tyrtrpln.typcon%type;
        v_typtrain          tyrtrpln.typtrain%type;
        v_codhotel          tyrtrpln.codhotel%type;
        v_codinsts          tyrtrpln.codinsts%type;
        v_qtynumcl          tyrtrpln.qtynumcl%type;
        v_qtyptbdg          tyrtrpln.qtyptbdg%type;
        v_amtpbdg           tyrtrpln.amtpbdg%type;
        v_amtclbdg          tyrtrpln.amtclbdg%type;
        v_amttot            tyrtrpln.amttot%type;
        v_qtyptpln          tyrtrpln.qtyptpln%type;
        v_codrespn          tyrtrpln.codrespn%type;
        v_remark            tyrtrpln.remark%type;
        v_codtparg          tyrtrpln.codtparg%type;
        p_check             varchar2(6);
        chk_approve         boolean;
        v_approvno          number;
        v_codcate           tcourse.codcate%type;
        v_ttpotent          ttpotent%rowtype;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        obj_detail      := hcm_util.get_json_t(json_obj,'detail');
        obj_tab1        := hcm_util.get_json_t(obj_detail,'tab1');
        obj_tab2        := hcm_util.get_json_t(obj_detail,'tab2');
        obj_table       := hcm_util.get_json_t(hcm_util.get_json_t(obj_tab2,'table'),'rows');

        p_dteyear       := hcm_util.get_string_t(hcm_util.get_json_t(json_obj,'searchParam'),'dteyear');
        p_codcompy      := hcm_util.get_string_t(hcm_util.get_json_t(json_obj,'searchParam'),'codcompy');
        p_codcours      := hcm_util.get_string_t(hcm_util.get_json_t(json_obj,'searchParam'),'codcours');

--        CODCATE
        v_codtparg      := hcm_util.get_string_t(obj_tab1,'codtparg');
        v_plancond      := hcm_util.get_string_t(obj_tab1,'plancond');
        v_typcon        := hcm_util.get_string_t(obj_tab1,'typcon');
        obj_syncond     := hcm_util.get_json_t(obj_tab1,'syncond');
        v_syncond       := hcm_util.get_string_t(obj_syncond,'code');
        v_statement     := hcm_util.get_string_t(obj_syncond,'statement');
        v_typtrain      := hcm_util.get_string_t(obj_tab1,'typtrain');
        v_codhotel      := hcm_util.get_string_t(obj_tab1,'codhotel');
        v_codinsts      := hcm_util.get_string_t(obj_tab1,'codinsts');
        v_qtynumcl      := hcm_util.get_string_t(obj_tab1,'qtynumcl');
        v_qtyptbdg      := hcm_util.get_string_t(obj_tab1,'qtyptbdg');
        v_amtpbdg       := hcm_util.get_string_t(obj_tab1,'amtpbdg');
        v_amtclbdg      := hcm_util.get_string_t(obj_tab1,'amtclbdg');
        v_amttot        := hcm_util.get_string_t(obj_tab1,'amttot');
--        v_qtyptpln      := hcm_util.get_string_t(obj_tab1,'qtyptpln');
        v_qtyptpln      := obj_table.get_size();
        v_codrespn      := hcm_util.get_string_t(obj_tab1,'codrespn');

        v_remark        := hcm_util.get_string_t(obj_tab1,'remark');
        v_flgedit       := hcm_util.get_string_t(obj_tab1,'flgedit');

        if(v_codtparg = '2')then
           if( v_amtpbdg is null ) or ( v_amtclbdg is null ) or (v_amttot is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
           end if;
        end if; -- check save detail

        chk_approve := chk_flowmail.check_approve( 'HRTR34E',v_codrespn,v_approvno,v_codrespn ,null, null, p_check);
        if p_check ='HR2010' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tfwmailc');
        end if;

        if param_msg_error is null then
            begin
                begin
                    select codcate into v_codcate
                      from tcourse
                     where codcours = p_codcours;
                exception when no_data_found then
                    v_codcate := null;
                end;
                insert into tyrtrpln (dteyear,codcompy,codcours,plancond,syncond,statement,
                                      codcate,typcon,typtrain,codhotel,codinsts,
                                      qtynumcl,qtyptbdg,amtpbdg,amtclbdg,
                                      amttot,qtyptpln,codrespn,remark,codtparg,staappr,
                                      dtecreate,codcreate,dteupd,coduser)
                         values (p_dteyear,p_codcompy,p_codcours,v_plancond,v_syncond,v_statement,
                                 v_codcate,v_typcon,v_typtrain,v_codhotel,v_codinsts,
                                 v_qtynumcl,v_qtyptbdg,v_amtpbdg,v_amtclbdg,
                                 v_amttot,v_qtyptpln,v_codrespn,v_remark,v_codtparg,'P',
                                 sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tyrtrpln
                   set plancond = v_plancond,
                       syncond = v_syncond,
                       statement = v_statement,
                       typcon = v_typcon,
                       typtrain = v_typtrain,
                       codhotel = v_codhotel,
                       codinsts = v_codinsts,
                       qtynumcl = v_qtynumcl,
                       qtyptbdg = v_qtyptbdg,
                       amtpbdg = v_amtpbdg,
                       amtclbdg = v_amtclbdg,
                       codtparg = v_codtparg,
                       amttot = v_amttot,
                       qtyptpln = v_qtyptpln,
                       codrespn = v_codrespn,
                       remark = v_remark,
                       staappr = 'P',
                       dteupd = sysdate,
                       coduser = global_v_coduser,
                       remarkap = null
                 where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codcours = p_codcours;
            end;

            if(obj_table.get_size() > 0) then
                begin
                    delete ttpotent
                     where dteyear = p_dteyear
                       and codcompy = p_codcompy
                       and codcours = p_codcours;
                end;

                for i in 0..obj_table.get_size-1 loop
                    json_emp                := hcm_util.get_json_t(obj_table,to_char(i));

                    v_ttpotent.codempid     := hcm_util.get_string_t(json_emp,'codempid');
                    v_ttpotent.codcomp      := hcm_util.get_string_t(json_emp,'codcomp');
                    v_ttpotent.codpos       := hcm_util.get_string_t(json_emp,'codpos');
                    v_ttpotent.stacours     := hcm_util.get_string_t(json_emp,'stacours');
                    v_ttpotent.flgclass     := 'N';
                    v_ttpotent.remark       := hcm_util.get_string_t(json_emp,'remark');
                    begin
                        select numlvl
                          into v_ttpotent.numlvl
                          from temploy1
                         where codempid = v_ttpotent.codempid;
                    exception when no_data_found then
                        v_ttpotent.numlvl := null;
                    end;
                    begin
                        insert into ttpotent (dteyear,codcompy,codcours,codempid,codcomp,codpos,
                                              stacours,flgclass,numlvl,remark,
                                              dtecreate,codcreate,dteupd,coduser)
                             values (p_dteyear,p_codcompy,p_codcours,v_ttpotent.codempid,v_ttpotent.codcomp,v_ttpotent.codpos,
                                     v_ttpotent.stacours,v_ttpotent.flgclass,v_ttpotent.numlvl,v_ttpotent.remark,
                                     sysdate,global_v_coduser,sysdate,global_v_coduser);
                    exception when dup_val_on_index then
                        null;
                    end;
                end loop;
            end if;

            select count(codempid)
              into v_qtyptpln
              from ttpotent
              where dteyear = p_dteyear
              and codcompy = p_codcompy
              and codcours = p_codcours;

            v_amttot :=  round(nvl(v_qtyptpln,0) * v_qtyptbdg,0);

            update tyrtrpln
               set qtyptbdg = v_qtyptbdg,
                   qtyptpln = v_qtyptpln,
                   amttot = v_amttot,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours;
        end if;
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
    end save_detail;

   procedure save_plan(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        json_row            json_object_t;
        obj_detail          json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        obj_table           json_object_t;
        obj_syncond         json_object_t;
        json_emp            json_object_t;
        v_flgedit           varchar2(10 char);
        v_plancond          tyrtrpln.plancond%type;
        v_syncond           tyrtrpln.syncond%type;
        v_statement         tyrtrpln.statement%type;
        v_typcon            tyrtrpln.typcon%type;
        v_typtrain          tyrtrpln.typtrain%type;
        v_codhotel          tyrtrpln.codhotel%type;
        v_codinsts          tyrtrpln.codinsts%type;
        v_qtynumcl          tyrtrpln.qtynumcl%type;
        v_qtyptbdg          tyrtrpln.qtyptbdg%type;
        v_amtpbdg           tyrtrpln.amtpbdg%type;
        v_amtclbdg          tyrtrpln.amtclbdg%type;
        v_amttot            tyrtrpln.amttot%type;
        v_qtyptpln          tyrtrpln.qtyptpln%type;
        v_codrespn          tyrtrpln.codrespn%type;
        v_remark            tyrtrpln.remark%type;
        v_codtparg          tyrtrpln.codtparg%type;
        p_check             varchar2(6);
        chk_approve         boolean;
        v_approvno          number;
        v_codcate           tcourse.codcate%type;
        v_ttpotent          ttpotent%rowtype;
        v_count_tyrtrpln    number;
        searchParams        json_object_t;
        v_dteyear           tyrtrpln.dteyear%type;

        v_typemp            varchar2(1);
        v_codcomp           tidpplan.codcomp%type;
        v_codpos            tidpplan.codpos%type;
        v_qtyposst          tbasictp.qtyposst%type;

        cursor c1 is
            select a.codempid, a.commtemp
              from tidpplan a,tidpplans b
             where a.dteyear = b.dteyear
               and a.codempid = b.codempid
               and a.dteyear = p_dteyear
               and a.codcomp = p_codcomp
               and a.codpos = p_codpos
               and b.codcours = p_codcours
               and ((b.dtestr between p_dtestrt and p_dteend)
                   or (b.dteend between p_dtestrt and p_dteend)
                   or (p_dtestrt between b.dtestr and b.dteend)
                   or (p_dteend between b.dtestr and b.dteend))
          order by a.codempid;

        cursor c2 is
            select a.codempid
              from temploy1 a,tapptrnf b
             where a.codempid = b.codempid
               and b.dteyreap = p_dteyreap
               and b.numtime = p_numtime
               and a.codcomp =  p_codcomp
               and a.codpos = p_codpos
               and b.codcours = p_codcours
          order by a.codempid;

        cursor c3 is
            select codcomp,codpos, 'N' as typemp
              from temploy1
             where codcomp like p_codcompy||'%'
               and staemp <> '9'
               and dteempmt between p_dteempmtst and p_dteempmtend
               and p_flgempnew = 'Y'
               and codcomp = p_codcomp
               and codpos = p_codpos
          group by codcomp,codpos
             union
            select codcomp,codpos, 'M' as typemp
              from ttmovemt
             where codcomp like p_codcompy||'%'
               and codcomp <> codcompt
               and codpos <> codposnow
               and staupd = 'C'
               and stapost2 = 0
               and dteeffec between p_dteeffecst and p_dteeffecend
               and p_flgempmove = 'Y'
               and codcomp = p_codcomp
               and codpos = p_codpos
          group by codcomp,codpos
          order by codcomp,codpos;

        cursor c4 is
            select codcomp, codpos,codcate, codcours, qtyposst, typemp
              from tbasictp
             where v_codcomp like codcomp||'%'
               and codpos = v_codpos
               and typemp = v_typemp
               and codcours = p_codcours
          order by codcate,codcours;

        cursor c5 is
            select codempid
              from temploy1
             where codcomp = v_codcomp
               and codpos = v_codpos
               and staemp <> '9'
               and dteempmt  between  p_dteempmtst and p_dteempmtend
               and months_between(sysdate,dteefpos)  >= v_qtyposst;

        cursor c6 is
            select b.codempid
              from ttmovemt b
             where b.codcomp = v_codcomp
               and b.codpos = v_codpos
               and b.codcomp <> codcompt
               and b.codpos <> codposnow
               and b.staupd = 'C'
               and stapost2 = 0
               and b.dteeffec  between  p_dteeffecst and p_dteeffecend
               and months_between(sysdate,b.dteeffec) >= v_qtyposst;

        cursor c7 is
            select codempid,a.remark
              from ttrneedg a, ttrneedgd b
             where a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.codcours = b.codcours
               and a.dteyear = p_dteyear
               and a.codcomp = p_codcomp
               and codpos = p_codpos
               and a.codcours = p_codcours
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A' ))
          order by codempid;

        cursor c8 is
            select c.codempid
              from ttrneedcc a ,ttrneedcd c
             where a.dteyear = c.dteyear
               and a.codpos = c.codpos
               and a.codskill = c.codskill
               and a.grade = c.grade
               and a.codcompc = c.codcompc
               and a.dteyear = p_dteyear
               and a.codcompc = p_codcomp
               and c.codpos = p_codpos
               and a.codcours = p_codcours
               and a.codskill = p_codskill
               and a.grade = p_grade
               and ((a.flgprior = p_flgprior)
                     or ( p_flgprior = 'A'))
          order by codempid;

        cursor c9 is
            select b.codempid,b.codpos
              from ttrneedp a, ttrneedpd b
             where b.codempid = b.codempid
               and a.dteyear = b.dteyear
               and a.codcomp = b.codcomp
               and a.numseq = b.numseq
               and a.dteyear = p_dteyear
               and a.codcomp = p_codcomp
               and a.numseq = p_numseq
               and a.codcours = p_codcours
          order by codempid;

          v_staappr  tyrtrpln.staappr%type;

    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        searchParams    := hcm_util.get_json_t(json_obj,'searchParams');
        p_dteyear       := hcm_util.get_string_t(searchParams,'dteyear');
        p_codcompy      := hcm_util.get_string_t(searchParams,'codcompy');
        p_dtestrt       := to_date(hcm_util.get_string_t(searchParams,'dtestrt'),'dd/mm/yyyy');
        p_dteend        := to_date(hcm_util.get_string_t(searchParams,'dteend'),'dd/mm/yyyy');

        p_dteyreap      := hcm_util.get_string_t(searchParams,'dteyreap');
        p_numtime       := hcm_util.get_string_t(searchParams,'numtime');
        p_flgprior      := hcm_util.get_string_t(searchParams,'flgprior');

        p_flgempnew     := hcm_util.get_string_t(searchParams,'flgempnew');
        p_flgempmove    := hcm_util.get_string_t(searchParams,'flgempmove');
        p_dteempmtst    := to_date(hcm_util.get_string_t(searchParams,'dteempmtst'),'dd/mm/yyyy');
        p_dteempmtend   := to_date(hcm_util.get_string_t(searchParams,'dteempmtend'),'dd/mm/yyyy');
        p_dteeffecst    := to_date(hcm_util.get_string_t(searchParams,'dteeffecst'),'dd/mm/yyyy');
        p_dteeffecend   := to_date(hcm_util.get_string_t(searchParams,'dteeffecend'),'dd/mm/yyyy');

        p_flgTab        := hcm_util.get_string_t(searchParams,'flgtab');

        obj_table       := hcm_util.get_json_t(json_obj,'param_json');

        for i in 0..obj_table.get_size-1 loop
            json_row    := hcm_util.get_json_t(obj_table,to_char(i));
            p_codcours  := hcm_util.get_string_t(json_row,'codcours');
            p_codcomp   := hcm_util.get_string_t(json_row,'codcomp');
            p_codpos    := hcm_util.get_string_t(json_row,'codpos');
            v_plancond  := hcm_util.get_string_t(json_row,'plancond');
            p_codskill  := hcm_util.get_string_t(json_row,'codskill');
            p_grade     := hcm_util.get_string_t(json_row,'grade');
            p_numseq    := hcm_util.get_string_t(json_row,'numseq');

            begin
                select count(*)
                  into v_count_tyrtrpln
                  from tyrtrpln
                 where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codcours = p_codcours;
            exception when others then
                v_count_tyrtrpln := 0;
            end;

            if v_count_tyrtrpln > 0 then
                begin
                    select staappr
                      into v_staappr
                      from tyrtrpln
                     where dteyear = p_dteyear
                       and codcompy = p_codcompy
                       and codcours = p_codcours;
                exception when others then
                    v_staappr := 'P';
                end;

                if v_staappr <> 'P' then
                    param_msg_error := get_error_msg_php('HR1490',global_v_lang);
                    exit;
                end if;
            elsif v_count_tyrtrpln = 0 then
                begin
                    select qtyppc, amtbudg
                      into v_qtyptbdg, v_amtpbdg
                      from tcourse
                     where codcours = p_codcours;

                    begin
                        select codcate  into v_codcate
                          from tcourse
                         where codcours  =  p_codcours;
                    exception when no_data_found then
                        v_codcate := null;
                    end;

                    insert into tyrtrpln (dteyear,codcompy,codcours,plancond,
                                          codcate,qtyptbdg,amtpbdg,
                                          staappr,remarkap,
                                          dtecreate,codcreate,dteupd,coduser)
                     values (p_dteyear,p_codcompy,p_codcours,v_plancond,
                             v_codcate,v_qtyptbdg,v_amtpbdg,
                             'P',null,
                             sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                exception when others then
                    null;
                end;
            end if;

            if v_plancond = '1' then
                for r1 in c1 loop
                    if secur_main.secur3(p_codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                        begin
                            select numlvl
                              into v_ttpotent.numlvl
                              from temploy1
                             where codempid = r1.codempid;
                        exception when no_data_found then
                            v_ttpotent.numlvl := null;
                        end;
                        begin
                            insert into ttpotent (dteyear,codcompy,codcours,codempid,
                                                  codcomp,codpos,numlvl,stacours,flgclass,remark,
                                                  dtecreate,codcreate,dteupd,coduser)
                            values(p_dteyear,p_codcompy,p_codcours,r1.codempid,
                                   p_codcomp,p_codpos,v_ttpotent.numlvl,v_plancond,'N',r1.commtemp,
                                   sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                        exception when dup_val_on_index then
                            null;
                        end;
                    end if;
                end loop;
            elsif v_plancond = '2' then
                for r2 in c2 loop
                    if secur_main.secur3(p_codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                        begin
                            select numlvl
                              into v_ttpotent.numlvl
                              from temploy1
                             where codempid = r2.codempid;
                        exception when no_data_found then
                            v_ttpotent.numlvl := null;
                        end;
                        begin
                            insert into ttpotent (dteyear,codcompy,codcours,codempid,
                                                  codcomp,codpos,numlvl,stacours,flgclass,remark,
                                                  dtecreate,codcreate,dteupd,coduser)
                            values(p_dteyear,p_codcompy,p_codcours,r2.codempid,
                                   p_codcomp,p_codpos,v_ttpotent.numlvl,v_plancond,'N','',
                                   sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                        exception when dup_val_on_index then
                            null;
                        end;
                    end if;
                end loop;
            elsif v_plancond = '3' then
                for r3 in c3 loop
                    v_typemp        := r3.typemp;
                    v_codcomp       := r3.codcomp;
                    v_codpos        := r3.codpos;

                    for r4 in c4 loop
                        v_qtyposst      := r4.qtyposst;
                        if v_typemp = 'N' then
                            for r5 in c5 loop
                                if secur_main.secur3(r4.codcomp,r5.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                                    begin
                                        select numlvl
                                          into v_ttpotent.numlvl
                                          from temploy1
                                         where codempid = r5.codempid;
                                    exception when no_data_found then
                                        v_ttpotent.numlvl := null;
                                    end;
                                    begin
                                        insert into ttpotent (dteyear,codcompy,codcours,codempid,
                                                              codcomp,codpos,numlvl,stacours,flgclass,remark,
                                                              dtecreate,codcreate,dteupd,coduser)
                                        values(p_dteyear,p_codcompy,p_codcours,r5.codempid,
                                               v_codcomp,v_codpos,v_ttpotent.numlvl,v_plancond,'N','',
                                               sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                                    exception when dup_val_on_index then
                                        null;
                                    end;
                                end if;
                            end loop;
                        end if;
                        if v_typemp = 'M' then
                            for r6 in c6 loop
                                if secur_main.secur3(r4.codcomp,r6.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                                    begin
                                        select numlvl
                                          into v_ttpotent.numlvl
                                          from temploy1
                                         where codempid = r6.codempid;
                                    exception when no_data_found then
                                        v_ttpotent.numlvl := null;
                                    end;
                                    begin
                                        insert into ttpotent (dteyear,codcompy,codcours,codempid,
                                                              codcomp,codpos,numlvl,stacours,flgclass,remark,
                                                              dtecreate,codcreate,dteupd,coduser)
                                        values(p_dteyear,p_codcompy,p_codcours,r6.codempid,
                                               v_codcomp,v_codpos,v_ttpotent.numlvl,v_plancond,'N','',
                                               sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                                    exception when dup_val_on_index then
                                        null;
                                    end;
                                end if;
                            end loop;
                        end if;
                    end loop;
                end loop;
            elsif v_plancond = '4' then
                if p_flgTab = 'G' then
                    for r7 in c7 loop
                        if secur_main.secur3(p_codcomp,r7.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            begin
                                select numlvl
                                  into v_ttpotent.numlvl
                                  from temploy1
                                 where codempid = r7.codempid;
                            exception when no_data_found then
                                v_ttpotent.numlvl := null;
                            end;
                            begin
                                insert into ttpotent (dteyear,codcompy,codcours,codempid,
                                                      codcomp,codpos,numlvl,stacours,flgclass,remark,
                                                      dtecreate,codcreate,dteupd,coduser)
                                values(p_dteyear,p_codcompy,p_codcours,r7.codempid,
                                       p_codcomp,p_codpos,v_ttpotent.numlvl,v_plancond,'N',r7.remark,
                                       sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                            exception when dup_val_on_index then
                                null;
                            end;
                        end if;
                    end loop;
                elsif p_flgTab = 'C' then
                    for r8 in c8 loop
                        if secur_main.secur3(p_codcomp,r8.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            begin
                                select numlvl
                                  into v_ttpotent.numlvl
                                  from temploy1
                                 where codempid = r8.codempid;
                            exception when no_data_found then
                                v_ttpotent.numlvl := null;
                            end;
                            begin
                                insert into ttpotent (dteyear,codcompy,codcours,codempid,
                                                      codcomp,codpos,numlvl,stacours,flgclass,remark,
                                                      dtecreate,codcreate,dteupd,coduser)
                                values(p_dteyear,p_codcompy,p_codcours,r8.codempid,
                                       p_codcomp,p_codpos,v_ttpotent.numlvl,v_plancond,'N','',
                                       sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                            exception when dup_val_on_index then
                                null;
                            end;
                        end if;
                    end loop;
                elsif p_flgTab = 'P' then
                    for r9 in c9 loop
                        if secur_main.secur3(p_codcomp,r9.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            begin
                                select numlvl
                                  into v_ttpotent.numlvl
                                  from temploy1
                                 where codempid = r9.codempid;
                            exception when no_data_found then
                                v_ttpotent.numlvl := null;
                            end;
                            begin
                                insert into ttpotent (dteyear,codcompy,codcours,codempid,
                                                      codcomp,codpos,numlvl,stacours,flgclass,remark,
                                                      dtecreate,codcreate,dteupd,coduser)
                                values(p_dteyear,p_codcompy,p_codcours,r9.codempid,
                                       p_codcomp,r9.codpos,v_ttpotent.numlvl,v_plancond,'N','',
                                       sysdate,global_v_coduser,sysdate,'TEMP-'||global_v_codempid);
                            exception when dup_val_on_index then
                                null;
                            end;
                        end if;
                    end loop;
                end if;
            end if;
        end loop;

--        v_codtparg      := hcm_util.get_string_t(obj_tab1,'codtparg');
--        v_plancond      := hcm_util.get_string_t(obj_tab1,'plancond');
--        v_typcon        := hcm_util.get_string_t(obj_tab1,'typcon');
--        obj_syncond     := hcm_util.get_json_t(obj_tab1,'syncond');
--        v_syncond       := hcm_util.get_string_t(obj_syncond,'code');
--        v_statement     := hcm_util.get_string_t(obj_syncond,'statement');
--        v_typtrain      := hcm_util.get_string_t(obj_tab1,'typtrain');
--        v_codhotel      := hcm_util.get_string_t(obj_tab1,'codhotel');
--        v_codinsts      := hcm_util.get_string_t(obj_tab1,'codinsts');
--        v_qtynumcl      := hcm_util.get_string_t(obj_tab1,'qtynumcl');
--        v_qtyptbdg      := hcm_util.get_string_t(obj_tab1,'qtyptbdg');
--        v_amtpbdg       := hcm_util.get_string_t(obj_tab1,'amtpbdg');
--        v_amtclbdg      := hcm_util.get_string_t(obj_tab1,'amtclbdg');
--        v_amttot        := hcm_util.get_string_t(obj_tab1,'amttot');
--        v_qtyptpln      := hcm_util.get_string_t(obj_tab1,'qtyptpln');
--        v_codrespn      := hcm_util.get_string_t(obj_tab1,'codrespn');
--
--        v_remark        := hcm_util.get_string_t(obj_tab1,'remark');
--        v_flgedit       := hcm_util.get_string_t(obj_tab1,'flgedit');

--        if param_msg_error is null then
--            if(obj_table.get_size() > 0) then
--                begin
--                    delete ttpotent
--                     where dteyear = p_dteyear
--                       and codcompy = p_codcompy
--                       and codcours = p_codcours;
--                end;
--
--                for i in 0..obj_table.get_size-1 loop
--                    json_emp                := hcm_util.get_json_t(obj_table,to_char(i));
--                    v_ttpotent.codempid     := hcm_util.get_string_t(json_emp,'codempid');
--                    v_ttpotent.codcomp      := hcm_util.get_string_t(json_emp,'codcomp');
--                    v_ttpotent.codpos       := hcm_util.get_string_t(json_emp,'codpos');
--                    v_ttpotent.stacours     := hcm_util.get_string_t(json_emp,'stacours');
--                    v_ttpotent.flgclass     := 'N';
--                    v_ttpotent.remark       := hcm_util.get_string_t(json_emp,'remark');
--                    begin
--                        select numlvl
--                          into v_ttpotent.numlvl
--                          from temploy1
--                         where codempid = v_ttpotent.codempid;
--                    exception when no_data_found then
--                        v_ttpotent.numlvl := null;
--                    end;
--                    begin
--                        insert into ttpotent (dteyear,codcompy,codcours,codempid,codcomp,codpos,
--                                              stacours,flgclass,numlvl,remark,
--                                              dtecreate,codcreate,dteupd,coduser)
--                             values (p_dteyear,p_codcompy,p_codcours,v_ttpotent.codempid,v_ttpotent.codcomp,v_ttpotent.codpos,
--                                     v_ttpotent.stacours,v_ttpotent.flgclass,v_ttpotent.numlvl,v_ttpotent.remark,
--                                     sysdate,global_v_coduser,sysdate,global_v_coduser);
--                    exception when dup_val_on_index then
--                        null;
--                    end;
--                end loop;
--            end if;
--        end if;
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
    end save_plan;

END HRTR34E;

/
