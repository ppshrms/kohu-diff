--------------------------------------------------------
--  DDL for Package Body HRAPSBX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSBX" is
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

    --block b_index
    b_index_codcompy   := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_complvl    := hcm_util.get_string_t(json_obj,'p_complvl');
    b_index_dteyear1   := hcm_util.get_string_t(json_obj,'p_dteyear1');
    b_index_dteyear2   := hcm_util.get_string_t(json_obj,'p_dteyear2');
    b_index_dteyear3   := hcm_util.get_string_t(json_obj,'p_dteyear3');

    --Group รายละเอียด
    b_index_v_grp1     := get_label_name('HRAPSBX', global_v_lang, '60');
    b_index_v_grp2     := get_label_name('HRAPSBX', global_v_lang, '70');
    b_index_v_grp3     := get_label_name('HRAPSBX', global_v_lang, '80');

    --HEADER GRAPH
    b_index_v_graph1   := get_label_name('HRAPSBX', global_v_lang, '90');
    b_index_v_graph2   := get_label_name('HRAPSBX', global_v_lang, '100');

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
             and codapp   = 'HRAPSBX';
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
          return;
        end;
        gen_graph;
        gen_graph2;

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
    j         varchar2(2 char);
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

    v_dipsal1       number := 0;
    v_dipsal2       number := 0;
    v_dipsal3       number := 0;

    v_perc1         number := 0;
    v_perc2         number := 0;
    v_perc3         number := 0;

    cursor c1 is
      select distinct substr(codcomp , 1 , v_comp_length) codcomp
        from tapprais
       where codcomp like b_index_codcompy||'%'
         and dteyreap in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3)
      group by substr(codcomp, 1, v_comp_length)
      order by substr(codcomp, 1, v_comp_length);

  begin
    begin
        Select sum(qtycode) into v_comp_length
          from tsetcomp
         where numseq <= b_index_complvl;
        exception when others then v_comp_length := 3;
        v_comp_length := nvl(v_comp_length , 3);
    end;

    obj_row := json_object_t();
    for i in c1 loop
      for j in 1..3 loop
          v_flgdata := 'Y';
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('seq',v_rcnt);
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));

          if j = 1 then  --จำนวนคน
                obj_data.put('description',b_index_v_grp1);
                begin
                    select count(dteyreap) into v_cntemp1
                      from tapprais
                     where codcomp like i.codcomp||'%'
                       and dteyreap = b_index_dteyear1
                       and numlvl between global_v_zminlvl and global_v_zwrklvl;
                end;
                obj_data.put('year1',v_cntemp1);
                -----
                begin
                    select count(dteyreap) into v_cntemp2
                      from tapprais
                     where codcomp like i.codcomp||'%'
                       and dteyreap = b_index_dteyear2
                       and numlvl between global_v_zminlvl and global_v_zwrklvl;
                end;
                obj_data.put('year2',v_cntemp2);
                -----
                begin
                    select count(dteyreap) into v_cntemp3
                      from tapprais
                     where codcomp like i.codcomp||'%'
                       and dteyreap = b_index_dteyear3
                       and numlvl between global_v_zminlvl and global_v_zwrklvl;
                end;
                obj_data.put('year3',v_cntemp3);
          elsif j = 2 then  --จำนวนเงิน(ปรับสุทธิ)
                obj_data.put('description',b_index_v_grp2);
                begin
                    select sum(nvl(stddec(amtsal,tapprais.codempid,v_chken),0))  ,
                           sum(nvl(stddec(amtsaln,tapprais.codempid,v_chken),0))
                      into v_amtsal, v_amtsaln
                      from tapprais
                     where codcomp like i.codcomp||'%'
                       and dteyreap = b_index_dteyear1
                       and numlvl between global_v_zminlvl and global_v_zwrklvl;
                    v_dipsal1 := (nvl(v_amtsaln,0) - nvl(v_amtsal,0));
                end;
                obj_data.put('year1',to_char(v_dipsal1,'fm99,999,990.00'));
                -----
                begin
                    select sum(nvl(stddec(amtsal,tapprais.codempid,v_chken),0))  ,
                           sum(nvl(stddec(amtsaln,tapprais.codempid,v_chken),0))
                      into v_amtsal, v_amtsaln
                      from tapprais
                     where codcomp like i.codcomp||'%'
                       and dteyreap = b_index_dteyear2
                       and numlvl between global_v_zminlvl and global_v_zwrklvl;
                    v_dipsal2 := (nvl(v_amtsaln,0) - nvl(v_amtsal,0));
                end;
                obj_data.put('year2',to_char(v_dipsal2,'fm99,999,990.00'));
                -----
                 begin
                    select sum(nvl(stddec(amtsal,tapprais.codempid,v_chken),0))  ,
                           sum(nvl(stddec(amtsaln,tapprais.codempid,v_chken),0))
                      into v_amtsal, v_amtsaln
                      from tapprais
                     where codcomp like i.codcomp||'%'
                       and dteyreap = b_index_dteyear3
                       and numlvl between global_v_zminlvl and global_v_zwrklvl;
                    v_dipsal3 := (nvl(v_amtsaln,0) - nvl(v_amtsal,0));
                end;
                obj_data.put('year3',to_char(v_dipsal3,'fm99,999,990.00'));
          else  -- % การขึ้นเงินเดือนเฉลี่ย
                obj_data.put('description',b_index_v_grp3);
                v_perc1 := null;
                if nvl(v_cntemp1,0) > 0 then
                    --<<User37 Demo Test V.11 #3633 14/12/2020
                    begin
                        select sum(PCTADJSAL)
                          into v_perc1
                          from tapprais
                         where codcomp like i.codcomp||'%'
                           and dteyreap = b_index_dteyear1
                           and numlvl between global_v_zminlvl and global_v_zwrklvl;
                    exception when no_data_found then
                        v_perc1 := null;
                    end;
                    v_perc1 := (v_perc1 / v_cntemp1);
                    --v_perc1 := (v_dipsal1 / v_cntemp1) / 100;
                    -->>User37 Demo Test V.11 #3633 14/12/2020
                end if;
                obj_data.put('year1',to_char(nvl(v_perc1,0),'fm990.00'));
                -----
                v_perc2 := null;
                if nvl(v_cntemp2,0) > 0 then
                    --<<User37 Demo Test V.11 #3633 14/12/2020
                    begin
                        select sum(PCTADJSAL)
                          into v_perc2
                          from tapprais
                         where codcomp like i.codcomp||'%'
                           and dteyreap = b_index_dteyear2
                           and numlvl between global_v_zminlvl and global_v_zwrklvl;
                    exception when no_data_found then
                        v_perc2 := null;
                    end;
                    v_perc2 := (v_perc2 / v_cntemp2);
                    --v_perc2 := (v_dipsal2 / v_cntemp2) / 100;
                    -->>User37 Demo Test V.11 #3633 14/12/2020
                end if;
                obj_data.put('year2',to_char(nvl(v_perc2,0),'fm990.00'));
                -----
                v_perc3 := null;
                if nvl(v_cntemp3,0) > 0 then
                    --<<User37 Demo Test V.11 #3633 14/12/2020
                    begin
                        select sum(PCTADJSAL)
                          into v_perc3
                          from tapprais
                         where codcomp like i.codcomp||'%'
                           and dteyreap = b_index_dteyear3
                           and numlvl between global_v_zminlvl and global_v_zwrklvl;
                    exception when no_data_found then
                        v_perc3 := null;
                    end;
                    v_perc3 := (v_perc3 / v_cntemp3);
                    --v_perc3 := (v_dipsal3 / v_cntemp3) / 100;
                    -->>User37 Demo Test V.11 #3633 14/12/2020
                end if;
                obj_data.put('year3',to_char(nvl(v_perc3,0),'fm990.00'));
                -----
          end if;
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end loop;

    if v_rcnt > 0 then
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
    v_codapp    ttemprpt.codapp%type := 'HRAPSBX';
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
    j          varchar2(10 char);
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

    cursor c1 is
      select distinct substr(codcomp , 1 , v_comp_length) codcomp
        from tapprais
       where codcomp like b_index_codcompy||'%'
         and dteyreap in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3)
      group by substr(codcomp, 1, v_comp_length)
      order by substr(codcomp, 1, v_comp_length);

  begin
    param_msg_error := null;
    begin
        Select sum(qtycode) into v_comp_length
          from tsetcomp
         where numseq <= b_index_complvl;
        exception when others then v_comp_length := 3;
        v_comp_length := nvl(v_comp_length , 3);
    end;

    v_item1  := get_label_name('HRAPSBX', global_v_lang, '90'); --'จำนวนเงินที่จ่าย'
    v_item31 := get_label_name('HRAPSBX', global_v_lang, '110'); --'สถิติการขึ้นเงินเดือนประจำปี'
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
--                        v_item8  := v_dteyreap;
                        v_item8  := hcm_util.get_year_buddhist_era(v_dteyreap);
                        v_item9  := get_label_name('HRAPSBX', global_v_lang, '90'); --'จำนวนเงินที่จ่าย';
                    ----------แกน x
                        v_item4  := i.codcomp;
                        v_item5  := get_tcenter_name(i.codcomp,global_v_lang);
                        v_item6  := get_label_name('HRAPSBX', global_v_lang, '40'); --'หน่วยงาน';
                    ----------ค่าข้อมูล
                        v_dipsal := 0;
                        begin
                            select sum(nvl(stddec(amtsal,tapprais.codempid,v_chken),0))  ,
                                   sum(nvl(stddec(amtsaln,tapprais.codempid,v_chken),0))
                              into v_amtsal, v_amtsaln
                              from tapprais
                             where codcomp like i.codcomp||'%'
                               and dteyreap = v_dteyreap
                               and numlvl between global_v_zminlvl and global_v_zwrklvl;
                            v_dipsal := (v_amtsaln - v_amtsal);
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
    v_codapp    ttemprpt.codapp%type := 'HRAPSBX';
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
    j          varchar2(10 char);
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
    v_cntemp         number := 0;

    v_percent        number := 0;

    cursor c1 is
      select distinct substr(codcomp , 1 , v_comp_length) codcomp
        from tapprais
       where codcomp like b_index_codcompy||'%'
         and dteyreap in (b_index_dteyear1, b_index_dteyear2, b_index_dteyear3)
      group by substr(codcomp, 1, v_comp_length)
      order by substr(codcomp, 1, v_comp_length);

  begin
    param_msg_error := null;
    begin
        Select sum(qtycode) into v_comp_length
          from tsetcomp
         where numseq <= b_index_complvl;
        exception when others then v_comp_length := 3;
        v_comp_length := nvl(v_comp_length , 3);
    end;

    v_item1  := get_label_name('HRAPSBX', global_v_lang, '100'); --'% การขึ้นเงินเดือน'
    v_item31 := get_label_name('HRAPSBX', global_v_lang, '110'); --'สถิติการขึ้นเงินเดือนประจำปี'
    v_item14 := '2';

    for i in c1 loop
        v_flgdata := 'Y';
        for j in 1..3 loop
                v_dteyreap := null;
                v_percent :=  0;
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
                        v_item8  := hcm_util.get_year_buddhist_era(v_dteyreap);
                        v_item9  := get_label_name('HRAPSBX', global_v_lang, '100'); --'% การขึ้นเงินเดือน';
                    ----------แกน Y
                        v_item4  := i.codcomp;
                        v_item5  := get_tcenter_name(i.codcomp,global_v_lang);
                        v_item6  := get_label_name('HRAPSBX', global_v_lang, '40'); --'หน่วยงาน';
                    ----------ค่าข้อมูล
                        v_dipsal := 0;
                        begin
                            select sum(nvl(stddec(amtsal,tapprais.codempid,v_chken),0))  ,
                                   sum(nvl(stddec(amtsaln,tapprais.codempid,v_chken),0))
                              into v_amtsal, v_amtsaln
                              from tapprais
                             where codcomp like i.codcomp||'%'
                               and dteyreap = v_dteyreap
                               and numlvl between global_v_zminlvl and global_v_zwrklvl;
                            v_dipsal := (v_amtsaln - v_amtsal);
                        end;

                        begin
                            select count(dteyreap) into v_cntemp
                              from tapprais
                             where codcomp like i.codcomp||'%'
                               and dteyreap = v_dteyreap
                               and numlvl between global_v_zminlvl and global_v_zwrklvl;
                        end;
                        begin
                            select sum(PCTADJSAL)
                              into v_percent
                              from tapprais
                             where codcomp like i.codcomp||'%'
                               and dteyreap = v_dteyreap
                               and numlvl between global_v_zminlvl and global_v_zwrklvl;
                        exception when no_data_found then
                            v_percent := null;
                        end;
                        v_item10 := 0;
                        if nvl(v_percent, 0) <> 0 then
                            v_item10  := v_percent / v_cntemp;
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
                        v_numseq  := v_numseq + 1;
                end if;-- v_dteyreap is not null then
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
        where codcompy = b_index_codcompy
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
--
--    if v_rcnt = 0 then
--        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tsetcomp');
--        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--     else
        json_str_output := obj_row.to_clob;
--     end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
