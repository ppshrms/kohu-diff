--------------------------------------------------------
--  DDL for Package Body HRRC93X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC93X" AS

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
--  index parameter
        p_codcomp        := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_year           := hcm_util.get_string_t(data_obj,'p_year');
        p_monthst        := lpad(hcm_util.get_string_t(data_obj,'p_monthst'),2,'0');
        p_monthen        := lpad(hcm_util.get_string_t(data_obj,'p_monthen'),2,'0');

  end initial_params;

  function check_index return boolean as
    v_temp      varchar(1 char);
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return false;
    end;



--  check secur7
    if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

    return true;

  end;

  procedure clear_ttemprpt(v_codapp varchar2) is
  begin
    begin
        delete
        from  ttemprpt
        where codempid = global_v_codempid
        and   codapp   = v_codapp;
    exception when others then
        null;
    end;
  end clear_ttemprpt;

  function get_max_numseq(v_codapp varchar2) return number is
    v_numseq    ttemprpt.numseq%type;
  begin
    select max(numseq) into v_numseq
    from  ttemprpt
    where codempid = global_v_codempid
    and   codapp   = v_codapp;

    if v_numseq is null then
        v_numseq := 1;
    else
        v_numseq := v_numseq + 1;
    end if;

    return v_numseq;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_qtyemp        number;
    v_qtyact        number;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_numseq        number := 0;
    cursor c1 is
        select codjobpost, sum(amtpay) as amtpay
        from tjobposte
        where codcomp like p_codcomp || '%'
          and to_char(dtepost, 'yyyy') = p_year
          and to_char(dtepost, 'mm') between p_monthst and p_monthen
        group by codjobpost;

  begin
    obj_rows := json_object_t();
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRC93X';
--    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRC93X1';
    
--    v_numseq := get_max_numseq('HRRC93X1');
--    insert into ttemprpt(codempid,codapp,numseq,
--                         item1,item2,item3,item4,item5)
--    values(global_v_codempid, 'HRRC93X1', v_numseq,
--           'DETAIL', p_codcomp||' - '||get_tcenter_name(p_codcomp,global_v_lang), 
--           hcm_util.get_year_buddhist_era(p_year), 
--           get_nammthful(p_monthst,global_v_lang), 
--           get_nammthful(p_monthen,global_v_lang));
    
    for i in c1 loop
        v_count := v_count + 1;
        --if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_count_secur := v_count_secur + 1;
            select count(b.numappl) into v_qtyemp
            from tjobpost a, tapplinf b
            where a.codcomp like p_codcomp || '%'
              and to_char(a.dtepost, 'yyyy') = p_year
              and to_char(a.dtepost, 'mm') between p_monthst and p_monthen
              and a.codjobpost = i.codjobpost
              and a.numreqst = b.numreql
              and a.codpos = b.codposl;

            select sum(b.qtyact) into v_qtyact
            from tjobpost a, treqest2 b
            where a.codcomp like p_codcomp || '%'
              and to_char(a.dtepost, 'yyyy') = p_year
              and to_char(a.dtepost, 'mm') between p_monthst and p_monthen
              and a.codjobpost = i.codjobpost
              and a.numreqst = b.numreqst
              and a.codpos = b.codpos;

            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('news', get_tcodec_name('TCODJOBPOST', i.codjobpost, global_v_lang));
            obj_data.put('budget', i.amtpay);
            obj_data.put('numapp', v_qtyemp);
            obj_data.put('numppl', v_qtyact);
            obj_rows.put(to_char(v_row-1),obj_data);
            
--            v_numseq := get_max_numseq('HRRC93X1');
--            insert into ttemprpt(codempid,codapp,numseq,
--                                 item1,item2,item3,item4,item5,item6)
--            values(global_v_codempid, 'HRRC93X1', v_numseq,
--                   'TABLE', v_row, get_tcodec_name('TCODJOBPOST', i.codjobpost, global_v_lang), 
--                   to_char(i.amtpay, 'fm999,999,999,999,990.00'), 
--                   to_char(v_qtyemp, 'fm999,999,999,999,990'), 
--                   to_char(v_qtyact, 'fm999,999,999,999,990'));

            v_numseq := get_max_numseq('HRRC93X');

            -- ค่าใช้จ่าย
            insert into ttemprpt(codempid,codapp,numseq,item1,item4,item5,item7,item8,item9,item10)
            values(global_v_codempid,
                'HRRC93X',
                v_numseq,
                get_label_name('HRRC93XC1',global_v_lang,60),
                i.codjobpost,get_tcodec_name('TCODJOBPOST', i.codjobpost, global_v_lang),
                1,
                get_label_name('HRRC93XC1',global_v_lang,60),
                get_label_name('HRRC93XC1',global_v_lang,60),
                i.amtpay);

            -- จำนวนคนสมัคร
            insert into ttemprpt(codempid,codapp,numseq,item1,item4,item5,item7,item8,item9,item10)
            values(global_v_codempid,
                'HRRC93X',
                v_numseq+1,
                get_label_name('HRRC93XC1',global_v_lang,70),
                i.codjobpost,get_tcodec_name('TCODJOBPOST', i.codjobpost, global_v_lang),
                2,
                get_label_name('HRRC93XC1',global_v_lang,80),
                get_label_name('HRRC93XC1',global_v_lang,70),v_qtyemp);

            -- จำนวนคนที่จัดจ้าง
            insert into ttemprpt(codempid,codapp,numseq,item1,item4,item5, item7,item8,item9,item10)
            values(global_v_codempid,
                'HRRC93X',
                v_numseq+2,
                get_label_name('HRRC93XC1',global_v_lang,70),
                i.codjobpost,get_tcodec_name('TCODJOBPOST', i.codjobpost, global_v_lang),
                3,
                get_label_name('HRRC93XC1',global_v_lang,90),
                get_label_name('HRRC93XC1',global_v_lang,70),v_qtyact);

            commit;
        --end if;
    end loop;

    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TJOBPOSTE');
    end if;

    if param_msg_error is null then
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        rollback;
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


  procedure gen_report(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_qtyemp        number;
    v_qtyact        number;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_numseq        number := 0;
    sum_amtpay      number := 0;
    sum_qtyemp      number := 0;
    sum_qtyact      number := 0;
    cursor c1 is
        select codjobpost, sum(amtpay) as amtpay
        from tjobposte
        where codcomp like p_codcomp || '%'
          and to_char(dtepost, 'yyyy') = p_year
          and to_char(dtepost, 'mm') between p_monthst and p_monthen
        group by codjobpost;

  begin
    obj_rows := json_object_t();
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRC93X1';
    
    v_numseq := get_max_numseq('HRRC93X1');
    insert into ttemprpt(codempid,codapp,numseq,
                         item1,item2,item3,item4,item5)
    values(global_v_codempid, 'HRRC93X1', v_numseq,
           'DETAIL', p_codcomp||' - '||get_tcenter_name(p_codcomp,global_v_lang), 
           hcm_util.get_year_buddhist_era(p_year), 
           get_nammthful(p_monthst,global_v_lang), 
           get_nammthful(p_monthen,global_v_lang));
    
    for i in c1 loop
        v_count := v_count + 1;
        --if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_count_secur := v_count_secur + 1;
            select count(b.numappl) into v_qtyemp
            from tjobpost a, tapplinf b
            where a.codcomp like p_codcomp || '%'
              and to_char(a.dtepost, 'yyyy') = p_year
              and to_char(a.dtepost, 'mm') between p_monthst and p_monthen
              and a.codjobpost = i.codjobpost
              and a.numreqst = b.numreql
              and a.codpos = b.codposl;

            select sum(b.qtyact) into v_qtyact
            from tjobpost a, treqest2 b
            where a.codcomp like p_codcomp || '%'
              and to_char(a.dtepost, 'yyyy') = p_year
              and to_char(a.dtepost, 'mm') between p_monthst and p_monthen
              and a.codjobpost = i.codjobpost
              and a.numreqst = b.numreqst
              and a.codpos = b.codpos;

            v_row := v_row+1;
            v_numseq := get_max_numseq('HRRC93X1');
            insert into ttemprpt(codempid,codapp,numseq,
                                 item1,item2,item3,item4,item5,item6)
            values(global_v_codempid, 'HRRC93X1', v_numseq,
                   'TABLE', v_row, get_tcodec_name('TCODJOBPOST', i.codjobpost, global_v_lang), 
                   to_char(i.amtpay, 'fm999,999,999,999,990.00'), 
                   to_char(v_qtyemp, 'fm999,999,999,999,990'), 
                   to_char(v_qtyact, 'fm999,999,999,999,990'));
            sum_amtpay := sum_amtpay + i.amtpay;
            sum_qtyemp := sum_qtyemp + v_qtyemp;
            sum_qtyact := sum_qtyact + v_qtyact;
        --end if;
    end loop;
    
    if v_row > 0 then
        v_row := v_row + 1;
        v_numseq := get_max_numseq('HRRC93X1');
        insert into ttemprpt(codempid,codapp,numseq,
                             item1,item2,item3,item4,item5,item6)
        values(global_v_codempid, 'HRRC93X1', v_numseq,
               'TABLE', '', get_label_name('HRRC93XC1',global_v_lang,'160'), 
               to_char(sum_amtpay, 'fm999,999,999,999,990.00'), 
               to_char(sum_qtyemp, 'fm999,999,999,999,990'), 
               to_char(sum_qtyact, 'fm999,999,999,999,990'));
    end if;

    param_msg_error := get_error_msg_php('HR2401', global_v_lang, 'TJOBPOSTE');
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end gen_report;

  procedure get_report(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_report(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_report;
END HRRC93X;

/
