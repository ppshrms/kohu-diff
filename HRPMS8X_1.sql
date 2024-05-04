--------------------------------------------------------
--  DDL for Package Body HRPMS8X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMS8X" is
-- last update: 09/02/2021 17:30 redmine3020

  procedure initial_value (json_str in clob) is
      json_obj   json_object_t := json_object_t(json_str);
  begin
      global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
      global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
      global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

      p_dteyrbug          := hcm_util.get_string_t(json_obj,'p_dteyrbug');
      p_syncond           := hcm_util.get_string_t(json_obj,'p_syncond');
      numyearreport       := hcm_appsettings.get_additional_year();
      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
      v_codcomp         varchar2(100);
      v_codcomp1        varchar2(100);
      v_secur_codcomp   boolean;
  begin
    if p_dteyrbug is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
--    if p_syncond is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--      return;
--    end if;
  end;
  procedure get_json_obj ( json_str_input in clob ) is
  begin
    if json_str_input is not null then
        p_codcomp_array := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str') );
    end if;
  end get_json_obj;

  procedure insert_treppms8x is
      v_codcomp         varchar2(100);
      v_count           number;
      v_flg             varchar2(10);
      json_param_obj    json_object_t;--user37 #3604 Final Test Phase 1 V11 01/02/2021
      v_flgaed          boolean;
  begin
    json_param_obj        := hcm_util.get_json_t(p_codcomp_array,'rows');--user37 #3604 Final Test Phase 1 V11 01/02/2021
    for i in 0..json_param_obj.get_size - 1 loop--user37 #3604 Final Test Phase 1 V11 01/02/2021 for i in 0..p_codcomp_array.get_size - 1 loop
      param_json_row  := hcm_util.get_json_t(json_param_obj,to_char(i));--user37 #3604 Final Test Phase 1 V11 01/02/2021 json_object_t(p_codcomp_array.get(to_char(i) ) );
      v_count         := 0;
      v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
      --<<user37 #3604 Final Test Phase 1 V11 01/02/2021
      --user37 #3604 Final Test Phase 1 V11 01/02/2021 v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      v_flgaed        := hcm_util.get_boolean_t(param_json_row,'flgDelete');
      if v_flgaed then
        v_flg := 'N';
      else
        v_flg := 'Y';
      end if;
      -->>user37 #3604 Final Test Phase 1 V11 01/02/2021
      --User37 #3605 Final Test Phase 1 V11 09/12/2020 if v_flg = 'add' then
        if v_flg = 'Y' then
        select count(*) into v_count
          from treppms8x
         where coduser = global_v_coduser
           and codcomp = v_codcomp
           and dteyear = p_dteyrbug;

        if v_count = 0 then
            insert into treppms8x
                 values ( global_v_coduser, p_dteyrbug, v_codcomp, sysdate, global_v_coduser, sysdate );
        end if;
        end if;
      --User37 #3605 Final Test Phase 1 V11 09/12/2020 end if;
    end loop;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end insert_treppms8x;

  procedure delete_treppms8x is
    v_codcomp       varchar2(100);
    v_flg           varchar2(10);
    v_count         number;
    json_param_obj  json_object_t;--user37 #3604 Final Test Phase 1 V11 01/02/2021
  begin
    json_param_obj        := hcm_util.get_json_t(p_codcomp_array,'rows');--user37 #3604 Final Test Phase 1 V11 01/02/2021
    for i in 0..json_param_obj.get_size - 1 loop--user37 #3604 Final Test Phase 1 V11 01/02/2021 for i in 0..p_codcomp_array.get_size - 1 loop
      param_json_row  := hcm_util.get_json_t(json_param_obj,to_char(i));--user37 #3604 Final Test Phase 1 V11 01/02/2021 json_object_t(p_codcomp_array.get(to_char(i) ) );
      v_count         := 0;
      v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
      --user37 #3604 Final Test Phase 1 V11 01/02/2021 v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      --User37 #3605 Final Test Phase 1 V11 09/12/2020 if v_flg = 'delete' then
        delete from treppms8x
         where coduser = global_v_coduser
           --User37 #3605 Final Test Phase 1 V11 09/12/2020 and codcomp = v_codcomp
           and dteyear = p_dteyrbug;
      --User37 #3605 Final Test Phase 1 V11 09/12/2020 end if;
    end loop;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end delete_treppms8x;

  procedure gen_treppms8x ( json_str_output out clob ) is
    v_rcnt   number;
    v_secur_codcomp boolean;
    cursor c_treppms8x is
      select coduser, codcomp
        from treppms8x
       where coduser = global_v_coduser
         and dteyear = p_dteyrbug
       order by codcomp;
  begin
    obj_row := json_object_t ();
    v_rcnt  := 0;
    for i in c_treppms8x loop
      v_secur_codcomp := secur_main.secur7(i.codcomp,global_v_coduser);
      if v_secur_codcomp then
        v_rcnt    := v_rcnt + 1;
        obj_data  := json_object_t ();
        obj_data.put('coderror','200');
        obj_data.put('coduser',i.coduser);
        obj_data.put('codcomp',i.codcomp);
        obj_row.put(to_char(v_rcnt - 1),obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
--    dbms_lob.createtemporary(json_str_output,true);
--    obj_row.to_clob(json_str_output);

  exception when no_data_found then
    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'treppms8x');
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_getindex is
      v_codcomp         varchar2(100);
      v_codcomp1        varchar2(100);
      v_secur_codcomp   boolean;
      v_flg       varchar2(100);--User37 #3608 Final Test Phase 1 V11 09/12/2020
  begin
    if p_dteyrbug is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;

    --<<User37 #3608 Final Test Phase 1 V11 09/12/2020
    /*for i in 0..p_codcomp_array.get_size - 1 loop
      pjson_object_t(p_codcomp_array.get(to_char(i) ) );
      v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');--User37 #3608 Final Test Phase 1 V11 09/12/2020
      if nvl(v_flg,'!@#$') <> 'delete' then
          for j in 0..p_codcomp_array.get_size - 1 loop
            param_json_row  := json_object_t(p_codcomp_array.get(to_char(j) ) );
            v_codcomp1      := hcm_util.get_string_t(param_json_row,'codcomp');
            v_flg           := hcm_util.get_string_t(param_json_row,'flg');--User37 #3608 Final Test Phase 1 V11 09/12/2020
            if nvl(v_flg,'!@#$') <> 'delete' then
                if i <> j then
                  if v_codcomp = v_codcomp1 then
                      param_msg_error := get_error_msg_php('HR1503',global_v_lang);
                      return;
                  end if;
                end if;
            end if;
          end loop;
      end if;
    end loop;*/
    /*for i in 0..p_codcomp_array.get_size - 1 loop
      param_json_row  := json_object_t(p_codcomp_array.get(to_char(i) ) );
      v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
      for j in 0..p_codcomp_array.get_size - 1 loop
        param_json_row  := json_object_t(p_codcomp_array.get(to_char(j) ) );
        v_codcomp1      := hcm_util.get_string_t(param_json_row,'codcomp');
        if i <> j then
          if v_codcomp = v_codcomp1 then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'codcomp');
              return;
          end if;
        end if;
      end loop;
    end loop;*/
    -->>User37 #3608 Final Test Phase 1 V11 09/12/2020
    for i in 0..p_codcomp_array.get_size - 1 loop
      param_json_row  := hcm_util.get_json_t(p_codcomp_array,to_char(i));--user37 #3604 Final Test Phase 1 V11 01/02/2021 param_json_row := json_object_t(p_codcomp_array.get(to_char(i) ) );
      v_codcomp := hcm_util.get_string_t(param_json_row,'codcomp');
      v_secur_codcomp := secur_main.secur7(v_codcomp,global_v_coduser);
      if v_secur_codcomp = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
        return;
      end if;

    end loop;

  end;

  procedure gen_data (json_str_output out clob) is
    idx                  number := 1;
    v_rcnt              number := 0;
    v_rcnt_upper     number := 0;
    v_rcnt_graph     number := 0;
    v_no_month       number := 0;
    v_qty_out        number := 0;
    v_qty_tot        number := 0;
    v_state          varchar2(4000 char);
    v_codcomp        varchar2(100 char);
    v_dteyrbug       number;
    v_dterybug_txt   varchar2(100 char);
    v_graph          varchar2(100 char);
    v_month          varchar2(100 char);
    v_dtemthbug      varchar2(100 char);
    v_item5          varchar2(100 char);    
    v_item8          varchar2(100 char):= '  ';
    v_chk_out        number := 0;

    cursor c1 is
      select codcomp
        from treppms8x
     where dteyear = p_dteyrbug
         and coduser = global_v_coduser
    order by codcomp;

  begin
    begin
      delete  ttemprpt where codapp = 'HRPMS8X' and codempid = global_v_codempid;
    end;

    v_rcnt_upper  := 0;
    v_rcnt := 0;
    obj_row   := json_object_t ();

--<<redmine PM-2033
      v_state := 'select count(codempid) sum_out '||
                       'from V_HRPMS8X '||
                       'where  dteeffec between to_date('''||'01/01/'||(p_dteyrbug)||''',''dd/mm/yyyy'') '||
                       'and last_day( to_date('''||'01/12/'||(p_dteyrbug)||''',''dd/mm/yyyy'') ) '||
                       'and exists  (select b.codcomp from treppms8x b '||
                       '              where b.dteyear = '||p_dteyrbug||
                       '                and b.coduser = '''||global_v_coduser||''' '||
                       '                and V_HRPMS8X.codcomp like b.codcomp||'||'''%'')'||
                       'and ('||p_syncond||')';
-- #3607
      v_state := v_state || ' and (numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                              ' and exists (select c.coduser from tusrcom c
                                             where c.coduser = '''||global_v_coduser||''' '||
                                             ' and codcomp like c.codcomp||'||'''%''))' ;
-- #3607 */
--User37 #3605 Final Test Phase 1 V11 09/12/2020 update a set a = v_state; commit ;
      v_qty_out := execute_qty(v_state);
      if v_qty_out is null then
        v_qty_out := 0;
      end if;

   if v_qty_out = 0  then
-- #3607         param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TEMPLOY1');
         v_state := 'select count(codempid) sum_out '||
                    'from V_HRPMS8X '||
                    'where  dteeffec between to_date('''||'01/01/'||(p_dteyrbug)||''',''dd/mm/yyyy'') '||
                    'and last_day( to_date('''||'01/12/'||(p_dteyrbug)||''',''dd/mm/yyyy'') ) '||
                    'and exists  (select b.codcomp from treppms8x b '||
                    '              where b.dteyear = '||p_dteyrbug||
                    '                and b.coduser = '''||global_v_coduser||''' '||
                    '                and V_HRPMS8X.codcomp like b.codcomp||'||'''%'')'||
                    'and ('||p_syncond||')';
         v_qty_out := execute_qty(v_state);
         if v_qty_out is null then
            v_qty_out := 0;
         end if;

         if v_qty_out = 0  then
             param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TEMPLOY1');
         else
             param_msg_error := get_error_msg_php('HR3007',global_v_lang,'TEMPLOY1');
         end if;
-- #3607
         json_str_output    := get_response_message(null, param_msg_error, global_v_lang);
         return;
   end if;
-->>redmine PM-2033

    for i in c1 loop
      obj_data      := json_object_t ();
      v_no_month    :=  0;
      v_chk_out     :=  0;
      v_rcnt_upper  := v_rcnt_upper + 1;
      v_codcomp     := i.codcomp;
      -- New employee, Dec previous
      v_state := 'select count(codempid) sum_out '||
                 'from V_HRPMS8X '||
                 'where codcomp like '''||v_codcomp||'%'' '||
                 'and dteeffec between to_date('''||'01/12/'||(p_dteyrbug-1)||''',''dd/mm/yyyy'') '||
                 'and last_day( to_date('''||'01/12/'||(p_dteyrbug-1)||''',''dd/mm/yyyy'') ) '||
                 'and ('||p_syncond||')';

-- #3607
      v_state := v_state || ' and (numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                              ' and exists (select c.coduser from tusrcom c
                                             where c.coduser = '''||global_v_coduser||''' '||
                                             ' and codcomp like c.codcomp||'||'''%'')) ' ;
-- #3607 */

      v_qty_out := execute_qty(v_state);

      if v_qty_out is null then
        v_qty_out := 0;
      end if;
      v_chk_out := v_chk_out + v_qty_out;

      v_dteyrbug := to_number(p_dteyrbug) - 1;
      v_dterybug_txt := to_char(v_dteyrbug) || '12';
      obj_data.put('coderror','200');
      obj_data.put('codcomp',v_codcomp ||' - '||get_tcenter_name(v_codcomp,global_v_lang));
       -- insert previous year
      insert into ttemprpt (codempid,codapp,numseq,item13,
                            item1, item2,
                            item4, item5,item7, 
                            item8,item9,
                            item10, item12, item31)
          values (global_v_codempid, 'HRPMS8X',idx,v_codcomp,
                  get_label_name('HRPMS8X',global_v_lang,19),--รายเดือน
                  get_label_name('HRPMS8X',global_v_lang,15)||v_dteyrbug,
                  v_rcnt_upper, --item4
                  v_codcomp, '2',
                  v_item8,--get_label_name('HRPMS8X',global_v_lang,2),--item8
                  get_label_name('HRAL1NX',global_v_lang,490),
                  v_qty_out,--item10
                  lpad(v_no_month,2,0), --item12
                  get_label_name('HRPMS8X',global_v_lang,17));
      idx := idx +1;

      obj_data.put('mount'||v_no_month,v_qty_out);
      v_no_month := v_no_month + 1;

      insert into ttemprpt (codempid,codapp,numseq,item13,
                            item1, item2, item4, item5, item7, item8,item9,item10, item12, item31)
      values (global_v_codempid, 'HRPMS8X', idx,v_codcomp,
              get_label_name('HRPMS8X',global_v_lang,18),--ราย ปี
              get_tcenter_name(v_codcomp,global_v_lang),
              lpad(v_rcnt,2,0), --item4
              get_label_name('HRPMS8X',global_v_lang,15)||v_dteyrbug,
              '2',
              v_item8,--get_label_name('HRPMS8X',global_v_lang,2),--item8
              get_label_name('HRAL1NX',global_v_lang,490),
              v_qty_out, --item10
              v_codcomp, --item12
              get_label_name('HRPMS8X',global_v_lang,17));
      idx := idx +1;

      for k in 1..12 loop
        v_month := to_char(k);
        if k < 10 then
          v_month := '0'||to_char(k);
        end if;

        v_state := 'select count(codempid) sum_out '||
                   'from V_HRPMS8X '||
                   'where codcomp like '''||v_codcomp||'%'' '||
                   'and dteeffec between to_date('''||'01/'||lpad(v_month,2,'0')||'/'||p_dteyrbug||''',''dd/mm/yyyy'') '||
                   'and last_day( to_date('''||'01/'||lpad(v_month,2,'0')||'/'||p_dteyrbug||''',''dd/mm/yyyy'') ) '||
                   'and ('||p_syncond||')';

-- #3607
      v_state := v_state || ' and (numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||
                              ' and exists (select c.coduser from tusrcom c
                                             where c.coduser = '''||global_v_coduser||''' '||
                                             ' and codcomp like c.codcomp||'||'''%''))' ;
-- #3607 */

        v_qty_out := execute_qty(v_state);

        if v_qty_out is null then
          v_qty_out := 0;
        end if;
        v_chk_out := v_chk_out + v_qty_out;
        if k = 1 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,4);
        end if;
        if k = 2 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,5);
        end if;
        if k = 3 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,6);
        end if;
        if k = 4 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,7);
        end if;
        if k = 5 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,8);
        end if;
        if k = 6 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,9);
        end if;
        if k = 7 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,10);
        end if;
        if k = 8 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,11);
        end if;
        if k = 9 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,12);
        end if;
        if k = 10 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,13);
        end if;
        if k = 11 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,14);
        end if;
        if k = 12 then
            v_graph := get_label_name('HRPMS8X',global_v_lang,15);
        end if;
        --year
        insert into ttemprpt (codempid,codapp,numseq,item13,
                              item1, item2, item4, item5, item7, item8,item9,item10, item12, item31)
             values (global_v_codempid, 'HRPMS8X',idx,v_codcomp,
                     get_label_name('HRPMS8X',global_v_lang,18),--ราย ปี
                     get_tcenter_name(v_codcomp,global_v_lang),
                     lpad(to_char(k+1),2,0),--item4
                     v_graph,
                     '2',
                     v_item8,--get_label_name('HRPMS8X',global_v_lang,2),--item8
                     get_label_name('HRAL1NX',global_v_lang,490),
                     v_qty_out,    --item10
                     v_codcomp,  --item12
                     get_label_name('HRPMS8X',global_v_lang,17) );
              idx := idx +1;
        --//--
        insert into ttemprpt (codempid,codapp,numseq,item13,
                              item1, item2, item4, item5,item7, 
                              item8,item9,item10, item12, item31)
            values (global_v_codempid, 'HRPMS8X',idx,v_codcomp,
                    get_label_name('HRPMS8X',global_v_lang,19), --รายเดือน
                    v_graph,
                    v_rcnt_upper,  --item4
                    v_codcomp,
                    '2',
                    v_item8,--get_label_name('HRPMS8X',global_v_lang,2),--item8
                    get_label_name('HRAL1NX',global_v_lang,490),
                    v_qty_out,   --item10
                    lpad(v_no_month,2,0),  --item12
                    get_label_name('HRPMS8X',global_v_lang,17) );
        idx := idx +1;

        obj_data.put('mount'||v_no_month,v_qty_out);
        v_no_month := v_no_month + 1;

      end loop;
      if v_chk_out <> 0 then
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1;
      else
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRPMS8X'
           and item13 = v_codcomp;
      end if;
    end loop;
    json_str_output := obj_row.to_clob;


  exception when no_data_found then
    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTEXEMPT');
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_data;

  procedure get_index ( json_str_input    in clob, json_str_output   out clob ) as
  begin
    initial_value(json_str_input);
    get_json_obj(json_str_input);
    check_getindex;
    if param_msg_error is null then
      --<<User37 #3604 Final Test Phase 1 V11 09/12/2020
      /*insert_treppms8x;
      delete_treppms8x;*/
      delete_treppms8x;
      insert_treppms8x;
      -->>User37 #3604 Final Test Phase 1 V11 09/12/2020
      if param_msg_error is null then
        gen_data(json_str_output);
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_treppms8x ( json_str_input    in clob, json_str_output   out clob ) as
  begin
    param_msg_error := null;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_treppms8x(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrpms8x;

/
