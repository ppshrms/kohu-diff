--------------------------------------------------------
--  DDL for Package Body HRBF1AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1AE" AS

    procedure initial_value(json_str_input in clob) as
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codheal         := hcm_util.get_string(json_obj,'p_codheal');
        p_codprgheal      := hcm_util.get_string(json_obj,'p_codprgheal');
    end initial_value;

    procedure check_params as
    begin
--  check null parameters
        if p_codprgheal is null or p_typpgm is null or p_syncond is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if global_v_lang = '101' and p_desheale is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '102' and p_deshealt is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '103' and p_desheal3 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '104' and p_desheal4 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '105' and p_desheal5 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_qtymth is not null then 
          if nvl(p_qtymth,0) < 12  then
            param_msg_error := get_error_msg_php('BF0063',global_v_lang);
            return;
          end if;
        end if;
    end;

    procedure check_params2 as
    begin
        if p_codheal is null or p_qtysetup is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end;

    function gen_thealcde2 return json as
        obj_data    json;
        v_qtysetup  thealcde2.qtysetup%type;
    begin
        begin
            select qtysetup into v_qtysetup
              from thealcde2
             where codheal = p_codheal
               /*and codprgheal = p_codprgheal*/
               and rownum = 1;
        exception when no_data_found then
            v_qtysetup := '';
        end;
        obj_data := json();
        obj_data.put('qtysetup',v_qtysetup);
        return obj_data;
    end;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        cursor c1 is
            select codprgheal,decode(global_v_lang,'101', desheale,'102', deshealt,'103', desheal3,'104', desheal4,'105', desheal5) desheal,
                   amtheal
              from thealcde
          order by codprgheal;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('codprgheal',i.codprgheal);
            obj_data.put('desheal',i.desheal);
            obj_data.put('amtheal',i.amtheal);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

    end gen_index;

    procedure gen_detail(json_str_output out clob) as
        obj_data        json;
        obj_data2       json;
        v_desheal       thealcde.desheale%type;
        v_desheale      thealcde.desheale%type;
        v_deshealt      thealcde.deshealt%type;
        v_desheal3      thealcde.desheal3%type;
        v_desheal4      thealcde.desheal4%type;
        v_desheal5      thealcde.desheal5%type;
        v_amtheal       thealcde.amtheal%type;
        v_typpgm        thealcde.typpgm%type;
        v_syncond       thealcde.syncond%type;
        v_qtymth        thealcde.qtymth%type;
        v_statement     thealcde.statement%type;
        v_flag          varchar(50 char) := 'Edit';
    begin
        begin
            select desheale,deshealt,desheal3,desheal4,desheal5,amtheal,typpgm,syncond,statement,qtymth,
                   decode(global_v_lang,'101',desheale,'102',deshealt,'103',desheal3,'104',desheal4,'105',desheal5)
              into v_desheale,v_deshealt,v_desheal3,v_desheal4,v_desheal5,v_amtheal,v_typpgm,v_syncond,v_statement,v_qtymth,v_desheal
              from thealcde
             where codprgheal = p_codprgheal;
        exception when no_data_found then
            v_desheal  := '';
            v_desheale := '';
            v_deshealt := '';
            v_desheal3 := '';
            v_desheal4 := '';
            v_desheal5 := '';
            v_amtheal  := '';
            v_typpgm   := '1';
            v_syncond  := '';
            v_qtymth   := '';
            v_flag     := 'Add';
        end;

        obj_data := json();
        obj_data.put('flag',v_flag);
        obj_data.put('desheal',v_desheal);
        obj_data.put('desheale',v_desheale);
        obj_data.put('deshealt',v_deshealt);
        obj_data.put('desheal3',v_desheal3);
        obj_data.put('desheal4',v_desheal4);
        obj_data.put('desheal5',v_desheal5);
        obj_data.put('amtheal',v_amtheal);
        obj_data.put('typpgm',v_typpgm);
        --  add logical statement
        obj_data2 := json();
        obj_data2.put('code',v_syncond);
        obj_data2.put('description',get_logical_desc(v_statement));
--        obj_data2.put('description',get_logical_name('HRBFA1E',v_syncond,global_v_lang));
        obj_data2.put('statement',v_statement);

        obj_data.put('syncond',obj_data2);
        obj_data.put('qtymth',v_qtymth);
        obj_data.put('coderror',200);

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);

    end gen_detail;

    procedure gen_detail_table(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        v_row           number := 0;
        cursor c1 is
            select codheal,qtysetup
              from thealcde2
             where codprgheal = p_codprgheal
          order by codheal;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('codheal',i.codheal);
            obj_data.put('qtysetup',i.qtysetup);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

    end gen_detail_table;

    procedure update_thealcde as
    begin
        update thealcde
           set desheale = p_desheale,
               deshealt = p_deshealt,
               desheal3 = p_desheal3,
               desheal4 = p_desheal4,
               desheal5 = p_desheal5,
               amtheal = p_amtheal,
               typpgm = p_typpgm,
               syncond = p_syncond,
               statement = p_statement,
               qtymth = p_qtymth,
               coduser = global_v_coduser
         where codprgheal = p_codprgheal;
    end update_thealcde;

    procedure insert_thealcde as
    begin
        begin
            insert into thealcde(codprgheal,desheale,deshealt,desheal3,desheal4,desheal5,amtheal,typpgm,syncond,statement,qtymth,
                   codcreate,coduser)
            values (p_codprgheal,p_desheale,p_deshealt,p_desheal3,p_desheal4,p_desheal5,p_amtheal,p_typpgm,p_syncond,p_statement,
                   p_qtymth,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
            update_thealcde;
        end;
    end;
    
    procedure delete_thealcde as
        v_count1   number := 0;
        v_count2   number := 0;
        v_codcomp  temploy1.codcomp%type;
    begin
        begin
            select codcomp into v_codcomp
              from temploy1
             where codempid = global_v_codempid;
        exception when no_data_found then
            v_codcomp := '';
        end;

        select count(*) into v_count1
          from thealinf
         where codprgheal = p_codprgheal
           and rownum = 1;

        select count(*) into v_count2
          from thealinf1
         where codprgheal = p_codprgheal
           and rownum = 1;

        if v_count1 > 0 or v_count2 > 0 then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang);
            return;
        end if;

        delete from thealcde
         where codprgheal = p_codprgheal;

        delete from thealcde2
         where codprgheal = p_codprgheal;

    end delete_thealcde;

    procedure insert_thealcde2 as
        v_count number := 0;
    begin
        --  check dupicate codheal
        select count(*) into v_count
          from thealcde2
         where codprgheal = p_codprgheal
           and codheal = p_codheal;

        if v_count > 0 then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'THEALCDE2');
            return;
        end if;

        insert into thealcde2(codprgheal,codheal,qtysetup,codcreate,coduser)
             values (p_codprgheal,p_codheal,p_qtysetup,global_v_coduser,global_v_coduser);
    end insert_thealcde2;

    procedure update_thealcde2 as
    begin
        update thealcde2
           set qtysetup = p_qtysetup,
               coduser = global_v_coduser
         where codprgheal = p_codprgheal
           and codheal = p_codheal;
    end update_thealcde2;

    procedure delete_thealcde2 as
    begin
        delete from thealcde2
               where codprgheal = p_codprgheal
                 and codheal = p_codheal;
    end delete_thealcde2;

    procedure get_index(json_str_input in clob,json_str_output out clob) AS
    begin
        initial_value(json_str_input);
        gen_index(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        gen_detail_table(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail_table;

    procedure get_thealcde2(json_str_input in clob, json_str_output out clob) as
        obj_data    json;
        obj_rows    json;
    begin
        initial_value(json_str_input);
        obj_data := json();
        obj_rows := json();
        obj_data.put('qtysetup',hcm_util.get_string(gen_thealcde2,'qtysetup'));
        obj_rows.put(0,obj_data);
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_thealcde2;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj        json;
        data_obj        json;
        data_obj2       json;
        detail_obj      json;
        v_temp          number := 0;
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');
        detail_obj  := hcm_util.get_json(json_obj,'detail');
        
        p_desheale      := hcm_util.get_string(detail_obj,'desheale');
        p_deshealt      := hcm_util.get_string(detail_obj,'deshealt');
        p_desheal3      := hcm_util.get_string(detail_obj,'desheal3');
        p_desheal4      := hcm_util.get_string(detail_obj,'desheal4');
        p_desheal5      := hcm_util.get_string(detail_obj,'desheal5');
        p_amtheal       := to_number(hcm_util.get_string(detail_obj,'amtheal'));
        p_typpgm        := hcm_util.get_string(detail_obj,'typpgm');
        p_syncond       := hcm_util.get_string(hcm_util.get_json(detail_obj,'syncond'),'code');
        p_statement     := hcm_util.get_string(hcm_util.get_json(detail_obj,'syncond'),'statement');
        p_qtymth        := to_number(hcm_util.get_string(detail_obj,'qtymth'));
        check_params;
        insert_thealcde;
        
        for i in 0..param_json.count-1 loop
            data_obj        := hcm_util.get_json(param_json,to_char(i));
            p_codheal       := upper(hcm_util.get_string(data_obj,'codheal'));
            p_qtysetup      := hcm_util.get_string(data_obj,'qtysetup');
            p_flag          := hcm_util.get_string(data_obj,'flg');

            check_params2;
            if param_msg_error is not null then
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;

            if p_flag = 'add' then
                insert_thealcde2;
            elsif p_flag = 'edit' then
                update_thealcde2;
            elsif p_flag = 'delete' then
                delete_thealcde2;
            end if;

            if param_msg_error is not null then
                exit;
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
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

    procedure save_delete(json_str_input in clob, json_str_output out clob) as
        json_obj       json;
        data_obj       json;
        v_temp         number := 0;
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');
        for i in 0..param_json.count-1 loop
            data_obj        := hcm_util.get_json(param_json,to_char(i));
            p_codprgheal    := upper(hcm_util.get_string(data_obj,'codprgheal'));
            p_flag          := hcm_util.get_string(data_obj,'flg');

            if p_flag = 'delete' then
                delete_thealcde;
            end if;

            if param_msg_error is not null then
                exit;
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
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_delete;
END HRBF1AE;

/
