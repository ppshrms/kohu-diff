--------------------------------------------------------
--  DDL for Package Body HRAP32E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP32E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_rcnt      number := 0;
    cursor c1 is
      select emp.codempid,obj.codcomp,emp.codpos,emp.dteefpos,emp.dteappr
        from tobjemp obj,temploy1 emp
       where obj.codempid   = emp.codempid
         and obj.dteyreap   = b_index_dteyreap
         and obj.numtime    = b_index_numtime
         and obj.codcomp    like b_index_codcomp||'%'
         and emp.codpos     = nvl(b_index_codpos,emp.codpos)
         and emp.codempid   = nvl(b_index_codempid,emp.codempid)
      order by codempid;
  begin
    obj_row   := json_object_t;
    for i in c1 loop
      obj_data    := json_object_t;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('codpos',i.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
      obj_data.put('dteempmt',to_char(i.dteefpos,'dd/mm/yyyy'));
      obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
      obj_data.put('dteyreap',b_index_dteyreap);
      obj_data.put('numtime',b_index_numtime);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt    := v_rcnt + 1;
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
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
  procedure gen_object_kpi(json_str_output out clob) is
    obj_data        json_object_t;
    obj_data_kpi    json_object_t;
    obj_row_kpi     json_object_t;
    v_rcnt          number := 0;
    v_objective     tobjemp.objective%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    cursor c_kpi is
      select typkpi,codkpi,kpides,target,
             mtrfinish,pctwgt,targtstr,targtend,
             'N' as flgdefault
        from tkpiemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
      union
      select 'D' as typkpi,codkpino as codkpi,'' as kpides,target,
             kpivalue as mtrfinish,null as pctwgt,targtstr,targtend,
             'Y' as flgdefault
         from tkpidpem  dp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
         and codcomp    like b_index_codcomp||'%'
         and not exists (select 1
                           from tkpiemp em
                          where em.dteyreap   = b_index_dteyreap
                            and em.numtime    = b_index_numtime
                            and em.codempid   = b_index_codempid
                            and dp.codkpino   = em.codkpi)
      order by typkpi, codkpi;
  begin
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      null;
    end;
    begin
      select objective into v_objective
        from tobjemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid;
    exception when no_data_found then
      v_objective   := null;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('objective',v_objective);
    obj_data.put('codcomp',v_codcomp);
    obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
    obj_data.put('codpos',v_codpos);
    obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
    obj_row_kpi := json_object_t();
    for i in c_kpi loop
      obj_data_kpi      := json_object_t();
      obj_data_kpi.put('coderror','200');
      obj_data_kpi.put('typkpi',i.typkpi);
      obj_data_kpi.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
      obj_data_kpi.put('codkpi',i.codkpi);
      if i.flgdefault = 'Y' then
        begin
          select kpides into i.kpides
            from tkpidph
           where dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
             and codcomp  = v_codcomp
             and codkpino = i.codkpi;
        exception when no_data_found then
          null;
        end;
        obj_data_kpi.put('kpides',i.kpides);
      else
        obj_data_kpi.put('kpides',i.kpides);
      end if;
      obj_data_kpi.put('target',i.target);
      obj_data_kpi.put('mtrfinish',to_char(i.mtrfinish,'fm999,999,990.00'));
      obj_data_kpi.put('pctwgt',to_char(i.pctwgt,'fm990.00'));
      obj_data_kpi.put('targtstr',to_char(i.targtstr,'dd/mm/yyyy'));
      obj_data_kpi.put('targtend',to_char(i.targtend,'dd/mm/yyyy'));
      obj_data_kpi.put('flgdefault',i.flgdefault);
      obj_row_kpi.put(to_char(v_rcnt),obj_data_kpi);
      v_rcnt  := v_rcnt + 1;
    end loop;
    obj_data.put('kpi_index',obj_row_kpi);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_object_kpi(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_object_kpi(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_job_kpi(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;

    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    cursor c1 is
      select codkpi,kpiitem,target,kpivalue
        from tjobkpi
       where codcomp    = v_codcomp
         and codpos     = v_codpos
      order by codkpi;
  begin
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      null;
    end;

    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codkpi',i.codkpi);
      obj_data.put('kpides',i.kpiitem);
      obj_data.put('target',i.target);
      obj_data.put('mtrfinish',i.kpivalue);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_job_kpi(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_job_kpi(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_lov_kpi(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;

    cursor c1 is
      select a.codkpino as codkpi,a.kpides,'D' as typkpi
        from tkpidph a join tkpidpem b
          on (a.dteyreap  = b.dteyreap
         and a.numtime    = b.numtime
         and a.codcomp    = b.codcomp
         and a.codkpino   = b.codkpino
         and b.dteyreap   = b_index_dteyreap
         and b.numtime    = b_index_numtime
         and b.codempid   = b_index_codempid)
       where not exists (select 1
                           from tkpiemp emp
                          where emp.codkpi   = b.codkpino
                            and dteyreap     = b_index_dteyreap
                            and numtime      = b_index_numtime
                            and codempid     = b_index_codempid)
      union
      select codkpi,kpiitem as kpides,'J' as typkpi
        from tjobkpi job
       where codpos       = v_codpos
         and codcomp      = v_codcomp
         and not exists (select 1
                           from tkpiemp emp
                          where emp.codkpi   = job.codkpi
                            and dteyreap     = b_index_dteyreap
                            and numtime      = b_index_numtime
                            and codempid     = b_index_codempid)
      union
      select codkpi,kpides,'I' as typkpi
        from tkpiemp
       where dteyreap     = b_index_dteyreap
         and numtime      = b_index_numtime
         and codempid     = b_index_codempid
      order by codkpi;
  begin
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      null;
    end;

    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codkpi',i.codkpi);
      obj_data.put('kpides',i.kpides);
      obj_data.put('typkpi',i.typkpi);
      obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_lov_kpi(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_lov_kpi(json_str_input,json_str_output);
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
    v_typkpi        tkpiemp.typkpi%type;
    v_codkpi        tkpiemp.codkpi%type;
    v_found         varchar2(1) := 'N';
    cursor c_kpi is
      select typkpi,codkpi,kpides,target,
             mtrfinish,pctwgt,targtstr,targtend,
             'N' as flgdefault
        from tkpiemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
         and codkpi     = v_codkpi
      union
      select v_typkpi as typkpi,codkpino as codkpi,'' as kpides,target,
             kpivalue as mtrfinish,null as pctwgt,targtstr,targtend,
             'Y' as flgdefault
        from tkpidpem dp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
         and codkpino   = v_codkpi
         and v_typkpi   = 'D'
         and not exists (select 1
                           from tkpiemp em
                          where em.dteyreap   = b_index_dteyreap
                            and em.numtime    = b_index_numtime
                            and em.codempid   = b_index_codempid
                            and dp.codkpino   = em.codkpi)
      union
      select v_typkpi as typkpi,codkpi,kpiitem as kpides,target,
             kpivalue as mtrfinish,null as pctwgt,null as targtstr,null as targtend,
             'Y' as flgdefault
        from tjobkpi jb
       where codpos     = v_codpos
         and codcomp    = v_codcomp
         and codkpi     = v_codkpi
         and v_typkpi   = 'J'
         and not exists (select 1
                           from tkpiemp em
                          where em.dteyreap   = b_index_dteyreap
                            and em.numtime    = b_index_numtime
                            and em.codempid   = b_index_codempid
                            and jb.codkpi     = em.codkpi)
      order by typkpi, codkpi;
  begin
    json_input    := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_input,'p_codkpi');
    v_typkpi      := hcm_util.get_string_t(json_input,'p_typkpi');

    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      null;
    end;

    obj_data_kpi    := json_object_t();
    for i in c_kpi loop
      v_found   := 'Y';
      obj_data_kpi.put('coderror','200');
      obj_data_kpi.put('typkpi',i.typkpi);
      obj_data_kpi.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
      obj_data_kpi.put('codkpi',i.codkpi);
      if i.flgdefault = 'Y' and i.typkpi = 'D' then
        begin
          select kpides into i.kpides
            from tkpidph
           where dteyreap   = b_index_dteyreap
             and numtime    = b_index_numtime
             and codcomp    = v_codcomp
             and codkpino   = i.codkpi;
        exception when no_data_found then
          null;
        end;
        obj_data_kpi.put('kpides',i.kpides);
      else
        obj_data_kpi.put('kpides',i.kpides);
      end if;
      obj_data_kpi.put('target',i.target);
      obj_data_kpi.put('mtrfinish',to_char(i.mtrfinish));
      obj_data_kpi.put('pctwgt',to_char(i.pctwgt,'fm990.00'));
      obj_data_kpi.put('targtstr',to_char(i.targtstr,'dd/mm/yyyy'));
      obj_data_kpi.put('targtend',to_char(i.targtend,'dd/mm/yyyy'));
      obj_data_kpi.put('flgdefault',i.flgdefault);
    end loop;
    if v_found = 'N' then
      obj_data_kpi.put('coderror','200');
      obj_data_kpi.put('typkpi',v_typkpi);
    end if;
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
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_codkpi        tkpiemp.codkpi%type;
    v_typkpi        tkpiemp.typkpi%type;
    v_flgkpi        tjobkpig.codkpi%type;
    v_descgrd       varchar2(500 char);

    v2_kpides       varchar2(500 char);
    v2_stakpi       varchar2(1 char);

    cursor c1 is
      select grade,desgrade,score,color,kpides,stakpi,'N' as flgdefault
        from tkpiempg
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
         and codkpi     = v_codkpi
      union
      select grade,desgrade,score,color,measuredes as kpides,'' as stakpi,'Y' as flgdefault
        from tgradekpi
       where codcompy   = v_codcompy
         and dteyreap   = (select max(dteyreap)
                             from tgradekpi
                            where codcompy = v_codcompy
                              and dteyreap <= to_number(to_char(sysdate,'yyyy')))
         and not exists (select 1
                           from tkpiempg em
                          where em.dteyreap   = b_index_dteyreap
                            and em.numtime    = b_index_numtime
                            and em.codempid   = b_index_codempid
                            and em.codkpi     = v_codkpi)
      order by grade desc; --#7160 || USER39 || 04/11/2021
  begin
    json_input    := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_input,'p_codkpi');
    v_typkpi      := hcm_util.get_string_t(json_input,'p_type');

    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
      v_codcompy    := hcm_util.get_codcomp_level(v_codcomp,1);
    exception when no_data_found then
      null;
    end;

    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('grade',i.grade);
      obj_data.put('desgrade',i.desgrade);
      obj_data.put('score',i.score);
      obj_data.put('color',i.color);
      obj_data.put('desc_color','<i class="fas fa-circle" style="color: '||i.color||';"></i>');

      if i.flgdefault = 'Y' --and v_typkpi = 'J' --#7146 || 09/06/2022
      then             
             begin
              select decode(flgkpi,'P','Y','F','N','Y'),descgrd
                into v_flgkpi,v_descgrd
                from tjobkpig
               where codcomp      = v_codcomp
                 and codpos       = v_codpos
                 and codkpi       = v_codkpi
                 and qtyscor      = i.score;                                 
             exception when no_data_found then
              null;
             end;
             obj_data.put('kpides',v_descgrd);
             obj_data.put('stakpi',v_flgkpi);
             obj_data.put('flgAdd',v_true);
      else
         --<< #7462 || USER39 || 12/01/2022
            if (i.kpides is null) and (i.stakpi is null) then
                    begin
                       select kpides , stakpi
                       into v2_kpides , v2_stakpi
                        from tkpidpg
                       where dteyreap   = b_index_dteyreap
                         and numtime    = b_index_numtime
                         and codcomp    = v_codcomp
                         and codkpino   = v_codkpi
                         and grade      = i.grade;
                    exception when no_data_found then
                          v2_kpides := null;
                          v2_stakpi := null;
                    end;
              else
                  v2_kpides :=  i.kpides;
                  v2_stakpi :=  i.stakpi;
              end if;

            obj_data.put('kpides',v2_kpides);
            obj_data.put('stakpi',v2_stakpi);
        -->> #7462 || USER39 || 12/01/2022

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
  procedure gen_action_plan(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_true          boolean := true;

    v_codcompy      tcompny.codcompy%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_codkpi        tkpiemp.codkpi%type;
    v_typkpi        tkpiemp.typkpi%type;
    v_flgkpi        tjobkpig.codkpi%type;
    v_descgrd       tjobkpig.codkpi%type;

    cursor c1 is
      select planno,plandes,targtstr,targtend, 'N' as flgdefault
        from tkpiemppl
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
         and codkpi     = v_codkpi
      union
      select to_char(planlvl) as planno,plandesc as plandes,null as targtstr,null as targtend, 'Y' as flgdefault
        from tjobkpip
       where codcomp    = v_codcomp
         and codpos     = v_codpos
         and codkpi     = v_codkpi
         and v_typkpi   = 'J'
         and not exists (select 1
                           from tkpiemppl em
                          where em.dteyreap   = b_index_dteyreap
                            and em.numtime    = b_index_numtime
                            and em.codempid   = b_index_codempid
                            and em.codkpi     = v_codkpi)
      order by planno;

    cursor c_temp is
        select  to_char(planlvl) as planno,plandesc as plandes,sysdate as targtstr,sysdate as targtend, 'Y' as flgdefault
          from  tjobkpip
         where  codpos = v_codpos and codcomp like substr(v_codcomp,1,4)||'%' and codkpi = v_codkpi; 


  begin

    json_input    := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_input,'p_codkpi');
    v_typkpi      := hcm_util.get_string_t(json_input,'p_type');

    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
      v_codcompy    := hcm_util.get_codcomp_level(v_codcomp,1);
    exception when no_data_found then
      null;
    end;

    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('planno',i.planno);
      obj_data.put('plandes',i.plandes);
      obj_data.put('targtstr',to_char(i.targtstr,'dd/mm/yyyy'));
      obj_data.put('targtend',to_char(i.targtend,'dd/mm/yyyy'));
      if i.flgdefault = 'Y' then
        obj_data.put('flgAdd',v_true);
      end if;
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
--#7146 || 09/06/2022
    if v_rcnt = 0 then
      for i2 in c_temp loop
          obj_data    := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('planno',i2.planno);
          obj_data.put('plandes',i2.plandes);
          obj_data.put('targtstr',to_char(i2.targtstr,'dd/mm/yyyy'));
          obj_data.put('targtend',to_char(i2.targtend,'dd/mm/yyyy'));
          if i2.flgdefault = 'Y' then
            obj_data.put('flgAdd',v_true);
          end if;
          obj_row.put(to_char(v_rcnt),obj_data);
          v_rcnt  := v_rcnt + 1;
      end loop;
    end if;
--#7146 || 09/06/2022    
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
  procedure insert_tkpiemp(t_tkpiemp tkpiemp%rowtype) is
  v2_codcomp  varchar2(100 char); --#7235
  begin
    begin
    --#7235
      select codcomp into v2_codcomp
      from temploy1
      where codempid = b_index_codempid;
    --#7235
--#3705
      insert into tkpiemp(dteyreap,numtime,codempid,codkpi,typkpi,
                          kpides,target,mtrfinish,pctwgt,targtstr,
                          targtend,codcreate,coduser,
--#3705
                          codpos,-- )
--#3705
                         codcomp ) --#7235
      values (b_index_dteyreap,b_index_numtime,b_index_codempid,t_tkpiemp.codkpi,t_tkpiemp.typkpi,
              t_tkpiemp.kpides,t_tkpiemp.target,t_tkpiemp.mtrfinish,t_tkpiemp.pctwgt,t_tkpiemp.targtstr,
              t_tkpiemp.targtend,global_v_coduser,global_v_coduser,
--#3705
              t_tkpiemp.codpos, -- );
--#3705
              v2_codcomp ); --#7235
    exception when dup_val_on_index then
--#3705
      update tkpiemp
         set kpides      = t_tkpiemp.kpides,
             target      = t_tkpiemp.target,
             mtrfinish   = t_tkpiemp.mtrfinish,
             pctwgt      = t_tkpiemp.pctwgt,
             targtstr    = t_tkpiemp.targtstr,
             targtend    = t_tkpiemp.targtend,
             coduser     = global_v_coduser,
--#3705
             codpos      = t_tkpiemp.codpos ,
--#3705
             codcomp     = v2_codcomp
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codempid    = b_index_codempid
         and codkpi      = t_tkpiemp.codkpi;
    end;
  end;
  --
  procedure insert_tkpiempg(t_tkpiempg tkpiempg%rowtype) is
  begin
    begin
      insert into tkpiempg(dteyreap,numtime,codempid,codkpi,grade,
                           desgrade,score,color,kpides,stakpi,
                           codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,b_index_codempid,t_tkpiempg.codkpi,t_tkpiempg.grade,
              t_tkpiempg.desgrade,t_tkpiempg.score,t_tkpiempg.color,t_tkpiempg.kpides,t_tkpiempg.stakpi,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpiempg
         set kpides      = t_tkpiempg.kpides,
             stakpi      = t_tkpiempg.stakpi,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codempid    = b_index_codempid
         and codkpi      = t_tkpiempg.codkpi
         and grade       = t_tkpiempg.grade;
    end;
  end;
  --
  procedure insert_tkpiemppl(t_tkpiemppl tkpiemppl%rowtype) is
  begin
    begin
--#3705
      insert into tkpiemppl(dteyreap,numtime,codempid,codkpi,planno,
                            plandes,targtstr,targtend,codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,b_index_codempid,t_tkpiemppl.codkpi,t_tkpiemppl.planno,
              t_tkpiemppl.plandes,t_tkpiemppl.targtstr,t_tkpiemppl.targtend,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpiemppl
         set plandes     = t_tkpiemppl.plandes,
             targtstr    = t_tkpiemppl.targtstr,
             targtend    = t_tkpiemppl.targtend,
             coduser     = global_v_coduser
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codempid    = b_index_codempid
         and codkpi      = t_tkpiemppl.codkpi
         and planno      = t_tkpiemppl.planno;
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
  function auto_gen_kpino(p_codempid temploy1.codempid%type) return varchar2 is
    v_kpino   varchar2(100);
    cursor c1_kpiemp is
      select substr(codkpi,2,3) as substr_codkpi
        from tkpiemp
       where dteyreap     = b_index_dteyreap
         and numtime      = b_index_numtime
         and codempid     = p_codempid
         and substr(codkpi,1,1) = 'I'
      order by substr_codkpi desc;
  begin
    for i in c1_kpiemp loop
      if is_number(i.substr_codkpi) = 'Y' then
        v_kpino  := 'I'||lpad((to_number(i.substr_codkpi) + 1),3,'0');
        exit;
      end if;
    end loop;
    if v_kpino is null then
      v_kpino  := 'I001';
    end if;
    return v_kpino;
  end;
  --
  procedure save_kpi(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    json_kpi_detail       json_object_t;
    json_score_condition  json_object_t;
    json_scr_cond_row     json_object_t;
    json_action_plan      json_object_t;
    json_act_plan_row     json_object_t;
    v_response_json       json_object_t;
    t_tkpiemp             tkpiemp%rowtype;
    t_tkpiempg            tkpiempg%rowtype;
    t_tkpiemppl           tkpiemppl%rowtype;
    v_gen_codkpi          varchar2(20);
    v_gen_planno          varchar2(20);
    v_flg_empg            varchar2(10);
    v_flg_emppl           varchar2(10);

    v_flg_copy            boolean;
    v_dteyreap_copy number;
    v_numtime_copy  number;
    v_codempid_copy temploy1.codempid%type;

    v_codcomp             temploy1.codcomp%type;
    v_codpos              temploy1.codpos%type;
    cursor c1_kpiemppl is
      select planno
        from tkpiemppl
       where dteyreap     = b_index_dteyreap
         and numtime      = b_index_numtime
         and codempid     = b_index_codempid
         and codkpi       = t_tkpiemp.codkpi
      order by planno desc;
  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);
    b_index_dteyreap      := hcm_util.get_string_t(json_input,'p_dteyreap');
    b_index_numtime       := hcm_util.get_string_t(json_input,'p_numtime');
    b_index_codempid      := hcm_util.get_string_t(json_input,'p_codempid_query');

    --<<user46
    v_flg_copy            := hcm_util.get_boolean_t(json_input,'p_flg_copy');
    v_dteyreap_copy       := hcm_util.get_string_t(json_input,'p_dteyreap_copy');
    v_numtime_copy        := hcm_util.get_string_t(json_input,'p_numtime_copy');
    v_codempid_copy       := hcm_util.get_string_t(json_input,'p_codempid_copy');
    if v_flg_copy then
      begin
        select codcomp,codpos
          into v_codcomp,v_codpos
          from temploy1
         where codempid     = b_index_codempid;
      exception when no_data_found then
        null;
      end;

      begin
        insert into tkpiemp(dteyreap,numtime,codempid,codkpi,
                            typkpi,kpides,target,mtrfinish,
                            pctwgt,targtstr,targtend,grade,
                            qtyscor,qtyscorn,achieve,mtrrn,
                            codcomp,codpos,codcreate,coduser)
        select b_index_dteyreap,b_index_numtime,b_index_codempid,codkpi,
               typkpi,kpides,target,mtrfinish,
               pctwgt,targtstr,targtend,grade,
               qtyscor,qtyscorn,achieve,mtrrn,
               'v_codcomp 1',v_codpos,global_v_coduser,global_v_coduser
          from tkpiemp
         where codempid   = v_codempid_copy
           and dteyreap   = v_dteyreap_copy
           and numtime    = v_numtime_copy;
      exception when others then null;
      end;

      begin
        insert into tobjemp(dteyreap,numtime,codempid,codcomp,
                            objective,codcreate,coduser)
        select b_index_dteyreap,b_index_numtime,b_index_codempid,v_codcomp,
               objective,global_v_coduser,global_v_coduser
          from tobjemp
         where codempid   = v_codempid_copy
           and dteyreap   = v_dteyreap_copy
           and numtime    = v_numtime_copy;
      exception when others then null;
      end;

      begin
        insert into tkpiempg(dteyreap,numtime,codempid,
                             codkpi,grade,desgrade,score,color,kpides,stakpi,
                             codcreate,coduser)
        select b_index_dteyreap,b_index_numtime,b_index_codempid,
               codkpi,grade,desgrade,score,color,kpides,stakpi,
               global_v_coduser,global_v_coduser
          from tkpiempg
         where codempid   = v_codempid_copy
           and dteyreap   = v_dteyreap_copy
           and numtime    = v_numtime_copy;
      exception when others then null;
      end;

      begin
        insert into tkpiemppl(dteyreap,numtime,codempid,
                              codkpi,planno,plandes,targtstr,
                              targtend,dtewstr,dtewend,workdesc,
                              codcreate,coduser)
        select b_index_dteyreap,b_index_numtime,b_index_codempid,
               codkpi,planno,plandes,targtstr,
               targtend,dtewstr,dtewend,workdesc,
               global_v_coduser,global_v_coduser
          from tkpiemppl
         where codempid   = v_codempid_copy
           and dteyreap   = v_dteyreap_copy
           and numtime    = v_numtime_copy;
      exception when others then null;
      end;
    end if;
    -->>
    param_json            := hcm_util.get_json_t(json_input,'param_json');
    json_kpi_detail       := hcm_util.get_json_t(param_json,'detail');
    t_tkpiemp.codkpi      := hcm_util.get_string_t(json_kpi_detail,'codkpi');
    t_tkpiemp.typkpi      := hcm_util.get_string_t(json_kpi_detail,'typkpi');
    t_tkpiemp.kpides      := hcm_util.get_string_t(json_kpi_detail,'kpides');
    t_tkpiemp.target      := hcm_util.get_string_t(json_kpi_detail,'target');
    t_tkpiemp.mtrfinish   := hcm_util.get_string_t(json_kpi_detail,'mtrfinish');
    t_tkpiemp.pctwgt      := hcm_util.get_string_t(json_kpi_detail,'pctwgt');
    t_tkpiemp.targtstr    := to_date(hcm_util.get_string_t(json_kpi_detail,'targtstr'),'dd/mm/yyyy');
    t_tkpiemp.targtend    := to_date(hcm_util.get_string_t(json_kpi_detail,'targtend'),'dd/mm/yyyy');
--#3705
    t_tkpiemp.codpos      := hcm_util.get_string_t(json_kpi_detail,'codpos');
    if t_tkpiemp.codpos is null then
        begin
          select codpos into t_tkpiemp.codpos
            from temploy1
           where codempid = b_index_codempid;
        exception when no_data_found then null;
        end;
    end if;
--#3705

    if t_tkpiemp.codkpi is null then
      t_tkpiemp.codkpi    := auto_gen_kpino(b_index_codempid);
    end if;
    insert_tkpiemp(t_tkpiemp);

    json_score_condition  := hcm_util.get_json_t(param_json,'scr_cond');
    if json_score_condition.get_size > 0 then
      for i in 0..(json_score_condition.get_size - 1) loop
        json_scr_cond_row     := hcm_util.get_json_t(json_score_condition,to_char(i));
        t_tkpiempg.codkpi     := t_tkpiemp.codkpi;
        t_tkpiempg.grade      := hcm_util.get_string_t(json_scr_cond_row,'grade');
        t_tkpiempg.desgrade   := hcm_util.get_string_t(json_scr_cond_row,'desgrade');
        t_tkpiempg.score      := hcm_util.get_string_t(json_scr_cond_row,'score');
        t_tkpiempg.color      := hcm_util.get_string_t(json_scr_cond_row,'color');
        t_tkpiempg.kpides     := hcm_util.get_string_t(json_scr_cond_row,'kpides');
        t_tkpiempg.stakpi     := hcm_util.get_string_t(json_scr_cond_row,'stakpi');
        v_flg_empg            := hcm_util.get_string_t(json_scr_cond_row,'flg');
        if v_flg_empg in ('add','edit') then
          insert_tkpiempg(t_tkpiempg);
        end if;
      end loop;
    end if;

    json_action_plan      := hcm_util.get_json_t(param_json,'act_plan');
    if json_action_plan.get_size > 0 then
      for i in 0..(json_action_plan.get_size - 1) loop
        json_act_plan_row     := hcm_util.get_json_t(json_action_plan,to_char(i));
        t_tkpiemppl.codkpi    := t_tkpiemp.codkpi;
        t_tkpiemppl.planno    := hcm_util.get_string_t(json_act_plan_row,'planno');
        t_tkpiemppl.plandes   := hcm_util.get_string_t(json_act_plan_row,'plandes');
        t_tkpiemppl.targtstr  := to_date(hcm_util.get_string_t(json_act_plan_row,'targtstr'),'dd/mm/yyyy');
        t_tkpiemppl.targtend  := to_date(hcm_util.get_string_t(json_act_plan_row,'targtend'),'dd/mm/yyyy');
        v_flg_emppl           := hcm_util.get_string_t(json_act_plan_row,'flg');
        v_gen_planno          := null;
        if t_tkpiemppl.planno is null then
          for i in c1_kpiemppl loop
            if is_number(i.planno) = 'Y' then
              v_gen_planno  := lpad((to_number(i.planno) + 1),4,'0');
              exit;
            end if;
          end loop;
          if v_gen_planno is null then
            v_gen_planno  := '0001';
          end if;
          t_tkpiemppl.planno    := v_gen_planno;
        end if;
        if v_flg_emppl in ('add','edit') then
          insert_tkpiemppl(t_tkpiemppl);
        elsif v_flg_emppl = 'delete' then
          delete from tkpiemppl
           where dteyreap    = b_index_dteyreap
             and numtime     = b_index_numtime
             and codempid    = b_index_codempid
             and codkpi      = t_tkpiemppl.codkpi
             and planno      = t_tkpiemppl.planno;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      v_response_json   := json_object_t();
      v_response_json.put('coderror','200');
      v_response_json.put('desc_coderror','HR2401 '||get_errorm_name('HR2401',global_v_lang));
      v_response_json.put('response','HR2401 '||get_errorm_name('HR2401',global_v_lang));
      v_response_json.put('field_name','');
      v_response_json.put('codkpi',t_tkpiemp.codkpi);
      v_response_json.put('typkpi',t_tkpiemp.typkpi);
      json_str_output   := v_response_json.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_copy_kpi(json_str_input in clob) is
    json_input        json_object_t;
    v_dteyreap_copy   number;
    v_numtime_copy    number;
    v_codempid_copy   temploy1.codempid%type;
    v_codcomp         temploy1.codcomp%type;
    v_codpos          temploy1.codpos%type;
  begin
    json_input  := json_object_t(json_str_input);

    v_dteyreap_copy       := hcm_util.get_string_t(json_input,'p_dteyreap_copy');
    v_numtime_copy        := hcm_util.get_string_t(json_input,'p_numtime_copy');
    v_codempid_copy       := hcm_util.get_string_t(json_input,'p_codempid_copy');
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid     = b_index_codempid;
    exception when no_data_found then
      null;
    end;

    begin
      insert into tkpiemp(dteyreap,numtime,codempid,codkpi,
                          typkpi,kpides,target,mtrfinish,
                          pctwgt,targtstr,targtend,grade,
                          qtyscor,qtyscorn,achieve,mtrrn,
                          codcomp,codpos,codcreate,coduser)
      select b_index_dteyreap,b_index_numtime,b_index_codempid,codkpi,
             typkpi,kpides,target,mtrfinish,
             pctwgt,targtstr,targtend,grade,
             qtyscor,qtyscorn,achieve,mtrrn,
             'v_codcomp 2',v_codpos,global_v_coduser,global_v_coduser
        from tkpiemp
       where codempid   = v_codempid_copy
         and dteyreap   = v_dteyreap_copy
         and numtime    = v_numtime_copy;
    exception when others then null;
    end;

    begin
      insert into tobjemp(dteyreap,numtime,codempid,codcomp,
                          objective,codcreate,coduser)
      select b_index_dteyreap,b_index_numtime,b_index_codempid,v_codcomp,
             objective,global_v_coduser,global_v_coduser
        from tobjemp
       where codempid   = v_codempid_copy
         and dteyreap   = v_dteyreap_copy
         and numtime    = v_numtime_copy;
    exception when others then null;
    end;

    begin
      insert into tkpiempg(dteyreap,numtime,codempid,
                           codkpi,grade,desgrade,score,color,kpides,stakpi,
                           codcreate,coduser)
      select b_index_dteyreap,b_index_numtime,b_index_codempid,
             codkpi,grade,desgrade,score,color,kpides,stakpi,
             global_v_coduser,global_v_coduser
        from tkpiempg
       where codempid   = v_codempid_copy
         and dteyreap   = v_dteyreap_copy
         and numtime    = v_numtime_copy;
    exception when others then null;
    end;

    begin
      insert into tkpiemppl(dteyreap,numtime,codempid,
                            codkpi,planno,plandes,targtstr,
                            targtend,dtewstr,dtewend,workdesc,
                            codcreate,coduser)
      select b_index_dteyreap,b_index_numtime,b_index_codempid,
             codkpi,planno,plandes,targtstr,
             targtend,dtewstr,dtewend,workdesc,
             global_v_coduser,global_v_coduser
        from tkpiemppl
       where codempid   = v_codempid_copy
         and dteyreap   = v_dteyreap_copy
         and numtime    = v_numtime_copy;
    exception when others then null;
    end;
  end;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    t_tkpiemp             tkpiemp%rowtype;
    v_codkpi              tkpiemp.codkpi%type;
    v_objective           tobjemp.objective%type;
    v_codcomp             temploy1.codcomp%type;
    v_codpos              temploy1.codpos%type;
    v_flg                 varchar2(50);
    v_flg_delete          varchar2(1) := 'N';
    v_eval                varchar2(1) := 'N';
    v_found               varchar2(1) := 'N';
    v_flg_copy            boolean;
    v_flg_copy_str        varchar2(1) := 'N';
  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);
    b_index_dteyreap      := hcm_util.get_string_t(json_input,'p_dteyreap');
    b_index_numtime       := hcm_util.get_string_t(json_input,'p_numtime');
    b_index_codempid      := hcm_util.get_string_t(json_input,'p_codempid_query');
    v_objective           := hcm_util.get_string_t(json_input,'p_objective');
    v_flg_copy            := hcm_util.get_boolean_t(json_input,'p_flg_copy');
    if v_flg_copy then
      save_copy_kpi(json_str_input); --<<user46
      v_flg_copy_str  := 'Y';
    end if;
    param_json            := hcm_util.get_json_t(json_input,'param_json');
    for i in 0..(param_json.get_size - 1) loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_codkpi            := hcm_util.get_string_t(param_json_row,'codkpi');
      v_flg               := hcm_util.get_string_t(param_json_row,'flg');
      if v_flg = 'delete' then
        v_flg_delete  := 'Y';
        begin
          select 'Y'
            into v_eval
            from tkpiemp
           where dteyreap    = b_index_dteyreap
             and numtime     = b_index_numtime
             and codempid    = b_index_codempid
             and codkpi      = v_codkpi
             and grade       is not null
             and v_flg_copy_str = 'N';
             param_msg_error := get_error_msg_php('HR1450',global_v_lang);
             exit;
        exception when no_data_found then
          delete tkpiemp
           where dteyreap    = b_index_dteyreap
             and numtime     = b_index_numtime
             and codempid    = b_index_codempid
             and codkpi      = v_codkpi;

          delete tkpiempg
           where dteyreap    = b_index_dteyreap
             and numtime     = b_index_numtime
             and codempid    = b_index_codempid
             and codkpi      = v_codkpi;

          delete tkpiemppl
           where dteyreap    = b_index_dteyreap
             and numtime     = b_index_numtime
             and codempid    = b_index_codempid
             and codkpi      = v_codkpi;
        end;
      elsif v_flg = 'add' then
        t_tkpiemp.codkpi      := hcm_util.get_string_t(param_json_row,'codkpi');
        t_tkpiemp.typkpi      := hcm_util.get_string_t(param_json_row,'typkpi');
        t_tkpiemp.kpides      := hcm_util.get_string_t(param_json_row,'kpides');
        t_tkpiemp.target      := hcm_util.get_string_t(param_json_row,'target');
        t_tkpiemp.mtrfinish   := hcm_util.get_string_t(param_json_row,'mtrfinish');
        insert_tkpiemp(t_tkpiemp);
      end if;
    end loop;
    begin
      select 'Y'
        into v_found
        from tkpiemp
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codempid    = b_index_codempid
         and rownum      = 1;
    exception when no_data_found then
      v_found   := 'N';
    end;

    if v_found = 'Y' or v_flg_delete = 'N' then
      begin
        select codcomp into v_codcomp
          from temploy1
         where codempid = b_index_codempid;
        --<< user20 Date: 25/08/2021  AP Module- #5832
        exception when no_data_found then v_codcomp := null;
        -->> user20 Date: 25/08/2021  AP Module- #5832
      end;
      begin
        insert into tobjemp(dteyreap,numtime,codempid,codcomp,
                            objective,codcreate,coduser)
        values (b_index_dteyreap,b_index_numtime,b_index_codempid,v_codcomp,
                v_objective,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tobjemp
           set objective   = v_objective,
               coduser     = global_v_coduser
         where dteyreap    = b_index_dteyreap
           and numtime     = b_index_numtime
           and codempid    = b_index_codempid;
      end;
    else
      delete tobjemp
       where dteyreap    = b_index_dteyreap
         and numtime     = b_index_numtime
         and codempid    = b_index_codempid;
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
  --
  function validate_import_data(p_col_key   t_arr_char,
                                p_col_name  t_arr_char,
                                p_col_value t_arr_char) return varchar2 is
    v_error     varchar2(4000);
    v_code      varchar2(1000);
    v_code2     varchar2(1000);
    v_code3     varchar2(1000);
    v_boolean   boolean;
    v_zupdsal   varchar2(1);
    v_max       number;
    v_codemp_not_found varchar2(1) := 'N';

    v_codcomp   temploy1.codcomp%type;
    v_codpos    temploy1.codpos%type;
  begin
    if p_col_value(1) is not null then
      begin
        select codempid,staemp,codpos,codcomp
          into v_code,v_code2,v_codpos,v_codcomp
          from temploy1
         where codempid   = p_col_value(1);
      exception when no_data_found then
        v_codemp_not_found := 'Y';
        v_error   := v_error||','||p_col_name(1)||' - HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
      end;

      v_boolean   := secur_main.secur2(v_code,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_boolean then
        v_error   := v_error||','||p_col_name(1)||' - HR3007 '||get_errorm_name('HR3007',global_v_lang);
      elsif v_code2 = '0' then
        v_error   := v_error||','||p_col_name(1)||' - HR2102 '||get_errorm_name('HR2102',global_v_lang);
      elsif v_code2 = '9' then
        v_error   := v_error||','||p_col_name(1)||' - HR2101 '||get_errorm_name('HR2101',global_v_lang);
      end if;
    else
      v_error   := v_error||','||p_col_name(1)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
--<< user20 Date: 25/08/2021  AP Module- #5832
    if p_col_value(3) is null and p_col_value(4) in ('D','J') then
      v_error   := v_error||','||p_col_name(3)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    elsif p_col_value(3) is null and p_col_value(4) = 'I' then
        global_v_kpino := auto_gen_kpino(p_col_value(1));
    end if;
-->> user20 Date: 25/08/2021  AP Module- #5832

    if p_col_value(2) is not null then
      v_boolean   := hcm_validate.check_length(p_col_value(2),'TOBJEMP','OBJECTIVE',v_max);
      if v_boolean then
        v_error := v_error||','||p_col_name(2)||' - HR6591 '||get_errorm_name('HR6591',global_v_lang)||' (Max: '||v_max||')';
      end if;
    else
      v_error   := v_error||','||p_col_name(2)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    if p_col_value(4) is not null then
      if p_col_value(4) not in ('D','J','I') then
        v_error   := v_error||','||p_col_name(4)||' - HR2057 '||get_errorm_name('HR2057',global_v_lang)||' (''D'',''J'',''I'')';
      else
        if p_col_value(3) is not null then
          if p_col_value(4) = 'D' then
            if v_codemp_not_found = 'N' then
              begin
                select codkpino
                  into v_code
                  from tkpidpem
                 where dteyreap   = b_index_dteyreap
                   and numtime    = b_index_numtime
                   and codcomp    = v_codcomp
                   and codempid   = p_col_value(1)
                   and codkpino   = p_col_value(3);
              exception when no_data_found then
                v_error   := v_error||','||p_col_name(3)||' - HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TKPIDPEM)';
              end;
            end if;
          elsif p_col_value(4) = 'J' then
            begin
              select codkpi
                into v_code
                from tjobkpi
               where codpos     = v_codpos
                 and codcomp    = v_codcomp
                 and codkpi     = p_col_value(3);
            exception when no_data_found then
              v_error   := v_error||','||p_col_name(3)||' - HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TJOBKPI)';
            end;
          else
            if v_codemp_not_found = 'N' then
              begin
                select codkpi
                  into v_code
                  from tkpiemp
                 where dteyreap   = b_index_dteyreap
                   and numtime    = b_index_numtime
                   and codempid   = p_col_value(1)
                   and codkpi     = p_col_value(3);
              exception when no_data_found then
                v_error   := v_error||','||p_col_name(3)||' - HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TKPIEMP)';
              end;
            end if;
          end if;
        else
          if p_col_value(4) not in ('D','J') then
            v_error   := v_error||','||p_col_name(3)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
          end if;
        end if;
      end if;
    else
      v_error   := v_error||','||p_col_name(4)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    for i in 5..8 loop
      if p_col_value(i) is not null then
        v_boolean   := hcm_validate.check_length(p_col_value(i),'TKPIEMP',upper(p_col_key(i)),v_max);
        if v_boolean then
          v_error := v_error||','||p_col_name(i)||' - HR6591 '||get_errorm_name('HR6591',global_v_lang)||' (Max: '||v_max||')';
        end if;
      else
        v_error   := v_error||','||p_col_name(i)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
      end if;
    end loop;
    --
    if p_col_value(9) is not null then
      v_boolean   := hcm_validate.check_date(p_col_value(9));
      if v_boolean then
        v_error   := v_error||','||p_col_name(9)||' - HR2025 '||get_errorm_name('HR2025',global_v_lang);
        v_code3   := 'COL9E';
      else
        v_code3   := 'COL9P';
      end if;
    else
      v_error   := v_error||','||p_col_name(9)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    if p_col_value(10) is not null then
      v_boolean   := hcm_validate.check_date(p_col_value(10));
      if v_boolean then
        v_error   := v_error||','||p_col_name(10)||' - HR2025 '||get_errorm_name('HR2025',global_v_lang);
      else
        if v_code3 = 'COL9P' and to_date(p_col_value(9),'dd/mm/yyyy') > to_date(p_col_value(10),'dd/mm/yyyy') then
          v_error   := v_error||','||p_col_name(10)||' - HR2021 '||get_errorm_name('HR2021',global_v_lang);
        end if;
      end if;
    else
      v_error   := v_error||','||p_col_name(10)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    if p_col_value(11) is not null then
      begin
        select grade
          into v_code
          from tgradekpi
         where codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
           and grade      = p_col_value(11)
           and dteyreap   = (select max(dteyreap)
                               from tgradekpi
                              where codcompy    = hcm_util.get_codcomp_level(v_codcomp,1)
                                and dteyreap    <= to_char(sysdate,'yyyy'));
      exception when no_data_found then
        v_error   := v_error||','||p_col_name(11)||' - HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TGRADEKPI)';
      end;
    else
      v_error   := v_error||','||p_col_name(11)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    if p_col_value(11) is not null then
      begin
        select grade
          into v_code
          from tgradekpi
         where codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
           and grade      = p_col_value(11)
           and dteyreap   = (select max(dteyreap)
                               from tgradekpi
                              where codcompy    = hcm_util.get_codcomp_level(v_codcomp,1)
                                and dteyreap    <= to_char(sysdate,'yyyy'));
      exception when no_data_found then
        v_error   := v_error||','||p_col_name(11)||' - HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TGRADEKPI)';
      end;
    else
      v_error   := v_error||','||p_col_name(11)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    if p_col_value(12) is not null then
      v_boolean   := hcm_validate.check_length(p_col_value(12),'TKPIEMPG','KPIDES',v_max);
      if v_boolean then
        v_error := v_error||','||p_col_name(12)||' - HR6591 '||get_errorm_name('HR6591',global_v_lang)||' (Max: '||v_max||')';
      end if;
    else
      v_error   := v_error||','||p_col_name(12)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    if p_col_value(13) is not null then
      if p_col_value(13) not in ('Y','N') then
        v_error   := v_error||','||p_col_name(13)||' - HR2057 '||get_errorm_name('HR2057',global_v_lang)||' (''Y'',''N'')';
      end if;
    else
      v_error   := v_error||','||p_col_name(13)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
    end if;
    --
    for i in 14..15 loop
      if p_col_value(i) is not null then
        v_boolean   := hcm_validate.check_length(p_col_value(i),'TKPIEMPPL',upper(p_col_key(i)),v_max);
        if v_boolean then
          v_error := v_error||','||p_col_name(i)||' - HR6591 '||get_errorm_name('HR6591',global_v_lang)||' (Max: '||v_max||')';
        end if;
      end if;
    end loop;
    --
    if p_col_value(16) is not null then
      v_boolean   := hcm_validate.check_date(p_col_value(16));
      if v_boolean then
        v_error   := v_error||','||p_col_name(16)||' - HR2025 '||get_errorm_name('HR2025',global_v_lang);
        v_code3   := 'COL16E';
      else
        v_code3   := 'COL16P';
      end if;
    else
      if p_col_value(17) is not null then
        v_error   := v_error||','||p_col_name(16)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
      end if;
    end if;
    --
    if p_col_value(17) is not null then
      v_boolean   := hcm_validate.check_date(p_col_value(17));
      if v_boolean then
        v_error   := v_error||','||p_col_name(17)||' - HR2025 '||get_errorm_name('HR2025',global_v_lang);
      else
        if v_code3 = 'COL16P' and to_date(p_col_value(16),'dd/mm/yyyy') > to_date(p_col_value(17),'dd/mm/yyyy') then
          v_error   := v_error||','||p_col_name(17)||' - HR2021 '||get_errorm_name('HR2021',global_v_lang);
        end if;
      end if;
    else
      if p_col_value(16) is not null then
        v_error   := v_error||','||p_col_name(17)||' - HR2045 '||get_errorm_name('HR2045',global_v_lang);
      end if;
    end if;

    return substr(v_error,2);
  end;
  --
  function insert_tobjemp(p_col_value  t_arr_char) return varchar2 is
    v_error     varchar2(4000);
    v_codcomp   temploy1.codcomp%type;
  begin
    begin
      select codcomp
        into v_codcomp
        from temploy1
       where codempid     = p_col_value(1);
    exception when no_data_found then
      null;
    end;
    begin
      insert into tobjemp(dteyreap,numtime,codempid,codcomp,
                          objective,codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,p_col_value(1),v_codcomp,
              p_col_value(2),global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tobjemp
         set objective    = p_col_value(2),
             coduser      = global_v_coduser
       where dteyreap     = b_index_dteyreap
         and numtime      = b_index_numtime
         and codempid     = p_col_value(1);
    end;
    return '';
  exception when others then
    v_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return v_error;
  end;
  --
  function insert_tkpiemp(p_col_value  t_arr_char) return varchar2 is
    v_error     varchar2(4000);
    v_codcomp   temploy1.codcomp%type;
    v_codpos    temploy1.codpos%type;
    v_kpino     tkpiemp.codkpi%type;
  begin
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid     = p_col_value(1);
    exception when no_data_found then
      null;
    end;

/*--<< user20 Date: 25/08/2021  AP Module- #5832
    v_kpino := p_col_value(3);
    if p_col_value(4) = 'I' and v_kpino is null then
      v_kpino := auto_gen_kpino(p_col_value(1));
    end if;
-->> user20 Date: 25/08/2021  AP Module- #5832 */

--<< user20 Date: 25/08/2021  AP Module- #5832
    v_kpino := nvl(p_col_value(3), global_v_kpino);
    if p_col_value(4) = 'I' and v_kpino is null then
      v_kpino := auto_gen_kpino(p_col_value(1));
      global_v_kpino := v_kpino;
    end if;
-->> user20 Date: 25/08/2021  AP Module- #5832

    begin
      insert into tkpiemp(dteyreap,numtime,codempid,codkpi,typkpi,
                          kpides,target,mtrfinish,pctwgt,targtstr,
                          targtend,codcomp,codpos,codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,p_col_value(1),v_kpino,p_col_value(4),
              p_col_value(5),p_col_value(6),p_col_value(7),p_col_value(8),to_date(p_col_value(9),'dd/mm/yyyy'),
              to_date(p_col_value(10),'dd/mm/yyyy'),'v_codcomp 3',v_codpos,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tkpiemp
         set kpides       = p_col_value(5),
             target       = p_col_value(6),
             mtrfinish    = p_col_value(7),
             pctwgt       = p_col_value(8),
             targtstr     = to_date(p_col_value(9),'dd/mm/yyyy'),
             targtend     = to_date(p_col_value(10),'dd/mm/yyyy'),
             coduser      = global_v_coduser,
             codcomp      = 'v_codcomp 3'
       where dteyreap     = b_index_dteyreap
         and numtime      = b_index_numtime
         and codempid     = p_col_value(1)
         and codkpi       = v_kpino;
    end;
    return '';
  exception when others then
    v_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return v_error;
  end;
  --
  function insert_tkpiempg(p_col_value  t_arr_char) return varchar2 is
    v_error     varchar2(4000);
    v_codkpi    varchar2(30) := p_col_value(3);
  begin
--<< user20 Date: 25/08/2021  AP Module- #5832
    v_codkpi := nvl(v_codkpi, global_v_kpino);
-->> user20 Date: 25/08/2021  AP Module- #5832
    begin
      insert into tkpiempg(dteyreap,numtime,codempid,codkpi,grade,
                           kpides,stakpi,codcreate,coduser)
      values (b_index_dteyreap,b_index_numtime,p_col_value(1),v_codkpi,p_col_value(11),
              p_col_value(12),p_col_value(13),global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then

      update tkpiempg
         set kpides       = p_col_value(12),
             stakpi       = p_col_value(13),
             coduser      = global_v_coduser
       where dteyreap     = b_index_dteyreap
         and numtime      = b_index_numtime
         and codempid     = p_col_value(1)
         and codkpi       = v_codkpi
         and grade        = p_col_value(11);
    end;
    return '';
  exception when others then
    v_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return v_error;
  end;
  --
  function insert_tkpiemppl(p_col_value  t_arr_char) return varchar2 is
    v_error     varchar2(4000);
    v_codkpi    varchar2(30) := p_col_value(3);
  begin
--<< user20 Date: 25/08/2021  AP Module- #5832
    v_codkpi := nvl(v_codkpi, global_v_kpino);
-->> user20 Date: 25/08/2021  AP Module- #5832
    if p_col_value(14) is not null then
      begin
        insert into tkpiemppl(dteyreap,numtime,codempid,codkpi,planno,
                             plandes,targtstr,targtend,codcreate,coduser)
        values (b_index_dteyreap,b_index_numtime,p_col_value(1),v_codkpi,p_col_value(14),
                p_col_value(15),p_col_value(16),p_col_value(17),global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tkpiemppl
           set plandes      = p_col_value(15),
               targtstr     = p_col_value(16),
               targtend     = p_col_value(17),
               coduser      = global_v_coduser
         where dteyreap     = b_index_dteyreap
           and numtime      = b_index_numtime
           and codempid     = p_col_value(1)
           and codkpi       = v_codkpi
           and planno       = p_col_value(14);
      end;
    end if;
    return '';
  exception when others then
    v_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return v_error;
  end;
  --
  procedure get_codcomp_codpos(p_codempid in varchar2, p_codcomp out varchar2, p_codpos out varchar2) is
    v_codcomp     temploy1.codcomp%type;
    v_codpos      temploy1.codpos%type;
  begin
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = p_codempid;
    exception when no_data_found then
      null;
    end;
    p_codcomp   := v_codcomp;
    p_codpos    := v_codpos;
  end;
  --
  function check_codempid(p_codempid varchar2) return varchar2 is
    v_codcomp   temploy1.codcomp%type;
    v_numlvl    temploy1.numlvl%type;
    v_staemp    temploy1.staemp%type;
    v_secure    boolean;
    v_zupdsal   varchar2(1);
  begin
    if p_codempid is null then
      return get_terrorm_name('HR2045',global_v_lang)||' ('||arr_col_name('codempid')||')';
    end if;
    begin
      select codcomp,numlvl,staemp
        into v_codcomp,v_numlvl,v_staemp
        from temploy1
       where codempid   = p_codempid;
    exception when no_data_found then
      return get_terrorm_name('HR2010',global_v_lang)||' TEMPLOY1'||' ('||arr_col_name('codempid')||')';
    end;
    if v_staemp = '0' then
      return get_terrorm_name('HR2102',global_v_lang)||' ('||arr_col_name('codempid')||')';
    end if;
    if v_staemp = '9'then
      return get_terrorm_name('HR2101',global_v_lang)||' ('||arr_col_name('codempid')||')';
    end if;
    v_secure    := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    if not v_secure then
      return get_terrorm_name('HR3007',global_v_lang)||' ('||arr_col_name('codempid')||')';
    end if;
    return '';
  end;
  --
  function validate_object return varchar2 is
    v_error     varchar2(4000);
    v_boolean   boolean;
    v_max       number;
  begin
    v_error   := check_codempid(arr_col_value('codempid'));
    if v_error is not null then
      return v_error;
    end if;
    if arr_col_value('objective') is null then
      return get_terrorm_name('HR2045',global_v_lang)||' ('||arr_col_name('objective')||')';
    else
      v_boolean := hcm_validate.check_length(arr_col_value('objective'),'TOBJEMP','OBJECTIVE',v_max);
      if v_boolean then
        return get_errorm_name('HR6591',global_v_lang)||' Max: '||v_max||' ('||arr_col_name('objective')||')';
      end if;
    end if;
    return '';
  end;
  --
  function import_tobjemp(param_column  json_object_t,
                          param_data    json_object_t,
                          p_num_rec_pass out number,
                          p_num_rec_fail out number) return json_object_t is
    obj_result      json_object_t;
    obj_row         json_object_t;
--    obj_data_sheet  json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_error_msg     varchar2(4000);

    obj_tobjemp_col         json_object_t;
    obj_tobjemp_col_row     json_object_t;
    obj_tobjemp             json_object_t;
    obj_tobjemp_row         json_object_t;
--    t_tobjemp               tobjemp%rowtype;
    v_key                   varchar2(100);
    tobjemp_complete        number := 0;
    tobjemp_error           number := 0;
    v_rcnt                  number := 0;
  begin
    -- set column name --
--    obj_data_sheet    := hcm_util.get_json_t(param_data,'dataSheet');
    obj_tobjemp       := hcm_util.get_json_t(param_data,'p_kpi_objective');
    obj_tobjemp_col   := hcm_util.get_json_t(param_column,'p_kpi_objective');
    arr_col_name      := arr_col_empty;
    arr_col_value     := arr_col_empty;
    for i in 0..(obj_tobjemp_col.get_size - 1) loop
      obj_tobjemp_col_row := hcm_util.get_json_t(obj_tobjemp_col,to_char(i));
      v_key := hcm_util.get_string_t(obj_tobjemp_col_row,'key');
      arr_col_name(v_key) := hcm_util.get_string_t(obj_tobjemp_col_row,'name');
    end loop;

    obj_row := json_object_t();
    for i in 0..(obj_tobjemp.get_size - 1) loop
      obj_tobjemp_row             := hcm_util.get_json_t(obj_tobjemp,to_char(i));
      arr_col_value('codempid')   := hcm_util.get_string_t(obj_tobjemp_row,'codempid');
      arr_col_value('objective')  := hcm_util.get_string_t(obj_tobjemp_row,'objective');
      v_error_msg                 := validate_object;
      get_codcomp_codpos(arr_col_value('codempid'),v_codcomp,v_codpos);

      if v_error_msg is null then
        begin
          insert into tobjemp(dteyreap,numtime,codempid,codcomp,
                              objective,codcreate,coduser)
          values (b_index_dteyreap,b_index_numtime,arr_col_value('codempid'),v_codcomp,
                  arr_col_value('objective'),'IMPORT','IMPORT');
        exception when dup_val_on_index then
          update tobjemp
             set objective  = arr_col_value('objective'),
                 codcomp    = v_codcomp,
                 coduser    = 'IMPORT'
           where dteyreap   = b_index_dteyreap
             and numtime    = b_index_numtime
             and codempid   = arr_col_value('codempid');
        end;
        tobjemp_complete  := tobjemp_complete + 1;
      else
        tobjemp_error     := tobjemp_error + 1;
        obj_result        := json_object_t();
        obj_result.put('line_error',to_char(i + 1));
        obj_result.put('desc_data',get_label_name('HRAP32EC3',global_v_lang,170));
        obj_result.put('err_detail',v_error_msg);
        obj_row.put(to_char(v_rcnt),obj_result);
        v_rcnt  := v_rcnt + 1;
      end if;
    end loop;
    p_num_rec_pass    := tobjemp_complete;
    p_num_rec_fail    := tobjemp_error;
    return obj_row;
  end;
  --
  function validate_kpi_emp return varchar2 is
    v_error         varchar2(4000);
    v_max           number;
    v_boolean       boolean;
    v_first_char    varchar2(10);
  begin
    v_error   := check_codempid(arr_col_value('codempid'));
    if v_error is not null then
      return v_error;
    end if;
    begin
      select 'Y'
        into v_error
        from tobjemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = arr_col_value('codempid');
    exception when no_data_found then
      return get_terrorm_name('HR2010',global_v_lang)||' TOBJEMP';
    end;
    if arr_col_value('codkpi') is null then
      return get_terrorm_name('HR2045',global_v_lang)||' ('||arr_col_name('codkpi')||')';
    else
      if arr_col_value('typkpi') = 'I' then
        if length(arr_col_value('codkpi')) <> 4 then
          return get_errorm_name('HR2020',global_v_lang)||' ('||arr_col_name('codkpi')||')';
        end if;
        v_first_char  := substr(arr_col_value('codkpi'),1,1);
        if v_first_char <> 'I' then
          return get_errorm_name('AP0066',global_v_lang)||' ('||arr_col_name('typkpi')||')';
        end if;
      elsif arr_col_value('typkpi') = 'D' then
        begin
          select 'Y'
            into v_error
            from tkpidph  -- issue 7026 SA(Ball) recommend to check data from tkpidph (the first checked at TKPIDPEMP)
           where dteyreap     = b_index_dteyreap
             and numtime      = b_index_numtime
             and codcomp      = arr_col_value('codcomp')
             and codkpino     = arr_col_value('codkpi');
--             and codempid     = arr_col_value('codempid');
        exception when no_data_found then
          return get_errorm_name('HR2010',global_v_lang)||' TKPIDPH';
        end;
      elsif arr_col_value('typkpi') = 'J' then
        begin
          select 'Y'
            into v_error
            from tjobkpi
           where codpos     = arr_col_value('codpos')
             and codcomp    = arr_col_value('codcomp')
             and codkpi     = arr_col_value('codkpi');
        exception when no_data_found then
          return get_errorm_name('HR2010',global_v_lang)||' TJOBKPI';
        end;
      else
        if arr_col_value('typkpi') is null then
          return get_terrorm_name('HR2045',global_v_lang)||' ('||arr_col_name('typkpi')||')';
        else
--            if arr_col_value('typkpi') not in ('D','J','I') then
          return get_errorm_name('HR2057',global_v_lang)||' (''D'',''J'',''I'')'||' ('||arr_col_name('typkpi')||')';
--            end if;
        end if;
      end if;
    end if;
    if arr_col_value('kpides') is null then
      return get_terrorm_name('HR2045',global_v_lang)||' ('||arr_col_name('kpides')||')';
    else
      v_boolean := hcm_validate.check_length(arr_col_value('kpides'),'TKPIEMP','KPIDES',v_max);
      if v_boolean then
        return get_errorm_name('HR6591',global_v_lang)||' Max: '||v_max||' ('||arr_col_name('kpides')||')';
      end if;
    end if;

    if arr_col_value('target') is null then
      return get_terrorm_name('HR2045',global_v_lang)||' ('||arr_col_name('target')||')';
    else
      v_boolean := hcm_validate.check_length(arr_col_value('target'),'TKPIEMP','TARGET',v_max);
      if v_boolean then
        return get_errorm_name('HR6591',global_v_lang)||' Max: '||v_max||' ('||arr_col_name('target')||')';
      end if;
    end if;

    if arr_col_value('pctwgt') is null then
      return get_terrorm_name('HR2045',global_v_lang)||' ('||arr_col_name('pctwgt')||')';
    else
      if is_number(arr_col_value('pctwgt')) = 'Y' then
        if to_number(arr_col_value('pctwgt')) not between 0 and 100 then
          return get_terrorm_name('HR2020',global_v_lang)||' ('||arr_col_name('pctwgt')||')';
        end if;
      else
        return get_terrorm_name('HR2020',global_v_lang)||' ('||arr_col_name('pctwgt')||')';
      end if;
    end if;

    if is_number(arr_col_value('mtrfinish')) = 'Y' then
      v_boolean := hcm_validate.check_length(arr_col_value('mtrfinish'),'TKPIEMP','MTRFINISH',v_max);
      if v_boolean then
        return get_errorm_name('HR6591',global_v_lang)||' Max: '||v_max||' ('||arr_col_name('mtrfinish')||')';
      end if;
    else
      return get_terrorm_name('HR2020',global_v_lang)||' ('||arr_col_name('mtrfinish')||')';
    end if;

    if arr_col_value('targtstr') is not null then
      v_boolean   := hcm_validate.check_date(arr_col_value('targtstr'));
      if v_boolean then
        return get_errorm_name('HR2025',global_v_lang)||' ('||arr_col_name('targtstr')||')';
      end if;
    else
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('targtstr')||')';
    end if;

    if arr_col_value('targtend') is not null then
      v_boolean   := hcm_validate.check_date(arr_col_value('targtend'));
      if v_boolean then
        return get_errorm_name('HR2025',global_v_lang)||' ('||arr_col_name('targtend')||')';
      else
        if to_date(arr_col_value('targtstr'),'dd/mm/yyyy') > to_date(arr_col_value('targtend'),'dd/mm/yyyy') then
          return get_errorm_name('HR2021',global_v_lang)||' ('||arr_col_name('targtend')||')';
        end if;
      end if;
    else
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('targtend')||')';
    end if;
    return '';
  end;
  --
  function import_tkpiemp(param_column  json_object_t,
                          param_data    json_object_t,
                          p_num_rec_pass out number,
                          p_num_rec_fail out number) return json_object_t is
    obj_result      json_object_t;
    obj_row         json_object_t;
--    obj_data_sheet  json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_error_msg     varchar2(4000);

    obj_tkpiemp_col         json_object_t;
    obj_tkpiemp_col_row     json_object_t;
    obj_tkpiemp             json_object_t;
    obj_tkpiemp_row         json_object_t;
    v_key                   varchar2(100);
    tkpiemp_complete        number := 0;
    tkpiemp_error           number := 0;
    v_rcnt                  number := 0;
  begin
    -- set column name --
--    obj_data_sheet    := hcm_util.get_json_t(param_data,'dataSheet');
    obj_tkpiemp       := hcm_util.get_json_t(param_data,'p_kpi_employee');
    obj_tkpiemp_col   := hcm_util.get_json_t(param_column,'p_kpi_employee');
    arr_col_name      := arr_col_empty;
    arr_col_value     := arr_col_empty;
    for i in 0..(obj_tkpiemp_col.get_size - 1) loop
      obj_tkpiemp_col_row := hcm_util.get_json_t(obj_tkpiemp_col,to_char(i));
      v_key               := hcm_util.get_string_t(obj_tkpiemp_col_row,'key');
      arr_col_name(v_key) := hcm_util.get_string_t(obj_tkpiemp_col_row,'name');
    end loop;

    obj_row         := json_object_t();
    for i in 0..(obj_tkpiemp.get_size - 1) loop
      obj_tkpiemp_row             := hcm_util.get_json_t(obj_tkpiemp,to_char(i));
      arr_col_value('codempid')   := hcm_util.get_string_t(obj_tkpiemp_row,'codempid');
      arr_col_value('codkpi')     := hcm_util.get_string_t(obj_tkpiemp_row,'codkpi');
      arr_col_value('typkpi')     := hcm_util.get_string_t(obj_tkpiemp_row,'typkpi');
      arr_col_value('kpides')     := hcm_util.get_string_t(obj_tkpiemp_row,'kpides');
      arr_col_value('target')     := hcm_util.get_string_t(obj_tkpiemp_row,'target');
      arr_col_value('mtrfinish')  := hcm_util.get_string_t(obj_tkpiemp_row,'mtrfinish');
      arr_col_value('pctwgt')     := hcm_util.get_string_t(obj_tkpiemp_row,'pctwgt');
      arr_col_value('targtstr')   := hcm_util.get_string_t(obj_tkpiemp_row,'targtstr');
      arr_col_value('targtend')   := hcm_util.get_string_t(obj_tkpiemp_row,'targtend');
      get_codcomp_codpos(arr_col_value('codempid'),v_codcomp,v_codpos);
      arr_col_value('codcomp')    := v_codcomp;
      arr_col_value('codpos')     := v_codpos;

      v_error_msg                 := validate_kpi_emp;

      if v_error_msg is null then
        begin
          insert into tkpiemp(dteyreap,numtime,codempid,codkpi,
                              typkpi,kpides,target,mtrfinish,
                              pctwgt,targtstr,targtend,
                              codcomp,codpos,codcreate,coduser)
          values (b_index_dteyreap,b_index_numtime,arr_col_value('codempid'),arr_col_value('codkpi'),
                  arr_col_value('typkpi'),arr_col_value('kpides'),arr_col_value('target'),arr_col_value('mtrfinish'),
                  arr_col_value('pctwgt'),to_date(arr_col_value('targtstr'),'dd/mm/yyyy'),to_date(arr_col_value('targtend'),'dd/mm/yyyy'),
                  'v_codcomp 4',v_codpos,'IMPORT','IMPORT');
        exception when dup_val_on_index then
          update tkpiemp
             set typkpi     = arr_col_value('typkpi'),
                 kpides     = arr_col_value('kpides'),
                 target     = arr_col_value('target'),
                 mtrfinish  = arr_col_value('mtrfinish'),
                 pctwgt     = arr_col_value('pctwgt'),
                 targtstr   = to_date(arr_col_value('targtstr'),'dd/mm/yyyy'),
                 targtend   = to_date(arr_col_value('targtend'),'dd/mm/yyyy'),
                 codcomp    = 'v_codcomp 4',
                 codpos     = v_codpos,
                 coduser    = 'IMPORT'
           where dteyreap   = b_index_dteyreap
             and numtime    = b_index_numtime
             and codempid   = arr_col_value('codempid')
             and codkpi     = arr_col_value('codkpi');
        end;
        tkpiemp_complete  := tkpiemp_complete + 1;
      else
        tkpiemp_error     := tkpiemp_error + 1;
        obj_result        := json_object_t();
        obj_result.put('line_error',to_char(i + 1));
        obj_result.put('desc_data',get_label_name('HRAP32EC3',global_v_lang,170));
        obj_result.put('err_detail',v_error_msg);
        obj_row.put(to_char(v_rcnt),obj_result);
        v_rcnt  := v_rcnt + 1;
      end if;
    end loop;
    p_num_rec_pass    := tkpiemp_complete;
    p_num_rec_fail    := tkpiemp_error;
    return obj_row;
  end;
  --
  function validate_kpi_grade return varchar2 is
    v_max       number;
    v_boolean   boolean;
    v_error     varchar2(4000);
    v_temp      varchar2(1000);
  begin
    v_error   := check_codempid(arr_col_value('codempid'));
    if v_error is not null then
      return v_error;
    end if;
    --
    begin
      select 'Y'
        into v_error
        from tobjemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = arr_col_value('codempid');
    exception when no_data_found then
      return get_terrorm_name('HR2010',global_v_lang)||' TOBJEMP';
    end;
    --
    begin
      select 'Y'
        into v_error
        from tkpiemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = arr_col_value('codempid')
         and codkpi     = arr_col_value('codkpi');
    exception when no_data_found then
      return get_terrorm_name('HR2010',global_v_lang)||' TKPIEMP';
    end;
    --
    if arr_col_value('grade') is null then
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('grade')||')';
    else
      begin
        select 'Y'
          into v_error
          from tgradekpi
         where codcompy   = hcm_util.get_codcomp_level(arr_col_value('codcomp'),1)
           and grade      = arr_col_value('grade')
           and dteyreap   = (select max(dteyreap)
                               from tgradekpi
                              where codcompy    = hcm_util.get_codcomp_level(arr_col_value('codcomp'),1)
                                and grade       = arr_col_value('grade')
                                and dteyreap    <= to_number(to_char(sysdate,'yyyy')));
      exception when no_data_found then
        return get_terrorm_name('HR2010',global_v_lang)||' TGRADEKPI';
      end;
    end if;

    if arr_col_value('kpides') is null then
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('kpides')||')';
    else
      v_boolean := hcm_validate.check_length(arr_col_value('kpides'),'TKPIEMPG','KPIDES',v_max);
      if v_boolean then
        return get_errorm_name('HR6591',global_v_lang)||' Max: '||v_max||' ('||arr_col_name('kpides')||')';
      end if;
    end if;
    if arr_col_value('stakpi') is null then
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('stakpi')||')';
    else
    v_temp := arr_col_value('stakpi');
      if v_temp not in ('Y','N') then
        return get_errorm_name('HR2057',global_v_lang)||' (''Y'',''N'')'||' ('||v_temp||')';
      end if;
    end if;
    return '';
  end;
  --
  function import_tkpiempg(param_column  json_object_t,
                           param_data    json_object_t,
                           p_num_rec_pass out number,
                           p_num_rec_fail out number) return json_object_t is
    obj_result      json_object_t;
    obj_row         json_object_t;
--    obj_data_sheet  json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_error_msg     varchar2(4000);

    obj_tkpiempg_col         json_object_t;
    obj_tkpiempg_col_row     json_object_t;
    obj_tkpiempg             json_object_t;
    obj_tkpiempg_row         json_object_t;
--    t_tkpiempg               tkpiempg%rowtype;
    v_key              varchar2(100);
    tkpiempg_complete  number := 0;
    tkpiempg_error     number := 0;
    v_rcnt             number := 0;
    v_color            tkpiempg.color%type;
    v_score            tkpiempg.score%type;
    v_desgrade         tkpiempg.desgrade%type;
  begin
    -- set column name --
--    obj_data_sheet    := hcm_util.get_json_t(param_data,'dataSheet');
    obj_tkpiempg      := hcm_util.get_json_t(param_data,'p_codition_employee');
    obj_tkpiempg_col  := hcm_util.get_json_t(param_column,'p_codition_employee');
    arr_col_name      := arr_col_empty;
    arr_col_value     := arr_col_empty;
    for i in 0..(obj_tkpiempg_col.get_size - 1) loop
      obj_tkpiempg_col_row := hcm_util.get_json_t(obj_tkpiempg_col,to_char(i));
      v_key := hcm_util.get_string_t(obj_tkpiempg_col_row,'key');
      arr_col_name(v_key) := hcm_util.get_string_t(obj_tkpiempg_col_row,'name');
    end loop;
    obj_row         := json_object_t();
    for i in 0..(obj_tkpiempg.get_size - 1) loop
      obj_tkpiempg_row            := hcm_util.get_json_t(obj_tkpiempg,to_char(i));
      arr_col_value('codempid')   := hcm_util.get_string_t(obj_tkpiempg_row,'codempid');
      arr_col_value('codkpi')     := hcm_util.get_string_t(obj_tkpiempg_row,'codkpi');
      arr_col_value('grade')      := hcm_util.get_string_t(obj_tkpiempg_row,'grade');
      arr_col_value('kpides')     := hcm_util.get_string_t(obj_tkpiempg_row,'kpides');
      arr_col_value('stakpi')     := hcm_util.get_string_t(obj_tkpiempg_row,'stakpi');
      get_codcomp_codpos(arr_col_value('codempid'),v_codcomp,v_codpos);
      arr_col_value('codcomp')    := v_codcomp;
      arr_col_value('codpos')     := v_codpos;
      v_error_msg                 := validate_kpi_grade;
      begin

        select color,score,desgrade into v_color, v_score, v_desgrade
          from tgradekpi
         where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
           and dteyreap = b_index_dteyreap
           and grade = arr_col_value('grade');
      exception when no_data_found then
        v_color := '';
      end;
      if v_error_msg is null then
        begin
          insert into tkpiempg(dteyreap,numtime,codempid,codkpi,
                               grade,color,kpides,stakpi,
                               score,desgrade,
                               codcreate,coduser)
          values (b_index_dteyreap,b_index_numtime,arr_col_value('codempid'),arr_col_value('codkpi'),
                  arr_col_value('grade'),v_color,arr_col_value('kpides'),arr_col_value('stakpi'),
                  v_score, v_desgrade,
                  'IMPORT','IMPORT');
        exception when dup_val_on_index then
          update tkpiempg
             set grade      = arr_col_value('grade'),
                 color      = v_color,
                 kpides     = arr_col_value('kpides'),
                 stakpi     = arr_col_value('stakpi'),
                 score      = v_score,
                 desgrade   = v_desgrade,
                 coduser    = 'IMPORT'
           where dteyreap   = b_index_dteyreap
             and numtime    = b_index_numtime
             and codempid   = arr_col_value('codempid')
             and codkpi     = arr_col_value('codkpi')
             and grade      = arr_col_value('grade');
        end;
        tkpiempg_complete   := tkpiempg_complete + 1;
      else
        tkpiempg_error      := tkpiempg_error + 1;
        obj_result          := json_object_t();
        obj_result.put('line_error',to_char(i + 1));
        obj_result.put('desc_data',get_label_name('HRAP32EC3',global_v_lang,170));
        obj_result.put('err_detail',v_error_msg);
        obj_row.put(to_char(v_rcnt),obj_result);
        v_rcnt  := v_rcnt + 1;
      end if;
    end loop;
    p_num_rec_pass    := tkpiempg_complete;
    p_num_rec_fail    := tkpiempg_error;
    return obj_row;
  end;
  --
  function validate_kpi_plan return varchar2 is
    v_max       number;
    v_boolean   boolean;
    v_error     varchar2(4000);
  begin
    v_error   := check_codempid(arr_col_value('codempid'));
    if v_error is not null then
      return v_error;
    end if;
    --
    begin
      select 'Y'
        into v_error
        from tobjemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = arr_col_value('codempid');
    exception when no_data_found then
      return get_terrorm_name('HR2010',global_v_lang)||' TOBJEMP';
    end;
    --
    begin
      select 'Y'
        into v_error
        from tkpiemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = arr_col_value('codempid')
         and codkpi     = arr_col_value('codkpi');
    exception when no_data_found then
      return get_terrorm_name('HR2010',global_v_lang)||' TKPIEMP';
    end;
    --
    if arr_col_value('planno') is null then
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('planno')||')';
    else
      v_boolean := hcm_validate.check_length(arr_col_value('planno'),'TKPIEMPPL','PLANNO',v_max);
      if v_boolean then
        return get_errorm_name('HR6591',global_v_lang)||' Max: '||v_max||' ('||arr_col_name('planno')||')';
      end if;
    end if;
    --
    if arr_col_value('plandes') is null then
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('plandes')||')';
    else
      v_boolean := hcm_validate.check_length(arr_col_value('plandes'),'TKPIEMPPL','PLANDES',v_max);
      if v_boolean then
        return get_errorm_name('HR6591',global_v_lang)||' Max: '||v_max||' ('||arr_col_name('plandes')||')';
      end if;
    end if;
    --
    if arr_col_value('targtstr') is not null then
      v_boolean   := hcm_validate.check_date(arr_col_value('targtstr'));
      if v_boolean then
        return get_errorm_name('HR2025',global_v_lang)||' ('||arr_col_name('targtstr')||')';
      end if;
    else
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('targtstr')||')';
    end if;
    --
    if arr_col_value('targtend') is not null then
      v_boolean   := hcm_validate.check_date(arr_col_value('targtend'));
      if v_boolean then
        return get_errorm_name('HR2025',global_v_lang)||' ('||arr_col_name('targtend')||')';
      else
        if to_date(arr_col_value('targtstr'),'dd/mm/yyyy') > to_date(arr_col_value('targtend'),'dd/mm/yyyy') then
          return get_errorm_name('HR2021',global_v_lang)||' ('||arr_col_name('targtend')||')';
        end if;
      end if;
    else
      return get_errorm_name('HR2045',global_v_lang)||' ('||arr_col_name('targtend')||')';
    end if;
    return '';
  end;
  --
  function import_tkpiemppl(param_column  json_object_t,
                            param_data    json_object_t,
                            p_num_rec_pass out number,
                            p_num_rec_fail out number) return json_object_t is
    obj_result      json_object_t;
    obj_row         json_object_t;
--    obj_data_sheet  json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_error_msg     varchar2(4000);

    obj_tkpiemppl_col       json_object_t;
    obj_tkpiemppl_col_row   json_object_t;
    obj_tkpiemppl           json_object_t;
    obj_tkpiemppl_row       json_object_t;
--    t_tkpiemppl               tkpiemppl%rowtype;
    v_key                   varchar2(100);
    tkpiemppl_complete      number := 0;
    tkpiemppl_error         number := 0;
    v_rcnt                  number := 0;
  begin
    -- set column name --
--    obj_data_sheet    := hcm_util.get_json_t(param_data,'dataSheet');
    obj_tkpiemppl     := hcm_util.get_json_t(param_data,'p_action_plan');
    obj_tkpiemppl_col := hcm_util.get_json_t(param_column,'p_action_plan');
    arr_col_name      := arr_col_empty;
    arr_col_value     := arr_col_empty;
    for i in 0..(obj_tkpiemppl_col.get_size - 1) loop
      obj_tkpiemppl_col_row := hcm_util.get_json_t(obj_tkpiemppl_col,to_char(i));
      v_key                 := hcm_util.get_string_t(obj_tkpiemppl_col_row,'key');
      arr_col_name(v_key)   := hcm_util.get_string_t(obj_tkpiemppl_col_row,'name');
    end loop;

    obj_row   := json_object_t();
    for i in 0..(obj_tkpiemppl.get_size - 1) loop
      obj_tkpiemppl_row           := hcm_util.get_json_t(obj_tkpiemppl,to_char(i));
      arr_col_value('codempid')   := hcm_util.get_string_t(obj_tkpiemppl_row,'codempid');
      arr_col_value('codkpi')     := hcm_util.get_string_t(obj_tkpiemppl_row,'codkpi');
      arr_col_value('planno')     := hcm_util.get_string_t(obj_tkpiemppl_row,'planno');
      arr_col_value('plandes')    := hcm_util.get_string_t(obj_tkpiemppl_row,'plandes');
      arr_col_value('targtstr')   := hcm_util.get_string_t(obj_tkpiemppl_row,'targtstr');
      arr_col_value('targtend')   := hcm_util.get_string_t(obj_tkpiemppl_row,'targtend');
      v_error_msg                 := validate_kpi_plan;
      get_codcomp_codpos(arr_col_value('codempid'),v_codcomp,v_codpos);

      if v_error_msg is null then
        begin
          insert into tkpiemppl(dteyreap,numtime,codempid,codkpi,
                                planno,plandes,targtstr,targtend,
                                codcreate,coduser)
          values (b_index_dteyreap,b_index_numtime,arr_col_value('codempid'),arr_col_value('codkpi'),
                  arr_col_value('planno'),arr_col_value('plandes'),
                  to_date(arr_col_value('targtstr'),'dd/mm/yyyy'),to_date(arr_col_value('targtend'),'dd/mm/yyyy'),
                  'IMPORT','IMPORT');
        exception when dup_val_on_index then
          update tkpiemppl
             set plandes    = arr_col_value('plandes'),
                 targtstr   = to_date(arr_col_value('targtstr'),'dd/mm/yyyy'),
                 targtend   = to_date(arr_col_value('targtend'),'dd/mm/yyyy'),
                 coduser    = 'IMPORT'
           where dteyreap   = b_index_dteyreap
             and numtime    = b_index_numtime
             and codempid   = arr_col_value('codempid')
             and codkpi     = arr_col_value('codkpi')
             and planno     = arr_col_value('planno');
        end;
        tkpiemppl_complete  := tkpiemppl_complete + 1;
      else
        tkpiemppl_error     := tkpiemppl_error + 1;
        obj_result          := json_object_t();
        obj_result.put('line_error',to_char(i + 1));
        obj_result.put('desc_data',get_label_name('HRAP32EC3',global_v_lang,170));
        obj_result.put('err_detail',v_error_msg);
        obj_row.put(to_char(v_rcnt),obj_result);
        v_rcnt  := v_rcnt + 1;
      end if;
    end loop;
    p_num_rec_pass    := tkpiemppl_complete;
    p_num_rec_fail    := tkpiemppl_error;
    return obj_row;
  end;
  --
  procedure import_data(json_str_input in clob,json_str_output out clob) is
    json_input        json_object_t;
    param_json        json_object_t;
    param_column      json_object_t;
    param_data        json_object_t;
    obj_data          json_object_t;
    json_str_result   json_object_t;
    v_num_rec_pass    number;
    v_num_rec_fail    number;
  begin
    initial_value(json_str_input);
    json_input        := json_object_t(json_str_input);
    param_json        := hcm_util.get_json_t(hcm_util.get_json_t(json_input,'param_json'),'data_import');
    param_column      := hcm_util.get_json_t(param_json,'columns');
    param_data        := hcm_util.get_json_t(param_json,'dataSheet');
    obj_data   := json_object_t();
    obj_data.put('coderror','200');

    json_str_result   := import_tobjemp(param_column,param_data,v_num_rec_pass,v_num_rec_fail);
    obj_data.put('rec_objective_tran',nvl(v_num_rec_pass,0));
    obj_data.put('rec_objective_err',nvl(v_num_rec_fail,0));
    obj_data.put('detail_objective_err',json_str_result);

    json_str_result   := import_tkpiemp(param_column,param_data,v_num_rec_pass,v_num_rec_fail);
    obj_data.put('rec_kpiemp_tran',nvl(v_num_rec_pass,0));
    obj_data.put('rec_kpiemp_err',nvl(v_num_rec_fail,0));
    obj_data.put('detail_kpiemp_err',json_str_result);
--
    json_str_result   := import_tkpiempg(param_column,param_data,v_num_rec_pass,v_num_rec_fail);
    obj_data.put('rec_grade_tran',nvl(v_num_rec_pass,0));
    obj_data.put('rec_grade_err',nvl(v_num_rec_fail,0));
    obj_data.put('detail_grade_err',json_str_result);
--
    json_str_result   := import_tkpiemppl(param_column,param_data,v_num_rec_pass,v_num_rec_fail);
    obj_data.put('rec_plan_tran',nvl(v_num_rec_pass,0));
    obj_data.put('rec_plan_err',nvl(v_num_rec_fail,0));
    obj_data.put('detail_plan_err',json_str_result);
    obj_data.put('response','HR2715'||get_terrorm_name('HR2715',global_v_lang));

    json_str_output   := obj_data.to_clob;

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_copy_kpi(json_str_input in clob, json_str_output out clob) is
    json_str        json_object_t;
    obj_data        json_object_t;
    obj_data_kpi    json_object_t;
    obj_row_kpi     json_object_t;
    v_rcnt          number := 0;
    v_objective     tobjemp.objective%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_flg_found     varchar2(1) := 'N';
    v_dteyreap_copy number;
    v_numtime_copy  number;
    v_codempid_copy temploy1.codempid%type;
    cursor c_kpi is
      select typkpi,codkpi,kpides,target,
             mtrfinish,pctwgt,targtstr,targtend,
             'N' as flgdefault
        from tkpiemp
       where dteyreap   = v_dteyreap_copy
         and numtime    = v_numtime_copy
         and codempid   = v_codempid_copy
      order by typkpi, codkpi;
  begin
    initial_value(json_str_input);
    json_str          := json_object_t(json_str_input);
    v_dteyreap_copy   := hcm_util.get_string_t(json_str,'p_dteyreap_copy');
    v_numtime_copy    := hcm_util.get_string_t(json_str,'p_numtime_copy');
    v_codempid_copy   := hcm_util.get_string_t(json_str,'p_codempid_copy');
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      null;
    end;
    begin
      select objective into v_objective
        from tobjemp
       where dteyreap   = v_dteyreap_copy
         and numtime    = v_numtime_copy
         and codempid   = v_codempid_copy;
    exception when no_data_found then
      v_objective   := null;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('objective',v_objective);
    obj_data.put('codcomp',v_codcomp);
    obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
    obj_data.put('codpos',v_codpos);
    obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
    obj_row_kpi := json_object_t();
    for i in c_kpi loop
      v_flg_found := 'Y';
      obj_data_kpi      := json_object_t();
      obj_data_kpi.put('coderror','200');
      obj_data_kpi.put('typkpi',i.typkpi);
      obj_data_kpi.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
      obj_data_kpi.put('codkpi',i.codkpi);
      obj_data_kpi.put('kpides',i.kpides);
      obj_data_kpi.put('target',i.target);
      obj_data_kpi.put('mtrfinish',to_char(i.mtrfinish,'fm999,999,990.00'));
      obj_data_kpi.put('pctwgt',to_char(i.pctwgt,'fm990.00'));
      obj_data_kpi.put('targtstr',to_char(i.targtstr,'dd/mm/yyyy'));
      obj_data_kpi.put('targtend',to_char(i.targtend,'dd/mm/yyyy'));
      obj_data_kpi.put('flgdefault',i.flgdefault);
      obj_row_kpi.put(to_char(v_rcnt),obj_data_kpi);
      v_rcnt  := v_rcnt + 1;
    end loop;
    obj_data.put('kpi_index',obj_row_kpi);
    if v_flg_found = 'N' then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'TKPIEMP');
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output   := obj_data.to_clob;
    end if;
  end;
  --
  procedure delete_index(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_dteyreap      tobjemp.dteyreap%type;
    v_numtime       tobjemp.numtime%type;
    v_codempid      tobjemp.codempid%type;
    v_check         varchar2(1);
  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);
    param_json            := hcm_util.get_json_t(json_input,'param_json');
    for i in 0..(param_json.get_size - 1) loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_dteyreap          := hcm_util.get_string_t(param_json_row,'dteyreap');
      v_numtime           := hcm_util.get_string_t(param_json_row,'numtime');
      v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
      begin
        select 'Y'
          into v_check
          from tkpiemp
         where codempid   = v_codempid
           and numtime    = v_numtime
           and dteyreap   = v_dteyreap
           and grade is not null
           and rownum = 1;
        param_msg_error := get_error_msg_php('HR1450',global_v_lang);
        exit;
      exception when no_data_found then null;
      end;
      delete tobjemp
       where dteyreap    = v_dteyreap
         and numtime     = v_numtime
         and codempid    = v_codempid;

      delete tkpiemp
       where dteyreap    = v_dteyreap
         and numtime     = v_numtime
         and codempid    = v_codempid;
    end loop;

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
