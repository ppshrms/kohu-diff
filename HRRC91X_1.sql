--------------------------------------------------------
--  DDL for Package Body HRRC91X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC91X" AS

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

        p_dtestr         := to_date(get_period_date(p_monthst, p_year, 'S'), 'dd/mm/yyyy');
        p_dteend         := to_date(get_period_date(p_monthen, p_year, ''), 'dd/mm/yyyy');

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
            and   codapp   = 'HRRC91X';
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
    and   codapp   = 'HRRC91X';

    if v_numseq is null then
        v_numseq := 1;
    else
        v_numseq := v_numseq + 1;
    end if;

    return v_numseq;

  end;

  procedure insert_graph_codcomp as
    v_item1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_row       number;
    v_sum       number;
    cursor c1 is
        select codcomp
          from tjobpost
         where codcomp like p_codcomp || '%'
           and dtepost between p_dtestr and p_dteend
         group by codcomp
         order by codcomp;
  begin
    v_item1 := get_label_name('HRRC91XC1', global_v_lang, '50');
    v_item9 := get_label_name('HRRC91XC1', global_v_lang, '90');
    for i in c1 loop
        if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_item5 := get_tcenter_name(i.codcomp, global_v_lang);
            v_row := get_max_numseq;
            -- Adisak redmine#8809 -- 28/03/2023 14:18
            begin
              select sum(a.amtpay)
                into v_sum
                from tjobpost a
                join treqest2 b
                  on b.numreqst in (
                    select distinct(c.numreqst)
                      from tjobpost c
                     where c.codcomp = a.codcomp
                       and c.codpos = a.codpos
                       and c.dtepost between p_dtestr and p_dteend
                  )
                  and b.codpos = a.codpos
                where a.codcomp = b.codcomp
                  and a.codcomp = i.codcomp
                  and a.dtepost between p_dtestr and p_dteend
                  and nvl(b.qtyact, 0) > 0
                group by a.codcomp
                order by a.codcomp;
            exception when no_data_found then
              v_sum := 0;
            end;
            -- Adisak redmine#8809 -- 28/03/2023 14:18
            insert into ttemprpt
                (
                    codempid, codapp, numseq, item1, item4, item5,
                    item7, item8, item9, item10, item14
                )
            values
                (
                    global_v_codempid, 'HRRC91X', v_row, v_item1, i.codcomp, v_item5,
                    v_item1, v_item1, v_item9, v_sum, 'A'
                );
        end if;
    end loop;

  end insert_graph_codcomp;

--  procedure insert_graph_codpos as
--    v_item1     ttemprpt.item1%type;
--    v_item5     ttemprpt.item4%type;
--    v_item9     ttemprpt.item9%type;
--    v_item10    ttemprpt.item10%type;
--    v_row       number;
--    v_temp      varchar2(1 char);
--    v_sum       number;
--    cursor c1 is
--        select codpos,codcomp,sum(amtpay) as total
--          from tjobpost
--         where codcomp like p_codcomp || '%'
--           and dtepost between p_dtestr and p_dteend
--         group by codpos,codcomp
--         order by codpos,codcomp;
--  begin
--    v_item1 := get_label_name('HRRC91XC1', global_v_lang,'60');
--    v_item9 := get_label_name('HRRC91XC1', global_v_lang,'90');
--    for i in c1 loop
--        if secur_main.secur7(i.codcomp, global_v_coduser) then
--            begin
--                select 'X' into v_temp
--                  from ttemprpt
--                 where codempid = global_v_codempid
--                   and codapp = 'HRRC91X'
--                   and item4 = i.codpos
--                   and item14 = 'B';
--            exception when no_data_found then
--                v_item5 := get_tpostn_name(i.codpos, global_v_lang);
--                v_row := get_max_numseq;
--                insert into ttemprpt
--                       (codempid, codapp, numseq, item1, item4, item5,
--                       item7, item8, item9, item10, item14)
--                values (global_v_codempid, 'HRRC91X', v_row, v_item1, i.codpos, v_item5,
--                       v_item1, v_item1, v_item9, i.total, 'B');
--                v_temp := '';
--            end;
--            if v_temp = 'X' then
--                update ttemprpt
--                   set item10 = item10 + i.total
--                 where codempid = global_v_codempid
--                   and codapp = 'HRRC91X'
--                   and item4 = i.codpos
--                   and item14 = 'B';
--            end if;
--        end if;
--    end loop;
--  end insert_graph_codpos;

-- Adisak redmine#8809 -- 28/03/2023 15:21
  procedure insert_graph_codpos as
    v_item1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_row       number;
    v_temp      varchar2(1 char);
    v_sum       number;
    v_codpos    tjobpost.codpos%type;
    v_codcomps  varchar2(4000 char);
    cursor c1 is
        select distinct codpos
          from tjobpost
         where codcomp like p_codcomp || '%'
           and dtepost between p_dtestr and p_dteend
         group by codpos
         order by codpos;
    cursor c2 is
        select distinct codcomp
          from tjobpost
         where codcomp like p_codcomp || '%'
           and codpos = v_codpos
           and dtepost between p_dtestr and p_dteend
         group by codcomp
         order by codcomp;
  begin
    v_item1 := get_label_name('HRRC91XC1', global_v_lang,'60');
    v_item9 := get_label_name('HRRC91XC1', global_v_lang,'90');
    for i in c1 loop
        v_codpos := i.codpos;
        v_codcomps := '|';
        v_item5 := get_tpostn_name(i.codpos, global_v_lang);
        for i2 in c2 loop
          if secur_main.secur7(i2.codcomp, global_v_coduser) then 
            v_codcomps := v_codcomps || i2.codcomp || '|';
          end if;
        end loop;
        begin
          select sum(a.amtpay)
            into v_sum
            from tjobpost a
            join treqest2 b
              on b.numreqst in (
              select distinct(c.numreqst)
                from tjobpost c
               where c.codcomp = a.codcomp
                 and c.codpos = a.codpos
                 and c.dtepost between p_dtestr and p_dteend
              )
            and b.codpos = a.codpos
          where a.codcomp = b.codcomp
            and a.codpos = i.codpos
            and v_codcomps like '%|' || a.codcomp || '|%'
            and a.dtepost between p_dtestr and p_dteend
            and nvl(b.qtyact, 0) > 0
          group by a.codpos
          order by a.codpos;
        exception when no_data_found then
          v_sum := 0;
        end;
        v_row := get_max_numseq;
        insert into ttemprpt
               (codempid, codapp, numseq, item1, item4, item5,
               item7, item8, item9, item10, item14)
        values (global_v_codempid, 'HRRC91X', v_row, v_item1, i.codpos, v_item5,
               v_item1, v_item1, v_item9, v_sum, 'B');
    end loop;
  end insert_graph_codpos;
-- Adisak redmine#8809 -- 28/03/2023 15:21

  procedure gen_index(json_str_output out clob) as
    v_codcomp       tjobpost.codcomp%type;
    v_codpos        tjobpost.codpos%type;
    obj_rows        json_object_t;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_qtyact        treqest2.qtyact%type;
    v_qtyact_sum    number := 0;
    obj_data        json_object_t;
    v_row           number := 0;
    v_exp           number := 0;
    v_total         number := 0;

    cursor c1 is
        select codcomp,codpos,sum(amtpay) as amtpay
          from tjobpost
         where codcomp like p_codcomp || '%'
           and dtepost between p_dtestr and p_dteend
      group by codcomp,codpos
      order by codcomp,codpos;

    cursor c2 is
        select distinct(numreqst)
          from tjobpost
         where codcomp = v_codcomp
           and codpos = v_codpos
           and dtepost between p_dtestr and p_dteend
      order by numreqst;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_count     := v_count + 1;
        v_codcomp   := i.codcomp;
        v_codpos    := i.codpos;
        v_qtyact_sum := 0;
        if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_count_secur := v_count_secur + 1;
            for i2 in c2 loop
                begin
                    select nvl(qtyact,0) into v_qtyact
                      from treqest2
                     where numreqst = i2.numreqst
                       and codpos   = v_codpos;
                exception when no_data_found then
                    v_qtyact := 0;
                end;
                v_qtyact_sum := v_qtyact_sum + v_qtyact;
            end loop;

            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
            obj_data.put('qtyact', v_qtyact_sum);

            v_exp := nvl(i.amtpay / nullif(v_qtyact_sum,0),0);
            obj_data.put('costp', v_exp);
            v_total := nvl((v_qtyact_sum * v_exp),0);
            obj_data.put('costtoal', v_total);
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TJOBPOST');
    end if;

    if param_msg_error is null then
        insert_graph_codcomp;
        insert_graph_codpos;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
  end gen_index;

  procedure gen_index_old(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_codcomp       treqest2.codcomp%type;
    v_codpos        treqest2.codpos%type;
    v_cs_emp        number;
    v_exp           number;
    v_total         number;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_row_graph     number := 0;
    v_emp           number := 0;
    v_qtyact        treqest2.qtyact%type;
    cursor c1 is
        select numreqst, codpos, amtpay, codcomp
        from tjobpost
        where codcomp like p_codcomp || '%'
          and dtepost between p_dtestr and p_dteend
        order by codcomp, codpos;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_count := v_count + 1;
        v_codcomp := i.codcomp;
        v_codpos := i.codpos;
        if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_count_secur := v_count_secur + 1;
            begin
                select nvl(qtyact,0)
                  into v_qtyact
                  from treqest2
                 where numreqst = i.numreqst
                   and codpos   = i.codpos;
            exception when no_data_found then
                v_qtyact := 0;
            end;
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
            obj_data.put('qtyact', v_qtyact);

            v_exp := nvl(i.amtpay / nullif(v_qtyact,0),0);
            obj_data.put('costp', v_exp);
            v_total := nvl((v_qtyact * v_exp),0);
            obj_data.put('costtoal', v_total);
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;
    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TJOBPOST');
    end if;

    if param_msg_error is null then
        insert_graph_codcomp;
        insert_graph_codpos;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

  end gen_index_old;


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

END HRRC91X;

/
