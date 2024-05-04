--------------------------------------------------------
--  DDL for Package Body HRRC21X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21X" AS
 procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
    begin
        p_codcomp    := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_month      := hcm_util.get_string_t(data_obj,'p_month');
        p_year       := hcm_util.get_string_t(data_obj,'p_year');

  end initial_params;

  function check_index return boolean as
    v_temp  varchar(1 char);
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return false;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return false;
    end if;

    return true;

  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_dtestrbf      date;
    v_dteendbf      date;
    v_dtestr        date;
    v_dteend        date;

    v_qtyreq_ss     treqest2.qtyreq%type;
    v_qtyact_ss     treqest2.qtyact%type;
    v_qtyreq_s      treqest2.qtyreq%type;
    v_qtyact_s      treqest2.qtyact%type;
    cursor c1 is
    -- <<  surachai add || 21/11/2022 || ##8189
    select b.codpos
    from treqest1 a, treqest2 b
    where a.numreqst = b.numreqst
        and a.codcomp like p_codcomp||'%'
        and a.dtereq between v_dtestrbf and v_dteend
        and stareq not in ('C','X')
    group by b.codpos
    order by b.codpos asc;
    -- >>

-- <<    surachai bk || 21/11/2022 || ##8189
--    order by b.codpos asc;
--      select b.codpos, nvl(sum(b.qtyreq),0) qtyreq_s, nvl(sum(b.qtyact),0) qtyact_s
--        from treqest1 a, treqest2 b
--        where a.numreqst = b.numreqst
--          and a.codcomp like p_codcomp || '%'
--          and a.dtereq between v_dtestrbf and v_dteendbf
--          and stareq not in ('C','X')
--        group by b.codpos
-- >>
        --------------------------------------
--      union ----
--      select b.codpos, 0 qtyreq_s, 0 qtyact_s
--        from treqest1 a, treqest2 b
--        where a.numreqst = b.numreqst
--          and a.codcomp like p_codcomp || '%'
--          and a.dtereq between v_dtestr and v_dteend
--          and stareq not in ('C','X')
--          and not exists  (select d.codpos
--                             from treqest1 c, treqest2 d
--                            where c.numreqst = d.numreqst
--                              and c.codcomp like p_codcomp || '%'
--                              and c.dtereq between v_dtestrbf and v_dteendbf
--                              and stareq not in ('C','X')
--                              and b.codpos = d.codpos)
--        group by b.codpos
--        order by 1;
--        select b.codpos, nvl(sum(b.qtyreq),0) qtyreq_s, nvl(sum(b.qtyact),0) qtyact_s
--        from treqest1 a, treqest2 b
--        where a.numreqst = b.numreqst
--          and a.codcomp like p_codcomp || '%'
--          and a.dtereq between v_dtestr and v_dteend
--          and stareq not in('C','X')
--        group by b.codpos
--        order by b.codpos;

  begin
    obj_rows := json_object_t();
    v_dtestrbf    := to_date(get_period_date(p_month-1,p_year,'S'),'dd/mm/yyyy');
    v_dteendbf  := to_date(get_period_date(p_month-1,p_year,''),'dd/mm/yyyy');
    v_dtestr    := to_date(get_period_date(p_month,p_year,'S'),'dd/mm/yyyy');
    v_dteend  := to_date(get_period_date(p_month,p_year,''),'dd/mm/yyyy');
    for i in c1 loop
        v_count := v_count + 1;
        v_row := v_row+1;
        obj_data := json_object_t();
--        v_dtestr    := to_date(get_period_date(p_month,p_year,'S'),'dd/mm/yyyy');
--        v_dteend  := to_date(get_period_date(p_month,p_year,''),'dd/mm/yyyy');
        -- <<  surachai add || 21/11/2022 || ##8189
        begin
            select nvl(sum(b.qtyreq),0) qtyreq_ss, nvl(sum(b.qtyact),0) qtyact_ss
            into v_qtyreq_ss, v_qtyact_ss
            from treqest1 a, treqest2 b
            where a.numreqst = b.numreqst
              and a.codcomp like p_codcomp || '%'
              and a.dtereq between v_dtestrbf and v_dteendbf
              and stareq not in ('C','X')
              and b.codpos = i.codpos;
        exception when no_data_found then
            v_qtyreq_ss := 0;
            v_qtyact_ss := 0;
        end;
        -- >>
        begin
            select nvl(sum(qtyreq),0) qtyreq_s, nvl(sum(qtyact),0) qtyact_s
            into v_qtyreq_s, v_qtyact_s
            from treqest1 a, treqest2 b
            where a.numreqst = b.numreqst
              and a.codcomp like p_codcomp || '%'
              and a.dtereq between v_dtestr and v_dteend
              and b.codpos = i.codpos
              and a.stareq not in('C','X')
              and b.codpos = i.codpos;
        exception when no_data_found then
            v_qtyreq_s := 0;
            v_qtyact_s := 0;
        end;
-- <<  surachai bk || 21/11/2022 || ##8189
--        obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
--        obj_data.put('quolsmt',i.qtyreq_s);
--        obj_data.put('qtyreq',v_qtyreq_s);
--        obj_data.put('total',v_qtyreq_s + i.qtyreq_s);
--        obj_data.put('allocate',i.qtyact_s + v_qtyact_s);
--        obj_data.put('balance',(v_qtyreq_s + i.qtyreq_s) + (i.qtyact_s + v_qtyact_s));
--        obj_rows.put(to_char(v_row-1),obj_data);
-- >>
        -- <<  surachai add || 21/11/2022 || ##8189
        obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
        obj_data.put('quolsmt',v_qtyreq_ss);
        obj_data.put('qtyreq',v_qtyreq_s);
        obj_data.put('total',v_qtyreq_s + v_qtyreq_ss);
        obj_data.put('allocate',v_qtyact_ss + v_qtyact_s);
        obj_data.put('balance',(v_qtyreq_s + v_qtyreq_ss) + (v_qtyact_ss + v_qtyact_s));
        obj_rows.put(to_char(v_row-1),obj_data);
        -- >>
    end loop;
    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST1');
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

END HRRC21X;

/
