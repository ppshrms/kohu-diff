--------------------------------------------------------
--  DDL for Package Body HRAPSJX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSJX" is
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

    --block b_index
    b_index_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteyear    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_numtime    := hcm_util.get_string_t(json_obj,'p_numseq');

    --Group รายละเอียด
    b_index_v_grp1     := get_label_name('HRAPSJX', global_v_lang, '60');
    b_index_v_grp2     := get_label_name('HRAPSJX', global_v_lang, '70');
    b_index_v_grp3     := get_label_name('HRAPSJX', global_v_lang, '80');

    --HEADER GRAPH
    b_index_v_graph1   := get_label_name('HRAPSJX', global_v_lang, '90');
    b_index_v_graph2   := get_label_name('HRAPSJX', global_v_lang, '100');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
--        gen_head(json_str_output);
        gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_head(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';

    cursor c1 is
      select distinct grdap grdap
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
      order by grdap;

  begin
    obj_row := json_object_t();

    for i in c1 loop
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seq',v_rcnt);
      obj_data.put('grade',i.grdap);
--
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_codcomp       varchar2(400 char);
    v_jobgrade      varchar2(400 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);

    v_cntemp        number := 0;
    v_cntall        number := 0;
    v_dteyreap      number := 0;
    v_year          number := 0;
    v_desc          varchar2(4000 char);
    v_grade_seq     number := 1;
    v_grade1        number := 0;
    v_grade2        number := 0;
    v_grade3        number := 0;
    v_grade4        number := 0;
    v_grade5        number := 0;

    sum_grade1      number := 0;
    sum_grade2      number := 0;
    sum_grade3      number := 0;
    sum_grade4      number := 0;
    sum_grade5      number := 0;
    sum_cntall      number := 0;

    cursor c1 is
      select distinct jobgrade
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
      order by jobgrade;

    cursor c2 is
      select distinct grdap grdap
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and grdap is not null --User37 #3756 14/09/2021
      order by grdap;

    v_numseq        number := 0;
    v_max_grade     number := 0;

  begin
    -->> insert data for static report
      BEGIN
          DELETE ttemprpt
           WHERE codempid = global_v_codempid
             AND codapp = 'HRAPSJX1';
      EXCEPTION WHEN OTHERS THEN
        NULL;
      END;

    INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                           item2, item3, item4)
                  VALUES ( global_v_codempid, 'HRAPSJX1', 1, 'DETAIL',
                           b_index_codcomp, hcm_util.get_year_buddhist_era(b_index_dteyear), b_index_numtime);

    begin
        select nvl(max(numseq),0)
          into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRAPSJX1';
    exception when others then
        v_numseq := 0;
    end;
    v_numseq := nvl(v_numseq,0) + 1;
    --<<insert data for static report

      select count(distinct grdap)
        into v_max_grade
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime;

    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';
      v_jobgrade := i.jobgrade;
      v_desc := get_tcodec_name('TCODJOBG', i.jobgrade, global_v_lang);
      v_rcnt := v_rcnt+1;
      v_cntall := 0;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seq',v_rcnt);
      obj_data.put('jobgrade',i.jobgrade);
      obj_data.put('desc_jobgrade',v_desc);
      v_grade_seq := 1;
      for j in c2 loop
        begin
            select count(distinct codempid) into v_cntemp
              from tappemp
             where codcomp like b_index_codcomp||'%'
               and dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and jobgrade = i.jobgrade
               and grdap = j.grdap
               and numlvl between global_v_zminlvl and global_v_zwrklvl;
            exception when others then v_cntemp := 0;
        end;
        v_cntall := v_cntall + nvl(v_cntemp,0);
        obj_data.put('grade'||v_grade_seq, v_cntemp);
        if v_grade_seq = 1 then
            v_grade1 := nvl(v_cntemp,0);
        elsif v_grade_seq = 2 then
            v_grade2 := nvl(v_cntemp,0);
        elsif v_grade_seq = 3 then
            v_grade3 := nvl(v_cntemp,0);
        elsif v_grade_seq = 4 then
            v_grade4 := nvl(v_cntemp,0);
        elsif v_grade_seq = 5 then
            v_grade5 := nvl(v_cntemp,0);
        end if;
        v_grade_seq := v_grade_seq + 1;
      end loop;
      obj_data.put('total',v_cntall);
      obj_row.put(to_char(v_rcnt-1),obj_data);

      if v_max_grade <= 1 then
        v_grade5    := null;
        v_grade4    := null;
        v_grade3    := null;
        v_grade2    := null;
      elsif v_max_grade <= 2 then
        v_grade5    := null;
        v_grade4    := null;
        v_grade3    := null;
      elsif v_max_grade <= 3 then
        v_grade5    := null;
        v_grade4    := null;
      elsif v_max_grade <= 4 then
        v_grade5    := null;
      end if;
      -->>insert data for static report
      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                               item2, item3, item4,
                               item5, item6,
                               item7, item8, item9,item10,
                               item11,item12)
                    VALUES ( global_v_codempid, 'HRAPSJX1', v_numseq, 'TABLE',
                               b_index_codcomp, hcm_util.get_year_buddhist_era(b_index_dteyear), b_index_numtime,
                               v_jobgrade,v_desc,
                               v_grade1, v_grade2, v_grade3, v_grade4, v_grade5, v_cntall);
      v_numseq := v_numseq + 1;
      sum_grade1    := sum_grade1 + v_grade1;
      sum_grade2    := sum_grade2 + v_grade2;
      sum_grade3    := sum_grade3 + v_grade3;
      sum_grade4    := sum_grade4 + v_grade4;
      sum_grade5    := sum_grade5 + v_grade5;
      sum_cntall    := sum_cntall + v_cntall;
      --<<insert data for static report

    end loop;

      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                               item2, item3, item4,
                               item5, item6,
                               item7, item8, item9,item10,
                               item11,item12)
                    VALUES ( global_v_codempid, 'HRAPSJX1', v_numseq, 'TABLE',
                               b_index_codcomp, hcm_util.get_year_buddhist_era(b_index_dteyear), b_index_numtime,
                               '',get_label_name('HRAPSJXC1', global_v_lang, 70),
                               sum_grade1, sum_grade2, sum_grade3, sum_grade4, sum_grade5, sum_cntall);

    if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_graph (json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_left      json_object_t;
    obj_rigth     json_object_t;

    obj_text_leftX      json_object_t;
    obj_text_leftY      json_object_t;
    obj_row_leftX      json_object_t;
    obj_row_leftY      json_object_t;
    obj_data_left      json_object_t;
    obj_text_rigth     json_object_t;
    obj_data_rigth     json_object_t;

    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSJX';
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

    j           varchar2(10 char);
    v_flgdata   varchar2(1 char) := 'N';
    v_cnt       number := 0;

    v_cntemp        number := 0;
    v_cntall        number := 0;
    v_dteyreap      number := 0;
    v_year          number := 0;
    v_desc          varchar2(4000 char);
    v_grade_seq     number := 1;
    v_grade1        number := 0;
    v_grade2        number := 0;
    v_grade3        number := 0;
    v_grade4        number := 0;
    v_grade5        number := 0;
    v_row           number := 0;
    v_row2          number := 0;
    v_row3          number := 0;

    cursor c1 is
      select distinct jobgrade jobgrade
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and jobgrade is not null --User37 #3756 14/09/2021
      order by jobgrade;

    cursor c2 is
      select distinct grdap grdap
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and numlvl between global_v_zminlvl and global_v_zwrklvl
         and grdap is not null --User37 #3756 14/09/2021
      order by grdap;
  begin

    param_msg_error := null;
    obj_text_leftX := json_object_t();
    for i in c1 loop
      obj_text_leftX.put(to_char(v_row),i.jobgrade);
      v_row := v_row + 1;
    end loop;
    ---------------------------------

    obj_row_leftY := json_object_t();
    v_row2 := 0;
    for j in c2 loop
      obj_row_leftX := json_object_t();
      v_row3 := 0;
      for k in c1 loop
        begin
          select count(distinct codempid) into v_cntemp
            from tappemp
           where codcomp like b_index_codcomp||'%'
             and dteyreap = b_index_dteyear
             and numtime = b_index_numtime
             and jobgrade = k.jobgrade
             and grdap = j.grdap
             and numlvl between global_v_zminlvl and global_v_zwrklvl;
          exception when others then v_cntemp := 0;
        end;
        obj_row_leftX.put(to_char(v_row3),to_char(v_cntemp));
        v_row3 := v_row3 + 1;
      end loop;
      obj_text_leftY := json_object_t();
      obj_text_leftY.put('label', j.grdap);
      obj_text_leftY.put('data', obj_row_leftX);
      obj_row_leftY.put(to_char(v_row2),obj_text_leftY);

      v_row2 := v_row2 + 1;
    end loop;
    ---------------------------------
    obj_data_rigth := json_object_t();
    obj_text_rigth := json_object_t();

    v_row2 := 0;
    for j in c2 loop
      begin
        select count(distinct codempid) into v_cntemp
          from tappemp
         where codcomp like b_index_codcomp||'%'
           and dteyreap = b_index_dteyear
           and numtime = b_index_numtime
           and grdap = j.grdap
           and numlvl between global_v_zminlvl and global_v_zwrklvl;
        exception when others then v_cntemp := 0;
      end;
      v_cntall := v_cntall + nvl(v_cntemp,0);
      --
      obj_data_rigth.put(to_char(v_row2),nvl(v_cntemp,0));
--      obj_text_rigth.put(to_char(v_row2),j.grdap||' : '||nvl(v_cntemp,0));--User37 #3757 06/10/2021 obj_text_rigth.put(to_char(v_row2),j.grdap);
      obj_text_rigth.put(to_char(v_row2),j.grdap);
      v_row2 := v_row2 + 1;
    end loop;

    obj_left  := json_object_t();
    obj_left.put('graphLeftX', obj_text_leftX);
    obj_left.put('graphLeftY', obj_row_leftY);

    obj_rigth  := json_object_t();
    obj_rigth.put('grade', obj_text_rigth);
    obj_rigth.put('graphRightY', obj_data_rigth);
    obj_rigth.put('totalEmps', v_cntall);

    obj_data  := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('graphLeft',obj_left);
    obj_data.put('graphRight',obj_rigth);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_graph2 is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSJX2';
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

    v_jobgrade  varchar2(10 char);
    v_grdap     varchar2(10 char);
    j           varchar2(10 char);
    v_flgdata   varchar2(1 char) := 'N';
    v_dteyreap  number := 0;
    v_cntemp1   number := 0;
    v_cntemp2   number := 0;

    cursor c1 is
      select distinct jobgrade jobgrade
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and numlvl between global_v_zminlvl and global_v_zwrklvl
      order by jobgrade;

    cursor c2 is
      select distinct grdap grdap
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and numlvl between global_v_zminlvl and global_v_zwrklvl
      order by grdap;

  begin
    v_numseq := 1;
    param_msg_error := null;
    v_item1  := get_label_name('HRAPSJX', global_v_lang, '90'); --'% พนักงาน'
    v_item31 := get_label_name('HRAPSJX', global_v_lang, '110'); --'เปรียบเทียบ Performance Grade ของพนักงานในแต่ละปี'

    for i in c1 loop
        v_flgdata := 'Y';
        v_dteyreap := b_index_dteyear;
        v_jobgrade := i.jobgrade;
        for j in c2 loop
        ---------- Group1
            v_item7  := i.jobgrade;
            v_item8  := get_tcodec_name('TCODJOBG', i.jobgrade, global_v_lang);
--            v_item9  := get_label_name('HRAPSJX', global_v_lang, '90'); --'% พนักงาน';
        ----------แกน x
            v_item4  := j.grdap;
            v_item5  := j.grdap;
--            v_item6  := get_label_name('HRAPSJX', global_v_lang, '30'); --'ปี';

        ----------ค่าข้อมูล (จำนวนพนักงานทั้งหมด)
            v_cntemp1 := 0;  v_cntemp2:= 0;
            begin
                select count(distinct codempid) into v_cntemp1
                  from tappemp
                 where codcomp like b_index_codcomp||'%'
                   and dteyreap = b_index_dteyear
                   and numtime  = b_index_numtime
                   and jobgrade = i.jobgrade
                   and grdap    = j.grdap
                   and numlvl between global_v_zminlvl and global_v_zwrklvl;
                exception when others then v_cntemp1 := 0;
            end;
--
            v_item10 := v_cntemp1;
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

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  --
  procedure gen_grade (json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_grade     json_object_t;

    v_row           number := 0;

    cursor c1 is
      select distinct grdap grdap
        from tappemp
       where codcomp like b_index_codcomp||'%'
         and dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and numlvl between global_v_zminlvl and global_v_zwrklvl
         and grdap is not null --User37 #3756 14/09/2021
      order by grdap;
  begin

    v_row := 0;
    obj_grade := json_object_t();
    for r1 in c1 loop
      v_row := v_row + 1;
      obj_grade.put('grade'||to_char(v_row),r1.grdap);
    end loop;

    obj_data  := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('grade',obj_grade);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end;

/
