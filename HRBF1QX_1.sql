--------------------------------------------------------
--  DDL for Package Body HRBF1QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1QX" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json;
  begin
    json_obj          := json(json_str_input);
    global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codcomp         := upper(hcm_util.get_string(json_obj,'p_codcomp'));
    p_mthst           := to_number(hcm_util.get_string(json_obj,'p_mthst'));
    p_dteyear1        := to_number(hcm_util.get_string(json_obj,'p_dteyear1'));
    p_mthen           := to_number(hcm_util.get_string(json_obj,'p_mthen'));
    p_dteyear2        := to_number(hcm_util.get_string(json_obj,'p_dteyear2'));
    p_flgdocmt        := hcm_util.get_string(json_obj,'p_flgdocmt');

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--  check null parameters
    if p_codcomp is null or p_mthst is null or p_dteyear1 is null or p_mthen is null or p_dteyear2 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check date
    if to_date(get_period_date(p_mthst,p_dteyear1,'S'),'dd/mm/yyyy') > to_date(get_period_date(p_mthen,p_dteyear2,'S'),'dd/mm/yyyy') then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json;
    obj_data        json;
    v_row           number := 0;
    v_chk_secur     boolean := false;
    v_count         number := 0;
    v_count_secur   number := 0;

    cursor c1 is
        --<<User37 #4175 BF - PeoplePlus 26/03/2021
        select codempid,codcomp,codcln,dtecrest,dtecreen,coddc,sum(amtexp) amtexp,sum(amtalw) amtalw,dtebill
        from tclnsinf
        where codcomp like p_codcomp || '%'
          and dtecrest between to_date(get_period_date(p_mthst,p_dteyear1,'S'),'dd/mm/yyyy') and to_date(get_period_date(p_mthen,p_dteyear2,''),'dd/mm/yyyy')
          and typamt = '5'
          and flgdocmt = nvl(p_flgdocmt,flgdocmt)
        group by codempid,codcomp,codcln,dtecrest,dtecreen,coddc,dtebill
        order by codempid asc,dtecrest desc;
        /*select numvcher,codempid,codcomp,codcln,dtecrest,dtecreen,coddc,amtexp,amtalw,dtebill
        from tclnsinf
        where codcomp like p_codcomp || '%'
          and dtecrest between to_date(get_period_date(p_mthst,p_dteyear1,'S'),'dd/mm/yyyy') and to_date(get_period_date(p_mthen,p_dteyear2,''),'dd/mm/yyyy')
          and typamt = '5'
          and flgdocmt = nvl(p_flgdocmt,flgdocmt)
        order by codempid asc,dtecrest desc;*/
        -->>User37 #4175 BF - PeoplePlus 26/03/2021
  begin
    obj_rows := json();
    for i in c1 loop
        v_count := v_count + 1;
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_chk_secur then
            v_count_secur := v_count_secur + 1;
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('no',v_row);
            --User37 #4175 BF - PeoplePlus 26/03/2021 obj_data.put('numvcher',i.numvcher);
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codcln',i.codcln);
            obj_data.put('codcln_name',get_tclninf_name(i.codcln,global_v_lang));
            obj_data.put('dtecrest',to_char(i.dtecrest,'dd/mm/yyyy'));
            obj_data.put('dtecreen',to_char(i.dtecreen,'dd/mm/yyyy'));
            obj_data.put('coddc',i.coddc);
            obj_data.put('coddc_name',get_tdcinf_name(i.coddc,global_v_lang));
            obj_data.put('amtexp',i.amtexp);
            obj_data.put('amtalw',i.amtalw);
            obj_data.put('dtebill',to_char(i.dtebill,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        else
            continue;
        end if;
    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tclnsinf');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
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

  END get_index;

END HRBF1QX;


/
