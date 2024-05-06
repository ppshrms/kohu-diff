--------------------------------------------------------
--  DDL for Package Body HRAP4CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP4CE" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codkpino          := hcm_util.get_string_t(json_obj,'p_codkpino');

    -- save
    p_codeva            := hcm_util.get_string_t(json_obj,'p_codeva');
    p_dteeva            := to_date(hcm_util.get_string_t(json_obj,'p_dteeva'),'dd/mm/yyyy');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
  begin
    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
    if param_msg_error is not null then
      return;
    end if;
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

  procedure gen_index(json_str_output out clob)as
    obj_result      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_codeva        tkpidph.codeva%type;
    v_dteeva        tkpidph.dteeva%type;
    v_codappr       tkpidph.codappr%type;
    v_dteappr       tkpidph.dteappr%type;
    v_rcnt          number := 0;

    cursor c1 is
      select codkpino,kpides,wgt,target,kpivalue,achieve,mtrfinish,grade,qtyscor,qtyscorn,stakpi,
             codeva,dteeva,codappr,dteappr,
             dteyreap,numtime,codcomp
        from tkpidph
       where numtime  = b_index_numtime
         and dteyreap = b_index_dteyreap
         and codcomp  = b_index_codcomp
      order by codkpino;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_codeva  := r1.codeva;
      v_dteeva  := r1.dteeva;
      v_codappr := r1.codappr;
      v_dteappr := r1.dteappr;

      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codkpino', r1.codkpino);
      obj_data.put('kpides', r1.kpides);
      obj_data.put('wgt', r1.wgt);
      obj_data.put('target', r1.target);
      obj_data.put('kpivalue', r1.kpivalue);
      obj_data.put('achieve', r1.achieve);
      obj_data.put('mtrfinish', r1.mtrfinish);
      obj_data.put('grade', r1.grade);
      obj_data.put('qtyscor', r1.qtyscor);
      obj_data.put('qtyscorn', r1.qtyscorn);
      obj_data.put('stakpi', r1.stakpi);
      obj_data.put('desc_stakpi', r1.stakpi);
      obj_data.put('dteyreap', to_char(r1.dteyreap));
      obj_data.put('numtime', to_char(r1.numtime));
      obj_data.put('codcomp', r1.codcomp);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt <= 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tkpidph');
    end if;

    if param_msg_error is null then
      obj_result := json_object_t();
      obj_result.put('coderror','200');
      obj_result.put('codeva',v_codeva);
      obj_result.put('dteeva',to_char(v_dteeva,'dd/mm/yyyy'));
      obj_result.put('codappr',v_codappr);
      obj_result.put('dteappr',to_char(v_dteappr,'dd/mm/yyyy'));
      obj_result.put('table',obj_row);
      json_str_output := obj_result.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail(json_str_output out clob)as
    obj_result      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgeva        boolean := false;
    v_secur         boolean := false;
    v_codempid      temploy1.codempid%type;
    v_flg_tkpiemp   boolean := false;

    cursor c1 is
      select codempid,codpos,target,kpivalue
        from tkpidpem
       where dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
         and codcomp  = b_index_codcomp
         and codkpino = p_codkpino
      order by codempid;

    cursor c2 is
      select achieve,mtrrn,qtyscor
        from tkpiemp
       where dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
         and codempid = v_codempid
         and codkpi   = p_codkpino
      order by codcomp;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_secur then
        v_codempid := r1.codempid;
        v_flg_tkpiemp := false;
        for r2 in c2 loop
          v_flg_tkpiemp := true;
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
          obj_data.put('target', r1.target);
          obj_data.put('kpivalue', r1.kpivalue);
          obj_data.put('achieve', r2.achieve);
          obj_data.put('mtrrn', r2.mtrrn);
          obj_data.put('qtyscor', r2.qtyscor);

          --<<User37 #4323 01/10/2021
          /*if r2.achieve is not null or r2.mtrrn is not null then
            v_flgeva := true;
          end if;*/
          if not v_flgeva then
            if r2.achieve is null and r2.mtrrn is null then
              v_flgeva := true;
            end if;
          end if;
          -->>User37 #4323 01/10/2021

          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end loop;

        if v_flg_tkpiemp = false then
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
          obj_data.put('target', r1.target);
          obj_data.put('kpivalue', r1.kpivalue);
          obj_data.put('achieve', '');
          obj_data.put('mtrrn', '');
          obj_data.put('qtyscor', '');
          obj_row.put(to_char(v_rcnt - 1), obj_data);
          v_flgeva := true;
        end if;
      end if;
    end loop;

    if v_rcnt <= 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tkpidpem');
    end if;

    obj_result := json_object_t();

    if v_flgeva then--User37 #4323 01/10/2021 v_flgeva = false then
      obj_result.put('message', replace(get_error_msg_php('AP0060',global_v_lang),'@#$%400',null));
    end if;

    if param_msg_error is null then
      obj_result.put('coderror','200');
      obj_result.put('table',obj_row);
      json_str_output := obj_result.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_save is
    v_dteapend    tstdisd.dteapend%type;
  begin
    if p_codeva is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeva');
      return;
    else
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codeva);
      if param_msg_error is not null then
        --<<User37 #4323 01/10/2021
        if param_msg_error like '%<div%' then
          param_msg_error := replace(param_msg_error,'<div',' ('||get_label_name('HRAP4CE1','102',150)||')<div');
        else
          param_msg_error := replace(param_msg_error,'@#$%400',' ('||get_label_name('HRAP4CE1','102',150)||')@#$%400');
        end if;
        -->>User37 #4323 01/10/2021
        return;
      end if;
    end if;

    if p_dteeva is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeva');
      return;
    else
      begin
        select dteapend into v_dteapend
          from tstdisd
         where b_index_codcomp like codcomp||'%'--User37 #4323 01/10/2021 codcomp  like b_index_codcomp||'%'
           and dteyreap = b_index_dteyreap
           and numtime  = b_index_numtime
--#5552
           and exists(select codaplvl
                      from tempaplvl
                     where dteyreap = tstdisd.dteyreap
                       and numseq  = tstdisd.numtime
                       and codaplvl = tstdisd.codaplvl)
--#5552
           and rownum = 1;
      exception when no_data_found then
        v_dteapend := null;
      end;
      --param_msg_error := get_error_msg_php('HR2045',global_v_lang,v_dteapend); return;--User37 #4323 01/10/2021

/* --#7249 || USER39 || 23/11/2021    
      if p_dteeva > v_dteapend then
        param_msg_error := get_error_msg_php('AP0059',global_v_lang);
        return;
      end if;
*/  --#7249 || USER39 || 23/11/2021      
    end if;

    if p_codappr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codappr');
      return;
    else
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codappr);
      if param_msg_error is not null then
        --<<User37 #4323 01/10/2021
        if param_msg_error like '%<div%' then
          param_msg_error := replace(param_msg_error,'<div',' ('||get_label_name('HRAP4CE1','102',170)||')<div');
        else
          param_msg_error := replace(param_msg_error,'@#$%400',' ('||get_label_name('HRAP4CE1','102',170)||')@#$%400');
        end if;
        -->>User37 #4323 01/10/2021
        return;
      end if;
    end if;

    if p_dteappr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteappr');
      return;
    end if;
  end;

  procedure post_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      save_detail(json_str_input);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);--User37 #4323 01/10/2021
      commit;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);--User37 #4323 01/10/2021
      rollback;
    end if;
    --User37 #4323 01/10/2021 json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_codkpino      tkpidph.codkpino%type;
    v_achieve       tkpidph.achieve%type;
    v_mtrfinish     tkpidph.mtrfinish%type;
    v_grade         tkpidph.grade%type;
    v_qtyscor       tkpidph.qtyscor%type;
    v_qtyscorn      tkpidph.qtyscorn%type;
    v_stakpi        tkpidph.stakpi%type;
    v_clob clob;
  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    v_clob := param_json.to_clob;
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_codkpino      := hcm_util.get_string_t(param_json_row,'codkpino');
      v_achieve       := hcm_util.get_string_t(param_json_row,'achieve');
      v_mtrfinish     := hcm_util.get_string_t(param_json_row,'mtrfinish');
      v_grade         := hcm_util.get_string_t(param_json_row,'grade');
      v_qtyscor       := hcm_util.get_string_t(param_json_row,'qtyscor');
      v_qtyscorn      := hcm_util.get_string_t(param_json_row,'qtyscorn');
      v_stakpi        := hcm_util.get_string_t(param_json_row,'stakpi');

      if v_achieve is null   then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'achieve');   return; end if;
      if v_mtrfinish is null then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'mtrfinish'); return; end if;
      if v_grade is null     then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'grade');     return; end if;
      if v_qtyscor is null   then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtyscor');   return; end if;
      if v_qtyscorn is null  then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtyscorn');  return; end if;
      if v_stakpi is null    then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stakpi');    return; end if;

      begin
        update tkpidph
           set achieve   = v_achieve,
               mtrfinish = v_mtrfinish,
               grade     = v_grade,
               qtyscor   = v_qtyscor,
               qtyscorn  = v_qtyscorn,
               stakpi    = v_stakpi,
               dteeva    = p_dteeva,
               codeva    = p_codeva,
               dteappr   = p_dteappr,
               codappr   = p_codappr,
               coduser   = global_v_coduser --User37 #4323 01/10/2021
         where dteyreap  = b_index_dteyreap
           and numtime   = b_index_numtime
           and codcomp   = b_index_codcomp
           and codkpino  = v_codkpino;
      exception when others then
        null;
      end;
    end loop;
  end save_detail;

end hrap4ce;

/
