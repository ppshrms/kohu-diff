--------------------------------------------------------
--  DDL for Package Body HRRC5BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC5BX" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin

    p_dtetrnjost     := to_date(hcm_util.get_string_t(data_obj,'p_dtetrnjost'), 'dd/mm/yyyy');
    p_dtetrnjoen     := to_date(hcm_util.get_string_t(data_obj,'p_dtetrnjoen'), 'dd/mm/yyyy');
    p_codemprc       := hcm_util.get_string_t(data_obj,'p_codemprc');
    p_codcomp        := hcm_util.get_string_t(data_obj,'p_codcomp');
    p_numreqst       := hcm_util.get_string_t(data_obj,'p_numreqst');
    p_codpos         := hcm_util.get_string_t(data_obj,'p_codpos');


  end initial_params;

  function check_index return boolean as
    v_temp  varchar(1 char);
  begin
-- check date
    if p_dtetrnjost > p_dtetrnjoen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return false;
    end if;

--  check codemprc
    if p_codemprc is not null then
        begin
            select 'X' into v_temp
            from temploy1
            where codempid = p_codemprc;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TEMPLOY1');
            return false;
        end;
    end if;

--  check secur2
    if secur_main.secur2(p_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

    if p_codcomp is not null then
--  check codcomp
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
            return false;
        end;

--  check secur7
        if secur_main.secur7(p_codcomp, global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return false;
        end if;
    end if;

    if p_numreqst is not null then
-- check numreqst
        begin
            select 'X' into v_temp
            from treqest1
            where numreqst = p_numreqst;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TREQEST1');
            return false;
        end;
    end if;

    if p_codpos is not null then
--  check position
        begin
            select 'X' into v_temp
            from tpostn
            where codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
            return false;
        end;
    end if;

    if p_numreqst is not null and p_codpos is not null then
        begin
            select 'X' into v_temp
            from treqest2
            where numreqst = p_numreqst
              and codpos = p_codpos
              and codcomp like p_codcomp || '%';
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
            return false;
        end;
    end if;

    return true;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows          json_object_t;
    obj_data          json_object_t;
    v_row             number := 0;
    v_count_row       number := 0;
    v_count_secur     number := 0;

    cursor c1 is
        select a.numappl, decode(global_v_lang, '101', namempe,
                                                '102', namempt,
                                                '103', namemp3,
                                                '104', namemp4,
                                                '105', namemp5) namemp,
               a.dteappl, a.codpos1, a.codpos2, a.flgqualify, a.statappl,
               b.codcomp
        from tapplinf a, treqest2 b
        where a.numreql = b.numreqst
          and a.codposl = b.codpos
          and a.dtetrnjo between p_dtetrnjost and p_dtetrnjoen
          and a.codemprc = nvl(p_codemprc, a.codemprc)
          and b.codcomp like nvl(p_codcomp || '%', b.codcomp)
          and a.numreql = nvl(p_numreqst, a.numreql)
          and a.codposl = nvl(p_codpos, a.codposl)
        order by a.numappl;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_count_row := v_count_row + 1;
        if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_count_secur := v_count_secur + 1;
            obj_data := json_object_t();
            v_row := v_row + 1;
            obj_data.put('numappl', i.numappl);
            obj_data.put('desc_appl', i.namemp);
            obj_data.put('dteappl', to_char(i.dteappl, 'dd/mm/yyyy'));
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos1, global_v_lang));
            obj_data.put('desc_codposr', get_tpostn_name(i.codpos2, global_v_lang));
            obj_data.put('qualify', i.flgqualify);
            obj_data.put('result', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count_row != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    elsif v_count_row = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TAPPLINF');
    end if;

    if param_msg_error is null then
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

END HRRC5BX;

/
