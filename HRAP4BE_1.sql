--------------------------------------------------------
--  DDL for Package Body HRAP4BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP4BE" as
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
    b_index_codreview   := hcm_util.get_string_t(json_obj,'p_codreview');
    b_index_dtereview   := to_date(hcm_util.get_string_t(json_obj,'p_dtereview'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_error     varchar2(4000);
    cursor c1 is
      select staemp,codcomp,codpos
        from temploy1
       where codempid   = b_index_codreview
      union
      select '99' as staemp,codcomp,codpos
        from tsecpos
       where codempid   = b_index_codreview
         and dteeffec   <= trunc(sysdate)
         and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) 
      order by staemp;
  begin
    if b_index_codempid is not null then
      v_error   := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;
    if b_index_codreview is not null then
      v_error   := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codreview);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;

    begin
      select 'N'
        into v_error
        from tappkpimth
       where codempid   = b_index_codempid
         and dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and rownum     = 1;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'tappkpimth');
      return;
    end;

    for i in c1 loop
      if i.staemp = '9' then
        param_msg_error   := get_error_msg_php('HR2101',global_v_lang);
        exit;
      elsif i.staemp = '0' then
        param_msg_error   := get_error_msg_php('HR2102',global_v_lang);
        exit;
      end if;

      begin
        select 'N'
          into v_error
          from tappfm
         where codempid   = b_index_codempid
           and dteyreap   = b_index_dteyreap
           and numtime    = b_index_numtime
           and flgapman   in ('2','3')
           and (codapman  = b_index_codreview
            or (codcompap = i.codcomp and codposap = i.codpos)) 
           and rownum     = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tappfm');
        v_error         := 'Y';
      end;
      if v_error = 'N' then
        param_msg_error   := '';
        exit;
      end if;
    end loop;
    if param_msg_error is not null then
      return;
    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    v_data          varchar2(1) := 'N';

    cursor c_kpi is
      select codkpi,typkpi,kpides,target,mtrfinish,
             targtstr,targtend,achieve,mtrrn,
             decode(typkpi,'D',1,'J',2,3) as sort_by
        from tkpiemp
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
      order by sort_by,codkpi;
  begin
    obj_row := json_object_t();
    for i in c_kpi loop
      v_data        := 'Y';
      obj_data  := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codkpi',i.codkpi);
      obj_data.put('typkpi',i.typkpi);
      obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
      obj_data.put('kpides',i.kpides);
      obj_data.put('target',i.target);
      obj_data.put('mtrfinish',to_char(i.mtrfinish,'fm9,999,999,990.00'));
      obj_data.put('targtstr',to_char(i.targtstr,'dd/mm/yyyy'));
      obj_data.put('targtend',to_char(i.targtend,'dd/mm/yyyy'));
      obj_data.put('achieve',i.achieve);
      obj_data.put('mtrrn',to_char(i.mtrrn,'fm9,999,999,990.00'));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    if v_data = 'N' then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'tkpiemp');
      return;
    else
      json_str_output   := obj_row.to_clob;
    end if;
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
  procedure gen_detail(json_str_input in clob,json_str_output out clob) is
    json_str        json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_data          varchar2(1) := 'N';

    v_codkpi        tkpiemp.codkpi%type;

    cursor c_kpi is
      select dtemonth,codkpi,descwork,kpivalue,dteinput,
             dtereview,codreview,commtimpro
        from tappkpimth
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
         and codkpi     = v_codkpi
      order by dtemonth;
  begin
    json_str      := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_str,'p_codkpi');
    obj_row := json_object_t();
    for i in c_kpi loop
      v_data        := 'Y';
      obj_data  := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dtemonth',i.dtemonth);
      obj_data.put('desc_dtemonth',get_tlistval_name('NAMMTHFUL',i.dtemonth,global_v_lang));
      obj_data.put('codkpi',i.codkpi);
      obj_data.put('descwork',i.descwork);
      obj_data.put('kpivalue',i.kpivalue);
      obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
      obj_data.put('dtereview',to_char(nvl(i.dtereview,b_index_dtereview),'dd/mm/yyyy'));
      obj_data.put('codreview',nvl(i.codreview,b_index_codreview));
      if i.codreview is null then
        obj_data.put('desc_codreview',get_temploy_name(b_index_codreview,global_v_lang));
      else
        obj_data.put('desc_codreview',get_temploy_name(i.codreview,global_v_lang));
      end if;
      if nvl(i.codreview,b_index_codreview) = b_index_codreview then
        obj_data.put('flgedit','Y');
      else
        obj_data.put('flgedit','N');
      end if;
      obj_data.put('commtimpro',i.commtimpro);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_input,json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_act_plan(json_str_input in clob,json_str_output out clob) is
    json_str        json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_data          varchar2(1) := 'N';

    v_codkpi        tkpiemp.codkpi%type;
    t_tkpiemp       tkpiemp%rowtype;

    cursor c_kpi is
      select planno,plandes,targtstr,targtend,dtewstr,dtewend,workdesc
        from tkpiemppl
       where dteyreap   = b_index_dteyreap
         and numtime    = b_index_numtime
         and codempid   = b_index_codempid
         and codkpi     = v_codkpi
      order by planno;
  begin
    json_str      := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_str,'p_codkpi');
    obj_row := json_object_t();
    for i in c_kpi loop
      v_data        := 'Y';
      obj_data  := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('plandes',i.plandes);
      obj_data.put('targt',hcm_util.get_date_buddhist_era(i.targtstr)||' - '||hcm_util.get_date_buddhist_era(i.targtend));
      obj_data.put('dtew',hcm_util.get_date_buddhist_era(i.dtewstr)||' - '||hcm_util.get_date_buddhist_era(i.dtewend));
      obj_data.put('workdesc',i.workdesc);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_act_plan(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_act_plan(json_str_input, json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_review(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    t_tappkpimth          tappkpimth%rowtype;

    v_codkpi              tkpiemp.codkpi%type;
  begin
    initial_value(json_str_input);
    json_input    := json_object_t(json_str_input);
    v_codkpi      := hcm_util.get_string_t(json_input,'p_codkpi');
    param_json    := hcm_util.get_json_t(json_input,'param_json');
    for i in 0..(param_json.get_size - 1) loop
      param_json_row            := hcm_util.get_json_t(param_json,to_char(i));
      t_tappkpimth.dtemonth     := hcm_util.get_string_t(param_json_row,'dtemonth');
      t_tappkpimth.commtimpro   := hcm_util.get_string_t(param_json_row,'commtimpro');
      t_tappkpimth.dtereview    := to_date(hcm_util.get_string_t(param_json_row,'dtereview'),'dd/mm/yyyy');
      t_tappkpimth.codreview    := hcm_util.get_string_t(param_json_row,'codreview');

      if t_tappkpimth.commtimpro is null then
        t_tappkpimth.dtereview    := null;
        t_tappkpimth.codreview    := null;
      end if;

      begin
        update tappkpimth
           set commtimpro   = t_tappkpimth.commtimpro,
               dtereview    = t_tappkpimth.dtereview,
               codreview    = t_tappkpimth.codreview,
               coduser      = global_v_coduser
         where dteyreap     = b_index_dteyreap
           and numtime      = b_index_numtime
           and codempid     = b_index_codempid
           and dtemonth     = t_tappkpimth.dtemonth
           and codkpi       = v_codkpi;
      end;
    end loop;
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
