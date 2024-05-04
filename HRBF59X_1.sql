--------------------------------------------------------
--  DDL for Package Body HRBF59X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF59X" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj            := json_object_t(json_str_input);
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
        p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemthpay');
        p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
        p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
        p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_typpay            := hcm_util.get_string_t(json_obj,'p_typpay');

  end initial_value;

  procedure check_index as
    v_temp          varchar(1 char);
    obj_codobf      json_object_t;

  begin
--  check null parameters
    if p_dteyrepay is null or p_dtemthpay is null or p_numperiod is null or p_typpayroll is null or p_codcomp is null or p_typpay is null then
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
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
    end;

--  check secure7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check typpayroll in tcodtypy
    begin
        select 'X' into v_temp
          from tcodtypy
         where codcodec = p_typpayroll
           and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY');
        return;
    end;

  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_chk_secur     boolean := false;

    cursor c1 is
        select t1.codcomp, t1.amtpfin, t1.amtpint, t1.amtrepmt, t1.dterepmt, t1.numcont, t1.typtran,
               t2.codlon, t2.codempid
          from tloanpay t1, tloaninf t2
         where t2.numcont = t1.numcont
           and t1.dtemthpay = p_dtemthpay
           and t1.dteyrepay = p_dteyrepay
           and t1.typpayroll = p_typpayroll
           and t1.numperiod = p_numperiod
           and t1.codcomp like p_codcomp || '%'
           and t1.typpay = p_typpay
      order by t1.codcomp, t2.codempid, t1.dterepmt, t2.codlon;

    obj_codobf        json;

  begin
    obj_rows := json_object_t();
    for r1 in c1 loop
        v_count := v_count + 1;
        --v_chk_secur := secur_main.secur3(r1.codcomp,r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        v_chk_secur := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if v_chk_secur then
            v_count_secur := v_count_secur + 1;
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('image',get_emp_img(r1.codempid));
            obj_data.put('codempid',r1.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('desc_codlon',get_ttyplone_name(r1.codlon,  global_v_lang));
            obj_data.put('dterepmt',to_char(r1.dterepmt,'dd/mm/yyyy'));
            obj_data.put('amtpfin',r1.amtpfin);
            obj_data.put('amtpint',r1.amtpint);
            obj_data.put('amtrepmt',r1.amtrepmt);
            obj_data.put('numcont',r1.numcont);
            obj_data.put('typtran',r1.typtran);

            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLOANINF');
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

END HRBF59X;

/
