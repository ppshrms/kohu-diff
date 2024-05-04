--------------------------------------------------------
--  DDL for Package Body HRBFS5X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFS5X" AS

 procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_dteyear         := hcm_util.get_string(json_obj,'p_dteyear');
        p_mthst           := to_number(hcm_util.get_string(json_obj,'p_mthst'));
        p_mthen           := to_number(hcm_util.get_string(json_obj,'p_mthen'));
        p_codcomp         := hcm_util.get_string(json_obj,'p_codcomp');
        p_list_coddc      := hcm_util.get_json(json_obj,'p_list_coddc');

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--  check null parameter
    if p_dteyear is null or p_mthst is null or p_mthen is null or p_codcomp is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check date
    if p_mthst > p_mthen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
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

--  check secure7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;
  end;

  procedure clear_ttemprpt is
    begin
        begin
            delete
            from  ttemprpt
            where codempid = global_v_codempid
            and   codapp   = 'HRBFS5X';
        exception when others then
    null;
    end;
  end clear_ttemprpt;

  function get_max_numseq return number is
    v_numseq    ttemprpt.numseq%type;
  begin
    select max(numseq) into v_numseq
    from  ttemprpt
    where codempid = global_v_codempid
    and   codapp   = 'HRBFS5X';

    if v_numseq is null then
        v_numseq := 1;
    else
        v_numseq := v_numseq + 1;
    end if;

    return v_numseq;

  end;

  procedure insert_ttemprpt_amtalw_type(v_row number,v_coddc varchar2,v_amtalw number) as
    v_item1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item31    ttemprpt.item31%type;

  begin
    v_item1 := get_label_name('HRBFS5X',global_v_lang,'70');
    v_item5 := get_tdcinf_name(v_coddc,global_v_lang);
    v_item31 := get_label_name('HRBFS5X',global_v_lang,'100');

    insert into ttemprpt
        (
            codempid, codapp, numseq, item1, item4, item5,
            item7, item8, item9, item10, item14, item31
        )
    values
        (
            global_v_codempid, 'HRBFS5X', v_row,v_item1, v_coddc, v_item5,
            v_item1, v_item1, v_item1, v_amtalw, 'A', v_item31
        );

  end insert_ttemprpt_amtalw_type;

  procedure insert_ttemprpt_qtyemp_type(v_row number,v_coddc varchar2,v_qtyemp number) as
    v_item1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item31    ttemprpt.item31%type;

  begin
    v_item1 := get_label_name('HRBFS5X',global_v_lang,'80');
    v_item5 := get_tdcinf_name(v_coddc,global_v_lang);
    v_item31 := get_label_name('HRBFS5X',global_v_lang,'100');

    insert into ttemprpt
        (
            codempid, codapp, numseq, item1, item4, item5,
            item7, item8, item9, item10, item14, item31
        )
    values
        (
            global_v_codempid, 'HRBFS5X', v_row, v_item1, v_coddc, v_item5,
            v_item1, v_item1, v_item1, v_qtyemp, 'B', v_item31
        );

  end insert_ttemprpt_qtyemp_type;

  procedure gen_index(json_str_output out clob) as
    obj_data        json;
    obj_rows        json;
    v_row           number := 0;
    v_coddc         tclnsinf.coddc%type;
    v_amtalw        number;
    v_qtyemp        number;
    v_count         number;
  begin
    obj_rows := json();
    for i in 0..p_list_coddc.count-1 loop
        p_coddc := hcm_util.get_string(p_list_coddc,(i));
        begin
            select coddc,sum(amtalw) amtalw,count(distinct codempid) qtyemp into v_coddc, v_amtalw, v_qtyemp
            from tclnsinf
            where dtecrest between to_date(get_period_date(p_mthst,p_dteyear,'S'),'dd/mm/yyyy') and to_date(get_period_date(p_mthen,p_dteyear,''),'dd/mm/yyyy')
              and codcomp like p_codcomp || '%'
              and coddc = p_coddc
              and codrel = 'E'
            group by coddc
            order by coddc;
        exception when no_data_found then
            v_coddc  := p_coddc;
            v_amtalw := 0;
            v_qtyemp := 0;
--            v_count := 0;
        end;
        v_row := v_row + 1;
        obj_data := json();
        obj_data.put('coddc',v_coddc);
        obj_data.put('coddc_name',get_tdcinf_name(v_coddc,global_v_lang));
        obj_data.put('amtalw',v_amtalw);
        obj_data.put('qtyemp',v_qtyemp);
        obj_rows.put(to_char(v_row-1),obj_data);

        insert_ttemprpt_amtalw_type(get_max_numseq,v_coddc,v_amtalw);

        insert_ttemprpt_qtyemp_type(get_max_numseq,v_coddc,v_qtyemp);

    end loop;

    if v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tclnsinf');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    clear_ttemprpt;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

END HRBFS5X;

/
