--------------------------------------------------------
--  DDL for Package Body HRTR3CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR3CX" AS

  procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    p_year       := hcm_util.get_string(json_obj,'p_year');
    p_codcomp    := upper(hcm_util.get_string(json_obj,'p_codcomp'));
    p_codpos     := hcm_util.get_string(json_obj,'p_codpos');
    p_codempid   := upper(hcm_util.get_string(json_obj,'p_codempid'));

  end initial_value;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_row_secur    number := 0;
    cursor c1 is
        select a.codempid,a.dtetrst,a.codcours,a.numclseq,a.dtetren,a.flgatend,c.codhotel
        from tpotentp a,temploy1 b,tyrtrsch c
        where a.codempid = b.codempid
        and a.dteyear = c.dteyear
        and a.codcompy = c.codcompy
        and a.codcours = c.codcours
        and a.numclseq = c.numclseq
        and a.dteyear = p_year
        and a.codcomp like p_codcomp||'%'
        and b.codpos = nvl(p_codpos,a.codpos)
        and a.codempid = nvl(p_codempid,a.codempid)
        and a.staappr = 'Y'
        and a.flgatend <> 'C'
        order by a.codempid, a.codcours, a.numclseq;

    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
                obj_data := json();
                v_row_secur := v_row_secur +1;
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('codcours',i.codcours);
                obj_data.put('desc_codcurs',get_tcourse_name(i.codcours,global_v_lang));
                obj_data.put('numclseq',i.numclseq);
                obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
                obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
                if(i.flgatend = 'Y') then
                    obj_data.put('flgatend',get_label_name('HRTR3CX',global_v_lang,'150'));
                    obj_data.put('desc_status','<div class="badge-custom _bg-green"><i class="fa fa-check-circle"></i>'||get_label_name('HRTR3CX',global_v_lang,'150')||'</div>');
                end if;
                if(i.flgatend = 'N') then
                    obj_data.put('flgatend',get_label_name('HRTR3CX',global_v_lang,'160'));
                    obj_data.put('desc_status','<div class="badge-custom _bg-red"><i class="fa fa-times-circle"></i>'||get_label_name('HRTR3CX',global_v_lang,'160')||'</div>');
                end if;
                obj_data.put('desc_hotel',get_thotelif_name(i.codhotel,global_v_lang));
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if  v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpotentp');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        if ( v_row > 0 ) and ( v_row_secur = 0 ) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index;

    procedure check_index as
        v_temp varchar2(1 char);
        v_temp2 varchar2(1 char);
        v_temp3 varchar2(1 char);
    begin
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
        begin
            select 'X' into v_temp2
            from tpostn
            where codpos like p_codpos||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;
        begin
            select 'X' into v_temp3
            from temploy1
            where codempid like p_codempid||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
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
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;
END HRTR3CX;

/
