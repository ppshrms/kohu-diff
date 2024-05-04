--------------------------------------------------------
--  DDL for Package Body HRRPSAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRPSAX" AS
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    logic			json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_zyear      := hcm_appsettings.get_additional_year() ;
    --block b_index
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_dteyear1    := hcm_util.get_string_t(json_obj,'p_dteyear1');
    b_index_dteyear2    := hcm_util.get_string_t(json_obj,'p_dteyear2');
    b_index_dteyear3    := hcm_util.get_string_t(json_obj,'p_dteyear3');
    b_index_dteyear4    := hcm_util.get_string_t(json_obj,'p_dteyear4');
    b_index_dteyear5    := hcm_util.get_string_t(json_obj,'p_dteyear5');
    b_index_dteyear6    := hcm_util.get_string_t(json_obj,'p_dteyear6');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    obj_result   json_object_t;

    v_rcnt        number := 0;
    v_cyear       number := 0;
    v_datarow1    number(9,2) := 0;
    v_datarow2    number(9,2) := 0;
    v_datarow3    number(9,2) := 0;
    v_datarow4    number(9,2) := 0;
    v_datarow5    number(9,2) := 0;

    v_qtyexman    number(9,2) := 0;
    v_percntemp   number(9,2) := 0;
    v_percntex    number(9,2) := 0;
    v_flgdata     varchar2(10 char) := 'N';
    v_qtytotrc    number(4,2) := 0;
    v_qtytotrf    number(4,2) := 0;

    v_idx         number := 0;
    cursor c1 is
      select a.dteyrbug, sum(a.qtytotrc) qtytotrc, sum(a.qtytotrf) qtytotrf, sum(a.qtytotre) qtytotre, sum(a.qtytotro) qtytotro
        from tmanpw a
       where hcm_util.get_codcomp_level(codcomp,1) = b_index_codcompy
         and dteyrbug in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3, b_index_dteyear4, b_index_dteyear5, b_index_dteyear6)
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp like a.codcompy||'%')
       group by dteyrbug
       order by dteyrbug;
  begin
    for r1 in c1 loop
      v_flgdata := 'Y';
      exit;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tmanpw');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    obj_row := json_object_t();
    begin
      delete
        from ttemprpt
       where codapp = 'HRRPSAX'
         and codempid = global_v_codempid;
    end;
    -- gen data case by case from input on screen
    for j in 1..5 loop
      v_rcnt := v_rcnt + 1;
      v_cyear := 1;
      if j = 1 then
        obj_data := json_object_t();
        obj_data.put('detail', get_label_name('HRRPSAX2', global_v_lang, '90'));
        if b_index_dteyear1 is not null then
          v_datarow1 := get_data_row1(b_index_dteyear1);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow1,0));
          v_cyear := v_cyear + 1;

        end if;
        if b_index_dteyear2 is not null then
          v_datarow1 := get_data_row1(b_index_dteyear2);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow1,0));
          v_cyear := v_cyear + 1;
        end if;
        if b_index_dteyear3 is not null then
          v_datarow1 := get_data_row1(b_index_dteyear3);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow1,0));
          v_cyear := v_cyear + 1;
        end if;
        if b_index_dteyear4 is not null then
          v_datarow1 := get_data_row1(b_index_dteyear4);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow1,0));
          v_cyear := v_cyear + 1;
        end if;
        if b_index_dteyear5 is not null then
          v_datarow1 := get_data_row1(b_index_dteyear5);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow1,0));
          v_cyear := v_cyear + 1;
        end if;
        if b_index_dteyear6 is not null then
          v_datarow1 := get_data_row1(b_index_dteyear6);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow1,0));
          v_cyear := v_cyear + 1;
        end if;
      elsif j = 2 then
        obj_data := json_object_t();
        obj_data.put('detail', get_label_name('HRRPSAX2', global_v_lang, '120'));
        if b_index_dteyear1 is not null then
          v_datarow2 := get_data_row2(b_index_dteyear1);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow2,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear1 + global_v_zyear), (b_index_dteyear1 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,70), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow2,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear2 is not null then
          v_datarow2 := get_data_row2(b_index_dteyear2);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow2,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear2 + global_v_zyear), (b_index_dteyear2 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,70), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow2,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear3 is not null then
          v_datarow2 := get_data_row2(b_index_dteyear3);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow2,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear3 + global_v_zyear), (b_index_dteyear3 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,70), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow2,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear4 is not null then
          v_datarow2 := get_data_row2(b_index_dteyear4);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow2,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear4 + global_v_zyear), (b_index_dteyear4 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,70), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow2,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear5 is not null then
          v_datarow2 := get_data_row2(b_index_dteyear5);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow2,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear5 + global_v_zyear), (b_index_dteyear5 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,70), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow2,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear6 is not null then
          v_datarow2 := get_data_row2(b_index_dteyear6);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow2,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear6 + global_v_zyear), (b_index_dteyear6 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,70), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow2,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
      elsif j = 3 then
        obj_data := json_object_t();
        obj_data.put('detail', get_label_name('HRRPSAX2', global_v_lang, '140'));
        if b_index_dteyear1 is not null then
          v_datarow3 := get_data_row3(b_index_dteyear1);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow3,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear1 + global_v_zyear), (b_index_dteyear1 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,140), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow3,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear2 is not null then
          v_datarow3 := get_data_row3(b_index_dteyear2);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow3,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear2 + global_v_zyear), (b_index_dteyear2 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,140), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow3,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear3 is not null then
          v_datarow3 := get_data_row3(b_index_dteyear3);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow3,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear3 + global_v_zyear), (b_index_dteyear3 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,140), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow3,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear4 is not null then
          v_datarow3 := get_data_row3(b_index_dteyear4);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow3,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear4 + global_v_zyear), (b_index_dteyear4 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,140), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow3,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear5 is not null then
          v_datarow3 := get_data_row3(b_index_dteyear5);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow3,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear5 + global_v_zyear), (b_index_dteyear5 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,140), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow3,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear6 is not null then
          v_datarow3 := get_data_row3(b_index_dteyear6);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow3,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear6 + global_v_zyear), (b_index_dteyear6 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,140), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow3,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
      elsif j = 4 then
        obj_data := json_object_t();
        obj_data.put('detail', get_label_name('HRRPSAX2', global_v_lang, '130'));
        if b_index_dteyear1 is not null then
          v_datarow4 := get_data_row4(b_index_dteyear1);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow4,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear1 + global_v_zyear), (b_index_dteyear1 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,80), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow4,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear2 is not null then
          v_datarow4 := get_data_row4(b_index_dteyear2);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow4,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear2 + global_v_zyear), (b_index_dteyear2 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,80), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow4,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear3 is not null then
          v_datarow4 := get_data_row4(b_index_dteyear3);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow4,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear3 + global_v_zyear), (b_index_dteyear3 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,80), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow4,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear4 is not null then
          v_datarow4 := get_data_row4(b_index_dteyear4);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow4,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear4 + global_v_zyear), (b_index_dteyear4 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,80), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow4,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear5 is not null then
          v_datarow4 := get_data_row4(b_index_dteyear5);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow4,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear5 + global_v_zyear), (b_index_dteyear5 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,80), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow4,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear6 is not null then
          v_datarow4 := get_data_row4(b_index_dteyear6);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow4,0));
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), (b_index_dteyear6 + global_v_zyear), (b_index_dteyear6 + global_v_zyear),
                  get_label_name('HRRPSAX1',global_v_lang,80), get_label_name('HRRPSAX1',global_v_lang,60),
                  v_datarow4,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
      elsif j = 5 then
        obj_data := json_object_t();
        obj_data.put('detail', get_label_name('HRRPSAX2', global_v_lang, '150'));
        if b_index_dteyear1 is not null then
          v_datarow5 := get_data_row5(b_index_dteyear1);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow5,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear1 + global_v_zyear), (b_index_dteyear1 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,150), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow5,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear2 is not null then
          v_datarow5 := get_data_row5(b_index_dteyear2);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow5,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear2 + global_v_zyear), (b_index_dteyear2 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,150), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow5,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear3 is not null then
          v_datarow5 := get_data_row5(b_index_dteyear3);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow5,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear3 + global_v_zyear), (b_index_dteyear3 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,150), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow5,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear4 is not null then
          v_datarow5 := get_data_row5(b_index_dteyear4);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow5,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear4 + global_v_zyear), (b_index_dteyear4 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,150), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow5,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear5 is not null then
          v_datarow5 := get_data_row5(b_index_dteyear5);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow5,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear5 + global_v_zyear), (b_index_dteyear5 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,150), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow5,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
        if b_index_dteyear6 is not null then
          v_datarow5 := get_data_row5(b_index_dteyear6);
          obj_data.put('dteyear'||v_cyear, nvl(v_datarow5,0)||'%');
          v_cyear := v_cyear + 1;

          -- gen graph case by case from input on screen
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item4, item5,
                      item8,item9, item10, item31)
          values (global_v_codempid, 'HRRPSAX', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), (b_index_dteyear6 + global_v_zyear), (b_index_dteyear6 + global_v_zyear),
                  get_label_name('HRRPSAX2',global_v_lang,150), get_label_name('HRRPSAX2',global_v_lang,80),
                  v_datarow5,get_label_name('HRRPSAX1',global_v_lang,50) );
        end if;
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('rows',obj_row);
      json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure check_index is
    v_codcompy  tcompny.codcompy%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';

  begin
     if b_index_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      begin
        select codcompy into v_codcompy
        from tcompny
        where codcompy = b_index_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
      end;
      if not secur_main.secur7(b_index_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if b_index_dteyear1 > to_char(sysdate,'yyyy') or
       b_index_dteyear2 > to_char(sysdate,'yyyy') or
       b_index_dteyear3 > to_char(sysdate,'yyyy') or
       b_index_dteyear4 > to_char(sysdate,'yyyy') or
       b_index_dteyear5 > to_char(sysdate,'yyyy') or
       b_index_dteyear6 > to_char(sysdate,'yyyy') then
      param_msg_error := get_error_msg_php('HR4509',global_v_lang);
      return;
    end if;
  end;

  function get_data_row1(v_year in varchar2) return number is
    v_qtyexman    number(9,2) := 0;
  begin
    begin
       select round(avg(b.qtyexman)) into v_qtyexman --จำนวน พนักงาน เฉลี่ย
         from tmanpwm b
        where hcm_util.get_codcomp_level(b.codcomp,1) = b_index_codcompy
          and b.dteyrbug = v_year
          and exists (select codcomp
                        from tusrcom x
                       where x.coduser = global_v_coduser
                         and b.codcomp like x.codcomp||'%');
    exception when others then
      v_qtyexman := null;
    end;
    return v_qtyexman;
  end get_data_row1;
  --
  function get_data_row2(v_year in varchar2) return number is
    v_qtytotrc    number(9,2) := 0;
    v_qtytotrf    number(9,2) := 0;
    v_dteyrbug    tmanpw.dteyrbug%type;
    v_sum         number(9,2) := 0;
  begin
    begin
      select a.dteyrbug, sum(a.qtytotrc) qtytotrc, sum(a.qtytotrf) qtytotrf
        into v_dteyrbug,v_qtytotrc, v_qtytotrf
        from tmanpw a
       where hcm_util.get_codcomp_level(codcomp,1) = b_index_codcompy
         and dteyrbug = v_year
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp like a.codcompy||'%')
       group by dteyrbug
       order by dteyrbug;
      v_sum := v_qtytotrc + v_qtytotrf;  --กำลังคนที่รับใหม่ทั้งหมด + กำลังคนที่โอนเข้าทั้งหมด--<< user25 date: 09/09/2021 #4603 #4606


----#3531       v_sum := v_qtytotrc + v_qtytotrf;  --กำลังคนที่รับใหม่ทั้งหมด + กำลังคนที่โอนเข้าทั้งหมด
--       v_sum := v_qtytotrc;  --กำลังคนที่รับใหม่ทั้งหมด
----#3531

    exception when no_data_found then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      v_sum := 0;
    end;

    return v_sum;
  end get_data_row2;
  --
  function get_data_row3(v_year in varchar2) return number is
    v_qtyexman    number(9,2) := 0;
    v_qtytotrc    number(9,2) := 0;
    v_qtytotrf    number(9,2) := 0;
    v_dteyrbug    tmanpw.dteyrbug%type;
    v_sum         number(9,2) := 0;
    v_percntemp   number(9,2) := 0;
  begin
    begin
     select nvl(round(avg(b.qtyexman)),0) into v_qtyexman --จำนวน พนักงาน เฉลี่ย
       from tmanpwm b
      where hcm_util.get_codcomp_level(b.codcomp,1) = b_index_codcompy
        and b.dteyrbug = v_year
        and exists (select codcomp
                      from tusrcom x
                     where x.coduser = global_v_coduser
                       and b.codcomp like x.codcomp||'%');
    exception when others then
      v_qtyexman := 0;
    end;
    begin
      select a.dteyrbug, sum(a.qtytotrc) qtytotrc, sum(a.qtytotrf) qtytotrf
        into v_dteyrbug,v_qtytotrc, v_qtytotrf
        from tmanpw a
       where hcm_util.get_codcomp_level(codcomp,1) = b_index_codcompy
         and dteyrbug = v_year
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp like a.codcompy||'%')
       group by dteyrbug
       order by dteyrbug;
     v_sum := v_qtytotrc + v_qtytotrf;  --กำลังคนที่รับใหม่ทั้งหมด + กำลังคนที่โอนเข้าทั้งหมด--<< user25 date: 09/09/2021 #4603 #4606



----#3531       v_sum := v_qtytotrc + v_qtytotrf;  --กำลังคนที่รับใหม่ทั้งหมด + กำลังคนที่โอนเข้าทั้งหมด
--       v_sum := v_qtytotrc;  --กำลังคนที่รับใหม่ทั้งหมด
----#3531
    exception when no_data_found then
      v_sum := 0;
    end;
    if v_qtyexman > 0 then
      v_percntemp := (v_sum * 100) / v_qtyexman;
    else
      v_percntemp := 0;
    end if;
    return v_percntemp;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end get_data_row3;
  function get_data_row4(v_year in varchar2) return number is
    v_qtytotre    number(9,2) := 0;
    v_qtytotro    number(9,2) := 0;
    v_dteyrbug    tmanpw.dteyrbug%type;
    v_sum         number(9,2) := 0;
  begin
    begin
      select a.dteyrbug, sum(a.qtytotre) qtytotre, sum(a.qtytotro) qtytotro
        into v_dteyrbug,v_qtytotre, v_qtytotro
        from tmanpw a
       where hcm_util.get_codcomp_level(codcomp,1) = b_index_codcompy
         and dteyrbug = v_year
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp like a.codcompy||'%')
       group by dteyrbug
       order by dteyrbug;
       v_sum := v_qtytotre + v_qtytotro;  --กำลังคนที่ลาออก + กำลังคนที่โอนออก--<< user25 date: 09/09/2021 #4603 #4606


----#3531       v_sum := v_qtytotre + v_qtytotro;  --กำลังคนที่ลาออก + กำลังคนที่โอนออก
--       v_sum := v_qtytotre;  --กำลังคนที่ลาออก
----#3531

    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      v_sum := null;
    end;
    return v_sum;
  end get_data_row4;
  function get_data_row5(v_year in varchar2) return number is
    v_qtyexman    number(9,2) := 0;
    v_qtytotre    number(9,2) := 0;
    v_qtytotro    number(9,2) := 0;
    v_dteyrbug    tmanpw.dteyrbug%type;
    v_sum         number(9,2) := 0;
    v_percntex   number(9,2) := 0;
  begin
    begin
     select nvl(round(avg(b.qtyexman)),0) into v_qtyexman --จำนวน พนักงาน เฉลี่ย
       from tmanpwm b
      where hcm_util.get_codcomp_level(b.codcomp,1) = b_index_codcompy
        and b.dteyrbug = v_year
        and exists (select codcomp
                      from tusrcom x
                     where x.coduser = global_v_coduser
                       and b.codcomp like x.codcomp||'%');
    exception when others then
      v_qtyexman := 0;
    end;
    begin
      select a.dteyrbug, sum(a.qtytotre) qtytotre, sum(a.qtytotro) qtytotro
        into v_dteyrbug,v_qtytotre, v_qtytotro
        from tmanpw a
       where hcm_util.get_codcomp_level(codcomp,1) = b_index_codcompy
         and dteyrbug = v_year
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp like a.codcompy||'%')
       group by dteyrbug
       order by dteyrbug;
       v_sum := v_qtytotre + v_qtytotro;  --กำลังคนที่ลาออก + กำลังคนที่โอนออก--<< user25 date: 09/09/2021 #4603 #4606


----#3531       v_sum := v_qtytotre + v_qtytotro;  --กำลังคนที่ลาออก + กำลังคนที่โอนออก
--       v_sum := v_qtytotre;  --กำลังคนที่ลาออก
----#3531
    exception when no_data_found then
      v_sum := 0;
    end;
    if v_qtyexman > 0 then
      v_percntex := (v_sum * 100) / v_qtyexman;
    else
      v_percntex := 0;
    end if;
    return v_percntex;
  end get_data_row5;
    --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail(json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    obj_children      json_object_t;
    obj_result   json_object_t;

    v_idx         number := 0;
    v_rcnt        number := 0;
    v_countmth    number := 0;
    v_countyre    number := 0;
    v_year        varchar2(10 char);
    v_datarow1    number(9,2) := 0;
    v_datarow2    number(9,2) := 0;
    v_datarow3    number(9,2) := 0;
    v_datarow4    number(9,2) := 0;
    v_datarow5    number(9,2) := 0;

    v_qtycurrent    number(9,2) := 0;
    v_qtynew    number(9,2) := 0;
    v_percennew    number(9,2) := 0;
    v_qtyout    number(9,2) := 0;
    v_percenout    number(9,2) := 0;

    v_sum_qtycurrent    number(9,2) := 0;
    v_sum_qtynew    number(9,2) := 0;
    v_sum_percennew    number(9,2) := 0;
    v_sum_qtyout    number(9,2) := 0;
    v_sum_percenout    number(9,2) := 0;
    v_qty    number(9,2) := 0;
    TYPE varArray IS varray(6) of varchar2(10 char);
    v_varArray varArray;
    v_arrayCount number;
    v_arrayData varArray;
    cursor c1 is
      select a.dtemthbug, sum(a.qtyexman) qtyexman, sum(a.qtytotrc) qtytotrc, sum(a.qtytotrf) qtytotrf,sum(a.qtytotre) qtytotre, 
      sum(a.qtytotro) qtytotro
        from tmanpwm a
       where hcm_util.get_codcomp_level(codcomp,1) = b_index_codcompy
         and dteyrbug = v_year
         and exists (select codcomp

                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and a.codcomp like x.codcomp||'%')
      group by dtemthbug
      order by dtemthbug;
  begin
    begin
      delete from ttemprpt
       where codapp = 'HRRPSAX2'
         and codempid = global_v_codempid;
    end;
    v_varArray    := varArray(b_index_dteyear1, b_index_dteyear2, b_index_dteyear3, b_index_dteyear4, b_index_dteyear5, b_index_dteyear6);
    v_arrayCount  := v_varArray.Count;

    obj_result := json_object_t();
    for i in 1..v_arrayCount loop
      v_year := v_varArray(i);
      if v_year is not null then
        obj_row := json_object_t();
        v_rcnt := 0;
        v_countyre := v_countyre + 1;
        v_sum_qtycurrent  := 0;
        v_sum_qtynew  := 0;
        v_sum_percennew  := 0;
        v_sum_qtyout  := 0;
        v_sum_percenout  := 0;
        v_qty := 0;
        v_countmth := 0;
        for r1 in c1 loop
          v_countmth := v_countmth + 1;
          v_rcnt      := v_rcnt+1;
          obj_data     := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('month', get_tlistval_name('MONTH',r1.dtemthbug,global_v_lang));
          --
          v_qtycurrent := r1.qtyexman;
          v_sum_qtycurrent := v_sum_qtycurrent + v_qtycurrent;
          obj_data.put('qtycurrent', to_char(nvl(v_qtycurrent,0), 'fm999,999,990'));
          --
     v_qtynew := r1.qtytotrc + r1.qtytotrf; --กำลังคนที่รับใหม่ทั้งหมด + กำลังคนที่โอนเข้าทั้งหมด --<< user25 date: 09/09/2021 #4603 #4606

----#3531          v_qtynew := r1.qtytotrc + r1.qtytotrf; --กำลังคนที่รับใหม่ทั้งหมด + กำลังคนที่โอนเข้าทั้งหมด
--          v_qtynew := r1.qtytotrc; --กำลังคนที่รับใหม่ทั้งหมด
----#3531

          v_sum_qtynew := v_sum_qtynew + v_qtynew;
          obj_data.put('qtynew', to_char(nvl(v_qtynew,0)));
          --
          if v_qtycurrent > 0 then
            v_percennew := (v_qtynew * 100) / v_qtycurrent;
          else
            v_percennew := 0.00;
          end if;
          v_sum_percennew := v_sum_percennew + v_percennew;
          obj_data.put('percennew', to_char(nvl(v_percennew,0),'fm990.00'));
          --
       v_qtyout := r1.qtytotre + r1.qtytotro;  --กำลังคนที่ลาออก + กำลังคนที่โอนออก --<< user25 date: 09/09/2021 #4603 #4606


----#3531          v_qtyout := r1.qtytotre + r1.qtytotro;  --กำลังคนที่ลาออก + กำลังคนที่โอนออก
--          v_qtyout := r1.qtytotre;  --กำลังคนที่ลาออก
----#3531

          v_sum_qtyout := v_sum_qtyout + v_qtyout;
          obj_data.put('qtyout', to_char(nvl(v_qtyout,0)));
          --
          if v_qtycurrent > 0 then
            v_percenout := (v_qtyout * 100) / v_qtycurrent;
          else
            v_percenout := 0.00;
          end if;
          v_sum_percenout := v_sum_percenout + v_percenout;
          obj_data.put('percenout', to_char(nvl(v_percenout,0),'fm990.00'));

          obj_row.put(to_char(v_rcnt-1),obj_data);


          -- gen graph case by case from input on screen (QTY)
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item2,
                      item4, item5,
                      item8,item9,
                      item10, item31)
          values (global_v_codempid, 'HRRPSAX2', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), 
                  v_year + global_v_zyear,
                  r1.dtemthbug, 
                  get_tlistval_name('MONTH',r1.dtemthbug,global_v_lang),
                  get_label_name('HRRPSAX1',global_v_lang,70), get_label_name('HRRPSAX1',global_v_lang,60),
                  to_char(nvl(v_qtynew,0)), get_label_name('HRRPSAX1',global_v_lang,50) );

          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item2,
                      item4, item5,
                      item8,item9,
                      item10, item31)
          values (global_v_codempid, 'HRRPSAX2', v_idx,
                  get_label_name('HRRPSAX1',global_v_lang,60), v_year + global_v_zyear,
                  r1.dtemthbug, get_tlistval_name('MONTH',r1.dtemthbug,global_v_lang),
                  get_label_name('HRRPSAX1',global_v_lang,80), get_label_name('HRRPSAX1',global_v_lang,60),
                  to_char(nvl(v_qtyout,0)), get_label_name('HRRPSAX1',global_v_lang,50) );

          -- gen graph case by case from input on screen (PERCENT)
          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item2,
                      item4, item5,
                      item8,item9,
                      item10, item31)
          values (global_v_codempid, 'HRRPSAX2', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), v_year + global_v_zyear,
                  r1.dtemthbug, get_tlistval_name('MONTH',r1.dtemthbug,global_v_lang),
                  get_label_name('HRRPSAX2',global_v_lang,140), get_label_name('HRRPSAX2',global_v_lang,80),
                  to_char(nvl(v_percennew,0),'fm990.00'), get_label_name('HRRPSAX1',global_v_lang,50) );

          v_idx := v_idx + 1;
          insert into ttemprpt (codempid, codapp, numseq,
                      item1, item2,
                      item4, item5,
                      item8,item9,
                      item10, item31)
          values (global_v_codempid, 'HRRPSAX2', v_idx,
                  get_label_name('HRRPSAX2',global_v_lang,80), v_year + global_v_zyear,
                  r1.dtemthbug, get_tlistval_name('MONTH',r1.dtemthbug,global_v_lang),
                  get_label_name('HRRPSAX2',global_v_lang,150), get_label_name('HRRPSAX2',global_v_lang,80),
                  to_char(nvl(v_percenout,0),'fm990.00'), get_label_name('HRRPSAX1',global_v_lang,50) );
        end loop;

        obj_data     := json_object_t();
        if v_countmth > 0 then
          obj_data.put('coderror', '200');
          obj_data.put('month', get_label_name('HRRPSAX2',global_v_lang,100));
          obj_data.put('qtycurrent', to_char(nvl(v_sum_qtycurrent,0),'fm999,999,990'));
          obj_data.put('qtynew', to_char(nvl(v_sum_qtynew,0)));
          obj_data.put('percennew', to_char(nvl(v_sum_percennew,0), 'fm990.00'));
          obj_data.put('qtyout', to_char(nvl(v_sum_qtyout,0)));
          obj_data.put('percenout', to_char(nvl(v_sum_percenout,0), 'fm990.00'));
          obj_row.put(to_char(v_rcnt),obj_data);
          v_qty := floor(v_sum_qtycurrent/v_countmth);
        else
          v_qty := 0;
        end if;
        obj_children := json_object_t();
        obj_children.put('children',obj_row);
        obj_children.put('qty', to_char(v_qty,'fm9,999,999,990'));
        obj_children.put('dteyear',v_year);

        obj_result.put(to_char(v_countyre-1),obj_children);
      end if;
    end loop;

    json_str_output := obj_result.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --
END HRRPSAX;

/
