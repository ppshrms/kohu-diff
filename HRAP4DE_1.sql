--------------------------------------------------------
--  DDL for Package Body HRAP4DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP4DE" is

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
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codkpi            := hcm_util.get_string_t(json_obj,'p_codkpi');

    -- save
    p_codeva            := hcm_util.get_string_t(json_obj,'p_codeva');
    p_dteeva            := to_date(hcm_util.get_string_t(json_obj,'p_dteeva'),'dd/mm/yyyy');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');
  end;

  procedure check_index is
  begin
    if b_index_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompy);
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
    v_codeva        tkpicmphs.codeva%type;
    v_dteeva        tkpicmphs.dteeva%type;
    v_codappr       tkpicmphs.codappr%type;
    v_dteappr       tkpicmphs.dteappr%type;
    v_rcnt          number := 0;

    cursor c1 is
      select b.balscore,b.codkpi,b.target,b.kpivalue,a.achieve,a.mtrfinish,a.grade,a.qtyscor,a.stakpi,
             a.codeva,a.dteeva,a.codappr,a.dteappr,
             b.dteyreap,a.numtime,b.codcompy
        from tkpicmphs a, tkpicmph b
       where a.dteyreap(+) = b.dteyreap
         and a.codcompy(+) = b.codcompy
         and a.codkpi(+)   = b.codkpi
         and a.numtime(+)  = b_index_numtime
         and b.dteyreap(+) = b_index_dteyreap
         and b.codcompy(+) = b_index_codcompy
      order by b.balscore,a.codkpi;
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
      obj_data.put('balscore', r1.balscore);
      obj_data.put('desc_balscore', get_tlistval_name('BALSCORE',r1.balscore,global_v_lang));
      obj_data.put('codkpi', r1.codkpi);
      obj_data.put('desc_codkpi', get_tkpicmph_name(r1.dteyreap,r1.codcompy,r1.codkpi));
      obj_data.put('target', r1.target);
      obj_data.put('kpivalue', r1.kpivalue);
      obj_data.put('achieve', r1.achieve);
      obj_data.put('mtrfinish', r1.mtrfinish);
      obj_data.put('grade', r1.grade);
      obj_data.put('qtyscor', nvl(r1.qtyscor,0));
      obj_data.put('stakpi', r1.stakpi);
      obj_data.put('desc_stakpi', get_tlistval_name('STAKPI',r1.stakpi,global_v_lang));
      obj_data.put('dteyreap', to_char(r1.dteyreap));
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('numtime', to_char(r1.numtime));
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt <= 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tkpicmph');
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
    v_codkpino      tkpicmppl.codkpino%type;
    v_codcomp       tkpicmpdp.codcomp%type;
    v_achieve       tkpidph.achieve%type;
    v_flgeva        boolean := false;
    v_flg_tkpicmpdp boolean := false;

    cursor c1 is
      select codkpino,kpides,targetkpi
        from tkpicmppl
       where dteyreap = b_index_dteyreap
         and codcompy = b_index_codcompy
         and codkpi   = p_codkpi
      order by codkpino;

    cursor c2 is
      select codcomp,target,kpivalue
        from tkpicmpdp
       where dteyreap = b_index_dteyreap
         and codcompy = b_index_codcompy
         and codkpi   = p_codkpi
         and codkpino = v_codkpino
      order by codcomp;

    cursor c3 is
      select achieve,mtrfinish,qtyscor
        from tkpidph
       where dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
         and codcomp  = v_codcomp
         and codkpino = v_codkpino
      order by codcomp;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_codkpino := r1.codkpino;
      for r2 in c2 loop
        v_flg_tkpicmpdp := false;
        v_rcnt := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codkpino', r1.codkpino);
        obj_data.put('kpides', r1.kpides);
        obj_data.put('codcomp', hcm_util.get_codcomp_level(r2.codcomp,null,'-','Y'));
        obj_data.put('desc_codcomp', get_tcenter_name(r2.codcomp, global_v_lang));
        obj_data.put('target', r2.target);
        obj_data.put('kpivalue', r2.kpivalue);
        v_codcomp := r2.codcomp;
        for r3 in c3 loop
          v_flg_tkpicmpdp := true;
          obj_data.put('achieve', r3.achieve);
          obj_data.put('mtrfinish', r3.mtrfinish);
          obj_data.put('qtyscor', r3.qtyscor);
          if r3.achieve is not null or r3.mtrfinish is not null then
            v_flgeva := true;
          end if;
        end loop;

        if v_flg_tkpicmpdp = false then
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('achieve', '');
          obj_data.put('mtrfinish', '');
          obj_data.put('qtyscor', '');
          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end loop;

    if v_rcnt <= 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tkpicmpdp');
    end if;

    obj_result := json_object_t();

    if v_flgeva = false then
      obj_result.put('message', replace(get_error_msg_php('AP0058',global_v_lang),'@#$%400',null));
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
         where codcomp  like b_index_codcompy||'%'
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
 --      if p_dteeva > v_dteapend then
--        param_msg_error := get_error_msg_php('AP0059',global_v_lang);
--        return;
--      end if; --#7245
    end if;

    if p_codappr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codappr');
      return;
    else
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codappr);
      if param_msg_error is not null then
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
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_codkpi        tkpicmphs.codkpi%type;
    v_achieve       tkpicmphs.achieve%type;
    v_mtrfinish     tkpicmphs.mtrfinish%type;
    v_grade         tkpicmphs.grade%type;
    v_qtyscor       tkpicmphs.qtyscor%type;
    v_stakpi        tkpicmphs.stakpi%type;
    v_grd           varchar2(1 char);
    v_clob clob;
  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    v_clob := param_json.to_clob;
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_codkpi        := hcm_util.get_string_t(param_json_row,'codkpi');
      v_achieve       := hcm_util.get_string_t(param_json_row,'achieve');
      v_mtrfinish     := hcm_util.get_string_t(param_json_row,'mtrfinish');
      v_grade         := hcm_util.get_string_t(param_json_row,'grade');
      v_qtyscor       := hcm_util.get_string_t(param_json_row,'qtyscor');
      v_stakpi        := hcm_util.get_string_t(param_json_row,'stakpi');

      if v_achieve is null   then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'achieve');   return; end if;
      if v_mtrfinish is null then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'mtrfinish'); return; end if;
      if v_grade is null     then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'grade');     return; end if;
      if v_qtyscor is null   then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtyscor');   return; end if;
      if v_stakpi is null    then param_msg_error := get_error_msg_php('HR2045',global_v_lang,'stakpi');    return; end if;

      begin ----
        select 'Y' into v_grd
        from  tkpicmpg
        where dteyreap  = b_index_dteyreap
        and   codcompy  = b_index_codcompy
        and   codkpi    = v_codkpi
        and   rownum    = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TKPICMPG');
        return;
      end;
      begin
--        update tkpicmphs
--           set achieve   = v_achieve,
--               mtrfinish = v_mtrfinish,
--               grade     = v_grade,
--               qtyscor   = v_qtyscor,
--               stakpi    = v_stakpi,
--               dteeva    = p_dteeva,
--               codeva    = p_codeva,
--               dteappr   = p_dteappr,
--               codappr   = p_codappr,
--               coduser   = global_v_lang
--         where dteyreap  = b_index_dteyreap
--           and numtime   = b_index_numtime
--           and codcompy  = b_index_codcompy
--           and codkpi    = v_codkpi;
        insert into tkpicmphs(dteyreap,numtime,codcompy,codkpi, ----
                              achieve,mtrfinish,grade,qtyscor,stakpi,
                              dteeva,codeva,dteappr,codappr,
                              codcreate,coduser) 
                      values (b_index_dteyreap,b_index_numtime,b_index_codcompy,v_codkpi,
                              v_achieve,v_mtrfinish,v_grade,v_qtyscor,v_stakpi,
                              p_dteeva,p_codeva,p_dteappr,p_codappr,
                              global_v_coduser,global_v_coduser); 
      exception when others then
        update tkpicmphs
           set achieve   = v_achieve,
               mtrfinish = v_mtrfinish,
               grade     = v_grade,
               qtyscor   = v_qtyscor,
               stakpi    = v_stakpi,
               dteeva    = p_dteeva,
               codeva    = p_codeva,
               dteappr   = p_dteappr,
               codappr   = p_codappr,
               coduser   = global_v_coduser
         where dteyreap  = b_index_dteyreap
           and numtime   = b_index_numtime
           and codcompy  = b_index_codcompy
           and codkpi    = v_codkpi;
      end;

      begin
        update tkpicmph
           set achieve   = v_achieve,
               mtrfinish = v_mtrfinish,
               grade     = v_grade,
               qtyscor   = v_qtyscor,
               stakpi    = v_stakpi,
               coduser   = global_v_coduser ----global_v_lang
         where dteyreap  = b_index_dteyreap
           and codcompy  = b_index_codcompy
           and codkpi    = v_codkpi;
      exception when others then
        null;
      end;
    end loop;
  end save_detail;

end hrap4de;

/
