--------------------------------------------------------
--  DDL for Package Body HRESH8X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRESH8X" as
  procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codempid         := upper(hcm_util.get_string(json_obj,'codempid'));
        p_numcont         :=  hcm_util.get_string(json_obj,'numcont');
        p_codapp           := 'HRBF5BXX';

    end initial_value;

    procedure check_codempid as
        v_temp varchar2(1 char);
    begin
        if p_codempid is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
            from temploy1
            where codempid = p_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        end;
    end check_codempid;

    procedure gen_index(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_row_secur     number := 0;
        cursor c1 is
            select a.dtelonst,a.numcont,a.amtlon,a.amtnpfin,a.dteaccls,a.codlon,a.numlon,a.codcomp,b.numlvl
            from tloaninf a, temploy1 b
            where a.codempid like p_codempid
            and a.codempid = b.codempid
            order by a.dtelonst,a.numcont;
    begin

        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            v_row_secur := v_row_secur+1;
            obj_data := json_object_t();
            obj_data.put('dtelonst',to_char(i.dtelonst,'dd/mm/yyyy'));
            obj_data.put('numcont',i.numcont);
            obj_data.put('amtlon',i.amtlon);
            obj_data.put('amtnpfin',i.amtnpfin);
            obj_data.put('dteaccls',to_char(i.dteaccls,'dd/mm/yyyy'));
            obj_data.put('codlon',i.codlon);
            obj_data.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));
            obj_data.put('numlon',i.numlon);
            obj_rows.put(to_char(v_row_secur-1),obj_data);
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLOANINF');
        end if;
        if param_msg_error is null then
          json_str_output := obj_rows.to_clob;
        else
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_codempid;
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
        obj_head        json_object_t;

        cursor c1detail is
            select a.rateilon,a.stalon,a.dtelpay,a.desaccls,a.dteappr,a.codappr,a.amtiflat,a.amtpaybo,a.qtyperiod,a.amttlpay, a.typpayamt,a.reaslon,a.dteissue,a.dtelonen,a.dtestcal,a.typintr,a.dtelonst,a.numcont,a.amtlon,a.amtnpfin,a.dteaccls,a.codlon,a.numlon,a.codcomp,b.numlvl,a.codempid
            from tloaninf a, temploy1 b
            where a.numcont like p_numcont
            and a.codempid = b.codempid;

    begin

        for i in c1detail loop
            obj_head := json_object_t();
            obj_head.put('numcont',i.numcont);
            obj_head.put('codempid',i.codempid);
            obj_head.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));
            obj_head.put('dtelonst',to_char(i.dtelonst,'dd/mm/yyyy'));
            obj_head.put('codlon',i.codlon);
            obj_head.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));
            obj_head.put('typintr',i.typintr);
            obj_head.put('typintr_desc',get_tlistval_name('TYPINTREST',i.typintr,global_v_lang));
            obj_head.put('rateilon',i.rateilon);

            obj_head.put('amtlon',i.amtlon);
            obj_head.put('dteissue',to_char(i.dteissue,'dd/mm/yyyy'));
            obj_head.put('numlon', i.numlon);
            obj_head.put('numlon_year', floor(i.numlon/12));
            obj_head.put('numlon_month', MOD(i.numlon,12));
            obj_head.put('dtestcal',to_char(i.dtestcal,'dd/mm/yyyy'));
            obj_head.put('reaslon', i.reaslon);
            obj_head.put('dtelonst',to_char(i.dtelonst,'dd/mm/yyyy'));
            obj_head.put('dtelonen',to_char(i.dtelonen,'dd/mm/yyyy'));

            obj_head.put('typpayamt', i.typpayamt);
            obj_head.put('typpayamt_desc', get_tlistval_name('LOANPAYMT2',i.typpayamt,global_v_lang));
            obj_head.put('amttlpay', i.amttlpay);
            obj_head.put('qtyperiod', i.qtyperiod);
            obj_head.put('amtpaybo', i.amtpaybo);
            obj_head.put('amtiflat', i.amtiflat);

            obj_head.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            obj_head.put('codappr', i.codappr);
            obj_head.put('codappr_desc',get_temploy_name(i.codappr,global_v_lang));

            obj_head.put('stalon',i.stalon);
            obj_head.put('stalon_desc',get_tlistval_name('STALOAN',i.stalon,global_v_lang));
            obj_head.put('dteaccls',to_char(i.dteaccls,'dd/mm/yyyy'));
            obj_head.put('amtnpfin',i.amtnpfin);
            obj_head.put('dtelpay',to_char(i.dtelpay,'dd/mm/yyyy'));
            obj_head.put('qtyperiod',i.qtyperiod);
            obj_head.put('desaccls',i.desaccls);
            obj_head.put('coderror',200);
        end loop;
        json_str_output :=  obj_head.to_clob;
    end gen_detail;

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  BEGIN
        initial_value(json_str_input);
        gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail;

    procedure gen_detail_tab2(json_str_output out clob) as
        obj_data        json;
        obj_data_child  json;
        v_row           number := 0;

        cursor c1 is
            select codcolla,amtcolla,numrefer,descolla
            from tloancol  a
            where a.numcont = p_numcont
            order by codcolla;

    begin

        obj_data  := json();
        v_row := 0;
        for k in c1 loop
            v_row := v_row+1;
            obj_data_child := json();
            obj_data_child.put('codcolla',k.codcolla);
            obj_data_child.put('codcolla_desc', get_tcodec_name('TCODCOLA', k.codcolla, global_v_lang));
            obj_data_child.put('amtcolla',k.amtcolla);
            obj_data_child.put('numrefer',k.numrefer);
            obj_data_child.put('descolla',k.descolla);
            obj_data.put(v_row-1,obj_data_child);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_detail_tab2;

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) AS
  BEGIN
        initial_value(json_str_input);
        gen_detail_tab2(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_tab2;

    procedure gen_detail_tab3(json_str_output out clob) as
        obj_data_child        json;
        obj_data        json;
        v_row           number := 0;

        cursor c1 is
            select a.codempgar,b.codpos,b.codcomp,b.dteempmt,a.amtgar
            from tloangar  a, temploy1 b
            where a.numcont = p_numcont
            and b.codempid = a.codempgar
            order by codempgar;

    begin

            obj_data  := json();
            v_row := 0;
            for j in c1 loop
                v_row := v_row+1;
                obj_data_child := json();
                obj_data_child.put('image',j.codempgar);
                obj_data_child.put('codempgar',j.codempgar);
                obj_data_child.put('codempgar_desc',get_temploy_name(j.codempgar,global_v_lang));
                obj_data_child.put('codpos',j.codpos);
                obj_data_child.put('codpos_desc',get_tpostn_name(j.codpos,global_v_lang));
                obj_data_child.put('codcomp',j.codcomp);
                obj_data_child.put('codcomp_desc',get_tcenter_name(j.codcomp, global_v_lang));
                obj_data_child.put('workage',floor(months_between(sysdate,j.dteempmt)/12)||'('||floor(mod(months_between(sysdate,j.dteempmt),12))||')');
                obj_data_child.put('amtgar',j.amtgar);
                obj_data.put(v_row-1,obj_data_child);
            end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_detail_tab3;

  procedure get_detail_tab3(json_str_input in clob, json_str_output out clob) AS
  BEGIN
        initial_value(json_str_input);
        gen_detail_tab3(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_tab3;

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

    procedure gen_report(v_numcont tloaninf.numcont%type, v_doc_no number) as
        v_row_child     number := 0;

        v_numseq                    number;
        add_month number:=0;

        cursor c1detail is
            select a.rateilon,a.stalon,a.dtelpay,a.desaccls,a.dteappr,a.codappr,a.amtiflat,a.amtpaybo,a.qtyperiod,a.amttlpay, a.typpayamt,a.reaslon,a.dteissue,a.dtelonen,a.dtestcal,a.typintr,a.dtelonst,a.numcont,a.amtlon,a.amtnpfin,a.dteaccls,a.codlon,a.numlon,a.codcomp,b.numlvl,a.codempid
            from tloaninf a, temploy1 b
            where a.numcont like v_numcont
            and a.codempid = b.codempid;

        cursor c2 is
            select codcolla,amtcolla,numrefer,descolla
            from tloancol  a
            where a.numcont = v_numcont
            order by codcolla;

        cursor c3 is
            select a.codempgar,b.codpos,b.codcomp,b.dteempmt, a.amtgar
            from tloangar a, temploy1 b
            where a.numcont = v_numcont
            and b.codempid = a.codempgar
            order by codempgar;
    begin

        select max(numseq) into v_numseq
        from ttemprpt
        where codempid = global_v_codempid
        and codapp = p_codapp;
        if v_numseq is null  then
            v_numseq := 0;
        end if;
        v_numseq := v_numseq+1;
        if global_v_lang ='102' then
            add_month := 543*12;
        end if;

        for i in c1detail loop
            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18,item19,item20,item21,item22,item23,item25,item26,item27,item28,item29,item30,item31)
            values (global_v_codempid,p_codapp,v_numseq,'header',i.codempid,get_temploy_name(i.codempid,global_v_lang),i.numcont,to_char(add_months(i.dtelonst,add_month),'dd/mm/yyyy')
            ,to_char(i.rateilon),i.codlon||' - '||get_ttyploan_name(i.codlon,global_v_lang),get_tlistval_name('TYPINTREST',i.typintr,global_v_lang),ltrim(to_char(i.amtlon, '9G999G999D00'))
            ,to_char(add_months(i.dteissue,add_month),'dd/mm/yyyy'),floor(i.numlon/12),MOD(i.numlon,12),to_char(add_months(i.dtestcal,add_month),'dd/mm/yyyy'),i.reaslon,to_char(add_months(i.dtelonst,add_month),'dd/mm/yyyy')
            ,to_char(add_months(i.dtelonen,add_month),'dd/mm/yyyy'),get_tlistval_name('LOANPAYMT2',i.typpayamt,global_v_lang),i.amttlpay, i.qtyperiod, i.amtpaybo
            ,i.amtiflat,to_char(add_months(i.dteappr,add_month),'dd/mm/yyyy'),i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang),get_tlistval_name('STALOAN',i.stalon,global_v_lang)
            ,to_char(add_months(i.dteaccls,add_month),'dd/mm/yyyy'),i.amtnpfin,to_char(add_months(i.dtelpay,add_month),'dd/mm/yyyy'),i.qtyperiod,i.desaccls
            ,v_doc_no);
            v_numseq := v_numseq+1;

            v_row_child := 0;
            for k in c2 loop
                v_row_child := v_row_child+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item9,item10)
                values (global_v_codempid,p_codapp,v_numseq,'asset',k.codcolla,get_tcodec_name('TCODCOLA', k.codcolla, global_v_lang),ltrim(to_char(k.amtcolla, '9G999G999D00')),k.numrefer,k.descolla,v_row_child,v_doc_no);
                v_numseq := v_numseq+1;
            end loop;
            if v_row_child = 0 then
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item9,item10)
                values (global_v_codempid,p_codapp,v_numseq,'asset','','','','','','',v_doc_no);
                v_numseq := v_numseq+1;
            end if;
            v_row_child := 0;
            for j in c3 loop
                v_row_child := v_row_child+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item9,item10)
                values (global_v_codempid,p_codapp,v_numseq,'empgar',j.codempgar,get_temploy_name(j.codempgar,global_v_lang),get_tpostn_name(j.codpos,global_v_lang),get_tcenter_name(j.codcomp, global_v_lang)
                ,to_char(floor(months_between(sysdate,j.dteempmt)/12))||'('||to_char(floor(mod(months_between(sysdate,j.dteempmt),12)))||')',ltrim(to_char(j.amtgar, '9G999G999D00'))
                ,v_row_child,v_doc_no);
                v_numseq := v_numseq+1;
            end loop;
            if v_row_child = 0 then
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item9,item10)
                values (global_v_codempid,p_codapp,v_numseq,'empgar','','','','','','','',v_doc_no);
                v_numseq := v_numseq+1;
            end if;
        end loop;
    end gen_report;

    procedure get_report(json_str_input in clob, json_str_output out clob) as
        param_json      json_object_t;
        json_obj        json_object_t;
        v_doc_no  number:=0;
        v_numcont  tloaninf.numcont%type;
    begin
        initial_value(json_str_input);
        clear_ttemprpt;
        json_obj          := json_object_t(json_str_input);
        param_json := hcm_util.get_json_t(json_obj, 'numcont');
        FOR i IN 0..param_json.get_size - 1 LOOP
            v_doc_no := v_doc_no+1;
            v_numcont :=  hcm_util.get_string_t(param_json,to_char(i));
            gen_report(v_numcont,v_doc_no);
        end loop;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_report;
end hresh8x;

/
