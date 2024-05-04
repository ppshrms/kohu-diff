--------------------------------------------------------
--  DDL for Package Body HRAPSIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSIX" is
-- last update: 19/08/2020 11:00

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
--msg_err2('IN initial_value');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_zyear      := hcm_appsettings.get_additional_year() ;

    --block b_index
    b_index_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_sql        := hcm_util.get_string_t(json_obj,'p_sql_statement');
    b_index_dteyear1   := hcm_util.get_string_t(json_obj,'p_year1');
    b_index_dteyear2   := hcm_util.get_string_t(json_obj,'p_year2');
    b_index_dteyear3   := hcm_util.get_string_t(json_obj,'p_year3');

    --Group รายละเอียด
    b_index_v_grp1     := get_label_name('HRAPSIX', global_v_lang, '60');
    b_index_v_grp2     := get_label_name('HRAPSIX', global_v_lang, '70');
    b_index_v_grp3     := get_label_name('HRAPSIX', global_v_lang, '80');

    --HEADER GRAPH
    b_index_v_graph1   := get_label_name('HRAPSIX', global_v_lang, '90');
    b_index_v_graph2   := get_label_name('HRAPSIX', global_v_lang, '100');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_data(json_str_output);

--delete
        param_msg_error := null;
        v_numseq := 1;
        begin
          delete from ttemprpt
           where codempid = global_v_codempid
             and codapp   = 'HRAPSIX';
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
          return;
        end;
--gen_graph
        gen_graph;
        gen_graph2;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function chk_tapprais return number is
    v_stmt      varchar2(4000 char);
    v_cntemp    number := 0;
  begin
    v_stmt := 'select count(distinct codempid) from tapprais ';
    v_stmt := v_stmt ||' where codcomp like '''|| b_index_codcomp ||'%''';
    v_stmt := v_stmt ||' and dteyreap in ('||b_index_dteyear1||','||''||b_index_dteyear2||','||b_index_dteyear3||')';--|| v_year ;
    --v_stmt := v_stmt ||' and grade    =  '''|| i.grade ||'''';
    v_stmt := v_stmt ||' and numlvl between  '|| global_v_zminlvl ||' and '|| global_v_zwrklvl;
    if b_index_sql is not null then
        v_stmt := v_stmt ||' '||b_index_sql;
    end if;
    begin
        execute immediate v_stmt into v_cntemp;
        exception when others then v_cntemp := 0;
    end;
    return v_cntemp;
  end;

  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    j               varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);

    v_codcompy      varchar2(400 char);
    v_codlinef      varchar2(400 char);
    v_dteeffec      date;
    v_codcompr      varchar2(400 char);
    v_comp_length   number := 3;
    v_cntemp        number := 0;
    v_amtsal        number := 0;
    v_amtsaln       number := 0;

    v_cntemp1       number := 0;
    v_cntemp2       number := 0;
    v_cntemp3       number := 0;

    v_sumemp1       number := 0;
    v_sumemp2       number := 0;
    v_sumemp3       number := 0;

    v_dipsal1       number := 0;
    v_dipsal2       number := 0;
    v_dipsal3       number := 0;

    v_perc1         number := 0;
    v_perc2         number := 0;
    v_perc3         number := 0;
    v_dteyreap      number := 0;
    v_year          number := 0;
    v_desc          varchar2(4000 char);
    v_cond          varchar2(4000 char);
    v_stmt          varchar2(4000 char);
    v_flgcal        boolean;
    --<<User37 #3766 AP - PeoplePlus 24/12/2020
    v_sumtotal1     number := 0;
    v_sumtotal2     number := 0;
    v_sumtotal3     number := 0;
    v_sumpercent1   number := 0;
    v_sumpercent2   number := 0;
    v_sumpercent3   number := 0;
    -->>User37 #3766 AP - PeoplePlus 24/12/2020

    cursor c1 is
      select distinct grade grade
        from tstdis
       where codcomp like b_index_codcomp||'%'
         and dteyreap in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3)
/*
         and  0 <> (select count(ts.codcomp)
                     from tusrcom ts
                   where ts.coduser = global_v_coduser
                   and codcomp like ts.codcomp||'%'
                   and rownum <= 1 )
*/
      order by grade;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      if chk_tapprais > 0 then
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seq',v_rcnt);
      obj_data.put('grade',i.grade);

--msg_err2('i.grade  =  '||i.grade);

      begin
        select decode(global_v_lang, '101', desgrade,
                                     '102', desgradt,
                                     '103', desgrad3,
                                     '104', desgrad4,
                                     '105', desgrad5, desgradt) description
          into v_desc
          from tstdis a
         where a.codcomp like b_index_codcomp||'%'
           and a.grade = i.grade
           and a.dteyreap = (select max(b.dteyreap)
                               from tstdis b
                              where b.codcomp like a.codcomp||'%'
                                and b.grade = a.grade
                                and b.dteyreap in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3));
        exception when others then v_desc := null;
      end;

      obj_data.put('description',v_desc);

      for j in 1..3 loop
          v_sumemp1 := 0;
          v_sumemp2 := 0;
--
          if j = 1 then  --ปีที่1
                v_year := b_index_dteyear1;
          elsif j = 2 then  --ปีที่2
                v_year := b_index_dteyear2;
          else  --ปีที่3
                v_year := b_index_dteyear3;
          end if;
--
--v_cntemp1(จำนวนพนักงาน)
          begin
            select count(distinct codempid) into v_cntemp1
              from tapprais
             where codcomp like b_index_codcomp||'%'
               and dteyreap = v_year
               and numlvl between global_v_zminlvl and global_v_zwrklvl;
            exception when others then v_cntemp1 := 0;
          end;
--v_cntemp2(จำนวนพนักงานทั้งหมด)
          v_stmt := 'select count(distinct codempid) from tapprais ';
          v_stmt := v_stmt ||' where codcomp like '''|| b_index_codcomp ||'%''';
          v_stmt := v_stmt ||' and dteyreap =  '|| v_year ;
          v_stmt := v_stmt ||' and grade    =  '''|| i.grade ||'''';
          v_stmt := v_stmt ||' and numlvl between  '|| global_v_zminlvl ||' and '|| global_v_zwrklvl;
          if b_index_sql is not null then
               v_stmt := v_stmt ||' '||b_index_sql;
          end if;
          begin
               execute immediate v_stmt into v_cntemp2;
               exception when others then v_cntemp2 := 0;
          end;
--
          if j = 1 then  --ปีที่1
                --<<User37 #3765 AP - PeoplePlus 29/11/2020
                --obj_data.put('total1',to_char(v_cntemp1, 'fm999,999,990'));
                --v_sumtotal1   := nvl(v_sumtotal1,0) + nvl(v_cntemp1,0);--User37 #3766 AP - PeoplePlus 24/12/2020
                obj_data.put('total1',to_char(v_cntemp2, 'fm999,999,990'));
                v_sumtotal1   := nvl(v_sumtotal1,0) + nvl(v_cntemp2,0);
                -->>User37 #3765 AP - PeoplePlus 29/11/2020
                if v_cntemp1 <> 0 then
                    obj_data.put('percent1',to_char((v_cntemp2 / v_cntemp1) * 100, 'fm999,999,990.00'));
                    v_sumpercent1 := nvl(v_sumpercent1,0) + nvl((v_cntemp2 / v_cntemp1) * 100,0);--User37 #3766 AP - PeoplePlus 24/12/2020
                else
                    obj_data.put('percent1','0.00');
                end if;
          elsif j = 2 then  --ปีที่2
                --<<User37 #3765 AP - PeoplePlus 29/11/2020
                --obj_data.put('total2',to_char(v_cntemp1, 'fm999,999,990'));
                --v_sumtotal2   := nvl(v_sumtotal2,0) + nvl(v_cntemp1,0);--User37 #3766 AP - PeoplePlus 24/12/2020
                obj_data.put('total2',to_char(v_cntemp2, 'fm999,999,990'));
                v_sumtotal2   := nvl(v_sumtotal2,0) + nvl(v_cntemp2,0);
                -->>User37 #3765 AP - PeoplePlus 29/11/2020
                if v_cntemp1 <> 0 then
                    obj_data.put('percent2',to_char((v_cntemp2 / v_cntemp1) * 100, 'fm999,999,990.00'));
                    v_sumpercent2 := nvl(v_sumpercent2,0) + nvl((v_cntemp2 / v_cntemp1) * 100,0);--User37 #3766 AP - PeoplePlus 24/12/2020
                else
                    obj_data.put('percent2','0.00');
                end if;
          else  --ปีที่3
                --<<User37 #3765 AP - PeoplePlus 29/11/2020
                --obj_data.put('total3',to_char(v_cntemp1, 'fm999,999,990'));
                --v_sumtotal3   := nvl(v_sumtotal3,0) + nvl(v_cntemp1,0);--User37 #3766 AP - PeoplePlus 24/12/2020
                obj_data.put('total3',to_char(v_cntemp2, 'fm999,999,990'));
                v_sumtotal3   := nvl(v_sumtotal3,0) + nvl(v_cntemp2,0);
                -->>User37 #3765 AP - PeoplePlus 29/11/2020
                if v_cntemp1 <> 0 then
                    obj_data.put('percent3',to_char((v_cntemp2 / v_cntemp1) * 100, 'fm999,999,990.00'));
                    v_sumpercent3 := nvl(v_sumpercent3,0) + nvl((v_cntemp2 / v_cntemp1) * 100,0);--User37 #3766 AP - PeoplePlus 24/12/2020
                else
                    obj_data.put('percent3','0.00');
                end if;
          end if;
--
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
      end if;
    end loop;

    if v_rcnt > 0 then
        --<<User37 #3766 AP - PeoplePlus 24/12/2020
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('seq',v_rcnt);
        obj_data.put('grade','');
        obj_data.put('description',get_label_name('HRAPSIX', global_v_lang, '100'));
        if b_index_dteyear1 is not null then  --ปีที่1
            obj_data.put('total1',to_char(v_sumtotal1, 'fm999,999,990'));
            obj_data.put('percent1',to_char(v_sumpercent1, 'fm999,999,990.00'));
        end if;
        if b_index_dteyear2 is not null then  --ปีที่2
            obj_data.put('total2',to_char(v_sumtotal2, 'fm999,999,990'));
            obj_data.put('percent2',to_char(v_sumpercent2, 'fm999,999,990.00'));
        end if;

        if b_index_dteyear3 is not null then  --ปีที่3
            obj_data.put('total3',to_char(v_sumtotal3, 'fm999,999,990'));
            obj_data.put('percent3',to_char(v_sumpercent3, 'fm999,999,990.00'));
        end if;
        obj_row.put(to_char(v_rcnt-1),obj_data);
        -->>User37 #3766 AP - PeoplePlus 24/12/2020
        json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tapprais');
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
    v_codapp    ttemprpt.codapp%type := 'HRAPSIX';
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
    j                varchar2(10 char);
    v_desc_month     varchar2(1000 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;

    v_hours          varchar2(4000 char);
    v_othersleave    varchar2(4000 char);
    v_qtymth         number;
    v_flgdata        varchar2(1 char) := 'N';
    v_comp_length    number := 3;
    v_dteyreap       number := 0;
    v_amtsal         number := 0;
    v_amtsaln        number := 0;
    v_dipsal         number := 0;
    v_stmt           varchar2(4000 char);

    cursor c1 is
      select distinct grade grade
        from tstdis
       where codcomp like b_index_codcomp||'%'
         and dteyreap in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3)
/*
         and  0 <> (select count(ts.codcomp)
                     from tusrcom ts
                   where ts.coduser = global_v_coduser
                   and codcomp like ts.codcomp||'%'
                   and rownum <= 1 )
*/
      order by grade;

  begin
    param_msg_error := null;
    v_item1  := get_label_name('HRAPSIX', global_v_lang, '80'); --'จำนวนพนักงาน'
    v_item31 := get_label_name('HRAPSIX', global_v_lang, '110'); --'เปรียบเทียบ Performance Grade ของพนักงานในแต่ละปี'
    v_item14 := '1';

    for i in c1 loop
        v_flgdata := 'Y';
        for j in 1..3 loop
                v_dteyreap := null;
                if j = 1 then
                    v_dteyreap := b_index_dteyear1;
                elsif j = 2 then
                    v_dteyreap := b_index_dteyear2;
                else
                    v_dteyreap := b_index_dteyear3;
                end if;
                if v_dteyreap is not null then
                    ---------- Group1
                        v_item7  := j;
                        v_item8  := v_dteyreap + global_v_zyear;
                        v_item9  := get_label_name('HRAPSIX', global_v_lang, '80'); --'จำนวนพนักงาน';
                    ----------แกน x
                        v_item4  := i.grade;
                        v_item5  := i.grade;
                        v_item6  := get_label_name('HRAPSIX', global_v_lang, '30'); --'ปี';
                    ----------ค่าข้อมูล (จำนวนพนักงานทั้งหมด)
                        v_dipsal := 0;
                        begin
                            select count(distinct codempid) into v_dipsal
                              from tapprais
                             where codcomp like b_index_codcomp||'%'
                               and dteyreap = v_dteyreap
                               and numlvl between global_v_zminlvl and global_v_zwrklvl;
                            exception when others then v_dipsal := 0;
                        end;

                        v_stmt := 'select count(distinct codempid) from tapprais ';
                        v_stmt := v_stmt ||' where codcomp like '''|| b_index_codcomp ||'%''';
                        v_stmt := v_stmt ||' and dteyreap =  '|| v_dteyreap ;
                        v_stmt := v_stmt ||' and grade    =  '''|| i.grade ||'''';
                        v_stmt := v_stmt ||' and numlvl between  '|| global_v_zminlvl ||' and '|| global_v_zwrklvl;
                        if b_index_sql is not null then
                            v_stmt := v_stmt ||' '||b_index_sql;
                        end if;
                        begin
                            execute immediate v_stmt into v_dipsal;
                            exception when others then v_dipsal := 0;
                        end;

                        v_item10  := v_dipsal;
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
                end if; --if v_dteyreap is not null then
        end loop;
    end loop;
    commit;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  procedure gen_graph2 is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSIX';
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
    j                varchar2(10 char);
    v_desc_month     varchar2(1000 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;

    v_hours          varchar2(4000 char);
    v_othersleave    varchar2(4000 char);
    v_qtymth         number;
    v_flgdata        varchar2(1 char) := 'N';
    v_comp_length    number := 3;
    v_dteyreap       number := 0;
    v_amtsal         number := 0;
    v_amtsaln        number := 0;

    v_stmt          varchar2(4000 char);
    v_cntemp1       number := 0;
    v_cntemp2       number := 0;

    v_dipsal         number := 0;

    cursor c1 is
      select distinct grade grade
        from tstdis
       where codcomp like b_index_codcomp||'%'
         and dteyreap in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3)
/*
         and  0 <> (select count(ts.codcomp)
                     from tusrcom ts
                   where ts.coduser = global_v_coduser
                   and codcomp like ts.codcomp||'%'
                   and rownum <= 1 )
*/
      order by grade;

  begin
    param_msg_error := null;
    v_item1  := get_label_name('HRAPSIX', global_v_lang, '90'); --'% พนักงาน'
    v_item31 := get_label_name('HRAPSIX', global_v_lang, '110'); --'เปรียบเทียบ Performance Grade ของพนักงานในแต่ละปี'
    v_item14 := '2';

    for i in c1 loop
        v_flgdata := 'Y';
        for j in 1..3 loop
                v_dteyreap := null;
                if j = 1 then
                    v_dteyreap := b_index_dteyear1;
                elsif j = 2 then
                    v_dteyreap := b_index_dteyear2;
                else
                    v_dteyreap := b_index_dteyear3;
                end if;
                if v_dteyreap is not null then
                    ---------- Group1
                        v_item7  := j;
                        v_item8  := v_dteyreap + global_v_zyear;
                        v_item9  := get_label_name('HRAPSIX', global_v_lang, '90'); --'% พนักงาน';
                    ----------แกน x
                        v_item4  := i.grade;
                        v_item5  := i.grade;
                        v_item6  := get_label_name('HRAPSIX', global_v_lang, '30'); --'ปี';

                    ----------ค่าข้อมูล (จำนวนพนักงานทั้งหมด)
                        v_cntemp1 := 0;  v_cntemp2:= 0;  v_dipsal := 0;
                        begin
                            select count(distinct codempid) into v_cntemp1
                              from tapprais
                             where codcomp like b_index_codcomp||'%'
                               and dteyreap = v_dteyreap
                               and numlvl between global_v_zminlvl and global_v_zwrklvl;
                            exception when others then v_cntemp1 := 0;
                        end;

            --v_cntemp2(จำนวนพนักงานตามเกรด)
                        v_stmt := 'select count(distinct codempid) from tapprais ';
                        v_stmt := v_stmt ||' where codcomp like '''|| b_index_codcomp ||'%''';
                        v_stmt := v_stmt ||' and dteyreap =  '|| v_dteyreap ;
                        v_stmt := v_stmt ||' and grade    =  '''|| i.grade ||'''';
                        v_stmt := v_stmt ||' and numlvl between  '|| global_v_zminlvl ||' and '|| global_v_zwrklvl;
                        if b_index_sql is not null then
                           v_stmt := v_stmt ||' '||b_index_sql;
                        end if;
                        begin
                           execute immediate v_stmt into v_cntemp2;
                           exception when others then v_cntemp2 := 0;
                        end;
--
                        if v_cntemp1 <> 0 then
                            v_item10 := to_char((v_cntemp2 / v_cntemp1) * 100, 'fm999,999,990.00');
                        else
                            v_item10 := '0';
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
                end if; --if v_dteyreap is not null then
        end loop;
    end loop;
    commit;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  procedure get_list_comlevel (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    cursor c_1 is
      select  comlevel , decode(global_v_lang , '101', a.namcente,
                                                '102', a.namcentt,
                                                '103', a.namcent3,
                                                '104', a.namcent4,
                                                '105', a.namcent5) namecomlevel, qtycode
        from   tcompnyc a ,tsetcomp b
        where codcompy = b_index_codcomp
        and  a.comlevel = b.numseq
      order by comlevel ;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for r1 in c_1 loop
      v_rcnt      := v_rcnt+1;
      obj_data     := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('comlevel', r1.comlevel);
      obj_data.put('namecomlevel', r1.namecomlevel);
      obj_data.put('qtycode', r1.qtycode);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tsetcomp');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
     else
        json_str_output := obj_row.to_clob;
     end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'MSG';

  begin
    null;
    /*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = v_codapp;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(v_codapp,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;
  --
end;

/
