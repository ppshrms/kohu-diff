--------------------------------------------------------
--  DDL for Package Body HRBF4RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4RX" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp         := upper(hcm_util.get_string(json_obj,'codcomp'));
        p_numtravrq       := hcm_util.get_string(json_obj,'numtravrq');
        p_dtereq_start    := to_date(hcm_util.get_string(json_obj,'dtereq_start'),'dd/mm/yyyy');
        p_dtereq_end      := to_date(hcm_util.get_string(json_obj,'dtereq_end'),'dd/mm/yyyy');
        p_dtestrt_start   := to_date(hcm_util.get_string(json_obj,'dtestrt_start'),'dd/mm/yyyy');
        p_dtestrt_end     := to_date(hcm_util.get_string(json_obj,'dtestrt_end'),'dd/mm/yyyy');
        p_codapp          := 'HRBF4RX';

    end initial_value;

    procedure check_index as
    begin
--        if p_codcomp is null
        if (p_dtereq_start is not null and p_dtereq_end is null) or (p_dtereq_start is null and p_dtereq_end is not null)
        or (p_dtestrt_start is not null and p_dtestrt_end is null) or (p_dtestrt_start is null and p_dtestrt_end is not null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_dtereq_start > p_dtereq_end or p_dtestrt_start > p_dtestrt_end then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        if p_codcomp is not null then
            -- check ('HR3007')
            param_msg_error := hcm_secur.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_row_secur number := 0;
        cursor c1 is
            select codcomp,codempid, numtravrq, dtereq, location, dtestrt, dteend, amtreq, codappr, dteappr
              from ttravinf a
             where codcomp like nvl(p_codcomp,'')||'%'
               and dtereq >= nvl(p_dtereq_start,dtereq)
               and dtereq <= nvl(p_dtereq_end,dtereq)
               and dtestrt >= nvl(p_dtestrt_start,dtestrt)
               and dtestrt <= nvl(p_dtestrt_end,dtestrt)
          order by numtravrq;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                v_row_secur := v_row_secur+1;
                obj_data := json();
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('numtravrq',i.numtravrq);
                obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
                obj_data.put('location',i.location);
                obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
                obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
                obj_data.put('amtreq', i.amtreq);
                obj_data.put('codappr', i.codappr);
                obj_data.put('codappr_desc', get_temploy_name(i.codappr,global_v_lang));
                obj_data.put('dteappr', to_char(i.dteappr,'dd/mm/yyyy'));
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if v_row_secur = 0 and v_row > 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTRAVINF');
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure gen_detail(json_str_output out clob) as
        obj_rows        json;
        obj_head        json;
        v_row           number := 0;
        v_codgrpprov    TGRPPROV.codgrpprov%type;
        v_codgrpcnty    tgrpcnty.codgrpcnty%type;

        cursor c1detail is
            select codempid, typetrav, location, codprov, codcnty, dtestrt, timstrt, dteend, timend,
                   qtyday, qtydistance, remark, typepay, dtepay, codpay, numperiod, dtemthpay,
                   dteyrepay, codappr, dteappr
              from ttravinf a
             where a.numtravrq = p_numtravrq;

    begin

        obj_rows := json();
        for i in c1detail loop
            v_row := v_row+1;
            obj_head := json();
            obj_head.put('codempid',i.codempid);
            obj_head.put('typetrav',i.TYPETRAV);
            obj_head.put('location',i.location);
            obj_head.put('codprov',i.codprov);
            obj_head.put('desc_codprov',get_tcodec_name('TCODPROV', i.codprov, global_v_lang));
            begin
                select codgrpprov into v_codgrpprov
                  from tgrpprov
                 where codprov = i.codprov;
            exception when no_data_found then
                v_codgrpprov := '';
            end;
            obj_head.put('codgrpprov',v_codgrpprov);
            begin
                select codgrpcnty into v_codgrpcnty
                  from tgrpcnty
                 where codcnty = i.codcnty;
            exception when no_data_found then
                v_codgrpcnty := '';
            end;            
            obj_head.put('codgrpcnty',get_tcodec_name('TCODGRPCNTY', v_codgrpcnty, global_v_lang));
            obj_head.put('codcnty',i.codcnty);
            obj_head.put('desc_codcnty',get_tcodec_name('TCODCNTY', i.codcnty, global_v_lang));
            obj_head.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
            obj_head.put('timstrt',substr(i.timstrt, 1, 2) || ':' || substr(i.timstrt, 3, 2));
            obj_head.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_head.put('timend',substr(i.timend, 1, 2) || ':' || substr(i.timend, 3, 2));
            obj_head.put('qtyday',i.qtyday);
            obj_head.put('qtydistance',i.qtydistance);
            obj_head.put('remark',i.remark);
            obj_head.put('typepay',i.typepay);
            obj_head.put('dtepay',to_char(i.dtepay,'dd/mm/yyyy'));
            obj_head.put('numperiod',i.numperiod);
            obj_head.put('dtemthpay',i.dtemthpay);
            obj_head.put('dteyrepay',i.dteyrepay);
            obj_head.put('codappr',i.codappr);
            obj_head.put('dteappr',i.dteappr);
            obj_head.put('codpay',i.codpay);
        end loop;
        obj_rows.put(to_char(v_row-1),obj_head);
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure gen_detail_attach(json_str_output out clob) as
        obj_data        json;
        obj_data_child  json;
        v_row_child     number := 0;

        cursor c1attach is
            select numseq, filename, descattch
              from ttravattch  a
             where a.numtravrq = p_numtravrq
          order by numseq;

    begin
        obj_data  := json();
        v_row_child := 0;
        for j in c1attach loop
            v_row_child := v_row_child+1;
            obj_data_child := json();
            obj_data_child.put('numseq',j.numseq);
            obj_data_child.put('filename',j.filename);
            obj_data_child.put('descattch',j.descattch);
            obj_data.put(v_row_child-1,obj_data_child);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_detail_attach;

    procedure get_detail_attach(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_attach(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail_attach;

    procedure gen_detail_expense(json_str_output out clob) as
        obj_data        json;
        obj_data_child  json;
        v_row_child     number := 0;

        cursor c1expense is
            select codexp,codtravunit,amtalw,qtyunit,amtreq
            from ttravinfd  a
            where a.numtravrq = p_numtravrq
            order by codexp;

    begin
        obj_data  := json();
        v_row_child := 0;
        for k in c1expense loop
            v_row_child := v_row_child+1;
            obj_data_child := json();
            obj_data_child.put('codexp',k.codexp);
            obj_data_child.put('codexp_desc', get_tcodec_name('TCODEXP', k.codexp, global_v_lang));
            obj_data_child.put('codtravunit',k.codtravunit);
            obj_data_child.put('codtravunit_desc', get_tcodec_name('TCODTRAVUNIT', k.CODTRAVUNIT, global_v_lang));
            obj_data_child.put('amtalw',k.amtalw);
            obj_data_child.put('qtyunit',k.qtyunit);
            obj_data_child.put('amtreq',k.amtreq);
            obj_data.put(v_row_child-1,obj_data_child);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_detail_expense;

    procedure get_detail_expense(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_expense(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail_expense;

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

    procedure gen_report(json_str_input in clob) as
        v_row           number := 0;
        v_numtravrq_no  number:=0;
        v_numseq        number;
        v_total         number;
        add_month       number:=0;
        v_codgrpprov    tgrpprov.codgrpprov%type;
        v_codgrpcnty    tgrpcnty.codgrpcnty%type;
        v_numtravrq     ttravinf.numtravrq%type;
        param_json      json;
        json_obj        json;
        v_image          varchar2(200);
        v_has_image      varchar2(1) := 'N';
        v_ttemprpt      ttemprpt%rowtype;

        cursor c1detail is
            select codempid,typetrav, location, codprov, codcnty, dtestrt,timstrt,dteend,timend,
                   qtyday,qtydistance, remark,typepay, dtepay, codpay,numperiod,dtemthpay,
                   dteyrepay, codappr, dteappr
            from ttravinf  a
            where a.numtravrq = v_numtravrq;

        cursor c2attach is
            select numseq, filename, descattch
              from ttravattch  a
             where a.numtravrq = v_numtravrq
          order by numseq;

        cursor c3expense is
            select codexp,codtravunit,amtalw,qtyunit,amtreq
              from ttravinfd  a
             where a.numtravrq = v_numtravrq
          order by codexp;
    begin
        v_numseq := 0;

        if global_v_lang ='102' then
            add_month := 543*12;
        end if;
        json_obj          := json(json_str_input);
        param_json := hcm_util.get_json(json_obj, 'numtravrq');

        for i in 0..param_json.count - 1 loop
            v_numtravrq_no := v_numtravrq_no+1;
            v_numtravrq :=  hcm_util.get_string(param_json,to_char(i));
            for i in c1detail loop
                v_row := 0;
                for j in c2attach loop
                    insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item20)
                         values (global_v_codempid,p_codapp,v_numseq,'attach',j.numseq,j.filename,j.descattch,v_numtravrq_no);
                    v_numseq    := v_numseq+1;
                    v_row       := v_row+1;
                end loop;
                if v_row = 0 then
                    insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item20)
                         values (global_v_codempid,p_codapp,v_numseq,'attach',' ',' ',' ',v_numtravrq_no);
                    v_numseq    := v_numseq+1;
                end if;
                v_row := 0;
                v_total := 0;
                for k in c3expense loop
                    v_row := v_row+1;
                    insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item20)
                         values (global_v_codempid,p_codapp,v_numseq,'expense',
                         k.codexp,
                         get_tcodec_name('TCODEXP', k.codexp, global_v_lang)
                         ,get_tcodec_name('TCODTRAVUNIT', k.codtravunit, global_v_lang),
                         nvl(to_char(k.amtalw, 'fm999,999,990.00'), ' '),
                         nvl(to_char(k.qtyunit, 'fm999,999,990.00'), ' '),
                         nvl(to_char(k.amtreq, 'fm999,999,990.00'), ' '),
                         v_row,
                         v_numtravrq_no);
                    v_numseq    := v_numseq+1;
                    v_total     := v_total+k.amtreq;
                end loop;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item20)
                     values (global_v_codempid,p_codapp,v_numseq,
                     'expense',' ',' ',' ',' ',
                     get_label_name('HRBF4RXC1',global_v_lang,'160'),
                     nvl(to_char(v_total, 'fm999,999,990.00'), ' '),
                     ' ',
                     v_numtravrq_no);
                v_numseq    := v_numseq+1;

                begin
                    select codgrpprov into v_codgrpprov
                      from tgrpprov
                     where codprov = i.codprov;
                exception when no_data_found then
                    v_codgrpprov := '';
                end;
                begin
                    select codgrpcnty into v_codgrpcnty
                      from tgrpcnty
                     where codcnty = i.codcnty;
                exception when no_data_found then
                    v_codgrpcnty := '';
                end;            

                begin
                  select namimage
                   into v_image
                   from tempimge
                   where codempid = i.codempid;
                exception when no_data_found then
                  v_image := '';
                end;
               --<<check existing image
                if v_image is not null then
                  v_image := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1') || '/' || v_image;
                  v_has_image   := 'Y';
                else
--                  v_image := get_tsetup_value('PATHWORKPHP')||'default-emp.png';
                  v_has_image   := 'N';
                end if;

                if i.typetrav = 'I' then
                    v_ttemprpt.item5 := get_tcodec_name('TCODPROV', i.codprov, global_v_lang);
                    v_ttemprpt.item6 := get_tcodec_name('TCODGRPPROV', v_codgrpprov, global_v_lang);
                    v_ttemprpt.item23 := get_label_name('HRBF4RXC2',global_v_lang,'50');
                    v_ttemprpt.item24 := get_label_name('HRBF4RXC2',global_v_lang,'60');
                elsif i.typetrav = 'O' then
                    v_ttemprpt.item5 := get_tcodec_name('TCODCNTY', i.codcnty, global_v_lang);
                    v_ttemprpt.item6 := get_tcodec_name('TCODGRPCNTY', v_codgrpcnty, global_v_lang);
                    v_ttemprpt.item23 := get_label_name('HRBF4RXC2',global_v_lang,'55');
                    v_ttemprpt.item24 := get_label_name('HRBF4RXC2',global_v_lang,'65');
                end if;

                if i.typepay = '1' then
                    v_ttemprpt.item25 := get_label_name('HRBF4RXC2',global_v_lang,'160');
                    v_ttemprpt.item26 := get_label_name('HRBF4RXC2',global_v_lang,'170');
                    v_ttemprpt.item27 := hcm_util.get_date_buddhist_era(i.dtepay);
                elsif i.typepay = '2' then
                    v_ttemprpt.item25 := get_label_name('HRBF4RXC2',global_v_lang,'165');
                    v_ttemprpt.item26 := get_label_name('HRBF4RXC2',global_v_lang,'290')||'/'||
                                         get_label_name('HRBF4RXC2',global_v_lang,'300')||'/'||
                                         get_label_name('HRBF4RXC2',global_v_lang,'310');
                    v_ttemprpt.item27 := i.numperiod||'/'||
                                         i.dtemthpay||'/'||
--                                         get_nammthful(i.dtemthpay,global_v_lang)||' '||
                                         hcm_util.get_year_buddhist_era(i.dteyrepay);
                end if;

                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,
                            item12,item13,item14,item15,item16,item20,item21,item22,
                            item23, item24, item25, item26, item27)
                     values (global_v_codempid,p_codapp,v_numseq,'header',
                            i.codempid,
                            get_temploy_name(i.codempid,global_v_lang),
                            i.location,
                            v_ttemprpt.item5,
                            v_ttemprpt.item6,
                            to_char(add_months(i.dtestrt,add_month),'dd/mm/yyyy')||' '||substr(i.timstrt, 1, 2) || ':' || substr(i.timstrt, 3, 2)||' - '||to_char(add_months(i.dteend,add_month),'dd/mm/yyyy')||' '||substr(i.timend, 1, 2) || ':' || substr(i.timend, 3, 2),
                            i.qtyday,
--                            i.qtydistance,
                            to_char(i.qtydistance, 'fm999,999,990'),
                            i.remark,
                            i.typepay,
                            to_char(add_months(i.dtepay,add_month),'dd/mm/yyyy'),
                            i.numperiod,
                            i.dtemthpay,
                            i.dteyrepay,
                            i.codpay||' - '||GET_TINEXINF_NAME(i.codpay,global_v_lang),v_numtravrq_no,v_image,v_has_image,
                            v_ttemprpt.item23,v_ttemprpt.item24,v_ttemprpt.item25,v_ttemprpt.item26,v_ttemprpt.item27);
                v_numseq := v_numseq+1;
            end loop;
        end loop;

    end gen_report;

    procedure get_report(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        clear_ttemprpt;
        if param_msg_error is null then
            gen_report(json_str_input);
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            else
                commit;
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_report;

END HRBF4RX;

/
