--------------------------------------------------------
--  DDL for Package Body HRBF28X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF28X" AS

 procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp         := upper(hcm_util.get_string(json_obj,'p_codcomp'));
        p_dteacdst        := to_date(hcm_util.get_string(json_obj,'p_dteacdst'),'dd/mm/yyyy');
        p_dteacden        := to_date(hcm_util.get_string(json_obj,'p_dteacden'),'dd/mm/yyyy');

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--  check null parameters
    if  p_dteacdst is null or p_dteacden is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp in tcenter
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
        and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

--  check sercure7
    if p_codcomp is not null then
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;

--  check date
    if p_dteacdst > p_dteacden then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows       json;
    obj_data       json;
    v_row          number := 0;
    v_count        number := 0;
    v_count_secur  number := 0;
    cursor c1 is
        select codempid,codcomp,dteacd,timeacd,placeacd location,resultacd desresult,dtestr,dteend,
               dtesmit, numwc
        from thwccase
        where codcomp like nvl(p_codcomp||'%',codcomp)
          and dteacd between p_dteacdst and p_dteacden
        order by codcomp,codempid,dteacd desc,timeacd desc,dtesmit desc;
  begin
    obj_rows := json();
    for i in c1 loop
        v_count := v_count + 1;
        if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
            v_count_secur := v_count_secur + 1;
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('no',v_row);
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('dteacd',to_char(i.dteacd,'dd/mm/yyyy'));
            obj_data.put('timeacd',substr(i.timeacd,1,2)||':'||substr(i.timeacd,3,2));
            obj_data.put('location',i.location);
            obj_data.put('desresult',i.desresult);
            obj_data.put('dtestr',to_char(i.dtestr,'dd/mm/yyyy'));
            obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_data.put('dtesmit',to_char(i.dtesmit,'dd/mm/yyyy'));   
            obj_data.put('numwc',i.numwc);
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THWCCASE');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif v_count > 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
   end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) AS
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

END HRBF28X;

/
