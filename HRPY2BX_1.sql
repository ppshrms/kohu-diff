--------------------------------------------------------
--  DDL for Package Body HRPY2BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2BX" as

    procedure initial_value(json_str_input in clob) as
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    end initial_value;

    function has_codpay (p_codpay varchar) return boolean is
        v_count number := 0;
    begin
        select count(*) into v_count from tinexinf where codpay = p_codpay;
        if v_count < 1 then
            return false;
        end if;
        return true;
    end;

    procedure validate_get_index(p_codpay varchar2,p_st_date varchar2,p_end_date varchar2) as
    begin
        if p_codpay is not null and has_codpay(p_codpay) = false then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
            return;
        end if;

        if p_st_date is null or p_end_date is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if to_date(p_st_date,'dd/mm/yyyy') > to_date(p_end_date,'dd/mm/yyyy') then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;
    end;

    function get_fldname (p_fldedit varchar2) return varchar2 is
        v_fldname       varchar2(400 char) := '';
        v_codapp        varchar2(100 char) := 'HRPY2BX';
    begin
        if p_fldedit = 'CODPAY' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'110');
        elsif p_fldedit = 'DESCPAYE' or p_fldedit = 'DESCPAYT' or p_fldedit = 'DESCPAY3' or p_fldedit = 'DESCPAY4' or p_fldedit = 'DESCPAY5' then
            return get_label_name(v_codapp,global_v_lang,'120');
        elsif p_fldedit = 'TYPPAY' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'130');
        elsif p_fldedit = 'FLGPVDF' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'140');
        elsif p_fldedit = 'FLGWORK' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'150');
        elsif p_fldedit = 'FLGTAX' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'160');
        elsif p_fldedit = 'FLGFML' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'170');
        elsif p_fldedit = 'FLGSOC' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'180');
        elsif p_fldedit = 'FLGCAL' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'190');
        elsif p_fldedit = 'FLGFORM' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'200');
        elsif p_fldedit = 'TYPINC' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'210');
        elsif p_fldedit = 'TYPPAYR' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'220');
        elsif p_fldedit = 'TYPPAYT' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'230');
        elsif p_fldedit = 'GRPPAY' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'240');
        elsif p_fldedit = 'AMTMIN' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'250');
        elsif p_fldedit = 'AMTMAX' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'260');
        elsif p_fldedit = 'FORMULA' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'270');
        elsif p_fldedit = 'DTEEFFEC' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'280');
        elsif p_fldedit = 'CODTAX' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'290');
        elsif p_fldedit = 'TYPINCPND' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'300');
        elsif p_fldedit = 'TYPINCPND50' then
            v_fldname := get_label_name(v_codapp,global_v_lang,'310');
        end if;
        return v_fldname;
    end;

    function get_descname (p_fldedit varchar2,p_desc varchar2) return varchar2 is
        v_descript      varchar2(400 char) := '';
        v_date          date;
        additional_year number;
    begin
        if p_fldedit = 'CODPAY' then
            if get_tinexinf_name(p_desc,global_v_lang) like '****%' then
              v_descript := p_desc;
            else
              v_descript := p_desc||' - '||get_tinexinf_name(p_desc,global_v_lang);
            end if;
        elsif p_fldedit = 'DESCPAYE' or p_fldedit = 'DESCPAYT' or p_fldedit = 'DESCPAY3' or p_fldedit = 'DESCPAY4' or p_fldedit = 'DESCPAY5' then
            v_descript := p_desc;
        elsif p_fldedit = 'TYPPAY' then
            v_descript := p_desc||' - '||get_tlistval_name('TYPEINC',p_desc,global_v_lang);
        elsif p_fldedit = 'FLGPVDF' then
            v_descript := p_desc;
        elsif p_fldedit = 'FLGWORK' then
            v_descript := p_desc;
        elsif p_fldedit = 'FLGSOC' then
            v_descript := p_desc;
        elsif p_fldedit = 'FLGCAL' then
            v_descript := p_desc;
        elsif p_fldedit = 'TYPINC' then
            v_descript := p_desc||' - '||get_tcodec_name('TCODREVN',p_desc,global_v_lang);
        elsif p_fldedit = 'CODTAX' then
            if get_tinexinf_name(p_desc,global_v_lang) like '****%' then
              v_descript := p_desc;
            else
              v_descript := p_desc||' - '||get_tinexinf_name(p_desc,global_v_lang);
            end if;
--            v_descript := p_desc||' - '||get_tinexinf_name(p_desc,global_v_lang);
        elsif p_fldedit = 'DTEEFFEC' then
            additional_year := hcm_appsettings.get_additional_year;
            v_date          := to_date(p_desc,'dd/mm/yyyy');
            v_descript      := to_char(v_date, 'DD/MM/') || (to_number(to_char(v_date, 'YYYY')) + additional_year);
        else
            v_descript := p_desc;
        end if;
        return v_descript;
    end;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
        obj_row         json_object_t;
        obj_data        json_object_t;
        p_codpay        varchar2(4 char);
        p_st_date       varchar2(100 char);
        p_end_date      varchar2(100 char);
        v_row           number := 0;
        v_fldname       varchar2(100 char);

        cursor c1 is
            select dteupd,codpay,numseq,fldedit,descold,descnew,codcreate,rowid
              from tlogcodpay
             where codpay = nvl(p_codpay,codpay) 
               /*and dteupd >= to_date(p_st_date,'dd/mm/yyyy') 
               and dteupd <= to_date(p_end_date,'dd/mm/yyyy')*/
               and trunc(dteupd) between to_date(p_st_date,'dd/mm/yyyy') and to_date(p_end_date,'dd/mm/yyyy')
            order by dteupd desc;
    begin
        initial_value(json_str_input);
        json_obj     := json_object_t(json_str_input);
        p_codpay     := hcm_util.get_string_t(json_obj,'codpay');
        p_st_date    := hcm_util.get_string_t(json_obj,'stdate');
        p_end_date   := hcm_util.get_string_t(json_obj,'endate');
        validate_get_index(p_codpay,p_st_date,p_end_date);
        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        obj_row         := json_object_t();
        for i in c1 loop
              v_row := v_row + 1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('dateupd',to_char(i.dteupd,'dd/mm/yyyy'));
              obj_data.put('timeupd',to_char(i.dteupd,'hh24:mi:ss'));
              obj_data.put('coduser',i.codcreate);
              if get_tinexinf_name(i.codpay,global_v_lang) like '****%' then
                obj_data.put('codpay',i.codpay);
              else
                obj_data.put('codpay',i.codpay || ' - ' || get_tinexinf_name(i.codpay,global_v_lang));
              end if;
              obj_data.put('fldedit',get_fldname(i.fldedit));
              obj_data.put('descold',get_descname(i.fldedit,i.descold));
              obj_data.put('descnew',get_descname(i.fldedit,i.descnew));
              obj_row.put(to_char(v_row-1),obj_data);
        end loop;

        -- กรณีไม่พบข้อมูล
        if obj_row.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlogcodpay');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;
end HRPY2BX;

/
