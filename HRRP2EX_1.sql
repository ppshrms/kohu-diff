--------------------------------------------------------
--  DDL for Package Body HRRP2EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2EX" as
  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_dteyrbug    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;

  procedure check_index is
    v_cnt   number := 0;
  begin
    if b_index_dteyrbug is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    begin
      select nvl(sum(nvl(qtytotrc,0)) + sum(nvl(qtytotre,0)) ,0)
      into  v_cnt 
      from  tmanpwm
      where dteyrbug = b_index_dteyrbug
      and   codcomp  like b_index_codcomp||'%';
    end;    
    if v_cnt = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tmanpwm');   
      return;
    end if; ----
  end check_index;

  procedure get_index_table1(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;   
    if param_msg_error is null then
      gen_index_table1(json_str_output);
      gen_graph;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_table2(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;   
    if param_msg_error is null then
      gen_index_table2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index_table1(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';

    v_col           number := 0;
    v_cntemp        number := 0;

    v_sum1          number := 0;
    v_sum2          number := 0;
    v_sum3          number := 0;
    v_sum4          number := 0;
    v_sum5          number := 0;
    v_sum6          number := 0;
    v_sum7          number := 0;
    v_sum8          number := 0;
    v_sum9          number := 0;
    v_sum10         number := 0;
    v_sum11         number := 0;
    v_sum12         number := 0;
    v_numseq        number := 0;

    cursor c1 is
        select codpos,
        --New Employee
        sum(decode(dtemthbug,1,qtytotrc,0)) recruit1,
        sum(decode(dtemthbug,2,qtytotrc,0)) recruit2,
        sum(decode(dtemthbug,3,qtytotrc,0)) recruit3,
        sum(decode(dtemthbug,4,qtytotrc,0)) recruit4,
        sum(decode(dtemthbug,5,qtytotrc,0)) recruit5,
        sum(decode(dtemthbug,6,qtytotrc,0)) recruit6,
        sum(decode(dtemthbug,7,qtytotrc,0)) recruit7,
        sum(decode(dtemthbug,8,qtytotrc,0)) recruit8,
        sum(decode(dtemthbug,9,qtytotrc,0)) recruit9,
        sum(decode(dtemthbug,10,qtytotrc,0)) recruit10,
        sum(decode(dtemthbug,11,qtytotrc,0)) recruit11,
        sum(decode(dtemthbug,12,qtytotrc,0)) recruit12
        from  tmanpwm
        where dteyrbug = b_index_dteyrbug
        and   codcomp  like b_index_codcomp||'%'
        group by codpos
        having sum(nvl(qtytotrc,0)) > 0 ----
        order by codpos;
  begin
      BEGIN
          DELETE ttemprpt
           WHERE codempid = global_v_codempid
             AND codapp = 'HRRP2EX1';
      EXCEPTION WHEN OTHERS THEN
        NULL;
      END;

    INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                           item2, item3)
                  VALUES ( global_v_codempid, 'HRRP2EX1', 1, 'DETAIL',
                           hcm_util.get_year_buddhist_era(b_index_dteyrbug), b_index_codcomp);

    begin
        select nvl(max(numseq),0)
          into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRRP2EX1'
           /*AND ITEM1 in ('TABLE1','TABLE2')*/;
    exception when others then
        v_numseq := 0;
    end;
    v_numseq := nvl(v_numseq,0) + 1;
    obj_row := json_object_t();
    --New Employee--
    for r1 in c1 loop
        v_flgdata := 'Y';
      --if true then -- check secur7
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        --obj_data.put('flgdata', '1');
        --obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('jan', to_char(r1.recruit1,'fm9,999,990'));
        obj_data.put('feb', to_char(r1.recruit2,'fm9,999,990'));
        obj_data.put('mar', to_char(r1.recruit3,'fm9,999,990'));
        obj_data.put('apr', to_char(r1.recruit4,'fm9,999,990'));
        obj_data.put('may', to_char(r1.recruit5,'fm9,999,990'));
        obj_data.put('jun', to_char(r1.recruit6,'fm9,999,990'));
        obj_data.put('jul', to_char(r1.recruit7,'fm9,999,990'));
        obj_data.put('aug', to_char(r1.recruit8,'fm9,999,990'));
        obj_data.put('sep', to_char(r1.recruit9,'fm9,999,990'));
        obj_data.put('oct', to_char(r1.recruit10,'fm9,999,990'));
        obj_data.put('nov', to_char(r1.recruit11,'fm9,999,990'));
        obj_data.put('dec', to_char(r1.recruit12,'fm9,999,990'));

        obj_row.put(to_char(v_rcnt-1),obj_data);
        --summary--
        v_sum1 := v_sum1 + r1.recruit1;
        v_sum2 := v_sum2 + r1.recruit2;
        v_sum3 := v_sum3 + r1.recruit3;
        v_sum4 := v_sum4 + r1.recruit4;
        v_sum5 := v_sum5 + r1.recruit5;
        v_sum6 := v_sum6 + r1.recruit6;
        v_sum7 := v_sum7 + r1.recruit7;
        v_sum8 := v_sum8 + r1.recruit8;
        v_sum9 := v_sum9 + r1.recruit9;
        v_sum10 := v_sum10 + r1.recruit10;
        v_sum11 := v_sum11 + r1.recruit11;
        v_sum12 := v_sum12 + r1.recruit12;

        INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                               item2, item3,
                               item4,
                               item5, item6, item7, item8, item9,item10,
                               item11,item12, item13,item14,item15,item16)
                      VALUES ( global_v_codempid, 'HRRP2EX1', v_numseq, 'TABLE1',
                               hcm_util.get_year_buddhist_era(b_index_dteyrbug), b_index_codcomp,
                               get_tpostn_name(r1.codpos,global_v_lang),
                               to_char(r1.recruit1,'fm9,999,990'), to_char(r1.recruit2,'fm9,999,990'), to_char(r1.recruit3,'fm9,999,990'), to_char(r1.recruit4,'fm9,999,990'), to_char(r1.recruit5,'fm9,999,990'), to_char(r1.recruit6,'fm9,999,990'),
                               to_char(r1.recruit7,'fm9,999,990'), to_char(r1.recruit8,'fm9,999,990'), to_char(r1.recruit9,'fm9,999,990'), to_char(r1.recruit10,'fm9,999,990'), to_char(r1.recruit11,'fm9,999,990'), to_char(r1.recruit12,'fm9,999,990'));
        v_numseq := v_numseq + 1;
      --end if;
    end loop;
    --Summary recruit--
    v_rcnt := v_rcnt + 1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    --obj_data.put('flgdata', '3');
    --obj_data.put('codpos', r1.codpos);
    obj_data.put('desc_codpos', get_label_name('HRRP2EXC1', global_v_lang, '200'));
    obj_data.put('jan', to_char(v_sum1,'fm9,999,990'));
    obj_data.put('feb', to_char(v_sum2,'fm9,999,990'));
    obj_data.put('mar', to_char(v_sum3,'fm9,999,990'));
    obj_data.put('apr', to_char(v_sum4,'fm9,999,990'));
    obj_data.put('may', to_char(v_sum5,'fm9,999,990'));
    obj_data.put('jun', to_char(v_sum6,'fm9,999,990'));
    obj_data.put('jul', to_char(v_sum7,'fm9,999,990'));
    obj_data.put('aug', to_char(v_sum8,'fm9,999,990'));
    obj_data.put('sep', to_char(v_sum9,'fm9,999,990'));
    obj_data.put('oct', to_char(v_sum10,'fm9,999,990'));
    obj_data.put('nov', to_char(v_sum11,'fm9,999,990'));
    obj_data.put('dec', to_char(v_sum12,'fm9,999,990'));

    obj_row.put(to_char(v_rcnt-1),obj_data);
    INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                           item2, item3, item4,
                           item5, item6, item7, item8, item9,item10,
                           item11,item12, item13,item14,item15,item16)
                  VALUES ( global_v_codempid, 'HRRP2EX1', v_numseq, 'TABLE1',
                           hcm_util.get_year_buddhist_era(b_index_dteyrbug), b_index_codcomp, get_label_name('HRRP2EXC1', global_v_lang, '200'),
                           to_char(v_sum1,'fm9,999,990'), to_char(v_sum2,'fm9,999,990'), to_char(v_sum3,'fm9,999,990'), to_char(v_sum4,'fm9,999,990'), to_char(v_sum5,'fm9,999,990'), to_char(v_sum6,'fm9,999,990'),
                           to_char(v_sum7,'fm9,999,990'), to_char(v_sum8,'fm9,999,990'), to_char(v_sum9,'fm9,999,990'), to_char(v_sum10,'fm9,999,990'), to_char(v_sum11,'fm9,999,990'), to_char(v_sum12,'fm9,999,990'));
    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else 
--      json_str_output := obj_row.to_clob; ----Total
      param_msg_error := null; ----No msg ||get_error_msg_php('HR2055', global_v_lang, 'tmanpwm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

  procedure gen_index_table2(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';

    v_col           number := 0;
    v_cntemp        number := 0;

    v_sum1          number := 0;
    v_sum2          number := 0;
    v_sum3          number := 0;
    v_sum4          number := 0;
    v_sum5          number := 0;
    v_sum6          number := 0;
    v_sum7          number := 0;
    v_sum8          number := 0;
    v_sum9          number := 0;
    v_sum10         number := 0;
    v_sum11         number := 0;
    v_sum12         number := 0;
    v_numseq        number := 0;

    cursor c1 is
        select codpos,
        --Resign Employee
        sum(decode(dtemthbug,1,qtytotre,0)) resign1,
        sum(decode(dtemthbug,2,qtytotre,0)) resign2,
        sum(decode(dtemthbug,3,qtytotre,0)) resign3,
        sum(decode(dtemthbug,4,qtytotre,0)) resign4,
        sum(decode(dtemthbug,5,qtytotre,0)) resign5,
        sum(decode(dtemthbug,6,qtytotre,0)) resign6,
        sum(decode(dtemthbug,7,qtytotre,0)) resign7,
        sum(decode(dtemthbug,8,qtytotre,0)) resign8,
        sum(decode(dtemthbug,9,qtytotre,0)) resign9,
        sum(decode(dtemthbug,10,qtytotre,0)) resign10,
        sum(decode(dtemthbug,11,qtytotre,0)) resign11,
        sum(decode(dtemthbug,12,qtytotre,0)) resign12
        from  tmanpwm
        where dteyrbug = b_index_dteyrbug
        and   codcomp  like b_index_codcomp||'%'
        group by codpos
        having sum(nvl(qtytotre,0)) > 0 ----
        order by codpos;
  begin

    begin
        select nvl(max(numseq),0)
          into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRRP2EX1';
    exception when others then
        v_numseq := 0;
    end;
    v_numseq := nvl(v_numseq,0) + 1;

    obj_row := json_object_t();

    --Resign Employee--
    for r1 in c1 loop
      v_flgdata := 'Y';
      --if true then -- check secur7
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        --obj_data.put('flgdata', '2');
        --obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('jan', to_char(r1.resign1,'fm9,999,990'));
        obj_data.put('feb', to_char(r1.resign2,'fm9,999,990'));
        obj_data.put('mar', to_char(r1.resign3,'fm9,999,990'));
        obj_data.put('apr', to_char(r1.resign4,'fm9,999,990'));
        obj_data.put('may', to_char(r1.resign5,'fm9,999,990'));
        obj_data.put('jun', to_char(r1.resign6,'fm9,999,990'));
        obj_data.put('jul', to_char(r1.resign7,'fm9,999,990'));
        obj_data.put('aug', to_char(r1.resign8,'fm9,999,990'));
        obj_data.put('sep', to_char(r1.resign9,'fm9,999,990'));
        obj_data.put('oct', to_char(r1.resign10,'fm9,999,990'));
        obj_data.put('nov', to_char(r1.resign11,'fm9,999,990'));
        obj_data.put('dec', to_char(r1.resign12,'fm9,999,990'));

        obj_row.put(to_char(v_rcnt-1),obj_data);
        --summary--
        v_sum1 := v_sum1 + r1.resign1;
        v_sum2 := v_sum2 + r1.resign2;
        v_sum3 := v_sum3 + r1.resign3;
        v_sum4 := v_sum4 + r1.resign4;
        v_sum5 := v_sum5 + r1.resign5;
        v_sum6 := v_sum6 + r1.resign6;
        v_sum7 := v_sum7 + r1.resign7;
        v_sum8 := v_sum8 + r1.resign8;
        v_sum9 := v_sum9 + r1.resign9;
        v_sum10 := v_sum10 + r1.resign10;
        v_sum11 := v_sum11 + r1.resign11;
        v_sum12 := v_sum12 + r1.resign12;

        INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                               item2, item3,
                               item4,
                               item5, item6, item7, item8, item9,item10,
                               item11,item12, item13,item14,item15,item16)
                      VALUES ( global_v_codempid, 'HRRP2EX1', v_numseq, 'TABLE2',
                               hcm_util.get_year_buddhist_era(b_index_dteyrbug), b_index_codcomp,
                               get_tpostn_name(r1.codpos,global_v_lang),
                               to_char(r1.resign1,'fm9,999,990'), to_char(r1.resign2,'fm9,999,990'), to_char(r1.resign3,'fm9,999,990'), to_char(r1.resign4,'fm9,999,990'), to_char(r1.resign5,'fm9,999,990'), to_char(r1.resign6,'fm9,999,990'),
                               to_char(r1.resign7,'fm9,999,990'), to_char(r1.resign8,'fm9,999,990'), to_char(r1.resign9,'fm9,999,990'), to_char(r1.resign10,'fm9,999,990'), to_char(r1.resign11,'fm9,999,990'), to_char(r1.resign12,'fm9,999,990'));
        v_numseq := v_numseq + 1;


      --end if;
    end loop;
    --Summary Resign--
    v_rcnt := v_rcnt + 1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    --obj_data.put('flgdata', '1');
    --obj_data.put('codpos', r1.codpos);
    obj_data.put('desc_codpos', get_label_name('HRRP2EXC1', global_v_lang, '200'));
    obj_data.put('jan', to_char(v_sum1,'fm9,999,990'));
    obj_data.put('feb', to_char(v_sum2,'fm9,999,990'));
    obj_data.put('mar', to_char(v_sum3,'fm9,999,990'));
    obj_data.put('apr', to_char(v_sum4,'fm9,999,990'));
    obj_data.put('may', to_char(v_sum5,'fm9,999,990'));
    obj_data.put('jun', to_char(v_sum6,'fm9,999,990'));
    obj_data.put('jul', to_char(v_sum7,'fm9,999,990'));
    obj_data.put('aug', to_char(v_sum8,'fm9,999,990'));
    obj_data.put('sep', to_char(v_sum9,'fm9,999,990'));
    obj_data.put('oct', to_char(v_sum10,'fm9,999,990'));
    obj_data.put('nov', to_char(v_sum11,'fm9,999,990'));
    obj_data.put('dec', to_char(v_sum12,'fm9,999,990'));

    obj_row.put(to_char(v_rcnt-1),obj_data);

    INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                           item2, item3, item4,
                           item5, item6, item7, item8, item9,item10,
                           item11,item12, item13,item14,item15,item16)
                  VALUES ( global_v_codempid, 'HRRP2EX1', v_numseq, 'TABLE2',
                           hcm_util.get_year_buddhist_era(b_index_dteyrbug), b_index_codcomp, get_label_name('HRRP2EXC1', global_v_lang, '200'),
                           to_char(v_sum1,'fm9,999,990'), to_char(v_sum2,'fm9,999,990'), to_char(v_sum3,'fm9,999,990'), to_char(v_sum4,'fm9,999,990'), to_char(v_sum5,'fm9,999,990'), to_char(v_sum6,'fm9,999,990'),
                           to_char(v_sum7,'fm9,999,990'), to_char(v_sum8,'fm9,999,990'), to_char(v_sum9,'fm9,999,990'), to_char(v_sum10,'fm9,999,990'), to_char(v_sum11,'fm9,999,990'), to_char(v_sum12,'fm9,999,990'));
    if v_flgdata = 'Y' then
      if v_flgsecur = 'Y' then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else 
--      json_str_output := obj_row.to_clob; ----Total
      param_msg_error := null; ----No msg ||get_error_msg_php('HR2055', global_v_lang, 'tmanpwm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRRP2EX';
    v_numseq    ttemprpt.numseq%type := 1;
    v_item1     ttemprpt.item1%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item14    ttemprpt.item14%type;
    v_item31    ttemprpt.item31%type;

    v_flgdata   varchar2(1 char) := 'N';
    v_cntemp    number;

    cursor c1 is
        select
        --New Employee
        sum(decode(dtemthbug,1,qtytotrc,0)) recruit1,
        sum(decode(dtemthbug,2,qtytotrc,0)) recruit2,
        sum(decode(dtemthbug,3,qtytotrc,0)) recruit3,
        sum(decode(dtemthbug,4,qtytotrc,0)) recruit4,
        sum(decode(dtemthbug,5,qtytotrc,0)) recruit5,
        sum(decode(dtemthbug,6,qtytotrc,0)) recruit6,
        sum(decode(dtemthbug,7,qtytotrc,0)) recruit7,
        sum(decode(dtemthbug,8,qtytotrc,0)) recruit8,
        sum(decode(dtemthbug,9,qtytotrc,0)) recruit9,
        sum(decode(dtemthbug,10,qtytotrc,0)) recruit10,
        sum(decode(dtemthbug,11,qtytotrc,0)) recruit11,
        sum(decode(dtemthbug,12,qtytotrc,0)) recruit12,
        --Resign Employee
        sum(decode(dtemthbug,1,qtytotre,0)) resign1,
        sum(decode(dtemthbug,2,qtytotre,0)) resign2,
        sum(decode(dtemthbug,3,qtytotre,0)) resign3,
        sum(decode(dtemthbug,4,qtytotre,0)) resign4,
        sum(decode(dtemthbug,5,qtytotre,0)) resign5,
        sum(decode(dtemthbug,6,qtytotre,0)) resign6,
        sum(decode(dtemthbug,7,qtytotre,0)) resign7,
        sum(decode(dtemthbug,8,qtytotre,0)) resign8,
        sum(decode(dtemthbug,9,qtytotre,0)) resign9,
        sum(decode(dtemthbug,10,qtytotre,0)) resign10,
        sum(decode(dtemthbug,11,qtytotre,0)) resign11,
        sum(decode(dtemthbug,12,qtytotre,0)) resign12
        from  tmanpwm
        where dteyrbug = b_index_dteyrbug
        and   codcomp  like b_index_codcomp||'%';

  begin
    param_msg_error := null;
    begin
      delete from ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
      return;
    end;

    v_item31 := get_label_name('HRRP2EXC2', global_v_lang, '40');

    for v_emptype in 1..2 loop
        v_flgdata := 'Y';
        for r1 in c1 loop
            for v_month in 1..12 loop
                ----------Axis X level 2(from data column)
                v_item7  := v_emptype;
                if v_emptype = 1 then --new emp
                    v_item8  := get_label_name('HRRP2EXC2', global_v_lang, '10'); --พนักงานเข้าใหม่
                else --v_emptype = 2 then --resign emp
                    v_item8  := get_label_name('HRRP2EXC2', global_v_lang, '20'); --พนักงานลาออก
                end if;
                v_item6  := hcm_util.get_year_buddhist_era(b_index_dteyrbug);
                ----------Axis X level 1(from data row)
                v_item4  := lpad(v_month, 2, '0');
                v_item5  := get_tlistval_name('NAMMTHABB', v_month, global_v_lang);
                ----------Axis Y Label
                v_item9  := get_label_name('HRRP2EXC2', global_v_lang, '30'); --จำนวนพนักงาน
                ----------Data in table
                if v_emptype = 1 then --new emp
                    if v_month    = 1 then v_item10  := r1.recruit1;
                    elsif v_month = 2 then v_item10  := r1.recruit2;
                    elsif v_month = 3 then v_item10  := r1.recruit3;
                    elsif v_month = 4 then v_item10  := r1.recruit4;
                    elsif v_month = 5 then v_item10  := r1.recruit5;
                    elsif v_month = 6 then v_item10  := r1.recruit6;
                    elsif v_month = 7 then v_item10  := r1.recruit7;
                    elsif v_month = 8 then v_item10  := r1.recruit8;
                    elsif v_month = 9 then v_item10  := r1.recruit9;
                    elsif v_month = 10 then v_item10 := r1.recruit10;
                    elsif v_month = 11 then v_item10 := r1.recruit11;
                    elsif v_month = 12 then v_item10 := r1.recruit12;
                    end if;
                else --v_emptype = 2 then --resign emp
                    if v_month    = 1 then v_item10  := r1.resign1;
                    elsif v_month = 2 then v_item10  := r1.resign2;
                    elsif v_month = 3 then v_item10  := r1.resign3;
                    elsif v_month = 4 then v_item10  := r1.resign4;
                    elsif v_month = 5 then v_item10  := r1.resign5;
                    elsif v_month = 6 then v_item10  := r1.resign6;
                    elsif v_month = 7 then v_item10  := r1.resign7;
                    elsif v_month = 8 then v_item10  := r1.resign8;
                    elsif v_month = 9 then v_item10  := r1.resign9;
                    elsif v_month = 10 then v_item10 := r1.resign10;
                    elsif v_month = 11 then v_item10 := r1.resign11;
                    elsif v_month = 12 then v_item10 := r1.resign12;
                    end if;
                end if; --v_emptype
                ----------Insert ttemprpt
                begin
                  insert into ttemprpt
                    (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
                  values
                    (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14 );
                exception when dup_val_on_index then
                  rollback;
                  param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                  return;
                end;
                v_numseq := v_numseq + 1;
            end loop; --month
        end loop; --c1
    end loop; --new emp/resign emp

    commit;

    if v_numseq > 1 then
        param_msg_error := get_error_msg_php('HR2720', global_v_lang);
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tmanpwm');
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/
