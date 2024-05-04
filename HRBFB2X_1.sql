--------------------------------------------------------
--  DDL for Package Body HRBFB2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFB2X" AS
  procedure initial_value(json_str_input in clob) as
   json_obj json;
  begin
    json_obj            := json(json_str_input);
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codcomp           := hcm_util.get_string(json_obj,'p_codcomp');
    p_dteyear           := hcm_util.get_string(json_obj,'p_dteyear');
    p_dtefollowst       := to_date(hcm_util.get_string(json_obj,'p_dtefollowst'),'dd/mm/yyyy');
    p_dtefollowen       := to_date(hcm_util.get_string(json_obj,'p_dtefollowen'),'dd/mm/yyyy');
    p_codprgheal        := hcm_util.get_string(json_obj,'p_codprgheal');

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--  check null parameters
    if p_codcomp is null or p_dteyear is null or p_dtefollowst is null or p_dtefollowen is null then
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

--  check codprgheal
    if p_codprgheal is not null then
        begin
            select 'X' into v_temp
            from thealcde
            where codprgheal = p_codprgheal;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'thealcde');
            return;
        end;
    end if;

--  check secur7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

    if p_dtefollowst > p_dtefollowen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json;
    obj_data        json;
    v_row           number := 0;
    v_chk_secur     boolean := false;
    v_row_secur     number :=0;
    v_count         number := 0;

    cursor c1 is
        select t1.codempid,t1.codcomp,t1.dteheal,t1.codprgheal,t1.codcln,t1.descheal,t1.dtefollow
        from thealinf1 t1
        where t1.dteyear = p_dteyear
          and nvl(t1.codcomp,'%') like p_codcomp || '%'
          and t1.codprgheal = nvl(p_codprgheal,t1.codprgheal)
          and t1.dtefollow between p_dtefollowst and p_dtefollowen
        order by t1.codcomp,t1.codempid,t1.dteheal;
  begin
    obj_rows := json();
    for i in c1 loop
           v_count := v_count + 1;
           v_chk_secur := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if v_chk_secur then
                v_row := v_row + 1;
                obj_data := json();
                v_row_secur := v_row_secur+1;
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
                obj_data.put('codprgheal',i.codprgheal);
                obj_data.put('codprgheal_name',get_thealcde_name(i.codprgheal,global_v_lang));
                obj_data.put('codcln',i.codcln);
                obj_data.put('codcln_name',get_tclninf_name(i.codcln,global_v_lang));
                obj_data.put('dteheal',to_char(i.dteheal,'dd/mm/yyyy'));
                obj_data.put('descheal',i.descheal);
                obj_data.put('dteyear',p_dteyear);
                obj_data.put('dtefollow',to_char(i.dtefollow,'dd/mm/yyyy'));
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
    end loop;

    if v_row_secur = 0 and v_count != 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thealinf1');
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

END HRBFB2X;

/
