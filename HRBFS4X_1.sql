--------------------------------------------------------
--  DDL for Package Body HRBFS4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFS4X" as

  procedure initial_value(json_str_input in clob) as
    json_obj    json;
  begin
    json_obj            := json(json_str_input);

    -- global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

    -- index params
    p_codcomp          := hcm_util.get_string(json_obj, 'p_codcomp');
    p_dteyear          := hcm_util.get_string(json_obj, 'p_dteyear');
    p_dtemonthfr       := hcm_util.get_string(json_obj, 'p_dtemonthfr');
    p_dtemonthto       := hcm_util.get_string(json_obj, 'p_dtemonthto');
    p_typamt           := hcm_util.get_string(json_obj, 'p_typamt');
    p_typrep           := hcm_util.get_string(json_obj, 'p_typrep');
    p_breaklevel       := hcm_util.get_string(json_obj, 'p_breaklevel');

  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) as
    obj_row                   json    := json();
    obj_data                  json;
    json_obj_graph            json    := json();
    v_chk_codcomp             number  := 0;
    v_rcnt                    number  := 1;
    v_flg_secure              boolean := false;
    v_flg_exist               boolean := false;

    cursor c1 is
      select typamt
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by typamt
       order by typamt;

    cursor c2 is
      select
--            decode(typrelate ,'E', 50,60) lblrel ----
               to_char(dteyre)||'/'||lpad(dtemonth,2,'0') yearmonth
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by to_char(dteyre)||'/'||lpad(dtemonth,2,'0')
       order by to_char(dteyre)||'/'||lpad(dtemonth,2,'0');

    cursor c3 is
      select --decode(typrelate ,'E', 50,60) lblrel ----
             get_codcomp_bylevel(codcomp,p_breaklevel,null) codcomp_bylevel
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by get_codcomp_bylevel(codcomp,p_breaklevel,null)
       order by get_codcomp_bylevel(codcomp,p_breaklevel,null);

  begin
    select count(codcomp) into v_chk_codcomp
      from tcenter
     where codcomp like p_codcomp||'%' and rownum = 1;

    if v_chk_codcomp = 0 then
       param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    if p_codcomp is not null then
      v_flg_secure := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flg_secure then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    end if;

    if p_dtemonthto < p_dtemonthfr then
       param_msg_error := get_error_msg_php('HR2022',global_v_lang);
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;
    if p_typrep = '1' then -- by typamt
      for r1 in c1 loop
        v_flg_exist := true;
        obj_data := json();
        obj_data.put('typamt', get_tlistval_name('TYPAMT2',r1.typamt,global_v_lang));
        obj_data.put('typamt_search', get_tlistval_name('TYPAMT2',p_typamt,global_v_lang));
        obj_data.put('emp', get_label_name('HRBFS4XC2', global_v_lang, '50'));
        obj_data.put('empamt', r1.sum_amtsumin_emp);
        obj_data.put('qtyempamt',  r1.sum_qtysumin_emp);
        obj_data.put('fmy', get_label_name('HRBFS4XC2', global_v_lang, '60'));
        obj_data.put('fmypamt', r1.sum_amtsumin_fam);
        obj_data.put('qtyfmypamt',  r1.sum_qtysumin_fam);
        obj_row.put(to_char(v_rcnt-1),obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
    elsif p_typrep = '2' then -- by month
      for r2 in c2 loop
        v_flg_exist := true;
        obj_data := json();
        obj_data.put('typamt', ''); ----get_tlistval_name('TYPAMT2',p_typamt,global_v_lang));
        obj_data.put('typamt_search', get_tlistval_name('TYPAMT2',p_typamt,global_v_lang));
        obj_data.put('desc_month', get_nammthful(substr(r2.yearmonth,6,2),global_v_lang));
        obj_data.put('month_short', get_tlistval_name('NAMMTHABB', to_number(substr(r2.yearmonth,6,2)) ,global_v_lang));
        obj_data.put('emp', get_label_name('HRBFS4XC2', global_v_lang, '50'));
        obj_data.put('empamt', r2.sum_amtsumin_emp);
        obj_data.put('qtyempamt',  r2.sum_qtysumin_emp);
        obj_data.put('fmy', get_label_name('HRBFS4XC2', global_v_lang, '60'));
        obj_data.put('fmypamt', r2.sum_amtsumin_fam);
        obj_data.put('qtyfmypamt',  r2.sum_qtysumin_fam);
        obj_row.put(to_char(v_rcnt-1),obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
    elsif p_typrep = '3' then -- by codcomp
      for r3 in c3 loop
        v_flg_exist := true;
        obj_data := json();
        obj_data.put('typamt', ''); ----get_tlistval_name('TYPAMT2',p_typamt,global_v_lang));
        obj_data.put('typamt_search', get_tlistval_name('TYPAMT2',p_typamt,global_v_lang));
        obj_data.put('namcomp', get_tcenter_name(r3.codcomp_bylevel, global_v_lang));
        obj_data.put('emp', get_label_name('HRBFS4XC2', global_v_lang, '50'));
        obj_data.put('empamt', r3.sum_amtsumin_emp);
        obj_data.put('qtyempamt',  r3.sum_qtysumin_emp);
        obj_data.put('fmy', get_label_name('HRBFS4XC2', global_v_lang, '60'));
        obj_data.put('fmypamt', r3.sum_amtsumin_fam);
        obj_data.put('qtyfmypamt',  r3.sum_qtysumin_fam);
        obj_row.put(to_char(v_rcnt-1),obj_data);
        v_rcnt := v_rcnt + 1;
      end loop;
    end if;

    if not v_flg_exist then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TACCMEXP');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;
    json_obj_graph := obj_row;
    gen_graph(json_obj_graph);
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_dropdowns(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_dropdowns(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_dropdowns;

  procedure gen_dropdowns (json_str_output out clob) as
    obj_data        json;
    obj_row         json;
    v_rcnt          number := 0;

    cursor c_tcompnyc is
      select comlevel, namcente, namcentt, namcent3, namcent4, namcent5
        from tcompnyc
       where codcompy = p_codcomp
    order by comlevel;
  begin
    obj_row := json();
    for r1 in c_tcompnyc loop
      v_rcnt      := v_rcnt + 1;
      obj_data     := json();
      obj_data.put('coderror', '200');
      obj_data.put('comlevel', r1.comlevel);
      obj_data.put('namcente', r1.namcente);
      obj_data.put('namcentt', r1.namcentt);
      obj_data.put('namcent3', r1.namcent3);
      obj_data.put('namcent4', r1.namcent4);
      obj_data.put('namcent5', r1.namcent5);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_graph(obj_row in json) as
    obj_data    json;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRBFS4X';
    v_numseq    ttemprpt.numseq%type := 1;
    v_item1     ttemprpt.item1%type  := null;
    v_item2     ttemprpt.item2%type  := null;
    v_item12    ttemprpt.item2%type  := null;
    v_item3     ttemprpt.item3%type  := null;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item14    ttemprpt.item14%type;
    v_item31    ttemprpt.item31%type;
    v_numitem4  number;
    v_length    number := 0;

    ----<<
    cursor c1 is
      select typamt
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by typamt

       union --All typamt
      select 'Z' typamt
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
      order by 1;

    cursor c2 is
      select typamt
              , to_char(dteyre)||'/'||lpad(dtemonth,2,'0') yearmonth
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by typamt ,to_char(dteyre)||'/'||lpad(dtemonth,2,'0')

      union --All typamt
      select 'Z' typamt
              , to_char(dteyre)||'/'||lpad(dtemonth,2,'0') yearmonth
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by to_char(dteyre)||'/'||lpad(dtemonth,2,'0')
       order by 1,2;

    cursor c3 is
      select typamt
              , get_codcomp_bylevel(codcomp,p_breaklevel,null) codcomp_bylevel
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by typamt ,get_codcomp_bylevel(codcomp,p_breaklevel,null)

      union --All typamt
      select 'Z' typamt
              , get_codcomp_bylevel(codcomp,p_breaklevel,null) codcomp_bylevel
              , sum(decode(typrelate ,'E', amtsumin,0)) sum_amtsumin_emp
              , sum(decode(typrelate ,'E', qtysumin,0)) sum_qtysumin_emp
              , sum(decode(typrelate ,'E',0, amtsumin)) sum_amtsumin_fam
              , sum(decode(typrelate ,'E',0, qtysumin)) sum_qtysumin_fam
        from taccmexp
       where codcomp like p_codcomp||'%'
         and dteyre ||'/'||lpad(dtemonth,2,'0') between p_dteyear||'/'||lpad(p_dtemonthfr,2,'0') and
                                                        p_dteyear||'/'||lpad(p_dtemonthto,2,'0')
         and ( (p_typamt <> 'Z' and typamt = p_typamt) or p_typamt = 'Z')
       group by get_codcomp_bylevel(codcomp,p_breaklevel,null)
       order by 1,2;
    ---->>

  begin
    v_item31 := get_label_name('HRBFS4XC3', global_v_lang, p_typrep||'0');
    begin
      delete ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
      return;
    end;
    if p_typrep = '1' then -- by typamt ----
      for i in 0..1 loop -- loop item1
        v_numitem4 := 1;
        v_length := 0;
        for r1 in c1 loop
          v_length := v_length + 1;
          v_item2  := get_tlistval_name('TYPAMT2',r1.typamt,global_v_lang);
          v_item12 := r1.typamt;
          v_item4  := lpad(v_numitem4, v_length, '0');
          v_item14 := i + 1;
          for j in 0..1 loop
            if j = 0 then
              v_item5  := get_label_name('HRBFS4XC2', global_v_lang, '50');
              v_item8  := v_item2;
              if i = 0 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item10 := r1.sum_amtsumin_emp;
              elsif i = 1 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item10 := r1.sum_qtysumin_emp;
              end if;
            elsif j = 1 then
              v_item5  := get_label_name('HRBFS4XC2', global_v_lang, '60');
              v_item8  := v_item2;
              if i = 0 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item10 := r1.sum_amtsumin_fam;
              elsif i = 1 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item10 := r1.sum_qtysumin_fam;
              end if;
            end if;
            --
            begin
              insert into ttemprpt
                    (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item14, item31 ,item12)
                   values
                    (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item14, v_item31, v_item12);
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
            v_numseq   := v_numseq + 1;
          end loop;
          v_numitem4 := v_numitem4 + 1;
        end loop;
      end loop;
      --
      update ttemprpt set item4 = lpad(item4, v_length, '0')
       where codempid = v_codempid
         and codapp   = v_codapp;

    elsif p_typrep = '2' then -- by month
      for i in 0..1 loop -- loop item1
        v_numitem4 := 1;
        v_length := 0;
        for r2 in c2 loop
          v_length := v_length + 1;
          v_item2  := get_tlistval_name('TYPAMT2',r2.typamt,global_v_lang);
          v_item12 := r2.typamt;
          v_item4  := v_numitem4;
          v_item14 := i+1;
          v_item5  := get_tlistval_name('NAMMTHABB', to_number(substr(r2.yearmonth,6,2)) ,global_v_lang);
          for j in 0..1 loop
            if j = 0 then
              v_item8  := get_label_name('HRBFS4XC2', global_v_lang, '50');
              if i = 0 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item10 := r2.sum_amtsumin_emp;
              elsif i = 1 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item10 := r2.sum_qtysumin_emp;
              end if;
            elsif j = 1 then
              v_item8  := get_label_name('HRBFS4XC2', global_v_lang, '60');
              if i = 0 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item10 := r2.sum_amtsumin_fam;
              elsif i = 1 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item10 := r2.sum_qtysumin_fam;
              end if;
            end if;
            --
            begin
              insert into ttemprpt
                    (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item14, item31, item12)
                   values
                    (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item14, v_item31, v_item12);
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
            v_numseq   := v_numseq + 1;
          end loop;
          v_numitem4 := v_numitem4 + 1;
        end loop;
      end loop;
      --
      update ttemprpt set item4 = lpad(item4, v_length, '0')
       where codempid = v_codempid
         and codapp   = v_codapp;

    elsif p_typrep = '3' then -- by codcomp
      for i in 0..1 loop -- loop item1
        v_numitem4 := 1;
        v_length := 0;
        for r3 in c3 loop
          v_length := v_length + 1;
          v_item2  := get_tlistval_name('TYPAMT2',r3.typamt,global_v_lang);
          v_item12 := r3.typamt;
          v_item4  := v_numitem4;
          v_item14 := i+1;
          v_item5  := get_tcenter_name(r3.codcomp_bylevel, global_v_lang);
          for j in 0..1 loop
            if j = 0 then
              v_item8  := get_label_name('HRBFS4XC2', global_v_lang, '50');
              if i = 0 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item10 := r3.sum_amtsumin_emp;
              elsif i = 1 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item10 := r3.sum_qtysumin_emp;
              end if;
            elsif j = 1 then
              v_item8  := get_label_name('HRBFS4XC2', global_v_lang, '60');
              if i = 0 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
                v_item10 := r3.sum_amtsumin_fam;
              elsif i = 1 then
                v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
                v_item10 := r3.sum_qtysumin_fam;
              end if;
            end if;
            --
            begin
              insert into ttemprpt
                    (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item14, item31, item12)
                   values
                    (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item14, v_item31, v_item12);
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
            v_numseq   := v_numseq + 1;
          end loop;
          v_numitem4 := v_numitem4 + 1;
        end loop;
      end loop;
      --
      update ttemprpt set item4 = lpad(item4, v_length, '0')
       where codempid = v_codempid
         and codapp   = v_codapp;

    end if;
    ---->>
    /*Old, data from scren to graph
    v_length := length(obj_row.count);
    for i in 0..1 loop -- loop item1
      v_numitem4 := 1;
      for v_row in 1..obj_row.count loop
        obj_data := hcm_util.get_json(obj_row, to_char(v_row - 1));
        v_item2  := hcm_util.get_string(obj_data,'typamt');
        v_item4  := lpad(v_numitem4, v_length, '0');
        v_item14 := i+1;
        if p_typrep = '1' then
          v_item5  := hcm_util.get_string(obj_data,'typamt');
        elsif p_typrep = '2' then
          v_item5  := hcm_util.get_string(obj_data,'month_short');
        elsif p_typrep = '3' then
          v_item5  := hcm_util.get_string(obj_data,'namcomp');
        end if;
        for j in 0..1 loop
          if j = 0 then
            v_item8  := get_label_name('HRBFS4XC2', global_v_lang, '50');
            if i = 0 then
              v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
              v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
              v_item10 := hcm_util.get_string(obj_data,'empamt');
            elsif i = 1 then
              v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
              v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
              v_item10 := hcm_util.get_string(obj_data,'qtyempamt');
            end if;
          elsif j = 1 then
            v_item8  := get_label_name('HRBFS4XC2', global_v_lang, '60');
            if i = 0 then
              v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '70');
              v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '70');
              v_item10 := hcm_util.get_string(obj_data,'fmypamt');
            elsif i = 1 then
              v_item1  := get_label_name('HRBFS4XC2', global_v_lang, '80');
              v_item9  := get_label_name('HRBFS4XC2', global_v_lang, '80');
              v_item10 := hcm_util.get_string(obj_data,'qtyfmypamt');
            end if;
          end if;
          --
          begin
            insert into ttemprpt
                  (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item14, item31)
                 values
                  (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item14, v_item31 );
          exception when dup_val_on_index then
            rollback;
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
            return;
          end;
          v_numseq   := v_numseq + 1;
        end loop;
        v_numitem4 := v_numitem4 + 1;
      end loop;
    end loop;
    */
  end gen_graph;
end HRBFS4X;

/
