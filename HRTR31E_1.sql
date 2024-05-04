--------------------------------------------------------
--  DDL for Package Body HRTR31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR31E" AS

    procedure initial_value(json_str_input in clob) is
        json_obj          json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codcomp  := upper(hcm_util.get_string(json_obj,'p_codcomp'));
        p_codpos   := hcm_util.get_string(json_obj,'p_codpos');
        p_qtyminhr_str := hcm_util.get_string(json_obj,'p_qtyminhr');

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
--      validate codcomp
        if p_codcomp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

--      check codcomp in tcenter
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;

        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_temp      varchar2(100 char);
        v_hour varchar2(10 char);
        v_min  varchar2(2 char);
        cursor c1 is
          select codcomp,codpos,qtyminhr,'ttrnnhr' src
          from ttrnnhr
          where codcomp like p_codcomp || '%'
          order by codcomp,codpos;

--      Override when cursor c1 no data
        cursor c2 is
          select codcomp,codpos,'tjobpos' src
          from tjobpos
          where codcomp like p_codcomp || '%'
          order by codcomp,codpos;
        begin
            obj_rows := json();
            for i in c1 loop
                if secur_main.secur7(i.codcomp,global_v_coduser) then
                    v_row := v_row+1;
                    obj_data := json();
                    obj_data.put('codcomp',i.codcomp);
                    obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
                    obj_data.put('codpos',i.codpos);
                    obj_data.put('codpos_name',get_tpostn_name(i.codpos,global_v_lang));
                    obj_data.put('codpos_desc',i.codpos||' - '||get_tpostn_name(i.codpos,global_v_lang));
                    v_hour := to_char(trunc(i.qtyminhr));
                    v_min := lpad(mod(i.qtyminhr , 60), 2, '0') ;
                    v_min := lpad(to_char((i.qtyminhr-trunc(i.qtyminhr))*60), 2, '0') ;
--<< user20 Date: 16/09/2021  #6870                    obj_data.put('qtyminhr',v_hour || ':' || v_min);
--                    obj_data.put('qtyminhr',i.qtyminhr);
                    obj_data.put('qtyminhr', hcm_util.convert_minute_to_hour(i.qtyminhr)); -- Adisak redmine#8951 26/04/2023 18:47
--<< user20 Date: 16/09/2021  #6870
                    obj_data.put('src',i.src);
                    obj_rows.put(to_char(v_row-1),obj_data);
                end if;
            end loop;

            if obj_rows.count() = 0 then
                obj_rows := json();
                for i in c2 loop
                    if secur_main.secur7(i.codcomp,global_v_coduser) then
                        v_row := v_row+1;
                        obj_data := json();
                        obj_data.put('codcomp',i.codcomp);
                        obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
                        obj_data.put('codpos',i.codpos);
                        obj_data.put('codpos_name',get_tpostn_name(i.codpos,global_v_lang));
                        obj_data.put('codpos_desc',i.codpos||' - '||get_tpostn_name(i.codpos,global_v_lang));
                        obj_data.put('qtyminhr','0:00');
                        obj_data.put('src',i.src);
                        obj_rows.put(to_char(v_row-1),obj_data);
                    end if;
                end loop;
            end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

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
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure check_param as
        v_temp  varchar2(1 char);
        v_temp1 varchar2(1 char);
        v_temp2 varchar2(1 char);
    begin
--      validate codpos and qtyminhr
        if p_codpos is null or p_qtyminhr_str is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

--      check codcomp in tcenter
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;

--      check codpos in tpostn
        begin
            select 'X' into v_temp1
            from tpostn
            where codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;

--      check codcomp in tjobpos
        begin
            select 'Y' into v_temp2
                from tjobpos
                where codcomp = p_codcomp
                and codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tjobpos');
            return;
        end;

--      check training hour
        if p_qtyminhr > 2000 then
            param_msg_error := get_error_msg_php('TR0037',global_v_lang);
            return;
        end if;
    end check_param;

    procedure insert_index as
    begin
        insert into ttrnnhr (codcomp, codpos, qtyminhr, codcreate, coduser)
        values (p_codcomp, p_codpos, p_qtyminhr, global_v_coduser, global_v_coduser);
    end insert_index;

    procedure update_index as
    begin
     update ttrnnhr
     set
        qtyminhr = p_qtyminhr,
        coduser  = global_v_coduser
        where codcomp = p_codcomp
        and codpos = p_codpos;
    end update_index;

    procedure delete_index as
    begin
        delete ttrnnhr
        where codcomp = p_codcomp
        and codpos = p_codpos;
    end delete_index;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
         json_obj       json;
         data_obj       json;
         v_item_flgedit varchar2(10 char);
         p_src          varchar2(100 char);
         v_count        number;
    begin
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');
        for i in 0..param_json.count-1 loop
            p_qtyminhr := null;
            data_obj := hcm_util.get_json(param_json,to_char(i));
            initial_value(json_str_input);
            p_codcomp  := upper(hcm_util.get_string(data_obj,'p_codcomp'));
            p_codpos   := hcm_util.get_string(data_obj,'p_codpos');
            p_qtyminhr_str := hcm_util.get_string(data_obj,'p_qtyminhr');
--<< user20 Date: 16/09/2021  #6870            p_qtyminhr := hcm_util.convert_hour_to_minute(p_qtyminhr_str)/60;
--            p_qtyminhr := to_number(replace(p_qtyminhr_str, ':' , '.'));
            p_qtyminhr := hcm_util.convert_time_to_minute(p_qtyminhr_str); -- Adisak redmine#8951 26/04/2023 18:47
--<< user20 Date: 16/09/2021  #6870
            p_src      := hcm_util.get_string(data_obj,'p_src');


            if param_msg_error is null then
                    v_item_flgedit := hcm_util.get_string(data_obj,'flag');
                     if p_src = 'tjobpos' and v_item_flgedit = 'Edit' then
                            v_item_flgedit := 'Add';
                     end if;
                    if v_item_flgedit = 'Add' then
                        check_param;
                        if param_msg_error is null then
	                        select count(*) into v_count
	                        from ttrnnhr
	                        where codcomp = p_codcomp
	                          and codpos = p_codpos;
	                        if v_count = 0 then
	                            insert_index;
	                        else
	                            continue;
	                        end if;
                        end if;
                    elsif v_item_flgedit = 'Edit' then
                        check_param;
                        if param_msg_error is null then
                        	update_index;
                        end if;
                    elsif v_item_flgedit = 'Delete' then
                        delete_index;
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
END HRTR31E;

/
