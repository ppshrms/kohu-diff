--------------------------------------------------------
--  DDL for Package Body HRES11X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES11X" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    p_zyear             := HCM_APPSETTINGS.get_additional_year;

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_codkpi            := hcm_util.get_string_t(json_obj,'p_codkpi');
    p_codtency          := hcm_util.get_string_t(json_obj,'p_codtency');
    p_codskill          := hcm_util.get_string_t(json_obj,'p_codskill');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;

    v_row               number := 0;
    v_count             number := 0;

    cursor c1 is
      select codcomp, codpos, codjob
        from tjobpos
       where codcomp like nvl(p_codcomp||'%', codcomp) 
         and codpos = nvl(p_codpos, codpos)
       order by codcomp asc, codpos asc;

  begin
    obj_row := json_object_t();
    v_count := 0;

--    if p_codcomp is null and p_codpos is null then
--        select codcomp, codpos
--          into p_codcomp, p_codpos
--          from temploy1 
--         where codempid = global_v_codempid;
--    end if;

    for r1 in c1 loop
      obj_data   := json_object_t();
      v_count    := v_count + 1;
      obj_data.put('coderror', '200');  
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('codpos', r1.codpos);
      obj_data.put('codjob', r1.codjob);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
      obj_data.put('desc_codjob', get_tjobcode_name(r1.codjob, global_v_lang));

      obj_row.put(to_char(v_count-1),obj_data);
    end loop;
    if v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TJOBPOS');
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else 
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
  --  
  procedure check_index is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
  begin

    if p_codcomp is not  null then
    begin
      select count(*) into v_count_comp
        from tcenter
       where codcomp like p_codcomp || '%' ;
    exception when others then null;
    end;
    if v_count_comp < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
      return;
    end if;
    v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
    if not v_secur then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
    end if ;
    --
    if p_codpos is not null then
      begin
        select count(*) into v_chkExist
          from tpostn
         where codpos = p_codpos;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
        return;
      end if;
    end if;
    --
  end;
  --
  procedure get_index (json_str_input in clob,json_str_output out clob) is
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
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_codpos(json_str_output out clob) is
    obj_data            json_object_t;
    v_tjobpos           tjobpos%rowtype;
  begin
    begin
      select * into v_tjobpos
        from tjobpos
       where codcomp = p_codcomp 
         and codpos = p_codpos;
    exception when no_data_found then
      v_tjobpos := null;
    end;
    obj_data   := json_object_t();
    obj_data.put('coderror', '200');  
    obj_data.put('desc_codpos', get_tpostn_name(v_tjobpos.codpos, global_v_lang));
    obj_data.put('joblvlst', v_tjobpos.joblvlst);
    obj_data.put('joblvlen', v_tjobpos.joblvlen);
    obj_data.put('codjob', v_tjobpos.codjob || ' - ' || get_tjobcode_name(v_tjobpos.codjob, global_v_lang));
    obj_data.put('jobgrade', v_tjobpos.jobgrade || ' - ' || get_tcodec_name('TCODJOBG', v_tjobpos.jobgrade, global_v_lang));
    obj_data.put('jobgroup', v_tjobpos.jobgroup || ' - ' || get_tcodjobgrp_name(v_tjobpos.jobgroup, global_v_lang));
    obj_data.put('remarks', v_tjobpos.remarks);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --  
  procedure get_detail_codpos (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_codpos(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_kpi(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    cursor c1 is
      select codkpi,kpiitem,target,kpivalue
        from tjobkpi
       where codcomp = p_codcomp
         and codpos = p_codpos
       order by codkpi asc;

  begin
    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      obj_data   := json_object_t();
      v_count    := v_count + 1;
      obj_data.put('coderror', '200');  
      obj_data.put('codkpi', r1.codkpi);
      obj_data.put('kpiitem', r1.kpiitem);
      obj_data.put('target', r1.target);
      obj_data.put('kpivalue', to_char(r1.kpivalue,'fm999,999,990.00'));

      obj_row.put(to_char(v_count-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail_kpi (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_kpi(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_competency(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    cursor c1 is
      select codtency,codskill
        from tjobposskil
       where codcomp = p_codcomp
         and codpos = p_codpos
       order by codtency asc,codskill asc;

  begin
    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      obj_data   := json_object_t();
      v_count    := v_count + 1;
      obj_data.put('coderror', '200');  
      obj_data.put('codtency', r1.codtency);
      obj_data.put('codskill', r1.codskill);
      obj_data.put('desc_codtency', get_tcomptnc_name(r1.codtency, global_v_lang));
      obj_data.put('desc_codskill', get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang));

      obj_row.put(to_char(v_count-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail_competency (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_competency(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_drildown_kpi(json_str_output out clob) as
    obj_result  json_object_t;
    obj_tab1    json_object_t;
    obj_tab2    json_object_t;
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    rec_tjobkpi tjobkpi%rowtype;

    cursor c1 is
      select planlvl,plandesc 
        from tjobkpip
       where codpos = p_codpos
         and codcomp = p_codcomp
         and codkpi = p_codkpi
       order by planlvl;
    cursor c2 is
      select * 
        from tjobkpig
       where codpos = p_codpos
         and codcomp = p_codcomp
         and codkpi = p_codkpi
       order by qtyscor desc;
  begin
    obj_result := json_object_t();
    obj_result.put('coderror', '200');  
    obj_rows := json_object_t();
    for r1 in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('planlvl',r1.planlvl);
        obj_data.put('plandesc',r1.plandesc);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    obj_result.put('table1',obj_rows);

    obj_rows := json_object_t();
    v_row := 0;
    for r2 in c2 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        if r2.qtyscor = 5 then
          obj_data.put('tag','<i class="fa fa-circle _text-blue"></i>');
        elsif r2.qtyscor = 4 then
          obj_data.put('tag','<i class="fa fa-circle _text-green"></i>');
        elsif r2.qtyscor = 3 then
          obj_data.put('tag','<i class="fa fa-circle _text-yellow"></i>');
        elsif r2.qtyscor = 2 then
          obj_data.put('tag','<i class="fa fa-circle _text-orange"></i>');
        elsif r2.qtyscor = 1 then
          obj_data.put('tag','<i class="fa fa-circle _text-red"></i>');
        end if;
        obj_data.put('score',r2.qtyscor);
        if r2.flgkpi = 'P' then
          obj_data.put('result',get_tlistval_name('STAKPI', 'Y', global_v_lang));
        else
          obj_data.put('result',get_tlistval_name('STAKPI', 'N', global_v_lang));
        end if;
        obj_data.put('detail',r2.descgrd);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    obj_result.put('table2',obj_rows);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_drildown_kpi(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_drildown_kpi(json_str_output);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_drildown_competency(json_str_output out clob) as
    obj_rows          json_object_t;
    obj_data          json_object_t;
    obj_result        json_object_t;

    v_tjobposskil     tjobposskil%rowtype;
    v_namgrad         tskilscor.namgrade%type;
    v_row             number := 0;

    cursor c1 is
        select codpos, codcomp, codtency, codskill, grade, score
          from tjobscore
         where codpos = p_codpos
           and codcomp = p_codcomp
           and codtency =  p_codtency
           and codskill =  p_codskill
      order by grade;
  begin
  begin
      select * into v_tjobposskil
        from tjobposskil
       where codpos = p_codpos
         and codcomp = p_codcomp
         and codtency =  p_codtency 
         and codskill =  p_codskill;
  exception when no_data_found then
    v_tjobposskil := null;
  end;
    obj_rows := json_object_t();
    for i in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      begin
        select decode(global_v_lang,'101',namgrade
                                   ,'102',namgradt
                                   ,'103',namgrad3
                                   ,'104',namgrad4
                                   ,'105',namgrad5) as namgrad
          into v_namgrad
          from tskilscor
         where grade = i.grade
           and codskill = p_codskill;
      exception when no_data_found then
        v_namgrad := '';
      end;
      obj_data.put('grade',to_char(i.grade) || ' - ' || v_namgrad);
      obj_data.put('score',i.score);
      obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    begin
        select decode(global_v_lang,'101',namgrade
                                   ,'102',namgradt
                                   ,'103',namgrad3
                                   ,'104',namgrad4
                                   ,'105',namgrad5) as namgrad
          into v_namgrad
          from tskilscor
         where grade = v_tjobposskil.grade
           and codskill = p_codskill;
      exception when no_data_found then
        v_namgrad := '';
      end;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('grade',to_char(v_tjobposskil.grade) || ' - ' || v_namgrad);
    obj_result.put('score',v_tjobposskil.score);
    obj_result.put('fscore',v_tjobposskil.fscore);
    obj_result.put('table',obj_rows);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_drildown_competency(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_drildown_competency(json_str_output);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hres11x;

/
