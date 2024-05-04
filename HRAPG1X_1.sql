--------------------------------------------------------
--  DDL for Package Body HRAPG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPG1X" as
  procedure initial_value(json_str in clob) is
    json_obj      json_object_t;
    json_syncond  json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_syncond     := hcm_util.get_string_t(json_obj,'p_syncond');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_codbon      := hcm_util.get_string_t(json_obj,'p_codbonus');
    b_index_codtency    := hcm_util.get_string_t(json_obj,'p_codtencyt');
    b_index_typdata     := hcm_util.get_string_t(json_obj,'p_flgtype');
    b_index_comlevel    := hcm_util.get_string_t(json_obj,'p_complvl');

    b_index_dteyreap    := nvl(b_index_dteyreap,to_char(sysdate,'yyyy'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure get_last_kpi_org(json_str_input in clob,json_str_output out clob) is
    obj_data      json_object_t;
    v_max_time    varchar2(200);
  begin
    obj_data    := json_object_t();
    begin
      select max(dteyreap||'*'||numtime)
        into v_max_time
        from tkpicmphs
       where 1 = 1
         and codcompy   = nvl(b_index_codcompy,codcompy)
         and exists (select 1
                       from tusrcom us
                      where tkpicmphs.codcompy  like us.codcomp||'%'
                        and us.coduser          = global_v_coduser)
         and rownum   = 1;
    exception when no_data_found then
      null;
    end;

    obj_data.put('coderror','200');
    obj_data.put('dteyreap',substr(v_max_time,1,instr(v_max_time,'*') - 1));
    obj_data.put('numtime',substr(v_max_time,instr(v_max_time,'*') + 1));
  end;
  --
  procedure gen_kpi_organize(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_qty       json_array_t;
    array_data      json_array_t;
    cursor c1 is
      select a.codkpi, a.kpides, sum(b.qtyscor) as qtyscor
        from tkpicmph  a,  tkpicmphs  b
       where a.dteyreap      = b_index_dteyreap
         and a.codcompy      = nvl(b_index_codcompy,a.codcompy)
         and b.numtime       = b_index_numtime
         and a.dteyreap      = b.dteyreap
         and a.codcompy      = b.codcompy
         and a.codkpi        = b.codkpi
         and exists (select 1
                       from tusrcom us
                      where a.codcompy    like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
      group by a.codkpi, a.kpides
      order by a.codkpi;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty     := json_array_t();

    for i in c1 loop
--      array_label.append(i.codkpi||' '||i.kpides);
      array_label.append(i.codkpi);
      array_qty.append(i.qtyscor);
    end loop;
    array_data    := json_array_t();
    array_data.append(array_qty);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_kpi_organize(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_kpi_organize(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_last_kpi_department(json_str_input in clob,json_str_output out clob) is
    obj_data      json_object_t;
    v_max_time    varchar2(200);
  begin
    obj_data    := json_object_t();
    begin
      select max(dteyreap||'*'||numtime)
        into v_max_time
        from tkpidph
       where 1 = 1
         and codcomp    = nvl(b_index_codcomp,codcomp)
         and exists (select 1
                       from tusrcom us
                      where tkpidph.codcomp  like us.codcomp||'%'
                        and us.coduser       = global_v_coduser)
         and rownum   = 1;
    exception when no_data_found then
      null;
    end;

    obj_data.put('coderror','200');
    obj_data.put('dteyreap',substr(v_max_time,1,instr(v_max_time,'*') - 1));
    obj_data.put('numtime',substr(v_max_time,instr(v_max_time,'*') + 1));
  end;
  --
  procedure gen_kpi_department(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_qty       json_array_t;
    array_data      json_array_t;
    cursor c1 is
      select  codkpino, kpides, nvl(qtyscor,0) qtyscor
        from  tkpidph  b
       where  dteyreap      = b_index_dteyreap
         and  numtime       = b_index_numtime
--         and  codcomp       = nvl(hcm_util.get_codcomp_level(b_index_codcomp,null),codcomp)
         and  codcomp       like b_index_codcomp||'%'
         and exists (select 1
                       from tusrcom us
                      where b.codcomp     like us.codcomp||'%'
                        and us.coduser    = global_v_coduser)
      order by codkpino;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty     := json_array_t();

    for i in c1 loop
--      array_label.append(i.codkpino||' '||i.kpides);
      array_label.append(i.codkpino);
      array_qty.append(i.qtyscor);
    end loop;
    array_data    := json_array_t();
    array_data.append(array_qty);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_kpi_department(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_kpi_department(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_annual_salary_increase(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_qty1      json_array_t;
    array_qty2      json_array_t;
    array_qty3      json_array_t;
    array_per1      json_array_t;
    array_per2      json_array_t;
    array_per3      json_array_t;
    array_data1     json_array_t;
    array_data2     json_array_t;
    array_head_label json_array_t;
    v_curr_year     number := to_char(sysdate,'yyyy');
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
      select codcomp
      from (
        select distinct hcm_util.get_codcomp_level(codcomp, b_index_comlevel) codcomp
          from tapprais
         where codcomp  like b_index_codcompy||'%'
           and dteyreap in (v_curr_year, v_curr_year - 1, v_curr_year - 2)
           and numlvl   between global_v_zminlvl and global_v_zwrklvl
           and exists (select 1
                       from tusrcom us
                      where tapprais.codcomp    like us.codcomp||'%'
                        and us.coduser          = global_v_coduser)
        order by codcomp)
      group by codcomp
      order by codcomp;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty1    := json_array_t();
    array_qty2    := json_array_t();
    array_qty3    := json_array_t();
    array_per1    := json_array_t();
    array_per2    := json_array_t();
    array_per3    := json_array_t();

    for i in c1 loop
      array_label.append(i.codcomp);
      for j in 1..3 loop
        if j = 1 then  --จำนวนคน
          begin
            select count(dteyreap) into v_cntemp1
              from tapprais
             where codcomp like i.codcomp||'%'
               and dteyreap = v_curr_year
               and numlvl between global_v_zminlvl and global_v_zwrklvl
               and exists (select 1
                             from tusrcom us
                            where tapprais.codcomp    like us.codcomp||'%'
                              and us.coduser          = global_v_coduser);
          end;
          -----
          begin
            select count(dteyreap) into v_cntemp2
              from tapprais
             where codcomp like i.codcomp||'%'
               and dteyreap = v_curr_year - 1
               and numlvl between global_v_zminlvl and global_v_zwrklvl
               and exists (select 1
                             from tusrcom us
                            where tapprais.codcomp    like us.codcomp||'%'
                              and us.coduser          = global_v_coduser);
          end;
          -----
          begin
            select count(dteyreap) into v_cntemp3
              from tapprais
             where codcomp like i.codcomp||'%'
               and dteyreap = v_curr_year - 2
               and numlvl between global_v_zminlvl and global_v_zwrklvl
               and exists (select 1
                             from tusrcom us
                            where tapprais.codcomp    like us.codcomp||'%'
                              and us.coduser          = global_v_coduser);
          end;
        elsif j = 2 then  --จำนวนเงิน(ปรับสุทธิ)
          begin
            select sum(nvl(stddec(amtsal,tapprais.codempid,global_v_chken),0))  ,
                   sum(nvl(stddec(amtsaln,tapprais.codempid,global_v_chken),0))
              into v_amtsal, v_amtsaln
              from tapprais
             where codcomp like i.codcomp||'%'
               and dteyreap = v_curr_year
               and numlvl between global_v_zminlvl and global_v_zwrklvl
               and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
               and exists (select 1
                             from tusrcom us
                            where tapprais.codcomp    like us.codcomp||'%'
                              and us.coduser          = global_v_coduser);
            v_dipsal1 := (nvl(v_amtsaln,0) - nvl(v_amtsal,0));
          end;
          array_qty1.append(to_char(v_dipsal1,'fm99999990.00'));
          -----
          begin
            select sum(nvl(stddec(amtsal,tapprais.codempid,global_v_chken),0))  ,
                   sum(nvl(stddec(amtsaln,tapprais.codempid,global_v_chken),0))
              into v_amtsal, v_amtsaln
              from tapprais
             where codcomp like i.codcomp||'%'
               and dteyreap = v_curr_year - 1
               and numlvl between global_v_zminlvl and global_v_zwrklvl
               and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
               and exists (select 1
                             from tusrcom us
                            where tapprais.codcomp    like us.codcomp||'%'
                              and us.coduser          = global_v_coduser);
            v_dipsal2 := (nvl(v_amtsaln,0) - nvl(v_amtsal,0));
          end;
          array_qty2.append(to_char(v_dipsal2,'fm99999990.00'));
          -----
          begin
            select sum(nvl(stddec(amtsal,tapprais.codempid,global_v_chken),0))  ,
                   sum(nvl(stddec(amtsaln,tapprais.codempid,global_v_chken),0))
              into v_amtsal, v_amtsaln
              from tapprais
             where codcomp like i.codcomp||'%'
               and dteyreap = v_curr_year - 2
               and numlvl between global_v_zminlvl and global_v_zwrklvl
               and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
               and exists (select 1
                             from tusrcom us
                            where tapprais.codcomp    like us.codcomp||'%'
                              and us.coduser          = global_v_coduser);
            v_dipsal3 := (nvl(v_amtsaln,0) - nvl(v_amtsal,0));
          end;
          array_qty3.append(to_char(v_dipsal3,'fm99999990.00'));
        else  -- % การขึ้นเงินเดือนเฉลี่ย
          v_perc1 := null;
          if nvl(v_cntemp1,0) > 0 then
            v_perc1 := (v_dipsal1 / v_cntemp1) / 100;
          end if;
          array_per1.append(to_char(nvl(v_perc1,0),'fm990.00'));
          -----
          v_perc2 := null;
          if nvl(v_cntemp2,0) > 0 then
            v_perc2 := (v_dipsal2 / v_cntemp2) / 100;
          end if;
          array_per2.append(to_char(nvl(v_perc2,0),'fm990.00'));
          -----
          v_perc3 := null;
          if nvl(v_cntemp3,0) > 0 then
            v_perc3 := (v_dipsal3 / v_cntemp3) / 100;
          end if;
          array_per3.append(to_char(nvl(v_perc3,0),'fm990.00'));
          -----
        end if;
      end loop;
    end loop;
    array_data1   := json_array_t();
    array_data1.append(array_qty1);
    array_data1.append(array_qty2);
    array_data1.append(array_qty3);

    array_data2   := json_array_t();
    array_data2.append(array_per1);
    array_data2.append(array_per2);
    array_data2.append(array_per3);

    array_head_label  := json_array_t();
    array_head_label.append(v_curr_year);
    array_head_label.append(v_curr_year - 1);
    array_head_label.append(v_curr_year - 2);

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    if b_index_typdata = '1' then
      obj_data.put('data',array_data1);
    else
      obj_data.put('data',array_data2);
    end if;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_annual_salary_increase(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_annual_salary_increase(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_bonus_expense(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label json_array_t;
    array_label     json_array_t;
    array_amt1      json_array_t;
    array_amt2      json_array_t;
    array_amt3      json_array_t;
    array_data      json_array_t;
    v_curr_year     number := to_char(sysdate,'yyyy');
    v_amtnbon       number := 0;
    v_comp_length   number := 3;

    cursor c1 is
      select distinct substr(codcomp, 1, v_comp_length) codcomp
        from tbonus
       where codcomp  like b_index_codcompy||'%'
         and codbon   = nvl(b_index_codbon,codbon)
         and dteyreap in (v_curr_year, v_curr_year - 1, v_curr_year - 2)
         and nvl(stddec(amtnbon,tbonus.codempid,global_v_chken),0) > 0
         and staappr = 'Y'
         and exists (select 1
                       from temploy1 emp
                      where emp.codempid  = tbonus.codempid
                        and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
         and exists (select 1
                       from tusrcom us
                      where tbonus.codcomp  like us.codcomp||'%'
                        and us.coduser      = global_v_coduser)
      group by substr(codcomp, 1, v_comp_length)
      order by substr(codcomp, 1, v_comp_length);
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_amt1    := json_array_t();
    array_amt2    := json_array_t();
    array_amt3    := json_array_t();

    begin
      Select sum(qtycode) into v_comp_length
        from tsetcomp
       where numseq <= b_index_comlevel;
    exception when others then v_comp_length := 3;
      v_comp_length := nvl(v_comp_length , 3);
    end;
    for i in c1 loop
      array_label.append(i.codcomp);
      begin
        select sum(nvl(stddec(amtnbon,tbonus.codempid,global_v_chken),0))
          into v_amtnbon
          from tbonus
         where codcomp like i.codcomp||'%'
           and codbon   = nvl(b_index_codbon,codbon)
           and dteyreap = v_curr_year
           and nvl(stddec(amtnbon,tbonus.codempid,global_v_chken),0) > 0
           and staappr = 'Y'
           and exists (select 1
                       from temploy1 emp
                      where emp.codempid  = tbonus.codempid
                        and emp.numlvl between global_v_zminlvl and global_v_zwrklvl
                        and emp.numlvl between global_v_numlvlsalst and global_v_numlvlsalen)
           and exists (select 1
                         from tusrcom us
                        where tbonus.codcomp      like us.codcomp||'%'
                          and us.coduser          = global_v_coduser);
      end;
      array_amt1.append(to_char(nvl(v_amtnbon,0),'fm99999990.00'));
      -----
      begin
        select sum(nvl(stddec(amtnbon,tbonus.codempid,global_v_chken),0))
          into v_amtnbon
          from tbonus
         where codcomp like i.codcomp||'%'
           and codbon   = nvl(b_index_codbon,codbon)
           and dteyreap = v_curr_year - 1
           and nvl(stddec(amtnbon,tbonus.codempid,global_v_chken),0) > 0
           and staappr = 'Y'
           and exists (select 1
                       from temploy1 emp
                      where emp.codempid  = tbonus.codempid
                        and emp.numlvl between global_v_zminlvl and global_v_zwrklvl
                        and emp.numlvl between global_v_numlvlsalst and global_v_numlvlsalen)
           and exists (select 1
                         from tusrcom us
                        where tbonus.codcomp      like us.codcomp||'%'
                          and us.coduser          = global_v_coduser);
      end;
      array_amt2.append(to_char(nvl(v_amtnbon,0),'fm99999990.00'));
      -----
      begin
        select sum(nvl(stddec(amtnbon,tbonus.codempid,global_v_chken),0))
          into v_amtnbon
          from tbonus
         where codcomp like i.codcomp||'%'
           and codbon   = nvl(b_index_codbon,codbon)
           and dteyreap = v_curr_year - 2
           and nvl(stddec(amtnbon,tbonus.codempid,global_v_chken),0) > 0
           and staappr = 'Y'
           and exists (select 1
                       from temploy1 emp
                      where emp.codempid  = tbonus.codempid
                        and emp.numlvl between global_v_zminlvl and global_v_zwrklvl
                        and emp.numlvl between global_v_numlvlsalst and global_v_numlvlsalen)
           and exists (select 1
                         from tusrcom us
                        where tbonus.codcomp      like us.codcomp||'%'
                          and us.coduser          = global_v_coduser);
      end;
      array_amt3.append(to_char(nvl(v_amtnbon,0),'fm99999990.00'));
    end loop;
    array_head_label := json_array_t();
    array_head_label.append(v_curr_year);
    array_head_label.append(v_curr_year - 1);
    array_head_label.append(v_curr_year - 2);

    array_data    := json_array_t();
    array_data.append(array_amt1);
    array_data.append(array_amt2);
    array_data.append(array_amt3);

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_bonus_expense(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_bonus_expense(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_last_kpi_gap(json_str_input in clob,json_str_output out clob) is
    obj_data      json_object_t;
    v_max_time    varchar2(200);
  begin
    obj_data    := json_object_t();
    begin
      select max(dteyreap||'*'||numtime)
        into v_max_time
        from tappemp
       where 1 = 1
         and codcomp    = nvl(b_index_codcomp,codcomp)
         and exists (select 1
                       from temploy1 emp
                      where emp.codempid  = tappemp.codempid
                        and emp.numlvl    between global_v_zminlvl and global_v_zwrklvl)
         and exists (select 1
                       from tusrcom us
                      where tappemp.codcomp  like us.codcomp||'%'
                        and us.coduser       = global_v_coduser)
         and rownum   = 1;
    exception when no_data_found then
      null;
    end;

    obj_data.put('coderror','200');
    obj_data.put('dteyreap',substr(v_max_time,1,instr(v_max_time,'*') - 1));
    obj_data.put('numtime',substr(v_max_time,instr(v_max_time,'*') + 1));
  end;
  --
  procedure gen_gap_competency(json_str_output out clob) is
    obj_data        json_object_t;
    array_label     json_array_t;
    array_qty       json_array_t;
    array_data      json_array_t;

    cursor c1 is
      select b.codskill, count(a.codempid) as empdownstd
        from tappemp a,tappcmpf b,temploy1 e
       where a.codempid = b.codempid
         and a.dteyreap = b.dteyreap
         and a.numtime  = b.numtime
         and a.codcomp  like hcm_util.get_codcomp_level(b_index_codcomp,null)||'%'
         and a.dteyreap = b_index_dteyreap
         and a.numtime  = b_index_numtime
         and b.codtency = nvl(b_index_codtency,b.codtency)
         and a.codempid = e.codempid
         and e.numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists (select c.coduser
                       from tusrcom c
                      where c.coduser = global_v_coduser
                        and a.codcomp like c.codcomp||'%')
      group by b.codskill
      order by b.codskill;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty     := json_array_t();

    for r1 in c1 loop
      array_label.append(get_tcodec_name('TCODSKIL',r1.codskill,global_v_lang));
      array_qty.append(r1.empdownstd);
    end loop;
    array_data    := json_array_t();
    array_data.append(array_qty);

    obj_data.put('coderror','200');
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_gap_competency(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_gap_competency(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_performance_grade(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label json_array_t;
    array_label     json_array_t;
    array_qty1      json_array_t;
    array_qty2      json_array_t;
    array_qty3      json_array_t;
    array_data      json_array_t;
    v_current_year  number := to_char(sysdate,'yyyy');
    v_year          number;

    v_stmt          varchar2(5000);
    v_stmt2         varchar2(5000);
    v_cntemp1       number;
    v_cntemp2       number;

    cursor c1 is
      select distinct grade grade
        from tstdis a
       where codcomp like b_index_codcompy||'%'
         and dteyreap in (v_current_year, v_current_year - 1, v_current_year - 2)
         and exists (select c.coduser
                       from tusrcom c
                      where c.coduser = global_v_coduser
                        and a.codcomp like c.codcomp||'%')
      order by grade;
  begin
    obj_data      := json_object_t();
    array_label   := json_array_t();
    array_qty1    := json_array_t();
    array_qty2    := json_array_t();
    array_qty3    := json_array_t();

    for i in c1 loop
      array_label.append(i.grade);
      for j in 1..3 loop
        if j = 1 then
          v_year := v_current_year;
        elsif j = 2 then
          v_year := v_current_year - 1;
        else
          v_year := v_current_year - 2;
        end if;

        v_stmt2 := 'select count(distinct tapprais.codempid)
                      from tapprais, tstdisd
                     where tapprais.codcomp     like tstdisd.codcomp||''%''
                       and tapprais.dteyreap    = tstdisd.dteyreap
                       and tapprais.codcomp like '''||b_index_codcompy||'''||''%''
                       and tapprais.dteyreap     = '||v_year||'
                       and tapprais.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||'
                       and exists (select c.coduser
                                     from tusrcom c
                                    where c.coduser = '''||global_v_coduser||'''
                                      and tapprais.codcomp like c.codcomp||''%'')';
--#5552
        v_stmt2 := v_stmt2||' and exists(select codaplvl
                                  from tempaplvl
                                 where dteyreap = tstdisd.dteyreap
                                   and numseq  = tstdisd.numtime
                                   and codaplvl = tstdisd.codaplvl
                                   and codempid = tappraiscodempid) ';
--#5552
        if b_index_syncond is not null then
          v_stmt2 := v_stmt2 ||' and '||b_index_syncond;
        end if;

        begin
          execute immediate v_stmt2 into v_cntemp2;
        exception when others then v_cntemp2 := 0;
        end;

        v_stmt := 'select count(distinct tapprais.codempid)
                     from tapprais, tstdisd
                    where tapprais.codcomp     like tstdisd.codcomp||''%''
                      and tapprais.dteyreap    = tstdisd.dteyreap
                      and tapprais.codcomp like '''||b_index_codcompy||'''||''%''
                      and tapprais.dteyreap     = '||v_year||'
                      and tapprais.grade        = '''||i.grade||'''
                      and tapprais.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||'
                      and exists (select c.coduser
                                    from tusrcom c
                                   where c.coduser = '''||global_v_coduser||'''
                                     and tapprais.codcomp like c.codcomp||''%'')';
--#5552
        v_stmt := v_stmt||' and exists(select codaplvl
                                  from tempaplvl
                                 where dteyreap = tstdisd.dteyreap
                                   and numseq  = tstdisd.numtime
                                   and codaplvl = tstdisd.codaplvl
                                   and codempid = tappraiscodempid) ';
--#5552
        if b_index_syncond is not null then
          v_stmt := v_stmt ||' and '||b_index_syncond;
        end if;

        begin
          execute immediate v_stmt into v_cntemp1;
        exception when others then v_cntemp1 := 0;
        end;

        if j = 1 then
          if v_cntemp1 <> 0 then
            array_qty1.append((v_cntemp2 / v_cntemp1) * 100);
          else
            array_qty1.append(0);
          end if;
        elsif j = 2 then
          if v_cntemp1 <> 0 then
            array_qty2.append((v_cntemp2 / v_cntemp1) * 100);
          else
            array_qty2.append(0);
          end if;
        else
          if v_cntemp1 <> 0 then
            array_qty3.append((v_cntemp2 / v_cntemp1) * 100);
          else
            array_qty3.append(0);
          end if;
        end if;
      end loop;
    end loop;
    array_data    := json_array_t();
    array_data.append(array_qty1);
    array_data.append(array_qty2);
    array_data.append(array_qty3);

    array_head_label := json_array_t();
    array_head_label.append(v_current_year);
    array_head_label.append(v_current_year - 1);
    array_head_label.append(v_current_year - 2);

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_performance_grade(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_performance_grade(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_performance_grade_by_jobgrade(json_str_output out clob) is
    obj_data        json_object_t;
    array_head_label json_array_t;
    array_label     json_array_t;
    array_qty       json_array_t;
    array_data      json_array_t;
    v_cntemp        number := 0;

    cursor c1 is
      select jobgrade from (
        select distinct jobgrade
          from tappemp
         where codcomp like b_index_codcompy||'%'
           and dteyreap = b_index_dteyreap
           and numtime  = b_index_numtime
        order by jobgrade)
      where rownum   <= 6;

    cursor c2 is
      select distinct grdap grdap
        from tappemp
       where codcomp like b_index_codcompy||'%'
         and dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
      order by grdap;
  begin
    obj_data      := json_object_t();
    array_qty     := json_array_t();
    array_data    := json_array_t();

    for i in c2 loop
      array_qty   := json_array_t();
      for j in c1 loop
        begin
          select count(distinct codempid) into v_cntemp
            from tappemp a
           where codcomp like b_index_codcompy||'%'
             and dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
             and jobgrade = j.jobgrade
             and grdap = i.grdap
             and numlvl between global_v_zminlvl and global_v_zwrklvl
             and exists (select c.coduser
                           from tusrcom c
                          where c.coduser = global_v_coduser
                            and a.codcomp like c.codcomp||'%');
          exception when others then v_cntemp := 0;
        end;
        array_qty.append(v_cntemp);
      end loop;
      array_data.append(array_qty);
    end loop;

    array_label   := json_array_t();
    for k in c1 loop
      array_label.append(get_tcodec_name('TCODJOBG', k.jobgrade, global_v_lang));
    end loop;

    array_head_label  := json_array_t();
    for k in c2 loop
      array_head_label.append('Grade '||k.grdap);
    end loop;

    obj_data.put('coderror','200');
    obj_data.put('headLabelGroup',array_head_label);
    obj_data.put('labels',array_label);
    obj_data.put('data',array_data);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_performance_grade_by_jobgrade(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_performance_grade_by_jobgrade(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end;

/
