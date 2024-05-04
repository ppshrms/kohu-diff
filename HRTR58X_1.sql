--------------------------------------------------------
--  DDL for Package Body HRTR58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR58X" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codcompy        := upper(hcm_util.get_string(json_obj,'p_codcompy'));
        p_dteyear         := hcm_util.get_string(json_obj,'p_dteyear');
        p_monthst         := hcm_util.get_string(json_obj,'p_monthst');
        p_monthend        := hcm_util.get_string(json_obj,'p_monthend');

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
--      validate codcompy, year, month
        if p_codcompy is null or p_dteyear is null or p_monthst is null or p_monthend is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

--      check codcompy in tcompny
        begin
            select 'X' into v_temp
            from tcompny
            where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
            return;
        end;

--      check secure7
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        cursor c1 is
            select codcate,codcours,numclseq,dtetrst,dtetren,codresp,desreq,dtecancel,codempcanl
            from tyrtrsch
            where codcompy = p_codcompy
             and dteyear = p_dteyear
             and to_number(to_char(dtetrst,'mm')) between p_monthst and p_monthend
             and flgconf = 'X'
            order by codcate,codcours,numclseq;
    begin
        obj_rows := json();
        obj_data := json();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('tcodec_name',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
            obj_data.put('codcours',i.codcours);
            obj_data.put('codcours_name',get_tcourse_name(i.codcours,global_v_lang));
            obj_data.put('numclseq',i.numclseq);
            obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
            obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
            obj_data.put('codresp',get_temploy_name(i.codresp,global_v_lang));
            obj_data.put('desreq',i.desreq);
            obj_data.put('dtecancel',to_char(i.dtecancel,'dd/mm/yyyy'));
            obj_data.put('codempcanl',get_temploy_name(i.codempcanl,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        if obj_rows.count() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tyrtrsch');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
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
END HRTR58X;


/
