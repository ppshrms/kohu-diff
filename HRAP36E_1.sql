--------------------------------------------------------
--  DDL for Package Body HRAP36E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP36E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_error   varchar2(4000);
  begin
    if b_index_codcompy is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompy);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;
    
    begin
      select 'N'
        into v_error
        from tgradekpi
       where codcompy     = b_index_codcompy
         and dteyreap     = (select max(dteyreap)
                               from tgradekpi
                              where codcompy    = b_index_codcompy
                                and dteyreap    <= to_number(to_char(sysdate,'yyyy')))
         and rownum       = 1;
    exception when no_data_found then
      v_error           := 'Y';
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tgradekpi');
      return;
    end;
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
      select codkpi,kpides,target,kpivalue,balscore,stakpi
        from tkpicmph
       where dteyreap   = b_index_dteyreap
         and codcompy   = b_index_codcompy
      order by codkpi;
  begin
    begin
      select objective
        into v_objective
        from tobjective
       where dteyreap   = b_index_dteyreap
         and codcompy   = b_index_codcompy;
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
      obj_data_kpi.put('codcompy',b_index_codcompy);
      obj_data_kpi.put('codkpi',i.codkpi);
      obj_data_kpi.put('kpides',i.kpides);
      obj_data_kpi.put('target',i.target);
      obj_data_kpi.put('kpivalue',to_char(i.kpivalue,'fm999999999999990.00'));
      obj_data_kpi.put('balscore',i.balscore);
      obj_data_kpi.put('desc_balscore',get_tlistval_name('BALSCORE',i.balscore,global_v_lang));
      if i.stakpi in ('N','Y') then
        obj_data_kpi.put('flg_delete','N');
      else
        obj_data_kpi.put('flg_delete','Y');
      end if;
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
    v_codkpi        tkpicmph.codkpi%type;
    cursor c_kpi is
      select codkpi,kpides,target,kpivalue,balscore,stakpi
        from tkpicmph
       where dteyreap   = b_index_dteyreap
         and codcompy   = b_index_codcompy
         and codkpi     = v_codkpi
      order by codkpi;
  begin
    json_input    := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_input,'p_codkpi');

    obj_data_kpi    := json_object_t();
    obj_data_kpi.put('coderror','200');
    for i in c_kpi loop
      obj_data_kpi.put('dteyreap',b_index_dteyreap);
      obj_data_kpi.put('codcompy',b_index_codcompy);
      obj_data_kpi.put('codkpi',i.codkpi);
      obj_data_kpi.put('kpides',i.kpides);
      obj_data_kpi.put('target',i.target);
      obj_data_kpi.put('kpivalue',to_char(i.kpivalue,'fm999999999999990.00'));
      obj_data_kpi.put('balscore',i.balscore);
      obj_data_kpi.put('desc_balscore',get_tlistval_name('BALSCORE',i.balscore,global_v_lang));
      if i.stakpi in ('N','Y') then
        obj_data_kpi.put('flg_delete','N');
      else
        obj_data_kpi.put('flg_delete','Y');
      end if;
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
  procedure gen_action_plan(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data_kpi    json_object_t;
    obj_row_kpi     json_object_t;
    v_rcnt_act      number := 0;
    v_rcnt_kpi      number := 0;
    
    v_codkpi        tkpicmppl.codkpi%type;
    v_codkpino      tkpicmpdp.codkpino%type;
    
    cursor c_kpicmppl is
      select codkpi,codkpino,kpides,targetkpi
        from tkpicmppl
       where dteyreap   = b_index_dteyreap
         and codcompy   = b_index_codcompy
         and codkpi     = v_codkpi
      order by codkpino;
      
    cursor c_tkpicmpdp is
      select codcomp,target,kpivalue
        from tkpicmpdp
       where dteyreap   = b_index_dteyreap
         and codcompy   = b_index_codcompy
         and codkpi     = v_codkpi
         and codkpino   = v_codkpino
      order by codkpino;
  begin
    json_input    := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_input,'p_codkpi');
    
    obj_row   := json_object_t();
    for r1 in c_kpicmppl loop
      obj_data    := json_object_t();
      v_codkpino  := r1.codkpino;
      obj_data.put('coderror','200');
      obj_data.put('codkpi',r1.codkpi);
      obj_data.put('codkpino',r1.codkpino);
      obj_data.put('kpides',r1.kpides);
      obj_data.put('targetkpi',r1.targetkpi);
      obj_row_kpi := json_object_t();
      for r2 in c_tkpicmpdp loop
        obj_data_kpi  := json_object_t();
        obj_data_kpi.put('codcomp',r2.codcomp);
        obj_data_kpi.put('target',r2.target);
        obj_data_kpi.put('kpivalue',r2.kpivalue);
        obj_row_kpi.put(to_char(v_rcnt_act),obj_data_kpi);
        v_rcnt_act  := v_rcnt_act + 1;
      end loop;
--      obj_row_kpi.put('rows',obj_row_kpi);
      obj_data.put('kpi_no',obj_row_kpi);
      obj_row.put(to_char(v_rcnt_kpi),obj_data);
      v_rcnt_kpi  := v_rcnt_kpi + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_action_plan(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_action_plan(json_str_input,json_str_output);
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

    v_codkpi        tkpicmpg.codkpi%type;

    cursor c1 is
      select grade,desgrade,score,color,kpides,stakpi,'N' as flgdefault
        from tkpicmpg
       where dteyreap   = b_index_dteyreap
         and codcompy   = b_index_codcompy
         and codkpi     = v_codkpi
      union
      select grade,desgrade,score,color,measuredes as kpides,'' as stakpi,'Y' as flgdefault
        from tgradekpi
       where codcompy   = b_index_codcompy
         and dteyreap   = (select max(dteyreap)
                             from tgradekpi
                            where codcompy = b_index_codcompy
                              and dteyreap <= to_number(to_char(sysdate,'yyyy')))
         and not exists (select 1
                           from tkpicmpg em
                          where em.dteyreap   = b_index_dteyreap
                            and em.codcompy   = b_index_codcompy
                            and em.codkpi     = v_codkpi)
      order by score desc;
  begin
    json_input    := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_input,'p_codkpi');

    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('grade',i.grade);
      obj_data.put('desgrade',i.desgrade);
      obj_data.put('score',i.score);
      obj_data.put('color',i.color);
      obj_data.put('desc_color','<i class="fas fa-circle" style="color: '||i.color||';"></i>');
      obj_data.put('kpides',i.kpides);
      obj_data.put('stakpi',i.stakpi);
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
  procedure insert_tkpicmph(t_tkpicmph tkpicmph%rowtype) is
  begin
    begin
      insert into tkpicmph(dteyreap,codcompy,codkpi,kpides,target,kpivalue,balscore,
                           codcreate,coduser)
      values (b_index_dteyreap,b_index_codcompy,t_tkpicmph.codkpi,
              t_tkpicmph.kpides,t_tkpicmph.target,t_tkpicmph.kpivalue,t_tkpicmph.balscore,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpicmph
         set kpides      = t_tkpicmph.kpides,
             target      = t_tkpicmph.target,
             kpivalue    = t_tkpicmph.kpivalue,
             balscore    = t_tkpicmph.balscore,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and codcompy    = b_index_codcompy
         and codkpi      = t_tkpicmph.codkpi;
    end;
  end;
  --
  procedure insert_tkpicmppl(t_tkpicmppl tkpicmppl%rowtype,p_add boolean,p_edit boolean) is
    v_dup   varchar2(1) := 'N';
  begin
    if p_add then
      begin
        select 'Y'
          into v_dup
          from tkpicmpdp
         where dteyreap    = b_index_dteyreap
           and codcompy    = b_index_codcompy
           and codkpino    = t_tkpicmppl.codkpino
           and rownum      = 1;
      exception when no_data_found then
        v_dup   := 'N';
      end;
    end if;
    if v_dup = 'N' then
      begin
        insert into tkpicmppl(dteyreap,codcompy,codkpi,codkpino,kpides,targetkpi,
                              codcreate,coduser)
        values (b_index_dteyreap,b_index_codcompy,t_tkpicmppl.codkpi,t_tkpicmppl.codkpino,t_tkpicmppl.kpides,t_tkpicmppl.targetkpi,
                global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tkpicmppl
           set kpides      = t_tkpicmppl.kpides,
               targetkpi   = t_tkpicmppl.targetkpi,
               coduser     = global_v_coduser
         where dteyreap    = b_index_dteyreap
           and codcompy    = b_index_codcompy
           and codkpi      = t_tkpicmppl.codkpi
           and codkpino    = t_tkpicmppl.codkpino;
      end;
    else
      param_msg_error   := get_error_msg_php('HR2005',global_v_lang,'TKPICMPDP');
    end if;
  end;
  --
  procedure insert_tkpicmpdp(t_tkpicmpdp tkpicmpdp%rowtype) is
  begin
    begin
      insert into tkpicmpdp(dteyreap,codcompy,codkpi,codkpino,
                            codcomp,target,kpivalue,
                            codcreate,coduser)
      values (b_index_dteyreap,b_index_codcompy,t_tkpicmpdp.codkpi,t_tkpicmpdp.codkpino,
              t_tkpicmpdp.codcomp,t_tkpicmpdp.target,t_tkpicmpdp.kpivalue,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpicmpdp
         set target      = t_tkpicmpdp.target,
             kpivalue    = t_tkpicmpdp.kpivalue,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and codcompy    = b_index_codcompy
         and codkpi      = t_tkpicmpdp.codkpi
         and codkpino    = t_tkpicmpdp.codkpino
         and codcomp     = t_tkpicmpdp.codcomp;
    end;
  end;
  --
  procedure insert_tkpicmpg(t_tkpicmpg tkpicmpg%rowtype) is
  begin
    begin
      insert into tkpicmpg(dteyreap,codcompy,codkpi,grade,
                           desgrade,score,color,kpides,stakpi,
                           codcreate,coduser)
      values (b_index_dteyreap,b_index_codcompy,t_tkpicmpg.codkpi,t_tkpicmpg.grade,
              t_tkpicmpg.desgrade,t_tkpicmpg.score,t_tkpicmpg.color,t_tkpicmpg.kpides,t_tkpicmpg.stakpi,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpicmpg
         set kpides      = t_tkpicmpg.kpides,
             stakpi      = t_tkpicmpg.stakpi,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and codcompy    = b_index_codcompy
         and codkpi      = t_tkpicmpg.codkpi
         and grade       = t_tkpicmpg.grade;
    end;
  end;
  --
  procedure save_kpi(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    json_kpi_detail       json_object_t;
    
    json_score_condition  json_object_t;
    json_scr_cond_row     json_object_t;
    
    json_act_plan         json_object_t;
    json_act_plan_row     json_object_t;  
    
    json_kpi_no           json_object_t;
    json_kpi_no_row       json_object_t;
    
    t_tkpicmph            tkpicmph%rowtype;
    t_tkpicmppl           tkpicmppl%rowtype;
    t_tkpicmpg            tkpicmpg%rowtype;
    t_tkpicmpdp           tkpicmpdp%rowtype;
    
    v_codkpi              tkpicmph.codkpi%type;
    
    v_flg_act_add         boolean;
    v_flg_act_edit        boolean;
    v_flg_act_delete      boolean;
    v_flg_kpi_add         boolean;
    v_flg_kpi_edit        boolean;
    v_flg_kpi_delete      boolean;
    v_flg_scrcon          varchar2(10);

  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);

    param_json            := hcm_util.get_json_t(json_input,'param_json');
    v_codkpi              := hcm_util.get_string_t(json_input,'p_codkpi');
    
    json_kpi_detail       := hcm_util.get_json_t(param_json,'detail');
    t_tkpicmph.codkpi     := v_codkpi;
    t_tkpicmph.kpides     := hcm_util.get_string_t(json_kpi_detail,'kpides');
    t_tkpicmph.target     := hcm_util.get_string_t(json_kpi_detail,'target');
    t_tkpicmph.kpivalue   := hcm_util.get_string_t(json_kpi_detail,'kpivalue');
    t_tkpicmph.balscore   := hcm_util.get_string_t(json_kpi_detail,'balscore');
    insert_tkpicmph(t_tkpicmph);
    
    json_act_plan   := hcm_util.get_json_t(param_json,'act_plan');
    for i in 0..(json_act_plan.get_size - 1) loop
      json_act_plan_row     := hcm_util.get_json_t(json_act_plan,to_char(i));
      t_tkpicmppl.codkpi    := t_tkpicmph.codkpi;
      t_tkpicmppl.codkpino  := hcm_util.get_string_t(json_act_plan_row,'codkpino');
      t_tkpicmppl.kpides    := hcm_util.get_string_t(json_act_plan_row,'kpides');
      t_tkpicmppl.targetkpi := hcm_util.get_string_t(json_act_plan_row,'targetkpi');
      v_flg_act_add         := hcm_util.get_boolean_t(json_act_plan_row,'flgAdd');
      v_flg_act_edit        := hcm_util.get_boolean_t(json_act_plan_row,'flgEdit');
      v_flg_act_delete      := hcm_util.get_boolean_t(json_act_plan_row,'flgDelete');
      if v_flg_act_delete then
        delete from tkpicmppl
         where dteyreap   = b_index_dteyreap
           and codcompy   = b_index_codcompy
           and codkpi     = t_tkpicmph.codkpi
           and codkpino   = t_tkpicmppl.codkpino;
        delete from tkpicmpdp
         where dteyreap   = b_index_dteyreap
           and codcompy   = b_index_codcompy
           and codkpi     = t_tkpicmph.codkpi
           and codkpino   = t_tkpicmppl.codkpino;
      elsif v_flg_act_add or v_flg_act_edit then
        insert_tkpicmppl(t_tkpicmppl,v_flg_act_add,v_flg_act_edit);
        if param_msg_error is null then
          json_kpi_no       := hcm_util.get_json_t(hcm_util.get_json_t(json_act_plan_row,'kpi_no'),'rows');
          for i in 0..(json_kpi_no.get_size - 1) loop
            json_kpi_no_row       := hcm_util.get_json_t(json_kpi_no,to_char(i));
            t_tkpicmpdp.codkpi    := t_tkpicmph.codkpi;
            t_tkpicmpdp.codkpino  := t_tkpicmppl.codkpino;
            t_tkpicmpdp.codcomp   := hcm_util.get_string_t(json_kpi_no_row,'codcomp');
            t_tkpicmpdp.target    := hcm_util.get_string_t(json_kpi_no_row,'target');
            t_tkpicmpdp.kpivalue  := hcm_util.get_string_t(json_kpi_no_row,'kpivalue');
            v_flg_kpi_add         := hcm_util.get_boolean_t(json_kpi_no_row,'flgAdd');
            v_flg_kpi_edit        := hcm_util.get_boolean_t(json_kpi_no_row,'flgEdit');
            v_flg_kpi_delete      := hcm_util.get_boolean_t(json_kpi_no_row,'flgDelete');
            if v_flg_kpi_delete then
              delete from tkpicmpdp
               where dteyreap    = b_index_dteyreap
                 and codcompy    = b_index_codcompy
                 and codkpi      = t_tkpicmph.codkpi
                 and codkpino    = t_tkpicmpdp.codkpino
                 and codcomp     = t_tkpicmpdp.codcomp;
            elsif v_flg_kpi_add or v_flg_kpi_edit then
              insert_tkpicmpdp(t_tkpicmpdp);
            end if;
          end loop;
        else
          exit;
        end if;
      end if;
    end loop;
    
    json_score_condition  := hcm_util.get_json_t(param_json,'scr_cond');
    if param_msg_error is null then
      for i in 0..(json_score_condition.get_size - 1) loop
        json_scr_cond_row    := hcm_util.get_json_t(json_score_condition,to_char(i));
        t_tkpicmpg.codkpi    := t_tkpicmph.codkpi;
        t_tkpicmpg.grade     := hcm_util.get_string_t(json_scr_cond_row,'grade');
        t_tkpicmpg.desgrade  := hcm_util.get_string_t(json_scr_cond_row,'desgrade');
        t_tkpicmpg.score     := hcm_util.get_string_t(json_scr_cond_row,'score');
        t_tkpicmpg.color     := hcm_util.get_string_t(json_scr_cond_row,'color');
        t_tkpicmpg.kpides    := hcm_util.get_string_t(json_scr_cond_row,'kpides');
        t_tkpicmpg.stakpi    := hcm_util.get_string_t(json_scr_cond_row,'stakpi');
        v_flg_scrcon         := hcm_util.get_string_t(json_scr_cond_row,'flg');
        if v_flg_scrcon in ('add','edit') then  
          insert_tkpicmpg(t_tkpicmpg);
        end if;
      end loop;
    end if;
    
    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    else
      rollback;
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    v_codkpi              tkpicmph.codkpi%type;
    v_objective           tobjective.objective%type;
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
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codkpi          := hcm_util.get_string_t(param_json_row,'codkpi');
      v_flg             := hcm_util.get_string_t(param_json_row,'flg');
      if v_flg = 'delete' then
        v_flg_delete  := 'Y';
        delete tkpicmph  
         where dteyreap    = b_index_dteyreap
           and codcompy    = b_index_codcompy
           and codkpi      = v_codkpi;

        delete tkpicmppl
         where dteyreap    = b_index_dteyreap
           and codcompy    = b_index_codcompy
           and codkpi      = v_codkpi;

        delete tkpicmpg
         where dteyreap    = b_index_dteyreap
           and codcompy    = b_index_codcompy
           and codkpi      = v_codkpi;
           
        delete tkpicmpdp
         where dteyreap    = b_index_dteyreap
           and codcompy    = b_index_codcompy
           and codkpi      = v_codkpi;
      end if;
    end loop;

    begin
      select 'Y'
        into v_found
        from tkpicmph
       where dteyreap    = b_index_dteyreap
         and codcompy    = b_index_codcompy
         and rownum      = 1;
    exception when no_data_found then
      v_found   := 'N';
    end;

    if v_found = 'Y' or v_flg_delete = 'N' then
      begin
        insert into tobjective(dteyreap,codcompy,
                               objective,codcreate,coduser)
        values (b_index_dteyreap,b_index_codcompy,
                v_objective,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tobjective
           set objective   = v_objective,
               coduser     = global_v_coduser
         where dteyreap    = b_index_dteyreap
           and codcompy    = b_index_codcompy;
      end;
    else
      delete tobjective
       where dteyreap    = b_index_dteyreap
         and codcompy    = b_index_codcompy;
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
