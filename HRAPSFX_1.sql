--------------------------------------------------------
--  DDL for Package Body HRAPSFX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSFX" is
-- last update: 02/09/2020 10:17

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

    --block b_index
    b_index_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteyear1   := hcm_util.get_string_t(json_obj,'p_year1');
    b_index_dteyear2   := hcm_util.get_string_t(json_obj,'p_year2');
    b_index_dteyear3   := hcm_util.get_string_t(json_obj,'p_year3');

    ---
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
             and codapp   = 'HRAPSFX';
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
    v_flgsecu       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    j               varchar2(2 char);
    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_cs            number := 0;
    v_cs1           number := 0;
    v_seq_yre       number := 0;
    v_per_policy    varchar2(40 char);
    v_per_actual    varchar2(40 char);
    v_desc          varchar2(400 char);

cursor c_grade is
      select   grade,codcomp
        from    tstdis
       where    codcomp = b_index_codcomp
         and    (dteyreap   = b_index_dteyear1
                or dteyreap = b_index_dteyear2
                or dteyreap = b_index_dteyear3
                )
   group by grade,codcomp
   order by grade;

cursor c_dteyreap is
      select dteyreap,codcomp
        from tstdis
       where  codcomp = b_index_codcomp
         and    (dteyreap   = b_index_dteyear1
                or dteyreap = b_index_dteyear2
                or dteyreap = b_index_dteyear3
                )
    group by dteyreap,codcomp
    order by dteyreap desc;

begin
   begin
        select  count(distinct dteyreap)
          into  v_seq_yre
          from  tstdis
         where  codcomp         = b_index_codcomp
           and  (dteyreap       = b_index_dteyear1
                or dteyreap     = b_index_dteyear2
                or dteyreap     = b_index_dteyear3
                );
    end;

    obj_row := json_object_t();
    for i in c_grade loop
        v_flgdata := 'Y';
    end loop;

     if v_flgdata = 'Y' then
      for i in c_grade loop
      flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
      if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('grade',i.grade);
            v_cs1 := 0;
            for j in    c_dteyreap loop
             v_cs1 := v_cs1+1;
              v_cs :=0;
              for k in 1..v_seq_yre loop
                v_cs := v_cs+1;
                if  v_cs = v_cs1 then
                         begin
                            select  to_char(pctpostr,'fm990.00')||'-'||to_char(pctpoend,'fm990.00') ,
                                    to_char(pctactstr,'fm990.00')||'-'||to_char(pctactend,'fm990.00')
                              into  v_per_policy, v_per_actual
                              from  tstdis
                             where  codcomp  = i.codcomp
                               and  dteyreap = j.dteyreap
                               and  grade    = i.grade;
                          exception when no_data_found then
                                v_per_policy := null;
                                v_per_actual := null;
                        end;

                    --------------
               obj_data.put('description',get_tstdis_name(i.codcomp,j.dteyreap,i.grade,global_v_lang));
               obj_data.put('total'||v_cs,v_per_policy);
               obj_data.put('percent'||v_cs,v_per_actual);
               end if;
               obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;  -- k
        end loop;--j
      end if;-- if flgpass
     end loop;-- i
    end if;--v_flgdata = 'Y'

   if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tstdis');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    --   json_str_output := obj_data.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSFX';
--    v_numseq    ttemprpt.numseq%type := 0;
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
    j                varchar2(10 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;
    v_numseq2        number;
    v_flgdata        varchar2(1 char) := 'N';
  --  v_dteyreap       number := 0;
    v_qty_policy     number := 0;
    v_qty_actual     number := 0;
    v_desc           varchar2(400 char);
    v_seq_grd        number :=0;
    v_seq_yre        number :=0;
    v_cs1            number :=0;
    v_cs             number :=0;
    flgpass          boolean;
    v_per_policy    varchar2(40 char);
    v_pctpostr      varchar2(40 char);
    v_pctpoend      varchar2(40 char);
    v_year          number := 0;

    cursor c1 is
      select   grade,codcomp
          from    tstdis
         where    codcomp = b_index_codcomp
           and    (dteyreap   = b_index_dteyear1
                  or dteyreap = b_index_dteyear2
                  or dteyreap = b_index_dteyear3
                  )
       group by grade,codcomp
       order by grade;

    cursor c_dteyreap is
      select    dteyreap
          from    tstdis
         where    codcomp = b_index_codcomp
           and    (dteyreap   = b_index_dteyear1
                  or dteyreap = b_index_dteyear2
                  or dteyreap = b_index_dteyear3
                  )
      group by dteyreap
      order by dteyreap desc;

  begin
    v_year      := hcm_appsettings.get_additional_year;

    begin
        select  count(distinct dteyreap)
          into  v_seq_yre
          from  tstdis
         where  codcomp         = b_index_codcomp
           and  (dteyreap       = b_index_dteyear1
                or dteyreap     = b_index_dteyear2
                or dteyreap     = b_index_dteyear3
                );
    end;

    for i in c1 loop
        v_flgdata := 'Y';
    end loop;

    if v_flgdata = 'Y' then
        param_msg_error := null;
        v_item1  := get_label_name('HRAPSFX', global_v_lang, '60'); --'% ขึ้นตามนโยบาย'
        v_item14 := '1';
        v_seq_grd := 0;
        for i in c1 loop
          flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
          if flgpass then

            v_flgdata := 'Y';
            v_seq_grd := v_seq_grd+1;
            v_cs1 := 0;
            for j in  c_dteyreap loop
              v_cs1 := v_cs1+1;
              v_cs :=0;
              v_item2 := j.dteyreap + v_year;
              for k in 1..v_seq_yre loop
                v_cs := v_cs+1;
                if  v_cs = v_cs1 then
                    ----------ค่าข้อมูล
                  begin
                        select  to_char(pctpostr,'fm990.00'), to_char(pctpoend,'fm990.00')
                          into  v_pctpostr, v_pctpoend
                          from  tstdis
                         where  codcomp = i.codcomp
                           and  dteyreap = j.dteyreap
                           and  grade    = i.grade;
                  exception when no_data_found then
                    v_per_policy := null;
                    v_pctpostr := null; 
                    v_pctpoend := null;
                  end;
                  ----------แกน X
                      v_item6  := get_label_name('HRAPSFXC1', global_v_lang, '60'); --'เกรด';
                      v_item4  := v_seq_grd;
                      v_item5  := i.grade;
                    --v_itemXX  := get_tstdis_name(i.codcomp,v_dteyreap,i.grade,global_v_lang);
                      v_item31 := get_label_name('HRAPSFXC1', global_v_lang, '10'); --'สรุปอัตราการจ่ายโบนัสแยกตาม'|| 'เกรด'
                  ----------แกน Y
--                      v_item7  := k;
                      v_item8  := j.dteyreap;
                      v_item9  := get_label_name('HRAPSFXC1', global_v_lang, '50'); --'% การขึ้นเงินเดือน'
                      v_item10 := v_per_policy;
                  ----------Insert ttemprpt
                      begin
                       insert into ttemprpt
                          (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
                        values
                          (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, get_label_name('HRAPSFXC1', global_v_lang, '70'), v_item9, v_pctpostr, v_item31, v_item14 );
                      exception when dup_val_on_index then
                        rollback;
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                        return;
                      end;
                      v_numseq := v_numseq + 1;
                      begin
                       insert into ttemprpt
                          (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
                        values
                          (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7,get_label_name('HRAPSFXC1', global_v_lang, '80'), v_item9, v_pctpoend, v_item31, v_item14 );
                      exception when dup_val_on_index then
                        rollback;
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                        return;
                      end;
                      v_numseq := v_numseq + 1;
                 end if; --v_cs = v_cs1
              end loop;--loop j
            end loop; --loop k
          end if;--if flgpass
        end loop;--loop i
        commit;
     end if;-- if flgpass
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --

  procedure gen_graph2 is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSFX';
--    v_numseq    ttemprpt.numseq%type := 0;
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
    j                varchar2(10 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;
    v_numseq2        number;
    v_flgdata        varchar2(1 char) := 'N';
  --  v_dteyreap       number := 0;
    v_qty_policy     number := 0;
    v_qty_actual     number := 0;
    v_desc           varchar2(400 char);
    v_seq_grd        number :=0;
    v_seq_yre        number :=0;
    v_cs1            number :=0;
    v_cs             number :=0;
    flgpass          boolean;
    v_per_actual     varchar2(40 char);
    v_pctactstr      varchar2(40 char);
    v_pctactend      varchar2(40 char);
    v_year           number := 0;

    cursor c1 is
      select   grade,codcomp
        from    tstdis
       where    codcomp = b_index_codcomp
         and    (dteyreap   = b_index_dteyear1
                or dteyreap = b_index_dteyear2
                or dteyreap = b_index_dteyear3
                )
       group by grade,codcomp
       order by grade;

    cursor c_dteyreap is
      select    dteyreap
        from    tstdis
       where    codcomp = b_index_codcomp
         and    (dteyreap   = b_index_dteyear1
                or dteyreap = b_index_dteyear2
                or dteyreap = b_index_dteyear3
                )
      group by dteyreap
      order by dteyreap desc;

  begin
    v_year      := hcm_appsettings.get_additional_year;

    begin
        select  count(distinct dteyreap)
          into  v_seq_yre
          from  tstdis
         where  codcomp         = b_index_codcomp
           and  (dteyreap       = b_index_dteyear1
                or dteyreap     = b_index_dteyear2
                or dteyreap     = b_index_dteyear3
                );
    end;

    for i in c1 loop
        v_flgdata := 'Y';
    end loop;

if v_flgdata = 'Y' then
    param_msg_error := null;
    v_item1  := get_label_name('HRAPSFX', global_v_lang, '70'); --'% ขึ้นจริง'
    v_item14 := '2';
    v_seq_grd := 0;
    for i in c1 loop
    flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
    if flgpass then
        v_flgdata := 'Y';
         v_seq_grd := v_seq_grd+1;
            v_cs1 := 0;
            for j in  c_dteyreap loop
             v_cs1 := v_cs1+1;
              v_cs :=0;
              v_item2 := j.dteyreap + v_year;
              for k in 1..v_seq_yre loop
                v_cs := v_cs+1;
             if  v_cs = v_cs1 then
        ----------ค่าข้อมูล
                     begin
                            select  to_char(pctactstr,'fm990.00'), to_char(pctactend,'fm990.00')
                              into  v_pctactstr, v_pctactend
                              from  tstdis
                             where  codcomp  = i.codcomp
                               and  dteyreap = j.dteyreap
                               and  grade    = i.grade;
                          exception when no_data_found then
                                 v_per_actual := null;
                                 v_pctactstr := null;
                                 v_pctactend := null;
                        end;
                   ----------แกน X
                    v_item6  := get_label_name('HRAPSFXC1', global_v_lang, '60'); --'เกรด';
                    v_item4  := v_seq_grd;
                    v_item5  := i.grade;
                  --v_itemXX  := get_tstdis_name(i.codcomp,v_dteyreap,i.grade,global_v_lang);
                    v_item31 := get_label_name('HRAPSFXC1', global_v_lang, '10'); --'สรุป%การขึ้นเงินเดือนแยกตามเกรด'
           ----------แกน Y
                    v_item7  := k;
                    v_item8  := j.dteyreap;
                    v_item9  := get_label_name('HRAPSFXC1', global_v_lang, '50'); --'% การขึ้นเงินเดือน'
                    v_item10 := v_per_actual;
                ----------Insert ttemprpt
                    begin
                     insert into ttemprpt
                        (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
                      values
                        (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, get_label_name('HRAPSFXC1', global_v_lang, '70'), v_item9, v_pctactstr, v_item31, v_item14 );
                    exception when dup_val_on_index then
                      rollback;
                      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                      return;
                    end;
                     v_numseq := v_numseq + 1;
                     begin
                     insert into ttemprpt
                        (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
                      values
                        (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, get_label_name('HRAPSFXC1', global_v_lang, '80'), v_item9, v_pctactend, v_item31, v_item14 );
                    exception when dup_val_on_index then
                      rollback;
                      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                      return;
                    end;
                     v_numseq := v_numseq + 1;
               end if; --v_cs = v_cs1
            end loop;--loop j
       end loop; --loop k
       end if;--if flgpass
    end loop;--loop i
    commit;
 end if;-- if flgpass
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/
