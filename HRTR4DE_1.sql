--------------------------------------------------------
--  DDL for Package Body HRTR4DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR4DE" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codcompy         := upper(hcm_util.get_string(json_obj,'p_codcompy'));
        p_year          := hcm_util.get_string(json_obj,'p_year');
    end initial_value;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json; 
        v_row       number := 0;
        v_row_secur      number := 0;
        cursor c1 is
            select dteyear,codcomp,bugtrin,bugtrout from ttrnbudg 
            where hcm_util.get_codcomp_level(codcomp,1) like p_codcompy and dteyear = p_year
            order by codcomp;
    begin
        obj_rows := json();
        for i in c1 loop
                v_row := v_row+1;
            if secur_main.secur7(i.codcomp,global_v_coduser) = true then
                v_row_secur := v_row_secur+1;
                obj_data := json();
                obj_data.put('dteyear',i.dteyear);
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('bugtrin',i.bugtrin);
                obj_data.put('bugtrout',i.bugtrout);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if  v_row > 0 and v_row_secur = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_codcompy is null or p_year is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X' into v_temp 
            from tcompny 
            where codcompy like p_codcompy
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_index;

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

    procedure check_param(data_obj json) as
        v_temp       varchar2(40 char);
        p_codcomp    ttrnbudg.codcomp%type;
        p_bugtrin    ttrnbudg.bugtrin%type;   
        p_bugtrout   ttrnbudg.bugtrout%type;     
    begin
        p_codcomp      := upper(hcm_util.get_string(data_obj,'codcomp'));
        p_bugtrin          := hcm_util.get_string(data_obj,'bugtrin');
        p_bugtrout          := hcm_util.get_string(data_obj,'bugtrout');
        if p_codcomp is null or p_bugtrin is null or p_bugtrout is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if hcm_util.get_codcomp_level(p_codcomp,1) != p_codcompy then
            param_msg_error := get_error_msg_php('TR0040',global_v_lang);
            return;
        end if;
        begin
            select distinct 'X' into v_temp
            from tcenter 
            where codcomp like p_codcomp||'%';
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end;
    end check_param;

    procedure delete_budget(data_obj json) as
        v_codcomp     ttrnbudg.codcomp%type;
        v_bugtrin   ttrnbudg.bugtrin%type;
        v_bugtrout   ttrnbudg.bugtrout%type;
    begin
        v_codcomp   := upper(hcm_util.get_string(data_obj,'codcomp')); 
        v_bugtrin   := to_number(hcm_util.get_string(data_obj,'bugtrin')); 
        v_bugtrout  := to_number(hcm_util.get_string(data_obj,'bugtrout')); 
        delete ttrnbudg             
        where dteyear  = p_year
            and codcomp = v_codcomp;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace; 
    end delete_budget;

    procedure insert_budget(data_obj json) as
        v_codcomp     ttrnbudg.codcomp%type;
        v_bugtrin   ttrnbudg.bugtrin%type;
        v_bugtrout   ttrnbudg.bugtrout%type;

        v_temp       varchar2(40 char);
    begin
        v_codcomp   := upper(hcm_util.get_string(data_obj,'codcomp')); 
        v_bugtrin   := to_number(hcm_util.get_string(data_obj,'bugtrin')); 
        v_bugtrout  := to_number(hcm_util.get_string(data_obj,'bugtrout')); 

        param_msg_error  := get_error_msg_php('HR2005',global_v_lang,'TTRNBUDG'); 
        begin
            select 'x' into v_temp   
            from ttrnbudg
            where dteyear = p_year
            and  codcomp like v_codcomp
            and rownum = 1;
            exception when no_data_found THEN
                param_msg_error  := null;      
        end;
        if param_msg_error  is null then
        insert into  ttrnbudg (dteyear,codcomp,bugtrin,bugtrout,dtecreate,codcreate,dteupd,coduser)
             values (p_year,v_codcomp,v_bugtrin,v_bugtrout,sysdate,global_v_coduser,sysdate,global_v_coduser);
        end if;
    end insert_budget;

    procedure update_budget(data_obj json) as
        v_codcomp     ttrnbudg.codcomp%type;
        v_codcompOld  ttrnbudg.codcomp%type; 
        v_bugtrin     ttrnbudg.bugtrin%type;
        v_bugtrout    ttrnbudg.bugtrout%type;

    begin
        v_codcomp    := upper(hcm_util.get_string(data_obj,'codcomp')); 
        v_codcompOld := upper(hcm_util.get_string(data_obj,'codcompOld')); 
        v_bugtrin    := to_number(hcm_util.get_string(data_obj,'bugtrin')); 
        v_bugtrout   := to_number(hcm_util.get_string(data_obj,'bugtrout')); 

        update ttrnbudg 
           set dteyear = p_year,
               codcomp = v_codcomp,
               bugtrin = v_bugtrin,
               bugtrout = v_bugtrout,
               dteupd  =  sysdate,
               coduser  = global_v_coduser
         where codcomp  = v_codcompOld
           and dteyear  = p_year;
    end update_budget;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
        data_obj    json;
        v_item_flgedit varchar2(10 char);
    begin
        initial_value(json_str_input);
        check_index;
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');

        for i in 0..param_json.count-1 loop
            data_obj := hcm_util.get_json(param_json,to_char(i));
            check_param(data_obj);
            if param_msg_error is null then
                v_item_flgedit := hcm_util.get_string(data_obj,'flag');
                if v_item_flgedit = 'Add' then
                    insert_budget(data_obj);
                elsif v_item_flgedit = 'Edit' then
                    update_budget(data_obj);
                elsif v_item_flgedit = 'Delete' then
                    delete_budget(data_obj);
                end if;
            else
                exit;
            end if;
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
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace; 
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;
END HRTR4DE;

/
