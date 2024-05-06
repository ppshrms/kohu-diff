--------------------------------------------------------
--  DDL for Package Body HRBF4ME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4ME" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp               := upper(hcm_util.get_string(json_obj,'p_codcomp'));
        p_codempid_query        := upper(hcm_util.get_string(json_obj,'p_codempid_query'));
        p_dtereqstr             := to_date(hcm_util.get_string(json_obj,'p_dtereqstr'),'dd/mm/yyyy');
        p_dtereqend             := to_date(hcm_util.get_string(json_obj,'p_dtereqend'),'dd/mm/yyyy');
        p_dtestrt               := to_date(hcm_util.get_string(json_obj,'p_dtestrt'),'dd/mm/yyyy');
        p_dteend                := to_date(hcm_util.get_string(json_obj,'p_dteend'),'dd/mm/yyyy');
        p_numtravrq             := hcm_util.get_string(json_obj,'p_numtravrq');
        p_dtereq                := to_date(hcm_util.get_string(json_obj,'p_dtereq'),'dd/mm/yyyy');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if (p_codcomp is null and p_codempid_query is null)
           or (p_dtereqstr is not null and p_dtereqend is null) or (p_dtereqstr is null and p_dtereqend is not null)
           or (p_dtestrt is not null and p_dteend is null) or (p_dtestrt is null and p_dteend is not null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if  p_dtereqstr > p_dtereqend or p_dtestrt > p_dteend  then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        if p_codcomp is not null then
            param_msg_error :=  HCM_SECUR.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;

        if p_codempid_query is not null then
            begin
                select 'X' into v_temp
                  from TEMPLOY1
                 where codempid = p_codempid_query;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            if secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal, global_v_numlvlsalst, global_v_numlvlsalen) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        cursor c1 is
            select codempid, numtravrq, dtereq, location, dtestrt, dteend, codappr,flgvoucher,flgtranpy
              from ttravinf a
             where codcomp like nvl(p_codcomp,codcomp)||'%'
               and codempid = nvl(p_codempid_query,codempid)
               and dtereq >= nvl(p_dtereqstr,dtereq)
               and dtereq <= nvl(p_dtereqend,dtereq)
               and dtestrt  >= nvl(p_dtestrt,dtestrt)
               and dtestrt <= nvl(p_dteend,dtestrt)
          order by codempid,numtravrq;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('numtravrq',i.numtravrq);
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('location',i.location);
            obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
            obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_data.put('status',get_label_name('HRBF4MEP2',global_v_lang,'60'));
            obj_data.put('staappr','Y');
            obj_data.put('flgtranpy', i.flgtranpy);
            obj_data.put('flgvoucher', i.flgvoucher);

            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if p_codempid_query is not null then
            p_codcomp := null;
        end if;
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

    procedure check_detail as
        v_temp varchar2(1 char);
    begin
        if p_codempid_query is not null then
            begin
                select 'X' into v_temp
                  from TEMPLOY1
                 where codempid = p_codempid_query;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            if secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal, global_v_numlvlsalst, global_v_numlvlsalen) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_detail;

    procedure check_detail_add as
        v_temp varchar2(1 char);
    begin
        if p_codempid_query is null or p_dtereq is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codempid_query is not null then
            begin
                select staemp into v_temp
                  from temploy1
                 where codempid = p_codempid_query;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            if v_temp = '0' then
                param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                return;
            end if;
            if secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal, global_v_numlvlsalst, global_v_numlvlsalen) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_detail_add;

    procedure gen_detail(json_str_output out clob) as
        obj_rows        json;
        obj_head        json;

        v_row           number := 0;

        v_codgrpprov    tgrpprov.codgrpprov%type;
        v_codgrpcnty    tgrpcnty.codgrpcnty%type;

        cursor c1detail is
            select typetrav, location, codprov, codcnty, dtestrt,timstrt,dteend,timend,
                   qtyday,qtydistance, remark,typepay, dtepay, codpay,numperiod,dtemthpay,
                   dteyrepay, codappr, dteappr, flgtranpy, flgvoucher, codempid, numtravrq,
                   dtereq
              from ttravinf  a
             where a.numtravrq = p_numtravrq;
    begin
        obj_head    := json();
        obj_head.put('coderror',200);

        for i in c1detail loop
            obj_head.put('codempid',i.codempid);
            obj_head.put('numtravrq',i.numtravrq);
            obj_head.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_head.put('typetrav',i.typetrav);
            obj_head.put('location',i.location);
            obj_head.put('codprov',i.codprov);
            begin
                select codgrpprov into v_codgrpprov
                  from tgrpprov
                 where codprov = i.codprov;
            exception when no_data_found then
                v_codgrpprov := '';
            end;            
            obj_head.put('codgrpprov',get_tcodec_name('TCODGRPPROV', v_codgrpprov, global_v_lang));
            obj_head.put('codcnty',i.codcnty);
            begin
                select codgrpcnty into v_codgrpcnty
                  from tgrpcnty
                 where codcnty = i.codcnty;
            exception when no_data_found then
                v_codgrpcnty := '';
            end;            
            obj_head.put('codgrpcnty',get_tcodec_name('TCODGRPCNTY', v_codgrpcnty, global_v_lang));
            obj_head.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
            obj_head.put('timstrt',i.timstrt);
            obj_head.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_head.put('timend',i.timend);
            obj_head.put('qtyday',i.qtyday);
            obj_head.put('qtydistance',i.qtydistance);
            obj_head.put('remark',i.remark);
            obj_head.put('typepay',i.typepay);
            obj_head.put('dtepay',to_char(i.dtepay,'dd/mm/yyyy'));
            obj_head.put('dteyrepay',i.dteyrepay);
            obj_head.put('dtemthpay',i.dtemthpay);
            obj_head.put('numperiod',i.numperiod);
            obj_head.put('codpay',i.codpay);
            obj_head.put('desc_codpay',get_tinexinf_name(i.codpay,global_v_lang));
            obj_head.put('codappr',i.codappr);
            obj_head.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));   
            if i.flgvoucher = 'Y' or i.flgtranpy = 'Y' then                                            
                obj_head.put('message',replace(get_error_msg_php('HR1510',global_v_lang),'@#$%400'));  --> Peerasak || Issue#8708 || 30/11/2022
            end if;
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_detail;

    procedure gen_detail_default(json_str_output out clob) as
        obj_rows        json;
        obj_head        json;
        obj_result      json;

        obj_data        json;
        obj_data_child  json;
        v_row           number := 0;
        v_row_child     number := 0;

        v_codcompy      tconttrav.codcompy%type;
        v_codpay        tconttrav.codpay%type;

    begin
        obj_rows    := json();
        obj_head    := json();
        obj_data    := json();
        v_row_child := 0;

        obj_head.put('coderror',200);
        obj_head.put('codempid',p_codempid_query);
        obj_head.put('numtravrq','');
        obj_head.put('dtereq',to_char(sysdate,'dd/mm/yyyy'));
        obj_head.put('typepay','2');
        obj_head.put('codappr',global_v_codempid); -- user56
        obj_head.put('dteappr',to_char(sysdate,'dd/mm/yyyy'));-- user56

--        obj_head.put('attach',obj_data);

        begin
            select codcomp into p_codcomp
              from TEMPLOY1
             where codempid = p_codempid_query;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;
        v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);

        begin
            select codinctv into v_codpay
              from TCONTRBF
             where codcompy = v_codcompy
               and dteeffec = (select max(dteeffec)
                                 from TCONTRBF
                                where codcompy = v_codcompy
                                  and dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'));
        exception when no_data_found then
            v_codpay := '';
        end;
        obj_head.put('codpay',v_codpay);

        obj_data  := json();
        v_row_child := 0;
--        obj_head.put('expense',obj_data);
        obj_head.put('message','');

        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_detail_default;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        v_temp varchar2(1);
    begin
        initial_value(json_str_input);
        check_detail;
        if param_msg_error is null then
            if p_numtravrq is not null then
                begin
                    select 'Y' into v_temp
                      from ttravinf a
                     where a.numtravrq = p_numtravrq;
                exception when no_data_found then
                    v_temp := 'N';
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TTRAVINF');
                end;
            elsif p_numtravrq is null then
                check_detail_add;
                v_temp := 'N';
            end if;
            if param_msg_error is null then
                if v_temp = 'Y' then
                    gen_detail(json_str_output);
                elsif v_temp = 'N' then
                    gen_detail_default(json_str_output);
                end if;
            end if;
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
        obj_data    := json();
        v_row_child := 0;
        for j in c1attach loop
            v_row_child     := v_row_child+1;
            obj_data_child  := json();
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
        gen_detail_attach(json_str_output);
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
        v_codcompy      tconttrav.codcompy%type;
        cursor c1expense is
            select codexp,codtravunit,amtalw,qtyunit,amtreq
              from ttravinfd  a
             where a.numtravrq = p_numtravrq
          order by codexp;

    begin
        obj_data    := json();
        v_row_child := 0;
        for k in c1expense loop
            v_row_child := v_row_child+1;
            obj_data_child := json();
            obj_data_child.put('codexp',k.codexp);
            obj_data_child.put('codtravunit',k.codtravunit);
            obj_data_child.put('desc_codtravunit', get_tcodec_name('TCODTRAVUNIT', k.CODTRAVUNIT, global_v_lang));
            obj_data_child.put('amtalw',k.amtalw);
            obj_data_child.put('qtyunit',k.qtyunit);
            obj_data_child.put('amtreq',k.amtreq);
            obj_data.put(v_row_child-1,obj_data_child);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_detail_expense;

    procedure get_detail_expense(json_str_input in clob, json_str_output out clob) as
        v_temp varchar2(1 char);
    begin
        initial_value(json_str_input);
        gen_detail_expense(json_str_output);
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail_expense;

    procedure gen_codexp(json_str_input  in clob, json_str_output out clob) as
        json_obj        json;
        obj_rows        json;
        obj_head        json;
        v_codcompy      tconttrav.codcompy%type;
        v_codexp        tconttrav.codexp%type;
        v_codprov       TTRAVINF.codprov%type;
        v_codcnty       TTRAVINF.codcnty%type;
        v_row           number := 0;
        v_row_2           number := 0;

        v_syncond       TCONTTRAVD.syncond%TYPE;
        v_stmt          long;
        v_flg           boolean;
        v_codcomp       temploy1.codcomp%TYPE;
        v_codpos        temploy1.codpos%TYPE;
        v_numlvl        temploy1.numlvl%TYPE;
        v_jobgrade      temploy1.jobgrade%TYPE;
        v_typemp        temploy1.typemp%TYPE;
        v_codbrlc       temploy1.codbrlc%TYPE;
        v_dteeffec      tconttrav.dteeffec%type;
        v_qtyunit       ttravinfd.qtyunit%type;
        cursor c1 is
            select codexp, codtravunit, dteeffec
              from tconttrav  a
             where codcompy = v_codcompy
               and  codexp = v_codexp
               and dteeffec = (select max(dteeffec)
                                 from TCONTTRAV
                                where codcompy = v_codcompy
                                  and  codexp = v_codexp
                                  and dteeffec <= to_date(to_char(p_dtestrt,'dd/mm/yyyy'),'dd/mm/yyyy'));
        cursor c2 is
            select syncond,amtalw
              from TCONTTRAVD
             where codcompy = v_codcompy
               and codexp = v_codexp
               and dteeffec = v_dteeffec
          order by numseq;
    begin
        json_obj            := json(json_str_input);
--        p_codempid_query    := upper(hcm_util.get_string(json_obj,'p_codempid_query'));
        v_codexp            := upper(hcm_util.get_string(json_obj,'p_codexp'));
        v_qtyunit           := hcm_util.get_string(json_obj,'p_qtyunit');
--        p_dtestrt           := to_date(hcm_util.get_string(json_obj,'p_dtestrt'),'dd/mm/yyyy');

        begin
            select codcomp,codpos,numlvl,jobgrade,typemp,codbrlc
              into v_codcomp,v_codpos,v_numlvl,v_jobgrade,v_typemp,v_codbrlc
              from temploy1
             where codempid = p_codempid_query;
        end;
        v_codcompy  := hcm_util.get_codcomp_level(v_codcomp,1);
        v_flg       := false;
        obj_rows    := json();
        for i in c1 loop
            v_dteeffec  := i.dteeffec;
            v_row       := v_row+1;
            obj_head    := json();
            obj_head.put('codexp',i.codexp);
            obj_head.put('codtravunit',i.codtravunit);
            obj_head.put('desc_codtravunit', get_tcodec_name('TCODTRAVUNIT', i.CODTRAVUNIT, global_v_lang));
            obj_head.put('amtalw','0');
            v_row_2 := 0;
            for k in c2 loop
                if k.syncond is not null then
                    v_row_2 := v_row_2 + 1;
                    v_syncond := k.syncond;
                    v_syncond := replace(v_syncond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                    v_syncond := replace(v_syncond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                    v_syncond := replace(v_syncond,'TEMPLOY1.NUMLVL',v_numlvl);
                    v_syncond := replace(v_syncond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                    v_syncond := replace(v_syncond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                    v_syncond := replace(v_syncond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                    v_syncond := replace(v_syncond,'TGRPPROV.CODGRPPROV',''''||v_codprov||'''');
                    v_syncond := replace(v_syncond,'TGRPCNTY.CODGRPCNTY',''''||v_codcnty||'''');

                    v_stmt  := 'select count(*) from TEMPLOY1 where codempid = '''||p_codempid_query||''' and '||v_syncond;
                    v_flg   := execute_stmt(v_stmt);
                    if v_flg = true then
                        obj_head.put('amtalw',k.amtalw);
                        if v_qtyunit is not null then
                            obj_head.put('amtreq',k.amtalw * v_qtyunit);
                        end if;
                        exit;
                    end if;
                end if;
            end loop;
--            obj_head.put('amtreq','0');

            if v_flg = true then
                exit;
            end if;
        end loop;
        if v_row = 0 or v_flg = false then
            param_msg_error := get_error_msg_php('BF0049',global_v_lang);
        end if;
        if v_row_2 = 0 or v_flg = false then
            param_msg_error := get_error_msg_php('BF0049',global_v_lang);
        end if;
        obj_rows.put(to_char(v_row-1),obj_head);
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_codexp;

    procedure get_codexp(json_str_input in clob, json_str_output out clob) as
        v_codcompy      tconttrav.codcompy%type;
    begin
        initial_value(json_str_input);
        gen_codexp(json_str_input, json_str_output);
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_codexp;

    procedure gen_codprov(json_str_input  in clob, json_str_output out clob) as
        json_obj        json;
        obj_head        json;
        v_codprov       TTRAVINF.codprov%type;
        v_codgrpprov    TGRPPROV.codgrpprov%type;
    begin
        json_obj        := json(json_str_input);
        v_codprov       := upper(hcm_util.get_string(json_obj,'p_codprov'));

        obj_head        := json();
        obj_head.put('coderror',200);
        begin
            select codgrpprov into v_codgrpprov
              from tgrpprov
             where codprov = v_codprov;
        exception when no_data_found then
            v_codgrpprov := '';
        end;
        obj_head.put('desc_codgrpprov', get_tcodec_name('TCODGRPPROV', v_codgrpprov, global_v_lang));
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_codprov;

    procedure get_codprov(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        gen_codprov(json_str_input, json_str_output);
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_codprov;

    procedure gen_codcnty(json_str_input  in clob, json_str_output out clob) as
        json_obj        json;
        obj_head        json;
        v_codcnty       TTRAVINF.CODCNTY%type;
        v_codgrpcnty    TGRPCNTY.codgrpcnty%type;
    begin
        json_obj        := json(json_str_input);
        v_codcnty       := upper(hcm_util.get_string(json_obj,'p_codcnty'));

        obj_head        := json();
        obj_head.put('coderror',200);

        begin
            select codgrpcnty into v_codgrpcnty
              from tgrpcnty
             where codcnty = v_codcnty;
        exception when no_data_found then
            v_codgrpcnty := '';
        end;
        obj_head.put('desc_codgrpcnty', get_tcodec_name('TCODGRPCNTY', v_codgrpcnty, global_v_lang));
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_codcnty;

    procedure get_codcnty(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        gen_codcnty(json_str_input, json_str_output);
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_codcnty;

    procedure check_param_detail(param_json json) as
        v_typetrav      ttravinf.typetrav%type;
        v_location      ttravinf.location%type;
        v_codprov       ttravinf.codprov%type;
        v_codcnty       ttravinf.codcnty%type;
        v_dtestrt       ttravinf.dtestrt%type;
        v_timstrt       ttravinf.timstrt%type;
        v_dteend        ttravinf.dteend%type;
        v_timend        ttravinf.timend%type;
        v_qtyday        ttravinf.qtyday%type;
        v_qtydistance   ttravinf.qtydistance%type;
        v_remark        ttravinf.remark%type;
        v_typepay       ttravinf.typepay%type;
        v_dtepay        ttravinf.dtepay%type;
        v_numperiod     ttravinf.numperiod%type;
        v_dtemthpay     ttravinf.dtemthpay%type;
        v_dteyrepay     ttravinf.dteyrepay%type;
        v_codappr       ttravinf.codappr%type;
        v_dteappr       ttravinf.dteappr%type;
        v_flgvoucher    ttravinf.flgvoucher%type;
        v_flgtranpy     ttravinf.flgtranpy%type;
        v_codpay        ttravinf.codpay%type;

        v_temp          varchar2(1 char);
        v_codcomp       temploy1.codcomp%type;
        v_staemp        temploy1.staemp%type;
        v_typpayroll    tdtepay.typpayroll%type;
        v_dteeffex      temploy1.dteeffex%type;
    begin
        v_codappr       := upper(hcm_util.get_string(param_json,'codappr'));
        v_codcnty       := upper(hcm_util.get_string(param_json,'codcnty'));
        v_codpay        := upper(hcm_util.get_string(param_json,'codpay'));
        v_codprov       := upper(hcm_util.get_string(param_json,'codprov'));
        v_dteappr       := to_date(hcm_util.get_string(param_json,'dteappr'),'dd/mm/yyyy');
        v_dteend        := to_date(hcm_util.get_string(param_json,'dteend'),'dd/mm/yyyy');
        v_dtemthpay     := to_number(hcm_util.get_string(param_json,'dtemthpay'));
        v_dtepay        := to_date(hcm_util.get_string(param_json,'dtepay'),'dd/mm/yyyy');
        v_dtestrt       := to_date(hcm_util.get_string(param_json,'dtestrt'),'dd/mm/yyyy');
        v_dteyrepay     := to_number(hcm_util.get_string(param_json,'dteyrepay'));
        v_location      := hcm_util.get_string(param_json,'location');
        v_numperiod     := to_number(hcm_util.get_string(param_json,'numperiod'));
        v_qtyday        := to_number(hcm_util.get_string(param_json,'qtyday'));
        v_qtydistance   := to_number(hcm_util.get_string(param_json,'qtydistance'));
        v_remark        := hcm_util.get_string(param_json,'remark');
        v_timend        := replace(hcm_util.get_string(param_json,'timend'),':','');
        v_timstrt       := replace(hcm_util.get_string(param_json,'timstrt'),':','');
        v_typepay       := hcm_util.get_string(param_json,'typepay');
        v_typetrav      := hcm_util.get_string(param_json,'typetrav');

-- without codpay
        if v_location is null or ( v_codprov is null and  v_codcnty is null )
            or v_dtestrt is null or v_dteend is null or p_codempid_query is null
            or (v_timstrt is null  and v_timend is not null) or (v_timstrt is not null  and v_timend is null)
            or v_qtyday is null or ( v_typepay = '1' and v_dtepay is null )
            or ( v_typepay = '2' and (v_numperiod is null or v_dtemthpay is null or v_dteyrepay is null))
            or v_codappr is null or v_dteappr is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
        end if;

        if v_codcnty is not null then
            begin
                select 'x' into v_temp
                  from tcodcnty
                 where codcodec = v_codcnty;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCNTY');
                return;
            end;
        end if;

        if v_codprov is not null then
            begin
                select 'x' into v_temp
                  from tcodprov
                 where codcodec = v_codprov;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV');
                return;
            end;
        end if;

        if v_dtepay is not null then
            if v_dtepay < p_dtereq then
                param_msg_error := get_error_msg_php('HR2051',global_v_lang);
                return;
            end if;
        end if;

        if (v_dtestrt > v_dteend) or (v_dtestrt||v_timstrt > v_dteend||v_timend) then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        begin
            select codcomp,typpayroll,staemp,dteeffex 
              into v_codcomp,v_typpayroll,v_staemp, v_dteeffex
              from temploy1
             where codempid = p_codempid_query;
        exception when no_data_found then
            v_codcomp := '';
            v_typpayroll := '';
        end;

        if v_staemp = '9' and v_dtestrt > to_date(to_char(v_dteeffex-1,'dd/mm/yyyy'),'dd/mm/yyyy')  then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            return;
        end if;

        if v_numperiod is not null then
            v_temp := '';
            begin
                select flgcal into v_temp
                  from tdtepay
                 where typpayroll = v_typpayroll
                   and numperiod = v_numperiod
                   and dtemthpay = v_dtemthpay
                   and dteyrepay = v_dteyrepay
                   and codcompy =  hcm_util.get_codcomp_level(v_codcomp,1);
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TDTEPAY');
                return;
            end;
            if v_temp = 'Y' then
              --use PY0073 03/04/2021
              param_msg_error := get_error_msg_php('PY0073',global_v_lang);
              return;
                /*v_temp := '';
                begin
                    select flgcal into v_temp
                    from TDTEPAY
                    where typpayroll = v_typpayroll
                    and numperiod = v_numperiod+1
                    and dtemthpay = v_dtemthpay
                    and dteyrepay = v_dteyrepay
                    and codcompy =  hcm_util.get_codcomp_level(v_codcomp,1);
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TDTEPAY');
                    return;
                end;
                if v_temp = 'Y' then
                    param_msg_error := get_error_msg_php('PY0063',global_v_lang);
                    return;
                end if;*/
            end if;
        end if;

        if v_codappr is not null then
            v_staemp    := '';
            v_dteeffex  := null;
            begin
                select staemp,dteeffex  into v_staemp, v_dteeffex
                  from temploy1
                 where codempid = v_codappr;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            if v_staemp = '9' and v_dteappr > to_date(to_char(v_dteeffex-1,'dd/mm/yyyy'),'dd/mm/yyyy')  then
                param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                return;
            end if;
            if v_staemp = '0' then
                param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                return;
            end if;
            if secur_main.secur2(v_codappr,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;

        if v_dteappr < p_dtereq then
            param_msg_error := get_error_msg_php('HR8615',global_v_lang);
        end if;
    end check_param_detail;

    procedure add_detail(param_json json) as
        v_amtreq        ttravinf.amtreq%type;
        v_numtravrq     ttravinf.numtravrq%type;
        v_typetrav      ttravinf.typetrav%type;
        v_location      ttravinf.location%type;
        v_codprov       ttravinf.codprov%type;
        v_codcnty       ttravinf.codcnty%type;
        v_dtestrt       ttravinf.dtestrt%type;
        v_timstrt       ttravinf.timstrt%type;
        v_dteend        ttravinf.dteend%type;
        v_timend        ttravinf.timend%type;
        v_qtyday        ttravinf.qtyday%type;
        v_qtydistance   ttravinf.qtydistance%type;
        v_remark        ttravinf.remark%type;
        v_typepay       ttravinf.typepay%type;
        v_dtepay        ttravinf.dtepay%type;
        v_numperiod     ttravinf.numperiod%type;
        v_dtemthpay     ttravinf.dtemthpay%type;
        v_dteyrepay     ttravinf.dteyrepay%type;
        v_codappr       ttravinf.codappr%type;
        v_dteappr       ttravinf.dteappr%type;
        v_codpay        ttravinf.codpay%type;
        v_codcomp       ttravinf.codcomp%type;

        v_codcompy      tconttrav.codcompy%type;
        v_max_numtravrq ttravinf.numtravrq%type;
    begin

        v_amtreq        := to_number(hcm_util.get_string(param_json,'amtreq'));
        v_typetrav      := hcm_util.get_string(param_json,'typetrav');
        v_location      := hcm_util.get_string(param_json,'location');
        v_codprov       := upper(hcm_util.get_string(param_json,'codprov'));
        v_codcnty       := upper(hcm_util.get_string(param_json,'codcnty'));
        v_dtestrt       := to_date(hcm_util.get_string(param_json,'dtestrt'),'dd/mm/yyyy');
        v_timstrt       := replace(hcm_util.get_string(param_json,'timstrt'),':','');
        v_dteend        := to_date(hcm_util.get_string(param_json,'dteend'),'dd/mm/yyyy');
        v_timend        := replace(hcm_util.get_string(param_json,'timend'),':','');
        v_qtyday        := to_number(hcm_util.get_string(param_json,'qtyday'));
        v_qtydistance   := to_number(hcm_util.get_string(param_json,'qtydistance'));
        v_remark        := hcm_util.get_string(param_json,'remark');
        v_typepay       := hcm_util.get_string(param_json,'typepay');
        v_dtepay        := to_date(hcm_util.get_string(param_json,'dtepay'),'dd/mm/yyyy');
        v_codpay        := upper(hcm_util.get_string(param_json,'codpay'));
        v_numperiod     := to_number(hcm_util.get_string(param_json,'numperiod'));
        v_dtemthpay     := to_number(hcm_util.get_string(param_json,'dtemthpay'));
        v_dteyrepay     := to_number(hcm_util.get_string(param_json,'dteyrepay'));
        v_codappr       := upper(hcm_util.get_string(param_json,'codappr'));
        v_dteappr       := to_date(hcm_util.get_string(param_json,'dteappr'),'dd/mm/yyyy');
        begin
            select codcomp,hcm_util.get_codcomp_level(codcomp,1) 
              into v_codcomp, v_codcompy
              from temploy1
             where codempid = p_codempid_query;
        exception when no_data_found then
            v_codcomp   := '';
            v_codcompy  := '';
        end;

        begin
            select max(numtravrq) 
              into v_max_numtravrq
              from TTRAVINF
             where numtravrq like v_codcompy||to_char(sysdate,'YY')||to_char(sysdate,'MM')||'%';
        exception when no_data_found then
            v_max_numtravrq := v_codcompy||to_char(sysdate,'YY')||to_char(sysdate,'MM')||'0000';
        end;
        if v_max_numtravrq is null then
            v_max_numtravrq := v_codcompy||to_char(sysdate,'YY')||to_char(sysdate,'MM')||'0000';
        end if;
        v_numtravrq := v_codcompy||to_char(sysdate,'YY')||to_char(sysdate,'MM')||LPAD(SUBSTR(v_max_numtravrq, -4, 4)+1,4,'0');
        p_numtravrq := v_numtravrq;

        if param_msg_error is null then
            INSERT INTO TTRAVINF ( amtreq,codempid,dtereq,numtravrq, typetrav, location, codprov, codcnty, dtestrt, timstrt, dteend, timend,
                                   qtyday,qtydistance,remark,typepay,dtepay,numperiod,dtemthpay,dteyrepay,codappr,dteappr,
                                   flgvoucher,flgtranpy,codpay, codcomp, codcreate, coduser )
            VALUES ( v_amtreq, p_codempid_query,p_dtereq,v_numtravrq, v_typetrav,v_location,v_codprov,v_codcnty,v_dtestrt,v_timstrt,v_dteend,v_timend,
                     v_qtyday,v_qtydistance,v_remark,v_typepay,v_dtepay,v_numperiod,v_dtemthpay,v_dteyrepay,
                     v_codappr,v_dteappr,'N','N',v_codpay,v_codcomp, global_v_coduser, global_v_coduser );
        end if;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end add_detail;

    procedure update_detail(param_json json) as
        v_amtreq        ttravinf.amtreq%type;
        v_typetrav      ttravinf.typetrav%type;
        v_location      ttravinf.location%type;
        v_codprov       ttravinf.codprov%type;
        v_codcnty       ttravinf.codcnty%type;
        v_dtestrt       ttravinf.dtestrt%type;
        v_timstrt       ttravinf.timstrt%type;
        v_dteend        ttravinf.dteend%type;
        v_timend        ttravinf.timend%type;
        v_qtyday        ttravinf.qtyday%type;
        v_qtydistance   ttravinf.qtydistance%type;
        v_remark        ttravinf.remark%type;
        v_typepay       ttravinf.typepay%type;
        v_dtepay        ttravinf.dtepay%type;
        v_numperiod     ttravinf.numperiod%type;
        v_dtemthpay     ttravinf.dtemthpay%type;
        v_dteyrepay     ttravinf.dteyrepay%type;
        v_codappr       ttravinf.codappr%type;
        v_dteappr       ttravinf.dteappr%type;
        v_codpay        ttravinf.codpay%type;

        v_temp          varchar2(1 char);
    begin

        v_amtreq        := to_number(hcm_util.get_string(param_json,'amtreq'));
        v_typetrav      := hcm_util.get_string(param_json,'typetrav');
        v_location      := hcm_util.get_string(param_json,'location');
        v_codprov       := upper(hcm_util.get_string(param_json,'codprov'));
        v_codcnty       := upper(hcm_util.get_string(param_json,'codcnty'));
        v_dtestrt       := to_date(hcm_util.get_string(param_json,'dtestrt'),'dd/mm/yyyy');
        v_timstrt       := replace(hcm_util.get_string(param_json,'timstrt'),':','');
        v_dteend        := to_date(hcm_util.get_string(param_json,'dteend'),'dd/mm/yyyy');
        v_timend        := replace(hcm_util.get_string(param_json,'timend'),':','');
        v_qtyday        := to_number(hcm_util.get_string(param_json,'qtyday'));
        v_qtydistance   := to_number(hcm_util.get_string(param_json,'qtydistance'));
        v_remark        := hcm_util.get_string(param_json,'remark');
        v_typepay       := hcm_util.get_string(param_json,'typepay');
        v_dtepay        := to_date(hcm_util.get_string(param_json,'dtepay'),'dd/mm/yyyy');
        v_codpay        := upper(hcm_util.get_string(param_json,'codpay'));
        v_numperiod     := to_number(hcm_util.get_string(param_json,'numperiod'));
        v_dtemthpay     := to_number(hcm_util.get_string(param_json,'dtemthpay'));
        v_dteyrepay     := to_number(hcm_util.get_string(param_json,'dteyrepay'));
        v_codappr       := upper(hcm_util.get_string(param_json,'codappr'));
        v_dteappr       := to_date(hcm_util.get_string(param_json,'dteappr'),'dd/mm/yyyy');
        if p_numtravrq is not null then
            begin
                select 'Y' into v_temp
                  from ttravinf a
                 where a.numtravrq = p_numtravrq;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TTRAVINF');
                return;
            end;
        end if;

        begin
            select 'X' into v_temp
              from ttravinf
             where numtravrq = p_numtravrq
               and nvl(flgtranpy,'N') <> 'Y'
               and nvl(flgvoucher,'N') <> 'Y';
        exception when no_data_found then        
            param_msg_error := replace(get_error_msg_php('HR1510',global_v_lang),'@#$%400');  --> Peerasak || Issue#8708 || 30/11/2022
            return;
        end;

        if param_msg_error is null then
            update TTRAVINF
               set amtreq   = v_amtreq,
                   typetrav = v_typetrav,
                   location = v_location,
                   codprov = v_codprov,
                   codcnty = v_codcnty,
                   dtestrt = v_dtestrt,
                   timstrt = v_timstrt,
                   dteend = v_dteend,
                   timend = v_timend,
                   qtyday = v_qtyday,
                   qtydistance = v_qtydistance,
                   remark = v_remark,
                   typepay = v_typepay,
                   dtepay = v_dtepay,
                   codpay = v_codpay,
                   numperiod = v_numperiod,
                   dtemthpay = v_dtemthpay,
                   dteyrepay = v_dteyrepay,
                   codappr = v_codappr,
                   dteappr = v_dteappr,
                   coduser = global_v_coduser
             where numtravrq = p_numtravrq;
        end if;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end update_detail;

    function gen_file_name(v_filename varchar2,v_numseq number) return varchar2 is
        v_name  varchar2(100 char);
        v_type  varchar2(20 char);
    begin
        begin
            select substr(s,   nullif( instr(s,'.', -1) +1, 1) )
              into v_type
              from (select v_filename s from dual);
        exception when no_data_found then
            return v_filename;
        end;
        v_name := dbms_random.string('x',10)||upper(p_numtravrq)||v_numseq;
        return v_name||'.'||v_type;
    end;

    PROCEDURE insert_detail_attach( detail_obj json) AS
        v_numseq        ttravattch.numseq%TYPE;
        v_filename      ttravattch.filename%TYPE;
        v_descattch     ttravattch.descattch%TYPE;
        max_numseq      ttravattch.numseq%TYPE;
    BEGIN
        begin
            select max(numseq)
              into max_numseq
              from ttravattch
             where numtravrq = p_numtravrq;
        exception when others then
            max_numseq := 0;
        end;

        v_numseq    := nvl(max_numseq,0) + 1;
        v_filename  := hcm_util.get_string(detail_obj, 'filename');
        v_descattch := hcm_util.get_string(detail_obj, 'descattch');

        INSERT INTO ttravattch ( numtravrq,numseq, filename, descattch, codcreate, coduser )
        VALUES ( p_numtravrq, v_numseq, v_filename, v_descattch, global_v_coduser, global_v_coduser );

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END insert_detail_attach;

    PROCEDURE update_detail_attach( detail_obj json) AS
        v_numseq        ttravattch.numseq%TYPE;
        v_oldnumseq     tconttravd.numseq%TYPE;
        v_filename      ttravattch.filename%TYPE;
        v_descattch     ttravattch.descattch%TYPE;
        v_temp          varchar2(1 char);
    BEGIN
        v_numseq    := to_number(hcm_util.get_string(detail_obj, 'numseq'));
        v_oldnumseq := to_number(hcm_util.get_string(detail_obj, 'numseqOld'));
        v_filename  := hcm_util.get_string(detail_obj, 'filename');
        v_descattch := hcm_util.get_string(detail_obj, 'descattch');

        update ttravattch
           set filename = v_filename,
               descattch = v_descattch,
               numseq = v_numseq,
               coduser = global_v_coduser
         where numtravrq = p_numtravrq
           and numseq = nvl(v_oldnumseq,v_numseq);
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END update_detail_attach;

    PROCEDURE delete_detail_attach( detail_obj json) AS
        v_oldnumseq  tconttravd.numseq%TYPE;
    BEGIN
        v_oldnumseq := to_number(hcm_util.get_string(detail_obj, 'numseqOld'));
        DELETE ttravattch
         where numtravrq = p_numtravrq
           and NUMSEQ = v_oldnumseq;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_detail_attach;

    procedure do_detail_attach(child_attach json) as
        detail_obj      json;
        v_item_flgedit  varchar2(10 char);
    begin
        FOR i IN 0..child_attach.count - 1 LOOP
            detail_obj      := hcm_util.get_json(child_attach, to_char(i));
            v_item_flgedit  := hcm_util.get_string(detail_obj, 'flg');
            IF v_item_flgedit = 'delete' THEN
                delete_detail_attach(detail_obj);
            ELSIF v_item_flgedit = 'edit' THEN
                update_detail_attach(detail_obj);
            ELSIF v_item_flgedit = 'add' THEN
                insert_detail_attach(detail_obj);
            END IF;
        END LOOP;
    end do_detail_attach;

    PROCEDURE insert_detail_expense( detail_obj json) AS
        v_codexp        TTRAVINFD.codexp%TYPE;
        v_codtravunit   TTRAVINFD.codtravunit%TYPE;
        v_amtalw        TTRAVINFD.amtalw%TYPE;
        v_qtyunit       TTRAVINFD.qtyunit%TYPE;
        v_amtreq        TTRAVINFD.amtreq%TYPE;
    BEGIN
        v_codexp        := upper(hcm_util.get_string(detail_obj, 'codexp'));
        v_codtravunit   := upper(hcm_util.get_string(detail_obj, 'codtravunit'));
        v_amtalw        := to_number(hcm_util.get_string(detail_obj, 'amtalw'));
        v_qtyunit       := to_number(hcm_util.get_string(detail_obj, 'qtyunit'));
        v_amtreq        := to_number(hcm_util.get_string(detail_obj, 'amtreq'));

        INSERT INTO TTRAVINFD ( numtravrq, codexp, codtravunit, amtalw, qtyunit, amtreq, codcreate, coduser )
        VALUES ( p_numtravrq, v_codexp, v_codtravunit, v_amtalw, v_qtyunit, v_amtreq, global_v_coduser, global_v_coduser );

    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END insert_detail_expense;

    PROCEDURE update_detail_expense( detail_obj json) AS
        v_codexp        TTRAVINFD.codexp%TYPE;
        v_codtravunit   TTRAVINFD.codtravunit%TYPE;
        v_amtalw        TTRAVINFD.amtalw%TYPE;
        v_qtyunit       TTRAVINFD.qtyunit%TYPE;
        v_amtreq        TTRAVINFD.amtreq%TYPE;
    BEGIN
        v_codexp        := upper(hcm_util.get_string(detail_obj, 'codexp'));
        v_codtravunit   := upper(hcm_util.get_string(detail_obj, 'codtravunit'));
        v_amtalw        := to_number(hcm_util.get_string(detail_obj, 'amtalw'));
        v_qtyunit       := to_number(hcm_util.get_string(detail_obj, 'qtyunit'));
        v_amtreq        := to_number(hcm_util.get_string(detail_obj, 'amtreq'));

        update TTRAVINFD
           set codtravunit = v_codtravunit,
               amtalw = v_amtalw,
               qtyunit = v_qtyunit,
               amtreq = v_amtreq,
               coduser = global_v_coduser
         where numtravrq = p_numtravrq
           and codexp = v_codexp;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END update_detail_expense;

    PROCEDURE delete_detail_expense( detail_obj json) AS
        v_codexp     TTRAVINFD.codexp%TYPE;
    BEGIN
        v_codexp := upper(hcm_util.get_string(detail_obj, 'codexp'));
        DELETE TTRAVINFD
         where numtravrq = p_numtravrq
           and codexp = v_codexp;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_detail_expense;

    procedure do_detail_expense(child_attach json) as
        detail_obj      json;
        v_item_flgedit  varchar2(10 char);
    begin
        FOR i IN 0..child_attach.count - 1 LOOP
            detail_obj      := hcm_util.get_json(child_attach, to_char(i));
            v_item_flgedit  := hcm_util.get_string(detail_obj, 'flg');
            IF v_item_flgedit = 'delete' THEN
                delete_detail_expense(detail_obj);
            ELSIF v_item_flgedit = 'edit' THEN
                update_detail_expense(detail_obj);
            ELSIF v_item_flgedit = 'add' THEN
                insert_detail_expense(detail_obj);
            END IF;
        END LOOP;
    end do_detail_expense;

    procedure check_child_attach(child_attach json) as
        detail_obj      json;
        v_item_flgedit  varchar2(10 char);

        v_numseq        ttravattch.numseq%TYPE;
        v_filename      ttravattch.filename%TYPE;
        v_descattch     ttravattch.descattch%TYPE;
    BEGIN
        FOR i IN 0..child_attach.count - 1 LOOP
            detail_obj      := hcm_util.get_json(child_attach, to_char(i));
            v_item_flgedit  := hcm_util.get_string(detail_obj, 'flg');
            if v_item_flgedit = 'add' or v_item_flgedit = 'edit' then
                v_numseq    := to_number(hcm_util.get_string(detail_obj, 'numseq'));
                v_filename  := hcm_util.get_string(detail_obj, 'filename');
                v_descattch := hcm_util.get_string(detail_obj, 'descattch');
                if ( v_descattch is not null and v_filename is null ) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;
            end if;
        END LOOP;
    end check_child_attach;

    procedure check_child_expense(v_codprov TTRAVINF.codprov%type, v_codcnty TTRAVINF.codcnty%type, child_expense json) as
        v_temp          varchar2(1 char);
        detail_obj      json;
        v_item_flgedit  varchar2(10 char);
        v_row           number := 0;

        v_codexp        ttravinfd.codexp%type;
        v_codtravunit   ttravinfd.codtravunit%type;
        v_amtalw        ttravinfd.amtalw%type;
        v_qtyunit       ttravinfd.qtyunit%type;
        v_amtreq        ttravinfd.amtreq%type;

        v_codcompy      tconttravd.codcompy%type;
        v_syncond       tconttravd.syncond%type;
        v_stmt          long;
        v_flg           boolean;
        v_codcomp       temploy1.codcomp%type;
        v_codpos        temploy1.codpos%type;
        v_numlvl        temploy1.numlvl%type;
        v_jobgrade      temploy1.jobgrade%type;
        v_typemp        temploy1.typemp%type;
        v_codbrlc       temploy1.codbrlc%type;

        cursor c1 is
            select syncond
              from tconttravd
             where codcompy = v_codcompy
               and codexp = v_codexp
               and dteeffec = (select max(dteeffec)
                                 from tconttravd
                                where codcompy = v_codcompy
                                  and codexp = v_codexp
                                  and dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
          order by numseq;

    BEGIN
        v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
        FOR i IN 0..child_expense.count - 1 LOOP
            detail_obj          := hcm_util.get_json(child_expense, to_char(i));
            v_item_flgedit      := hcm_util.get_string(detail_obj, 'flag');
            IF v_item_flgedit = 'add' or v_item_flgedit = 'edit' THEN
                v_codexp        := upper(hcm_util.get_string(detail_obj, 'codexp'));
                v_codtravunit   := upper(hcm_util.get_string(detail_obj, 'codtravunit'));
                v_amtalw        := to_number(hcm_util.get_string(detail_obj, 'amtalw'));
                v_qtyunit       := to_number(hcm_util.get_string(detail_obj, 'qtyunit'));
                v_amtreq        := to_number(hcm_util.get_string(detail_obj, 'amtreq'));

                if v_codexp is null or v_codtravunit is null or v_amtalw is null or v_qtyunit is null or v_amtreq is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;

                begin
                    select 'x' into v_temp
                      from tcodexp
                     where codcodec = v_codexp;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXP');
                END;

                begin
                    select codcomp,codpos,numlvl,jobgrade,typemp,codbrlc
                      into v_codcomp,v_codpos,v_numlvl,v_jobgrade,v_typemp,v_codbrlc
                      from temploy1
                     where codempid = p_codempid_query;
                end;
                v_flg := false;
                for k in c1 loop
                    v_row := v_row+1;
                    if k.syncond is not null then
                        v_syncond := k.syncond;
                        v_syncond := replace(v_syncond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                        v_syncond := replace(v_syncond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                        v_syncond := replace(v_syncond,'TEMPLOY1.NUMLVL',v_numlvl);
                        v_syncond := replace(v_syncond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                        v_syncond := replace(v_syncond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                        v_syncond := replace(v_syncond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                        v_syncond := replace(v_syncond,'TGRPPROV.CODGRPPROV',''''||v_codprov||'''');
                        v_syncond := replace(v_syncond,'TGRPCNTY.CODGRPCNTY',''''||v_codcnty||'''');
                        v_stmt := 'select count(*) from TEMPLOY1 where codempid = '''||p_codempid_query||''' and '||v_syncond;
                        v_flg := v_flg or execute_stmt(v_stmt);
                        if v_flg then
                            exit;
                        end if;
                    end if;
                end loop;
                if not v_flg then
                    param_msg_error := get_error_msg_php('BF0049',global_v_lang,v_codexp);
                end if;
            END IF;
        END LOOP;
    end check_child_expense;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj            json;
        param_json          json;
        child_attach        json;
        child_expense       json;
        tab1                json;
        tab2                json;
        obj_detail          json;
        obj_attach          json;

        v_codprov           TTRAVINF.codprov%type;
        v_codcnty           TTRAVINF.codcnty%type;
        v_flag              varchar2(10 char);
        obj_result          json;
        v_amtreq            TTRAVINF.amtreq%TYPE;
    begin
        initial_value(json_str_input);
        json_obj            := json(json_str_input);
        tab1                := hcm_util.get_json(json_obj, 'tab1');
        obj_detail          := hcm_util.get_json(tab1, 'detail');
        obj_attach          := hcm_util.get_json(tab1, 'table');
        tab2                := hcm_util.get_json(json_obj, 'tab2');

        p_dtereq            := nvl(to_date(hcm_util.get_string(obj_detail,'dtereq'),'dd/mm/yyyy'),trunc(sysdate));
        p_codempid_query    := upper(hcm_util.get_string(obj_detail,'codempid'));
        p_numtravrq         := hcm_util.get_string(obj_detail,'numtravrq');

        check_detail_add;
        check_param_detail(obj_detail);

        check_child_attach(obj_attach);

        v_codprov           := upper(hcm_util.get_string(obj_detail,'codprov'));
        v_codcnty           := upper(hcm_util.get_string(obj_detail,'codcnty'));
        child_expense       := tab2;
        check_child_expense(v_codprov,v_codcnty,child_expense);
--
        if param_msg_error is null then
            if p_numtravrq is null then
                add_detail(obj_detail);
            else
                update_detail(obj_detail);
            end if;
        end if;
--
        if param_msg_error is null then
            do_detail_attach(obj_attach);
        end if;
        if param_msg_error is null then
            do_detail_expense(child_expense);
        end if;

        begin
            select sum(nvl(amtreq,0))
              into v_amtreq
              from ttravinfd
             where numtravrq = p_numtravrq;
        exception when others then
            v_amtreq := 0;
        end;

        begin
            update ttravinf
               set amtreq = v_amtreq
             where numtravrq = p_numtravrq;
        exception when others then
            null;
        end;

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            obj_result  := json();
            obj_result.put('coderror',200);
            obj_result.put('response',replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201'));
            obj_result.put('numtravrq',p_numtravrq);
            dbms_lob.createtemporary(json_str_output, true);
            obj_result.to_clob(json_str_output);
--            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
--            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    PROCEDURE delete_index( detail_obj json) AS
        v_numtravrq     ttravinf.numtravrq%TYPE;
        v_temp          varchar2(1 char);
    BEGIN
        v_numtravrq := upper(hcm_util.get_string(detail_obj, 'numtravrq'));
        begin
            select 'X' into v_temp
              from ttravinf
             where numtravrq = v_numtravrq
               and nvl(flgtranpy,'N') <> 'Y'
               and nvl(flgvoucher,'N') <> 'Y';
        exception when no_data_found then
            param_msg_error := replace(get_error_msg_php('HR1510',global_v_lang),'@#$%400');  --> Peerasak || Issue#8708 || 30/11/2022
            return;
        end;

        delete ttravattch
         where numtravrq = v_numtravrq;
        delete ttravinfd
         where numtravrq = v_numtravrq;
        delete ttravinf
         where numtravrq = v_numtravrq;

    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_index;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
        json_obj        json;
        param_json      json;
        detail_obj      json;
        v_flag          varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);

        if param_msg_error is null then
            param_json := hcm_util.get_json(json_obj, 'param_json');
            FOR i IN 0..param_json.count - 1 LOOP
                detail_obj := hcm_util.get_json(param_json, to_char(i));
                v_flag := hcm_util.get_string(detail_obj, 'flg');
                IF v_flag = 'delete' THEN
                    delete_index(detail_obj);
                END IF;
                if param_msg_error is not null then
                    exit;
                end if;
            END LOOP;
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
  END save_index;

END HRBF4ME;

/
