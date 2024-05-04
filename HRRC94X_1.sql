--------------------------------------------------------
--  DDL for Package Body HRRC94X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC94X" AS

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

  procedure clear_ttemprpt is
  begin
    begin
        delete
        from  ttemprpt
        where codempid = global_v_codempid
        and   codapp   = 'HRRC94X';
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
    and   codapp   = 'HRRC94X';

    if v_numseq is null then
        v_numseq := 1;
    else
        v_numseq := v_numseq + 1;
    end if;

    return v_numseq;

  end;

  procedure insert_graph(v_row number, v_name_x varchar2, v_value number, v_codpos varchar2,v_numreqst varchar2,v_codgroup varchar2) as
    v_item2     ttemprpt.item1%type;
    v_item31    ttemprpt.item31%type;
  begin

    v_item2 := get_label_name('HRRC94XC1',global_v_lang,'60')||' : '||v_numreqst||'   '||get_label_name('HRRC94XC1',global_v_lang,'70')||' : '||get_tpostn_name(v_codpos, global_v_lang);
    v_item31    := get_tappprof_name('HRRC94X', '2',global_v_lang);

    insert into ttemprpt
        (
            codempid, codapp, numseq, item2, item4, item5,
            item8, item9, item10,item31
        )
    values
        (
            global_v_codempid, 'HRRC94X', v_row, v_item2, v_codgroup, v_name_x,
            get_label_name('HRRC94XC1',global_v_lang,'140'), get_label_name('HRRC94XC1',global_v_lang,'140'), v_value,v_item31
        );

  end insert_graph;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_qtyapprove    number;
    v_qtypost       number;
    v_qtytransfer   number;
    v_interview_period  number;
    v_approval_period   number;
    v_total_duration    number;
    cursor c1 is
        select a.numreqst, b.codpos, trunc(a.dteaprov) as dteaprov, trunc(a.dtereq) as dtereq, trunc(b.dtepost) as dtepost
               , trunc(b.dteappchse) as dteappchse, trunc(b.dteintview) as dteintview, trunc(b.dtechoose) as dtechoose,a.codcomp
          from treqest1 a , treqest2 b
         where a.codcomp like p_codcomp || '%'
           and a.numreqst = b.numreqst
           and to_char(a.dtereq, 'yyyy') = p_year
           and to_char(a.dtereq, 'mm') between p_monthst and p_monthen
           and a.dteaprov is not null
         order by numreqst , codpos;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
    v_count := v_count + 1;
      if secur_main.secur7(i.codcomp, global_v_coduser) then
        v_count_secur := v_count_secur + 1;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('numreq', i.numreqst);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        
--<< user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8812 || v_qtypost          := (i.dtepost    - i.dteappchse) + 1;
        v_qtyapprove       := (i.dteaprov   - i.dtereq) + 1;
        v_qtypost          := (i.dtepost    - i.dteaprov);
        v_qtytransfer      := (i.dtechoose  - i.dtepost);
        v_interview_period := (i.dteintview - i.dtechoose);
        v_approval_period  := (i.dteappchse - i.dteintview);
        v_total_duration   := nvl(v_qtyapprove,0) + nvl(v_qtypost,0) + nvl(v_qtytransfer,0) + nvl(v_interview_period,0) + nvl(v_approval_period,0);
        /*v_qtyapprove :=(i.dteaprov - i.dtereq) + 1;
        v_qtypost := (i.dtepost - i.dteaprov) + 1;
        v_qtytransfer := (i.dtechoose - i.dtepost) + 1;
        v_interview_period := (i.dteintview - i.dtechoose) + 1;
        v_approval_period := (i.dteappchse - i.dteintview) + 1;
        v_total_duration := nvl((i.dteaprov - i.dtereq + 1),0) + nvl((i.dtepost - i.dteaprov + 1),0) + 
                            nvl((i.dtechoose - i.dtepost + 1),0) + nvl((i.dteintview - i.dtechoose + 1),0) + 
                            nvl((i.dteappchse - i.dteintview) + 1,0);*/
-->> user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8812 || v_qtypost          := (i.dtepost    - i.dteappchse) + 1;        
        obj_data.put('qtyapprove', v_qtyapprove);
        obj_data.put('qtypost', v_qtypost);
        obj_data.put('qtytransfer', v_qtytransfer);
        obj_data.put('interview_period', v_interview_period);
        obj_data.put('approval_period', v_approval_period);
        obj_data.put('total_duration', v_total_duration);
        
        insert_graph(get_max_numseq, get_label_name('HRRC94XC1',global_v_lang,'80'), v_qtyapprove, i.codpos,i.numreqst,'C1');
        insert_graph(get_max_numseq, get_label_name('HRRC94XC1',global_v_lang,'90'), v_qtypost, i.codpos,i.numreqst,'C2');
        insert_graph(get_max_numseq, get_label_name('HRRC94XC1',global_v_lang,'100'), v_qtytransfer, i.codpos,i.numreqst,'C3');
        insert_graph(get_max_numseq, get_label_name('HRRC94XC1',global_v_lang,'110'), v_interview_period, i.codpos,i.numreqst,'C4');
        insert_graph(get_max_numseq, get_label_name('HRRC94XC1',global_v_lang,'120'), v_approval_period, i.codpos,i.numreqst,'C5');
        insert_graph(get_max_numseq, get_label_name('HRRC94XC1',global_v_lang,'130'), v_total_duration, i.codpos,i.numreqst,'C6');
        
        obj_rows.put(to_char(v_row-1),obj_data);
      end if;
    end loop;

    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST1');
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
    clear_ttemprpt;
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

END HRRC94X;

/
