--------------------------------------------------------
--  DDL for Package Body HRBF4QE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4QE" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcompy         := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_dteeffec         := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
        p_codexp           := upper(hcm_util.get_string_t(json_obj,'p_codexp'));
        p_detail                := hcm_util.get_json_t(json_obj,'detail');

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcompy is null or p_dteeffec is null  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
            from TCOMPNY
            where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_index;

    procedure check_codexp as
        v_temp varchar2(1 char);
    begin
        if p_codexp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
            from TCODEXP
            where CODCODEC = p_codexp;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXP');
            return;
        end;
    end check_codexp;

    procedure gen_index(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_rows2       json_object_t;
        obj_head        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_temp          varchar2(1);

        cursor c1 is
            SELECT t1.codexp, t1.codtravunit, t1.codpay, t1.codcompy, t1.dteeffec
              FROM tconttrav t1
             WHERE codcompy = p_codcompy
               and dteeffec = ( select max(dteeffec)
                                  from tconttrav
                                 where codcompy = p_codcompy
                                   and dteeffec <= p_dteeffec)
          order by codexp;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('codexp',i.codexp);
            obj_data.put('desc_codexp', get_tcodec_name('tcodexp', i.codexp, global_v_lang));
--            obj_data.put('codtravunit',i.codtravunit);
            obj_data.put('codtravunit', get_tcodec_name('TCODTRAVUNIT', i.codtravunit, global_v_lang));
            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
            obj_data.put('codcompy',i.codcompy);
            begin
                select 'x' into v_temp
                  from TTRAVINFD
                 where codexp = i.codexp
                   and rownum = 1;
                obj_data.put('flgused','Y');
            exception when no_data_found then
                obj_data.put('flgused','N');
            end;
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        json_str_output     := obj_rows.to_clob;
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

    procedure gen_detail(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_head        json_object_t;
        obj_detail      json_object_t;

        obj_data        json_object_t;
        obj_data_child  json_object_t;
        v_row           number := 0;
        v_row_child     number := 0;
        obj_syncond      json_object_t;

        cursor c1detail is
            select codtravunit, codpay
              from tconttrav a
             where a.dteeffec = p_dteeffecquery
               and a.codcompy = p_codcompy
               and codexp = p_codexp;

        cursor c2detail is
            select numseq, syncond, amtalw, statement
              from tconttravd a
             where a.dteeffec = p_dteeffecquery
               and a.codcompy = p_codcompy
               and codexp = p_codexp
          order by numseq;
    begin
        gen_flg_status;
        obj_head    := json_object_t();
        obj_rows    := json_object_t();
        obj_detail  := json_object_t();
        obj_detail.put('codcompy',p_codcompy);
        obj_detail.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
        obj_detail.put('codexp',p_codexp);
        obj_detail.put('isAdd',isAdd);
        obj_detail.put('isEdit',isedit);
        obj_detail.put('msgerror','');
        if v_flgDisabled then
          obj_detail.put('msgerror',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
        end if;

        obj_data  := json_object_t();
        for i in c1detail loop
            v_row := v_row+1;
            obj_detail.put('codtravunit',i.codtravunit);
            for j in c2detail loop
                v_row_child         := v_row_child+1;
                obj_data_child      := json_object_t();
                obj_data_child.put('numseq',j.numseq);
                obj_syncond         := json_object_t();
                obj_syncond.put('code', j.syncond);
                obj_syncond.put('description',get_logical_desc(j.statement));
--                obj_syncond.put('description',get_logical_name('hrtr22e',j.syncond,global_v_lang));
                obj_syncond.put('statement', j.statement);
                obj_data_child.put('syncond', obj_syncond);
                obj_data_child.put('amtalw',j.amtalw);
                obj_data_child.put('flgAdd',isAdd);
                obj_data.put(v_row_child-1,obj_data_child);
            end loop;
        end loop;
        obj_head.put('coderror',200);
        obj_head.put('table',obj_data);
        obj_head.put('detail',obj_detail);

        json_str_output     := obj_head.to_clob;
    end gen_detail;

--    procedure gen_detail_default(json_str_output out clob) as
--        obj_rows        json_object_t;
--        obj_head        json_object_t;
--        obj_syncond      json_object_t;
--
--        obj_data        json_object_t;
--        obj_data_child  json_object_t;
--        v_row           number := 0;
--        v_row_child     number := 0;
--
--        v_dteeffec_max  tconttrav.dteeffec%type;
--        v_codinctv      tcontrbf.codinctv%type;
--
--        cursor c1detail is
--            select codtravunit, codpay,dteeffec
--            from tconttrav a
--            where a.dteeffec = v_dteeffec_max
--            and a.codcompy = p_codcompy
--            and codexp = p_codexp;
--
--        cursor c2detail is
--            select numseq, syncond, amtalw, statement
--            from tconttravd a
--            where a.dteeffec = v_dteeffec_max
--            and a.codcompy = p_codcompy
--            and codexp = p_codexp
--            order by numseq;
--    begin
--
--        begin
--            select max(dteeffec) into v_dteeffec_max
--            from TCONTTRAV
--            where dteeffec < p_dteeffec
--                and codcompy = p_codcompy
--                and codexp = p_codexp;
--        end;
--
--        obj_rows := json_object_t();
--        for i in c1detail loop
--            v_row := v_row+1;
--            obj_head := json_object_t();
--            obj_head.put('codtravunit',i.CODTRAVUNIT);
--            obj_head.put('codpay',i.CODPAY);
--            obj_data  := json_object_t();
--            for j in c2detail loop
--                v_row_child := v_row_child+1;
--                obj_data_child := json_object_t();
--                obj_data_child.put('numseq',j.numseq);
--                obj_data_child.put('flag','add');
--                obj_syncond    := json_object_t();
--                obj_syncond.put('code', j.SYNCOND);
--                obj_syncond.put('description',get_logical_name('HRTR22E',j.syncond,global_v_lang));
--                obj_syncond.put('statement', j.STATEMENT);
--                obj_data_child.put('syncond', obj_syncond);
--                obj_data_child.put('amtalw',j.AMTALW);
--                obj_data_child.put('can_delete', 'Y');
--                if i.dteeffec < to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') then
--                    obj_data_child.put('can_delete', 'N');
--                end if;
--                obj_data.put(v_row_child-1,obj_data_child);
--            end loop;
--            obj_head.put('rows',obj_data);
--            obj_head.put('flag','add');
--        end loop;
--
--
--        if v_dteeffec_max is null then
--            begin
--                select codinctv into v_codinctv
--                from tcontrbf
--                where dteeffec < to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
--                    and dteeffec = (select max(dteeffec) from tcontrbf)
--                    and codcompy = p_codcompy;
--            exception when no_data_found then
--                v_codinctv := '';
--            end;
--            obj_head := json_object_t();
--            obj_head.put('codtravunit','');
--            obj_head.put('codpay',v_codinctv);
--            obj_data  := json_object_t();
--            obj_head.put('rows',obj_data);
--            obj_head.put('flag','add');
--
--        end if;
--
--        if (p_dteeffec < to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')) then
--            obj_head.put('message', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
--        else
--            obj_head.put('message','');
--        end if;
--        obj_rows.put(to_char(v_row-1),obj_head);
--        dbms_lob.createtemporary(json_str_output, true);
--        obj_rows.to_clob(json_str_output);
--    end gen_detail_default;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        v_temp varchar2(1);
    begin
        initial_value(json_str_input);
        check_index;
        check_codexp;
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

    procedure add_detail as
    begin
        begin
            insert into tconttrav ( codcompy, codexp,dteeffec, codtravunit, codcreate, coduser,dtecreate,dteupd )
            values ( p_codcompy, p_codexp, p_dteeffec, p_codtravunit, global_v_coduser, global_v_coduser,sysdate,sysdate );
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TCONTTRAV');
        end;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end add_detail;

    procedure update_detail as
    begin
        update TCONTTRAV
           set codtravunit = p_codtravunit,
               coduser =  global_v_coduser,
               dteupd = sysdate
         where codcompy = p_codcompy
           and codexp = p_codexp
           and dteeffec = p_dteeffec;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end update_detail;

    PROCEDURE insert_detail_child( detail_obj json_object_t) AS
        v_numseq     tconttravd.numseq%TYPE;
        v_syncond    tconttravd.syncond%TYPE;
        v_statement    tconttravd.statement%TYPE;
        v_amtalw     tconttravd.amtalw%TYPE;
        obj_syncon          json_object_t;
        v_chk_dup     varchar2(1);
    BEGIN
        v_numseq    := to_number(hcm_util.get_string_t(detail_obj, 'numseq'));
        v_amtalw    := to_number(hcm_util.get_string_t(detail_obj, 'amtalw'));
        obj_syncon  := hcm_util.get_json_t(detail_obj, 'syncond');
        v_syncond   := hcm_util.get_string_t(obj_syncon, 'code');
        v_statement := hcm_util.get_string_t(obj_syncon, 'statement');

        begin
          select '1'
            into v_chk_dup
            from tconttravd
           where codcompy   = p_codcompy
             and codexp     = p_codexp
             and dteeffec   = p_dteeffec
             and numseq     <> v_numseq
             and syncond    = v_syncond;
          param_msg_error := get_error_msg_php('HR8860',global_v_lang);
          return;
        exception when no_data_found then null; end;

        begin
            insert into tconttravd ( codcompy, codexp, dteeffec, numseq, amtalw, syncond,statement, codcreate, coduser,dtecreate,dteupd )
            values ( p_codcompy, p_codexp, p_dteeffec, v_numseq, v_amtalw, v_syncond, v_statement, global_v_coduser, global_v_coduser,sysdate,sysdate );
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TCONTTRAVD');
        end;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END insert_detail_child;

    PROCEDURE update_detail_child( detail_obj json_object_t) AS
        v_numseq        tconttravd.numseq%TYPE;
        v_oldnumseq     tconttravd.numseq%TYPE;
        v_syncond       tconttravd.syncond%TYPE;
        v_statement     tconttravd.statement%TYPE;
        v_amtalw        tconttravd.amtalw%TYPE;
        obj_syncon      json_object_t;
        v_chk_dup       varchar2(1);
    BEGIN
        v_numseq        := to_number(hcm_util.get_string_t(detail_obj, 'numseq'));
        v_oldnumseq     := to_number(hcm_util.get_string_t(detail_obj, 'numseqOld'));
        v_syncond       := hcm_util.get_string_t(detail_obj, 'syncond');
        obj_syncon      := hcm_util.get_json_t(detail_obj, 'syncond');
        v_syncond       := hcm_util.get_string_t(obj_syncon, 'code');
        v_statement     := hcm_util.get_string_t(obj_syncon, 'statement');
        v_amtalw        := to_number(hcm_util.get_string_t(detail_obj, 'amtalw'));

        begin
          select '1'
            into v_chk_dup
            from tconttravd
           where codcompy   = p_codcompy
             and codexp     = p_codexp
             and dteeffec   = p_dteeffec
             and numseq     <> v_numseq
             and syncond    = v_syncond;
          param_msg_error := get_error_msg_php('HR8860',global_v_lang);
          return;
        exception when no_data_found then null; end;

        update TCONTTRAVD
            set syncond     = v_syncond,
                statement      = v_statement,
                numseq      = v_numseq,
                amtalw      = v_amtalw,
                coduser     =  global_v_coduser,
                dteupd      = sysdate
            where codcompy = p_codcompy
                and codexp = p_codexp
                and dteeffec = p_dteeffec
                and numseq = v_oldnumseq;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END update_detail_child;

    PROCEDURE delete_detail_child( detail_obj json_object_t) AS
        v_oldnumseq  tconttravd.numseq%TYPE;
    BEGIN
        v_oldnumseq := to_number(hcm_util.get_string_t(detail_obj, 'numseqOld'));--<< user25 Date : 26/08/2021 5. BF Module #6768
--      v_oldnumseq := to_number(hcm_util.get_string_t(detail_obj, 'oldnumseq'));--<< user25 Date : 26/08/2021 5. BF Module #6768
        DELETE TCONTTRAVD
         where codcompy = p_codcompy
           and codexp = p_codexp
           and dteeffec = p_dteeffec
           and numseq = v_oldnumseq;
    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_detail_child;

    procedure do_detail_child(json_obj json_object_t) as
        param_json      json_object_t;
        detail_obj      json_object_t;
--      v_item_flgedit  varchar2(4 char);--<< user25 Date : 26/08/2021 5. BF Module #6768
        v_item_flgedit  varchar2(10 char);--<< user25 Date : 26/08/2021 5. BF Module #6768
    begin

        param_json := hcm_util.get_json_t(json_obj, 'param_json');
        FOR i IN 0..param_json.get_size-1 loop
            detail_obj      := hcm_util.get_json_t(param_json, to_char(i));
            v_item_flgedit  := hcm_util.get_string_t(detail_obj, 'flg');

            IF v_item_flgedit = 'add' THEN
                insert_detail_child(detail_obj);
            ELSIF v_item_flgedit = 'edit' THEN
                update_detail_child(detail_obj);
            ELSIF v_item_flgedit = 'delete' THEN
                delete_detail_child(detail_obj);
            END IF;
        END LOOP;
    end do_detail_child;


    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        v_flag      varchar2(10 char);
    begin
        initial_value(json_str_input);
        p_codcompy         := upper(hcm_util.get_string_t(p_detail,'codcompy'));
        p_dteeffec         := to_date(hcm_util.get_string_t(p_detail,'dteeffec'),'dd/mm/yyyy');
        p_codexp           := upper(hcm_util.get_string_t(p_detail,'codexp'));
        p_codtravunit      := hcm_util.get_string_t(p_detail,'codtravunit');
        isAdd              := hcm_util.get_boolean_t(p_detail, 'isAdd');
        isEdit             := hcm_util.get_boolean_t(p_detail, 'isEdit') ;
        json_obj          := json_object_t(json_str_input);
        check_index;
        check_codexp;

        if p_codtravunit is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;

        if param_msg_error is null then
            if isAdd then
                add_detail;
            elsif isEdit then
                update_detail;
            end if;
        end if;

        if param_msg_error is null then
           do_detail_child(json_obj);
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

    PROCEDURE delete_index AS
    BEGIN
        DELETE TCONTTRAVD
         where codcompy = p_codcompy
           and codexp = p_codexp
           and dteeffec = p_dteeffec;

        DELETE TCONTTRAV
         where codcompy = p_codcompy
           and codexp = p_codexp
           and dteeffec = p_dteeffec;

    EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    END delete_index;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        param_json  json_object_t;
        detail_obj  json_object_t;
        v_flag      varchar2(10 char);
    begin
        initial_value(json_str_input);

        json_obj          := json_object_t(json_str_input);

        param_json := hcm_util.get_json_t(json_obj, 'param_json');
        FOR i IN 0..param_json.get_size - 1 LOOP
            detail_obj  := hcm_util.get_json_t(param_json, to_char(i));
            p_codcompy  := hcm_util.get_string_t(detail_obj, 'codcompy');
            p_dteeffec  := to_date(hcm_util.get_string_t(detail_obj, 'dteeffec'),'dd/mm/yyyy');
            p_codexp    := hcm_util.get_string_t(detail_obj, 'codexp');
            v_flag      := hcm_util.get_string_t(detail_obj, 'flg');

            IF v_flag = 'delete' THEN
                delete_index;
            END IF;
        END LOOP;

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
    end save_index;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    begin
        select count(*) 
          into v_count
          from tconttrav
         where codcompy = p_codcompy
          and codexp = p_codexp
          and dteeffec  = p_dteeffec;
        v_indexdteeffec := p_dteeffec;
    exception when no_data_found then
        v_count := 0;
    end;

    if v_count = 0 then

        select max(dteeffec) 
          into v_maxdteeffec
          from tconttrav
         where codcompy = p_codcompy
           and codexp = p_codexp
           and dteeffec <= p_dteeffec;

        if v_maxdteeffec is null then
          v_flgDisabled := false;          
        else
          if p_dteeffec < trunc(sysdate) then
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
          else
            v_flgDisabled       := false;
            p_dteeffecquery     := v_maxdteeffec;
          end if;
        end if;
      else
        if p_dteeffec < trunc(sysdate) then
          v_flgDisabled := true;
        else
          v_flgDisabled := false;
        end if;
        p_dteeffecquery := p_dteeffec;
      end if;

    if p_dteeffecquery < p_dteeffec or p_dteeffecquery is null then
        isAdd           := true;
        isEdit          := false;
    else
        isAdd           := false;
        isEdit          := not v_flgDisabled;
    end if;

    if forceAdd = 'Y' then
      isEdit := false;
      isAdd  := true;
    end if;
  end;

END HRBF4QE;

/
