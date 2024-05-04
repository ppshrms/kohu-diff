--------------------------------------------------------
--  DDL for Package Body HRTR1FE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR1FE" is

    procedure initial_value(json_str in clob) is
        json_obj   json := json(json_str);
    begin
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        p_codexpn           := hcm_util.get_string(json_obj, 'codexpn');

        json_params         := hcm_util.get_json(json_obj, 'json_input_str');

    end initial_value;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        obj_data    json;
        obj_row     json;
        v_row       number := 0;
        cursor c1 is
            select *
            from tcodexpn
            order by codexpn;
    begin
        initial_value(json_str_input);
        obj_row    := json();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('coderror','200');
            obj_data.put('codexpn',i.codexpn);
            obj_data.put('descode',i.descode);
            obj_data.put('descodt',i.descodt);
            obj_data.put('descod3',i.descod3);
            obj_data.put('descod4',i.descod4);
            obj_data.put('descod5',i.descod5);
            if global_v_lang = '101' then
                obj_data.put('descod',i.descode);
            elsif global_v_lang = '102' then
                obj_data.put('descod',i.descodt);
            elsif global_v_lang = '103' then
                obj_data.put('descod',i.descod3);
            elsif global_v_lang = '104' then
                obj_data.put('descod',i.descod4);
            elsif global_v_lang = '105' then
                obj_data.put('descod',i.descod5);
            end if;
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        param_json_row  json;
        v_descode       varchar2(500 char);
        v_descodt       varchar2(500 char);
        v_descod3       varchar2(500 char);
        v_descod4       varchar2(500 char);
        v_descod5       varchar2(500 char);
        v_flg           varchar2(6 char);
        v_count         int;
        v_count_tcosttr  int;
        v_count_thiscost int;
    begin
        initial_value(json_str_input);

        for i in 0..json_params.count-1 loop
            param_json_row  := hcm_util.get_json(json_params, to_char(i));
            p_codexpn       := hcm_util.get_string(param_json_row,'codexpn');
            v_flg           := hcm_util.get_string(param_json_row,'flg');

            if p_codexpn is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            elsif v_flg = 'add' then
                select count(codexpn) into v_count
                from tcodexpn
                where codexpn = p_codexpn;
                if v_count > 0 then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                end if;
            end if;
        end loop;

        if param_msg_error is null then
            for i in 0..json_params.count-1 loop
            param_json_row   := hcm_util.get_json(json_params, to_char(i));
            p_codexpn        := hcm_util.get_string(param_json_row,'codexpn');
            v_descode        := hcm_util.get_string(param_json_row,'descode');
            v_descodt        := hcm_util.get_string(param_json_row,'descodt');
            v_descod3        := hcm_util.get_string(param_json_row,'descod3');
            v_descod4        := hcm_util.get_string(param_json_row,'descod4');
            v_descod5        := hcm_util.get_string(param_json_row,'descod5');
            v_flg            := hcm_util.get_string(param_json_row,'flg');
            v_count          := 0;
            v_count_tcosttr  := 0;
            v_count_thiscost := 0;


            if p_codexpn is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            elsif v_flg = 'add' then
                select count(codexpn) into v_count
                from tcodexpn
                where codexpn = p_codexpn;
                if v_count > 0 then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                end if;
            end if;

            if param_msg_error is null then
                if v_flg = 'add' then
                    begin
                        insert into tcodexpn(codexpn,descode,descodt,descod3,descod4,descod5,codcreate,dtecreate)
                        values (p_codexpn,v_descode,v_descodt,v_descod3,v_descod4,v_descod5,global_v_coduser,trunc(sysdate));
                    exception when dup_val_on_index then
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang, 'TCODEXPN');
                    end;
                elsif v_flg = 'edit' then
                    begin
                        update  tcodexpn
                        set     descode   = v_descode,
                                descodt   = v_descodt,
                                descod3   = v_descod3,
                                descod4   = v_descod4,
                                descod5   = v_descod5,
                                dteupd    = trunc(sysdate),
                                coduser   = global_v_coduser
                        where   codexpn = p_codexpn;
                    exception when others then
                        rollback;
                    end;
                elsif v_flg = 'delete' then
                    begin
                        select count(*) into v_count_tcosttr
                        from tcosttr
                        where codexpn = p_codexpn;
                    exception when others then
                        null;
                    end;
                    begin
                        select count(*) into v_count_thiscost
                        from thiscost
                        where codexpn = p_codexpn;
                    exception when others then
                        null;
                    end;
                    if v_count_tcosttr > 0 or v_count_thiscost > 0 then
                        param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                    else
                        begin
                            delete from tcodexpn
                            where codexpn = p_codexpn;
                        exception when others then
                            null;
                        end;
                    end if;
                end if;
            end if;
        end loop;
        end if;

        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2715',global_v_lang);
            commit;
        end if;
        json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    end save_index;

    procedure gen_detail(json_str_output out clob) as
        obj_row       json;
        v_descode     varchar2(500 char);
        v_descodt     varchar2(500 char);
        v_descod3     varchar2(500 char);
        v_descod4     varchar2(500 char);
        v_descod5     varchar2(500 char);

      begin
        begin
            select descode, descodt, descod3, descod4, descod5
            into v_descode, v_descodt, v_descod3, v_descod4, v_descod5
            from tcodexpn
            where codexpn = p_codexpn;
        exception when no_data_found then
            v_descode   := null;
            v_descodt   := null;
            v_descod3   := null;
            v_descod4   := null;
            v_descod5   := null;
        end;

        obj_row := json();
        obj_row.put('coderror', '200');
        obj_row.put('codexpn', p_codexpn);
        if global_v_lang = '101' then
            obj_row.put('descod', v_descode);
        elsif global_v_lang = '102' then
            obj_row.put('descod', v_descodt);
        elsif global_v_lang = '103' then
            obj_row.put('descod', v_descod3);
        elsif global_v_lang = '104' then
            obj_row.put('descod', v_descod4);
        elsif global_v_lang = '105' then
            obj_row.put('descod', v_descod5);
        end if;
        obj_row.put('descode', v_descode);
        obj_row.put('descodt', v_descodt);
        obj_row.put('descod3', v_descod3);
        obj_row.put('descod4', v_descod4);
        obj_row.put('descod5', v_descod5);

        if isInsertReport then
            insert_ttemprpt(obj_row);
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_detail;

    procedure initial_report(json_str in clob) is
        json_obj        json;
    begin
        json_obj            := json(json_str);
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        json_codexpn        := hcm_util.get_json(json_obj, 'p_codexpn');
    end initial_report;

    procedure gen_report(json_str_input in clob,json_str_output out clob) is
        json_output       clob;
    begin
        initial_report(json_str_input);
        isInsertReport := true;
        if param_msg_error is null then
          clear_ttemprpt;
          for i in 0..json_codexpn.count-1 loop
            p_codexpn := hcm_util.get_string(json_codexpn, to_char(i));
            gen_detail(json_output);
          end loop;
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
             and codapp   = p_codapp;
        exception when others then
          null;
        end;
    end clear_ttemprpt;

    procedure insert_ttemprpt(obj_data in json) is
        v_numseq            number := 0;
    begin
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
                 codempid, codapp, numseq,
                 item1, item2
               )
          values
               (
                 global_v_codempid, p_codapp, v_numseq,
                 nvl(hcm_util.get_string(obj_data, 'codexpn'), ''), nvl(hcm_util.get_string(obj_data, 'descod'), '')
               );
        exception when others then
          null;
        end;
    end insert_ttemprpt;

end HRTR1FE;


/
