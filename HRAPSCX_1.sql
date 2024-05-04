--------------------------------------------------------
--  DDL for Package Body HRAPSCX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSCX" is
-- last update: 02/09/2020 21:00
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
    --b_index
    b_index_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numperiod');
    --screen
    b_index_codkpino    := hcm_util.get_string_t(json_obj,'p_codkpino');
    b_index_grade       := hcm_util.get_string_t(json_obj,'p_grade');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --


procedure get_data1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --


  procedure gen_data1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean;
    cs_emp_tot      number :=0;
    cs_emp_ap       number :=0;

 begin
            obj_row := json_object_t();
            begin
                select  count(codempid)
                  into  cs_emp_ap 
                  from  tempaplvl
                 where  dteyreap    = b_index_dteyreap
                   and  numseq      = b_index_numtime;
            end;
            
            
            -----
            begin
                select  count(codempid)
                  into  cs_emp_tot
                  from  tappemp
                 where  dteyreap    =  b_index_dteyreap
                   and  numtime     =  b_index_numtime
                   and  codcomp     like   b_index_codcomp||'%'
                   and nvl(flgappr,'P') = 'C';
            end;
            ----
            
            if cs_emp_tot > 0 then
                v_flgdata := 'Y';
            end if;

            if v_flgdata = 'Y' then
                    flgpass := secur_main.secur7(b_index_codcomp,global_v_coduser);
                    if flgpass then
                        v_flgsecu := 'Y';
                        v_rcnt := v_rcnt+1;
                        obj_data := json_object_t();
                        obj_data.put('coderror', '200');
                        obj_data.put('emp_evaluated',cs_emp_tot);
                        obj_data.put('emp_total',cs_emp_ap);
                      --obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
            end if; --v_flgdata
            if v_flgdata = 'N' then
              param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TEMPAPLVL');
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            elsif v_flgsecu = 'N' then
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            else
            --json_str_output := obj_row.to_clob;
              json_str_output := obj_data.to_clob;
            end if;
  end;
  --

  procedure get_data2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data2(json_str_output);
        --delete
        param_msg_error := null;
        v_numseq := 1;
        begin
          delete from ttemprpt
           where codempid = global_v_codempid
             and codapp   = 'HRAPSCX';
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
          return;
        end;
        gen_graph;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data2(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    flgpass     	boolean;
    v_codempid      temploy1.codempid%type;
    v_codkpi        tkpicmph.codkpi%type;
    v_color         tkpicmpg.color%type;
    v_desgrade      tkpicmpg.desgrade%type;
    v_flggrade      tapbudgt.flggrade%type;
    cs_emp_grd      number :=0;
    cs_emp_tot      number :=0;
    cs_emp_poli     number :=0;

cursor c1 is
     select a.grade,  nvl(a.pctemp,0)pctemp
       from tstdis a
      where a.codcomp like b_index_codcomp||'%'
        and a.dteyreap =   (select max(b.dteyreap)
                            from tstdis b
                           where b.codcomp = a.codcomp
                             and b.dteyreap <= b_index_dteyreap)
       order by a.grade;

/*
set serveroutput on
declare
  v_out   clob;
  v_in    clob := q'[{
                      "p_coduser" : "TJS00001",
                      "p_lang"    : "101",
                      "p_codempid"    : "16010",
                      "p_codcomp": "TJS000000000000000000",
                      "p_dteyreap": "2015",
                      "p_numtime": "1"
                    }]';
begin
  hrapscx.get_data2(v_in,v_out)  ;
  json(v_out).print;
end;
*/
 begin
         obj_row := json_object_t();
         for i in c1 loop
            v_flgdata := 'Y';

         end loop;

          begin
             select a.flggrade
               into v_flggrade
               from tapbudgt a
              where a.codcomp = b_index_codcomp
                and a.dteyreap =   (select max(b.dteyreap)
                                    from tapbudgt  b
                                   where b.codcomp = a.codcomp
                                     and b.dteyreap <= b_index_dteyreap);
                exception when no_data_found then
                    v_flggrade := null;
           end;

    if v_flgdata = 'Y' then
        for i in c1 loop
            flgpass := secur_main.secur7(b_index_codcomp,global_v_coduser);
            if flgpass then
                v_flgsecu := 'Y';
                    v_rcnt := v_rcnt+1;
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('grad',i.grade);
                    begin
                        select  count(codempid)
                          into  cs_emp_grd
                          from  tappemp
                         where  dteyreap    =  b_index_dteyreap
                           and  numtime     =  b_index_numtime
                           and  codcomp     like  b_index_codcomp||'%'
                           and  nvl(flgappr,'P') = 'C'
                           and  grdap       = i.grade;
                    end;
                    -- 1-กำหนดคะแนน
                    if v_flggrade = '1' then
                        obj_data.put('totalemp','');
                        obj_data.put('policy',cs_emp_grd);
                    -- 2-กำหนดคะแนนและ %พนักงาน
                    else
                        begin
                            select  count(codempid)
                              into  cs_emp_tot
                              from  tempaplvl
                             where  dteyreap    = b_index_dteyreap
                               and  numseq      = b_index_numtime;
                        end;
                        
                        cs_emp_poli := ((i.pctemp*cs_emp_tot)/100);
                        obj_data.put('totalemp',i.pctemp);
                        obj_data.put('policy',cs_emp_poli);
                    end if;
                    obj_data.put('assessment',cs_emp_grd);
                    obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;  --flgpass
        end loop; --c1
    end if; --v_flgdata

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tstdis');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -----

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSCX';
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
  --v_dteyreap       number := 0;
    v_qty_policy     number := 0;
    v_qty_actual     number := 0;
    v_desc           varchar2(400 char);
    v_seq_grd        number :=0;
    v_seq_yre        number :=0;
    v_cs1            number :=0;
    v_cs             number :=0;
    flgpass          boolean;
    v_per_policy     varchar2(40 char);
    v_flgsecu        varchar2(1);
    v_policy         number :=0;
    cs_emp_grd       number :=0;
    cs_emp_tot       number :=0;
    cs_emp_poli      number :=0;
    v_flggrade       tapbudgt.flggrade%type;

cursor c1 is
     select a.grade,  nvl(a.pctemp,0)pctemp
       from tstdis a
      where a.codcomp like b_index_codcomp||'%'
        and a.dteyreap =   (select max(b.dteyreap)
                            from tstdis b
                           where b.codcomp = a.codcomp
                             and b.dteyreap <= b_index_dteyreap)
       order by a.grade;

begin
    for i in c1 loop
        v_flgdata := 'Y';
        exit;
    end loop;

    if v_flgdata = 'Y' then
        param_msg_error := null;
        v_item1  := '';
        v_item14 := '';
        v_item31 := get_label_name('HRAPSCX', global_v_lang, '130');
        v_seq_grd := 0;
                --วิธีการตัดเกรด
                   begin
                     select a.flggrade
                       into v_flggrade
                       from tapbudgt a
                      where a.codcomp = b_index_codcomp
                        and a.dteyreap =   (select max(b.dteyreap)
                                            from tapbudgt  b
                                           where b.codcomp = a.codcomp
                                             and b.dteyreap <= b_index_dteyreap);
                        exception when no_data_found then
                            v_flggrade := null;
                   end;
        -----
        for i in c1 loop
            flgpass := secur_main.secur7(b_index_codcomp,global_v_coduser);
            if flgpass then
                v_flgsecu := 'Y';
                v_flgdata := 'Y';
                v_seq_grd := v_seq_grd+1;
--================================================================
                   begin
                        select  count(codempid)
                          into  cs_emp_grd
                          from  tappemp
                         where  dteyreap    =  b_index_dteyreap
                           and  numtime     =  b_index_numtime
                           and  codcomp     like   b_index_codcomp||'%'
                           and  nvl(flgappr,'P') = 'C'
                           and  grdap       = i.grade;
                    end;
                    ----
                    begin
                        select  count(codempid)
                          into  cs_emp_tot
                          from  tempaplvl
                         where  dteyreap    = b_index_dteyreap
                           and  numseq      = b_index_numtime;
                    end;
                    cs_emp_poli := (i.pctemp*cs_emp_tot)/100;
                    ---
                    if v_flggrade = '1' then
                         v_policy := cs_emp_grd;
                    else
                         v_policy := cs_emp_poli;
                    end if;
                    ---
--======================================================
            for j in 1..2 loop
                     if j = 1  then --จำนวนคนตามนโยบาย
                            v_item7  := j;
                            v_item8  := get_label_name('HRAPSCX', global_v_lang, '70'); --'จำนวนคนตามนโยบาย';
                            v_item10 := v_policy; ----------ค่าข้อมูล
                     else--จำนวนคนที่ได้จากการประเมิน
                            v_item7  := j;
                            v_item8  :=  get_label_name('HRAPSCX', global_v_lang, '80');--'จำนวนคนที่ได้จากการประเมิน';
                             v_item10 := cs_emp_grd; ----------ค่าข้อมูล
                     end if;
                        v_item9  := get_label_name('HRAPSCX', global_v_lang, '140'); --'จำนวนคน';
                    ----------แกน x
                        v_item6  := null;
                        v_item4  := v_seq_grd;
                        v_item5  := i.grade;
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
            end loop; -- loop j
         end if;-- if flgpass
       end loop;--loop i
       commit;
     end if;-- if flgdata
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/
