--------------------------------------------------------
--  DDL for Package Body HRBF51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF51E" AS
    procedure initial_value(json_str_input in clob) as
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codlon          := hcm_util.get_string(json_obj,'p_codlon');

    end initial_value;

    procedure check_params as
    begin
--  check language
        if global_v_lang = 101 and p_deslone is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = 102 and p_deslont is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = 103 and p_deslon3 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = 104 and p_deslon4 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = 105 and p_deslon5 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_amtmxlon is null and p_ratelon is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_amtmxlon is not null then
            p_ratelon := null;
        end if;

        if p_nummxlon > 999 then
            param_msg_error := get_error_msg_php('BF0037',global_v_lang);
            return;
        end if;

    end check_params;

    function codlon_was_used(v_codlon varchar2) return boolean is
        v_check number :=0;
    begin
        select sum(counter) into v_check
          from (select count(*) as counter
                  from tintrteh
                 where codlon = v_codlon
                   and rownum = 1
                union
                select count(*) as counter
                  from tloaninf
                 where codlon = v_codlon
                   and rownum = 1);
        if v_check > 0 then
            return true;
        else
            return false;
        end if;
    end;

    procedure gen_index(json_str_output out clob) as
        obj_data        json;
        obj_rows        json;
        v_row           number := 0;
        cursor c1 is
            select codlon,decode(global_v_lang, 101,deslone,
                                                102,deslont,
                                                103,deslon3,
                                                104,deslon4,
                                                105,deslon5) deslon
              from ttyploan
          order by codlon;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data  := json();
            obj_data.put('codlon',i.codlon);
            obj_data.put('deslon',i.deslon);
            obj_data.put('flgused',codlon_was_used(i.codlon));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

    end gen_index;

    procedure gen_detail(json_str_output out clob) as
        obj_data        json;
        obj_data2       json;
        v_ttyploan      ttyploan%rowtype;
        v_flag          varchar(50 char) := 'Edit';
    begin
        begin
            select * into v_ttyploan
              from ttyploan
             where codlon = p_codlon;
        exception when no_data_found then
            v_ttyploan := null;
            v_flag     := 'Add';
        end;

        obj_data := json();
        obj_data.put('flag',v_flag);
        obj_data.put('deslone',v_ttyploan.deslone);
        obj_data.put('deslont',v_ttyploan.deslont);
        obj_data.put('deslon3',v_ttyploan.deslon3);
        obj_data.put('deslon4',v_ttyploan.deslon4);
        obj_data.put('deslon5',v_ttyploan.deslon5);
        obj_data.put('amtmxlon',v_ttyploan.amtmxlon);
        obj_data.put('ratelon',v_ttyploan.ratelon);
        obj_data.put('nummxlon',v_ttyploan.nummxlon);
    --  add logical statement
        obj_data2 := json();
        obj_data2.put('code',v_ttyploan.condlon);
        obj_data2.put('description',get_logical_name('HRBF51E',v_ttyploan.condlon,global_v_lang));
        obj_data2.put('statement',v_ttyploan.statementl);

        obj_data.put('condlon',obj_data2);
        obj_data.put('amtasgar',v_ttyploan.amtasgar);
        obj_data.put('qtygar',v_ttyploan.qtygar);
        obj_data.put('amtguarntr',v_ttyploan.amtguarntr);
    --  add logical statement
        obj_data2 := json();
        obj_data2.put('code',v_ttyploan.condgar);
        obj_data2.put('description',get_logical_name('HRBF51E',v_ttyploan.condgar,global_v_lang));
        obj_data2.put('statement',v_ttyploan.statementg);

        obj_data.put('condgar',obj_data2);
        obj_data.put('dteupd',to_char(v_ttyploan.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',get_codempid(v_ttyploan.coduser));
        obj_data.put('coderror',200);

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);

    end gen_detail;

    procedure insert_ttyploan as
    begin
        insert into ttyploan(codlon,deslone,deslont,deslon3,deslon4,deslon5,amtmxlon,ratelon,nummxlon,condlon,statementl,
                    amtasgar,qtygar,condgar,statementg,amtguarntr,codcreate,coduser)
             values (p_codlon,p_deslone,p_deslont,p_deslon3,p_deslon4,p_deslon5,p_amtmxlon,p_ratelon,p_nummxlon,p_condlon,
                    p_statementl,p_amtasgar,p_qtygar,p_condgar,p_statementg,p_amtguarntr,global_v_coduser,global_v_coduser);
    end insert_ttyploan;

    procedure update_ttyploan as
    begin
        update ttyploan
           set deslone = p_deslone,
               deslont = p_deslont,
               deslon3 = p_deslon3,
               deslon4 = p_deslon4,
               deslon5 = p_deslon5,
               amtmxlon = p_amtmxlon,
               ratelon = p_ratelon,
               nummxlon = p_nummxlon,
               condlon = p_condlon,
               statementl = p_statementl,
               amtasgar = p_amtasgar,
               qtygar = p_qtygar,
               condgar = p_condgar,
               statementg = p_statementg,
               amtguarntr = p_amtguarntr,
               coduser = global_v_coduser
         where codlon = p_codlon;

    end update_ttyploan;

    procedure delete_ttyploan as
    begin
        delete from ttyploan
        where codlon = p_codlon;
    end delete_ttyploan;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
    begin
        initial_value(json_str_input);
        gen_index(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure get_detail(json_str_input in clob,json_str_output out clob) AS
    begin
        initial_value(json_str_input);
        gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj       json;
        data_obj       json;
        v_check        varchar(1 char);
    begin
        initial_value(json_str_input);
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');
        for i in 0..param_json.count-1 loop
            data_obj := hcm_util.get_json(param_json,to_char(i));
            p_codlon        := hcm_util.get_string(data_obj,'p_codlon');
            p_deslone       := hcm_util.get_string(data_obj,'p_deslone');
            p_deslont       := hcm_util.get_string(data_obj,'p_deslont');
            p_deslon3       := hcm_util.get_string(data_obj,'p_deslon3');
            p_deslon4       := hcm_util.get_string(data_obj,'p_deslon4');
            p_deslon5       := hcm_util.get_string(data_obj,'p_deslon5');
            p_amtmxlon      := to_number(hcm_util.get_string(data_obj,'p_amtmxlon'));
            p_ratelon       := to_number(hcm_util.get_string(data_obj,'p_ratelon'));
            p_nummxlon      := to_number(hcm_util.get_string(data_obj,'p_nummxlon'));
            p_condlon       := hcm_util.get_string(data_obj,'p_condlon');
            p_statementl    := hcm_util.get_string(data_obj,'p_statementl');
            p_amtasgar      := to_number(hcm_util.get_string(data_obj,'p_amtasgar'));
            p_amtguarntr    := to_number(hcm_util.get_string(data_obj,'p_amtguarntr'));
            p_qtygar        := to_number(hcm_util.get_string(data_obj,'p_qtygar'));
            p_condgar       := hcm_util.get_string(data_obj,'p_condgar');
            p_statementg    := hcm_util.get_string(data_obj,'p_statementg');
            p_flag          := hcm_util.get_string(data_obj,'p_flag');

            if p_flag != 'Delete' then
                check_params;
                if param_msg_error is not null then
                    exit;
                end if;
            end if;

            if p_flag = 'Add' then
                insert_ttyploan;
            elsif p_flag = 'Edit' then
                update_ttyploan;
            elsif p_flag = 'Delete' then
                select sum(counter) into v_check
                  from (select count(*) as counter
                          from tintrteh
                         where codlon = p_codlon
                           and rownum = 1
                        union
                        select count(*) as counter
                          from tloaninf
                         where codlon = p_codlon
                           and rownum = 1);

                if v_check > 0 then
                    param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                    exit;
                else
                    delete_ttyploan;
                end if;
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

END HRBF51E;


/
