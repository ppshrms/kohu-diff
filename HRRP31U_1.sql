--------------------------------------------------------
--  DDL for Package Body HRRP31U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP31U" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codselect');
    b_index_dteselect   := to_date(hcm_util.get_string_t(json_obj,'p_dteselect'),'dd/mm/yyyy');
    b_index_codselect   := hcm_util.get_string_t(json_obj,'p_codselect');
    b_index_apprno      := hcm_util.get_string_t(json_obj,'p_approvno');
    p_code              := hcm_util.get_string_t(json_obj,'p_code');
    params_syncond      := hcm_util.get_json_t(json_obj,'p_syncond');
    params_json         := hcm_util.get_json_t(json_obj,'json_input_str');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if b_index_codcomp is not null then
      begin
        select codcomp into v_codcomp
        from tcenter
        where codcomp = get_compful(b_index_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(b_index_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data_detail json_object_t;
    obj_row_output  json_object_t;
    v_rcnt          number := 0;
    v_flgAppr       boolean;
    v_flgData       boolean := false;

    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_year          number;
    v_month         number;
    v_day           number;
    v_approvno      number := 0;
    p_check         varchar2(10 char);
    cursor c1 is
      select ageemp,agework,codcompe,codempid,codpose,jobgrade, nvl(approvno,0) + 1 as approvno,codcomp
        from ttalente
       where codcomp = nvl(b_index_codcomp, codcomp)
         and dteeffec = nvl(b_index_dteselect, dteeffec)
         and staappr in ('P','A')
       order by codempid;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_flgData   := true;
      v_approvno  := r1.approvno;
      v_flgAppr   := chk_flowmail.check_approve('HRRP68E',r1.codempid,v_approvno,global_v_codempid,'','',p_check);
      if v_flgAppr then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('empid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('codcompe', r1.codcompe);
        obj_data.put('desc_codcompe', get_tcenter_name(r1.codcompe, global_v_lang));
        obj_data.put('codpos', r1.codpose);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpose, global_v_lang));
        obj_data.put('jobgrade', r1.jobgrade);
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG', r1.jobgrade, global_v_lang));
        obj_data.put('codappr', global_v_codempid);
        obj_data.put('approvno', v_approvno);
        begin
          select dteempmt,dteempdb into v_dteempmt,v_dteempdb
          from temploy1
          where codempid = r1.codempid;
        end;
        get_service_year(v_dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
        obj_data.put('workage', v_year||'('|| v_month ||')');

        get_service_year(v_dteempdb,trunc(sysdate),'Y',v_year,v_month,v_day);
        obj_data.put('age',v_year||'('|| v_month ||')');

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgData then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3008',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTALENTE');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_data(json_str_output out clob)as
    obj_data        json_object_t;
    v_dteyreap      number;

  begin
    begin
        select max(dteyreap) into v_dteyreap
        from tappcmpf
        where codempid = b_index_codempid;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dteyreap', v_dteyreap);


    obj_data.put('codcomp', 'r1.codcomp');



    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_data(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_competency(json_str_output out clob)as
  obj_data        json_object_t;
  obj_row         json_object_t;

  v_rcnt          number := 0;
  v_dteyreap      number;
  v_sum_qtyscor   number := 0;
  v_avg_qtyscor   number(5,2) := 0.0;
  v_groupno		    number := 0;
  v_idx		        number := 0;
  cursor c1 is
      select dteyreap||lpad(numtime,2,'0') as dteyreap,codtency, codskill, gradexpct, grade, qtyscor
        from tappcmpf a
       where codempid = b_index_codempid
         and dteyreap  = (select max(dteyreap)
                            from tappcmpf
                           where codempid = a.codempid)
       order by codtency, codskill;

  --           and dteyreap||lpad(numtime,2,'0')  = (select max(dteyreap||lpad(numtime,2,'0'))
  --                                                   from tappcmpf
  --                                                  where codempid = a.codempid)
  begin
  obj_row := json_object_t();
  obj_data := json_object_t();
  -- clear ttemprpt
  begin
    delete
      from ttemprpt
     where codapp = 'HRRP31U'
       and codempid = global_v_codempid;
  end;
  for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('dteyreap', r1.dteyreap);
      obj_data.put('codtency', r1.codtency);
      obj_data.put('desc_codtency', get_tcomptnc_name(r1.codtency, global_v_lang));
      obj_data.put('codskill', r1.codskill);
      obj_data.put('desc_codskill', get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang));
      obj_data.put('gradexpct', r1.gradexpct);
      obj_data.put('grade', r1.grade);
      obj_data.put('qtyscor', to_char(r1.qtyscor,'fm990.00'));
      v_sum_qtyscor := v_sum_qtyscor + r1.qtyscor;
      obj_row.put(to_char(v_rcnt-1),obj_data);

      v_groupno := v_groupno + 1;
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,
                              item4,item5,
                              item8,item9,
                              item10,item31)
             values (global_v_codempid, 'HRRP31U',v_idx,
                      r1.codskill, r1.codskill || ' - ' || get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang),
                      get_label_name('HRRP31U2',global_v_lang,50),get_label_name('HRRP31U2',global_v_lang,90),
                      r1.gradexpct,get_label_name('HRRP31U2',global_v_lang,5));
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,
                              item4,item5,
                              item8,item9,
                              item10,item31)
             values (global_v_codempid, 'HRRP31U',v_idx,
                      r1.codskill, r1.codskill || ' - ' || get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang),
                      get_label_name('HRRP31U2',global_v_lang,60),get_label_name('HRRP31U2',global_v_lang,90),
                      r1.grade,get_label_name('HRRP31U2',global_v_lang,5));
  end loop;
  --find average score
  if v_rcnt > 0 then
      v_avg_qtyscor := v_sum_qtyscor / v_rcnt;
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('dteyreap', '');
      obj_data.put('codtency', '');
      obj_data.put('desc_codtency', '');
      obj_data.put('codskill', '');
      obj_data.put('desc_codskill', '');
      obj_data.put('gradexpct', '');
      obj_data.put('grade', get_label_name('HRRP31U2',global_v_lang,80));
      obj_data.put('qtyscor', to_char(v_avg_qtyscor,'fm990.00'));
      obj_row.put(to_char(v_rcnt),obj_data);
  end if;
  if param_msg_error is null then
    json_str_output := obj_row.to_clob;
  else
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end if;
  exception when others then
  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_competency(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_competency(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_performance_history(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_kpi           number;
    v_behavior      number;
    v_comptncy      number;
    v_total         number;
		v_groupno		    number := 0;
		v_idx		        number := 0;
    v_codep         number := 0;
    v_qtypunsta     number;--User37 #7475 1. RP Module 18/01/2022 
    cursor c1 is
        select codcomp,codpos,dteyreap,qtyscore, grade,qtypuns + qtyta as qtypunsta
          from tapprais
         where codempid = b_index_codempid
           and dteyreap < to_char(sysdate,'yyyy')
      order by dteyreap desc;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    -- clear ttemprpt
    begin
      delete
        from ttemprpt
       where codapp = 'HRRP31U2'
         and codempid = global_v_codempid;
    end;
    for r1 in c1 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('dteyreap', r1.dteyreap);
        obj_data.put('qtyscore', to_char(nvl(r1.qtyscore,0),'fm990.00'));
        obj_data.put('grade', r1.grade);

        begin
          select nvl(qtykpie3,0), nvl(qtybeh3,0), nvl(qtycmp3,0), nvl(qtytot3,0) 
                 ,nvl(qtyta,0)+nvl(qtypuns,0)--User37 #7475 1. RP Module 18/01/2022 
            into v_kpi,v_behavior,v_comptncy,v_total
                 ,v_qtypunsta--User37 #7475 1. RP Module 18/01/2022 
            from tappemp
           where codempid = b_index_codempid
             and dteyreap = r1.dteyreap
             and numtime  = (select max(numtime)
                                  from tappemp
                                 where codempid = b_index_codempid
                                   and dteyreap = r1.dteyreap);
        exception when no_data_found then
            v_kpi := 0;
            v_behavior := 0;
            v_comptncy := 0;
            v_total := 0;
            v_qtypunsta := 0;--User37 #7475 1. RP Module 18/01/2022 
        end;
        obj_data.put('qtypunsta', to_char(nvl(v_qtypunsta,0),'fm990.00'));--User37 #7475 1. RP Module 18/01/2022 obj_data.put('qtypunsta', to_char(nvl(r1.qtypunsta,0),'fm990.00'));
        obj_data.put('kpi', to_char(v_kpi,'fm990.00'));
        obj_data.put('behavior', to_char(v_behavior,'fm990.00'));
        obj_data.put('comptncy', to_char(v_comptncy,'fm990.00'));
        obj_data.put('total', to_char(nvl(r1.qtypunsta,0) + v_total,'fm990.00'));
        obj_row.put(to_char(v_rcnt-1),obj_data);
        v_codep := 0;
        v_groupno := v_groupno + 1;
        v_idx := v_idx + 1;
        v_codep := v_codep + 1;
        insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRRP31U2',v_idx,
                        r1.dteyreap, r1.dteyreap + 543,
                        v_codep, get_label_name('HRRP31U3',global_v_lang,90),get_label_name('HRRP31U3',101,20),
                        r1.qtypunsta,get_label_name('HRRP31U3',global_v_lang,5));

        v_idx := v_idx + 1;
        v_codep := v_codep + 1;
        insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRRP31U2',v_idx,
                        r1.dteyreap, r1.dteyreap + 543,
                        v_codep, get_label_name('HRRP31U3',global_v_lang,60),get_label_name('HRRP31U3',101,20),
                        v_behavior,get_label_name('HRRP31U3',global_v_lang,5));

        v_idx := v_idx + 1;
        v_codep := v_codep + 1;
        insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRRP31U2',v_idx,
                        r1.dteyreap, r1.dteyreap + 543,
                        v_codep, get_label_name('HRRP31U3',global_v_lang,70),get_label_name('HRRP31U3',101,20),
                        v_comptncy,get_label_name('HRRP31U3',global_v_lang,5));

        v_idx := v_idx + 1;
        v_codep := v_codep + 1;
        insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRRP31U2',v_idx,
                        r1.dteyreap, r1.dteyreap + 543,
                        v_codep, get_label_name('HRRP31U3',global_v_lang,50),get_label_name('HRRP31U3',101,20),
                        v_kpi,get_label_name('HRRP31U3',global_v_lang,5));
        if v_rcnt = 3 then
            exit;
        end if;
    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_performance_history(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_performance_history(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_approve_data(json_str_output out clob)as
    obj_data        json_object_t;
    v_dteyreap      number;
    v_approvno      taptalent.approvno%type;
    v_codappr       taptalent.codappr%type;
    v_remarkap      taptalent.remarkap%type;
    v_staappr       taptalent.staappr%type;

  begin
    begin
      select approvno, codappr, remarkap, staappr into v_approvno,v_codappr,v_remarkap,v_staappr
        from taptalent
       where codcomp = b_index_codcomp
         and dteeffec = b_index_dteselect
         and codempid = b_index_codempid
         and approvno = b_index_apprno;
    exception when no_data_found then
      v_approvno  := b_index_apprno;
      v_codappr   := '';
      v_remarkap  := '';
      v_staappr   := '';
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcomp', b_index_codcomp);
    obj_data.put('codempid', b_index_codempid);
    obj_data.put('approvno', v_approvno);
    obj_data.put('codappr', v_codappr);
    obj_data.put('flgStaappr', v_staappr);
    obj_data.put('remarkap', v_remarkap);
    if v_staappr = 'N' then
      obj_data.put('notapprove', v_remarkap);
      obj_data.put('approve', '');
    else
      obj_data.put('notapprove', '');
      obj_data.put('approve', v_remarkap);
    end if;
    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_approve_data(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_approve_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_approve is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    null;
--    if b_index_codselect is not null then
--      begin
--        select staemp,codcomp into v_staemp,v_codcomp
--        from temploy1
--        where codempid = b_index_codselect;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
--        return;
--      end;
--      if get_compful(b_index_codcomp) <> v_codcomp then
--        param_msg_error := get_error_msg_php('HR2104',global_v_lang);
--        return;
--      end if;
--      v_flgSecur := secur_main.secur2(b_index_codselect, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
--      if not v_flgSecur then
--        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--        return;
--      end if;
--      if v_staemp = '9' then
--        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
--        return;
--      end if;
--      if v_staemp = '0' then
--        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
--        return;
--      end if;
--    end if;
  end;
  --
  procedure send_mail (v_codempid in varchar2, v_error_sendmail out varchar2, v_codcomp in varchar2, v_dteselect in varchar2,p_check in varchar2) is
		v_number_mail		  number := 0;
		json_obj		      json_object_t;
		param_object		  json_object_t;
		param_json_row		json_object_t;
		p_typemail		    varchar2(500);
    p_codapp          varchar2(500 char);
    p_lang            varchar2(500 char);
    o_msg_to          clob;
    p_template_to     clob;
    p_func_appr       varchar2(500 char);
		v_rowid           ROWID;
    v_codform         tfwmailh.codform%type;
		v_error			      terrorm.errorno%TYPE;
		obj_respone		    json_object_t;
		obj_respone_data  VARCHAR(500 char);
		obj_sum			      json_object_t;
    v_approvno        ttmovemt.approvno%type;
	begin
      p_codapp := 'HRRP68E';
      begin
        select codform
          into v_codform
          from tfwmailh
         where codapp = 'HRRP68E';
      exception
      when no_data_found then
        null;
      end;
      begin
        select rowid, nvl(approvno,0) + 1 as approvno
          into v_rowid,v_approvno
          from ttalente
         where codcomp = v_codcomp
           and dteeffec = v_dteselect
           and codempid = v_codempid;
      exception when no_data_found then
          v_approvno := 1;
      end;

      chk_flowmail.get_message(p_codapp,global_v_lang,o_msg_to,p_template_to,p_func_appr);

      chk_flowmail.replace_text_frmmail(p_template_to, 'ttalente', v_rowid,
                                        get_label_name('HRRP68E1', global_v_lang, 130),
                                        v_codform, '1', p_func_appr, global_v_coduser, global_v_lang, o_msg_to);

			v_error := chk_flowmail.send_mail_to_approve('HRRP68E', v_codempid, global_v_codempid, o_msg_to, null,
                                                    get_label_name('HRRP68E1', global_v_lang, 130),
                                                    'E', 'P', global_v_lang, v_approvno, null, null);
      v_error_sendmail     := get_error_msg_php('HR' || v_error, global_v_lang);
  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
	end send_mail;

  procedure process_approve(json_str_input in clob, json_str_output out clob) as
    json_obj      json_object_t;
    obj_data      json_object_t;

    v_dteappr     date;
    v_approvno    number;
    v_codempid    temploy1.codempid%type;
    v_codcomp     ttalente.codcomp%type;
    v_codcompe    ttalente.codcomp%type;
    v_codappr     ttalente.codempid%type;
    v_approve     ttalente.remarkap%type;
    v_notapprove  ttalente.remarkap%type;
    v_remark      ttalente.remarkap%type;
    v_dteselect   date;
		v_rowid       ROWID;

    v_staappr     ttalente.staappr%type;
    v_flgAppr     boolean;
    p_check       varchar2(10 char);
    v_error_sendmail    varchar2(4000 char);
    v_error_cc          varchar2(4000 char);
    v_error			  terrorm.errorno%type;
  begin
    initial_value(json_str_input);
    check_approve;

    json_obj := json_object_t(json_str_input);
    obj_data := hcm_util.get_json_t(json_obj,'params');

    v_codcomp     := hcm_util.get_string_t(json_obj,'codcomp');
    v_dteselect   := to_date(hcm_util.get_string_t(json_obj,'dteselect'),'dd/mm/yyyy');

    v_dteappr     := to_date(hcm_util.get_string_t(json_obj,'dteappr'),'dd/mm/yyyy');
    v_approvno    := to_number(hcm_util.get_string_t(json_obj,'approvno'));
    v_codappr     := hcm_util.get_string_t(json_obj,'codappr');
    v_approve     := hcm_util.get_string_t(json_obj,'approve');
    v_notapprove  := hcm_util.get_string_t(json_obj,'notapprove');

    v_staappr     := hcm_util.get_string_t(obj_data,'flgStaappr');
    v_codcomp     := hcm_util.get_string_t(obj_data,'codcomp');
    v_codempid    := hcm_util.get_string_t(obj_data,'codempid');

    if v_staappr = 'A' then
      v_remark := v_approve;
    elsif v_staappr = 'N' then
      v_remark := v_notapprove;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');

    v_flgAppr   := chk_flowmail.check_approve('HRRP68E',v_codempid,v_approvno,v_codappr,'','',p_check);
    if v_staappr = 'N' then
      begin
        insert into taptalent (codcomp, dteeffec, codempid, approvno, dteappr, codappr, staappr, remarkap,codcreate, coduser)
             values (v_codcomp, v_dteselect, v_codempid, v_approvno, v_dteappr, v_codappr, 'N',v_remark,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        null;
      end;
      begin
        update ttalent
           set staappr = 'C',
               codappr = v_codappr,
               dteappr = v_dteappr
         where codcomp = v_codcomp
           and dteeffec = v_dteselect;
      exception when others then
        null;
      end;
      begin
        update ttalente
           set staappr = 'N',
               codappr = v_codappr,
               dteappr = v_dteappr,
               remarkap = v_remark
         where codcomp = v_codcomp
           and dteeffec = v_dteselect
           and codempid = v_codempid;
      exception when others then
        null;
      end;
      v_error := '2402';
    elsif v_staappr = 'A' then
        if p_check = 'N' then
            begin
                insert into taptalent (codcomp, dteeffec, codempid, approvno, dteappr, codappr, staappr, remarkap,codcreate, coduser)
                     values (v_codcomp, v_dteselect, v_codempid, v_approvno, v_dteappr, v_codappr, 'Y',v_remark,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
                null;
            end;
            begin
                update ttalente
                   set staappr = 'A',
                       approvno = v_approvno,
                       codappr = v_codappr,
                       dteappr = v_dteappr,
                       remarkap = v_remark
                 where codcomp = v_codcomp
                   and dteeffec = v_dteselect
                   and codempid = v_codempid;
            exception when others then
                null;
            end;
            begin
                select rowid
                  into v_rowid
                  from ttalente
                 where codcomp = v_codcomp
                   and dteeffec = v_dteselect
                   and codempid = v_codempid;
            exception when no_data_found then
                v_rowid := null;
            end;
            begin
                v_error := chk_flowmail.send_mail_for_approve('HRRP68E', v_codempid, global_v_codempid, global_v_coduser, null, 'HRRP68E1', 130, 'U', v_staappr, v_approvno + 1, null, null,'TTALENTE',v_rowid, '1', null);
            EXCEPTION WHEN OTHERS THEN
                v_error := '2403';
            END;
        elsif p_check = 'Y' then
            begin
                insert into taptalent (codcomp, dteeffec, codempid, approvno, dteappr, codappr, staappr, remarkap,codcreate, coduser)
                     values (v_codcomp, v_dteselect, v_codempid, v_approvno, v_dteappr, v_codappr, 'Y',v_remark,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
                null;
            end;
            begin
                update ttalent
                   set staappr = 'C',
                       codappr = v_codappr,
                       dteappr = v_dteappr
                 where codcomp = v_codcomp
                   and dteeffec = v_dteselect;
            exception when others then
                null;
            end;
            begin
                update ttalente
                   set staappr = 'Y',
                       approvno = v_approvno,
                       codappr = v_codappr,
                       dteappr = v_dteappr,
                       remarkap = v_remark
                 where codcomp = v_codcomp
                   and dteeffec = v_dteselect
                   and codempid = v_codempid;
            exception when others then
                null;
            end;
            v_error := '2402';
        end if;
    end if;

    begin
      select rowid
        into v_rowid
        from ttalente
       where codcomp = v_codcomp
         and dteeffec = v_dteselect
         and codempid = v_codempid;
    exception when no_data_found then
      v_rowid := null;
    end;

    begin
        v_error_cc := chk_flowmail.send_mail_reply('HRRP31U', v_codempid, null , global_v_codempid, global_v_coduser, null, 'HRRP31U3', 100, 'U', v_staappr, v_approvno, null, null, 'TTALENTE', v_rowid, '1', null);
    EXCEPTION WHEN OTHERS THEN
      v_error_cc := '2403';
    END;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
      return;
    elsIF v_error in ('2046','2402') THEN
      param_msg_error_mail := get_error_msg_php('HR2402', global_v_lang);
      json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      commit;
      return;
    ELSE
      param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
      json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      rollback;
      return;
    END IF;

--    if param_msg_error_mail is not null then
--      json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
--    else
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrrp31u;

/
