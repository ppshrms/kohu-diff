--------------------------------------------------------
--  DDL for Package Body HRAPSGX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSGX" as
  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;

  procedure check_index is
  begin
    if b_index_dteyreap is null then
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

  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
      gen_graph;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';

    v_col           number := 0;
    v_avgbonrate        number := 0;
    v_pctsalrais        number := 0;
    v_sum_avgbonrate    number := 0;
    v_sum_pctsalrais    number := 0;

    cursor c1 is
      select jobgrade
      from  tapprais
      where dteyreap = b_index_dteyreap
      and   codcomp  like b_index_codcomp||'%'
      and   jobgrade is not null --user36 #3744 06/10/2021
      group by jobgrade
      union
      select jobgrade
      from  tbonus
      where dteyreap = b_index_dteyreap
      and   codcomp  like b_index_codcomp||'%'
      and   jobgrade is not null --user36 #3744 06/10/2021
      group by jobgrade
      order by 1;
  begin
    obj_row := json_object_t();
    --New Employee--
    for r1 in c1 loop
      v_flgdata := 'Y';
      --if true then -- check secur7
        --v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;
        --
        v_avgbonrate := 0;
        begin
          select sum(nvl(a.qtybon,0))/count(a.codempid) into v_avgbonrate
            from  tbonus a,temploy1 b
            where a.dteyreap = b_index_dteyreap
            and   a.codcomp  like b_index_codcomp||'%'
            and   a.codempid = b.codempid
            and   stddec(a.amtnbon,a.codempid,v_chken) > 0
            and   a.jobgrade = r1.jobgrade
            and   b.numlvl   between global_v_zminlvl and global_v_zwrklvl
            and   exists (select c.coduser
                          from tusrcom c
                         where c.coduser = global_v_coduser
                           and a.codcomp like c.codcomp||'%');
--#3742
            v_avgbonrate := round(v_avgbonrate, 2);
--#3742
        exception when others then null;
        end;
        --
        v_pctsalrais := 0;
        begin
            select sum(nvl(a.pctadjsal,0))/count(a.codempid) into v_pctsalrais
            from  tapprais a,temploy1 b
            where a.dteyreap = b_index_dteyreap
            and   a.codcomp  like b_index_codcomp||'%'
            and   a.codempid = b.codempid
            and   a.jobgrade = r1.jobgrade
            and   b.numlvl   between global_v_zminlvl and global_v_zwrklvl
            and   exists (select c.coduser
                          from tusrcom c
                         where c.coduser = global_v_coduser
                           and a.codcomp like c.codcomp||'%');
--#3742
            v_pctsalrais := round(v_pctsalrais, 2);
--#3742
        exception when others then null;
        end;
        if nvl(v_avgbonrate,0) > 0 or nvl(v_pctsalrais,0) > 0 then
            v_flgsecur := 'Y';
        end if;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('jobgrade', r1.jobgrade);
        obj_data.put('description', get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang));
/*#3742
        obj_data.put('average', v_avgbonrate);
        obj_data.put('salary', v_pctsalrais);
 #3742 */
--#3742
        obj_data.put('average', to_char(nvl(v_avgbonrate,0),'fm999,999,990.00'));
        obj_data.put('salary', to_char(nvl(v_pctsalrais,0),'fm999,999,990.00'));
--#3742
        obj_row.put(to_char(v_rcnt-1),obj_data);
        --summary--
        v_sum_avgbonrate := v_sum_avgbonrate + nvl(v_avgbonrate,0);
        v_sum_pctsalrais := v_sum_pctsalrais + nvl(v_pctsalrais,0);
      --end if;
    end loop;
    --Summary--
    v_rcnt := v_rcnt + 1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('jobgrade', '');
    obj_data.put('description', get_label_name('HRAPSGX', global_v_lang, '80'));
    --<<user36 #3744 06/10/2021
    v_sum_avgbonrate := 0;
    begin
      select sum(nvl(a.qtybon,0))/count(a.codempid) into v_sum_avgbonrate
      from  tbonus a,temploy1 b
      where a.dteyreap = b_index_dteyreap
      and   a.codcomp  like b_index_codcomp||'%'
      and   a.codempid = b.codempid
      and   stddec(a.amtnbon,a.codempid,v_chken) > 0      
      and   a.jobgrade is not null
      and   b.numlvl   between global_v_zminlvl and global_v_zwrklvl
      and   exists (select c.coduser
                    from tusrcom c
                   where c.coduser = global_v_coduser
                     and a.codcomp like c.codcomp||'%');
      v_sum_avgbonrate := round(v_sum_avgbonrate, 2);
    exception when others then null;
    end;
    v_sum_pctsalrais := 0;
    begin
      select sum(nvl(a.pctadjsal,0))/count(a.codempid) into v_sum_pctsalrais
      from  tapprais a,temploy1 b
      where a.dteyreap = b_index_dteyreap
      and   a.codcomp  like b_index_codcomp||'%'
      and   a.codempid = b.codempid      
      and   a.jobgrade is not null
      and   b.numlvl   between global_v_zminlvl and global_v_zwrklvl
      and   exists (select c.coduser
                    from tusrcom c
                   where c.coduser = global_v_coduser
                     and a.codcomp like c.codcomp||'%');
      v_sum_pctsalrais := round(v_sum_pctsalrais, 2);
    exception when others then null;
    end;
    -->>user36 #3744 06/10/2021
/*#3742
    obj_data.put('average', v_sum_avgbonrate);
    obj_data.put('salary', v_sum_pctsalrais);
*/
--#3742
    obj_data.put('average', to_char(nvl(v_sum_avgbonrate,0),'fm999,999,990.00'));
    obj_data.put('salary', to_char(nvl(v_sum_pctsalrais,0),'fm999,999,990.00'));
--#3742
    obj_row.put(to_char(v_rcnt-1),obj_data);

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tbonus');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSGX';
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

    v_avgbonrate        number := 0;
    v_pctsalrais        number := 0;
    v_sum_avgbonrate    number := 0;
    v_sum_pctsalrais    number := 0;

    cursor c1 is
      select jobgrade
      from  tapprais
      where dteyreap = b_index_dteyreap
      and   codcomp  like b_index_codcomp||'%'
      and   jobgrade is not null --user36 #3744 06/10/2021
      group by jobgrade
      union
      select jobgrade
      from  tbonus
      where dteyreap = b_index_dteyreap
      and   codcomp  like b_index_codcomp||'%'
      and   jobgrade is not null --user36 #3744 06/10/2021
      group by jobgrade
      order by 1;

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

    v_item31 := get_label_name('HRAPSGXC2', global_v_lang, '10'); --Graph Name

--    for v_type in 1..2 loop
        for r1 in c1 loop
            v_flgdata := 'Y';
            ----------Axis X level 2(from data column)
--            if v_type = 1 then
                v_avgbonrate := 0;
                begin
                    select sum(nvl(a.qtybon,0))/count(a.codempid) into v_avgbonrate
                    from  tbonus a,temploy1 b
                    where a.dteyreap = b_index_dteyreap
                    and   a.codcomp  like b_index_codcomp||'%'
                    and   a.codempid = b.codempid
                    and   stddec(a.amtnbon,a.codempid,v_chken) > 0
                    and   a.jobgrade = r1.jobgrade
                    and   b.numlvl   between global_v_zminlvl and global_v_zwrklvl
                    and   exists (select c.coduser
                                  from tusrcom c
                                 where c.coduser = global_v_coduser
                                   and a.codcomp like c.codcomp||'%');
                exception when no_data_found then null;
                end;
--            else
                v_pctsalrais := 0;
                begin
                    select sum(nvl(a.pctadjsal,0))/count(a.codempid) into v_pctsalrais
                    from  tapprais a,temploy1 b
                    where a.dteyreap = b_index_dteyreap
                    and   a.codcomp  like b_index_codcomp||'%'
                    and   a.codempid = b.codempid
                    and   a.jobgrade = r1.jobgrade
                    and   b.numlvl   between global_v_zminlvl and global_v_zwrklvl
                    and   exists (select c.coduser
                                  from tusrcom c
                                 where c.coduser = global_v_coduser
                                   and a.codcomp like c.codcomp||'%');
                exception when no_data_found then null;
                end;
--            end if;

            v_item4  := r1.jobgrade;
            v_item5  := get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang);
            ----------Axis X level 1(from data row)
            v_item8  := get_label_name('HRAPSGX', global_v_lang, '60');
            ----------Axis Y Label
            v_item9  := get_label_name('HRAPSGXC2', global_v_lang, '30'); --อัตราการจ่าย / % การขึ้นเงินเดือน
            v_item10 := to_char(nvl(v_avgbonrate,0),'fm9,999,990.00');

            v_item6 := get_label_name('HRAPSGX', global_v_lang, '40');
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

             v_item10 := to_char(nvl(v_pctsalrais,0),'fm9,999,990.00');

            v_item8  := get_label_name('HRAPSGX', global_v_lang, '70');
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
        end loop; --c1
--    end loop; --avg/pct

    commit;

    if v_numseq > 1 then
        param_msg_error := get_error_msg_php('HR2720', global_v_lang);
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tbonus');
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/
