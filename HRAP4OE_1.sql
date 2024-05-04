--------------------------------------------------------
--  DDL for Package Body HRAP4OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP4OE" AS
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap    := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_pctsal            := to_number(hcm_util.get_string_t(json_obj,'p_pctsal'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_row_child   json_object_t;
    obj_data_child  json_object_t;
    obj_result      json_object_t;
    obj_child       json_object_t;
    obj_child_detail    json_object_t;
    obj_child_table     json_object_t;

    v_dteappr       tapbudgt.dteappr%TYPE;
    v_codappr       tapbudgt.codappr%TYPE;
    v_lstupd        tapbudgt.dteupd%TYPE;
    v_coduser       tapbudgt.coduser%TYPE;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_response      varchar2(1000 char);
    v_flgexist      boolean := false;

    v_codcomp       tapbudgtd.codcomp%TYPE;
    v_jobgrade      tsalstr.jobgrade%TYPE;
    v_midpoint      tsalstr.midpoint%TYPE;
    v_pctsal        tapbudgt.pctsal%TYPE;
    v_sumbudg       number := 0;
    v_totalemp      number := 0;
    cursor c1 is
      select codcomp, pctsal, qtyemp, amtbudg, dteappr, codappr
        from tapbudgt
       where codcomp like b_index_codcompy||'%'
         and dteyreap = b_index_dteyreap
       order by codcomp;

    cursor c2 is
      select jobgrade, qtyemp, midpoint ,amtbudg
       from  tapbudgtd
       where codcomp = v_codcomp
         and dteyreap = b_index_dteyreap
       order by jobgrade;

    cursor c3 is
      select jobgrade, count(*) qtyemp
        from temploy1 a
       where a.codcomp = get_compful(v_codcomp)
         and a.staemp in ('1','3') --User37 #3774 AP - PeoplePlus 19/02/2021 a.staemp <> '9'
         and a.jobgrade in (select b.jobgrade
                              from tsalstr b
                             where b.codcompy = b_index_codcompy
                               and b.dteyreap =(select max(c.dteyreap)
                                                from tsalstr c
                                                where c.codcompy = b.codcompy
                                                and c.dteyreap <=  b_index_dteyreap))
   group by jobgrade
   order by jobgrade;
  begin
    obj_row := json_object_t();
--    check_yreeffec;
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('pctsal', i.pctsal);
      obj_data.put('qtyemp', i.qtyemp);
      obj_data.put('amtbudg', i.amtbudg);

      v_dteappr := i.dteappr;
      v_codappr := i.codappr;
      v_codcomp := i.codcomp;
      for r2 in c2 loop
        v_flgexist := true;
        exit;
      end loop;
      v_rcnt2 := 0;
      v_sumbudg := 0;
      v_totalemp := 0;
      obj_row_child := json_object_t();
      if v_flgexist then
        for r2 in c2 loop
          v_rcnt2 := v_rcnt2+1;
          obj_data_child := json_object_t();
          obj_data_child.put('coderror', '200');
          obj_data_child.put('jobgrade', r2.jobgrade);
          obj_data_child.put('desc_jobgrade', get_tcodec_name('TCODJOBG',r2.jobgrade,global_v_lang));
          obj_data_child.put('qtyemp', r2.qtyemp);
          obj_data_child.put('midpoint', r2.midpoint);
          if r2.amtbudg is not null and r2.amtbudg <>0 then
            obj_data_child.put('amtbudg', r2.amtbudg);
          else
            obj_data_child.put('amtbudg', ((i.pctsal/100) * r2.midpoint)+r2.midpoint);
          end if;

          v_sumbudg := v_sumbudg + r2.amtbudg;
          v_totalemp := v_totalemp + r2.qtyemp;
          obj_row_child.put(to_char(v_rcnt2-1),obj_data_child);
        end loop;
      else
        for r3 in c3 loop
          v_rcnt2 := v_rcnt2+1;
          obj_data_child := json_object_t();
          obj_data_child.put('coderror', '200');
          obj_data_child.put('jobgrade', r3.jobgrade);
          obj_data_child.put('desc_jobgrade', get_tcodec_name('TCODJOBG',r3.jobgrade,global_v_lang));
          obj_data_child.put('qtyemp', r3.qtyemp);
          begin
            select b.jobgrade, b.midpoint into v_jobgrade, v_midpoint
            from tsalstr b
            where b.codcompy = b_index_codcompy
            and b.jobgrade = r3.jobgrade
            and b.dteyreap = (select max(c.dteyreap)
                              from tsalstr c
                              where c.codcompy = b.codcompy
                              and c.dteyreap = b_index_dteyreap);
          exception when no_data_found then null;
          end;
          obj_data_child.put('midpoint', v_midpoint);
          obj_data_child.put('amtbudg', '');

          v_sumbudg := v_sumbudg + 0;
          v_totalemp := v_totalemp + r3.qtyemp;
          obj_row_child.put(to_char(v_rcnt2-1),obj_data_child);
        end loop;
      end if;
      begin
        select pctsal into v_pctsal
          from tapbudgt
         where codcomp = v_codcomp
           and dteyreap = b_index_dteyreap;
      exception when no_data_found then null;
      end;
      obj_child := json_object_t();
      obj_child.put('codcomp', v_codcomp);
      obj_child.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
      obj_child.put('pctsal', v_pctsal);
      obj_child.put('sumbudg', v_sumbudg);
      obj_child.put('totalemp', v_totalemp);
      --
      obj_child_table := json_object_t();
      obj_child_table.put('rows', obj_row_child);
      --
      obj_child_detail := json_object_t();
      obj_child_detail.put('detail', obj_child);
      obj_child_detail.put('table', obj_child_table);
      --
      obj_data.put('children', obj_child_detail);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    begin
       select dteupd,coduser  into v_lstupd, v_coduser
        from (select *
                from tapbudgt
               where codcomp like b_index_codcompy||'%'
                 and dteyreap = b_index_dteyreap
               order by dteupd desc)
        where rownum=1;
    exception when no_data_found then null;
    end;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('dteappr', to_char(nvl(v_dteappr,sysdate),'dd/mm/yyyy'));
    obj_result.put('codappr', v_codappr);
    obj_result.put('dteupd', to_char(v_lstupd,'dd/mm/yyyy'));
    obj_result.put('codupd', get_codempid(v_coduser));
    obj_result.put('desc_codupd', get_temploy_name(get_codempid(v_coduser), global_v_lang));
    obj_result.put('table', obj_row);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcompy   varchar2(4 char);
  begin
    if b_index_codcompy is not null then
      begin
        select codcompy into v_codcompy
          from tcompny
         where codcompy = b_index_codcompy
           and rownum = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCOMPNY');
        return;
      end;
      if not secur_main.secur7(b_index_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
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
  --
  procedure gen_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_dteappr       tapbudgt.dteappr%TYPE;
    v_codappr       tapbudgt.codappr%TYPE;
    v_lstupd        tapbudgt.dteupd%TYPE;
    v_coduser       tapbudgt.coduser%TYPE;
    v_pctsal        tapbudgt.pctsal%TYPE;
    v_jobgrade      tsalstr.jobgrade%TYPE;
    v_midpoint      tsalstr.midpoint%TYPE;

    v_codcomp       tapbudgt.codcomp%TYPE;
    v_formusal      tapbudgt.formusal%TYPE;
    v_flggrade      tapbudgt.flggrade%TYPE;
    v_data_formusal tapbudgt.formusal%TYPE;
    v_rcnt          number := 0;
    v_flgexist      boolean := false;
    v_response      varchar2(1000 char);
    v_sumbudg       number := 0;
    v_totalemp      number := 0;

    cursor c1 is
      select jobgrade, qtyemp, midpoint ,amtbudg
       from  tapbudgtd
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap
       order by jobgrade;

    cursor c2 is
      select jobgrade, count(*) qtyemp
        from temploy1 a
       where a.codcomp = get_compful(b_index_codcomp)
         and a.staemp in ('1','3')--User37 #3774 AP - PeoplePlus 19/02/2021 a.staemp <> '9'
         and a.jobgrade in (select b.jobgrade
                              from tsalstr b
                             where b.codcompy = b_index_codcompy
                               and b.dteyreap =(select max(c.dteyreap)
                                                from tsalstr c
                                                where c.codcompy = b.codcompy
                                                and c.dteyreap <=  b_index_dteyreap))
   group by jobgrade
   order by jobgrade;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_flgexist := true;
      exit;
    end loop;
    if v_flgexist then
      for i in c1 loop
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('jobgrade', i.jobgrade);
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang));
        obj_data.put('qtyemp', i.qtyemp);
        obj_data.put('midpoint', i.midpoint);
        obj_data.put('amtbudg', i.amtbudg);

        v_sumbudg := v_sumbudg + i.amtbudg;
        v_totalemp := v_totalemp + i.qtyemp;
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    else
      for i in c2 loop
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('jobgrade', i.jobgrade);
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang));
        obj_data.put('qtyemp', i.qtyemp);
        begin
          select b.jobgrade, b.midpoint into v_jobgrade, v_midpoint
          from tsalstr b
          where b.codcompy = b_index_codcompy
          and b.jobgrade = i.jobgrade
          and b.dteyreap = (select max(c.dteyreap)
                            from tsalstr c
                            where c.codcompy = b.codcompy
                            and c.dteyreap = b_index_dteyreap);
        exception when no_data_found then null;
        end;
        obj_data.put('midpoint', v_midpoint);
        obj_data.put('amtbudg', '');

        v_sumbudg := v_sumbudg + 0;
        v_totalemp := v_totalemp + i.qtyemp;
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    begin
      select pctsal into v_pctsal
        from tapbudgt
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap;
    exception when no_data_found then null;
    end;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('codcomp', b_index_codcomp);
    obj_result.put('desc_codcomp', get_tcenter_name(b_index_codcomp,global_v_lang));
    obj_result.put('pctsal', v_pctsal);
    obj_result.put('sumbudg', v_sumbudg);
    obj_result.put('totalemp', v_totalemp);
    obj_result.put('table', obj_row);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_drilldown(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_pctsal        tapbudgt.pctsal%type;
    v_pctsalt       tapbudgt.pctsalt%type;
    v_qtyemp        tapbudgt.qtyemp%type;
    v_qtyempt       tapbudgt.qtyempt%type;
    v_diff          number := 0;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
  begin
    begin
      select pctsal,pctsalt,qtyemp,qtyempt into v_pctsal, v_pctsalt, v_qtyemp, v_qtyempt
        from tapbudgt a
       where a.codcomp = b_index_codcomp
         and a.dteyreap = (select max(b.dteyreap)
                             from tapbudgt b
                            where b.codcomp = a.codcomp
                              and b.dteyreap < b_index_dteyreap);
    exception when no_data_found then
      v_pctsal := 0; v_pctsalt := 0; v_qtyemp := 0; v_qtyempt := 0;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_codcomp', get_tcenter_name(b_index_codcomp, global_v_lang));
    obj_data.put('year', b_index_dteyreap - 1);
    obj_data.put('pctsal', to_char(v_pctsal,'fm990.00'));
    obj_data.put('pctsalt', to_char(v_pctsalt,'fm990.00'));
    obj_data.put('qtyempt', v_qtyempt);
    v_diff := v_pctsalt - v_pctsal;
    obj_data.put('difference', to_char(v_diff,'fm990.00'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_drilldown(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_drilldown(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure cal_budget(json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_dteappr       tapbudgt.dteappr%TYPE;
    v_codappr       tapbudgt.codappr%TYPE;
    v_lstupd        tapbudgt.dteupd%TYPE;
    v_coduser       tapbudgt.coduser%TYPE;
    v_pctsal        tapbudgt.pctsal%TYPE;
    v_jobgrade      tsalstr.jobgrade%TYPE;
    v_midpoint      tsalstr.midpoint%TYPE;

    v_codcomp       tapbudgt.codcomp%TYPE;
    v_formusal      tapbudgt.formusal%TYPE;
    v_flggrade      tapbudgt.flggrade%TYPE;
    v_data_formusal tapbudgt.formusal%TYPE;
    v_stment        varchar2(4000 char);
    v_amtsvyr       number := 0;
    v_amtbudg       number := 0;
    v_sumbudg       number := 0;
    v_totalemp      number := 0;
    v_rcnt          number := 0;
    v_flgexist      boolean := false;
    v_response      varchar2(1000 char);
    v_qtyemp        number := 0;

    cursor c1 is
      select jobgrade, qtyemp, midpoint ,amtbudg
       from  tapbudgtd
       where codcomp  = b_index_codcomp
         and dteyreap = b_index_dteyreap
       order by jobgrade;

    cursor c2 is
      select jobgrade, count(*) qtyemp
        from temploy1 a
       where a.codcomp = get_compful(b_index_codcomp)
         and a.staemp in ('1','3')--User37 #3774 AP - PeoplePlus 19/02/2021 a.staemp <> '9'
         and a.jobgrade in (select b.jobgrade
                              from tsalstr b
                             where b.codcompy = b_index_codcompy
                               and b.dteyreap =(select max(c.dteyreap)
                                                from tsalstr c
                                                where c.codcompy = b.codcompy
                                                and c.dteyreap <=  b_index_dteyreap))
       group by jobgrade
       order by jobgrade;

    cursor c3 is
      select codcomp,formusal,flggrade
        from tapbudgt a
       where ( b_index_codcomp like a.codcomp||'%' or
               a.codcomp like b_index_codcomp ||'%'   )
         and a.dteyreap = b_index_dteyreap
       order by codcomp desc;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c1 loop
      v_flgexist := true;
      exit;
    end loop;
    if v_flgexist then
      for i in c1 loop
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('jobgrade', i.jobgrade);
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang));
        obj_data.put('qtyemp', i.qtyemp);
        obj_data.put('midpoint', i.midpoint);
--        begin
--          select codcomp,formusal,flggrade into v_codcomp, v_formusal, v_flggrade
--            from tapbudgt a
--          where b_index_codcomp like a.codcomp||'%'
--           and a.dteyreap = b_index_dteyreap
--           order by codcomp desc;
--        exception when no_data_found then null;
--        end;
        for r3 in c3 loop
          if r3.formusal is not null then
            v_formusal := r3.formusal;
            exit;
          end if;
        end loop;
        begin
          select sum(stddec(b.amtincom1,b.codempid,v_chken)),count(*)  into v_amtsvyr,v_qtyemp
            from temploy1 c,temploy3 b
           where c.codempid = b.codempid
             and c.codcomp = get_compful(b_index_codcomp)
             and c.jobgrade = i.jobgrade
             and c.staemp in ('1','3')--User37 #3774 AP - PeoplePlus 19/02/2021 c.staemp <> '9'
             and c.jobgrade in (select b.jobgrade
                                from tsalstr b
                                where b.codcompy = b_index_codcompy
                                and b.dteyreap =(select max(d.dteyreap)
                                                from tsalstr d
                                                where d.codcompy = b.codcompy
                                                and d.dteyreap <=  b_index_dteyreap)) ;

        exception when no_data_found then
          v_amtsvyr := 0;
        end;
        begin
          select b.jobgrade, b.midpoint  into v_jobgrade, v_midpoint
          from tsalstr b
          where b.codcompy = b_index_codcompy
          and b.jobgrade = i.jobgrade
          and b.dteyreap = (select max(c.dteyreap)
                            from tsalstr c
                            where c.codcompy = b.codcompy
                            and c.dteyreap = b_index_dteyreap);
        exception when no_data_found then null;
        end;
        v_midpoint := v_midpoint * v_qtyemp ;

        v_data_formusal := v_formusal;
        /*
        v_data_formusal := replace(v_data_formusal,'{[AMTSAL]}', v_amtsvyr);
        v_data_formusal := replace(v_data_formusal,'{[AMTINC]}', to_char(p_pctsal/100));
        v_data_formusal := replace(v_data_formusal,'{[AMTMID]}', v_midpoint);
        */
        v_data_formusal := replace(v_data_formusal,'BASICSALARY', v_amtsvyr);
        v_data_formusal := replace(v_data_formusal,'PCTINCR', (p_pctsal));
        v_data_formusal := replace(v_data_formusal,'MITPOINT', v_midpoint);

        v_stment    := 'select '||v_data_formusal||' from dual ';
        v_amtbudg   :=  execute_qty(v_stment);


        --chai
        --v_amtbudg    := v_amtsvyr * (p_pctsal/100) ;
        v_amtbudg   := round(v_amtbudg,2);



        obj_data.put('amtbudg', v_amtbudg);
        v_sumbudg := v_sumbudg + v_amtbudg;
        v_totalemp := v_totalemp + i.qtyemp;
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    else
      for i in c2 loop
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('jobgrade', i.jobgrade);
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang));
        obj_data.put('qtyemp', i.qtyemp);
        begin
          select b.jobgrade, b.midpoint into v_jobgrade, v_midpoint
          from tsalstr b
          where b.codcompy = b_index_codcompy
          and b.jobgrade = i.jobgrade
          and b.dteyreap = (select max(c.dteyreap)
                            from tsalstr c
                            where c.codcompy = b.codcompy
                            and c.dteyreap = b_index_dteyreap);
        exception when no_data_found then null;
        end;
        obj_data.put('midpoint', v_midpoint);
--        begin
--          select codcomp,formusal,flggrade into v_codcomp, v_formusal, v_flggrade
--            from tapbudgt a
--          where b_index_codcomp like a.codcomp||'%'
--           and a.dteyreap = b_index_dteyreap
--           order by codcomp desc;
--        exception when no_data_found then null;
--        end;
        for r3 in c3 loop
          if r3.formusal is not null then
            v_formusal := r3.formusal;
            exit;
          end if;
        end loop;
        begin
          select sum(stddec(b.amtincom1,b.codempid,v_chken)),count(*) into v_amtsvyr ,v_qtyemp
            from temploy1 c,temploy3 b
           where c.codempid = b.codempid
             and c.codcomp = get_compful(b_index_codcomp)
             and c.jobgrade = i.jobgrade
             and c.staemp in ('1','3')--User37 #3774 AP - PeoplePlus 19/02/2021 c.staemp <> '9'
             and c.jobgrade in (select b.jobgrade
                                from tsalstr b
                                where b.codcompy = b_index_codcompy
                                and b.dteyreap =(select max(d.dteyreap)
                                                from tsalstr d
                                                where d.codcompy = b.codcompy
                                                and d.dteyreap <=  b_index_dteyreap)) ;

        exception when no_data_found then
          v_amtsvyr := 0;
        end;
        v_data_formusal := v_formusal;
        /*
        v_data_formusal := replace(v_data_formusal,'{[AMTSAL]}', v_amtsvyr);
        v_data_formusal := replace(v_data_formusal,'{[AMTINC]}', to_char(p_pctsal/100));
        v_data_formusal := replace(v_data_formusal,'{[AMTMID]}', v_midpoint);
        */

        v_midpoint := v_midpoint * v_qtyemp ;

        v_data_formusal := replace(v_data_formusal,'BASICSALARY', v_amtsvyr);
        v_data_formusal := replace(v_data_formusal,'PCTINCR', (p_pctsal));
        v_data_formusal := replace(v_data_formusal,'MITPOINT', v_midpoint);

        v_stment    := 'select '||v_data_formusal||' from dual ';
        --chai
        v_amtbudg   := execute_qty(v_stment);
        --v_amtbudg    := v_amtsvyr * (p_pctsal/100) ;

        v_amtbudg   := round(v_amtbudg,2);

        obj_data.put('amtbudg',  v_amtbudg);
        v_sumbudg := v_sumbudg + v_amtbudg;
        v_totalemp := v_totalemp + i.qtyemp;
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('codcomp', b_index_codcomp);
    obj_result.put('desc_codcomp', get_tcenter_name(b_index_codcomp,global_v_lang));
    obj_result.put('pctsal', p_pctsal);
    obj_result.put('sumbudg', v_sumbudg);
    obj_result.put('totalemp', v_totalemp);
    obj_result.put('table', obj_row);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
   --
  procedure check_save(json_str_input in clob) is
    param_json        json_object_t;
    param_json_row    json_object_t;
    obj_detail        json_object_t;

    v_dteappr       tapbudgt.dteappr%TYPE;
    v_codappr       tapbudgt.codappr%TYPE;
    v_dteupd        tapbudgt.dteupd%TYPE;
    v_coduser       tapbudgt.coduser%TYPE;
    v_codcomp       tapbudgt.codcomp%TYPE;
    v_pctsal        tapbudgt.pctsal%TYPE;
    v_staemp        temploy1.staemp%TYPE;
  begin
    obj_detail    := hcm_util.get_json_t(json_object_t(json_str_input),'detail');
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');

    b_index_codcompy    := hcm_util.get_string_t(obj_detail,'codcompy');
    b_index_dteyreap    := to_number(hcm_util.get_string_t(obj_detail,'dteyear'));
    v_dteappr           := to_date(hcm_util.get_string_t(obj_detail,'dteappr'),'dd/mm/yyyy');
    v_codappr           := hcm_util.get_string_t(obj_detail,'codappr');
    begin
      select staemp into v_staemp
      from temploy1
      where codempid = v_codappr;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
      return;
    end;
    if v_staemp = '9' then
      param_msg_error := get_error_msg_php('HR2101',global_v_lang);
      return;
    end if;
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_pctsal        := hcm_util.get_string_t(param_json_row,'pctsal');
      if v_pctsal is null then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang);
        exit;
      end if;
    end loop;
  end;
  --
  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json        json_object_t;
    param_json_row    json_object_t;
    obj_detail        json_object_t;
    obj_child         json_object_t;
    param_child       json_object_t;
    param_child_row   json_object_t;

    v_flg	          varchar2(1000 char);
    v_dteappr       tapbudgt.dteappr%TYPE;
    v_codappr       tapbudgt.codappr%TYPE;
    v_dteupd        tapbudgt.dteupd%TYPE;
    v_coduser       tapbudgt.coduser%TYPE;
    v_codcomp       tapbudgt.codcomp%TYPE;
    v_pctsal        tapbudgt.pctsal%TYPE;
    v_qtyemp        tapbudgt.qtyemp%TYPE;
    v_amtbudg       tapbudgt.amtbudg%TYPE;
    v_flgDelete     boolean;

    v_child_jobgrade  tapbudgtd.jobgrade%type;
    v_child_qtyemp    tapbudgtd.qtyemp%type;
    v_child_amtbudg   tapbudgtd.amtbudg%type;
    v_child_midpoint  tapbudgtd.midpoint%type;
  begin
    initial_value(json_str_input);
    check_save(json_str_input);

    obj_detail    := hcm_util.get_json_t(json_object_t(json_str_input),'detail');
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');

    b_index_codcompy    := hcm_util.get_string_t(obj_detail,'codcompy');
    b_index_dteyreap    := to_number(hcm_util.get_string_t(obj_detail,'dteyear'));
    v_dteappr           := to_date(hcm_util.get_string_t(obj_detail,'dteappr'),'dd/mm/yyyy');
    v_codappr           := hcm_util.get_string_t(obj_detail,'codappr');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_codcomp   := hcm_util.get_string_t(param_json_row,'codcomp');
        v_pctsal    := hcm_util.get_string_t(param_json_row,'pctsal');
        v_qtyemp    := hcm_util.get_string_t(param_json_row,'qtyemp');
        v_amtbudg   := hcm_util.get_string_t(param_json_row,'amtbudg');
        v_flgDelete := hcm_util.get_boolean_t(param_json_row,'flgDelete');

        begin
          insert into tapbudgt(dteyreap, codcomp, pctsal, qtyemp, amtbudg, dteappr, codappr, codcreate, coduser)
          values (b_index_dteyreap, v_codcomp, v_pctsal, v_qtyemp, v_amtbudg, v_dteappr, v_codappr, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          begin
            update tapbudgt
               set pctsal = v_pctsal,
                   qtyemp = v_qtyemp,
                   amtbudg = v_amtbudg,
                   dteappr = v_dteappr,
                   codappr = v_codappr,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where dteyreap = b_index_dteyreap
               and codcomp = v_codcomp;
          end;
        end;

        obj_child := hcm_util.get_json_t(param_json_row,'children');
        param_child := hcm_util.get_json_t(hcm_util.get_json_t(obj_child,'table'),'rows');

        for j in 0..param_child.get_size-1 loop
          param_child_row   := hcm_util.get_json_t(param_child,to_char(j));
          v_child_jobgrade  := hcm_util.get_string_t(param_child_row,'jobgrade');
          v_child_qtyemp    := hcm_util.get_string_t(param_child_row,'qtyemp');
          v_child_amtbudg   := hcm_util.get_string_t(param_child_row,'amtbudg');
          v_child_midpoint  := hcm_util.get_string_t(param_child_row,'midpoint');

          begin
            insert into tapbudgtd(dteyreap, codcomp, jobgrade, midpoint, qtyemp, amtbudg, codcreate, coduser)
            values (b_index_dteyreap, v_codcomp, v_child_jobgrade, v_child_midpoint, v_child_qtyemp, v_child_amtbudg, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            begin
              update tapbudgtd
                 set midpoint = v_child_midpoint,
                     qtyemp = v_child_qtyemp,
                     amtbudg = v_child_amtbudg,
                     dteupd = sysdate,
                     coduser = global_v_coduser
               where dteyreap = b_index_dteyreap
                 and codcomp = v_codcomp
                 and jobgrade = v_child_jobgrade;
            end;
          end;
        end loop;

        if v_flgDelete then
          begin
            delete tapbudgt where codcomp = v_codcomp and dteyreap = b_index_dteyreap;
            delete tapbudgtd where codcomp = v_codcomp and dteyreap = b_index_dteyreap;
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
END HRAP4OE;

/
