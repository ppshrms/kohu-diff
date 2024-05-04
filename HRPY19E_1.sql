--------------------------------------------------------
--  DDL for Package Body HRPY19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY19E" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        -- index param
        p_codcompy        := hcm_util.get_string_t(json_obj,'codcompy');
        p_dteyreff        := to_number(hcm_util.get_string_t(json_obj,'dteyreff'));
        p_delete_all      := nvl(hcm_util.get_string_t(json_obj,'delete_all'),'N');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล
        if p_codcompy is null or p_dteyreff is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- รหัสบริษัท ตรวจสอบรหัสต้องมีอยู่ในตาราง TCOMPNY (HR2010)
        begin
            select 'X' into v_temp
            from tcompny
            where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;

        -- ตรวจสอบ Secure (HR3007)
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    end;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
        v_year      number(4,0) := 0;
        v_row       number := 0;
        obj_row     json_object_t;
        obj_data    json_object_t;
        obj_detail  json_object_t;
        obj_main    json_object_t;
        
        cursor c1 is
            select * 
              from tproctax
             where codcompy = p_codcompy 
               and dteyreff = p_dteyreff_query
          order by codcompy,dteyreff,numseq;

        cursor c_maxyear is
            select dteyreff
              from tproctax
             where codcompy = p_codcompy 
               and dteyreff <= p_dteyreff
          order by dteyreff desc ;
    begin
        initial_value(json_str_input);
        check_index;

        
        if param_msg_error is null then
            gen_flg_status;
            obj_detail  := json_object_t();
            obj_detail.put('coderror',200);
            obj_detail.put('dteyrepay',p_dteyreff);
            obj_detail.put('flgDisable',v_flgDisabled);
            if v_flgDisabled then
                obj_detail.put('warning',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
            else
                obj_detail.put('warning','');
            end if;        
        
            obj_row := json_object_t();
            for i in c1 loop
                v_row       := v_row +1;
                obj_data    := json_object_t();
                obj_data.put('dteyreff',i.dteyreff);
                obj_data.put('numseq',i.numseq);
                obj_data.put('desproc','');
                obj_data.put('desproce',i.desproce);
                obj_data.put('desproct',i.desproct);
                obj_data.put('desproc3',i.desproc3);
                obj_data.put('desproc4',i.desproc4);
                obj_data.put('desproc5',i.desproc5);
                obj_data.put('formula',i.formula);
                obj_data.put('desc_formula',hcm_formula.get_description(i.formula, global_v_lang));
                obj_data.put('fmlmax',i.fmlmax);
--                obj_data.put('desc_fmlmax',i.fmlmax);
                obj_data.put('desc_fmlmax',hcm_formula.get_description(i.fmlmax, global_v_lang));
                obj_data.put('fmlmaxtot',i.fmlmaxtot);
--                obj_data.put('desc_fmlmaxtot',i.fmlmaxtot);
                obj_data.put('desc_fmlmaxtot',hcm_formula.get_description(i.fmlmaxtot, global_v_lang));
                obj_data.put('flgAdd',v_flgAdd);                
                obj_row.put(to_char(v_row-1),obj_data);
            end loop;
            
            obj_main    := json_object_t();
            obj_main.put('coderror',200);
            obj_main.put('detail',obj_detail);      
            obj_main.put('table',obj_row);            
            
            json_str_output := obj_main.to_clob;
            return;
        end if;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    function validate_coddeduct(p_codeduct varchar2) return boolean as
        v_temp      varchar2(1 char);
    begin
        -- รหัสลดหย่อน จะต้องมีอยู่จริงในตาราง TCODEDUCT (HR2010 TCODEDUCT)
        begin
            select 'X' into v_temp
              from tcodeduct
             where coddeduct = p_codeduct;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEDUCT');
            return false;
        end;
        -- รหัสลดหย่อน จะต้องใช้รหัสของบริษัทตนเองเท่านั้น ตรวจสอบจากตาราง TCODEDUCTC (PY0044)
        begin
            select 'X' into v_temp
              from tcodeductc
             where coddeduct = p_codeduct 
               and codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('PY0044',global_v_lang,p_codeduct||' - '||get_tcodeduct_name(p_codeduct,global_v_lang));
            return false;
        end;
        return true;
    end;

    function validate_save(
        p_numseq            number,
        p_formula           varchar2,
        p_fmlmax            varchar2,
        p_fmlmaxtot         varchar2,
        p_formula_deduct    json_object_t,
        p_formula_items     json_object_t,
        p_fmlmax_deduct     json_object_t,
        p_fmlmax_items      json_object_t,
        p_fmlmaxtot_deduct  json_object_t,
        p_fmlmaxtot_items   json_object_t,
        p_flg               varchar2
    ) return boolean as
        obj_deduct      json_object_t;
        obj_items       json_object_t;
        v_codeduct      varchar2(4 char);
        v_item          number;
        v_temp          varchar2(1 char);
        v_item_name     varchar2(10 char);
        v_using_count   number :=0;
        v_dup           number := 0;
        v_check_item    number := 0;
    begin

        if p_flg = 'add' or p_flg = 'edit' then
            -- บังคับกรอกข้อมูล (HR2045) สูตรคานวณ (ยกเว้นลาดับที่ 1 ไม่ต้องบังคับ)
            if p_numseq > 1 and p_formula is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return false;
            end if;
            if param_msg_error is not null then
                return false;
            end if;
            -- สูตรคานวณ รหัสลดหย่อน
            if p_formula is not null then
                obj_deduct := p_formula_deduct;
                for i in 0..obj_deduct.get_size-1 loop
                    v_codeduct := hcm_util.get_string_t(obj_deduct,to_char(i));
                    if validate_coddeduct(v_codeduct) = false then
                        exit;
                    end if;
                end loop;
                if param_msg_error is not null then
                    return false;
                end if;

                -- สูตรคานวณ Item รายละเอียด ต้องระบุ ลาดับที่ก่อนหน้า เท่านั้น (HR2810)
                obj_items := p_formula_items;
                for i in 0..obj_items.get_size-1 loop
                    v_item := to_number(hcm_util.get_string_t(obj_items,to_char(i)));
                    if v_item != 0 and v_item > p_numseq then
                        param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                        exit;
                    end if;

                    -- การอ้างถึง Item ที่ไม่มีอยู่
                    begin
                        select 'X' into v_temp
                          from tproctax
                         where codcompy = p_codcompy 
                           and dteyreff = p_dteyreff 
                           and numseq = v_item;
                    exception when no_data_found then
                        param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                        exit;
                    end;
                end loop;
                if param_msg_error is not null then
                    return false;
                end if;
            end if;

            if p_fmlmax is not null then
                -- แยกยื่น รหัสลดหย่อน
                obj_deduct := p_fmlmax_deduct;
                for i in 0..obj_deduct.get_size-1 loop
                    v_codeduct := hcm_util.get_string_t(obj_deduct,to_char(i));
                    if validate_coddeduct(v_codeduct) = false then
                        exit;
                    end if;
                end loop;
                if param_msg_error is not null then
                    return false;
                end if;

                -- แยกยื่น Item รายละเอียด ต้องระบุ ลาดับที่ก่อนหน้า เท่านั้น (HR2810)
                obj_items := p_fmlmax_items;
                for i in 0..obj_items.get_size-1 loop
                    v_item := to_number(hcm_util.get_string_t(obj_items,to_char(i)));
                    if v_item != 0 and v_item > p_numseq then
                        param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                        exit;
                    end if;

                    -- การอ้างถึง Item ที่ไม่มีอยู่
                    begin
                        select 'X' into v_temp
                          from tproctax
                         where codcompy = p_codcompy 
                           and dteyreff = p_dteyreff 
                           and numseq = v_item;
                    exception when no_data_found then
                        param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                        exit;
                    end;
                end loop;
                if param_msg_error is not null then
                    return false;
                end if;
            end if;

            if p_fmlmaxtot is not null then
                -- รวมยื่น รหัสลดหย่อน
                obj_deduct := p_fmlmaxtot_deduct;
                for i in 0..obj_deduct.get_size-1 loop
                    v_codeduct := hcm_util.get_string_t(obj_deduct,to_char(i));
                    if validate_coddeduct(v_codeduct) = false then
                        exit;
                    end if;
                end loop;
                if param_msg_error is not null then
                    return false;
                end if;

                -- รวมยื่น Item รายละเอียด ต้องระบุ ลาดับที่ก่อนหน้า เท่านั้น (HR2810)
                obj_items := p_fmlmaxtot_items;
                for i in 0..obj_items.get_size-1 loop
                    v_item := to_number(hcm_util.get_string_t(obj_items,to_char(i)));
                    if v_item != 0 and v_item > p_numseq then
                        param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                        exit;
                    end if;

                    -- การอ้างถึง Item ที่ไม่มีอยู่
                    begin
                        select 'X' into v_temp
                          from tproctax
                         where codcompy = p_codcompy 
                           and dteyreff = p_dteyreff 
                           and numseq = v_item;
                    exception when no_data_found then
                        param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                        exit;
                    end;
                end loop;
                if param_msg_error is not null then
                    return false;
                end if;
            end if;
        end if; -- end if flg=add & edit

        if p_flg = 'add' then
            -- ต้องไม่ซ้ากับที่มีอยู่ ตาม PK ของตาราง TPROCTAX (HR2005 TPROCTAX)
            begin
                select count(*) into v_dup
                  from tproctax
                 where codcompy = p_codcompy 
                   and dteyreff = p_dteyreff 
                   and numseq = p_numseq;
            exception when others then null;
            end;
            if v_dup > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPROCTAX');
                return false;
            end if;
        end if;

        if p_flg = 'delete' then
            -- ตรวจสอบค่าข้อมูลใน “สูตรคานวณ,แยกยื่น,รวมยื่น” ที่อ้างถึง Item ที่ถูกลบไป (HR2810)
            v_item_name := '%{item'||p_numseq||'}%';
            select count(*) into v_using_count
              from tproctax
             where codcompy = p_codcompy 
               and dteyreff = p_dteyreff 
               and (
                    (formula like v_item_name) or
                    (fmlmax like v_item_name) or
                    (fmlmaxtot like v_item_name)
                   );
            if v_using_count > 0 then
                param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                return false;
            end if;
        end if;
        return true;
    end;

    procedure save_index(json_str_input in clob,json_str_output out clob) as
        v_numseq            number :=0;
        v_desproce          varchar2(105 char);
        v_desproct          varchar2(105 char);
        v_desproc3          varchar2(105 char);
        v_desproc4          varchar2(105 char);
        v_desproc5          varchar2(105 char);
        v_formula           varchar2(500 char);
        v_fmlmax            varchar2(500 char);
        v_fmlmaxtot         varchar2(500 char);
        v_flg               varchar2(10 char);
        v_formula_deduct    json_object_t;
        v_formula_items     json_object_t;
        v_fmlmax_deduct     json_object_t;
        v_fmlmax_items      json_object_t;
        v_fmlmaxtot_deduct  json_object_t;
        v_fmlmaxtot_items   json_object_t;

        json_obj            json_object_t;
        obj_data            json_object_t;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            json_obj        := json_object_t(json_str_input);
            param_json      := hcm_util.get_json_t(json_obj,'param_json');
            for i in 0..param_json.get_size-1 loop
                obj_data    := hcm_util.get_json_t(param_json,to_char(i));
                v_numseq    := to_number(hcm_util.get_string_t(obj_data,'numseq'));
                v_desproce  := hcm_util.get_string_t(obj_data,'desproce');
                v_desproct  := hcm_util.get_string_t(obj_data,'desproct');
                v_desproc3  := hcm_util.get_string_t(obj_data,'desproc3');
                v_desproc4  := hcm_util.get_string_t(obj_data,'desproc4');
                v_desproc5  := hcm_util.get_string_t(obj_data,'desproc5');
                v_formula   := hcm_util.get_string_t(obj_data,'formula');
                v_fmlmax    := hcm_util.get_string_t(obj_data,'fmlmax');
                v_fmlmaxtot := hcm_util.get_string_t(obj_data,'fmlmaxtot');
                v_flg       := hcm_util.get_string_t(obj_data,'flg');
                
                v_formula_deduct    := hcm_util.get_json_t(obj_data,'formula_deduct');
                v_formula_items     := hcm_util.get_json_t(obj_data,'formula_items');
                v_fmlmax_deduct     := hcm_util.get_json_t(obj_data,'fmlmax_deduct');
                v_fmlmax_items      := hcm_util.get_json_t(obj_data,'fmlmax_items');
                v_fmlmaxtot_deduct  := hcm_util.get_json_t(obj_data,'fmlmaxtot_deduct');
                v_fmlmaxtot_items   := hcm_util.get_json_t(obj_data,'fmlmaxtot_items');

                if validate_save(v_numseq,v_formula,v_fmlmax,v_fmlmaxtot,v_formula_deduct,v_formula_items,v_fmlmax_deduct,v_fmlmax_items,v_fmlmaxtot_deduct,v_fmlmaxtot_items,v_flg) = false then
                    exit;
                end if;

                if v_flg = 'add' then
                    insert into tproctax (
                        codcompy, dteyreff, numseq, 
                        desproce, desproct, desproc3, desproc4, desproc5,
                        formula, fmlmax, fmlmaxtot, coduser, codcreate)
                    values (
                        p_codcompy, p_dteyreff, v_numseq,
                        v_desproce, v_desproct, v_desproc3, v_desproc4, v_desproc5,
                        v_formula, v_fmlmax, v_fmlmaxtot, global_v_coduser, global_v_coduser);
                elsif v_flg = 'edit' then
                    update tproctax set
                        desproce = v_desproce,
                        desproct = v_desproct,
                        desproc3 = v_desproc3,
                        desproc4 = v_desproc4,
                        desproc5 = v_desproc5,
                        formula = v_formula,
                        fmlmax = v_fmlmax,
                        fmlmaxtot = v_fmlmaxtot,
                        coduser = global_v_coduser
                    where
                        codcompy = p_codcompy and
                        dteyreff = p_dteyreff and
                        numseq = v_numseq;
                elsif v_flg = 'delete' then
                    delete from tproctax
                     where codcompy = p_codcompy 
                       and dteyreff = p_dteyreff 
                       and numseq = v_numseq;
                end if;
            end loop;
            if param_msg_error is null then
                commit;
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            else
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteyreff     number(4,0);
  begin
      begin
        select count(*) into v_count
          from tproctax
         where codcompy = p_codcompy 
           and dteyreff = p_dteyreff;
      exception when no_data_found then
        v_count := 0;
      end;  
      
      if v_count = 0 then
        select max(dteyreff) into v_maxdteyreff
          from tproctax
         where codcompy = p_codcompy 
           and dteyreff <= p_dteyreff;
           
        if v_maxdteyreff is null then
            select min(dteyreff) into v_maxdteyreff
              from tproctax
             where codcompy = p_codcompy 
               and dteyreff > p_dteyreff; 
            if v_maxdteyreff is null then
                v_flgDisabled     := false;
            else 
                v_flgDisabled     := true;
                p_dteyreff_query  := v_maxdteyreff;
                p_dteyreff        := v_maxdteyreff;
            end if;
        else
            if p_dteyreff < to_char(sysdate,'yyyy') then
              v_flgDisabled     := true;
              p_dteyreff_query  := v_maxdteyreff;
              p_dteyreff        := v_maxdteyreff;
            else
              v_flgDisabled     := false;
              p_dteyreff_query  := v_maxdteyreff;
            end if;
        end if;
      else
        if p_dteyreff < to_char(sysdate,'yyyy') then
          v_flgDisabled := true;
        else
          v_flgDisabled := false;
        end if;
        p_dteyreff_query := p_dteyreff;
      end if;
      
      if p_dteyreff_query < p_dteyreff then
        v_flgAdd          := true;  
      else
        v_flgAdd          := false;  
      end if;
  end gen_flg_status;

end HRPY19E;

/
