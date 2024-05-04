--------------------------------------------------------
--  DDL for Package Body TRAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "TRAIN_PKG" is
    function train_sum(p_input1 number, p_input2 number) return number is
        v_output    number;
    begin
        v_output := p_input1 + p_input2 + global_v_num;
        return v_output;
    end;

    procedure train_sum2(p_input1  number, p_input2 number, p_output1 out number) is
    begin
        global_v_num := 1;
        p_output1 := train_sum(p_input1,p_input2);
    end;
    
    procedure initial_value(json_str in clob) is
    begin
        param_msg_error := null;
    end;
    
    procedure check_save is
        v_codemp_chk    tt.codempid%type;
    begin
        BEGIN
            SELECT 
                CODEMPID INTO v_codemp_chk 
            FROM 
                TEMPLOY1 
            WHERE 
                codempid = v_codempid;
                
        EXCEPTION WHEN NO_DATA_FOUND THEN
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        END;
        
        if v_staemp NOT IN (0,1,3,9) then
            param_msg_error := get_error_msg_php('HR2020',global_v_lang);
            return;
        end if;
    END;
    
    procedure check_delete is
        v_codemp_chk    tt.codempid%type;
    begin
        begin
            SELECT 
                CODEMPID INTO v_codemp_chk 
            FROM 
                tt
            WHERE 
                CODEMPID = v_codempid AND
                STAEMP = v_staemp AND
                CSTR LIKE '%'||v_cstr||'%';
                
        EXCEPTION WHEN NO_DATA_FOUND THEN
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TT');
            return;
        end;
        
        if v_staemp NOT IN (0,1,3,9) then
            param_msg_error := get_error_msg_php('HR2020',global_v_lang);
            return;
        end if;
    end;
    
    
    procedure save_data(json_str_input in clob,json_str_output out clob) is
        v_row_in    json_object_t;
        obj_row     json_object_t;
        v_dt1       varchar2(100 char);
        v_dt2       varchar2(100 char);
    begin
        initial_value(json_str_input);
        
        v_row_in   := json_object_t(json_str_input);
        obj_row    := json_object_t();
         
        FOR i IN 0..v_row_in.get_size - 1  LOOP
            obj_row := hcm_util.get_json_t(v_row_in,to_char(i));
            
            v_codempid  := hcm_util.get_string_t(obj_row,'codempid');
            v_staemp    := hcm_util.get_number_t(obj_row,'staemp');
            v_cstr      := hcm_util.get_string_t(obj_row,'cstr');
            v_d1        := hcm_util.get_string_t(obj_row,'date1');
            v_d2        := hcm_util.get_string_t(obj_row,'date2');
            
            v_dt1       := TO_CHAR(TO_DATE(v_d1,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS');
            v_dt2       := TO_CHAR(TO_DATE(v_d2,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS');
            
            v_date1     := to_date(v_dt1,'DD/MM/YYYY HH24:MI:SS');
            v_date2     := to_date(v_dt2,'DD/MM/YYYY HH24:MI:SS');
            
            check_save;
            
            IF param_msg_error IS NULL THEN
                begin
                    INSERT INTO tt (codempid,staemp,cstr,date1,date2) 
                    VALUES (v_codempid,v_staemp,v_cstr,v_date1,v_date2);
                    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
                exception when dup_val_on_index then
                    update tt 
                    set staemp = v_staemp , cstr = v_cstr , date1 = v_date1, date2 = v_date2
                    where codempid = v_codempid;
                    param_msg_error := get_error_msg_php('HR2410',global_v_lang);
                END; 
            END IF;
         
         END LOOP;
         
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         COMMIT;  
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;
    
    procedure delete_data(json_str_input in clob,json_str_output out clob) is
        v_row_in    json_object_t;
        obj_row     json_object_t;
    BEGIN
        initial_value(json_str_input);
        
        v_row_in   := json_object_t(json_str_input);
        obj_row    := json_object_t();
        
        FOR i IN 0..v_row_in.get_size - 1  LOOP
            obj_row := hcm_util.get_json_t(v_row_in,to_char(i));
            
            v_codempid := hcm_util.get_string_t(obj_row,'codempid');
            v_staemp := hcm_util.get_number_t(obj_row,'staemp');
            v_cstr   := hcm_util.get_string_t(obj_row,'cstr');
            
            check_save;
            check_delete;
            
            IF param_msg_error IS NULL THEN
                begin
                    DELETE FROM TT WHERE CODEMPID = v_codempid;
                exception when dup_val_on_index then
                    update tt set staemp = v_staemp where codempid = v_codempid;
                    param_msg_error := get_error_msg_php('HR2410',global_v_lang);
                END; 
            END IF;
        END LOOP;
        
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         COMMIT;  
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        
    END;
    
    procedure search_data(json_str_input in clob,json_str_output out clob) is
        v_row_in        json_object_t;
        obj_row         json_object_t;
        v_search        clob;
        
        query_string   clob;
        
    begin
        initial_value(json_str_input);
        
        v_row_in   := json_object_t(json_str_input);
        obj_row    := json_object_t();
        
        FOR i IN 0..v_row_in.get_size - 1  LOOP
            obj_row := hcm_util.get_json_t(v_row_in,to_char(i));
            
            v_codempid  := hcm_util.get_string_t(obj_row,'codempid');
            v_staemp    := hcm_util.get_number_t(obj_row,'staemp');
            v_cstr      := hcm_util.get_string_t(obj_row,'cstr');
            v_date1     := hcm_util.get_string_t(obj_row,'date1');
            v_date2     := hcm_util.get_string_t(obj_row,'date2');
            
            if v_codempid is not null then
                if LENGTH(global_v_query) > 0 then
                    global_v_query := global_v_query||' AND codempid = '||v_codempid;
                ELSE
                    global_v_query := global_v_query||' WHERE codempid = '||v_codempid;
                end if;
            end if;
            
            if v_staemp is not null then
                if LENGTH(global_v_query) > 0 then
                    global_v_query := global_v_query||' AND staemp = '||v_staemp;
                ELSE
                    global_v_query := global_v_query||' WHERE staemp = '||v_staemp;
                end if;
            end if;
            
            if v_cstr is not null then
                if LENGTH(global_v_query) > 0 then
                    global_v_query := global_v_query||' AND cstr = '||v_cstr;
                ELSE
                    global_v_query := global_v_query||' WHERE cstr = '||v_cstr;
                end if;
            end if;
            
            if v_date1 is not null then
                if LENGTH(global_v_query) > 0 then
                    global_v_query := global_v_query||' AND date1 = '||v_date1;
                ELSE
                    global_v_query := global_v_query||' WHERE date1 = '||v_date1;
                end if;
            end if;
            
            if v_date2 is not null then
                if LENGTH(global_v_query) > 0 then
                    global_v_query := global_v_query||' AND date1 = '||v_date2;
                ELSE
                    global_v_query := global_v_query||' WHERE date1 = '||v_date2;
                end if;
            end if;
        end loop;
        
        begin
            global_v_query := 'SELECT * FROM tt' || global_v_query;
--            execute immediate global_v_query INTO v_search;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TT');
            return;
        end;
        
        json_str_output := global_v_query;
        
        
    end;
    
    procedure get_data(json_str_input in clob,json_str_output out clob) is
        v_row_in        json_object_t;
        obj_data        json_object_t;
        obj_row_in      json_object_t;
        obj_row_out     json_object_t;
        v_search        json_object_t;
        
        query_string   clob;
        
        cursor c1 is
            SELECT * 
            FROM TT 
            WHERE 
                codempid = nvl(v_codempid,codempid)
                and staemp = nvl(v_staemp,staemp);
        
    begin
        initial_value(json_str_input);
        obj_row_in  := json_object_t();
        obj_row_out := json_object_t();
        
        v_row_in    := json_object_t(json_str_input);
        obj_row_in  := hcm_util.get_json_t(v_row_in,to_char(0));
        v_codempid  := hcm_util.get_string_t(obj_row_in,'codempid');
        
        for v1 in c1 loop
            obj_data := json_object_t();
            obj_data.put('codempid1',v1.codempid);
            obj_data.put('staemp',v1.staemp);
            obj_data.put('cstr',v1.cstr);
            obj_row_out.put(global_v_num,obj_data);
            global_v_num := global_v_num + 1;
        end loop;
        
        json_str_output := obj_row_out.to_clob;
    end;
    
END;

/
