--------------------------------------------------------
--  DDL for Package Body HRAP3QE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3QE" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_error   varchar2(4000);
    v_kpicom  varchar2(1) := 'N';
  begin
    if b_index_codcomp is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;

    begin --user36 #6964 22/09/2021
      select 'Y' into v_kpicom
      from  tkpicmpdp
      where dteyreap  = b_index_dteyreap
      and   codcomp   = b_index_codcomp
      and   rownum    = 1;
    exception when no_data_found then null;
    end;
    if v_kpicom = 'N' then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tkpicmpdp');
      return;
    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_data_kpi    json_object_t;
    obj_row_kpi     json_object_t;
    v_rcnt          number := 0;
    v_objective     tobjdep.objective%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    cursor c_kpi is
      select codkpino,kpides,wgt,target,kpivalue,
             'N' as flgdefault
        from tkpidph
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codcomp    = b_index_codcomp
      union
      select d.codkpino,h.kpides,null as wgt,d.target,d.kpivalue,
             'Y' as flgdefault
        from tkpicmpdp d, tkpicmph h
       where d.dteyreap   = b_index_dteyreap
         and d.codcomp    = b_index_codcomp
         and d.dteyreap   = h.dteyreap
         and d.codcompy   = h.codcompy
         and d.codkpi     = h.codkpi
         and not exists (select 1
                           from tkpidph dp
                          where dp.dteyreap   = b_index_dteyreap
                            and dp.numtime    = b_index_numtime
                            and dp.codcomp    = b_index_codcomp
                            and dp.codkpino   = d.codkpino)
      order by codkpino;
  begin
    begin
      select objective
        into v_objective
        from tobjdep
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codcomp    = b_index_codcomp;
    exception when no_data_found then
      v_objective   := null;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('objective',v_objective);
    obj_row_kpi := json_object_t();
    for i in c_kpi loop
      obj_data_kpi      := json_object_t();
      obj_data_kpi.put('coderror','200');
      obj_data_kpi.put('dteyreap',b_index_dteyreap);
      obj_data_kpi.put('numtime',b_index_numtime);
      obj_data_kpi.put('codcomp',b_index_codcomp);
      obj_data_kpi.put('codkpino',i.codkpino);
      obj_data_kpi.put('kpides',i.kpides);
      obj_data_kpi.put('target',i.target);
--      obj_data_kpi.put('kpivalue',to_char(i.kpivalue,'fm9,999,999,999,990.00'));
      obj_data_kpi.put('kpivalue',i.kpivalue);
      obj_data_kpi.put('wgt',to_char(i.wgt,'fm990.00'));
      obj_data_kpi.put('flgdefault',i.flgdefault);
      obj_row_kpi.put(to_char(v_rcnt),obj_data_kpi);
      v_rcnt  := v_rcnt + 1;
    end loop;
    obj_data.put('kpi_index',obj_row_kpi);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_kpi_detail(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data_kpi    json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_codkpino      tkpidph.codkpino%type;
    v_found         varchar2(1) := 'N';
    cursor c_kpi is
      select codkpino,kpides,target,kpivalue,wgt,
             'N' as flgdefault
        from tkpidph
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codcomp    = b_index_codcomp
         and codkpino   = v_codkpino
      union
      select b.codkpino,a.kpides,b.target,b.kpivalue,null as wgt,
             'Y' as flgdefault
        from tkpicmph a,tkpicmpdp b
       where b.dteyreap   = b_index_dteyreap
         and b.codcomp    = b_index_codcomp
         and b.dteyreap   = a.dteyreap
         and b.codcompy   = a.codcompy
         and b.codkpi     = a.codkpi
         and b.codkpino   = v_codkpino
         and not exists (select 1
                           from tkpidph dp
                          where dp.dteyreap   = b_index_dteyreap
                            and dp.numtime    = b_index_numtime
                            and dp.codcomp    = b_index_codcomp
                            and dp.codkpino   = b.codkpino)
      order by codkpino;
  begin
    json_input    := json_object_t(json_str_input);
    v_codkpino    := hcm_util.get_string_t(json_input,'p_codkpino');

    obj_data_kpi    := json_object_t();
    obj_data_kpi.put('coderror','200');
    for i in c_kpi loop
      v_found   := 'Y';
      obj_data_kpi.put('codkpino',i.codkpino);
      obj_data_kpi.put('kpides',i.kpides);
      obj_data_kpi.put('target',i.target);
      obj_data_kpi.put('kpivalue',i.kpivalue);
      obj_data_kpi.put('wgt',to_char(i.wgt,'fm990.00'));
      obj_data_kpi.put('flgdefault',i.flgdefault);
    end loop;
    json_str_output   := obj_data_kpi.to_clob;
  end;
  --
  procedure get_kpi_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_kpi_detail(json_str_input,json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_score_condition(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_true          boolean := true;

    v_codcompy      tcompny.codcompy%type;
    v_codkpino      tkpidph.codkpino%type;    
    v2_kpides       varchar2(1000 char); 
    v2_codkpi       varchar2(1000 char);
    v2_stakpi       varchar2(1000 char);

    cursor c1 is
      select grade,desgrade,score,color,kpides,stakpi,'N' as flgdefault
        from tkpidpg
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codcomp    = b_index_codcomp
         and codkpino   = v_codkpino
      union
      select grade,desgrade,score,color,measuredes as kpides,'' as stakpi,'Y' as flgdefault
        from tgradekpi
       where codcompy   = v_codcompy
         and dteyreap   = (select max(dteyreap)
                             from tgradekpi
                            where codcompy = v_codcompy
                              and dteyreap <= to_number(to_char(sysdate,'yyyy')))
         and not exists (select 1
                           from tkpidpg em
                          where em.dteyreap   = b_index_dteyreap
                            and em.numtime    = b_index_numtime
                            and em.codcomp    = b_index_codcomp
                            and em.codkpino   = v_codkpino)
      order by score desc, grade;

      cursor c2 is 
          select codkpi from TKPICMPH where DTEYREAP = b_index_dteyreap
          and CODCOMPY = v_codcompy
          order by codkpi;

  begin
    json_input    := json_object_t(json_str_input);
    v_codkpino    := hcm_util.get_string_t(json_input,'p_codkpino');
    v_codcompy    := hcm_util.get_codcomp_level(b_index_codcomp,1);

    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('grade',i.grade);
      obj_data.put('desgrade',i.desgrade);
      obj_data.put('score',i.score);
      obj_data.put('color',i.color);
      obj_data.put('desc_color','<i class="fas fa-circle" style="color: '||i.color||';"></i>');
-- ST117447 || 27/04/2022 || User39         
      if i.kpides is null then
            begin
                for i in c2 loop
                   v2_codkpi := i.codkpi;
                   exit;
                end loop;

                select kpides , stakpi into v2_kpides , v2_stakpi 
                from TKPICMPG where DTEYREAP = b_index_dteyreap
                and codcompy = v_codcompy 
                and codkpi = v2_codkpi 
                and grade = i.grade;


             exception when no_data_found then
                v2_kpides := null;
             end;
         obj_data.put('kpides',v2_kpides);
         obj_data.put('stakpi',v2_stakpi);
      else
         obj_data.put('kpides',i.kpides);
         obj_data.put('stakpi',i.stakpi);
      end if;
-- ST117447 || 27/04/2022 || User39      
      if i.flgdefault = 'Y' then
        obj_data.put('flgAdd',v_true);
      end if;

      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_score_condition(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_score_condition(json_str_input,json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_res_emp(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    v_codkpino      tkpidph.codkpino%type;

    cursor c1 is
      select codempid,codpos,target,kpivalue,targtstr,targtend
        from tkpidpem
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codcomp    = b_index_codcomp
         and codkpino   = v_codkpino
      order by codempid;
  begin
    json_input    := json_object_t(json_str_input);
    v_codkpino    := hcm_util.get_string_t(json_input,'p_codkpino');

    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('codcomp',b_index_codcomp);
      obj_data.put('codpos',i.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
      obj_data.put('target',i.target);
      obj_data.put('kpivalue',i.kpivalue);
      obj_data.put('targtstr',to_char(i.targtstr,'dd/mm/yyyy'));
      obj_data.put('targtend',to_char(i.targtend,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_res_emp(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_res_emp(json_str_input,json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_tkpidph(t_tkpidph tkpidph%rowtype) is
    v_wgt number;
  begin
    begin
      insert into tkpidph(dteyreap,numtime,codcomp,codkpino,
                          kpides,wgt,target,kpivalue,
                          codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,b_index_codcomp,t_tkpidph.codkpino,
              t_tkpidph.kpides,t_tkpidph.wgt,t_tkpidph.target,t_tkpidph.kpivalue,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpidph
         set kpides      = t_tkpidph.kpides,
             target      = t_tkpidph.target,
             kpivalue    = t_tkpidph.kpivalue,
             wgt         = t_tkpidph.wgt,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codcomp     = b_index_codcomp
         and codkpino    = t_tkpidph.codkpino;
    end;

    begin
      select sum(wgt)
        into v_wgt
        from tkpidph
       where dteyreap = b_index_dteyreap
         and numtime = b_index_numtime
         and codcomp = b_index_codcomp;
    exception when no_data_found then
        v_wgt := 0;
    end;

    if v_wgt > 100 then
        param_msg_error := get_error_msg_php('AP0065',global_v_lang);
    end if;
  end;
  --
  procedure insert_tkpidpg(t_tkpidpg tkpidpg%rowtype) is
  begin
    begin
      insert into tkpidpg(dteyreap,numtime,codcomp,codkpino,grade,
                           desgrade,score,color,kpides,stakpi,
                           codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,b_index_codcomp,t_tkpidpg.codkpino,t_tkpidpg.grade,
              t_tkpidpg.desgrade,t_tkpidpg.score,t_tkpidpg.color,t_tkpidpg.kpides,t_tkpidpg.stakpi,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpidpg
         set kpides      = t_tkpidpg.kpides,
             stakpi      = t_tkpidpg.stakpi,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codcomp     = b_index_codcomp
         and codkpino    = t_tkpidpg.codkpino
         and grade       = t_tkpidpg.grade;
    end;
  end;
  --
  procedure insert_tkpidpem(t_tkpidpem tkpidpem%rowtype) is
  begin
    begin
      insert into tkpidpem(dteyreap,numtime,codcomp,codkpino,codempid,
                           codpos,target,kpivalue,targtstr,targtend,
                           codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,b_index_codcomp,t_tkpidpem.codkpino,t_tkpidpem.codempid,
              t_tkpidpem.codpos,t_tkpidpem.target,t_tkpidpem.kpivalue,t_tkpidpem.targtstr,t_tkpidpem.targtend,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpidpem
         set target      = t_tkpidpem.target,
             kpivalue    = t_tkpidpem.kpivalue,
             targtstr    = t_tkpidpem.targtstr,
             targtend    = t_tkpidpem.targtend,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codcomp     = b_index_codcomp
         and codkpino    = t_tkpidpem.codkpino
         and codempid    = t_tkpidpem.codempid;
    end;
  end;
  --
  function is_number( p_str in varchar2 ) return varchar2 is
    l_num   number;
  begin
    l_num   := to_number( p_str );
    return 'Y';
  exception when value_error then return 'N';
  end;
  --
  procedure save_kpi(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    json_kpi_detail       json_object_t;
    json_score_condition  json_object_t;
    json_scr_cond_row     json_object_t;
    json_res_emp          json_object_t;
    json_res_emp_row      json_object_t;
    t_tkpidph             tkpidph%rowtype;
    t_tkpidpg             tkpidpg%rowtype;
    t_tkpidpem            tkpidpem%rowtype;
    v_flg_scrcon          varchar2(10);
    v_flg_resemp          varchar2(10);

  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);
--    b_index_dteyreap      := hcm_util.get_string_t(json_input,'p_dteyreap');
--    b_index_numtime       := hcm_util.get_string_t(json_input,'p_numtime');
--    b_index_codcomp       := hcm_util.get_string_t(json_input,'p_codcomp');
    t_tkpidph.codkpino    := hcm_util.get_string_t(json_input,'p_codkpino');

    param_json            := hcm_util.get_json_t(json_input,'param_json');
    json_kpi_detail       := hcm_util.get_json_t(param_json,'detail');
    t_tkpidph.kpides      := hcm_util.get_string_t(json_kpi_detail,'kpides');
    t_tkpidph.wgt         := hcm_util.get_string_t(json_kpi_detail,'wgt');
    t_tkpidph.target      := hcm_util.get_string_t(json_kpi_detail,'target');
    t_tkpidph.kpivalue    := hcm_util.get_string_t(json_kpi_detail,'kpivalue');
    insert_tkpidph(t_tkpidph);

    json_score_condition  := hcm_util.get_json_t(param_json,'scr_cond');
    for i in 0..(json_score_condition.get_size - 1) loop
      json_scr_cond_row    := hcm_util.get_json_t(json_score_condition,to_char(i));
      t_tkpidpg.codkpino   := t_tkpidph.codkpino;
      t_tkpidpg.grade      := hcm_util.get_string_t(json_scr_cond_row,'grade');
      t_tkpidpg.desgrade   := hcm_util.get_string_t(json_scr_cond_row,'desgrade');
      t_tkpidpg.score      := hcm_util.get_string_t(json_scr_cond_row,'score');
      t_tkpidpg.color      := hcm_util.get_string_t(json_scr_cond_row,'color');
      t_tkpidpg.kpides     := hcm_util.get_string_t(json_scr_cond_row,'kpides');
      t_tkpidpg.stakpi     := hcm_util.get_string_t(json_scr_cond_row,'stakpi');
      v_flg_scrcon         := hcm_util.get_string_t(json_scr_cond_row,'flg');
      if v_flg_scrcon in ('add','edit') then
        insert_tkpidpg(t_tkpidpg);
      end if;
    end loop;

    json_res_emp      := hcm_util.get_json_t(param_json,'res_emp');
    for i in 0..(json_res_emp.get_size - 1) loop
      json_res_emp_row     := hcm_util.get_json_t(json_res_emp,to_char(i));
      t_tkpidpem.codkpino  := t_tkpidph.codkpino;
      t_tkpidpem.codempid  := hcm_util.get_string_t(json_res_emp_row,'codempid');
      t_tkpidpem.codpos    := hcm_util.get_string_t(json_res_emp_row,'codpos');
      t_tkpidpem.target    := hcm_util.get_string_t(json_res_emp_row,'target');
      t_tkpidpem.kpivalue  := hcm_util.get_string_t(json_res_emp_row,'kpivalue');
      t_tkpidpem.targtstr  := to_date(hcm_util.get_string_t(json_res_emp_row,'targtstr'),'dd/mm/yyyy');
      t_tkpidpem.targtend  := to_date(hcm_util.get_string_t(json_res_emp_row,'targtend'),'dd/mm/yyyy');
      v_flg_resemp         := hcm_util.get_string_t(json_res_emp_row,'flg');
      if v_flg_resemp in ('add','edit') then
        insert_tkpidpem(t_tkpidpem);
      elsif v_flg_resemp = 'delete' then
        delete from tkpidpem
         where dteyreap    = b_index_dteyreap
           and numtime     = b_index_numtime
           and codcomp     = b_index_codcomp
           and codkpino    = t_tkpidpem.codkpino
           and codempid    = t_tkpidpem.codempid;
      end if;
    end loop;
    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    else
      rollback;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    t_tkpidph             tkpidph%rowtype;
    v_codkpino            tkpidph.codkpino%type;
    v_objective           tobjdep.objective%type;
    v_flg                 varchar2(50);
    v_flg_delete          varchar2(1) := 'N';
    v_eval                varchar2(1) := 'N';
    v_found               varchar2(1) := 'N';
  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);
    v_objective           := hcm_util.get_string_t(json_input,'p_objective');

    param_json            := hcm_util.get_json_t(json_input,'param_json');
    for i in 0..(param_json.get_size - 1) loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_codkpino          := hcm_util.get_string_t(param_json_row,'codkpino');
      v_flg               := hcm_util.get_string_t(param_json_row,'flg');
      if v_flg = 'delete' then
        v_flg_delete  := 'Y';
        delete tkpidph
         where dteyreap    = b_index_dteyreap
           and numtime     = b_index_numtime
           and codcomp     = b_index_codcomp
           and codkpino    = v_codkpino;

        delete tkpidpg
         where dteyreap    = b_index_dteyreap
           and numtime     = b_index_numtime
           and codcomp     = b_index_codcomp
           and codkpino    = v_codkpino;

        delete tkpidpem
         where dteyreap    = b_index_dteyreap
           and numtime     = b_index_numtime
           and codcomp     = b_index_codcomp
           and codkpino    = v_codkpino;
      end if;
    end loop;

    begin
      select 'Y'
        into v_found
        from tkpidph
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codcomp     = b_index_codcomp
         and rownum      = 1;
    exception when no_data_found then
      v_found   := 'N';
    end;

    if v_found = 'Y' or v_flg_delete = 'N' then
      begin
        insert into tobjdep(dteyreap,numtime,codcomp,
                            objective,codcreate,coduser)
        values (b_index_dteyreap,b_index_numtime,b_index_codcomp,
                v_objective,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tobjdep
           set objective   = v_objective,
               coduser     = global_v_coduser
         where dteyreap    = b_index_dteyreap
           and numtime     = b_index_numtime
           and codcomp     = b_index_codcomp;
      end;
    else
      delete tobjdep
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codcomp     = b_index_codcomp;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
