--------------------------------------------------------
--  DDL for Package Body HRPY12E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY12E" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        -- index param
        p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
        p_dteeffec        := to_number(hcm_util.get_string_t(json_obj,'p_dteeffec'));
        p_codapp          := upper(hcm_util.get_string_t(json_obj,'p_codapp'));

    end initial_value;

    procedure check_index as
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล
        if p_codcompy is null or p_dteeffec is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- ตรวจสอบ Secure (HR3007)
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    end;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
        obj_row json_object_t;
        obj_group json_object_t;
        obj_data json_object_t;
        obj_data_e json_object_t;
        obj_data_d json_object_t;
        obj_data_o json_object_t;
        v_year number := 0;
        v_rows number := 0;
        obj_formula json_object_t;
        cursor ce is
            select * from tdeductd
            where
                codcompy = p_codcompy and
                dteyreff = v_year and
                typdeduct = 'E'
            order by coddeduct;
        cursor cd is
            select * from tdeductd
            where
                codcompy = p_codcompy and
                dteyreff = v_year and
                typdeduct = 'D'
            order by coddeduct;
        cursor co is
            select * from tdeductd
            where
                codcompy = p_codcompy and
                dteyreff = v_year and
                typdeduct = 'O'
            order by coddeduct;
    begin
        initial_value(json_str_input);
        check_index;
        obj_row := json_object_t();
        obj_group := json_object_t();
        obj_data_e := json_object_t();
        obj_data_d := json_object_t();
        obj_data_o := json_object_t();
        obj_formula := json_object_t();
        if param_msg_error is null then
            begin
                select dteyreff into v_year
                from tdeductd
                where
                    codcompy = p_codcompy and
                    dteyreff <= p_dteeffec
                order by dteyreff desc
                fetch first 1 rows only;
            exception when no_data_found then
                obj_group.put('E',obj_data_e);
                obj_group.put('D',obj_data_d);
                obj_group.put('O',obj_data_o);
                obj_row.put('0',obj_group);
                json_str_output := obj_row.to_clob;
                return;
            end;
            for e in ce loop
                v_rows := v_rows + 1;
                obj_data := json_object_t();
                obj_data.put('coddeduct',e.coddeduct);
                obj_data.put('desc_coddeduct',get_tcodeduct_name(e.coddeduct,global_v_lang));
                obj_data.put('typdeduct',e.typdeduct);
                obj_data.put('amtdemax',nvl(e.amtdemax,0));
                obj_data.put('pctdemax',nvl(e.pctdemax,0));
                obj_formula := json_object_t();
                obj_formula.put('code',e.formula);
                obj_formula.put('description',e.formula);
                obj_data.put('formula',obj_formula);
                obj_data.put('flgdef',e.flgdef);
                obj_data.put('flgclear',e.flgclear);
                obj_data.put('_flgdef',e.flgdef);
                obj_data.put('_flgclear',e.flgclear);
                obj_data_e.put(to_char(v_rows-1),obj_data);
            end loop;
            v_rows := 0;
            for d in cd loop
                v_rows := v_rows + 1;
                obj_data := json_object_t();
                obj_data.put('coddeduct',d.coddeduct);
                obj_data.put('desc_coddeduct',get_tcodeduct_name(d.coddeduct,global_v_lang));
                obj_data.put('typdeduct',d.typdeduct);
                obj_data.put('amtdemax',nvl(d.amtdemax,0));
                obj_data.put('pctdemax',nvl(d.pctdemax,0));
                obj_formula := json_object_t();
                obj_formula.put('code',d.formula);
                obj_formula.put('description',d.formula);
                obj_data.put('formula',obj_formula);
                obj_data.put('flgdef',d.flgdef);
                obj_data.put('flgclear',d.flgclear);
                obj_data.put('_flgdef',d.flgdef);
                obj_data.put('_flgclear',d.flgclear);
                obj_data_d.put(to_char(v_rows-1),obj_data);
            end loop;
            v_rows := 0;
            for o in co loop
                v_rows := v_rows + 1;
                obj_data := json_object_t();
                obj_data.put('coddeduct',o.coddeduct);
                obj_data.put('desc_coddeduct',get_tcodeduct_name(o.coddeduct,global_v_lang));
                obj_data.put('typdeduct',o.typdeduct);
                obj_data.put('amtdemax',nvl(o.amtdemax,0));
                obj_data.put('pctdemax',nvl(o.pctdemax,0));
                obj_formula := json_object_t();
                obj_formula.put('code',o.formula);
                obj_formula.put('description',o.formula);
                obj_data.put('formula',obj_formula);
                obj_data.put('flgdef',o.flgdef);
                obj_data.put('flgclear',o.flgclear);
                obj_data.put('_flgdef',o.flgdef);
                obj_data.put('_flgclear',o.flgclear);
                obj_data_o.put(to_char(v_rows-1),obj_data);
            end loop;
            obj_group.put('E',obj_data_e);
            obj_group.put('D',obj_data_d);
            obj_group.put('O',obj_data_o);
            obj_row.put('0',obj_group);
            json_str_output := obj_row.to_clob;
            return;
        end if;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    function validate_save(v_typdeduct varchar2,v_coddeduct varchar2,v_pctdemax number,v_flgEdit varchar2) return boolean as
        v_check varchar2(1 char);
        v_count number := 0;
    begin
        if v_flgEdit = 'Add' then
            -- รหัสรายการที่ระบุ จะต้องมีอยู่จริงในตาราง TCODEDUCT (HR2010 TCODEDUCT)
            begin
                select 'X' into v_check
                from tcodeduct
                where coddeduct = v_coddeduct;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEDUCT');
                return false;
            end;

            -- รหัสรายการที่ระบุ จะต้องใช้รหัสของบริษัทตนเองเท่านั้น ตรวจสอบจากตาราง TCODEDUCTC แจ้งเตือน “PY0044 - รหัสที่ระบุไม่สามารถใช้กับบริษัทนี้”
            begin
                select 'X' into v_check
                from tcodeductc
                where
                    coddeduct = v_coddeduct and
                    codcompy = p_codcompy;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('PY0044',global_v_lang,v_coddeduct||' - '||get_tcodeduct_name(v_coddeduct,global_v_lang));
                return false;
            end;

            -- ฟิลด์ ‘รหัสรายการ’ รหัสที่ระบุต้องเป็นรหัสยกเว้นภาษีเท่านั้น (PY0001) tcodeduct.typdeduct = 'E'
            if v_typdeduct = 'E' then
                begin
                    select 'X' into v_check
                    from tcodeduct
                    where
                        coddeduct = v_coddeduct and
                        typdeduct = 'E';
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('PY0001',global_v_lang);
                    return false;
                end;
            end if;

            -- ลดหย่อนภาษี : ฟิลด์ ‘รหัสรายการ’ รหัสที่ระบุต้องเป็นรหัสลดหย่อนภาษีเท่านั้น (PY0002) tcodeduct.typdeduct = 'D'
            if v_typdeduct = 'D' then
                begin
                    select 'X' into v_check
                    from tcodeduct
                    where
                        coddeduct = v_coddeduct and
                        typdeduct = 'D';
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('PY0002',global_v_lang);
                    return false;
                end;
            end if;

            -- ส่วนหักอื่น ๆ : ฟิลด์ ‘รหัสรายการ’ รหัสที่ระบุต้องเป็นรหัสส่วนหักอื่นๆเท่านั้น (PY0005) tcodeduct.typdeduct = 'O'
            if v_typdeduct = 'O' then
                begin
                    select 'X' into v_check
                    from tcodeduct
                    where
                        coddeduct = v_coddeduct and
                        typdeduct = 'O';
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('PY0005',global_v_lang);
                    return false;
                end;
            end if;
        end if;

        if  v_flgEdit = 'Add' or v_flgEdit = 'Edit' then
            -- ฟิลด์ ‘% เงินได้’ ใส่ข้อมูลได้ตั้งแต่ 0 – 100 เท่านั้น (HR2020)
            if v_pctdemax < 0 or v_pctdemax > 100 then
                param_msg_error := get_error_msg_php('HR2020',global_v_lang);
                return false;
            end if;
        end if;

        if  v_flgEdit = 'Add' then
            -- ตรวจสอบ การ Dup ของ PK : กรณีรหัสซ้า (HR2005 TDEDUCTD)
            select count(*) into v_count
            from tdeductd
            where
                codcompy = p_codcompy and
                dteyreff = p_dteeffec and
                coddeduct = v_coddeduct;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TDEDUCTD');
                return false;
            end if;
        end if;

        return true;
    end;

    procedure save_index(json_str_input in clob,json_str_output out clob) as

    begin
        initial_value (json_str_input);
        check_index;
        json_input_obj   := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        
        v_count_flg_Delete  := 0;
        v_count_flg_Ot      := 0;
        if param_msg_error is null then
          save_tab1 (json_str_output);
        end if;
        if param_msg_error is null then
          save_tab2 (json_str_output);
        end if;
        if param_msg_error is null then
          save_tab3 (json_str_output);
        end if;
        if param_msg_error is null then
          commit;
          if v_count_flg_Delete > 0 and v_count_flg_Ot = 0 then
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
          else
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          end if;
        else
          rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
--    check_dtepay;
    gen_detail (json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_data         json_object_t;
    v_year           number;
    v_flgdata        varchar2(1 char);

    cursor c1 is
        select * 
          from tdeductd
         where codcompy = p_codcompy 
           and dteyreff <= p_dteyreff_query
        order by dteyreff desc;

  begin
    gen_flg_status; 
    for i in c1 loop
        v_year := i.dteyreff;
        exit;
    end loop;
    v_flgdata := 'N';
    if p_dteeffec >= to_number(to_char(sysdate,'yyyy')) then 
        v_flgdata := 'Y';
    else
        if v_year is null then
            v_flgdata := 'Y';
        end if;
    end if;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', global_v_codempid);
    obj_data.put('coduser', global_v_coduser);
    obj_data.put('desc_coduser', get_temploy_name(global_v_codempid,global_v_lang));
    obj_data.put('dteupd', to_char(sysdate,'dd/mm/yyyy'));
    obj_data.put('flgdata', v_flgdata);
    obj_data.put('flgDisable', v_flgDisabled);
    obj_data.put('dteyreff', p_dteeffec);
    if v_flgDisabled then
        obj_data.put('warning',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
    else 
        obj_data.put('warning','');
    end if;
    if isInsertReport then
          obj_data.put('item1','DETAIL');
          obj_data.put('item2',p_codcompy);
          obj_data.put('item3',p_dteeffec);
          insert_ttemprpt_table(obj_data);
    end if;
    json_str_output := obj_data.to_clob;
  end gen_detail;

 procedure get_tab1 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    gen_tab1 (json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1;

  procedure gen_tab1 (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_codempid          varchar2(100 char);
    v_rcnt              number := 0;
    v_dteyreff          number;
    v_flgdef_b          boolean;
    v_flgclear_b        boolean;
    

    cursor c1 is
        select * 
          from tdeductd
         where codcompy = p_codcompy 
           and dteyreff = p_dteyreff_query
           and typdeduct = 'E'
        order by dteyreff desc;
  begin
    gen_flg_status;
    obj_row         := json_object_t();
    
    for i in c1 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('flgAdd', v_flgAdd);
      obj_data.put('coddeduct', i.coddeduct);
      obj_data.put('desc_coddeduct', get_tcodeduct_name(i.coddeduct,global_v_lang));
      obj_data.put('amtdemax', i.amtdemax);
      obj_data.put('pctdemax', i.pctdemax);
      obj_data.put('typdeduct', i.typdeduct);
      obj_data.put('formula', i.formula);
      obj_data.put('desc_formula', hcm_formula.get_description(i.formula, global_v_lang));
      
      if nvl(i.flgdef,'N') = 'N' then
        v_flgdef_b := false;
      else
        v_flgdef_b := true;
      end if;
      if nvl(i.flgclear,'N') = 'N' then
        v_flgclear_b := false;
      else
        v_flgclear_b := true;
      end if;
      
      obj_data.put('flgdef', v_flgdef_b);
      obj_data.put('_flgdef', nvl(i.flgdef,'N'));
      obj_data.put('flgclear', v_flgclear_b);
      obj_data.put('_flgclear', nvl(i.flgclear,'N'));
      
        if isInsertReport then
          obj_data.put('item1','TABLE1');
          obj_data.put('item2',p_codcompy);
          obj_data.put('item3',p_dteeffec);
          obj_data.put('item4',v_rcnt);
          obj_data.put('item5',i.coddeduct||'-'||get_tcodeduct_name(i.coddeduct,global_v_lang));
          obj_data.put('item6',to_char(i.amtdemax,'999,999,990.00'));
          obj_data.put('item7',to_char(i.pctdemax,'999,999,990.00'));
          obj_data.put('item8',hcm_formula.get_description(i.formula, global_v_lang));
          obj_data.put('item9',nvl(i.flgdef,'N'));
          obj_data.put('item10',nvl(i.flgclear,'N'));
          insert_ttemprpt_table(obj_data);
        end if;
      
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1;

  procedure get_tab2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tab2(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab2;

  procedure gen_tab2 (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_codempid          varchar2(100 char);
    v_rcnt              number := 0;
    v_dteyreff          number;
    v_flgdef_b          boolean;
    v_flgclear_b        boolean;
    

    cursor c1 is
        select * 
          from tdeductd
         where codcompy = p_codcompy 
           and dteyreff = p_dteyreff_query
           and typdeduct = 'D'
        order by dteyreff desc;
  begin
    gen_flg_status;
    obj_row         := json_object_t();
    
    for i in c1 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('flgAdd', v_flgAdd);
      obj_data.put('coddeduct', i.coddeduct);
      obj_data.put('desc_coddeduct', get_tcodeduct_name(i.coddeduct,global_v_lang));
      obj_data.put('amtdemax', i.amtdemax);
      obj_data.put('pctdemax', i.pctdemax);
      obj_data.put('typdeduct', i.typdeduct);
      obj_data.put('formula', i.formula);
      obj_data.put('desc_formula', hcm_formula.get_description(i.formula, global_v_lang));
      
      if nvl(i.flgdef,'N') = 'N' then
        v_flgdef_b := false;
      else
        v_flgdef_b := true;
      end if;
      if nvl(i.flgclear,'N') = 'N' then
        v_flgclear_b := false;
      else
        v_flgclear_b := true;
      end if;
      
      obj_data.put('flgdef', v_flgdef_b);
      obj_data.put('_flgdef', nvl(i.flgdef,'N'));
      obj_data.put('flgclear', v_flgclear_b);
      obj_data.put('_flgclear', nvl(i.flgclear,'N'));
      
        if isInsertReport then
          obj_data.put('item1','TABLE2');
          obj_data.put('item2',p_codcompy);
          obj_data.put('item3',p_dteeffec);
          obj_data.put('item4',v_rcnt);
          obj_data.put('item5',i.coddeduct||'-'||get_tcodeduct_name(i.coddeduct,global_v_lang));
          obj_data.put('item6',to_char(i.amtdemax,'999,999,990.00'));
          obj_data.put('item7',to_char(i.pctdemax,'999,999,990.00'));
          obj_data.put('item8',hcm_formula.get_description(i.formula, global_v_lang));
          obj_data.put('item9',nvl(i.flgdef,'N'));
          obj_data.put('item10',nvl(i.flgclear,'N'));
          insert_ttemprpt_table(obj_data);
        end if;
      
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab2;

  procedure get_tab3 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tab3(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab3;

  procedure gen_tab3 (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_codempid          varchar2(100 char);
    v_rcnt              number := 0;
    v_dteyreff          number;
    v_flgdef_b          boolean;
    v_flgclear_b        boolean;
    

    cursor c1 is
        select * 
          from tdeductd
         where codcompy = p_codcompy 
           and dteyreff = p_dteyreff_query
           and typdeduct = 'O'
        order by dteyreff desc;
  begin
    obj_row         := json_object_t();
    
    for i in c1 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('flgAdd', v_flgAdd);
      obj_data.put('coddeduct', i.coddeduct);
      obj_data.put('desc_coddeduct', get_tcodeduct_name(i.coddeduct,global_v_lang));
      obj_data.put('amtdemax', i.amtdemax);
      obj_data.put('pctdemax', i.pctdemax);
      obj_data.put('typdeduct', i.typdeduct);
      obj_data.put('formula', i.formula);
      obj_data.put('desc_formula', hcm_formula.get_description(i.formula, global_v_lang));
      
      if nvl(i.flgdef,'N') = 'N' then
        v_flgdef_b := false;
      else
        v_flgdef_b := true;
      end if;
      if nvl(i.flgclear,'N') = 'N' then
        v_flgclear_b := false;
      else
        v_flgclear_b := true;
      end if;
      
      obj_data.put('flgdef', v_flgdef_b);
      obj_data.put('_flgdef', nvl(i.flgdef,'N'));
      obj_data.put('flgclear', v_flgclear_b);
      obj_data.put('_flgclear', nvl(i.flgclear,'N'));
      
        if isInsertReport then
          obj_data.put('item1','TABLE3');
          obj_data.put('item2',p_codcompy);
          obj_data.put('item3',p_dteeffec);
          obj_data.put('item4',v_rcnt);
          obj_data.put('item5',i.coddeduct||'-'||get_tcodeduct_name(i.coddeduct,global_v_lang));
          obj_data.put('item6',to_char(i.amtdemax,'999,999,990.00'));
          obj_data.put('item7',to_char(i.pctdemax,'999,999,990.00'));
          obj_data.put('item8',hcm_formula.get_description(i.formula, global_v_lang));
          obj_data.put('item9',nvl(i.flgdef,'N'));
          obj_data.put('item10',nvl(i.flgclear,'N'));
          insert_ttemprpt_table(obj_data);
        end if;
      
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab3;

  procedure save_tab1 (json_str_output out clob) is
    json_param_obj      json_object_t;
    json_row            json_object_t;
    obj_formula         json_object_t;
    v_formula           varchar2(4000 char);
    v_coddeduct         tdeductd.coddeduct%type;
    v_typdeduct         tdeductd.typdeduct%type;
    v_amtdemax          tdeductd.amtdemax%type;
    v_amtdemaxOld       tdeductd.amtdemax%type;
    v_pctdemax          tdeductd.pctdemax%type;
    v_pctdemaxOld       tdeductd.pctdemax%type;
    v_flag              varchar2(100 char);
    v_flgdef_b          boolean;
    v_flgdef            tdeductd.flgdef%type;
    v_flgclear_b        boolean;
    v_flgclear          tdeductd.flgclear%type;
    v_count             number;
    v_validate          boolean;
  begin
    if param_msg_error is null then
        json_param_obj        := hcm_util.get_json_t(json_input_obj,'tab1');
        for i in 0..json_param_obj.get_size-1 loop
            json_row        := hcm_util.get_json_t(json_param_obj,to_char(i));
            v_coddeduct     := hcm_util.get_string_t(json_row,'coddeduct');
            v_typdeduct     := 'E';
            v_amtdemax      := to_number(hcm_util.get_string_t(json_row,'amtdemax'));
            v_amtdemaxOld   := to_number(hcm_util.get_string_t(json_row,'amtdemaxOld'));
            v_pctdemax      := to_number(hcm_util.get_string_t(json_row,'pctdemax'));
            v_pctdemaxOld   := to_number(hcm_util.get_string_t(json_row,'pctdemaxOld'));
            obj_formula     := hcm_util.get_json_t(json_row,'formula');
            v_formula       := hcm_util.get_string_t(obj_formula, 'code');
            v_flag          := hcm_util.get_string_t(json_row, 'flg');
            v_flgdef_b      := hcm_util.get_boolean_t(json_row,'flgdef');
            v_flgclear_b    := hcm_util.get_boolean_t(json_row,'flgclear');
    
            if v_flgdef_b is null then
                v_flgdef    := 'N';
            else
                if v_flgdef_b then
                    v_flgdef  := 'Y';
                else 
                    v_flgdef  := 'N';
                end if;
            end if;
            if v_flgclear_b is null then
                v_flgclear    := 'N';
            else
                if v_flgclear_b then
                    v_flgclear  := 'Y';
                else 
                    v_flgclear  := 'N';
                end if;
            end if;
            
            begin
                select count(*) 
                  into v_count
                  from tdeductd
                 where codcompy  = p_codcompy 
                   and dteyreff  = p_dteeffec 
                   and coddeduct = v_coddeduct 
                   and typdeduct = v_typdeduct;
            exception when others then null;
            end;
    
            v_validate := validate_save(v_typdeduct,v_coddeduct,v_pctdemax,v_flag);
            if v_validate = false then
                exit;
            end if;
            
            if upper(v_flag) = 'ADD' then
                v_count_flg_Ot := v_count_flg_Ot + 1;
                insert into tdeductd (codcompy, dteyreff, coddeduct, typdeduct, 
                                      amtdemax, pctdemax, formula, flgdef, 
                                      flgclear, codcreate, coduser, dtecreate, dteupd)
                              values (p_codcompy,p_dteeffec,v_coddeduct,v_typdeduct,
                                      v_amtdemax,v_pctdemax,v_formula,v_flgdef,
                                      v_flgclear,global_v_coduser,global_v_coduser,sysdate,sysdate);
            elsif upper(v_flag) = 'EDIT' then
                v_count_flg_Ot := v_count_flg_Ot + 1;
                update tdeductd set amtdemax = v_amtdemax,
                                    pctdemax = v_pctdemax,
                                    formula  = v_formula,
                                    flgdef   = v_flgdef,
                                    flgclear = v_flgclear,
                                    coduser  = global_v_coduser,
                                    dteupd   = sysdate
                              where codcompy = p_codcompy 
                                and dteyreff = p_dteeffec 
                                and coddeduct = v_coddeduct
                                and typdeduct = v_typdeduct;
            elsif upper(v_flag) = 'DELETE' then
                v_count_flg_Delete := v_count_flg_Delete + 1;
                delete from tdeductd
                      where codcompy = p_codcompy 
                        and dteyreff = p_dteeffec 
                        and coddeduct = v_coddeduct
                        and typdeduct = v_typdeduct;
                    end if;
        end loop;
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  ----
  procedure save_tab2 (json_str_output out clob) is
    json_param_obj      json_object_t;
    json_row            json_object_t;
    obj_formula         json_object_t;
    v_formula           varchar2(4000 char);
    v_coddeduct         tdeductd.coddeduct%type;
    v_typdeduct         tdeductd.typdeduct%type;
    v_amtdemax          tdeductd.amtdemax%type;
    v_amtdemaxOld       tdeductd.amtdemax%type;
    v_pctdemax          tdeductd.pctdemax%type;
    v_pctdemaxOld       tdeductd.pctdemax%type;
    v_flag              varchar2(100 char);
    v_flgdef_b          boolean;
    v_flgdef            tdeductd.flgdef%type;
    v_flgclear_b        boolean;
    v_flgclear          tdeductd.flgclear%type;
    v_count             number;
    v_validate          boolean;
  begin
    if param_msg_error is null then
        json_param_obj        := hcm_util.get_json_t(json_input_obj,'tab2');
        for i in 0..json_param_obj.get_size-1 loop
            json_row        := hcm_util.get_json_t(json_param_obj,to_char(i));
            v_coddeduct     := hcm_util.get_string_t(json_row,'coddeduct');
            v_typdeduct     := 'D';
            v_amtdemax      := to_number(hcm_util.get_string_t(json_row,'amtdemax'));
            v_amtdemaxOld   := to_number(hcm_util.get_string_t(json_row,'amtdemaxOld'));
            v_pctdemax      := to_number(hcm_util.get_string_t(json_row,'pctdemax'));
            v_pctdemaxOld   := to_number(hcm_util.get_string_t(json_row,'pctdemaxOld'));
            obj_formula     := hcm_util.get_json_t(json_row,'formula');
            v_formula       := hcm_util.get_string_t(obj_formula, 'code');
            v_flag          := hcm_util.get_string_t(json_row, 'flg');
            v_flgdef_b      := hcm_util.get_boolean_t(json_row,'flgdef');
            v_flgclear_b    := hcm_util.get_boolean_t(json_row,'flgclear');
    
            if v_flgdef_b is null then
                v_flgdef    := 'N';
            else
                if v_flgdef_b then
                    v_flgdef  := 'Y';
                else 
                    v_flgdef  := 'N';
                end if;
            end if;
            if v_flgclear_b is null then
                v_flgclear    := 'N';
            else
                if v_flgclear_b then
                    v_flgclear  := 'Y';
                else 
                    v_flgclear  := 'N';
                end if;
            end if;
            
            begin
                select count(*) 
                  into v_count
                  from tdeductd
                 where codcompy  = p_codcompy 
                   and dteyreff  = p_dteeffec 
                   and coddeduct = v_coddeduct 
                   and typdeduct = v_typdeduct;
            exception when others then null;
            end;
    
            v_validate := validate_save(v_typdeduct,v_coddeduct,v_pctdemax,v_flag);
            if v_validate = false then
                exit;
            end if;
            
            if upper(v_flag) = 'ADD' then
                v_count_flg_Ot := v_count_flg_Ot + 1;
                insert into tdeductd (codcompy, dteyreff, coddeduct, typdeduct, 
                                      amtdemax, pctdemax, formula, flgdef, 
                                      flgclear, codcreate, coduser, dtecreate, dteupd)
                              values (p_codcompy,p_dteeffec,v_coddeduct,v_typdeduct,
                                      v_amtdemax,v_pctdemax,v_formula,v_flgdef,
                                      v_flgclear,global_v_coduser,global_v_coduser,sysdate,sysdate);
            elsif upper(v_flag) = 'EDIT' then
                v_count_flg_Ot := v_count_flg_Ot + 1;
                update tdeductd set amtdemax = v_amtdemax,
                                    pctdemax = v_pctdemax,
                                    formula  = v_formula,
                                    flgdef   = v_flgdef,
                                    flgclear = v_flgclear,
                                    coduser  = global_v_coduser,
                                    dteupd   = sysdate
                              where codcompy = p_codcompy 
                                and dteyreff = p_dteeffec 
                                and coddeduct = v_coddeduct
                                and typdeduct = v_typdeduct;
            elsif upper(v_flag) = 'DELETE' then
                v_count_flg_Delete  := v_count_flg_Delete + 1;
                delete from tdeductd
                      where codcompy = p_codcompy 
                        and dteyreff = p_dteeffec 
                        and coddeduct = v_coddeduct
                        and typdeduct = v_typdeduct;
                    end if;
        end loop;
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  ----
  procedure save_tab3 (json_str_output out clob) is
    json_param_obj      json_object_t;
    json_row            json_object_t;
    obj_formula         json_object_t;
    v_formula           varchar2(4000 char);
    v_coddeduct         tdeductd.coddeduct%type;
    v_typdeduct         tdeductd.typdeduct%type;
    v_amtdemax          tdeductd.amtdemax%type;
    v_amtdemaxOld       tdeductd.amtdemax%type;
    v_pctdemax          tdeductd.pctdemax%type;
    v_pctdemaxOld       tdeductd.pctdemax%type;
    v_flag              varchar2(100 char);
    v_flgdef_b          boolean;
    v_flgdef            tdeductd.flgdef%type;
    v_flgclear_b        boolean;
    v_flgclear          tdeductd.flgclear%type;
    v_count             number;
    v_validate          boolean;
  begin
    if param_msg_error is null then
        json_param_obj        := hcm_util.get_json_t(json_input_obj,'tab3');
        for i in 0..json_param_obj.get_size-1 loop
            json_row        := hcm_util.get_json_t(json_param_obj,to_char(i));
            v_coddeduct     := hcm_util.get_string_t(json_row,'coddeduct');
            v_typdeduct     := 'O';
            v_amtdemax      := to_number(hcm_util.get_string_t(json_row,'amtdemax'));
            v_amtdemaxOld   := to_number(hcm_util.get_string_t(json_row,'amtdemaxOld'));
            v_pctdemax      := to_number(hcm_util.get_string_t(json_row,'pctdemax'));
            v_pctdemaxOld   := to_number(hcm_util.get_string_t(json_row,'pctdemaxOld'));
            obj_formula     := hcm_util.get_json_t(json_row,'formula');
            v_formula       := hcm_util.get_string_t(obj_formula, 'code');
            v_flag          := hcm_util.get_string_t(json_row, 'flg');
            v_flgdef_b      := hcm_util.get_boolean_t(json_row,'flgdef');
            v_flgclear_b    := hcm_util.get_boolean_t(json_row,'flgclear');
    
            if v_flgdef_b is null then
                v_flgdef    := 'N';
            else
                if v_flgdef_b then
                    v_flgdef  := 'Y';
                else 
                    v_flgdef  := 'N';
                end if;
            end if;
            if v_flgclear_b is null then
                v_flgclear    := 'N';
            else
                if v_flgclear_b then
                    v_flgclear  := 'Y';
                else 
                    v_flgclear  := 'N';
                end if;
            end if;
            
            begin
                select count(*) 
                  into v_count
                  from tdeductd
                 where codcompy  = p_codcompy 
                   and dteyreff  = p_dteeffec 
                   and coddeduct = v_coddeduct 
                   and typdeduct = v_typdeduct;
            exception when others then null;
            end;
    
            v_validate := validate_save(v_typdeduct,v_coddeduct,v_pctdemax,v_flag);
            if v_validate = false then
                exit;
            end if;
            
            if upper(v_flag) = 'ADD' then
                v_count_flg_Ot := v_count_flg_Ot + 1;
                insert into tdeductd (codcompy, dteyreff, coddeduct, typdeduct, 
                                      amtdemax, pctdemax, formula, flgdef, 
                                      flgclear, codcreate, coduser, dtecreate, dteupd)
                              values (p_codcompy,p_dteeffec,v_coddeduct,v_typdeduct,
                                      v_amtdemax,v_pctdemax,v_formula,v_flgdef,
                                      v_flgclear,global_v_coduser,global_v_coduser,sysdate,sysdate);
            elsif upper(v_flag) = 'EDIT' then
                v_count_flg_Ot := v_count_flg_Ot + 1;
                update tdeductd set amtdemax = v_amtdemax,
                                    pctdemax = v_pctdemax,
                                    formula  = v_formula,
                                    flgdef   = v_flgdef,
                                    flgclear = v_flgclear,
                                    coduser  = global_v_coduser,
                                    dteupd   = sysdate
                              where codcompy = p_codcompy 
                                and dteyreff = p_dteeffec 
                                and coddeduct = v_coddeduct
                                and typdeduct = v_typdeduct;
            elsif upper(v_flag) = 'DELETE' then
                v_count_flg_Delete := v_count_flg_Delete + 1;
                delete from tdeductd
                      where codcompy = p_codcompy 
                        and dteyreff = p_dteeffec 
                        and coddeduct = v_coddeduct
                        and typdeduct = v_typdeduct;
                    end if;
        end loop;
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  
  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      gen_detail(json_output);
      gen_tab1(json_output);
      gen_tab2(json_output);
      gen_tab3(json_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;
  
  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq            number := 0;

    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;


  begin

    v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
    v_item2       := nvl(hcm_util.get_string_t(obj_data, 'item2'), '');
    v_item3       := nvl(hcm_util.get_string_t(obj_data, 'item3'), '');
    v_item4       := nvl(hcm_util.get_string_t(obj_data, 'item4'), '');
    v_item5       := nvl(hcm_util.get_string_t(obj_data, 'item5'), '');
    v_item6       := nvl(hcm_util.get_string_t(obj_data, 'item6'), '');
    v_item7       := nvl(hcm_util.get_string_t(obj_data, 'item7'), '');
    v_item8       := nvl(hcm_util.get_string_t(obj_data, 'item8'), '');
    v_item9       := nvl(hcm_util.get_string_t(obj_data, 'item9'), '');
    v_item10      := nvl(hcm_util.get_string_t(obj_data, 'item10'), '');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
      v_numseq := v_numseq + 1;
      
      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3
               , item4, item5, item6, item7, item8, item9, item10
             )
        values
             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             , v_item4,v_item5,v_item6, v_item7, v_item8, v_item9, v_item10
        );
      exception when others then
        null;
      end;
      commit;
  end;

  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteyreff     number(4,0);
  begin
      begin
        select count(*) into v_count
          from tdeductd
         where codcompy = p_codcompy 
           and dteyreff = p_dteeffec;
      exception when no_data_found then
        v_count := 0;
      end;  
      
      if v_count = 0 then
        select max(dteyreff) into v_maxdteyreff
          from tdeductd
         where codcompy = p_codcompy 
           and dteyreff <= p_dteeffec;
           
        if v_maxdteyreff is null then
            select min(dteyreff) into v_maxdteyreff
              from tdeductd
             where codcompy = p_codcompy 
               and dteyreff > p_dteeffec; 
            if v_maxdteyreff is null then
                v_flgDisabled     := false;
            else 
                v_flgDisabled     := true;
                p_dteyreff_query  := v_maxdteyreff;
                p_dteeffec        := v_maxdteyreff;
            end if;
        else
            if p_dteeffec < to_char(sysdate,'yyyy') then
              v_flgDisabled     := true;
              p_dteyreff_query  := v_maxdteyreff;
              p_dteeffec        := v_maxdteyreff;
            else
              v_flgDisabled     := false;
              p_dteyreff_query  := v_maxdteyreff;
            end if;
        end if;
      else
        if p_dteeffec < to_char(sysdate,'yyyy') then
          v_flgDisabled := true;
        else
          v_flgDisabled := false;
        end if;
        p_dteyreff_query := p_dteeffec;
      end if;
      
      if p_dteyreff_query < p_dteeffec then
        v_flgAdd          := true;  
      else
        v_flgAdd          := false;  
      end if;
  end gen_flg_status;
end HRPY12E;

/
