--------------------------------------------------------
--  DDL for Package Body HRRP48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP48X" is
-- last update: 19/08/2020 11:00

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_zyear      := hcm_appsettings.get_additional_year() ;
    --block b_index 
    b_index_dteyear    := hcm_util.get_string_t(json_obj,'p_dteyear');
    b_index_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_typerep    := hcm_util.get_string_t(json_obj,'p_typerep');  --แสดงข้อมูลตาม (1-ครบเกษียณอายุ , 2-ครบกำหนดจ้างงาน)
    b_index_man_age    := hcm_util.get_string_t(json_obj,'p_man_age');
    b_index_woman_age  := hcm_util.get_string_t(json_obj,'p_woman_age'); 

    --block drilldown 
    b_index_codpos     := hcm_util.get_string_t(json_obj,'p_codpos');
    ---
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        --แสดงข้อมูลตาม (1-ครบเกษียณอายุ , 2-ครบกำหนดจ้างงาน)
        if b_index_typerep = '1' then
            gen_data(json_str_output);
            gen_graph;
        else
            gen_data2(json_str_output);
            gen_graph2;
        end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -- 
  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_month         varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean; 

    v_codcompy      varchar2(400 char);
    v_codlinef      varchar2(400 char);
    v_dteeffec      date;
    v_codcompr      varchar2(400 char); 

    cursor c1 is 
      select codcomp, codpos,
             count(decode(to_char(dteretire,'mm'),'01',1,null))qtymth1,
             count(decode(to_char(dteretire,'mm'),'02',1,null))qtymth2,
             count(decode(to_char(dteretire,'mm'),'03',1,null))qtymth3,
             count(decode(to_char(dteretire,'mm'),'04',1,null))qtymth4,
             count(decode(to_char(dteretire,'mm'),'05',1,null))qtymth5,
             count(decode(to_char(dteretire,'mm'),'06',1,null))qtymth6,
             count(decode(to_char(dteretire,'mm'),'07',1,null))qtymth7,
             count(decode(to_char(dteretire,'mm'),'08',1,null))qtymth8,
             count(decode(to_char(dteretire,'mm'),'09',1,null))qtymth9,
             count(decode(to_char(dteretire,'mm'),'10',1,null))qtymth10,
             count(decode(to_char(dteretire,'mm'),'11',1,null))qtymth11,
             count(decode(to_char(dteretire,'mm'),'12',1,null))qtymth12
        from temploy1
       where codcomp like b_index_codcomp||'%'
         and to_char(dteretire,'yyyy') =  b_index_dteyear
         and staemp = '3'
         and exists (select codcomp  from tusrcom a
                      where a.coduser = global_v_coduser
                        and codcomp like a.codcomp||'%')
         and numlvl between global_v_zminlvl and  global_v_zwrklvl
      group by codcomp,codpos
      order by codcomp,codpos;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y'; 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seq',v_rcnt);
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('comp_desc',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('codpos',i.codpos);
      obj_data.put('pos_desc',get_tpostn_name(i.codpos,global_v_lang));

      obj_data.put('qtymth1',i.qtymth1);
      obj_data.put('qtymth2',i.qtymth2);
      obj_data.put('qtymth3',i.qtymth3);
      obj_data.put('qtymth4',i.qtymth4);
      obj_data.put('qtymth5',i.qtymth5);
      obj_data.put('qtymth6',i.qtymth6);
      obj_data.put('qtymth7',i.qtymth7);
      obj_data.put('qtymth8',i.qtymth8);
      obj_data.put('qtymth9',i.qtymth9);
      obj_data.put('qtymth10',i.qtymth10);
      obj_data.put('qtymth11',i.qtymth11);
      obj_data.put('qtymth12',i.qtymth12);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -- 
  procedure gen_data2(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_month         varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean;

    v_codcompy      varchar2(400 char);
    v_codlinef      varchar2(400 char);
    v_dteeffec      date;
    v_codcompr      varchar2(400 char); 

    cursor c1 is 
      select codcomp, codpos,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'01',1,null))qtymth1,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'02',1,null))qtymth2,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'03',1,null))qtymth3,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'04',1,null))qtymth4,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'05',1,null))qtymth5,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'06',1,null))qtymth6,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'07',1,null))qtymth7,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'08',1,null))qtymth8,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'09',1,null))qtymth9,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'10',1,null))qtymth10,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'11',1,null))qtymth11,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'12',1,null))qtymth12
        from temploy1
       where codcomp like b_index_codcomp||'%'
         --dteoccup  วันที่บรรจุ     qtydatrq	กำหนดการจ้างงาน(เดือน)
         and to_char(add_months(dteoccup,qtydatrq),'YYYY') = b_index_dteyear
         and nvl(qtydatrq,0) > 0
         and exists (select codcomp  from tusrcom a
                      where a.coduser = global_v_coduser
                        and codcomp like a.codcomp||'%')
         and numlvl between global_v_zminlvl and  global_v_zwrklvl
      group by codcomp,codpos
      order by codcomp,codpos;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y'; 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seq',v_rcnt);
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('comp_desc',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('codpos',i.codpos);
      obj_data.put('pos_desc',get_tpostn_name(i.codpos,global_v_lang));

      obj_data.put('qtymth1',i.qtymth1);
      obj_data.put('qtymth2',i.qtymth2);
      obj_data.put('qtymth3',i.qtymth3);
      obj_data.put('qtymth4',i.qtymth4);
      obj_data.put('qtymth5',i.qtymth5);
      obj_data.put('qtymth6',i.qtymth6);
      obj_data.put('qtymth7',i.qtymth7);
      obj_data.put('qtymth8',i.qtymth8);
      obj_data.put('qtymth9',i.qtymth9);
      obj_data.put('qtymth10',i.qtymth10);
      obj_data.put('qtymth11',i.qtymth11);
      obj_data.put('qtymth12',i.qtymth12);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -- 
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_svyre         number;
    v_svmth         number;
    v_svday         number;

    cursor c1 is 
      select dteretire, codempid, codcomp, codpos, dteempdb, dteempmt  
        from temploy1
       where codcomp like b_index_codcomp||'%'
         and codpos   =   b_index_codpos
         and to_char(dteretire,'yyyy') = b_index_dteyear
         and staemp = 3
/*
         and exists (select codcomp  from tusrcom a
                      where a.coduser = global_v_coduser
                        and codcomp like a.codcomp||'%')
         and numlvl between global_v_zminlvl and  global_v_zwrklvl
*/
      order by dteretire , codempid;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';
      flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('seq',v_rcnt);
          obj_data.put('dteretire',to_char(i.dteretire,'dd/mm/yyyy'));
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('pos_desc',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('comp_desc',get_tcenter_name(i.codcomp,global_v_lang));
          obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy'));

          get_service_year(i.dteempdb,sysdate,'Y',v_svyre,v_svmth,v_svday);
          obj_data.put('age',to_char(v_svyre) ||'('|| to_char(v_svmth) ||')');

          get_service_year(i.dteempmt,sysdate,'Y',v_svyre,v_svmth,v_svday);
          obj_data.put('workage',to_char(v_svyre) ||'('|| to_char(v_svmth) ||')');

          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRRP48X';
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

    v_codleave       varchar2(10 char);
    v_desc_codleave  varchar2(1000 char);
    v_month          varchar2(10 char);
    v_desc_month     varchar2(1000 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;

    v_hours          varchar2(4000 char);
    v_othersleave    varchar2(4000 char);
    v_qtymth         number;
    v_flgdata        varchar2(1 char) := 'N';

    cursor c1 is 
      select codcomp ,codpos ,
             count(decode(to_char(dteretire,'mm'),'01',1,null))qtymth1,
             count(decode(to_char(dteretire,'mm'),'02',1,null))qtymth2,
             count(decode(to_char(dteretire,'mm'),'03',1,null))qtymth3,
             count(decode(to_char(dteretire,'mm'),'04',1,null))qtymth4,
             count(decode(to_char(dteretire,'mm'),'05',1,null))qtymth5,
             count(decode(to_char(dteretire,'mm'),'06',1,null))qtymth6,
             count(decode(to_char(dteretire,'mm'),'07',1,null))qtymth7,
             count(decode(to_char(dteretire,'mm'),'08',1,null))qtymth8,
             count(decode(to_char(dteretire,'mm'),'09',1,null))qtymth9,
             count(decode(to_char(dteretire,'mm'),'10',1,null))qtymth10,
             count(decode(to_char(dteretire,'mm'),'11',1,null))qtymth11,
             count(decode(to_char(dteretire,'mm'),'12',1,null))qtymth12
        from temploy1
       where codcomp like b_index_codcomp||'%'
         and to_char(dteretire,'yyyy') =  b_index_dteyear
         and staemp = '3'
         and exists (select codcomp  from tusrcom a
                      where a.coduser = global_v_coduser
                        and codcomp like a.codcomp||'%')
         and numlvl between global_v_zminlvl and  global_v_zwrklvl
      group by codcomp,codpos
      order by codcomp,codpos;

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

    v_item31 := get_label_name('HRRP48X2', global_v_lang, '140'); --'จำนวนพนักงานครบเกษียณอายุ';
--    v_item14 := b_index_typerep;
--    v_item1  := b_index_typerep; --get_label_name('HRRP48XC2', global_v_lang, '40');

    for i in c1 loop
        v_flgdata := 'Y';
        for v_month in 1..12 loop
            ----------แกน X
                v_item4  := lpad(v_month, 2, '0');
                v_item5  := get_tlistval_name('NAMMTHABB', v_month, global_v_lang);
                v_item6  := b_index_dteyear + global_v_zyear;
            ----------แกน Y
                v_item7  := i.codpos;
                v_item8  := get_tpostn_name(i.codpos,global_v_lang);
                v_item9  := get_label_name('HRRP48X2', global_v_lang, '150'); --'จำนวนพนักงาน'; 
            ----------ค่าข้อมูล
                if v_month    = 1 then v_item10  := i.qtymth1;
                elsif v_month = 2 then v_item10  := i.qtymth2;
                elsif v_month = 3 then v_item10  := i.qtymth3;
                elsif v_month = 4 then v_item10  := i.qtymth4;
                elsif v_month = 5 then v_item10  := i.qtymth5;
                elsif v_month = 6 then v_item10  := i.qtymth6;
                elsif v_month = 7 then v_item10  := i.qtymth7;
                elsif v_month = 8 then v_item10  := i.qtymth8;
                elsif v_month = 9 then v_item10  := i.qtymth9;
                elsif v_month = 10 then v_item10 := i.qtymth10;
                elsif v_month = 11 then v_item10 := i.qtymth11;
                elsif v_month = 12 then v_item10 := i.qtymth12;
                end if;
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
        end loop;
    end loop;
    commit;

    if v_numseq > 1 then
        param_msg_error := get_error_msg_php('HR2720', global_v_lang);
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  -- 
  procedure gen_graph2 is 
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRRP48X';
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

    v_codleave       varchar2(10 char);
    v_desc_codleave  varchar2(1000 char);
    v_month          varchar2(10 char);
    v_desc_month     varchar2(1000 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;

    v_hours          varchar2(4000 char);
    v_othersleave    varchar2(4000 char);
    v_qtymth         number;
    v_flgdata        varchar2(1 char) := 'N';

    cursor c1 is 
      select codcomp ,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'01',1,null))qtymth1,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'02',1,null))qtymth2,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'03',1,null))qtymth3,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'04',1,null))qtymth4,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'05',1,null))qtymth5,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'06',1,null))qtymth6,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'07',1,null))qtymth7,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'08',1,null))qtymth8,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'09',1,null))qtymth9,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'10',1,null))qtymth10,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'11',1,null))qtymth11,
             count(decode(to_char(add_months(dteoccup,qtydatrq),'mm'),'12',1,null))qtymth12
        from temploy1
       where codcomp like b_index_codcomp||'%'
         --dteoccup  วันที่บรรจุ     qtydatrq	กำหนดการจ้างงาน(เดือน)
         and to_char(add_months(dteoccup,qtydatrq),'YYYY') = b_index_dteyear
         and nvl(qtydatrq,0) > 0
         and exists (select codcomp  from tusrcom a
                      where a.coduser = global_v_coduser
                        and codcomp like a.codcomp||'%')
         and numlvl between global_v_zminlvl and  global_v_zwrklvl
      group by codcomp
      order by codcomp;

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

    v_item31 := get_label_name('HRRP48XC2', global_v_lang, '210'); --'จำนวนพนักงานครบเกษียณอายุ';
--    v_item14 := b_index_typerep;
--    v_item1  := b_index_typerep; --get_label_name('HRRP48XC2', global_v_lang, '40');

    for i in c1 loop
        v_flgdata := 'Y';
        for v_month in 1..12 loop
            ----------แกน X
                v_item4  := i.codcomp;
                v_item5  := get_tcenter_name(i.codcomp,global_v_lang);
                v_item6  := get_label_name('HRRP48XC2', global_v_lang, '140'); --'จำนวนพนักงาน'; 
            ----------แกน Y
                v_item7  := lpad(v_month, 2, '0');
                v_item8  := get_tlistval_name('NAMMTHFUL', v_month, global_v_lang);
                v_item9  := b_index_dteyear;
            ----------ค่าข้อมูล
                if v_month    = 1 then v_item10  := i.qtymth1;
                elsif v_month = 2 then v_item10  := i.qtymth2;
                elsif v_month = 3 then v_item10  := i.qtymth3;
                elsif v_month = 4 then v_item10  := i.qtymth4;
                elsif v_month = 5 then v_item10  := i.qtymth5;
                elsif v_month = 6 then v_item10  := i.qtymth6;
                elsif v_month = 7 then v_item10  := i.qtymth7;
                elsif v_month = 8 then v_item10  := i.qtymth8;
                elsif v_month = 9 then v_item10  := i.qtymth9;
                elsif v_month = 10 then v_item10 := i.qtymth10;
                elsif v_month = 11 then v_item10 := i.qtymth11;
                elsif v_month = 12 then v_item10 := i.qtymth12;
                end if;
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
        end loop;
    end loop;
    commit;

    if v_numseq > 1 then
        param_msg_error := get_error_msg_php('HR2720', global_v_lang);
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/
