--------------------------------------------------------
--  DDL for Package Body HRAPSEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSEX" is
-- last update: 01/09/2020 14:22

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
    b_index_codbon     := hcm_util.get_string_t(json_obj,'p_codbon');
    b_index_numtime    := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_dteyear1   := hcm_util.get_string_t(json_obj,'p_year1');
    b_index_dteyear2   := hcm_util.get_string_t(json_obj,'p_year2');
    b_index_dteyear3   := hcm_util.get_string_t(json_obj,'p_year3');
    b_index_typeof     := hcm_util.get_string_t(json_obj,'p_typeof');--G =  ตามประเมิน C = ตามเงื่อนไข

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
             and codapp   = 'HRAPSEX';
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
    j               varchar2(2 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_cs            number := 0;
    v_cs1           number := 0;
    v_seq_yre       number := 0;
    v_qty_policy    number := 0;
    v_qty_actual    number := 0;
    v_numcond       number;
    v_desc          varchar2(400 char);
    v2_desc          varchar2(400 char);

    cursor c_grade is
      select   decode(b_index_typeof,'A',grade,'O',numcond)  grade,codcomp,codbon,numtime,numcond
        from    tbonus
       where    codcomp like b_index_codcomp||'%'
         and    codbon       = b_index_codbon
         and    numtime      = b_index_numtime
         and    (dteyreap   = b_index_dteyear1
                or dteyreap = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap = nvl(b_index_dteyear3,b_index_dteyear1)
                )
        and decode(b_index_typeof,'A',grade,'O',numcond) is not null
       group by decode(b_index_typeof,'A',grade,'O',numcond) ,codcomp,codbon,numtime,numcond
       order by grade;

    cursor c_dteyreap is
      select    dteyreap,codcomp,codbon,numtime
        from    tbonus
       where    codcomp like b_index_codcomp||'%'
         and    codbon       = b_index_codbon
         and    numtime      = b_index_numtime
         and    (dteyreap   = b_index_dteyear1
                or dteyreap = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap = nvl(b_index_dteyear3,b_index_dteyear1)
                )
    group by dteyreap,codcomp,codbon,numtime
    order by dteyreap desc;

    begin
      begin
        select  count(distinct dteyreap)
          into  v_seq_yre
          from  tbonus
         where  codcomp         like b_index_codcomp||'%'
           and  codbon          = b_index_codbon
           and  numtime         = b_index_numtime
           and  (dteyreap       = b_index_dteyear1
                or dteyreap     = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap     = nvl(b_index_dteyear3,b_index_dteyear1)
                );
      end;
    obj_row := json_object_t();
    for i in c_grade loop
      v_flgdata := 'Y';
      exit;
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
                -- ***
                v_cs := 0;
                if b_index_dteyear1 is not null then
                  v_cs := v_cs+1;
                  get_data_sumary(b_index_dteyear1, i.grade, i.numcond, v_desc, v_qty_policy, v_qty_actual);

                  obj_data.put('desc_grade',v_desc);
                  obj_data.put('paypolicy'||v_cs,v_qty_policy);
                  obj_data.put('payactual'||v_cs,v_qty_actual);
                end if;
                if b_index_dteyear2 is not null then
                  v_cs := v_cs+1;
                  get_data_sumary(b_index_dteyear2, i.grade, i.numcond, v_desc, v_qty_policy, v_qty_actual);

                  obj_data.put('desc_grade',v_desc);
                  obj_data.put('paypolicy'||v_cs,v_qty_policy);
                  obj_data.put('payactual'||v_cs,v_qty_actual);
                end if;
                if b_index_dteyear3 is not null then
                  v_cs := v_cs+1;
                  get_data_sumary(b_index_dteyear3, i.grade, i.numcond, v_desc, v_qty_policy, v_qty_actual);

                  obj_data.put('desc_grade',v_desc);
                  obj_data.put('paypolicy'||v_cs,v_qty_policy);
                  obj_data.put('payactual'||v_cs,v_qty_actual);
                end if;
                obj_row.put(to_char(v_rcnt-1),obj_data);
                -- ***

--                v_cs1 := 0;
--                for j in c_dteyreap loop
--                  v_cs1 := v_cs1+1; 
--                  v_cs :=0;
--                  for k in REVERSE 1..v_seq_yre loop
--                  
--                    v_cs := v_cs+1;
--                    if  v_cs = v_cs1 then
--                       if b_index_typeof = 'A' then --Grade ตามการประเมิน
--                             begin
--                                select  ratebon
--                                  into  v_qty_policy
--                                  from  ttbonpard
--                                 where  codcomp like hcm_util.get_codcomp_level(i.codcomp,1)||'%'
--                                   and  codbon  = i.codbon
--                                   and  numtime = i.numtime
--                                   and  dteyreap = j.dteyreap
--                                   and  grade    = i.grade;
--                              exception when no_data_found then
--                                    v_qty_policy :=0;
--                              end;
--
----                                v_desc := get_tstdis_name(hcm_util.get_codcomp_level(i.codcomp,1),j.dteyreap,i.grade,global_v_lang);
--               
--                              v_desc := get_tstdis_name(i.codcomp,j.dteyreap,i.grade,global_v_lang);                              
--                              --if v2_desc is not null then
--                              --   v_desc := v2_desc;
--                              --end if;
--
--/*
--                              begin
--                                  select  decode('102','101',desgrade,'102',desgradt,'103',desgrad3,'104',desgrad4,'105',desgrad5, desgradt)
--                                   into   v_desc  
--                                   from      tstdis
--                                  where      i.codcomp like codcomp||'%'
--                                    and      dteyreap    <= j.dteyreap
--                                    and      grade       = i.grade 
--                                    and      rownum = 1 ;
--                              exception when others then
--                                    v_desc := '-----';
--                              end;
--*/                                
--
--                       else--Grade ตามเงื่อนไข
--                              begin
--                                select  ratebon ,ratecond
--                                  into  v_qty_policy, v_desc
--                                  from  ttbonparc
--                                 where  codcomp like hcm_util.get_codcomp_level(i.codcomp,1)||'%'
--                                   and  codbon  = i.codbon
--                                   and  numtime = i.numtime
--                                   and  dteyreap = j.dteyreap
--                                   and  numseq   = i.numcond;
--                              exception when no_data_found then
--                                    v_qty_policy :=0;
--                                    v_desc := '';
--                              end;
--                        end if;
--                        --------------
--                        begin
--                            select  nvl(sum(nvl(qtybon,0))/count(codempid),0)
--                              into  v_qty_actual
--                              from  tbonus
--                             where  codcomp like hcm_util.get_codcomp_level(i.codcomp,1)||'%'
--                               and  codbon  = i.codbon
--                               and  numtime = i.numtime
--                               and  dteyreap = j.dteyreap
--                               and  decode(b_index_typeof,'A',grade,'O',numcond,grade) = i.grade;
--                            exception when no_data_found then
--                                v_qty_actual :=0;
--                        end;
--                       obj_data.put('desc_grade',v_desc);
--                       obj_data.put('paypolicy'||v_cs,v_qty_policy);
--                       obj_data.put('payactual'||v_cs,v_qty_actual);
--                  end if;
--                  obj_row.put(to_char(v_rcnt-1),obj_data);
--                end loop; -- k
--            end loop;--j
            end if;-- if flgpass
        end loop;-- i
    end if;--v_flgdata = 'Y'


    if nvl(v_flgdata,'N') = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONUS');
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
    v_codapp    ttemprpt.codapp%type := 'HRAPSEX';
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
    v_seq_grd   number :=0;
    v_seq_yre number :=0;
    v_cs1 number :=0;
    v_cs number :=0;
    flgpass boolean;

    cursor c1 is
     select   decode(b_index_typeof,'A',grade,'O',numcond)  grade , codcomp
        from    tbonus
       where    codcomp like b_index_codcomp||'%'
         and   codbon       = b_index_codbon
         and   numtime      = b_index_numtime
         and    (dteyreap   = nvl(b_index_dteyear1,dteyreap)
                or dteyreap = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap = nvl(b_index_dteyear3,b_index_dteyear1)
                )
        and decode(b_index_typeof,'A',grade,'O',numcond) is not null
      group by decode(b_index_typeof,'A',grade,'O',numcond) ,codcomp
      order by grade;


    cursor c_dteyreap is
      select    dteyreap
        from    tbonus
       where    codcomp like b_index_codcomp||'%'
         and    codbon       = b_index_codbon
         and    numtime      = b_index_numtime
         and    (dteyreap   = nvl(b_index_dteyear1,dteyreap)
                or dteyreap = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap = nvl(b_index_dteyear3,b_index_dteyear1)
                )
      group by dteyreap
      order by dteyreap;

  begin
     begin
        select  count(distinct dteyreap)
          into  v_seq_yre
          from  tbonus
         where  codcomp         like b_index_codcomp||'%'
           and  codbon          = b_index_codbon
           and  numtime         = b_index_numtime
           and  (dteyreap       = b_index_dteyear1
                or dteyreap     = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap     = nvl(b_index_dteyear3,b_index_dteyear1)
                );
    end;

    for i in c1 loop
        v_flgdata := 'Y';
        exit;
    end loop;

    if v_flgdata = 'Y' then
        param_msg_error := null;
        v_item1  := get_label_name('HRAPSEXC3', global_v_lang, '30'); --'จ่ายตามนโยบาย'
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
              for k in 1..v_seq_yre loop
                v_cs := v_cs+1;
                if  v_cs = v_cs1 then
                  ----------ค่าข้อมูล
                  if b_index_typeof = 'A' then --Grade ตามการประเมิน
                        begin
                            select  ratebon
                              into  v_qty_policy
                              from  ttbonpard
--                             where  codcomp = i.codcomp
                             where  codcomp like hcm_util.get_codcomp_level(i.codcomp,1)||'%'
                               and  codbon  = b_index_codbon
                               and  numtime = b_index_numtime
                               and  dteyreap = j.dteyreap--v_dteyreap
                               and  grade    = i.grade;
                          exception when no_data_found then
                                v_qty_policy :=0;
                        end;
                       ----------แกน X
                        v_item6  := get_label_name('HRAPSEXC3', global_v_lang, '50'); --'เกรด';
                        v_item4  := v_seq_grd;
                        v_item5  := i.grade;
                      --v_itemXX  := get_tstdis_name(i.codcomp,v_dteyreap,i.grade,global_v_lang);
                        v_item31 := get_label_name('HRAPSEXC3', global_v_lang, '10')||' '||get_label_name('HRAPSEXC3', global_v_lang, '50'); --'สรุปอัตราการจ่ายโบนัสแยกตาม'|| 'เกรด'
                  else--Grade ตามเงื่อนไข
                        begin
                            select  ratebon,ratecond
                              into  v_qty_policy, v_desc
                              from  ttbonparc
                             where  codcomp     like hcm_util.get_codcomp_level(i.codcomp,1)||'%'
                               and  codbon      = b_index_codbon
                               and  numtime     = b_index_numtime
                               and  dteyreap    = j.dteyreap--v_dteyreap
                               and  numseq      = i.grade
                               and rownum <=1;
                          exception when no_data_found then
                                v_qty_policy :=0;
                                v_desc := '';
                        end;
                        --v_itemXX  := v_desc;
                        ----------แกน X

                        v_item4  := v_seq_grd;
                        v_item5  := i.grade;
                        v_item6  := get_label_name('HRAPSEXC3', global_v_lang, '60'); --'เงื่อนไข';
                        v_item31 := get_label_name('HRAPSEXC3', global_v_lang, '10')||' '||get_label_name('HRAPSEXC3', global_v_lang, '60'); --'สรุปอัตราการจ่ายโบนัสแยกตาม'||'เงื่อนไข'
                  end if;
                  ----------แกน Y
                  v_item7  := k;
                  -- v_item8  := j.dteyreap;
                  v_item8  := hcm_util.get_year_buddhist_era(j.dteyreap);--v_dteyreap;
                  v_item9  := get_label_name('HRAPSEXC3', global_v_lang, '30'); --'จ่ายตามนโยบาย'
                  v_item10 := v_qty_policy;
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
               end if;   --v_cs = v_cs1
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
    v_codapp    ttemprpt.codapp%type := 'HRAPSEX';
--v_numseq    ttemprpt.numseq%type := 0;
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
    v_dteyreap       number := 0;
    v_qty_policy     number := 0;
    v_qty_actual     number := 0;
    v_desc           varchar2(400 char);
    v_seq_grd        number :=0;
    v_seq_yre number :=0;
    v_cs1 number :=0;
    v_cs number :=0;
    flgpass boolean;

    cursor c1 is
     select   decode(b_index_typeof,'A',grade,'O',numcond)  grade , codcomp
        from    tbonus
       where    codcomp like b_index_codcomp||'%'
         and   codbon       = b_index_codbon
         and   numtime      = b_index_numtime
         and    (dteyreap   = nvl(b_index_dteyear1,dteyreap)
                or dteyreap = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap = nvl(b_index_dteyear3,b_index_dteyear1)
                )
        and decode(b_index_typeof,'A',grade,'O',numcond) is not null
   group by decode(b_index_typeof,'A',grade,'O',numcond) ,codcomp
   order by grade;

 cursor c_dteyreap is
      select    dteyreap
        from    tbonus
       where    codcomp like b_index_codcomp||'%'
         and    codbon       = b_index_codbon
         and    numtime      = b_index_numtime
         and    (dteyreap   = nvl(b_index_dteyear1,dteyreap)
                or dteyreap = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap = nvl(b_index_dteyear3,b_index_dteyear1)
                )
    group by dteyreap
    order by dteyreap;

  begin

       begin
        select  count(distinct dteyreap)
          into  v_seq_yre
          from  tbonus
         where  codcomp         like b_index_codcomp||'%'
           and  codbon          = b_index_codbon
           and  numtime         = b_index_numtime
           and  (dteyreap       = b_index_dteyear1
                or dteyreap     = nvl(b_index_dteyear2,b_index_dteyear1)
                or dteyreap     = nvl(b_index_dteyear3,b_index_dteyear1)
                );
    end;

    for i in c1 loop
        v_flgdata := 'Y';
        exit;
    end loop;

    if v_flgdata = 'Y' then
        param_msg_error := null;
        v_item1  := get_label_name('HRAPSEXC3', global_v_lang, '40'); --'อัตราการจ่ายตามจริง'
        v_item14 := '2';

    for i in c1 loop
       flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
       if flgpass then
        v_flgdata := 'Y';
         v_seq_grd := v_seq_grd+1;
          v_cs1 := 0;
            for j in  c_dteyreap loop
             v_cs1 := v_cs1+1;
               v_cs :=0;
              for k in 1..v_seq_yre loop
                v_cs := v_cs+1;
               if  v_cs = v_cs1 then
                          ---------ค่าข้อมูล--------------
                        --แกน X

                         begin
                            select  nvl(sum(nvl(qtybon,0))/count(codempid),0)
                              into  v_qty_actual
                              from  tbonus
                             where  codcomp  like hcm_util.get_codcomp_level(i.codcomp,1)||'%'
                               and  codbon   = b_index_codbon
                               and  numtime  = b_index_numtime
                               and  dteyreap = j.dteyreap--v_dteyreap
                               and  decode(b_index_typeof,'A',grade,'O',numcond,grade) = i.grade;
                            exception when no_data_found then
                                v_qty_actual :=0;
                        end;
                        if b_index_typeof = 'A' then --Grade ตามการประเมิน
                            v_item4  := v_seq_grd;
                            v_item5  := i.grade;
                         --   v_item8  := get_tstdis_name(i.codcomp,v_dteyreap,i.grade,global_v_lang);
                            v_item6  := get_label_name('HRAPSEXC3', global_v_lang, '50'); --'เกรด';
                            v_item31 := get_label_name('HRAPSEXC3', global_v_lang, '10')||' '||get_label_name('HRAPSEXC3', global_v_lang, '50'); --'สรุปอัตราการจ่ายโบนัสแยกตาม'|| 'เกรด'
                       else--Grade ตามเงื่อนไข
                           /*
                            begin
                                select  ratecond
                                  into  v_desc
                                  from  ttbonparc
                                 where  codcomp =  i.codcomp
                                   and  codbon  =  b_index_codbon
                                   and  numtime =  b_index_numtime
                                   and  dteyreap = v_dteyreap
                                   and  numseq   = i.grade
                                   and rownum <=1;
                              exception when no_data_found then
                                    v_desc := '';
                            end;
                            --v_itemXX  := v_desc;
                            */
                            v_item4  := v_seq_grd;
                            v_item5  := i.grade;
                            v_item6  := get_label_name('HRAPSEXC3', global_v_lang, '60'); --'เงื่อนไข';
                            v_item31 := get_label_name('HRAPSEXC3', global_v_lang, '10')||' '||get_label_name('HRAPSEXC3', global_v_lang, '60'); --'สรุปอัตราการจ่ายโบนัสแยกตาม'|| 'เงื่อนไข'

                       end if;
                        ---แกน Y
                        v_item7  := k;
                      --  v_item8  := j.dteyreap;--v_dteyreap;
                        v_item8  := hcm_util.get_year_buddhist_era(j.dteyreap);--v_dteyreap;
                        v_item9 := get_label_name('HRAPSEXC3', global_v_lang, '40'); --'อัตราการจ่ายตามจริง'
                        v_item10 := v_qty_actual;
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
            end loop;--loop j
       end loop; --loop k
       end if;--if flgpass
    end loop;--loop i
    commit;
  end if;-- if v_flgdata
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  procedure get_data_sumary(v_year in varchar2, v_grade in varchar2, v_numcond in number,
                            v_desc out varchar2,
                            v_qty_policy out number,
                            v_qty_actual out number) as
  begin
     if b_index_typeof = 'A' then --Grade ตามการประเมิน
           begin
              select  ratebon
                into  v_qty_policy
                from  ttbonpard
               where  codcomp like hcm_util.get_codcomp_level(b_index_codcomp,1)||'%'
                 and  codbon  = b_index_codbon
                 and  numtime = b_index_numtime
                 and  dteyreap = v_year
                 and  grade    = v_grade;
            exception when no_data_found then
                  v_qty_policy :=0;
            end;
            v_desc := get_tstdis_name(b_index_codcomp,v_year,v_grade,global_v_lang);                                                         
     else--Grade ตามเงื่อนไข
            begin
              select  ratebon ,ratecond
                into  v_qty_policy, v_desc
                from  ttbonparc
               where  codcomp like hcm_util.get_codcomp_level(b_index_codcomp,1)||'%'
                 and  codbon  = b_index_codbon
                 and  numtime = b_index_numtime
                 and  dteyreap = v_year
                 and  numseq   = v_numcond;
            exception when no_data_found then
                  v_qty_policy :=0;
                  v_desc := '';
            end;
      end if;
      --------------
      begin
          select  nvl(sum(nvl(qtybon,0))/count(codempid),0)
            into  v_qty_actual
            from  tbonus
           where  codcomp like hcm_util.get_codcomp_level(b_index_codcomp,1)||'%'
             and  codbon  = b_index_codbon
             and  numtime = b_index_numtime
             and  dteyreap = v_year
             and  decode(b_index_typeof,'A',grade,'O',numcond,grade) = v_grade;
          exception when no_data_found then
              v_qty_actual :=0;
      end;
      if v_desc is null then
        v_qty_policy  := null;
        v_qty_actual  := null;
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  --
end;

/
