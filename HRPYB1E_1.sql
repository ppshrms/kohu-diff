--------------------------------------------------------
--  DDL for Package Body HRPYB1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYB1E" as

    -- Update 13/08/2019 10:51

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcompy        := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_dteeffec        := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'ddmmyyyy');
        p_flgresign       := upper(hcm_util.get_string_t(json_obj,'p_flgresign'));
        p_qtyremth        := to_number(hcm_util.get_string_t(json_obj,'p_qtyremth'));
        p_flgedit         := hcm_util.get_string_t(json_obj,'p_flgedit');
        p_mode            := hcm_util.get_string_t(json_obj,'p_mode');--user37 #2349 Final Test Phase 1 V11 02/03/2021 

    end initial_value;

    procedure initial_save(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj            := json_object_t(json_str_input);
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        param_detail        := hcm_util.get_json_t(json_obj,'indexData');
        param_table         := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'table'),'rows');
        
        isAdd               := hcm_util.get_boolean_t(param_detail,'isAdd');
        isEdit              := hcm_util.get_boolean_t(param_detail,'isEdit');
        p_codcompy          := upper(hcm_util.get_string_t(param_detail,'codcompy'));
        p_dteeffec          := to_date(hcm_util.get_string_t(param_detail,'dteeffec'),'dd/mm/yyyy');
        p_flgresign         := upper(hcm_util.get_string_t(param_detail,'flgresign'));
        p_qtyremth          := to_number(hcm_util.get_string_t(param_detail,'qtyremth'));
    end initial_save;
    
    procedure check_index as
        v_temp varchar2(1 char);
        v_secur boolean;
    begin
        -- บังคับใส่ข้อมูล รหัสบริษัท,วันทีมีผลบังคับใช้
        if (p_codcompy is null) or (p_dteeffec is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- รหัสบริษัท ต้องมีข้อมูลในตาราง TCOMPNY หากไม่พบข้อมูลให้ ALERT HR2010iu
        begin
            select 'X' into v_temp from tcompny where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
            return;
        end;

        -- รหัสบริษัทให้ Check Security โดยใช้ HCM_SCUR.secur_codcomp หากไม่ผ่าน Security ให้ Alert HR3007
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_result          json_object_t;
        obj_detail          json_object_t;
        obj_table           json_object_t;
        obj_data            json_object_t;
        obj_rows            json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        v_row               number := 0;
        v_dteeffec          date;
        v_numseq            number;
        obj_tpfdinf         json_object_t;
        obj_tpfcinf         json_object_t;
        v_row_tab1          number := 0;
        v_row_tab2          number := 0;
        v_canedit           boolean := true;
        v_found             varchar2(1 char) := 'N';
        obj_syncond         json_object_t;
        
        cursor c1 is
            select codcompy,dteeffec,flgresign,qtyremth
              from tpfhinf
             where codcompy = p_codcompy
              and dteeffec = p_dteeffecquery;

        cursor c2 is --สาหรับเก็บเงื่อนไขของกองทุน
            select codcompy,dteeffec,numseq,syncond,flgconret,flgconded,statement
              from tpfeinf
             where codcompy = p_codcompy
               and trunc(dteeffec) = trunc(p_dteeffecquery)
          order by numseq;

        cursor c3 is --สาหรับเก็บเงื่อนไขการหักเงินสมบทบ
            select codcompy,dteeffec,numseq,qtywkst,qtywken,ratecsbt,rateesbt
              from tpfdinf
             where codcompy = p_codcompy
               and numseq = v_numseq
               and trunc(dteeffec) = trunc(p_dteeffecquery);

        cursor c4 is --สาหรับเก็บเงื่อนไขการจ่ายคืนกองทุน
            select codcompy,dteeffec,numseq,qtyyrst,qtyyren,ratecsbt
              from tpfcinf
             where codcompy = p_codcompy
               and numseq = v_numseq
               and trunc(dteeffec) = trunc(p_dteeffecquery)
            order by numseq;
    begin
        gen_flg_status;
        obj_result  := json_object_t();
        obj_data    := json_object_t();
        obj_detail  := json_object_t();
    
        obj_detail.put('coderror',200);
        obj_detail.put('codcompy',p_codcompy);
        obj_detail.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
        obj_detail.put('isAdd',isAdd);
        obj_detail.put('isEdit',isEdit);
        if v_flgDisabled then
          obj_detail.put('msgerror',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
        end if;        
        v_row := 0;    
        for r1 in c1 loop
            v_row := v_row + 1;
            obj_detail.put('flgresign',r1.flgresign);
            obj_detail.put('qtyremth',r1.qtyremth);
        end loop;
        if v_row = 0 then
            obj_detail.put('flgresign','Y');
            obj_detail.put('qtyremth','');        
        end if;
        
        v_row := 0;
        obj_table := json_object_t();
        for r2 in c2 loop
            v_numseq := r2.numseq;
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('numseq',r2.numseq); -- ลำดับที่เงื่อนไขพนักงาน
            obj_syncond := json_object_t();
            obj_syncond.put('code',r2.syncond); -- เงื่อนไขพนักงานที่อยู่ในกลุ่ม
            obj_syncond.put('description',get_logical_name('HRPYB1E',r2.syncond,global_v_lang)); -- รายละเอียด
            obj_syncond.put('statement',r2.statement); -- statement
            obj_data.put('syncond',obj_syncond); -- เงื่อนไขพนักงานที่อยู่ในกลุ่ม
            obj_data.put('flgconret',r2.flgconret); -- เงื่อนไขการจ่ายคืนเงินสะสม (1-ตามอายุมาชิก,2-ตามอายุงาน)
            obj_data.put('flgconded',r2.flgconded); -- เงื่อนไขการหักเงินสะสม (1-ตามอายุสมาชิก,2-ตามอายุงาน)

            obj_rows := json_object_t();
            v_row_tab1 := 0;
            for r3 in c3 loop
                v_row_tab1 := v_row_tab1 + 1;
                obj_tpfdinf := json_object_t();
                obj_tpfdinf.put('qtywkst',r3.qtywkst); -- อายุงานตั้งแต่ (เดือน)
                obj_tpfdinf.put('qtywken',r3.qtywken); -- อายุงานถึง (เดือน)
                obj_tpfdinf.put('ratecsbt',to_char(r3.ratecsbt)); -- หักจากบริษัท (%)
                obj_tpfdinf.put('rateesbt',to_char(r3.rateesbt)); -- หักจากพนักงาน (%)
                obj_tpfdinf.put('flgAdd', isAdd);
                obj_rows.put(to_char(v_row_tab1 - 1),obj_tpfdinf);
            end loop;
            obj_data.put('tpfdinf',obj_rows);

            obj_rows := json_object_t();
            v_row_tab2 := 0;
            for r4 in c4 loop
                v_row_tab2 := v_row_tab2 + 1;
                obj_tpfcinf := json_object_t();
                obj_tpfcinf.put('qtyyrst',r4.qtyyrst); -- อายุงานตั้งแต่ (เดือน)
                obj_tpfcinf.put('qtyyren',r4.qtyyren); -- อายุงานถึง (เดือน)
                obj_tpfcinf.put('ratecsbt',to_char(r4.ratecsbt)); -- หักจากบริษัท (%)
                obj_tpfcinf.put('flgAdd', isAdd);
                obj_rows.put(to_char(v_row_tab2 - 1),obj_tpfcinf);
            end loop;
            obj_data.put('tpfcinf',obj_rows);
            obj_data.put('numseq',r2.numseq); -- ลำดับที่เงื่อนไขพนักงาน
            obj_syncond := json_object_t();
            obj_syncond.put('code',r2.syncond); -- เงื่อนไขพนักงานที่อยู่ในกลุ่ม
            obj_syncond.put('description',get_logical_name('HRPYB1E',r2.syncond,global_v_lang)); -- รายละเอียด
            obj_syncond.put('statement',r2.statement); -- statement
            obj_data.put('syncond',obj_syncond); -- เงื่อนไขพนักงานที่อยู่ในกลุ่ม
            obj_data.put('flgconret',r2.flgconret); -- เงื่อนไขการจ่ายคืนเงินสะสม (1-ตามอายุมาชิก,2-ตามอายุงาน)
            obj_data.put('flgconded',r2.flgconded); -- เงื่อนไขการหักเงินสะสม (1-ตามอายุสมาชิก,2-ตามอายุงาน)

            obj_table.put(to_char(v_row - 1),obj_data);
        end loop;
        
        if v_row = 0 then
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_rows := json_object_t();
            obj_data.put('tpfdinf',obj_rows);

            obj_rows := json_object_t();
            obj_data.put('tpfcinf',obj_rows);
            
            obj_data.put('numseq',1); -- ลำดับที่เงื่อนไขพนักงาน
            obj_syncond := json_object_t();
            obj_syncond.put('code',''); -- เงื่อนไขพนักงานที่อยู่ในกลุ่ม
            obj_syncond.put('description',''); -- รายละเอียด
            obj_syncond.put('statement',''); -- statement
            obj_data.put('syncond',obj_syncond); -- เงื่อนไขพนักงานที่อยู่ในกลุ่ม
            obj_data.put('flgconret',2); -- เงื่อนไขการจ่ายคืนเงินสะสม (1-ตามอายุมาชิก,2-ตามอายุงาน)
            obj_data.put('flgconded',2); -- เงื่อนไขการหักเงินสะสม (1-ตามอายุสมาชิก,2-ตามอายุงาน)
            obj_table.put(to_char(v_row - 1),obj_data);
        end if;

        obj_result.put('coderror',200);
        obj_result.put('indexData',obj_detail);
        obj_result.put('table',obj_table);
        json_str_output := obj_result.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure validate_save  as
        obj_cond            json_object_t;
        obj_conds           json_object_t;
        obj_tab1s           json_object_t;
        obj_tab2s           json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        v_numseq            tpfeinf.numseq%type;
        v_syncond           tpfeinf.syncond%type;
        v_flgconret         tpfeinf.flgconret%type;
        v_flgconded         tpfeinf.flgconded%type;
        v_cond_flgedit      varchar2(10 char);

        v_qtywkst           tpfdinf.qtywkst%type;
        v_qtywken           tpfdinf.qtywken%type;
        v_ratecsbt          tpfdinf.ratecsbt%type;
        v_rateesbt          tpfdinf.rateesbt%type;
        v_tab1_flgedit      varchar2(10 char);
        v_tab1_overlap      varchar2(10 char);

        v_qtyyrst           tpfcinf.qtyyrst%type;
        v_qtyyren           tpfcinf.qtyyren%type;
        v_ratecsbt2         tpfcinf.ratecsbt%type;
        v_tab2_flgedit      varchar2(10 char);
        v_tab2_overlap      varchar2(10 char);
        v_flgedit_check     varchar2(10 char);
        v_qtywkst_check     tpfdinf.qtywkst%type;
        v_qtyyrst_check     tpfcinf.qtyyrst%type;
        obj_json            json_object_t;
        obj_syscond         json_object_t;
        v_count             number := 0;

        cursor c1 is
            select qtywkst,qtywken 
              from tpfdinf
             where qtywkst <> v_qtywkst
               and qtywken <> v_qtywken
               and codcompy = p_codcompy
               and trunc(dteeffec) = p_dteeffec;
    begin
        begin
            select count(*) 
              into v_count 
              from tpfhinf
             where codcompy = p_codcompy
            and trunc(dteeffec) = p_dteeffec;
        end;
        if isAdd then
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFHINF');
                return;
            end if;
        end if;

        if isAdd or isEdit then
            if p_flgresign = 'Y' and p_qtyremth is null then
                -- กรณีที่เลือกสถานะสมัครสมาชิกใหม่เมื่อลาออกกองทุน   = “ได้“ ให้บังคับระบุ สมัครสมาชิกครั้งที่ 2 ได้นับจากวันที่ลาออกภายใน   (เดือน)  เมื่อ   Click Save   หากไม่ระบุข้อมูลให้   Alert HR2045
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
        end if;

        for i in 0..param_table.get_size-1 loop
            obj_cond        := hcm_util.get_json_t(param_table,to_char(i));
            v_numseq        := to_number(hcm_util.get_string_t(obj_cond,'numseq'));
            obj_syscond     := hcm_util.get_json_t(obj_cond,'syncond');
            v_syncond       := hcm_util.get_string_t(obj_syscond,'code');
            v_flgconret     := hcm_util.get_string_t(obj_cond,'flgconret');
            v_flgconded     := hcm_util.get_string_t(obj_cond,'flgconded');
            v_cond_flgedit  := hcm_util.get_string_t(obj_cond,'flg');

            -- dup condition
            v_count := 0;
            begin
                select count(*) 
                  into v_count
                  from tpfeinf
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec
                   and numseq = v_numseq;
            end;
            if v_cond_flgedit = 'Add' then
                if v_count > 0 then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFEINF');
                    return;
                end if;
            end if;
            -- tab 1
            obj_tab1s    := hcm_util.get_json_t(hcm_util.get_json_t(obj_cond,'tpfdinf'),'rows');
            for t1 in 0..obj_tab1s.get_size-1 loop
                obj_tab1        := hcm_util.get_json_t(obj_tab1s,to_char(t1));
                v_qtywkst       := to_number(hcm_util.get_string_t(obj_tab1,'qtywkst'));
                v_qtywken       := to_number(hcm_util.get_string_t(obj_tab1,'qtywken'));
                v_ratecsbt      := to_number(hcm_util.get_string_t(obj_tab1,'ratecsbt'));
                v_rateesbt      := to_number(hcm_util.get_string_t(obj_tab1,'rateesbt'));
                v_tab1_flgedit  := hcm_util.get_string_t(obj_tab1,'flgedit');
                v_tab1_overlap  := hcm_util.get_string_t(obj_tab1,'overlap');

                -- ข้อมูลที่ต้องระบุ อายุเดือน (จาก),อายุเดือน (ถึง), % อัตราเงินสะสมส่วนของพนักงาน และ % อัตราเงินสะสมส่วนของบริษัท Alert HR2045
                if v_qtywkst is null or v_qtywken is null or v_ratecsbt is null or v_rateesbt is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;
                -- เดือนที่ระบุ เริ่มต้น ต้องห้ามมากกว่า เดือน สิ้นสุด หากผิดเงื่อนไขให้ Alert HR2022
                if v_qtywkst > v_qtywken then
                    param_msg_error := get_error_msg_php('HR2022',global_v_lang);
                    return;
                end if;
                -- หากระบุ เดือนเริ่มต้น ซ้ากับกันให้ Alert HR2005 ข้อมูลมีอยู่แล้วในฐานข้อมูล (TPFDINF)
                for cd in 0..obj_tab1s.get_size-1 loop
                    v_flgedit_check := nvl(hcm_util.get_string_t(hcm_util.get_json_t(obj_tab1s,to_char(cd)),'flgedit'),'');
                    v_qtywkst_check := to_number(hcm_util.get_string_t(hcm_util.get_json_t(obj_tab1s,to_char(cd)),'qtywkst'));
                    if v_tab1_flgedit != 'Delete' then
                        if cd != t1 and (v_flgedit_check != 'Delete') then
                            if v_qtywkst = v_qtywkst_check and v_flgedit_check <> 'Delete' then
                                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFDINF');
                                return;
                            end if;
                        end if;
                    end if;
                end loop;
                v_count := 0;
                begin
                    select count(*) 
                      into v_count
                      from tpfdinf
                     where codcompy = p_codcompy
                       and trunc(dteeffec) = p_dteeffec
                       and numseq = v_numseq
                       and qtywkst = v_qtywkst;
                end;
--                if v_tab1_flgedit = 'Add' then
--                    if v_count > 0 then
--                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFDINF');
--                        return;
--                    end if;
--                elsif v_tab1_flgedit = 'Edit' then
--                    if v_count > 1 then
--                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFDINF');
--                        return;
--                    end if;
--                end if;
                -- อายุเดือน ที่ระบุ ต้อง ห้ามคาบเกี่ยวกัน หากกาหนดเดือนผิดเงือ่นไขให้ Alert PY0012
                if v_tab1_overlap is not null then
                    if v_tab1_overlap = 'true' then
                        param_msg_error := get_error_msg_php('PY0012',global_v_lang);
                        return;
                    end if;
                end if;
            end loop;
            -- tab 2
            obj_tab2s    := hcm_util.get_json_t(hcm_util.get_json_t(obj_cond,'tpfcinf'),'rows');
            for t2 in 0..obj_tab2s.get_size-1 loop
                obj_tab2        := hcm_util.get_json_t(obj_tab2s,to_char(t2));
                v_qtyyrst       := to_number(hcm_util.get_string_t(obj_tab2,'qtyyrst'));
                v_qtyyren       := to_number(hcm_util.get_string_t(obj_tab2,'qtyyren'));
                v_ratecsbt2     := to_number(hcm_util.get_string_t(obj_tab2,'ratecsbt'));
                v_tab2_flgedit  := hcm_util.get_string_t(obj_tab2,'flgedit');
                v_tab2_overlap  := hcm_util.get_string_t(obj_tab2,'overlap');
                -- ข้อมูลที่ต้องระบุ อายุเดือน (จาก),อายุเดือน (ถึง), % จ่ายคืน เมื่อ Click Save หากไม่ระบุ ข้อมูลที่ต้องระบุให้ Alert HR2045
                if v_qtyyrst is null or v_qtyyren is null or v_ratecsbt2 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;
                -- เดือนที่ระบุ เริ่มต้น ต้องห้ามมากกว่า เดือน สิ้นสุด หากผิดเงื่อนไขให้ Alert HR2022
                if v_qtyyrst > v_qtyyren then
                    param_msg_error := get_error_msg_php('HR2022',global_v_lang);
                    return;
                end if;
                -- หากระบุ เดือนเริ่มต้น ซ้ากับกันให้ Alert HR2005 ข้อมูลมีอยู่แล้วในฐานข้อมูล (TPFCINF)
                for cd in 0..obj_tab2s.get_size-1 loop
                    v_flgedit_check := nvl(hcm_util.get_string_t(hcm_util.get_json_t(obj_tab2s,to_char(cd)),'flgedit'),'');
                    v_qtyyrst_check := to_number(hcm_util.get_string_t(hcm_util.get_json_t(obj_tab2s,to_char(cd)),'qtyyrst'));
                    if v_tab2_flgedit != 'Delete' then
                        if cd <> t2 and v_flgedit_check <> 'Delete' then
                            if v_qtyyrst = v_qtyyrst_check and v_flgedit_check <> 'Delete' then
                                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFCINF');
                                return;
                            end if;
                        end if;
                    end if;
                end loop;
                v_count := 0;
                begin
                    select count(*) 
                      into v_count
                      from tpfcinf
                     where codcompy = p_codcompy
                       and trunc(dteeffec) = p_dteeffec
                       and numseq = v_numseq
                       and qtyyrst = v_qtyyrst;
                end;
--                if v_tab2_flgedit = 'Add' then
--                    if v_count > 0 then
--                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFCINF');
--                        return;
--                    end if;
--                elsif v_tab2_flgedit = 'Edit' then
--                    if v_count > 1 then
--                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFCINF');
--                        return;
--                    end if;
--                end if;
                -- อายุเดือน ที่ระบุ ต้อง ห้ามคาบเกี่ยวกัน หากกาหนดเดือนผิดเงือ่นไขให้ Alert PY0012 อายุต้องไม่คาบเกี่ยวกัน
                if v_tab2_overlap is not null then
                    if v_tab2_overlap = 'true' then
                        param_msg_error := get_error_msg_php('PY0012',global_v_lang);
                        return;
                    end if;
                end if;
            end loop;
        end loop;
    end validate_save;

    procedure save_data(json_str_output out clob) as
        obj_cond            json_object_t;
        obj_conds           json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        v_numseq            tpfeinf.numseq%type;
        v_syncond           tpfeinf.syncond%type;
        v_statement         tpfeinf.statement%type;
        v_flgconret         tpfeinf.flgconret%type;
        v_flgconded         tpfeinf.flgconded%type;
        v_cond_flgedit      varchar2(10 char);
        v_cond_flgDelete    boolean;

        v_qtywkst           tpfdinf.qtywkst%type;
        v_qtywken           tpfdinf.qtywken%type;
        v_ratecsbt          tpfdinf.ratecsbt%type;
        v_rateesbt          tpfdinf.rateesbt%type;
        v_tab1_flgedit      varchar2(10 char);
        v_tab1_overlap      varchar2(10 char);

        v_qtyyrst           tpfcinf.qtyyrst%type;
        v_qtyyren           tpfcinf.qtyyren%type;
        v_ratecsbt2         tpfcinf.ratecsbt%type;
        v_tab2_flgedit      varchar2(10 char);
        v_tab2_overlap      varchar2(10 char);

        obj_json            json_object_t;
        obj_syscond         json_object_t;
        v_flg_have_delete   boolean := false;
        
        
        obj_tpfdinf             json_object_t;
        obj_tpfcinf             json_object_t;
        
        v_tpfdinf_flgAdd        boolean;
        v_tpfdinf_flgEdit       boolean;
        v_tpfdinf_flgDelete     boolean;
        
        v_tpfcinf_flgAdd        boolean;
        v_tpfcinf_flgEdit       boolean;
        v_tpfcinf_flgDelete     boolean;
        
        v_numseq_new            number;
        v_count_tpfeinf         number;
        
        cursor c1 is
            select *
              from tpfeinf
             where codcompy = p_codcompy
               and trunc(dteeffec) = p_dteeffec
          order by numseq;
       
    begin
        -- ตาราง TPFHINF สาหรับเก็บ รหัสบริษัท วันที่มีผลบังคับใช้,สถานะสมัครสมาชิกใหม่เมื่อลาออก, จานวนเดือนที่สมัครครั้งที่ 2
        if isAdd or isEdit then
            begin
                insert into tpfhinf (codcompy, dteeffec, flgresign, qtyremth, codcreate, coduser)
                values (p_codcompy, p_dteeffec, p_flgresign, p_qtyremth, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
                update tpfhinf
                   set flgresign = p_flgresign,
                       qtyremth = p_qtyremth,
                       coduser = global_v_coduser,
                       dteupd = sysdate
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec;
            end;
        end if;

        for i in 0..param_table.get_size-1 loop
            obj_cond            := hcm_util.get_json_t(param_table,to_char(i));
            v_numseq            := to_number(hcm_util.get_string_t(obj_cond,'numseq'));
            obj_syscond         := hcm_util.get_json_t(obj_cond,'syncond');
            v_syncond           := hcm_util.get_string_t(obj_syscond,'code');
            v_statement         := hcm_util.get_string_t(obj_syscond,'statement');
            v_flgconret         := hcm_util.get_string_t(obj_cond,'flgconret');
            v_flgconded         := hcm_util.get_string_t(obj_cond,'flgconded');
            v_cond_flgDelete    := nvl(hcm_util.get_boolean_t(obj_cond,'flgDelete'),false);
            
            -- ตาราง TPFEINF สาหรับเก็บเงื่อนไขของกองทุน
            if v_cond_flgDelete then
                v_flg_have_delete := true;
                -- delete tpfeinf
                delete from tpfeinf
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec
                   and numseq = v_numseq;
                -- tab1
                delete from tpfdinf
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec
                   and numseq = v_numseq;
                -- tab2
                delete from tpfcinf
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec
                   and numseq = v_numseq;
                
                -- skip to next loop
                continue;
            else
                begin
                    insert into tpfeinf (codcompy, dteeffec, numseq, syncond, statement, flgconret, flgconded, codcreate, coduser)
                    values (p_codcompy, p_dteeffec, v_numseq, v_syncond, v_statement, v_flgconret, v_flgconded, global_v_coduser, global_v_coduser);
                exception when dup_val_on_index then
                    update tpfeinf
                       set syncond = v_syncond,
                           statement = v_statement,
                           flgconret = v_flgconret,
                           flgconded = v_flgconded,
                           coduser = global_v_coduser,
                           dteupd = sysdate
                     where codcompy = p_codcompy
                       and trunc(dteeffec) = p_dteeffec
                       and numseq = v_numseq;
                end;
            end if;

            -- tab 1 tpfdinf
            obj_tpfdinf    := hcm_util.get_json_t(hcm_util.get_json_t(obj_cond,'tpfdinf'),'rows');
            for t1 in 0..obj_tpfdinf.get_size-1 loop
                obj_tab1                := hcm_util.get_json_t(obj_tpfdinf,to_char(t1));
                v_qtywkst               := to_number(hcm_util.get_string_t(obj_tab1,'qtywkst'));
                v_qtywken               := to_number(hcm_util.get_string_t(obj_tab1,'qtywken'));
                v_ratecsbt              := to_number(hcm_util.get_string_t(obj_tab1,'ratecsbt'));
                v_rateesbt              := to_number(hcm_util.get_string_t(obj_tab1,'rateesbt'));
                v_tpfdinf_flgAdd        := hcm_util.get_boolean_t(obj_tab1,'flgAdd');
                v_tpfdinf_flgEdit       := hcm_util.get_boolean_t(obj_tab1,'flgEdit');
                v_tpfdinf_flgDelete     := hcm_util.get_boolean_t(obj_tab1,'flgDelete');

                -- ตาราง TPFDINF สาหรับเก็บเงื่อนไขการหักเงินสมบทบ
                if v_tpfdinf_flgDelete then
                    delete from tpfdinf
                     where codcompy = p_codcompy
                       and trunc(dteeffec) = p_dteeffec
                       and numseq = v_numseq
                       and qtywkst = v_qtywkst;
                elsif v_tpfdinf_flgAdd then
                    begin
                        insert into tpfdinf (codcompy, dteeffec, numseq, qtywkst, qtywken, ratecsbt, rateesbt, codcreate, coduser, dtecreate, dteupd)
                        values (p_codcompy, p_dteeffec, v_numseq, v_qtywkst, v_qtywken, v_ratecsbt, v_rateesbt, global_v_coduser, global_v_coduser, sysdate, sysdate);
                    exception when dup_val_on_index then
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFDINF');
                        return;
                    end;
                elsif v_tpfdinf_flgEdit then
                    update tpfdinf
                       set qtywken = v_qtywken, 
                           ratecsbt = v_ratecsbt, 
                           rateesbt = v_rateesbt, 
                           coduser = global_v_coduser, 
                           dteupd = sysdate
                     where codcompy = p_codcompy
                       and trunc(dteeffec) = p_dteeffec
                       and numseq = v_numseq
                       and qtywkst = v_qtywkst;
                end if;
            end loop;
            
            -- tab 2 tpfcinf
            obj_tpfcinf    := hcm_util.get_json_t(hcm_util.get_json_t(obj_cond,'tpfcinf'),'rows');
            for t2 in 0..obj_tpfcinf.get_size-1 loop
                obj_tab2                := hcm_util.get_json_t(obj_tpfcinf,to_char(t2));
                v_qtyyrst               := to_number(hcm_util.get_string_t(obj_tab2,'qtyyrst'));
                v_qtyyren               := to_number(hcm_util.get_string_t(obj_tab2,'qtyyren'));
                v_ratecsbt2             := to_number(hcm_util.get_string_t(obj_tab2,'ratecsbt'));
                v_tpfcinf_flgAdd        := hcm_util.get_boolean_t(obj_tab2,'flgAdd');
                v_tpfcinf_flgEdit       := hcm_util.get_boolean_t(obj_tab2,'flgEdit');
                v_tpfcinf_flgDelete     := hcm_util.get_boolean_t(obj_tab2,'flgDelete');

                -- ตาราง TPFCINF สาหรับเก็บเงื่อนไขการจ่ายคืนกองทุน
                if v_tpfcinf_flgDelete then
                    delete from tpfcinf
                     where codcompy      = p_codcompy
                       and trunc(dteeffec) = p_dteeffec
                       and numseq = v_numseq
                       and qtyyrst = v_qtyyrst;
                elsif v_tpfcinf_flgAdd then
                    begin
                        insert into tpfcinf (codcompy, dteeffec, numseq, qtyyrst, qtyyren, ratecsbt, codcreate, coduser)
                        values (p_codcompy, p_dteeffec, v_numseq, v_qtyyrst, v_qtyyren, v_ratecsbt2, global_v_coduser, global_v_coduser);
                    exception when dup_val_on_index then
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPFCINF');
                        return;
                    end;
                elsif v_tpfcinf_flgEdit then
                    update tpfcinf
                       set qtyyren = v_qtyyren, 
                           ratecsbt = v_ratecsbt2, 
                           coduser = global_v_coduser
                     where codcompy      = p_codcompy
                       and trunc(dteeffec) = p_dteeffec
                       and numseq = v_numseq
                       and qtyyrst = v_qtyyrst;
                end if;
            end loop;
        end loop;
        
        v_numseq_new := 0;
        for r1 in c1 loop
            v_numseq_new := v_numseq_new + 1;
            if r1.numseq <> v_numseq_new then
                update tpfeinf
                   set numseq = v_numseq_new
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec
                   and numseq = r1.numseq;
                   
                update tpfdinf
                   set numseq = v_numseq_new
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec
                   and numseq = r1.numseq;
                   
                update tpfcinf
                   set numseq = v_numseq_new
                 where codcompy = p_codcompy
                   and trunc(dteeffec) = p_dteeffec
                   and numseq = r1.numseq;
            end if;    
        end loop;
        
        if v_numseq_new = 0 then
            delete from tpfhinf
             where codcompy = p_codcompy
               and trunc(dteeffec) = p_dteeffec;        
        end if;
        
        if param_msg_error is null then
            --<<user37 #2349 Final Test Phase 1 V11 02/03/2021 
            if not v_flg_have_delete then
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            else
                param_msg_error := get_error_msg_php('HR2425',global_v_lang);
            end if;
            --param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            -->>user37 #2349 Final Test Phase 1 V11 02/03/2021 
            commit;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            rollback;
            return;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_save(json_str_input);
        validate_save;
        if param_msg_error is null then
            save_data(json_str_output);
            return;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;
  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
    v_response      varchar2(1000 char);
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      obj_data        := json_object_t();
      if v_flgDisabled then
        v_response  := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null);
      end if;
      obj_data.put('coderror', '200');
      obj_data.put('isEdit', isEdit);
      obj_data.put('isAdd', isAdd);
      obj_data.put('msqerror', v_response);

      obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));

      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    begin
     select count(*) into v_count
       from tpfhinf
      where codcompy = p_codcompy
        and dteeffec  = p_dteeffec;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then
      select max(dteeffec) into v_maxdteeffec
        from tpfhinf
       where codcompy = p_codcompy
         and dteeffec <= p_dteeffec;

      if v_maxdteeffec is null then
        select min(dteeffec) into v_maxdteeffec
          from tpfhinf
         where codcompy = p_codcompy
           and dteeffec > p_dteeffec;
        if v_maxdteeffec is null then
            v_flgDisabled       := false;
            isAdd               := true; 
            isEdit              := false;
            return;
        else 
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
        end if;
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
      
    if p_dteeffecquery < p_dteeffec then
        isAdd           := true; 
        isEdit          := false;
    else
        isAdd           := false;
        isEdit          := not v_flgDisabled;
    end if;

  end;
end HRPYB1E;

/
