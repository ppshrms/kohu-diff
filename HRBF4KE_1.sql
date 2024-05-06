--------------------------------------------------------
--  DDL for Package Body HRBF4KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4KE" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp         := upper(hcm_util.get_string(json_obj,'p_codcomp'));
        p_numseq          := to_number(hcm_util.get_string(json_obj,'p_numseq'));
        p_dtestart        := to_date( hcm_util.get_string(json_obj,'p_dtestart'),'dd/mm/yyyy');

    end initial_value;

    procedure check_codcomp as
    begin
        if p_codcomp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codcomp is not null then
            -- ('HR3007')
            param_msg_error :=  HCM_SECUR.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;
    end check_codcomp;

    procedure gen_index(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        v_row           number := 0;
        v_temp          varchar2(1 char);
        cursor c1 is
            select numseq,syncond,dtestart,dteend,codcomp,statement
            from TOBFCFP a
            where get_compful(codcomp) = p_codcomp
            order by codcomp, numseq, dtestart;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            if secur_main.secur7(i.codcomp, global_v_coduser) then
                obj_data := json();
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('numseq',i.numseq);
                obj_data.put('syncond',get_logical_desc(i.statement));
                obj_data.put('dtestart', to_char(i.dtestart,'dd/mm/yyyy'));
                obj_data.put('dteend', to_char(i.dteend,'dd/mm/yyyy'));
                obj_data.put('flgused','N');
                begin
                    select 'X' into v_temp
                    from TOBFCOMP a, TOBFCOMPD b, TOBFCFPD c
                    where a.NUMVCOMP = b.numvcomp
                    and c.codcomp like a.codcomp||'%'
                    and c.codcomp = i.codcomp
                    and c.dtestart = i.dtestart
                    and c.numseq = i.numseq
                    and b.codobf = c.codobf
                    and rownum = 1;
                    obj_data.put('flgused','Y');
                exception when no_data_found then
                    obj_data.put('flgused','N');
                end;
            end if;
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_codcomp;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure gen_codobf(v_codobf tobfcde.codobf%type,json_str_output out clob) as
        obj_rows        json;

        v_codunit       TOBFCDE.codunit%type;
        v_flglimit      TOBFCDE.flglimit%type;
        v_amtvalue      TOBFCDE.amtvalue%type;
        v_typepay       TOBFCDE.typepay%type;
        v_typebf       TOBFCDE.typebf%type;
    begin

        obj_rows := json();
        obj_rows.put('codobf',v_codobf);
        begin
            select codunit,flglimit,amtvalue,typepay,typebf into v_codunit, v_flglimit, v_amtvalue, v_typepay, v_typebf
            from TOBFCDE
            where codobf = v_codobf;
        exception when no_data_found then
            v_codunit := '';
            v_flglimit := '';
            v_amtvalue := 0;
        end;
        obj_rows.put('codunit',v_codunit);
        obj_rows.put('codunit_desc', get_tcodec_name('TCODUNIT', v_codunit, global_v_lang));
        obj_rows.put('flglimit',v_flglimit);
        obj_rows.put('amtvalue',v_amtvalue);
        obj_rows.put('typebf',v_typebf);
        obj_rows.put('typepay',v_typepay);
        obj_rows.put('can_delete','Y');
        obj_rows.put('coderror',200);
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_codobf;


    procedure get_codobf(json_str_input in clob, json_str_output out clob) as
    v_codobf  tobfcde.codobf%type;
    json_obj  json;
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);
        v_codobf  := hcm_util.get_string(json_obj,'codobf');
        gen_codobf(v_codobf, json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_codobf;

    procedure check_detail as
    begin
        if p_dtestart is null or p_numseq is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

    end check_detail;

    procedure check_detail_add as
        v_temp varchar2(1 char);
    begin
        -- compare date without time
        if p_dtestart < trunc(sysdate) then
            param_msg_error := get_error_msg_php('HR8519',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp
              from TOBFCFP
             where  codcomp = p_codcomp
               and numseq = p_numseq
               and ((p_dteend between dtestart and dteend)
                     or ((dtestart < p_dteend) and dteend is null)
                     or (p_dteend is null and (p_dtestart <= dtestart or p_dtestart <= dteend)))
               and rownum = 1;

            param_msg_error := get_error_msg_php('HR2507',global_v_lang);
        exception when no_data_found then
            null;
        end;
    end check_detail_add;

    procedure check_detail_edit as
        v_temp varchar2(1 char);
    begin
        -- compare date without time
--        if p_dtestart < trunc(sysdate) then
--            param_msg_error := get_error_msg_php('HR8519',global_v_lang);
--            return;
--        end if;

        begin
            select 'X' into v_temp
              from TOBFCFP
             where codcomp = p_codcomp
               and numseq = p_numseq
               and dtestart <> p_dtestart
               and ((p_dteend between dtestart and dteend)
                    or ((dtestart < p_dteend) and dteend is null)
                    or (p_dteend is null and (p_dtestart <= dtestart or p_dtestart <= dteend)))
               and rownum = 1;
            param_msg_error := get_error_msg_php('HR2507',global_v_lang);
        exception when no_data_found then
            null;
        end;
    end check_detail_edit;

    procedure gen_detail(json_str_output out clob) as
        obj_head        json;
        obj_syncond     json;
        v_row           number := 0;

        cursor c1detail is
--            select syncond,dteend,statement
--              from TOBFCFP  a
--             where a.codcomp = p_codcomp
--               and numseq = p_numseq
--               and dtestart = p_dtestart;

        --<<wanlapa #8820 31/01/2023    
            select syncond,dteend,statement,rowid
              from TOBFCFP  a
             where a.codcomp = p_codcomp
               and numseq = p_numseq
               and dtestart = p_dtestart;
        -->>wanlapa #8820 31/01/2023      
    begin
        obj_head := json();
        obj_syncond := json();
        obj_head.put('coderror','200');
        obj_head.put('codcomp',p_codcomp);
        obj_head.put('dtestart',to_char(p_dtestart,'dd/mm/yyyy'));
        obj_head.put('numseq',p_numseq);

        for i in c1detail loop
            obj_syncond.put('code',i.syncond);
            obj_syncond.put('statement',i.statement);
            obj_syncond.put('description',get_logical_desc(i.statement));

            --<<wanlapa #8820 31/01/2023
            obj_head.put('rowid',i.rowid);
            -->>wanlapa #8820 31/01/2023
            obj_head.put('syncond',obj_syncond);
            obj_head.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_head.put('msgerror','');
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_detail;

    procedure gen_detail_default(json_str_output out clob) as
        obj_head        json;
        obj_syncond     json;
    begin
        obj_head := json();
        obj_syncond := json();
        obj_head.put('coderror',200);
        obj_head.put('codcomp',p_codcomp);
        obj_head.put('dtestart',to_char(p_dtestart,'dd/mm/yyyy'));
        obj_head.put('numseq',p_numseq);
        obj_syncond.put('code','');
        obj_syncond.put('statement','');
        obj_syncond.put('description','');
        obj_head.put('syncond',obj_syncond);
        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);
    end gen_detail_default;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        v_temp varchar2(1);
    begin
        initial_value(json_str_input);
        check_codcomp;
        check_detail;

       if param_msg_error is null then
            begin
                select 'Y' into v_temp
                from TOBFCFP a
                where a.codcomp = p_codcomp
                and numseq = p_numseq
                and dtestart = p_dtestart;
            exception when no_data_found then
                v_temp := 'N';
            end;

            if param_msg_error is null then
                if v_temp = 'Y' then
                    gen_detail(json_str_output);
                elsif v_temp = 'N' then
                    check_detail_add;
                    gen_detail_default(json_str_output);
                end if;
            end if;
        end if;
--        param_msg_error := get_error_msg_php('HR8519',global_v_lang);
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure gen_detail_children(json_str_output out clob) as

        obj_data        json;
        obj_data_child  json;
        v_row_child     number := 0;

        v_codunit       TOBFCDE.codunit%type;
        v_flglimit      TOBFCDE.flglimit%type;
        v_amtvalue      TOBFCDE.amtvalue%type;
        v_typepay       TOBFCDE.typepay%type;
        v_typebf        TOBFCDE.typebf%type;

        v_temp          varchar2(2);

        cursor c1child is
            select codobf,qtyalw,qtytalw,amtalw,flglimit,amtvalue
              from TOBFCFPD  a
             where a.codcomp = p_codcomp
               and numseq = p_numseq
               and dtestart = p_dtestart
          order by codobf;

    begin

        obj_data  := json();
        v_row_child := 0;
        for k in c1child loop
            v_row_child := v_row_child+1;
            obj_data_child := json();
            begin
                select codunit,flglimit,amtvalue,typepay,typebf into v_codunit, v_flglimit, v_amtvalue, v_typepay,v_typebf
                from TOBFCDE
                where codobf = k.codobf;
            exception when no_data_found then
                v_codunit := '';
                v_flglimit := '';
                v_typepay := '';
                v_amtvalue := 0;
            end;

            obj_data_child.put('codobf',k.codobf);
            obj_data_child.put('codunit',v_codunit);
            obj_data_child.put('desc_codunit', get_tcodec_name('TCODUNIT', v_codunit, global_v_lang));
            obj_data_child.put('typebf',v_typebf);
            obj_data_child.put('flglimit',k.flglimit);
            obj_data_child.put('amtvalue',k.amtvalue);
            obj_data_child.put('qtyalw',k.qtyalw);
            obj_data_child.put('qtytalw',k.qtytalw);
            obj_data_child.put('amtalw',k.amtalw);
            if k.flglimit = 'M' then
                obj_data_child.put('amtalwyr',k.amtalw * 12);
            else
                obj_data_child.put('amtalwyr',k.amtalw);
            end if;
            obj_data_child.put('flgused','N');

            begin
                select 'X' into v_temp
                from TOBFCOMP a, TOBFCOMPD b
                where a.numvcomp = b.numvcomp
                and b.codobf = k.codobf
                and a.codcomp like p_codcomp||'%'
                and rownum = 1;
                obj_data_child.put('flgused','Y');
            exception when no_data_found then
                obj_data_child.put('flgused','N');
            end;

            obj_data.put(v_row_child-1,obj_data_child);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    end gen_detail_children;

    procedure get_detail_children(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        gen_detail_children(json_str_output);
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail_children;

    procedure check_param_detail(detail_obj json) as
        obj_syncond     json;
        v_dteend        TOBFCFP.dteend%type;
        v_syncond       TOBFCFP.syncond%type;
        v_count_dup     number;

        --<<wanlapa #8820 31/01/2023  
        v_codcomp       TOBFCFP.CODCOMP%type;
        v_rowid         varchar2(100 char);
        -->>wanlapa #8820 31/01/2023

        tobfcfp_dteend  tobfcfp.dteend%type;
    begin
        obj_syncond := hcm_util.get_json(detail_obj,'syncond');
        v_syncond   := hcm_util.get_string(obj_syncond,'code');
        v_dteend    := to_date(hcm_util.get_string(detail_obj,'dteend'),'dd/mm/yyyy');

        --<<wanlapa #8820 31/01/2023
        v_rowid   := hcm_util.get_string(detail_obj,'rowid');   
        -->>wanlapa #8820 31/01/2023

        if v_syncond is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        else
            select count(*)
              into v_count_dup
              from TOBFCFP
             where CODCOMP = p_codcomp
               and DTESTART = p_dtestart
               and syncond = v_syncond
               and numseq <> p_numseq;

            if v_count_dup > 0 then
                param_msg_error := get_error_msg_php('HR8860',global_v_lang);
                return;
            end if;
        end if;

        if v_dteend is not null and p_dtestart > v_dteend then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        --> Peerasak || Issue#8746 || 30/11/2022
        begin
          select dteend into tobfcfp_dteend
            from tobfcfp
           where codcomp = p_codcomp
             and dtestart < p_dtestart
             and rownum = 1
        order by dtestart desc;
        exception when no_data_found then
          tobfcfp_dteend := null;
        end;

        --> Peerasak || Issue#8746 || 30/11/2022

--        if tobfcfp_dteend is null or p_dtestart < tobfcfp_dteend then
--            param_msg_error := get_error_msg_php('HR2507',global_v_lang);
--            return;
--        end if;

      --<<wanlapa #8820 31/01/2023      
        begin
            select count(codcomp) into v_codcomp
            from tobfcfp
            where codcomp = p_codcomp;
            exception when no_data_found then
              v_codcomp := null;  
        end;

        if v_rowid is null then
            if v_codcomp > 0 and tobfcfp_dteend is null or p_dtestart < tobfcfp_dteend then
                param_msg_error := get_error_msg_php('HR2507',global_v_lang);
                return;
            end if;
        end if;
        -->>wanlapa #8820 31/01/2023

    end check_param_detail;

    procedure check_child(children json) as
        v_temp          varchar2(1 char);
        detail_obj      json;
        v_item_flgedit  varchar2(10 char);

        v_codobf        TOBFCFPD.codobf%type;
        v_flglimit      TOBFCFPD.flglimit%type;
        v_qtyalw        TOBFCFPD.qtyalw%type;
        v_qtytalw       TOBFCFPD.qtytalw%type;
        v_amtvalue      TOBFCFPD.amtvalue%type;

    BEGIN
        FOR i IN 0..children.count - 1 LOOP
            detail_obj      := hcm_util.get_json(children, to_char(i));
            v_item_flgedit  := hcm_util.get_string(detail_obj, 'flg');
            if v_item_flgedit = 'add' or v_item_flgedit = 'edit' then
                v_codobf        := upper(hcm_util.get_string(detail_obj, 'codobf'));
                v_flglimit      := hcm_util.get_string(detail_obj, 'flglimit');
                v_qtyalw        := to_number(hcm_util.get_string(detail_obj, 'qtyalw'));
                v_qtytalw       := to_number(hcm_util.get_string(detail_obj, 'qtytalw'));
                v_amtvalue      := to_number(hcm_util.get_string(detail_obj, 'amtvalue'));

                if v_codobf is null or v_flglimit is null or v_qtyalw is null or v_qtytalw is null or v_amtvalue is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;

                begin
                    select 'X' into v_temp
                    from tobfcde
                    where codobf = v_codobf;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TOBFCDE');
                    return;
                end;

                begin
                    select 'X' into v_temp
                    from TOBFCOMPY
                    where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                    and codobf = v_codobf;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TOBFCOMPY');
                    return;
                end;

                begin
                    select 'X' into v_temp
                    from tobfcde
                    where codobf = v_codobf
                      and typegroup = '1';
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('BF0058',global_v_lang);
                    return;
                end;

            elsif v_item_flgedit = 'delete' then
                v_codobf := upper(hcm_util.get_string(detail_obj, 'codobf'));
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TOBFCOMPD');
                begin
                    select 'X' into v_temp
                    from TOBFCOMP a, TOBFCOMPD b
                    where a.numvcomp = b.numvcomp
                    and b.codobf = v_codobf
                    and a.codcomp like p_codcomp||'%'
                    and rownum = 1;
                exception when no_data_found then
                    param_msg_error := null;
                end;

                if param_msg_error is not null then
                    return;
                end if;
            end if;
        END LOOP;
--        if v_count < 1 then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--        end if;
    end check_child;

    PROCEDURE insert_detail_child( detail_obj json) AS
        v_codobf        TOBFCFPD.codobf%TYPE;
        v_flglimit      TOBFCFPD.flglimit%TYPE;
        v_amtvalue      TOBFCFPD.amtvalue%TYPE;
        v_qtyalw        TOBFCFPD.qtyalw%TYPE;
        v_qtytalw       TOBFCFPD.qtytalw%TYPE;
        v_amtalw        TOBFCFPD.amtalw%TYPE;
    BEGIN
        v_codobf    := hcm_util.get_string(detail_obj, 'codobf');
        v_flglimit  := hcm_util.get_string(detail_obj, 'flglimit');
        v_amtvalue  := to_number(hcm_util.get_string(detail_obj, 'amtvalue'));
        v_qtyalw    := to_number(hcm_util.get_string(detail_obj, 'qtyalw'));
        v_qtytalw   := to_number(hcm_util.get_string(detail_obj, 'qtytalw'));
        v_amtalw    := to_number(replace(hcm_util.get_string(detail_obj, 'amtalw'),','));
        begin
        INSERT INTO TOBFCFPD ( codcomp,dtestart,numseq,codobf,
                               flglimit,amtvalue,qtyalw,qtytalw,amtalw, codcreate, coduser )
                      VALUES ( p_codcomp,p_dtestart,p_numseq,v_codobf,
                               v_flglimit ,v_amtvalue,v_qtyalw,v_qtytalw,v_amtalw, global_v_coduser, global_v_coduser );
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TOBFCFPD');
        end;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END insert_detail_child;

    PROCEDURE update_detail_child( detail_obj json) AS
        v_codobf     TOBFCFPD.codobf%TYPE;
        v_flglimit     TOBFCFPD.flglimit%TYPE;
        v_amtvalue     TOBFCFPD.amtvalue%TYPE;
        v_qtyalw     TOBFCFPD.qtyalw%TYPE;
        v_qtytalw     TOBFCFPD.qtytalw%TYPE;
        v_amtalw     TOBFCFPD.amtalw%TYPE;
    BEGIN
        v_codobf := hcm_util.get_string(detail_obj, 'codobf');
        v_flglimit := hcm_util.get_string(detail_obj, 'flglimit');
        v_amtvalue := to_number(hcm_util.get_string(detail_obj, 'amtvalue'));
        v_qtyalw := to_number(hcm_util.get_string(detail_obj, 'qtyalw'));
        v_qtytalw := to_number(hcm_util.get_string(detail_obj, 'qtytalw'));
        v_amtalw := to_number(replace(hcm_util.get_string(detail_obj, 'amtalw'),',',''));

        update TOBFCFPD
            set flglimit     = v_flglimit,
                amtvalue      = v_amtvalue,
                qtyalw      = v_qtyalw,
                qtytalw      = v_qtytalw,
                amtalw      = v_amtalw,
                coduser     =  global_v_coduser
            where codcomp = p_codcomp
            and codobf = v_codobf
            and dtestart = p_dtestart
            and NUMSEQ = p_numseq;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END update_detail_child;

    PROCEDURE delete_detail_child( detail_obj json) AS
        v_codobf     TOBFCFPD.codobf%TYPE;
    BEGIN
        v_codobf := hcm_util.get_string(detail_obj, 'codobf');
        DELETE TOBFCFPD
            where codcomp = p_codcomp
                and dtestart = p_dtestart
                and codobf = v_codobf
                and numseq = p_numseq;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_detail_child;

    procedure do_detail_child(children json) as
        detail_obj      json;
        v_item_flgedit  varchar2(10 char);
    begin
        FOR i IN 0..children.count - 1 LOOP
            detail_obj := hcm_util.get_json(children, to_char(i));
            v_item_flgedit := hcm_util.get_string(detail_obj, 'flg');
            IF v_item_flgedit = 'add' THEN
                insert_detail_child(detail_obj);
            ELSIF v_item_flgedit = 'edit' THEN
                update_detail_child(detail_obj);
            ELSIF v_item_flgedit = 'delete' THEN
                delete_detail_child(detail_obj);
            END IF;
        END LOOP;
    end do_detail_child;

    procedure add_detail(detail_obj json) as
        obj_syncond     json;
        v_syncond       TOBFCFP.syncond%type;
        v_statement     TOBFCFP.statement%type;
        v_dteend        TOBFCFP.dteend%type;
    begin
        obj_syncond := hcm_util.get_json(detail_obj,'syncond');
        v_syncond   := hcm_util.get_string(obj_syncond,'code');
        v_statement := hcm_util.get_string(obj_syncond,'statement');
        v_dteend    := to_date(hcm_util.get_string(detail_obj,'dteend'),'dd/mm/yyyy');

        if param_msg_error is null then
            INSERT INTO TOBFCFP ( codcomp,dtestart, numseq,syncond,statement, dteend, codcreate, coduser )
            VALUES ( p_codcomp, p_dtestart, p_numseq, v_syncond,v_statement,v_dteend, global_v_coduser, global_v_coduser );
        end if;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end add_detail;

    procedure update_detail(detail_obj json) as
        obj_syncond     json;
        v_syncond       TOBFCFP.syncond%type;
        v_statement     TOBFCFP.statement%type;
        v_dteend        TOBFCFP.dteend%type;
    begin
        obj_syncond := hcm_util.get_json(detail_obj,'syncond');
        v_syncond   := hcm_util.get_string(obj_syncond,'code');
        v_statement := hcm_util.get_string(obj_syncond,'statement');
        v_dteend    := to_date(hcm_util.get_string(detail_obj,'dteend'),'dd/mm/yyyy');

        if param_msg_error is null then
            begin
                update TOBFCFP
                set syncond = v_syncond,
                    statement = v_statement,
                    dteend = v_dteend,
                    coduser = global_v_coduser
                where  codcomp = p_codcomp
                    and dtestart = p_dtestart
                    and numseq = p_numseq;
            end;
        end if;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end update_detail;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj        json;
        detail_obj      json;
        param_json      json;
        children        json;
        v_count_tobfcfp number;

        v_flag          varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj        := json(json_str_input);
        detail_obj      := hcm_util.get_json(json_obj, 'detail');

        p_codcomp       := upper(hcm_util.get_string(detail_obj,'codcomp'));
        p_numseq        := to_number(hcm_util.get_string(detail_obj,'numseq'));
        p_dtestart      := to_date( hcm_util.get_string(detail_obj,'dtestart'),'dd/mm/yyyy');
        p_dteend        := to_date( hcm_util.get_string(detail_obj,'dteend'),'dd/mm/yyyy');
        param_json := hcm_util.get_json(json_obj, 'param_json');

        check_codcomp;
        check_detail;
        check_param_detail(detail_obj);

        check_child(param_json);

        select count(*)
          into v_count_tobfcfp
          from TOBFCFP
         where CODCOMP = p_codcomp
           and DTESTART = p_dtestart
           and NUMSEQ = p_numseq;

        if param_msg_error is null then
            if v_count_tobfcfp = 0 then
                check_detail_add;
                if param_msg_error is null then
                    add_detail(detail_obj);
                end if;
            else
                check_detail_edit;
                if param_msg_error is null then
                    update_detail(detail_obj);
                end if;
            end if;
        end if;

        if param_msg_error is null then
            do_detail_child(param_json);
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
    end save_detail;

    PROCEDURE delete_index( detail_obj json) AS
        v_dtestart    TOBFCFPD.dtestart%type;
        v_numseq      TOBFCFPD.numseq%type;

    BEGIN
        v_numseq := to_number(hcm_util.get_string(detail_obj,'numseq'));
        v_dtestart := to_date(hcm_util.get_string(detail_obj,'dtestart'),'dd/mm/yyyy');
        DELETE TOBFCFP
            where codcomp = p_codcomp
            and dtestart = v_dtestart
            and numseq = v_numseq;
        DELETE TOBFCFPD
            where codcomp = p_codcomp
            and dtestart = v_dtestart
            and numseq = v_numseq;
    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_index;

    procedure check_index_delete(detail_obj json) as
        v_temp          varchar2(1 char);
    begin
        begin
            select 'X' into v_temp
              from TOBFCOMP a, TOBFCOMPD b, TOBFCFPD c
             where a.numvcomp = b.numvcomp
               and c.codcomp like a.codcomp||'%'
               and c.codcomp = p_codcomp
               and c.dtestart = p_dtestart
               and c.numseq = p_numseq
               and b.codobf = c.codobf
               and rownum = 1;
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TOBFCOMP');
        exception when no_data_found then
            null;
        end;
        if param_msg_error is not null then
            return;
        end if;

    end check_index_delete;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
        json_obj        json;
        param_json      json;
        detail_obj      json;
        v_flag      varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);
        if param_msg_error is null then
            param_json := hcm_util.get_json(json_obj, 'param_json');
            FOR i IN 0..param_json.count - 1 LOOP
                detail_obj      := hcm_util.get_json(param_json, to_char(i));
                v_flag          := hcm_util.get_string(detail_obj, 'flg');
                p_codcomp       := hcm_util.get_string(detail_obj, 'codcomp');
                p_numseq        := hcm_util.get_string(detail_obj, 'numseq');
                p_dtestart      := to_date(hcm_util.get_string(detail_obj, 'dtestart'),'dd/mm/yyyy');
                IF v_flag = 'delete' THEN
                    check_index_delete(detail_obj);
                    if param_msg_error is null then
                        delete_index(detail_obj);
                    end if;
                END IF;
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

END HRBF4KE;

/
