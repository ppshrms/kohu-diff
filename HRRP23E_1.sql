--------------------------------------------------------
--  DDL for Package Body HRRP23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP23E" is
--last update: 27/03/2023 12.30

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_dteyrbug    := hcm_util.get_string_t(json_obj,'p_dteyrbug');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtereq      := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    b_index_codemprq    := hcm_util.get_string_t(json_obj,'p_codemprq');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');

    p_qtynewn           := nvl(hcm_util.get_string_t(json_obj,'p_qtynewn'),'0');
    p_qtypromoten       := nvl(hcm_util.get_string_t(json_obj,'p_qtypromoten'),'0');
    p_qtyretin          := nvl(hcm_util.get_string_t(json_obj,'p_qtyretin'),'0');
    p_qtybudgtn         := nvl(hcm_util.get_string_t(json_obj,'p_qtybudgtn'),'0');
    p_remarkrq          := hcm_util.get_string_t(json_obj,'p_remarkrq');
    p_newsalary         := hcm_util.get_string_t(json_obj,'p_newsalary');
    p_avgsalary         := hcm_util.get_string_t(json_obj,'p_avgsalary');
    p_promsalary        := hcm_util.get_string_t(json_obj,'p_promsalary');
    p_other             := hcm_util.get_string_t(json_obj,'p_other');
    global_qtyexman     := 0;

  end;

  procedure check_index is
  begin
    if b_index_dteyrbug is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrbug');
      return;
    else
        null;
-- << bk surachai | 27/03/2023 | st11- es.ms module(p2)#8911        
--      if b_index_dteyrbug < to_char(sysdate,'yyyy') then
--        param_msg_error := get_error_msg_php('HR4510',global_v_lang,'dteyrbug');
--        return;
--      end if;
-- >>
    end if;

    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_dtereq is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtereq');
      return;
    end if;

    if b_index_codemprq is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codemprq);
      if param_msg_error is not null then
        return;
      end if;
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
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_qtylstyr      number;

    cursor c1 is
      select dteyrbug,codcomp,codpos,qtyreqyr,qtypromote,qtyreti,qtybudgt,amttotbudgt,staappr,remarkrq,dtereq,codemprq
        from tbudget
       where dteyrbug = b_index_dteyrbug
--         and codcomp  like b_index_codcomp||'%'
--         and codemprq = nvl(b_index_codemprq,codemprq)
--         and trunc(dtereq)   = b_index_dtereq
      order by dtereq;
  begin

    obj_row := json_object_t();
    for r1 in c1 loop
      begin
        select qtyexman
          into v_qtylstyr
          from tmanpwm
         where dteyrbug  = r1.dteyrbug - 1
           and dtemthbug = 12
           and codcomp   = r1.codcomp
           and codpos    = r1.codpos;
      exception when no_data_found then
        v_qtylstyr := 0;
      end;
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dteyrbug', r1.dteyrbug);
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('qtylstyr', nvl(v_qtylstyr,0));
      obj_data.put('qtyreqyr', nvl(r1.qtyreqyr,0));
      obj_data.put('qtypromote', nvl(r1.qtypromote,0));
      obj_data.put('qtyreti', nvl(r1.qtyreti,0));
      obj_data.put('qtybudgt', nvl(r1.qtybudgt,0));
      obj_data.put('amttotbudgt', nvl(r1.amttotbudgt,0));
      obj_data.put('staappr', r1.staappr);
      obj_data.put('status', get_tlistval_name('STAAPPR', r1.staappr, global_v_lang));
      obj_data.put('remarkrq', r1.remarkrq);
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('codemprq', r1.codemprq);
      obj_data.put('desc_codemprq', get_temploy_name(r1.codemprq,global_v_lang));
      --<< user25 Date : 13/09/2021 1. RP Module #4880

      if to_number(to_char(trunc(sysdate),'yyyy')) > r1.dteyrbug then 
          obj_data.put('flgDisabled', true);
      else
          if nvl(r1.staappr,'N') <> 'P' then
            obj_data.put('flgDisabled', true);
          else
            obj_data.put('flgDisabled', false);
          end if;        
      end if;

      -->> user25 Date : 13/09/2021 1. RP Module #4880
      obj_row.put(to_char(v_rcnt-1),obj_data);
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

  procedure check_detail is
    v_codemprq  tbudget.codemprq%type;
  begin
    if b_index_codemprq is not null then
      begin
        select codemprq
          into v_codemprq
          from tbudget
         where dteyrbug = b_index_dteyrbug
           and codcomp  = b_index_codcomp
           and codpos   = b_index_codpos
           and dtereq   = b_index_dtereq
           and codemprq <> b_index_codemprq;
        param_msg_error := get_error_msg_php('RP0025',global_v_lang);
        return;
      exception when no_data_found then
        null;
      end;
    end if;
  end;

  procedure get_tab1_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_tab1_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tab1_detail(json_str_output out clob)as
    obj_data        json_object_t;
    v_qtybgman      tmanpw.qtybgman%type;
    v_qtyexman      tmanpw.qtyexman%type;
    v_qtytotrf      tmanpw.qtytotrf%type;
    v_qtytotrc      tmanpw.qtytotrc%type;
    v_qtypromote    tmanpw.qtypromote%type;
    v_qtytotre      tmanpw.qtytotre%type;
    v_qtytotro      tmanpw.qtytotro%type;
    v_flgdata       boolean := false;

    cursor c1 is
      select dteyrbug,qtyreqyr,qtypromote,qtyreti,qtybudgt,remarkrq,dteappr,codappr,remarkap,
             staappr --<< user25 Date : 13/09/2021 1. RP Module #4880
        from tbudget
       where dteyrbug = b_index_dteyrbug
         and codcomp  = b_index_codcomp
         and codpos   = b_index_codpos
         and dtereq   = b_index_dtereq;

  begin
    begin
      select qtybgman,qtyexman,qtytotrf,qtytotrc,qtypromote,qtytotre,qtytotro
        into v_qtybgman,v_qtyexman,v_qtytotrf,v_qtytotrc,v_qtypromote,v_qtytotre,v_qtytotro
        from tmanpwm
       where dteyrbug  = b_index_dteyrbug - 1
         and dtemthbug = 12
         and codcomp   = b_index_codcomp
         and codpos    = b_index_codpos;
--#7153 || User39 || 28/10/2021
    exception when no_data_found then
      select count(*)
        into v_qtyexman
        from temploy1
       where codcomp = b_index_codcomp
         and codpos  = b_index_codpos
         and staemp in ('1','3');
      v_qtybgman   := 0;
      v_qtytotrf   := 0;
      v_qtytotrc   := 0;
      v_qtypromote := 0;
      v_qtytotre   := 0;
      v_qtytotro   := 0;
    end;
--#7153 || User39 || 28/10/2021

    global_qtyexman := v_qtyexman;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('qtybgman', nvl(v_qtybgman,0));
    obj_data.put('qtyexman', nvl(v_qtyexman,0));
    obj_data.put('qtynew', nvl(v_qtytotrf,0) + nvl(v_qtytotrc,0));
    obj_data.put('qtypromote', nvl(v_qtypromote,0));
    obj_data.put('qtyreti', nvl(v_qtytotre,0) + nvl(v_qtytotro,0));
    obj_data.put('qtynet', nvl(v_qtyexman,0) + nvl(v_qtytotrf,0) + nvl(v_qtytotrc,0) + nvl(v_qtypromote,0) - (nvl(v_qtytotre,0) + nvl(v_qtytotro,0)));

    for r1 in c1 loop
      v_flgdata := true;
      obj_data.put('qtynewn', nvl(r1.qtyreqyr,0));
      obj_data.put('qtypromoten', nvl(r1.qtypromote,0));
      obj_data.put('qtyretin', nvl(r1.qtyreti,0));
      obj_data.put('qtybudgtn', nvl(r1.qtybudgt,0));
      obj_data.put('remarkrq', r1.remarkrq);
      obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', r1.codappr||' - '||get_temploy_name(r1.codappr,global_v_lang));
      obj_data.put('remarkap', r1.remarkap);
      --<< user25 Date : 13/09/2021 1. RP Module #4880
      if nvl(r1.staappr,'N') <> 'P' then
        obj_data.put('flgDisabled', true);
      else
        obj_data.put('flgDisabled', false);
      end if;
      -->> user25 Date : 13/09/2021 1. RP Module #4880
    end loop;

    if v_flgdata = false then
      obj_data.put('qtynewn', '');
      obj_data.put('qtypromoten', '');
      obj_data.put('qtyretin', '');
      obj_data.put('qtybudgtn', '');
      obj_data.put('remarkrq', '');
      obj_data.put('dteappr', '');
      obj_data.put('codappr', '');
      obj_data.put('desc_codappr', '');
      obj_data.put('remarkap', '');
      obj_data.put('flgDisabled', false);--<< user25 Date : 13/09/2021 1. RP Module #4880
    end if;

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_tab2_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tab2_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tab2_table(json_str_output out clob)as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_ytd           number := 0;
    v_month         number := 0;
    type arr_number_1d is table of number index by binary_integer;
      a_detail      arr_number_1d;
    type arr_number_2d is table of arr_number_1d index by binary_integer;
      a_qtydata     arr_number_2d;

    cursor c1 is
      select dtemthbug,qtymonth,qtynew,qtypromote,qtyreti,qtybudgt
        from tbudgetm
       where dteyrbug  = b_index_dteyrbug
         and codcomp   = b_index_codcomp
         and codpos    = b_index_codpos
         and dtereq    = b_index_dtereq
         and dtemthbug = v_month;
  begin
    for i in 1..5 loop
      a_detail(i) := null;
      for j in 1..12 loop
        a_qtydata(i)(j) := 0;
      end loop;
    end loop;

    for mth in 1..12 loop
      v_month := mth;
      for r1 in c1 loop
        a_qtydata(1)(mth) := nvl(r1.qtymonth,0);
        a_qtydata(2)(mth) := nvl(r1.qtynew,0);
        a_qtydata(3)(mth) := nvl(r1.qtypromote,0);
        a_qtydata(4)(mth) := nvl(r1.qtyreti,0);
        a_qtydata(5)(mth) := nvl(r1.qtybudgt,0);
      end loop;
    end loop;

    obj_row := json_object_t();
    for rw in 1..5 loop
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('detail', get_label_name('HRRP23EC3',global_v_lang,(10*rw) + 40)); -- [50 - 90]
      v_ytd := 0;
      for mth in 1..12 loop
        if rw = 1 then
            v_ytd := a_qtydata(rw)(1);
        elsif rw = 5 then
            v_ytd := a_qtydata(rw)(12);
        else
            v_ytd := v_ytd + a_qtydata(rw)(mth);
        end if;
--        if nvl(a_qtydata(2)(mth),0) > 0 or
--           nvl(a_qtydata(3)(mth),0) > 0 or
--           nvl(a_qtydata(4)(mth),0) > 0 then
--            v_ytd := a_qtydata(rw)(mth);
--        end if;
        obj_data.put('month'||to_char(mth), a_qtydata(rw)(mth));

        -- set flgdisable column
        if b_index_dteyrbug = to_number(to_char(sysdate,'yyyy')) then
            if mth >= to_number(to_char(sysdate,'mm')) then --user36 #4881 15/09/2021
              obj_data.put('flgdisp'||to_char(mth), 'Y');
            else
              obj_data.put('flgdisp'||to_char(mth), 'N');
            end if;
        elsif b_index_dteyrbug > to_number(to_char(sysdate,'yyyy')) then
            obj_data.put('flgdisp'||to_char(mth), 'Y');
        else
            obj_data.put('flgdisp'||to_char(mth), 'N');
        end if;
      end loop;
      obj_data.put('ytd', v_ytd);
      obj_row.put(to_char(rw-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_tab3_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tab3_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tab3_detail(json_str_output out clob)as
    obj_data        json_object_t;
    v_amtsal        number;
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    json_str_tmp    clob;
    v_aversalary    number := 0;
    v_amtnewsal     tbudget.amtnewsal%type;
    v_amtavgsal     tbudget.amtavgsal%type;
    v_amtprosal     tbudget.amtprosal%type;
    v_pctothbudgt   tbudget.pctothbudgt%type;

    cursor c1 is
      select a.codcomp,a.codempmt,
             stddec(amtincom1,a.codempid,v_chken) incom1,
             stddec(amtincom2,a.codempid,v_chken) incom2,
             stddec(amtincom3,a.codempid,v_chken) incom3,
             stddec(amtincom4,a.codempid,v_chken) incom4,
             stddec(amtincom5,a.codempid,v_chken) incom5,
             stddec(amtincom6,a.codempid,v_chken) incom6,
             stddec(amtincom7,a.codempid,v_chken) incom7,
             stddec(amtincom8,a.codempid,v_chken) incom8,
             stddec(amtincom9,a.codempid,v_chken) incom9,
             stddec(amtincom10,a.codempid,v_chken) incom10
        from temploy1 a,temploy3 b
       where a.codempid = b.codempid
         and a.codcomp  = b_index_codcomp
         and a.codpos   = b_index_codpos
         and a.staemp in ('1','3');
  begin
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    begin
      select amtsal
        into v_amtsal
        from tmanpwm
       where dteyrbug  = b_index_dteyrbug - 1
         and dtemthbug = 12
         and codcomp   = b_index_codcomp
         and codpos    = b_index_codpos;
    exception when no_data_found then
      v_amtsal := 0;
      for r1 in c1 loop
        get_wage_income(r1.codcomp,r1.codempmt,
                        r1.incom1,r1.incom2,r1.incom3,r1.incom4,r1.incom5,
                        r1.incom6,r1.incom7,r1.incom8,r1.incom9,r1.incom10,
                        v_sumhur,v_sumday,v_summth);
        v_amtsal := v_amtsal + v_summth;
      end loop;
    end;

    obj_data.put('amtsal', to_char(v_amtsal,'fm999,999,999,999,990.00'));

    begin
      select amtnewsal,amtavgsal,amtprosal,pctothbudgt
        into v_amtnewsal,v_amtavgsal,v_amtprosal,v_pctothbudgt
        from tbudget
       where dteyrbug  = b_index_dteyrbug
         and codcomp   = b_index_codcomp
         and codpos    = b_index_codpos
         and dtereq    = b_index_dtereq;
    exception when no_data_found then
      gen_tab1_detail(json_str_tmp); -- for get global_qtyexman of tab request
      if global_qtyexman > 0 then   --if global_qtyexman <> 0 then --#7153 || User39 || 28/10/2021
        v_amtavgsal := v_amtsal/global_qtyexman;
      end if;
    end;

    obj_data.put('aversalary', to_char(v_amtavgsal,'fm999,999,999,999,990.00'));
    obj_data.put('newsalary', to_char(v_amtnewsal));
    obj_data.put('newsalaryc', to_char(v_amtnewsal,'fm999,999,999,999,990.00'));
    obj_data.put('other', v_pctothbudgt);
    obj_data.put('otherc', to_char(v_pctothbudgt,'fm999,999,999,999,990.00'));
    obj_data.put('promsalary', to_char(v_amtprosal));
    obj_data.put('promsalaryc', to_char(v_amtprosal,'fm999,999,999,999,990.00'));
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_tab3_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tab3_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tab3_table(json_str_output out clob)as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_ytd           number := 0;
    v_month         number := 0;
    type arr_varchar_1d is table of varchar2(1000 char) index by binary_integer;
      a_detail      arr_varchar_1d;
    type arr_number_1d is table of number index by binary_integer;
    type arr_number_2d is table of arr_number_1d index by binary_integer;
      a_qtydata     arr_number_2d;

    v_pctothbudgt   tbudget.pctothbudgt%type;

    cursor c1 is
      select dtemthbug,amtsalmth,amthirebudgt,amtprobudgt,amtresbudgt,amttotbudgt
        from tbudgetm
       where dteyrbug  = b_index_dteyrbug
         and codcomp   = b_index_codcomp
         and codpos    = b_index_codpos
         and dtereq    = b_index_dtereq
         and dtemthbug = v_month;
  begin

    begin
      select pctothbudgt
        into v_pctothbudgt
        from tbudget
       where dteyrbug  = b_index_dteyrbug
         and codcomp   = b_index_codcomp
         and codpos    = b_index_codpos
         and dtereq    = b_index_dtereq;
    exception when no_data_found then
      v_pctothbudgt := 0;
    end;

    a_detail(1) := get_label_name('HRRP23EC4',global_v_lang,'120');
    a_detail(2) := get_label_name('HRRP23EC4',global_v_lang,'130');
    a_detail(3) := get_label_name('HRRP23EC4',global_v_lang,'140');
    a_detail(4) := get_label_name('HRRP23EC4',global_v_lang,'320');
    a_detail(5) := get_label_name('HRRP23EC4',global_v_lang,'330');
    a_detail(6) := get_label_name('HRRP23EC4',global_v_lang,'150');
    a_detail(7) := get_label_name('HRRP23EC4',global_v_lang,'340');
    for i in 1..7 loop
      for j in 1..12 loop
        a_qtydata(i)(j) := 0;
      end loop;
    end loop;

    for mth in 1..12 loop
      v_month := mth;
      for r1 in c1 loop
        a_qtydata(1)(mth) := nvl(r1.amtsalmth,0);
        a_qtydata(2)(mth) := nvl(r1.amthirebudgt,0);
        a_qtydata(3)(mth) := nvl(r1.amtprobudgt,0);
        a_qtydata(4)(mth) := nvl(r1.amtresbudgt,0);
        a_qtydata(5)(mth) := a_qtydata(1)(mth) + a_qtydata(2)(mth) + a_qtydata(3)(mth) - a_qtydata(4)(mth);
        a_qtydata(6)(mth) := nvl(r1.amttotbudgt,0);
        a_qtydata(6)(mth) := round(a_qtydata(5)(mth) * v_pctothbudgt/100,2);
        a_qtydata(7)(mth) := a_qtydata(5)(mth) + a_qtydata(6)(mth);
      end loop;
    end loop;

    obj_row := json_object_t();
    for rw in 1..7 loop
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('detail', a_detail(rw));
      v_ytd := 0;
      for mth in 1..12 loop
        -- set flgdisable column
        if b_index_dteyrbug = to_number(to_char(sysdate,'yyyy')) then
            if mth >= to_number(to_char(sysdate,'mm')) then --user36 #4881 15/09/2021
              obj_data.put('flgdisp'||to_char(mth), 'Y');
            else
              obj_data.put('flgdisp'||to_char(mth), 'N');
            end if;
        elsif b_index_dteyrbug > to_number(to_char(sysdate,'yyyy')) then
            obj_data.put('flgdisp'||to_char(mth), 'Y');
        else
            obj_data.put('flgdisp'||to_char(mth), 'N');
        end if;
        -- set values 
        v_ytd := v_ytd + a_qtydata(rw)(mth);
        obj_data.put('month'||to_char(mth), a_qtydata(rw)(mth));
      end loop;
      obj_data.put('ytd', v_ytd);

      if rw in ('5','7') then
        obj_data.put('flgsum', 'Y');
      else
        obj_data.put('flgsum', '');
      end if;
      obj_row.put(to_char(rw-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_index(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_flg           varchar2(10 char);
    v_dteyrbug      tbudget.dteyrbug%type;
    v_codcomp       tbudget.codcomp%type;
    v_codpos        tbudget.codpos%type;
    v_dtereq        tbudget.dtereq%type;
    v_staappr       tbudget.staappr%type;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row   := hcm_util.get_json_t(param_json,to_char(i));
        v_flg            := hcm_util.get_string_t(param_json_row,'flg');
        v_dteyrbug       := hcm_util.get_string_t(param_json_row,'dteyrbug');
        v_codcomp        := hcm_util.get_string_t(param_json_row,'codcomp');
        v_codpos         := hcm_util.get_string_t(param_json_row,'codpos');
        v_dtereq         := to_date(hcm_util.get_string_t(param_json_row,'dtereq'),'dd/mm/yyyy');
        v_staappr        := hcm_util.get_string_t(param_json_row,'staappr');

        if v_flg = 'delete' then
          begin
            delete from tbudget
             where dteyrbug = v_dteyrbug
               and codcomp  = v_codcomp
               and codpos   = v_codpos
               and dtereq   = v_dtereq;
          end;
          begin
            delete from tbudgetm
             where dteyrbug = v_dteyrbug
               and codcomp  = v_codcomp
               and codpos   = v_codpos
               and dtereq   = v_dtereq;
          end;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  procedure post_detail(json_str_input in clob, json_str_output out clob) is
    param_json_qty        json_object_t;
    param_json_qty_row    json_object_t;
    param_json_budget     json_object_t;
    param_json_budget_row json_object_t;

    type arr_number_1d is table of number index by binary_integer;
      a_sumqty        arr_number_1d;
      a_sumbudget     arr_number_1d;
    type arr_number_2d is table of arr_number_1d index by binary_integer;
      a_qtydata       arr_number_2d;
      a_budgetdata    arr_number_2d;
  begin
    initial_value(json_str_input);

    param_json_qty    := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str_qty');
    param_json_budget := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str_budget');
    if param_msg_error is null then
      -- initial array
      for i in 1..param_json_budget.get_size loop
        for mth in 1..12 loop
          a_qtydata(i)(mth)    := 0;
          a_budgetdata(i)(mth) := 0;
        end loop;
        a_sumbudget(i)  := 0;
      end loop;

      -- qty
      for i in 0..param_json_qty.get_size-1 loop
        param_json_qty_row   := hcm_util.get_json_t(param_json_qty,to_char(i));
        for mth in 1..12 loop
          a_qtydata(i+1)(mth) := hcm_util.get_string_t(param_json_qty_row,'month'||to_char(mth));
          if a_qtydata(i+1)(mth) < 0 then
            param_msg_error := get_error_msg_php('HR2023',global_v_lang,to_char(a_qtydata(i+1)(mth),'fm999,990'));
            goto next_step;
          end if;
        end loop;
        a_sumqty(i+1)  := hcm_util.get_string_t(param_json_qty_row,'ytd');
      end loop;

      -- budget
      for i in 0..param_json_budget.get_size-1 loop
        param_json_budget_row   := hcm_util.get_json_t(param_json_budget,to_char(i));
        for mth in 1..12 loop
          a_budgetdata(i+1)(mth) := hcm_util.get_string_t(param_json_budget_row,'month'||to_char(mth));
          if a_budgetdata(i+1)(mth) < 0 then
            param_msg_error := get_error_msg_php('HR2023',global_v_lang,to_char(a_budgetdata(i+1)(mth),'fm999,990.90'));
            goto next_step;
          end if;
        end loop;
        a_sumbudget(i+1)  := hcm_util.get_string_t(param_json_budget_row,'ytd');
      end loop;

      -- validate qty of request tab and ytd of ratemonth tab
      if a_sumqty(2) <> p_qtynewn then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang,get_label_name('HRRP23EC3',global_v_lang,'100')||get_label_name('HRRP23EC3',global_v_lang,'60')||' '||to_char(a_sumqty(2),'fm999,990'));
        goto next_step;
      end if;
      if a_sumqty(3) <> p_qtypromoten then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang,get_label_name('HRRP23EC3',global_v_lang,'100')||get_label_name('HRRP23EC3',global_v_lang,'70')||' '||to_char(a_sumqty(3),'fm999,990'));
        goto next_step;
      end if;
      if a_sumqty(4) <> p_qtyretin then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang,get_label_name('HRRP23EC3',global_v_lang,'100')||get_label_name('HRRP23EC3',global_v_lang,'80')||' '||to_char(a_sumqty(4),'fm999,990'));
        goto next_step;
      end if;

      -- insert/update tbudgetm
      for mth in 1..12 loop
        begin
          insert into tbudgetm(dteyrbug,codcomp,codpos,dtereq,dtemthbug,
                              qtymonth,qtynew,qtypromote,qtyreti,qtybudgt,
                              amtsalmth,amthirebudgt,amtprobudgt,
                              amtresbudgt,amtother,amttotbudgt,
                              codcreate,coduser)
          values(b_index_dteyrbug,b_index_codcomp,b_index_codpos,b_index_dtereq,mth,
                 a_qtydata(1)(mth),a_qtydata(2)(mth),a_qtydata(3)(mth),a_qtydata(4)(mth),a_qtydata(5)(mth),
                 a_budgetdata(1)(mth),a_budgetdata(2)(mth),a_budgetdata(3)(mth),
                 a_budgetdata(4)(mth),a_budgetdata(6)(mth),a_budgetdata(5)(mth),
                 global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          update tbudgetm
             set qtymonth    = a_qtydata(1)(mth),
                 qtynew      = a_qtydata(2)(mth),
                 qtypromote  = a_qtydata(3)(mth),
                 qtyreti     = a_qtydata(4)(mth),
                 qtybudgt    = a_qtydata(5)(mth),
                 amtsalmth   = a_budgetdata(1)(mth),
                 amthirebudgt= a_budgetdata(2)(mth),
                 amtprobudgt = a_budgetdata(3)(mth),
                 amtresbudgt = a_budgetdata(4)(mth),
                 amtother    = a_budgetdata(6)(mth),
                 amttotbudgt = a_budgetdata(5)(mth),
                 dteedit     = sysdate,
                 codedit     = global_v_coduser,
                 codcreate   = global_v_coduser,
                 coduser     = global_v_coduser
           where dteyrbug    = b_index_dteyrbug
             and codcomp     = b_index_codcomp
             and codpos      = b_index_codpos
             and dtereq      = b_index_dtereq
             and dtemthbug   = mth;
        end;
      end loop;

      -- insert/update tbudget
      begin
        insert into tbudget(dteyrbug,codcomp,codpos,dtereq,
                            qtyreqyr,qtypromote,qtyreti,qtybudgt,
                            codemprq,remarkrq,staappr,
                            amtnewsal,amtavgsal,amtprosal,pctothbudgt,
                            amtsalbudgt,amthirebudgt,amtprobudgt,
                            amtresbudgt,amtothbudgt,amttotbudgt,
                            approvno,codcreate,coduser)
        values(b_index_dteyrbug,b_index_codcomp,b_index_codpos,b_index_dtereq,
               p_qtynewn,p_qtypromoten,p_qtyretin,p_qtybudgtn,
               b_index_codemprq,p_remarkrq,'P',
               p_newsalary,p_avgsalary,p_promsalary,p_other,
               a_sumbudget(1),a_sumbudget(2),a_sumbudget(3),
               a_sumbudget(4),a_sumbudget(6),a_sumbudget(5),
               0,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tbudget
           set qtyreqyr     = p_qtynewn,
               qtypromote   = p_qtypromoten,
               qtyreti      = p_qtyretin,
               qtybudgt     = p_qtybudgtn,
               codemprq     = nvl(codemprq,b_index_codemprq),
               remarkrq     = p_remarkrq,
               amtnewsal    = p_newsalary,
               amtavgsal    = p_avgsalary,
               amtprosal    = p_promsalary,
               pctothbudgt  = p_other,
               amtsalbudgt  = a_sumbudget(1),
               amthirebudgt = a_sumbudget(2),
               amtprobudgt  = a_sumbudget(3),
               amtresbudgt  = a_sumbudget(4),
               amtothbudgt  = a_sumbudget(6),
               amttotbudgt  = a_sumbudget(5)
         where dteyrbug     = b_index_dteyrbug
           and codcomp      = b_index_codcomp
           and codpos       = b_index_codpos
           and dtereq       = b_index_dtereq;
      end;

      <<next_step>>


      if param_msg_error is null then
        commit;
        send_mail_to_approve(b_index_dteyrbug,b_index_codcomp,b_index_codpos,b_index_dtereq);
        if param_msg_error_mail is not null then
            json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
            return;
        else
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        end if;
      else
        rollback;
      end if;
    end if;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_detail;

  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_rec_tran      number;
    v_rec_err       number;
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    format_text_json(json_str_input, v_rec_tran, v_rec_err);
    --
    if param_msg_error is null then
      obj_row    := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('rec_tran', v_rec_tran);
      obj_row.put('rec_err', v_rec_err);
      obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));

      if p_numseq.exists(p_numseq.first) then
        for i in p_numseq.first .. p_numseq.last
        loop
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_text(i));
          obj_data.put('error_code', p_error_code(i));
          obj_data.put('numseq', p_numseq(i) + 1);
          obj_result.put(to_char(v_rcnt-1),obj_data);
        end loop;
      end if;

      obj_row.put('datadisp', obj_result);

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    --
    data_file 		   varchar2(6000 char);
    v_column			   number := 4;
    v_error				   boolean;
    v_err_code  	   varchar2(1000 char);
    v_err_field  	   varchar2(1000 char);
    v_err_table		   varchar2(20 char);
    --
    v_month 			   varchar2(1000 char);
    v_qtynew		     varchar2(1000 char);
    v_qtypromote 		 varchar2(1000 char);
    v_qtyreti  		   varchar2(1000 char);

    v_flgfound  	   boolean;
    v_cnt					   number := 0;
    v_num            number := 0;
    v_concat         varchar2(10 char);

    type text is table of varchar2(1000 char) index by binary_integer;
      v_text   text;
      v_field  text;
      v_key    text;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_field(i) := null;
      v_key(i)   := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
      v_key(v_num)      := hcm_util.get_string_t(param_column_row,'key');
    end loop;
    --
    for rw in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(rw));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_error 	  := false;
        --
        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,v_key(1));  -- month
          v_text(2)   := hcm_util.get_string_t(param_json_row,v_key(2));  -- qtynew
          v_text(3)   := hcm_util.get_string_t(param_json_row,v_key(3));  -- qtypromote
          v_text(4)   := hcm_util.get_string_t(param_json_row,v_key(4));  -- qtyreti

          -- push row values
          data_file := null;
          v_concat := null;
          for i in 1..v_column loop
            data_file := data_file||v_concat||v_text(i);
            v_concat  := ',';
          end loop;

          -- check null
          if v_text(1) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;

          --1.month
          if v_text(1) <> rw + 1 then
            v_error     := true;
            v_err_code  := 'HR2020';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;

          --2.qtynew
          if v_text(2) < 0 then
            v_error     := true;
            v_err_code  := 'HR2023' ;
            v_err_table := 'TBUDGETM';
            v_err_field := v_field(2);
            exit cal_loop;
          end if;
          if v_text(2) > 9999 then
            v_error     := true;
            v_err_code  := 'HR6591' ;
            v_err_table := 'TBUDGETM';
            v_err_field := v_field(2);
            exit cal_loop;
          end if;

          --3.qtypromote
          if v_text(3) < 0 then
            v_error     := true;
            v_err_code  := 'HR2023' ;
            v_err_table := 'TBUDGETM';
            v_err_field := v_field(3);
            exit cal_loop;
          end if;
          if v_text(3) > 9999 then
            v_error     := true;
            v_err_code  := 'HR6591' ;
            v_err_table := 'TBUDGETM';
            v_err_field := v_field(3);
            exit cal_loop;
          end if;

          --4.qtyreti
          if v_text(4) < 0 then
            v_error     := true;
            v_err_code  := 'HR2023' ;
            v_err_table := 'TBUDGETM';
            v_err_field := v_field(4);
            exit cal_loop;
          end if;
          if v_text(4) > 9999 then
            v_error     := true;
            v_err_code  := 'HR6591' ;
            v_err_table := 'TBUDGETM';
            v_err_field := v_field(4);
            exit cal_loop;
          end if;

          exit cal_loop;
        end loop; -- cal_loop

        -- update status
        if not v_error then
          v_rec_tran := v_rec_tran + 1;
        else
          v_rec_error     := v_rec_error + 1;
          v_cnt           := v_cnt+1;

          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||' ['||v_err_field||']';
          p_numseq(v_cnt)     := rw;
        end if;--not v_error

      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;

  procedure send_mail_to_approve(para_dteyrbug   tbudget.dteyrbug%type,
                                 para_codcomp    tbudget.codcomp%type,
                                 para_codpos     tbudget.codpos%type,
                                 para_dtereq     tbudget.dtereq%type) is
    v_codapp        varchar2(100) := 'HRRP23E';
    v_o_msg_to      clob;
    v_template_to   clob;
    v_func_appr     clob;
    v_codform       tfwmailh.codform%type;
    v_rowid         varchar2(1000);
    v_subject_label varchar2(200);
    v_error         varchar2(100);

    v_item          varchar2(500) := 'item1,item2,item3,item4';
    v_label         varchar2(500) := 'label1,label2,label3,label4';
    v_file_name     varchar2(500) := 'HRRP2AU';
    para_codemprq   tbudget.codemprq%type;
    para_approvno   tbudget.approvno%type;
    v_tbudget       tbudget%rowtype;
  begin
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP23E';
    delete from ttempprm where codempid = global_v_codempid and codapp = 'HRRP23E';
    insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                          label1,label2,label3,label4)
    values(global_v_codempid,'HRRP23E','HRRP23E',to_char(sysdate,'dd/mm/yyyy'),'page1',
           get_label_name('HRRP2AU1',global_v_lang,50),
           get_label_name('HRRP2AU1',global_v_lang,60),
           get_label_name('HRRP2AU1',global_v_lang,70),
           get_label_name('HRRP2AU1',global_v_lang,80));
    begin
      select *
        into v_tbudget
        from tbudget r1
       where dteyrbug   = para_dteyrbug
         and codcomp    = para_codcomp
         and codpos     = para_codpos
         and dtereq     = para_dtereq;
    exception when no_data_found then
      v_tbudget := null;
    end;

    insert into ttemprpt (codempid,codapp,numseq,
                          item1,item2,item3,item4)
    values(global_v_codempid,'HRRP23E',1,
           get_tcenter_name(v_tbudget.codcomp,global_v_lang),
           get_tpostn_name(v_tbudget.codpos,global_v_lang),
           v_tbudget.qtyreqyr,to_char(v_tbudget.amttotbudgt,'fm999,999,999,990.00'));
      --

    v_file_name     := global_v_codempid||'_'||to_char(sysdate,'yyyymmddhh24miss');
    excel_mail(v_item,v_label,null,global_v_codempid,'HRRP23E',v_file_name);
    --
    begin
      select rowid
        into v_rowid
        from tbudget
       where dteyrbug   = para_dteyrbug
         and codcomp    = para_codcomp
         and codpos     = para_codpos
         and dtereq     = para_dtereq;
    exception when no_data_found then
      null;
    end;

    begin
        v_error := chk_flowmail.send_mail_for_approve('HRRP23E', v_tbudget.codemprq, global_v_codempid, global_v_coduser, v_file_name, 'HRRP2AU2', 900, 'E', 'P', 1, null, null,'TBUDGET',v_rowid, '1', 'Oracle');
    EXCEPTION WHEN OTHERS THEN
        null;
    END;

    IF v_error in ('2046','2402') THEN
      param_msg_error_mail := get_error_msg_php('HR2402', global_v_lang);
    ELSE
      param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
    end if;
  end;
end hrrp23e;

/
