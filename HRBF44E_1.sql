--------------------------------------------------------
--  DDL for Package Body HRBF44E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF44E" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp       := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
        p_codpos        := upper(hcm_util.get_string_t(json_obj,'p_codpos'));
        p_dtestr        := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'dd/mm/yyyy');
        p_dteend        := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

        p_codobf        := upper(hcm_util.get_string_t(json_obj,'p_codobf'));
        p_dtereq        := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
        p_qtyalw        := to_number(hcm_util.get_string_t(json_obj,'p_qtyalw'));
        p_amtwidrw      := to_number(hcm_util.get_string_t(json_obj,'p_amtwidrw'));
        p_qtyemp        := hcm_util.get_string_t(json_obj,'p_qtyemp');
        p_staemp        := hcm_util.get_string_t(json_obj,'p_staemp');
        p_dteempmtst    := to_date(hcm_util.get_string_t(json_obj,'p_dteempmtst'),'dd/mm/yyyy');
        p_dteempmten    := to_date(hcm_util.get_string_t(json_obj,'p_dteempmten'),'dd/mm/yyyy');
        p_numvcomp      := upper(hcm_util.get_string_t(json_obj,'p_numvcomp'));
        --p_qtywidrw      := to_number(hcm_util.get_string_t(json_obj,'p_qtywidrw')); --<< user25 Date: 30/08/2021 5. BF Module #6808
        p_qtywidrw      := to_number(replace(hcm_util.get_string_t(json_obj,'p_qtywidrw'),',',null)); --<< user25 Date: 30/08/2021 5. BF Module #6808
        p_qtyempwidrw   := to_number(hcm_util.get_string_t(json_obj,'p_qtyempwidrw'));
        p_codempid      := upper(hcm_util.get_string_t(json_obj,'p_codempid'));

        p_numvcher      := hcm_util.get_string_t(json_obj,'numvcher');

        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        param_detail    := hcm_util.get_json_t(json_obj,'detail');
        param_send      := hcm_util.get_json_t(json_obj,'sendParams');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_dtestr is null or p_dteend is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- check HR3007
        if p_codcomp is not null then
            begin
                select 'X' into v_temp
                  from tcenter
                 where codcomp like p_codcomp || '%'
                   and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;

            param_msg_error :=  hcm_secur.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;

        if p_codpos is not null then
            begin
                select 'X' into v_temp
                  from tpostn
                 where codpos = p_codpos;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
                return;
            end;
        end if;

        if p_dtestr > p_dteend then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_flgvoucher    varchar2(100 char);
        v_flgtranpy     varchar2(100 char);

        cursor c1 is
            select a.numvcomp ,a.dtereq,a.codreq,a.staemp,a.codappr,a.dteappr,a.codcomp
            from tobfcomp a
            where trunc(dtereq) between trunc(p_dtestr) and trunc(p_dteend)
            and a.codcomp like p_codcomp || '%'
            and a.codpos = nvl(p_codpos,a.codpos)
            order by numvcomp;
    begin

        obj_rows := json_object_t();
        for i in c1 loop
            if secur_main.secur7(i.codcomp, global_v_coduser) then
                v_row := v_row+1;
                obj_data := json_object_t();
                obj_data.put('numvcomp',i.numvcomp);
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('dtereq', to_char(i.dtereq,'dd/mm/yyyy'));
                obj_data.put('codreq', i.codreq);
                obj_data.put('desc_codreq',get_temploy_name(i.codreq,global_v_lang));
                obj_data.put('staemp', i.staemp);
                obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',i.staemp,global_v_lang));
                obj_data.put('codappr',i.codappr);
                obj_data.put('desc_codappr',get_temploy_name(i.codappr,global_v_lang));
                obj_data.put('dteappr', to_char(i.dteappr,'dd/mm/yyyy'));
                begin
                    select flgvoucher
                      into v_flgvoucher
                      from tobfinf
                     where numvcomp = i.numvcomp
                       and flgvoucher = 'Y'
                       and rownum = 1;
                exception when no_data_found then
                    v_flgvoucher := 'N';
                end;
                obj_data.put('flgvoucher',v_flgvoucher);
                begin
                    select flgtranpy
                      into v_flgtranpy
                      from tobfinf
                     where numvcomp = i.numvcomp
                       and flgtranpy = 'Y'
                       and rownum = 1;
                exception when no_data_found then
                    v_flgtranpy := 'N';
                end;
                obj_data.put('flgtranpy',v_flgtranpy);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        json_str_output := obj_rows.to_clob;
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
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure gen_detail(json_str_output out clob) as
        obj_data        json_object_t;
        v_tobfcomp      tobfcomp%rowtype;
        v_flag          varchar(50 char) := '';
        v_errorno       varchar2(100);
        v_flgvoucher    varchar2(1 char);
        v_flgtranpy     varchar2(1 char);
    begin
        begin
            select * into v_tobfcomp
            from tobfcomp
            where numvcomp = p_numvcomp;
            v_flag    := 'edit';
        exception when no_data_found then
            v_tobfcomp := null;
            v_flag    := 'add';
        end;

        if v_flag = 'add' then
            v_errorno   := benefit_secure_comp;
            if v_errorno is null then
                obj_data := json_object_t();
                obj_data.put('coderror',200);
                obj_data.put('codappr', '' );
                obj_data.put('codcomp', p_codcomp );
                obj_data.put('codempid', '' );
                obj_data.put('codpos', p_codpos );
                obj_data.put('desc_codcomp', get_tcenter_name(p_codcomp,global_v_lang) );
                obj_data.put('desc_codpos', get_tpostn_name(p_codpos,global_v_lang) );
                obj_data.put('desc_staemp', get_tlistval_name('NAMESTAT',p_staemp,global_v_lang) );
                obj_data.put('dteappr', '' );
                obj_data.put('dteempmten', to_char(p_dteempmten,'dd/mm/yyyy') );
                obj_data.put('dteempmtst', to_char(p_dteempmtst,'dd/mm/yyyy') );
                obj_data.put('dtemthpay', '' );
                obj_data.put('dtepay', '' );
                obj_data.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy') );
                obj_data.put('dteyrepay', '' );
                obj_data.put('msgerror', '' );
                obj_data.put('numperiod', '' );
                obj_data.put('numvcomp', '' );
                obj_data.put('staemp', p_staemp );
                obj_data.put('typepay', '' );
                obj_data.put('flgvoucher','');
                json_str_output := obj_data.to_clob;
            else
                param_msg_error := get_error_msg_php(v_errorno,global_v_lang,'tobfcfp');
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            end if;
        elsif v_flag = 'edit' then
            obj_data := json_object_t();
            obj_data.put('coderror',200);
            obj_data.put('codappr', v_tobfcomp.codappr );
            obj_data.put('codcomp', v_tobfcomp.codcomp );
            obj_data.put('codempid', v_tobfcomp.codreq);
            obj_data.put('codpos', v_tobfcomp.codpos );
            obj_data.put('desc_codcomp', get_tcenter_name(v_tobfcomp.codcomp,global_v_lang) );
            obj_data.put('desc_codpos', get_tpostn_name(v_tobfcomp.codpos,global_v_lang) );
            obj_data.put('desc_staemp', get_tlistval_name('NAMESTAT',v_tobfcomp.staemp,global_v_lang) );
            obj_data.put('dteappr', to_char(v_tobfcomp.dteappr,'dd/mm/yyyy') );
            obj_data.put('dteempmten', to_char(v_tobfcomp.dteempmten,'dd/mm/yyyy') );
            obj_data.put('dteempmtst', to_char(v_tobfcomp.dteempmtst,'dd/mm/yyyy') );
            obj_data.put('dtemthpay', v_tobfcomp.dtemthpay );
            obj_data.put('dtepay', to_char(v_tobfcomp.dtepay,'dd/mm/yyyy') );
            obj_data.put('dtereq', to_char(v_tobfcomp.dtereq,'dd/mm/yyyy') );
            obj_data.put('dteyrepay', v_tobfcomp.dteyrepay );
            obj_data.put('msgerror', '' );
            obj_data.put('numperiod', v_tobfcomp.numperiod );
            obj_data.put('numvcomp', v_tobfcomp.numvcomp );
            obj_data.put('staemp', v_tobfcomp.staemp );
            obj_data.put('typepay',v_tobfcomp.typepay );
            begin
                select flgvoucher
                  into v_flgvoucher
                  from tobfinf
                 where numvcomp = p_numvcomp
                   and flgvoucher = 'Y'
                   and rownum = 1;
            exception when no_data_found then
                v_flgvoucher := 'N';
            end;
            obj_data.put('flgvoucher',v_flgvoucher);
            begin
                select flgtranpy
                  into v_flgtranpy
                  from tobfinf
                 where numvcomp = p_numvcomp
                   and flgtranpy = 'Y'
                   and rownum = 1;
            exception when no_data_found then
                v_flgtranpy := 'N';
            end;
            obj_data.put('flgtranpy',v_flgtranpy);
            json_str_output := obj_data.to_clob;
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) AS
    BEGIN
        initial_value(json_str_input);
        gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END get_detail;

    procedure gen_detail_table(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        obj_data_att    json_object_t;
        obj_row_att     json_object_t;
        v_row           number := 0;
        v_row_att       number := 0;
        v_amtvalue      tobfcde.amtvalue%type;
        v_codunit       tobfcde.codunit%type;
        v_typebf        tobfcde.typebf%type;
        v_codobf        tobfcde.codobf%type;
        v_costcenter    tcenter.costcent%type;
        v_staemp        temploy1.staemp%type;
        v_codpos        temploy1.codpos%type;
        v_dteefpos      date;
        v_flgtranpy     varchar2(1 char);
        v_error         varchar2(100 char);
        v_tobfcomp      tobfcomp%rowtype;
        v_amtwidrw      number;
        cursor c1 is
            select codobf,qtywidrw,amtwidrw,qtyempwidrw
            from tobfcompd
            where numvcomp = p_numvcomp;

        cursor c2 is
            select *
              from tobfinf
             where numvcomp = p_numvcomp
               and codobf = v_codobf;
    begin
        obj_rows := json_object_t();
        begin
            select * into v_tobfcomp
            from tobfcomp
            where numvcomp = p_numvcomp;
        exception when no_data_found then
            null;
        end;
        p_codpos := v_tobfcomp.codpos;
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codobf',i.codobf);
            begin
                select amtvalue, codunit, typebf into v_amtvalue, v_codunit, v_typebf
                from tobfcde
                where codobf = i.codobf;
              exception when no_data_found then null;
            end;
            obj_data.put('codunit',v_codunit);
            obj_data.put('desc_codunit',get_tcodec_name('TCODUNIT',v_codunit,global_v_lang));
            obj_data.put('typebf',v_typebf);
            obj_data.put('desc_typebf',get_tlistval_name('TYPPAYBNF',v_typebf,global_v_lang));

            if v_typebf = 'C' then
                obj_data.put('amtwidrw','');
                v_amtwidrw  := i.qtywidrw;
                obj_data.put('amtwidrwav',to_char((v_amtwidrw/i.qtyempwidrw),'fm999,999,990.00'));
                obj_data.put('qtywidrwav',to_char((i.qtywidrw/i.qtyempwidrw),'fm999,999,990.00'));
                obj_data.put('qtywidrw',i.qtywidrw);--nut obj_data.put('qtywidrw',to_char((i.qtywidrw),'fm999,999,990.00'));
            else
                obj_data.put('amtwidrw',v_amtvalue);
                v_amtwidrw  := i.qtywidrw*v_amtvalue;
                obj_data.put('amtwidrwav',v_amtwidrw/i.qtyempwidrw);
                obj_data.put('qtywidrwav',i.qtywidrw/i.qtyempwidrw);
                obj_data.put('qtywidrw',i.qtywidrw);
            end if;
            obj_data.put('qtyempwidrw',i.qtyempwidrw);


            obj_data.put('temp','');
            obj_data.put('coderror',200);
            v_codobf    := i.codobf;
            obj_row_att := json_object_t();
            v_row_att   := 0;
            for j in c2 loop
                obj_data_att := json_object_t();
                obj_data_att.put('coderror', '200');
                obj_data_att.put('numvcomp',j.numvcomp);
                obj_data_att.put('codempid',j.codempid);
                obj_data_att.put('qtywidrw',j.qtywidrw);
                p_qtywidrw  := j.qtywidrw;
                p_dtereq    := j.dtereq;
                p_numvcomp  := j.numvcomp;
                p_codobf    := j.codobf;
                v_error := benefit_secure_comp;
                obj_data_att.put('qtytwidrw',p_qtytwidrw);
                begin
                    select costcent into v_costcenter
                    from tcenter
                    where codcomp = j.codcomp;
                  exception when no_data_found then null;
                end;
                begin
                    select staemp,codpos,dteefpos into v_staemp,v_codpos,v_dteefpos
                    from temploy1
                    where codempid = j.codempid;
                exception when no_data_found then
                    v_staemp  := null;
                    v_codpos := null;
                end;
                obj_data_att.put('costcenter',v_costcenter);
                obj_data_att.put('codpos',v_codpos);
                obj_data_att.put('desc_codpos',get_tpostn_name(v_codpos, global_v_lang));
                obj_data_att.put('staemp',v_staemp);
                obj_data_att.put('desc_staemp',get_tlistval_name('NAMESTAT',v_staemp,global_v_lang));
                obj_data_att.put('dteempmtst',to_char(v_dteefpos,'dd/mm/yyyy'));
                obj_data_att.put('numvcher',nvl(j.numvcher,''));
                obj_row_att.put(to_char(v_row_att),obj_data_att);
                v_row_att := v_row_att + 1;
            end loop;
            obj_data.put('employeeTable', obj_row_att);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_detail_table;

    procedure get_detail_table(json_str_input in clob, json_str_output out clob) AS
    BEGIN
        initial_value(json_str_input);
        gen_detail_table(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END get_detail_table;

    procedure gen_process(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_errorno       varchar2(10 char);
        v_sum_qtyalw    number := 0;
        v_costcenter    tcenter.costcent%type;

        cursor c1 is
            select codempid,codpos,staemp,dteefpos,codcomp
            from temploy1
            where codcomp like p_codcomp || '%'
            and codpos = nvl(p_codpos,codpos)
            and staemp = nvl(p_staemp,staemp)
            and dteefpos between p_dteempmtst and p_dteempmten
            order by codempid;

    begin
        obj_rows := json_object_t();
        v_errorno   := benefit_secure_comp;
        if v_errorno is null then
            p_amtwidrw := p_qtywidrw/p_qtyempwidrw;
            for i in c1 loop
                if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    p_codempid  := i.codempid;
                    v_errorno   := benefit_secure_man;
                    if v_errorno is null then
                        if p_qtywidrw > v_sum_qtyalw then
                            v_sum_qtyalw := nvl(p_amtwidrw,0) + nvl(v_sum_qtyalw,0);
                            v_row := v_row+1;
                            obj_data := json_object_t();
                            obj_data.put('codempid',i.codempid);
                            obj_data.put('amtwidrw',p_amtwidrw);
                            obj_data.put('codpos',i.codpos);
                            obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
                            obj_data.put('staemp',i.staemp);
                            obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',i.staemp,global_v_lang));
                            obj_data.put('dteempmtst',to_char(i.dteefpos,'dd/mm/yyyy'));
                            obj_data.put('numvcomp','');
                            obj_data.put('qtywidrw',p_qtywidrw/p_qtyempwidrw);
                            obj_data.put('qtytwidrw',p_qtytwidrw);
                            obj_data.put('flgAdd',true);
                            obj_data.put('flgDelete',false);
                            obj_data.put('flgDeleteHide',false);
                            obj_data.put('flgEdit',false);
                            begin
                                select costcent into v_costcenter
                                from tcenter
                                where codcomp = i.codcomp;
                              exception when no_data_found then null;
                            end;
                            obj_data.put('costcenter',v_costcenter);
                            obj_rows.put(to_char(v_row-1),obj_data);

                        else
                            exit;
                        end if;
                    else
                        null;--param_msg_error := get_error_msg_php(v_errorno,global_v_lang,'tobfcdet');
                    end if;
                end if;
            end loop;
            /*if v_row < p_qtyempwidrw then
                param_msg_error := get_error_msg_php('BF0078',global_v_lang,'tobfcdet');
            end if;*/
        else
            null;--param_msg_error := get_error_msg_php(v_errorno,global_v_lang,'tobfcfp');
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_process;

    procedure get_process(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_process(json_str_output);
            if param_msg_error is not null then
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_process;

    procedure gen_emp(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_costcenter    tcenter.costcent%type;
        v_temploy1   temploy1%rowtype;
        v_error         varchar2(100 char);

    begin
        begin
            select *
              into v_temploy1
              from temploy1
             where codempid = p_codempid;
        exception when no_data_found then null;
        end;
        begin
            select costcent
              into v_costcenter
              from tcenter
             where codcomp = v_temploy1.codcomp;
        exception when no_data_found then null;
        end;
        obj_data := json_object_t();
        obj_data.put('coderror',200);
        obj_data.put('codempid',p_codempid);
        obj_data.put('codpos',v_temploy1.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(v_temploy1.codpos,global_v_lang));
        obj_data.put('staemp',v_temploy1.staemp);
        obj_data.put('desc_staemp',get_tlistval_name('NAMESTAT',v_temploy1.staemp,global_v_lang));
        obj_data.put('dteempmtst',to_char(v_temploy1.dteefpos,'dd/mm/yyyy'));
        obj_data.put('numvcomp','');
        p_qtywidrw  := p_qtywidrw/p_qtyempwidrw;
        obj_data.put('qtywidrw',p_qtywidrw);
        v_error := benefit_secure_comp;
        obj_data.put('qtytwidrw',p_qtytwidrw);
        obj_data.put('costcenter',v_costcenter);
        json_str_output := obj_data.to_clob;
    end gen_emp;

    procedure get_emp(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_emp(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_emp;

    procedure check_emp(json_str_input in clob, json_str_output out clob) as
        data_obj        json_object_t;
        data_row        json_object_t;
        data_row2       json_object_t;
        json_obj        json;
        v_codcomp       varchar2(100 char);
        v_codempid      varchar2(100 char);
        v_row           number := 0;
        v_errorno       varchar2(10 char);
        v_sum_qtyalw    number := 0;
        v_emp           number := 0;
        v_flgDelete     boolean;
    begin
        initial_value(json_str_input);

        p_codcomp       := hcm_util.get_string_t(param_send,'codcomp');
        p_codobf        := hcm_util.get_string_t(param_send,'codobf');
        p_codpos        := hcm_util.get_string_t(param_send,'codpos');
        p_dteempmten    := to_date(hcm_util.get_string_t(param_send,'dteempmten'),'dd/mm/yyyy');
        p_dteempmtst    := to_date(hcm_util.get_string_t(param_send,'dteempmtst'),'dd/mm/yyyy');
        p_dtereq        := to_date(hcm_util.get_string_t(param_send,'dtereq'),'dd/mm/yyyy');
        p_numvcomp      := hcm_util.get_string_t(param_send,'numvcomp');
        p_staemp        := hcm_util.get_string_t(param_send,'staemp');
        p_qtywidrw      := to_number(hcm_util.get_string_t(param_send,'qtywidrw'));
        p_qtyempwidrw   := to_number(hcm_util.get_string_t(param_send,'qtyempwidrw'));
        p_amtwidrw      := p_qtywidrw/p_qtyempwidrw;
        data_row        := hcm_util.get_json_t(param_json,'rows');
        for i in 0..data_row.get_size-1 loop
            data_row2    := hcm_util.get_json_t(data_row,to_char(i));
            p_codempid   := hcm_util.get_string_t(data_row2, 'codempid');
            v_flgDelete  := hcm_util.get_boolean_t(data_row2, 'flgDelete');
            p_numvcher   := hcm_util.get_string_t(data_row2,'numvcher');
            if not v_flgDelete then
                if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                    begin
                        select count(*)
                          into v_emp
                          from temploy1
                         where codcomp like p_codcomp || '%'
                           and codpos = p_codpos
                           and staemp = p_staemp
                           and dteefpos between p_dteempmtst and p_dteempmten
                           and codempid = p_codempid
                        order by codempid;
                    exception when no_data_found then
                        v_emp := 0;
                    end;
                    if v_emp > 0 then
                        v_errorno   := benefit_secure_man;
                        if v_errorno is null then
                            v_sum_qtyalw := nvl(p_amtwidrw,0) + nvl(v_sum_qtyalw,0);
                            v_row := v_row+1;
                        else
                            param_msg_error := get_error_msg_php(v_errorno,global_v_lang,'tobfcdet');
                        end if;
                    else
                        param_msg_error := get_error_msg_php('BF0078',global_v_lang,'tobfcdet-4');
                    end if ;
                end if;
            end if;
        end loop;
        if v_row <> p_qtyempwidrw then
            param_msg_error := get_error_msg_php('BF0078',global_v_lang,'tobfcdet');
        end if;

        if param_msg_error is null then
            param_msg_error := replace(get_error_msg_php('BF0077',global_v_lang),'@#$%400');
            json_obj   := json();
            json_obj.put('coderror','200');
            json_obj.put('response',param_msg_error);
            json_str_output := json_obj.to_char;
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;

    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end check_emp;

    procedure save_index (json_str_input in clob, json_str_output out clob) as
        param_json_row  json_object_t;
        param_index     json_object_t;
        data_row        json_object_t;

        v_flg	        varchar2(1000 char);
        v_flgtranpy	    varchar2(1 char);
        v_flgvoucher    varchar2(1 char);
        v_numvcomp	    varchar2(1000 char);
        v_numvcher	    varchar2(1000 char);
        v_numseq        number;
        v_tobfinf       tobfinf%rowtype;

        cursor c1 is
            select *
              from tobfinf
             where numvcomp = v_numvcomp;
    begin
        initial_value(json_str_input);
        for i in 0..param_json.get_size-1 loop
            data_row        := hcm_util.get_json_t(param_json,to_char(i));
            v_numvcomp      := hcm_util.get_string_t(data_row,'numvcomp');
            v_flg           := hcm_util.get_string_t(data_row,'flg');
            v_flgtranpy	    := hcm_util.get_string_t(data_row,'flgtranpy');
            v_flgvoucher    := hcm_util.get_string_t(data_row,'flgvoucher');

            if v_flgtranpy = 'N' then
                delete tobfcomp where numvcomp = v_numvcomp;
                delete tobfcompd where numvcomp = v_numvcomp;
                for j in c1 loop
                    begin
                      select * into v_tobfinf
                        from tobfinf
                       where numvcher = j.numvcher;
                    exception when no_data_found then
                        null;
                    end;
                    delete tobfinf where numvcher = j.numvcher;
                    delete tobfattch where numvcher = j.numvcher;

                    hrbf43e.save_tobfsum(v_tobfinf.codempid, v_tobfinf.dtereq, v_tobfinf.codobf,
                                 v_tobfinf.codcomp, v_tobfinf.qtyalw, v_tobfinf.qtytalw);
                    hrbf43e.save_tobfdep(v_tobfinf.dtereq,v_tobfinf.codobf,v_tobfinf.codcomp);
                end loop;
            end if;
        end loop;

        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
        else
            json_str_output := param_msg_error;
            rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obje       json_object_t;
        data_obj        json_object_t;
        data_row        json_object_t;
        data_row2       json_object_t;
        data_row3       json_object_t;
        data_row4       json_object_t;
        json_obj        json;
        v_codappr       tobfcomp.codappr%type;
        v_codreq        tobfcomp.codreq%type;
        v_codpos        tobfcomp.codpos%type;
        v_dteappr       tobfcomp.dteappr%type;
        v_dteempmten    tobfcomp.dteempmten%type;
        v_dteempmtst    tobfcomp.dteempmtst%type;
        v_dtemthpay     tobfcomp.dtemthpay%type;
        v_dtepay        tobfcomp.dtepay%type;
        v_dtereq        tobfcomp.dtereq%type;
        v_dteyrepay     tobfcomp.dteyrepay%type;
        v_numperiod     tobfcomp.numperiod%type;
        v_numvcomp      tobfcomp.numvcomp%type;
        v_numvcomp2     tobfcomp.numvcomp%type;
        v_staemp        tobfcomp.staemp%type;
        v_typepay       tobfcomp.typepay%type;
        v_amtwidrw      number;
        v_qtytwidrw     number;

        v_codobf        varchar2(100 char);
        v_flgDelete     boolean;
        v_row           number := 0;
        v_errorno       varchar2(10 char);
        v_sum_qtyalw    number := 0;
        v_emp           number := 0;
        v_count         number;
        v_typebf        varchar2(1 char);
        v_numvcher      tobfinf.numvcher%type;
        v_numvcher2     tobfinf.numvcher%type;
        v_numvcher3     tobfinf.numvcher%type;
        v_codcomp       temploy1.codcomp%type;

    begin
        initial_value(json_str_input);

        v_codappr       := hcm_util.get_string_t(param_detail,'codappr');
        v_codreq        := hcm_util.get_string_t(param_detail,'codempid');
        v_dteappr       := to_date(hcm_util.get_string_t(param_detail,'dteappr'),'dd/mm/yyyy');

        p_codcomp       := hcm_util.get_string_t(param_detail,'codcomp');
        p_codpos        := hcm_util.get_string_t(param_detail,'codpos');
        p_dteempmten    := to_date(hcm_util.get_string_t(param_detail,'dteempmten'),'dd/mm/yyyy');
        p_dteempmtst    := to_date(hcm_util.get_string_t(param_detail,'dteempmtst'),'dd/mm/yyyy');
        p_dtereq        := to_date(hcm_util.get_string_t(param_detail,'dtereq'),'dd/mm/yyyy');
        p_numvcomp      := hcm_util.get_string_t(param_detail,'numvcomp');
        p_staemp        := hcm_util.get_string_t(param_detail,'staemp');

        v_dtepay        := to_date(hcm_util.get_string_t(param_detail,'dtepay'),'dd/mm/yyyy');
        v_dteyrepay     := to_number(hcm_util.get_string_t(param_detail,'dteyrepay'));
        v_dtemthpay     := to_number(hcm_util.get_string_t(param_detail,'dtemthpay'));
        v_numperiod     := to_number(hcm_util.get_string_t(param_detail,'numperiod'));
        v_numvcomp      := hcm_util.get_string_t(param_detail,'numvcomp');
        v_typepay       := hcm_util.get_string_t(param_detail,'typepay');
        data_row    := hcm_util.get_json_t(param_json,'rows');
        for i in 0..data_row.get_size-1 loop
            data_row2       := hcm_util.get_json_t(data_row,to_char(i));
            v_amtwidrw      := to_number(hcm_util.get_string_t(data_row2, 'amtwidrw'));
            v_flgDelete     := hcm_util.get_boolean_t(data_row2, 'flgDelete');
            p_qtywidrw      := to_number(hcm_util.get_string_t(data_row2,'qtywidrw'));
            p_qtyempwidrw   := to_number(hcm_util.get_string_t(data_row2,'qtyempwidrw'));
            p_codobf        := hcm_util.get_string_t(data_row2,'codobf');
            p_amtwidrw      := p_qtywidrw/p_qtyempwidrw;
            if not v_flgDelete then
                param_emp    := hcm_util.get_json_t(data_row2,'employeeTable');
                data_row3    := hcm_util.get_json_t(param_emp,'rows');
                v_sum_qtyalw := 0;
                v_row        := 0;
                for j in 0..data_row3.get_size-1 loop
                    data_row4    := hcm_util.get_json_t(data_row3,to_char(j));
                    v_qtytwidrw  := to_number(hcm_util.get_string_t(data_row4, 'qtytwidrw'));
                    v_flgDelete  := hcm_util.get_boolean_t(data_row4, 'flgDelete');
                    if v_flgDelete is null then
                        v_flgDelete  := false;
                    end if;
                    p_codempid   := hcm_util.get_string_t(data_row4, 'codempid');
                    p_numvcher   := hcm_util.get_string_t(data_row4, 'numvcher');
                    if not v_flgDelete then
                        if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            begin
                                select count(*)
                                  into v_emp
                                  from temploy1
                                 where codcomp like p_codcomp || '%'
                                   and codpos = p_codpos
                                   and staemp = p_staemp
                                   and dteefpos between p_dteempmtst and p_dteempmten
                                   and codempid = p_codempid
                                order by codempid;
                            exception when no_data_found then
                                v_emp := 0;
                            end;
                            if v_emp > 0 then
                                v_errorno   := benefit_secure_man;
                                if v_errorno is null then
                                    v_sum_qtyalw := nvl(p_amtwidrw,0) + nvl(v_sum_qtyalw,0);
                                    v_row := v_row+1;
                                else
                                    param_msg_error := get_error_msg_php(v_errorno,global_v_lang,'tobfcdet');
                                end if;
                            else
                                param_msg_error := get_error_msg_php('BF0078',global_v_lang,'tobfcdet');
                            end if ;
                        end if;
                    end if;
                end loop;
                if v_row <> p_qtyempwidrw then
                    param_msg_error := get_error_msg_php('BF0078',global_v_lang,'tobfcdet');
                end if;
            end if;
        end loop;

        p_numvcomp      := hcm_util.get_string_t(param_detail,'numvcomp');
        if param_msg_error is null then
            --Insert tobfcomp
            if p_numvcomp is null then
                p_numvcomp := 'G'||get_codcompy(p_codcomp)||to_char(p_dtereq,'yy')||to_char(p_dtereq,'mm');

                begin
                    select max(numvcomp) into v_numvcomp
                    from tobfcomp
                    where numvcomp like p_numvcomp || '%';
                exception when no_data_found then null;
                end;

                v_numvcomp2 := substr(v_numvcomp,-9,5);

                if substr(p_numvcomp,-5,5) = v_numvcomp2 then
                    v_numvcomp := lpad(substr(v_numvcomp,-4,4)+1,4,0);
                    p_numvcomp := p_numvcomp||v_numvcomp;
                else
                    p_numvcomp := p_numvcomp||'0000';
                end if;
                insert into tobfcomp (numvcomp, codcomp, codpos, staemp,
                                      dteempmtst, dteempmten, codreq, dtereq,
                                      codappr, dteappr, typepay, dtepay,
                                      dteyrepay, dtemthpay, numperiod, dtecreate,
                                      codcreate, dteupd, coduser)
                              values (p_numvcomp, p_codcomp, p_codpos, p_staemp,
                                      p_dteempmtst, p_dteempmten, v_codreq, p_dtereq,
                                      v_codappr, v_dteappr, v_typepay, v_dtepay,
                                      v_dteyrepay, v_dtemthpay, v_numperiod, sysdate,
                                      global_v_coduser, sysdate, global_v_coduser);

            else
                update tobfcomp
                   set codreq    = v_codreq,
                       codappr   = v_codappr,
                       dteappr   = v_dteappr,
                       typepay   = v_typepay,
                       dtepay    = v_dtepay,
                       dteyrepay = v_dteyrepay,
                       dtemthpay = v_dtemthpay,
                       numperiod = v_numperiod,
                       dteupd    = sysdate,
                       coduser   = global_v_coduser
                 where numvcomp  = p_numvcomp;
            end if;
            --Insert tobfcomp
            data_row    := hcm_util.get_json_t(param_json,'rows');
            for i in 0..data_row.get_size-1 loop
                data_row2       := hcm_util.get_json_t(data_row,to_char(i));
                v_amtwidrw      := to_number(hcm_util.get_string_t(data_row2, 'amtwidrw'));
                v_flgDelete     := hcm_util.get_boolean_t(data_row2, 'flgDelete');
                p_qtywidrw      := to_number(hcm_util.get_string_t(data_row2,'qtywidrw'));
                p_qtyempwidrw   := to_number(hcm_util.get_string_t(data_row2,'qtyempwidrw'));
                p_codobf        := hcm_util.get_string_t(data_row2,'codobf');
                p_amtwidrw      := p_qtywidrw/p_qtyempwidrw;
                --Insert tobfcompd
                if not v_flgDelete then
                    begin
                        select count(*)
                          into v_count
                          from tobfcompd
                         where numvcomp = p_numvcomp
                           and codobf = p_codobf;
                    exception when no_data_found then
                        v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tobfcompd (numvcomp, codobf, qtywidrw,
                                               amtwidrw, dtecreate, codcreate,
                                               dteupd, coduser, qtyempwidrw)
                                       values (p_numvcomp, p_codobf, p_qtywidrw,
                                               v_amtwidrw, sysdate, global_v_coduser,
                                               sysdate, global_v_coduser, p_qtyempwidrw);
                    else
                        update tobfcompd
                           set qtywidrw = p_qtywidrw,
                               amtwidrw = v_amtwidrw,
                               dteupd   = sysdate,
                               coduser  = global_v_coduser,
                               qtyempwidrw = p_qtyempwidrw
                         where numvcomp = p_numvcomp
                           and codobf = p_codobf;
                    end if;
                else
                    delete tobfcompd where numvcomp = p_numvcomp and codobf = p_codobf;
                end if;
                --Insert tobfcompd
                if not v_flgDelete then
                    param_emp    := hcm_util.get_json_t(data_row2,'employeeTable');
                    data_row3    := hcm_util.get_json_t(param_emp,'rows');
                    delete tobfinf where numvcomp = p_numvcomp and codobf = p_codobf;
                    for j in 0..data_row3.get_size-1 loop
                        data_row4    := hcm_util.get_json_t(data_row3,to_char(j));
                        v_qtytwidrw  := to_number(hcm_util.get_string_t(data_row4, 'qtytwidrw'));
                        v_flgDelete  := hcm_util.get_boolean_t(data_row4, 'flgDelete');
                        p_codempid   := hcm_util.get_string_t(data_row4, 'codempid');
                        p_numvcher   := hcm_util.get_string_t(data_row4, 'numvcher');
                        v_errorno    := benefit_secure_man;
                        if v_flgDelete is null then
                            v_flgDelete  := false;
                        end if;
                        if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
                            begin
                                select codcomp into v_codcomp
                                  from temploy1
                                 where codempid = p_codempid;
                            exception when no_data_found then null;
                                v_codcomp := null;
                            end;
                            if not v_flgDelete then
                                begin
                                  select count(*) into v_count
                                    from tobfinf
                                   where numvcher = p_numvcher;
                                exception when no_data_found then
                                    v_count := 0;
                                end;

                                v_errorno   := benefit_secure_man;

                                if v_count = 0 then
                                    p_numvcher := get_codcompy(p_codcomp)||to_char(p_dtereq,'yy')||to_char(p_dtereq,'mm');

                                    begin
                                        select max(numvcher) into v_numvcher2
                                        from tobfinf
                                        where numvcher like p_numvcher || '%';
                                    exception when no_data_found then null;
                                    end;

                                    v_numvcher3 := substr(v_numvcher2,-8,4);

                                    if substr(p_numvcher,-4,4) = v_numvcher3 then
                                        v_numvcher2 := lpad(substr(v_numvcher2,-4,4)+1,4,1);
                                        p_numvcher := p_numvcher||v_numvcher2;
                                    else
                                        p_numvcher := p_numvcher||'0000';
                                    end if;

                                    insert into tobfinf(numvcher,codempid,codcomp,dtereq,
                                                        codobf,typrelate,nameobf,numtsmit,
                                                        qtywidrw,amtwidrw,qtyalw,qtytalw,
                                                        typepay,dtepay,flgtranpy,dteyrepay,
                                                        dtemthpay,numperiod,desnote,codappr,
                                                        dteappr,codcreate,coduser,dtecreate,
                                                        dteupd,amtvalue,numvcomp)
                                                 values(p_numvcher,p_codempid,v_codcomp,p_dtereq,
                                                        p_codobf,'E',get_temploy_name(p_codempid,global_v_lang),p_numtsmit,
                                                        p_amtwidrw,nvl(v_amtwidrw,1)*p_amtwidrw,p_qtyalwm,p_qtytalwm,
                                                        v_typepay,v_dtepay,'N',v_dteyrepay,
                                                        v_dtemthpay,v_numperiod,null,v_codappr,
                                                        v_dteappr,global_v_coduser,global_v_coduser,sysdate,
                                                        sysdate,v_amtwidrw,p_numvcomp);
                                else
                                    update tobfinf
                                       set codempid = p_codempid,
                                           codcomp = v_codcomp,
                                           dtereq = p_dtereq,
                                           codobf = p_codobf,
                                           typrelate = 'E',
                                           nameobf = get_temploy_name(p_codempid,global_v_lang),
                                           numtsmit = p_numtsmit,
                                           qtywidrw = p_amtwidrw,
                                           amtwidrw = nvl(v_amtwidrw,1)*p_amtwidrw,
                                           qtyalw = p_qtyalwm,
                                           qtytalw = p_qtytalwm,
                                           typepay = v_typepay,
                                           dtepay = v_dtepay,
                                           dteyrepay = v_dteyrepay,
                                           dtemthpay = v_dtemthpay,
                                           numperiod = v_numperiod,
                                           desnote = null,
                                           codappr = v_codappr,
                                           dteappr = v_dteappr,
                                           coduser = global_v_coduser,
                                           dteupd = sysdate,
                                           amtvalue = v_amtwidrw
                                        where numvcher = p_numvcher;
                                end if;

                            else
                                delete tobfinf where numvcher = v_numvcher;
                            end if;
                            hrbf43e.save_tobfdep(p_dtereq,p_codobf,v_codcomp);
                            hrbf43e.save_tobfsum(p_codempid, p_dtereq, p_codobf,p_codcomp, p_qtyalwm, p_qtytalwm);
                        end if;
                    end loop;
                end if;
            end loop;
            param_msg_error := replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201');
            json_obj   := json();
            json_obj.put('numvcomp',p_numvcomp);
            json_obj.put('coderror','200');
            json_obj.put('response',param_msg_error);
            json_str_output := json_obj.to_char;
            commit;
        else
            json_obj   := json();
            json_obj.put('numvcomp',p_numvcomp);
            json_obj.put('coderror','400');
            json_str_output := json_obj.to_char;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    function benefit_secure_man return varchar2 is
        v_codunit   tobfcde.codunit%type;
        v_amtvalue  tobfcde.amtvalue%type;
        v_syncond   tobfcde.syncond%type;
        v_syncond2   tobfcde.syncond%type;
        v_typepay   tobfcde.typepay%type;
        v_flglimit  tobfcde.flglimit%type;
        v_typebf    tobfcde.typebf%type;
        v_qtyalw    tobfcdet.qtyalw%type;
        v_qtytalw   tobfcdet.qtytalw%type;
        v_stmt      varchar2(4000 char);
        v_stmt2     varchar2(4000 char);
        v_flgcond1  number;
        v_flgcond2  number;
        v_flgcond3  number;
        v_qtytwidrw number;
        v_flgsecur  boolean := false;
        v_qtywidrw  number;
        v_numtsmit  number;

        v_errorno    varchar2(10 char);

        cursor c1 is
          select a.syncond,b.flglimit,b.amtvalue,b.qtyalw,b.qtytalw,b.amtalw
            from tobfcfp a, tobfcfpd b
           where a.codcomp = b.codcomp
             and a.dtestart = b.dtestart
             and a.numseq = b.numseq
             and p_codcomp like a.codcomp ||'%'
           --and p_dtereq between a.dtestart and a.dteend --<<user25 Date : 31/08/2021 5. BF Module #6825
             and trunc(p_dtereq) between nvl(a.dtestart,trunc(p_dtereq)) and nvl(a.dteend,trunc(p_dtereq))--<<user25 Date : 31/08/2021 5. BF Module #6825
             and b.codobf = p_codobf
           order by a.numseq;

        cursor c2 is
            select *
              from tobfcdet
             where codobf = p_codobf
            order by numobf;
    begin

        for r1 in c1 loop
            v_stmt :=  'select count(*) '||
                       'from TEMPLOY1 '||
                       'where TEMPLOY1.codempid = '||''''||p_codempid||''''||' '||
                       --'and '||r1.syncond;
                       'and  ('||r1.syncond||' )';--redmine572
            execute immediate v_stmt into v_flgcond1;
            if v_flgcond1 > 0 then
                begin
                  select codunit,amtvalue,typepay, flglimit, typebf, syncond
                    into v_codunit,v_amtvalue,v_typepay, v_flglimit, v_typebf, v_syncond
                    from tobfcde
                   where codobf = p_codobf;
                exception when no_data_found then
                    v_codunit  := '';
                    v_amtvalue := '';
                end;

                if v_syncond is not null then
                   v_syncond := replace(v_syncond,'V_HRBF41.CODREL','E') ;
                    v_stmt :=  'select count(*) '||
                               'from V_HRBF41 '||
                               'where V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
                               --'and '||v_syncond;
                               ' and  ('||v_syncond||' )';--redmine572
                    execute immediate v_stmt into v_flgcond2;
                else
                    v_flgcond2 := 1;
                end if;

                if v_flgcond2 > 0 then

                    for i in c2 loop
                        if i.syncond is not null then
                           v_syncond2 := i.syncond;
                           v_syncond2 := replace(v_syncond2,'V_HRBF41.CODREL','E') ;
                            v_stmt2 :=  'select count(*) '||
                                        'from V_HRBF41 '||
                                        'where V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
                                        -- 'and '||v_syncond2;
                                        ' and  ('||v_syncond2||' )';--redmine572
                            execute immediate v_stmt2 into v_flgcond3;
                            if v_flgcond3 > 0 then
                                v_qtyalw    := i.qtyalw;
                                v_qtytalw   := i.qtytalw;

                                p_qtyalwm   := v_qtyalw;
                                p_qtytalwm  := v_qtytalw;

                                if v_flglimit = 'M' then
                                    /*begin
                                        select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
                                          from tobfsum
                                         where codempid = p_codempid
                                           and codobf = p_codobf
                                           and dteyre = to_char(p_dtereq,'yyyy')
                                           and dtemth = to_char(p_dtereq,'mm');
                                  exception when no_data_found then
                                    v_qtywidrw := p_amtwidrw;
                                  end;*/
                                  begin
                                        select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
                                          from tobfinf
                                         where codempid = p_codempid
                                           and codobf = p_codobf
                                           and to_char(dtereq,'mmyyyy') = to_char(p_dtereq,'mmyyyy')
                                           and numvcher <> p_numvcher;
                                    exception when no_data_found then
                                        v_qtywidrw := p_amtwidrw;
                                  end;
                                  begin
                                        select count(*) + 1
                                          into v_numtsmit
                                          from tobfinf
                                         where codempid = p_codempid
                                           and codobf = p_codobf
                                           and to_char(dtereq,'mmyyyy') = to_char(p_dtereq,'mmyyyy')
                                           and numvcher <> p_numvcher;
                                    exception when no_data_found then
                                        v_numtsmit := 1;
                                    end;
                                elsif v_flglimit = 'Y' then
                                  /*begin
                                    select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
                                      from tobfsum
                                     where codempid = p_codempid
                                       and codobf = p_codobf
                                       and dteyre = to_char(p_dtereq,'yyyy')
                                       and dtemth = 13;
                                  exception when no_data_found then
                                    v_qtywidrw := p_amtwidrw;
                                  end;*/
                                  begin
                                        select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
                                          from tobfinf
                                         where codempid = p_codempid
                                           and codobf = p_codobf
                                           and to_char(dtereq,'yyyy') = to_char(p_dtereq,'yyyy')
                                           and numvcher <> p_numvcher;
                                    exception when no_data_found then
                                        v_qtywidrw := p_amtwidrw;
                                  end;
                                  begin
                                        select count(*) + 1
                                          into v_numtsmit
                                          from tobfinf
                                         where codempid = p_codempid
                                           and codobf = p_codobf
                                           and to_char(dtereq,'yyyy') = to_char(p_dtereq,'yyyy')
                                           and numvcher <> p_numvcher;
                                    exception when no_data_found then
                                        v_numtsmit := 1;
                                    end;
                                elsif v_flglimit = 'A' then
                                  /*begin
                                    select nvl(sum(qtywidrw),0) + p_amtwidrw into v_qtywidrw
                                      from tobfsum
                                     where codempid = p_codempid
                                       and codobf = p_codobf;
                                  exception when no_data_found then
                                    v_qtywidrw := p_amtwidrw;
                                  end;*/
                                  begin
                                        select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
                                          from tobfinf
                                         where codempid = p_codempid
                                           and codobf = p_codobf
                                           and numvcher <> p_numvcher;
                                    exception when no_data_found then
                                        v_qtywidrw := p_amtwidrw;
                                  end;
                                  begin
                                        select count(*) + 1
                                          into v_numtsmit
                                          from tobfinf
                                         where codempid = p_codempid
                                           and codobf = p_codobf
                                           and numvcher <> p_numvcher;
                                    exception when no_data_found then
                                        v_numtsmit := 1;
                                    end;
                                end if;
                                v_flgsecur := true;
                                exit;
                            end if;
                        end if;
                    end loop;
                end if;
            end if;
        end loop;
        if not v_flgsecur then
            v_errorno := 'HR2055';
        else
            p_numtsmit := v_numtsmit;
            if v_numtsmit > v_qtytalw then
                v_errorno := 'BF0054';
            end if;

            if v_qtywidrw > v_qtyalw then
                v_errorno := 'BF0053';
            end if;
        end if;
    -- return error no
    return v_errorno;
    end benefit_secure_man;

     function benefit_secure_comp return varchar2 is
        v_flglimit  tobfcde.flglimit%type;
        v_qtyalw    tobfcdet.qtyalw%type;
        v_qtytalw   tobfcdet.qtytalw%type;
        v_qtytwidrw number;
        v_flgsecur  boolean := false;
        v_qtywidrw  number;

        v_errorno    varchar2(10 char);
        cursor c1 is
          select a.syncond,b.flglimit,b.amtvalue,b.qtyalw,b.qtytalw,b.amtalw
            from tobfcfp a, tobfcfpd b
           where a.codcomp = b.codcomp
             and a.dtestart = b.dtestart
             and a.numseq = b.numseq
             and p_codcomp like a.codcomp ||'%'
           --and trunc(p_dtereq) between trunc(a.dtestart) and trunc(a.dteend) --<< user25 Date: 30/08/2021 5. BF Module #6823
             and trunc(p_dtereq) between nvl(trunc(a.dtestart),trunc(p_dtereq)) and nvl(trunc(a.dteend),trunc(p_dtereq)) --<< user25 Date: 30/08/2021 5. BF Module #6823
             and b.codobf = nvl(p_codobf,b.codobf)
           order by a.numseq;
    begin
        for i in c1 loop
            v_flgsecur  := true;
            v_qtytalw   := i.qtytalw;
            v_flglimit  := i.flglimit;
            v_qtyalw := i.qtyalw;


            if i.flglimit = 'M' then
                begin
                    select nvl(sum(b.qtywidrw),0)+nvl(p_qtywidrw,0),count(a.numvcomp)+1
                      into v_qtywidrw,v_qtytwidrw
                      from tobfcomp a, tobfcompd b
                     where a.numvcomp = b.numvcomp
                       and a.codcomp = p_codcomp
                       and a.codpos = p_codpos
                       and b.codobf = p_codobf
                       and a.numvcomp <> p_numvcomp
                       and to_char(a.dtereq,'mmyyyy') = to_char(p_dtereq,'mmyyyy');
                end;
            elsif i.flglimit = 'Y' then
                begin
                    select nvl(sum(b.qtywidrw),0)+nvl(p_qtywidrw,0),count(a.numvcomp)+1
                      into v_qtywidrw,v_qtytwidrw
                      from tobfcomp a, tobfcompd b
                     where a.numvcomp = b.numvcomp
                       and a.codcomp = p_codcomp
                       and a.codpos = p_codpos
                       and b.codobf = p_codobf
                       and a.numvcomp <> p_numvcomp
                       and to_char(a.dtereq,'yyyy') = to_char(p_dtereq,'yyyy');
                end;
            elsif i.flglimit = 'A' then
                begin
                    select nvl(sum(b.qtywidrw),0)+nvl(p_qtywidrw,0),count(a.numvcomp)+1
                      into v_qtywidrw,v_qtytwidrw
                      from tobfcomp a, tobfcompd b
                     where a.numvcomp = b.numvcomp
                       and a.codcomp = p_codcomp
                       and a.codpos = p_codpos
                       and b.codobf = p_codobf
                       and a.numvcomp <> p_numvcomp;
                end;
            end if;
            v_flgsecur := true;
            exit;
        end loop;

        if not v_flgsecur then
            v_errorno := 'HR2055';
        else
            p_qtytwidrw := v_qtywidrw;
            if v_qtytwidrw > v_qtytalw then
                v_errorno := 'BF0054';
            end if;

            if v_qtywidrw > v_qtyalw then
                v_errorno := 'BF0053';
            end if;

        end if;
        return v_errorno;
    end benefit_secure_comp;

END HRBF44E;

/
