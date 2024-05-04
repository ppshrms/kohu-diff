--------------------------------------------------------
--  DDL for Package Body HRTR52X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR52X" AS
-- last update: 17/08/2022 12:13

   procedure initial_value(json_str_input in clob) as
        json_obj    json;
    begin
        json_obj            := json(json_str_input);

        --global
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

        -- index params
        p_codcomp          := hcm_util.get_string(json_obj, 'p_codcomp');
        p_typrep           := hcm_util.get_string(json_obj, 'p_typrep');
        p_dteyear          := hcm_util.get_string(json_obj, 'p_dteyear');
        p_dtemonthfr       := hcm_util.get_string(json_obj, 'p_dtemonthfr');
        p_dtemonthto       := hcm_util.get_string(json_obj, 'p_dtemonthto');
        p_breaklevel       := hcm_util.get_string(json_obj, 'p_breaklevel');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    end initial_value;

    procedure get_index_codcomp(json_str_input in clob, json_str_output out clob) as
        begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_index_codcomp(json_str_output);
        else
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end get_index_codcomp;

    procedure gen_index_codcomp (json_str_output out clob) as
        obj_data      json;
        obj_row       json := json();
        json_obj_graph   json     := json();
        v_countcodte  number := 0;
        v_percentcod  number := 0;
        v_rcnt        number := 0;
        v_complength  number := 0;
        v_check_codcompy  number := 0;
        v_codcomp     varchar2(40 char);
        v_tcenter     varchar2(40 char);
        v_complevel   varchar2(40 char);
        v_codcomp_sub varchar2(50 char);
        v_flg_exist       boolean := false;
        v_flg_secure      boolean := false;
        v_flg_permission     boolean := false;

        max_level         number;

            cursor c1 is
                select a.codcomp,count(codempid) countcodth,sum(amtcost) sumamt
                from  thistrnn a , tcenter b
                where a.codcomp = b.codcomp
                -- and   a.codcomp like rpad(rpad(p_codcomp, p_breaklevel*v_complength, '_'),v_complength*10,'0')
                and   a.codcomp like rpad(rpad(p_codcomp, p_breaklevel*v_complength, '_'),v_complength *  max_level,'0')
                and   dteyear = p_dteyear
                and   dtemonth between to_number(p_dtemonthfr) and to_number(p_dtemonthto)
                group by a.codcomp
                order by a.codcomp;

        begin
              begin
                  select max(numseq)  into max_level
                  from tsetcomp;
              end;


              v_complength := length(p_codcomp);
              select count(codcompy) into v_check_codcompy
              from tcompny
              where codcompy = p_codcomp;
              if v_check_codcompy = 0 then
                 param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              for r1 in c1 loop
                 v_flg_exist := true;
                 exit;
              end loop;

              if not v_flg_exist then
                 param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISTRNN');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

                for r1 in c1 loop
                    v_flg_secure := secur_main.secur7(r1.codcomp, global_v_coduser);
                    if v_flg_secure then
                        v_flg_permission := true;
                        v_tcenter := get_compful(r1.codcomp);
                        v_rcnt := v_rcnt + 1;
                        obj_data := json();
                        select nvl(count(distinct codempid),0) into v_countcodte
                        from temploy1
                        where codcomp = r1.codcomp;
                        if v_countcodte != 0 then
                            v_percentcod := (r1.countcodth*100)/v_countcodte;
                        end if;
                        v_codcomp_sub := get_codcomp_bylevel(r1.codcomp, p_breaklevel , '-');
                        if v_complength = '3' then
                            v_complevel := instr(v_codcomp_sub,'-000');
                        else
                            v_complevel := instr(v_codcomp_sub,'-0000');
                        end if;
                        if v_complevel > 0 then
                            v_codcomp_sub := substr(v_codcomp_sub,1,v_complevel-1);
                        end if;
                        obj_data.put('codcomp', v_codcomp_sub);
                        obj_data.put('namcomp', get_tcenter_name(v_tcenter, global_v_lang));
                        obj_data.put('qtyemp', v_countcodte);
                        obj_data.put('qtyp', r1.countcodth);
                        obj_data.put('qtyepp', round(v_percentcod,2));
                        obj_data.put('amtcost', r1.sumamt);
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                end loop;

      if not v_flg_permission and v_flg_exist then
         param_msg_error := get_error_msg_php('HR3007',global_v_lang);
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
    end gen_index_codcomp;

    procedure get_index_codcours(json_str_input in clob, json_str_output out clob) as
        begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_index_codcours(json_str_output);
        else
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end get_index_codcours;

    procedure gen_index_codcours (json_str_output out clob) as
        obj_data         json;
        obj_row          json     := json();
        json_obj_graph   json     := json();
        v_rcnt           number   := 0;
        v_check_codcompy number   := 0;
        v_sum_qtyp       number   := 0;
        v_sum_qtyc       number   := 0;
        v_sum_amtcost    number   := 0;
        v_total_qtyp     number   := 0;
        v_total_qtyc     number   := 0;
        v_total_amtcost  number   := 0;
        v_codcate  tcourse.codcate%type;
        v_flg_exist      boolean  := false;

        cursor c1 is
          select distinct codcate
            from thistrnn a , tcourse b
           where a.codcomp like p_codcomp||'%'
             and a.codcours = b.codcours
             and dteyear = p_dteyear
             and dtemonth between to_number(p_dtemonthfr) and to_number(p_dtemonthto)
        order by codcate;

        cursor c2 is
             select b.codcate codcate,a.codcours codcours,count(a.codempid) count_codempid,
                count(distinct(a.numclseq)) count_numclseq,sum(a.amtcost) sumamt
             from thistrnn a, tcourse b
             where a.codcours = b.codcours
             and a.codcomp like p_codcomp||'%'
             and b.codcate = v_codcate
             and   dteyear = p_dteyear
             and   dtemonth between to_number(p_dtemonthfr) and to_number(p_dtemonthto)
             group by b.codcate,a.codcours
             order by b.codcate,a.codcours;
    begin
          select count(codcompy) into v_check_codcompy
          from tcompny
          where codcompy = p_codcomp;

          if v_check_codcompy = 0 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
          end if;

          for r1 in c1 loop
             v_flg_exist := true;
             exit;
          end loop;

          if not v_flg_exist then
             param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISTRNN');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
          end if;

            for r1 in c1 loop
                v_codcate  := r1.codcate;
                for r2 in c2 loop
                    v_sum_qtyp := v_sum_qtyp + r2.count_codempid;
                    v_sum_qtyc := v_sum_qtyc + r2.count_numclseq;
                    v_sum_amtcost := v_sum_amtcost + r2.sumamt;
                    v_rcnt := v_rcnt + 1;
                    obj_data := json();
                    obj_data.put('namcate', get_tcodec_name('TCODCATE', r2.codcate, global_v_lang));
                    obj_data.put('codcours', r2.codcours);
                    obj_data.put('namcours', get_tcourse_name(r2.codcours,global_v_lang));
                    obj_data.put('qtyp', r2.count_codempid);
                    obj_data.put('qtyc', r2.count_numclseq);
                    obj_data.put('amtcost', r2.sumamt);
                    obj_row.put(to_char(v_rcnt-1),obj_data);
                end loop;
                v_rcnt := v_rcnt + 1;
                obj_data := json();
                obj_data.put('namcate', '');
                obj_data.put('codcours', '');
                obj_data.put('namcours', get_label_name('HRTR52XC2', global_v_lang, '130'));
                obj_data.put('qtyp', v_sum_qtyp);
                obj_data.put('qtyc', v_sum_qtyc);
                obj_data.put('amtcost', v_sum_amtcost);
                obj_row.put(to_char(v_rcnt-1),obj_data);
                v_total_qtyp := v_total_qtyp + v_sum_qtyp;
                v_total_qtyc := v_total_qtyc + v_sum_qtyc;
                v_total_amtcost := v_total_amtcost + v_sum_amtcost;
                v_sum_qtyp := 0;
                v_sum_qtyc := 0;
                v_sum_amtcost := 0;
             end loop;
                obj_data := json();
                obj_data.put('namcate', '');
                obj_data.put('codcours', '');
                obj_data.put('namcours', get_label_name('HRTR52XC2', global_v_lang, '140'));
                obj_data.put('qtyp', v_total_qtyp);
                obj_data.put('qtyc', v_total_qtyc);
                obj_data.put('amtcost', v_total_amtcost);
                obj_row.put(to_char(v_rcnt),obj_data);
        json_obj_graph := obj_row;
        gen_graph(json_obj_graph);
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index_codcours;

    procedure get_index_month(json_str_input in clob, json_str_output out clob) as
        begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_index_month(json_str_output);
        else
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end get_index_month;

    procedure gen_index_month (json_str_output out clob) as
    obj_data         json;
    obj_row          json      := json();
    json_obj_graph   json      := json();
    v_sum_emp        number;
    v_rcnt           number    := 0;
    v_sum_att_emp    number;
    v_sum_amt        number;
    v_percent        number;
    v_check_codcompy number    := 0;
    v_count          number    := 0;
    v_count2         number    := 0;
    v_flg_exist      boolean   := false;


    cursor c1 is
        select dtemonth, count(codempid) sum_att_emp, sum(amtcost) sum_amt
        from thistrnn
        where codcomp like p_codcomp||'%'
        and dteyear = p_dteyear
        and   dtemonth between to_number(p_dtemonthfr) and to_number(p_dtemonthto)
        group by dtemonth
        order by dtemonth;

    begin

         select count(codcompy) into v_check_codcompy
         from tcompny
         where codcompy = p_codcomp;

         if v_check_codcompy = 0 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
         end if;

         for r1 in c1 loop
             v_flg_exist := true;
             exit;
         end loop;

         if not v_flg_exist then
             param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISTRNN');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
         end if;

         for i in to_number(p_dtemonthfr)..to_number(p_dtemonthto) loop
             v_rcnt        := v_rcnt + 1;
             v_sum_att_emp      := 0;
             v_sum_amt          := 0;
             obj_data           := json();

            if i = p_dtemonthfr then
                select count(distinct codempid) into v_count
                  from ttaxcur
                 where dteyrepay = p_dteyear
                   and codcomp like p_codcomp||'%'
                   and dtemthpay = i;
                if v_count = 0 then
                    select count(distinct codempid) into v_count
                      from temploy1
                     where codcomp like p_codcomp||'%'
                       and (staemp = '1' or staemp = '3');
                 end if;
                 v_sum_emp := v_count;
             else
                select count(distinct codempid) into v_count2
                  from ttaxcur
                 where dteyrepay = p_dteyear
                   and codcomp like p_codcomp||'%'
                   and dtemthpay = i;
                   if v_count2 > 0 then
                        v_sum_emp := v_count2;
                    else
                        v_sum_emp := v_sum_emp;
                 end if;
             end if;
             obj_data.put('month', i);
             obj_data.put('month_short', get_tlistval_name('NAMMTHABB', i ,global_v_lang));
             obj_data.put('desc_month', get_tlistval_name('NAMMTHFUL', i ,global_v_lang));

             for r1 in c1 loop
                if i = r1.dtemonth then
                    v_sum_att_emp := r1.sum_att_emp;
                    v_sum_amt     := r1.sum_amt;
                end if;
             end loop;

             if v_sum_emp = 0 then
                v_percent := 0;
             else
                v_percent := (v_sum_att_emp*100)/v_sum_emp;
             end if;

             obj_data.put('qtyemp', v_sum_emp);
             obj_data.put('qtyp', v_sum_att_emp);
             obj_data.put('qtyepp', round(v_percent,2));
             obj_data.put('amtcost', nvl(v_sum_amt,0));
             obj_row.put(to_char(v_rcnt-1),obj_data);
         end loop;
        json_obj_graph := obj_row;
        gen_graph(json_obj_graph);
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index_month;

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
          v_rcnt      := v_rcnt+1;
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
        obj_data2   json;
        v_codempid  ttemprpt.codempid%type := global_v_codempid;
        v_codapp    ttemprpt.codapp%type := 'HRTR52X';
        v_numseq    ttemprpt.numseq%type := 1;
        v_item1     ttemprpt.item1%type  := null;
        v_item2     ttemprpt.item2%type  := null;
        v_item3     ttemprpt.item3%type  := null;
        v_item4     ttemprpt.item4%type;
        v_item5     ttemprpt.item5%type;
        v_item6     ttemprpt.item6%type;
        v_item7     ttemprpt.item7%type;
        v_item8     ttemprpt.item8%type;
        v_item9     ttemprpt.item9%type  := get_label_name('HRTR52XC2', global_v_lang, '40');
        v_item10    ttemprpt.item10%type;
        v_item14    ttemprpt.item14%type;
        v_item31    ttemprpt.item31%type;

        v_row       number;
        v_numitem4  number := 1;
        type t_codcours is table of thisclss.codcours%type;
        type t_sum is table of number;
        v_sum t_sum := t_sum();
        v_codcours t_codcours := t_codcours();
    begin
        v_item31 := get_label_name('HRTR52XC3', global_v_lang, p_typrep||'0');
        begin
          delete
            from ttemprpt
           where codempid = v_codempid
             and codapp = v_codapp;
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
          return;
        end;
        if p_typrep = 1 then
--            v_item6       := get_label_name('HRTR52XC2', global_v_lang, '20');
--            for v_filter in 1..2 loop
--                v_numitem4 := 1;
--                for i in 1..obj_row.count loop
--                       obj_data   := hcm_util.get_json(obj_row, to_char(i - 1));
--                       v_item4    := v_numitem4;
--                       v_item5    := hcm_util.get_string(obj_data,'namcomp');
--                    for j in 1..obj_row.count loop
--                       obj_data2  := hcm_util.get_json(obj_row, to_char(j - 1));
--                       v_item7    := hcm_util.get_string(obj_data2,'codcomp');
--                       v_item8    := hcm_util.get_string(obj_data2,'namcomp');
--                       if i = j then
--                            if v_filter = 1 then
--                                v_item1  := get_label_name('HRTR52XC2', global_v_lang, '50');
--                                v_item9  := get_label_name('HRTR52XC2', global_v_lang, '50');
--                                v_item10 := hcm_util.get_string(obj_data2,'qtyepp');
--                            elsif v_filter = 2 then
--                                v_item1  := get_label_name('HRTR52XC2', global_v_lang, '60');
--                                v_item9  := get_label_name('HRTR52XC2', global_v_lang, '60');
--                                v_item10 := hcm_util.get_string(obj_data2,'amtcost');
--                            end if;
--                       else
--                            v_item10 := 0;
--                       end if;
--                       begin
--                         insert into ttemprpt
--                                     (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31)
--                              values
--                                     (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31 );
--                      exception when dup_val_on_index then
--                                     rollback;
--                                     param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
--                             return;
--                      end;
--                      v_numseq := v_numseq + 1;
--                    end loop;
--                    v_numitem4 := v_numitem4 + 1;
--                end loop;
--            end loop;
-- Adisak redmine 4448#9250 07/04/2023 14:31
            v_item6       := get_label_name('HRTR52XC2', global_v_lang, '20');
            for v_filter in 1..2 loop
                v_numitem4 := 1;
                for i in 1..obj_row.count loop
                       obj_data   := hcm_util.get_json(obj_row, to_char(i - 1));
                       v_item4    := v_numitem4;
                       v_item5    := hcm_util.get_string(obj_data,'namcomp');
--                    for j in 1..obj_row.count loop
                       obj_data2  := hcm_util.get_json(obj_row, to_char(i - 1));
                       v_item7    := hcm_util.get_string(obj_data2,'codcomp');
                       v_item8    := hcm_util.get_string(obj_data2,'namcomp');
--                       if i = j then
                            if v_filter = 1 then
                                v_item1  := get_label_name('HRTR52XC2', global_v_lang, '50');
                                v_item9  := get_label_name('HRTR52XC2', global_v_lang, '50');
                                v_item10 := hcm_util.get_string(obj_data2,'qtyepp');
                            elsif v_filter = 2 then
                                v_item1  := get_label_name('HRTR52XC2', global_v_lang, '60');
                                v_item9  := get_label_name('HRTR52XC2', global_v_lang, '60');
                                v_item10 := hcm_util.get_string(obj_data2,'amtcost');
                            end if;
--                       else
--                            v_item10 := 0;
--                       end if;
                       begin
                         insert into ttemprpt
                                     (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item8, item9, item10, item31)
                              values
                                     (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item1, v_item9, v_item10, v_item31 );
                      exception when dup_val_on_index then
                                     rollback;
                                     param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                             return;
                      end;
                      v_numseq := v_numseq + 1;
--                    end loop;
                    v_numitem4 := v_numitem4 + 1;
                end loop;
            end loop;
-- Adisak redmine 4448#9250 07/04/2023 14:31
        elsif p_typrep = 2 then
--            v_item6       := get_label_name('HRTR52XC2', global_v_lang, '80');
--            for v_filter in 1..2 loop
--                v_sum := t_sum();
--                v_codcours := t_codcours();
--                v_numitem4 := 1;
--                v_item14   := lpad(v_filter, 2, '0');
--                for v_row in 1..obj_row.count loop
--                    obj_data   := hcm_util.get_json(obj_row, to_char(v_row - 1));
--                    if hcm_util.get_string(obj_data, 'codcours') is null then
--                        continue;
--                    end if;
--                    v_codcours.extend();
--                    v_codcours(v_codcours.last) := hcm_util.get_string(obj_data, 'codcours');
--                    v_sum.extend();
--                    if v_filter = 1 then
--                        v_sum(v_sum.last) := hcm_util.get_string(obj_data, 'qtyp');
--                    elsif v_filter = 2 then
--                        v_sum(v_sum.last) := hcm_util.get_string(obj_data, 'amtcost');
--                    end if;
--                end loop;
--                for i in 1..obj_row.count loop
--                    obj_data  := hcm_util.get_json(obj_row, to_char(i - 1));
--                    if hcm_util.get_string(obj_data, 'codcours') is null then
--                        continue;
--                    end if;
--                    for j in 1..v_codcours.count loop
--                        v_item4  := v_numitem4;
--                        v_item5  := hcm_util.get_string(obj_data, 'codcours');
--                        v_item7  := v_codcours(j);
--                        v_item8  := v_codcours(j);
--                        if v_filter = 1 then
--                             v_item1  := get_label_name('HRTR52XC2', global_v_lang, '40');
--                             v_item9  := get_label_name('HRTR52XC2', global_v_lang, '40');
--                        elsif v_filter = 2 then
--                             v_item1  := get_label_name('HRTR52XC2', global_v_lang, '60');
--                             v_item9  := get_label_name('HRTR52XC2', global_v_lang, '60');
--                        end if;
--                        if v_codcours(j) = hcm_util.get_string(obj_data, 'codcours') then
--                            v_item10 := v_sum(j);
--                        else
--                            v_item10 := 0;
--                        end if;
--                        begin
--                          insert into ttemprpt
--                            (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item14, item31)
--                          values
--                            (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item14, v_item31 );
--                         exception when dup_val_on_index then
--                           rollback;
--                             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
--                           return;
--                        end;
--                        v_numseq   := v_numseq + 1;
--                    end loop;
--                    v_numitem4 := v_numitem4 + 1;
--                end loop;
--            end loop;v
            v_item6       := get_label_name('HRTR52XC2', global_v_lang, '80');
            for v_filter in 1..2 loop
                v_sum := t_sum();
                v_codcours := t_codcours();
                v_numitem4 := 1;
                v_item14   := lpad(v_filter, 2, '0');
                for v_row in 1..obj_row.count loop
                    obj_data   := hcm_util.get_json(obj_row, to_char(v_row - 1));
--                    if hcm_util.get_string(obj_data, 'codcours') is null then
--                        continue;
--                    end if;
                    v_codcours.extend();
                    v_codcours(v_codcours.last) := hcm_util.get_string(obj_data, 'codcours');
                    v_sum.extend();
                    if v_filter = 1 then
                        v_sum(v_sum.last) := hcm_util.get_string(obj_data, 'qtyp');
                    elsif v_filter = 2 then
                        v_sum(v_sum.last) := hcm_util.get_string(obj_data, 'amtcost');
                    end if;
                end loop;
                for i in 1..obj_row.count loop
                    obj_data  := hcm_util.get_json(obj_row, to_char(i - 1));
                    if hcm_util.get_string(obj_data, 'codcours') is null then
                        continue;
                    end if;
--                    for j in 1..v_codcours.count loop
                        v_item4  := v_numitem4;
                        v_item5  := hcm_util.get_string(obj_data, 'codcours');
                        v_item7  := v_codcours(i);
                        v_item8  := v_codcours(i);
                        if v_filter = 1 then
                             v_item1  := get_label_name('HRTR52XC2', global_v_lang, '40');
                             v_item9  := get_label_name('HRTR52XC2', global_v_lang, '40');
                        elsif v_filter = 2 then
                             v_item1  := get_label_name('HRTR52XC2', global_v_lang, '60');
                             v_item9  := get_label_name('HRTR52XC2', global_v_lang, '60');
                        end if;
                        if v_codcours(i) = hcm_util.get_string(obj_data, 'codcours') then
                            v_item10 := v_sum(i);
                        else
                            v_item10 := 0;
                        end if;
                        begin
                          insert into ttemprpt
                            (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item8, item9, item10, item14, item31)
                          values
                            (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item1, v_item9, v_item10, v_item14, v_item31 );
                         exception when dup_val_on_index then
                           rollback;
                             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                           return;
                        end;
                        v_numseq   := v_numseq + 1;
--                    end loop;
                    v_numitem4 := v_numitem4 + 1;
                end loop;
            end loop;
-- Adisak redmine 4448#9250 07/04/2023 14:31
        elsif p_typrep = 3 then
            v_item6     := get_label_name('HRTR52XC2', global_v_lang, '110');
            v_item7     := null;
            for v_filter in 1..2 loop
                v_numitem4 := 1;
                v_item14   := lpad(v_filter, 2, '0');
                for i in 1..(to_number(p_dtemonthto)-to_number(p_dtemonthfr)+1) loop  -- Adisak redmine#9333 11/04/2023 10:08
                    obj_data   := hcm_util.get_json(obj_row, to_char(i - 1));
                    v_item4    := lpad(v_numitem4, 2, '0');
                    v_item5    := hcm_util.get_string(obj_data, 'month_short');
                    if v_filter = 1 then
                         v_item1  := get_label_name('HRTR52XC2', global_v_lang, '40');
                         v_item8  := get_label_name('HRTR52XC2', global_v_lang, '40');
                         v_item9  := get_label_name('HRTR52XC2', global_v_lang, '40');
                    elsif v_filter = 2 then
                        v_item1   := get_label_name('HRTR52XC2', global_v_lang, '60');
                         v_item8  := get_label_name('HRTR52XC2', global_v_lang, '60');
                         v_item9  := get_label_name('HRTR52XC2', global_v_lang, '60');
                    end if;
                    if i = hcm_util.get_string(obj_data, 'month') then
                        if v_filter = 1 then
                            v_item10 := hcm_util.get_string(obj_data, 'qtyp');
                        elsif v_filter = 2 then
                            v_item10 := hcm_util.get_string(obj_data, 'amtcost');
                        end if;
                    else
                        v_item10 := 0;
                    end if;
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
                    v_numitem4 := v_numitem4 + 1;
                end loop;
            end loop;
        end if;
    end gen_graph;

END HRTR52X;

/
